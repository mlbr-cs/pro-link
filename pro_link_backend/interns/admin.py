from django.contrib import admin

from .models import Department, Intern, Schedule


@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "description")
    search_fields = ("name",)


@admin.register(Intern)
class InternAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "university_id", "status", "department", "mentor", "created_at")
    list_filter = ("status", "department")
    search_fields = ("user__email", "user__full_name", "university_id")
    autocomplete_fields = ("user", "department", "mentor")


@admin.register(Schedule)
class ScheduleAdmin(admin.ModelAdmin):
    list_display = ("id", "department", "day", "start_time", "end_time", "subject")
    list_filter = ("department", "day")
    search_fields = ("subject",)
    autocomplete_fields = ("department",)
