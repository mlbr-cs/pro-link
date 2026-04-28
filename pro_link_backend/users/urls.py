from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    ApproveUserView,
    LoginView,
    MeView,
    PendingUsersView,
    RegisterView,
    RejectUserView,
)

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='auth-register'),
    path('auth/login/', LoginView.as_view(), name='auth-login'),
    path('auth/me/', MeView.as_view(), name='auth-me'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('pending-users/', PendingUsersView.as_view(), name='pending-users'),
    path('approve-user/<int:id>/', ApproveUserView.as_view(), name='approve-user'),
    path('reject-user/<int:id>/', RejectUserView.as_view(), name='reject-user'),
]
