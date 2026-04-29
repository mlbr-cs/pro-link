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
    performance_evaluation = serializers.SerializerMethodField()

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
            'performance_evaluation',
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

    def get_performance_evaluation(self, obj: Intern):
        # Return the latest evaluation (if any) so Flutter can display "Current mark"
        # and prefill mentor edit forms.
        try:
            from mentors.models import Evaluation
        except Exception:
            return None

        evaluation = (
            Evaluation.objects.filter(intern_id=obj.id).order_by('-created_at').first()
        )
        if evaluation is None:
            return None
        return {
            'id': evaluation.id,
            'score': evaluation.score,
            'comment': evaluation.comment,
            'created_at': evaluation.created_at,
        }


class AttendanceSerializer(serializers.ModelSerializer):
    week_label = serializers.CharField(source='week', required=False)
    is_present = serializers.BooleanField(write_only=True, required=False)

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

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['is_present'] = (getattr(instance, 'status', '') or '').lower() == 'present'
        return data

    def validate(self, attrs):
        # Support Flutter payload:
        # { intern, week_label, is_present }
        if 'week' not in attrs and 'week_label' in self.initial_data:
            attrs['week'] = self.initial_data.get('week_label')

        if 'status' not in attrs and 'is_present' in self.initial_data:
            is_present = self.initial_data.get('is_present')
            if isinstance(is_present, str):
                is_present = is_present.lower() in ('1', 'true', 'yes', 'y')
            attrs['status'] = 'present' if is_present else 'absent'
        return attrs


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

