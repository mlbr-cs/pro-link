from rest_framework import serializers

from interns.serializers import DepartmentSerializer
from users.serializers import UserSerializer

from .models import Evaluation, Mentor, TrainingFile


class MentorSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    department = DepartmentSerializer(read_only=True)

    class Meta:
        model = Mentor
        fields = ('id', 'full_name', 'email', 'department', 'created_at')


class EvaluationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evaluation
        fields = ('id', 'intern', 'mentor', 'score', 'comment', 'created_at')
        read_only_fields = ('created_at',)


class EvaluationInlineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evaluation
        fields = ('id', 'score', 'comment', 'created_at')


class TrainingFileSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()
    download_url = serializers.SerializerMethodField()
    category = serializers.SerializerMethodField()

    class Meta:
        model = TrainingFile
        fields = (
            'id',
            'mentor',
            'file_name',
            'file_url',
            'download_url',
            'category',
            'uploaded_at',
            'file',
        )
        extra_kwargs = {'file': {'write_only': True}}

    def get_file_url(self, obj: TrainingFile):
        request = self.context.get('request')
        if request is None:
            return obj.file_url
        return request.build_absolute_uri(obj.file_url)

    def get_download_url(self, obj: TrainingFile):
        return self.get_file_url(obj)

    def get_category(self, obj: TrainingFile):
        return 'Training File'

    def create(self, validated_data):
        uploaded = validated_data.get('file')
        if uploaded is not None and not validated_data.get('file_name'):
            validated_data['file_name'] = getattr(uploaded, 'name', 'file')
        return super().create(validated_data)

