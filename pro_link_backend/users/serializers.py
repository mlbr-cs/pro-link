from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from interns.models import Intern, InternStatus
from mentors.models import Mentor

from .models import User, UserRole


class UserSerializer(serializers.ModelSerializer):
    photo_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id',
            'email',
            'role',
            'full_name',
            'photo_url',
            'is_approved',
            'is_active',
            'created_at',
        )

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
        user = User.objects.create_user(password=password, **validated_data)

        # Only non-admin accounts go through approval workflow.
        if not user.is_staff and not user.is_superuser:
            user.is_active = False
            user.is_approved = False
            user.save(update_fields=['is_active', 'is_approved'])

        # Ensure a role-specific profile exists so admin screens (interns/assign)
        # can load data immediately.
        if user.role == UserRole.INTERN:
            Intern.objects.get_or_create(
                user=user,
                defaults={'status': InternStatus.PENDING},
            )
        elif user.role == UserRole.MENTOR:
            Mentor.objects.get_or_create(user=user)

        return user


class LoginTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = User.USERNAME_FIELD

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        # If the account exists + password is correct but it's not approved yet,
        # return a clear "approval required" error (even though inactive users
        # won't authenticate via Django's auth backend).
        if email and password:
            user_by_email = User.objects.filter(email__iexact=email).first()
            if (
                user_by_email
                and (not user_by_email.is_staff and not user_by_email.is_superuser)
                and not user_by_email.is_approved
            ):
                if user_by_email.check_password(password):
                    raise serializers.ValidationError({"error": "Wait for admin approval"})

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
