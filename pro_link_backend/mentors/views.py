from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from interns.models import Intern
from interns.serializers import InternSerializer
from users.models import UserRole

from .models import Evaluation, Mentor, TrainingFile
from .serializers import (
    EvaluationInlineSerializer,
    EvaluationSerializer,
    MentorSerializer,
    TrainingFileSerializer,
)


class MentorListView(generics.ListAPIView):
    queryset = Mentor.objects.select_related('user', 'department').order_by('user__full_name')
    serializer_class = MentorSerializer
    permission_classes = [permissions.IsAuthenticated]


class MentorInternsView(generics.ListAPIView):
    serializer_class = InternSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        mentor = Mentor.objects.filter(user=self.request.user).first()
        if mentor is None:
            return Intern.objects.none()
        return Intern.objects.select_related(
            'user',
            'department',
            'mentor',
            'mentor__user',
            'mentor__department',
        ).filter(mentor_id=mentor.id)


class EvaluationViewSet(viewsets.ModelViewSet):
    queryset = Evaluation.objects.select_related('intern', 'mentor', 'mentor__user')
    serializer_class = EvaluationSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def perform_create(self, serializer):
        mentor = Mentor.objects.filter(user=self.request.user).first()
        if mentor is None:
            return serializer.save()
        serializer.save(mentor=mentor)

    def partial_update(self, request, *args, **kwargs):
        # Allow PATCH /api/evaluations/{id}/
        return super().partial_update(request, *args, **kwargs)


class TrainingFileViewSet(viewsets.ModelViewSet):
    queryset = TrainingFile.objects.select_related('mentor', 'mentor__user')
    serializer_class = TrainingFileSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'head', 'options']

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx['request'] = self.request
        return ctx

    def perform_create(self, serializer):
        mentor = Mentor.objects.filter(user=self.request.user).first()
        if mentor is None:
            return serializer.save()
        serializer.save(mentor=mentor)


class InternEvaluationsView(generics.ListAPIView):
    serializer_class = EvaluationInlineSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        intern = Intern.objects.filter(user=self.request.user).first()
        if intern is None:
            return Evaluation.objects.none()
        return Evaluation.objects.filter(intern_id=intern.id)


class InternTrainingFilesView(generics.ListAPIView):
    serializer_class = TrainingFileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx['request'] = self.request
        return ctx

    def get_queryset(self):
        # If the intern has a mentor, return that mentor's training files; otherwise return all.
        intern = Intern.objects.select_related('mentor').filter(user=self.request.user).first()
        if intern is None:
            return TrainingFile.objects.none()
        if intern.mentor_id:
            return TrainingFile.objects.filter(mentor_id=intern.mentor_id)
        return TrainingFile.objects.all()

from django.shortcuts import render

# Create your views here.
