from django.contrib import admin

from .models import Evaluation, Mentor, TrainingFile


@admin.register(Mentor)
class MentorAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "department", "created_at")
    list_filter = ("department",)
    search_fields = ("user__email", "user__full_name")
    autocomplete_fields = ("user", "department")


@admin.register(Evaluation)
class EvaluationAdmin(admin.ModelAdmin):
    list_display = ("id", "intern", "mentor", "score", "created_at")
    list_filter = ("mentor",)
    search_fields = ("intern__user__email", "mentor__user__email")
    autocomplete_fields = ("intern", "mentor")


@admin.register(TrainingFile)
class TrainingFileAdmin(admin.ModelAdmin):
    list_display = ("id", "mentor", "file_name", "uploaded_at")
    list_filter = ("mentor",)
    search_fields = ("file_name", "mentor__user__email")
    autocomplete_fields = ("mentor",)
