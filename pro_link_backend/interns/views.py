from collections import defaultdict

from django.db.models import Prefetch
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from users.models import UserRole

from .models import Attendance, Department, Intern, InternStatus, Schedule
from .serializers import (
    AttendanceSerializer,
    DepartmentSerializer,
    InternProfileSerializer,
    InternSerializer,
    ScheduleSerializer,
)


class InternViewSet(viewsets.ModelViewSet):
    queryset = (
        Intern.objects.select_related('user', 'department', 'mentor', 'mentor__user', 'mentor__department')
    )
    serializer_class = InternSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_queryset(self):
        qs = super().get_queryset()
        role = getattr(self.request.user, 'role', None)
        if role == UserRole.ADMIN:
            return qs
        if role == UserRole.MENTOR:
            return qs.filter(mentor__user=self.request.user)
        if role == UserRole.INTERN:
            return qs.filter(user=self.request.user)
        return qs.none()

    def perform_create(self, serializer):
        # If user_id not provided, default to current user.
        if serializer.validated_data.get('user') is None:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

    @action(detail=True, methods=['patch'], url_path='status')
    def status(self, request, pk=None):
        intern = self.get_object()
        new_status = (request.data.get('status') or '').lower().strip()
        allowed = {choice for choice, _ in InternStatus.choices}
        if new_status not in allowed:
            return Response(
                {'detail': f'Invalid status. Allowed: {", ".join(sorted(allowed))}'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        intern.status = new_status
        intern.save(update_fields=['status'])
        return Response(self.get_serializer(intern).data, status=200)

    @action(detail=True, methods=['patch'], url_path='assign')
    def assign(self, request, pk=None):
        intern = self.get_object()
        department_id = request.data.get('department_id')
        mentor_id = request.data.get('mentor_id')

        if department_id is not None:
            intern.department_id = department_id or None
        if mentor_id is not None:
            intern.mentor_id = mentor_id or None

        intern.save(update_fields=['department_id', 'mentor_id'])
        intern.refresh_from_db()
        return Response(self.get_serializer(intern).data, status=200)


class DepartmentListView(generics.ListAPIView):
    queryset = Department.objects.all().order_by('name')
    serializer_class = DepartmentSerializer
    permission_classes = [permissions.IsAuthenticated]


class ScheduleViewSet(viewsets.ModelViewSet):
    queryset = Schedule.objects.select_related('department')
    serializer_class = ScheduleSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'head', 'options']


class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.select_related('intern', 'intern__user')
    serializer_class = AttendanceSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'head', 'options']


class InternProfileView(generics.RetrieveAPIView):
    serializer_class = InternSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return Intern.objects.select_related(
            'user',
            'department',
            'mentor',
            'mentor__user',
            'mentor__department',
        ).get(user=self.request.user)


class InternScheduleView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request, *args, **kwargs):
        intern = Intern.objects.select_related('department').filter(user=request.user).first()
        if intern is None or intern.department_id is None:
            return Response([], status=200)

        schedules = (
            Schedule.objects.filter(department_id=intern.department_id)
            .select_related('department')
            .order_by('day', 'start_time')
        )

        # Convert schedule slots into the shape Flutter expects (`TimetableEntry`):
        # { day, start_slot, end_slot } (Flutter maps to morning/afternoon)
        by_day = defaultdict(list)
        for item in schedules:
            by_day[item.day].append(item)

        payload = []
        for day, items in by_day.items():
            start = items[0].start_time.strftime('%H:%M') if items else ''
            end = items[-1].end_time.strftime('%H:%M') if items else ''
            payload.append({'day': day, 'start_slot': start, 'end_slot': end})

        return Response(payload, status=200)

from django.shortcuts import render

# Create your views here.
