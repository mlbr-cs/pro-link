from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from interns.models import Intern, InternStatus
from mentors.models import Mentor
from users.models import UserRole

from .models import User
from .permissions import IsAdminRole
from .serializers import (
    LoginTokenObtainPairSerializer,
    RegisterSerializer,
    UserSerializer,
)


class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(UserSerializer(user, context={'request': request}).data, status=201)


class LoginView(TokenObtainPairView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []
    serializer_class = LoginTokenObtainPairSerializer


class MeView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user, context={'request': request}).data, status=200)


class PendingUsersView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        users = User.objects.filter(
            is_approved=False,
            is_staff=False,
            is_superuser=False,
        ).order_by('-created_at')
        return Response(
            UserSerializer(users, many=True, context={'request': request}).data,
            status=status.HTTP_200_OK,
        )


class ApproveUserView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, id: int):
        user = get_object_or_404(User, id=id)

        # Admin/staff are always approved by model.save() anyway; this is safe.
        user.is_approved = True
        user.is_active = True
        user.save(update_fields=['is_approved', 'is_active'])

        # Keep role-specific profile in sync.
        if user.role == UserRole.INTERN:
            intern, _ = Intern.objects.get_or_create(user=user)
            intern.status = InternStatus.APPROVED
            intern.save(update_fields=['status'])
        elif user.role == UserRole.MENTOR:
            Mentor.objects.get_or_create(user=user)

        return Response(
            UserSerializer(user, context={'request': request}).data,
            status=status.HTTP_200_OK,
        )


class RejectUserView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, id: int):
        user = get_object_or_404(User, id=id)

        # Reject = keep unapproved and disable login.
        user.is_approved = False
        user.is_active = False
        user.save(update_fields=['is_approved', 'is_active'])

        if user.role == UserRole.INTERN:
            intern = Intern.objects.filter(user=user).first()
            if intern is not None:
                intern.status = InternStatus.REJECTED
                intern.save(update_fields=['status'])

        return Response(
            UserSerializer(user, context={'request': request}).data,
            status=status.HTTP_200_OK,
        )
