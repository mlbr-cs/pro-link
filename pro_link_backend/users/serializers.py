from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import User, UserRole


class UserSerializer(serializers.ModelSerializer):
    photo_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('id', 'email', 'role', 'full_name', 'photo_url', 'created_at')

    def get_photo_url(self, obj: User):
        request = self.context.get('request')
        if not obj.photo:
            return None
        if request is None:
            return obj.photo.url
        return request.build_absolute_uri(obj.photo.url)


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    role = serializers.ChoiceField(choices=UserRole.choices, required=False)

    class Meta:
        model = User
        fields = ('email', 'password', 'full_name', 'role', 'photo')

    def create(self, validated_data):
        password = validated_data.pop('password')
        return User.objects.create_user(password=password, **validated_data)


class LoginTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = User.USERNAME_FIELD

    def validate(self, attrs):
        # Ensure authenticate() uses email
        user = authenticate(
            request=self.context.get('request'),
            email=attrs.get('email'),
            password=attrs.get('password'),
        )
        if user is None:
            raise serializers.ValidationError('Invalid email or password.')

        data = super().validate(attrs)
        data['user'] = UserSerializer(user, context=self.context).data
        return data
