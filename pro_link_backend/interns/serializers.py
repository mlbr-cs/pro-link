from django.contrib.auth import get_user_model
from rest_framework import serializers

from mentors.models import Mentor
from users.serializers import UserSerializer

from .models import Attendance, Department, Intern, Schedule


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = ('id', 'name', 'description')


class MentorInlineSerializer(serializers.Serializer):
    id = serializers.CharField()
    full_name = serializers.CharField()
    email = serializers.EmailField()
    department = serializers.SerializerMethodField()

    def get_department(self, obj):
        dept = getattr(obj, 'department', None)
        if dept is None:
            return None
        return {'id': dept.id, 'name': dept.name}


class InternSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    department = DepartmentSerializer(read_only=True)
    mentor = serializers.SerializerMethodField()
    registration_pending = serializers.SerializerMethodField()

    department_id = serializers.PrimaryKeyRelatedField(
        source='department',
        queryset=Department.objects.all(),
        write_only=True,
        required=False,
        allow_null=True,
    )
    mentor_id = serializers.PrimaryKeyRelatedField(
        source='mentor',
        queryset=Mentor.objects.all(),
        write_only=True,
        required=False,
        allow_null=True,
    )
    user_id = serializers.PrimaryKeyRelatedField(
        source='user',
        queryset=get_user_model().objects.all(),
        write_only=True,
        required=False,
    )

    class Meta:
        model = Intern
        fields = (
            'id',
            'user',
            'user_id',
            'full_name',
            'email',
            'university_id',
            'department',
            'department_id',
            'mentor',
            'mentor_id',
            'status',
            'registration_pending',
            'work_id_number',
            'created_at',
        )
        read_only_fields = ('user', 'created_at')

    def get_registration_pending(self, obj: Intern) -> bool:
        return (obj.status or '').lower() == 'pending'

    def get_mentor(self, obj: Intern):
        mentor = getattr(obj, 'mentor', None)
        if mentor is None:
            return None
        user = mentor.user
        return {
            'id': mentor.id,
            'full_name': user.full_name,
            'email': user.email,
            'department': {'id': mentor.department_id, 'name': mentor.department.name}
            if mentor.department_id
            else None,
        }


class AttendanceSerializer(serializers.ModelSerializer):
    week_label = serializers.CharField(source='week', read_only=True)
    is_present = serializers.SerializerMethodField()

    class Meta:
        model = Attendance
        fields = (
            'id',
            'intern',
            'week',
            'week_label',
            'status',
            'is_present',
            'created_at',
        )
        read_only_fields = ('created_at',)

    def get_is_present(self, obj: Attendance) -> bool:
        return (obj.status or '').lower() == 'present'


class ScheduleSerializer(serializers.ModelSerializer):
    start_slot = serializers.SerializerMethodField()
    end_slot = serializers.SerializerMethodField()

    class Meta:
        model = Schedule
        fields = (
            'id',
            'department',
            'day',
            'start_time',
            'end_time',
            'start_slot',
            'end_slot',
            'subject',
        )

    def get_start_slot(self, obj: Schedule) -> str:
        return obj.start_time.strftime('%H:%M')

    def get_end_slot(self, obj: Schedule) -> str:
        return obj.end_time.strftime('%H:%M')


class InternProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    department = DepartmentSerializer(read_only=True)
    mentor = serializers.SerializerMethodField()

    class Meta:
        model = Intern
        fields = (
            'id',
            'user',
            'university_id',
            'department',
            'mentor',
            'status',
            'work_id_number',
        )

    def get_mentor(self, obj: Intern):
        mentor = getattr(obj, 'mentor', None)
        if mentor is None:
            return None
        return {
            'id': mentor.id,
            'full_name': mentor.user.full_name,
            'email': mentor.user.email,
        }

