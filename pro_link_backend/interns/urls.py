from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    AttendanceViewSet,
    DepartmentListView,
    InternProfileView,
    InternScheduleView,
    InternViewSet,
    ScheduleViewSet,
)

router = DefaultRouter()
router.register(r'interns', InternViewSet, basename='intern')
router.register(r'schedules', ScheduleViewSet, basename='schedule')
router.register(r'attendance', AttendanceViewSet, basename='attendance')

urlpatterns = [
    path('', include(router.urls)),
    path('departments/', DepartmentListView.as_view(), name='departments'),
    path('intern/profile/', InternProfileView.as_view(), name='intern-profile'),
    path('intern/schedule/', InternScheduleView.as_view(), name='intern-schedule'),
]

