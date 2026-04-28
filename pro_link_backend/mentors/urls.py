from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    EvaluationViewSet,
    InternEvaluationsView,
    InternTrainingFilesView,
    MentorInternsView,
    MentorListView,
    TrainingFileViewSet,
)

router = DefaultRouter()
router.register(r'evaluations', EvaluationViewSet, basename='evaluation')
router.register(r'training-files', TrainingFileViewSet, basename='training-file')

urlpatterns = [
    path('mentors/', MentorListView.as_view(), name='mentors'),
    path('mentor/interns/', MentorInternsView.as_view(), name='mentor-interns'),
    path('intern/evaluations/', InternEvaluationsView.as_view(), name='intern-evaluations'),
    path('intern/training-files/', InternTrainingFilesView.as_view(), name='intern-training-files'),
    path('', include(router.urls)),
]

