from django.conf import settings
from django.db import models


class Department(models.Model):
    name = models.CharField(max_length=255, unique=True)
    description = models.TextField(blank=True, default='')

    def __str__(self) -> str:
        return self.name


class InternStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    APPROVED = 'approved', 'Approved'
    REJECTED = 'rejected', 'Rejected'


class Intern(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='intern_profile',
    )
    department = models.ForeignKey(
        'interns.Department',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='interns',
    )
    mentor = models.ForeignKey(
        'mentors.Mentor',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='interns',
    )
    status = models.CharField(
        max_length=20,
        choices=InternStatus.choices,
        default=InternStatus.PENDING,
    )
    work_id_number = models.CharField(max_length=64, blank=True, default='')
    university_id = models.CharField(max_length=64, blank=True, default='')

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f'{self.user.email} ({self.status})'


class AttendanceStatus(models.TextChoices):
    PRESENT = 'present', 'Present'
    ABSENT = 'absent', 'Absent'


class Attendance(models.Model):
    intern = models.ForeignKey(
        'interns.Intern',
        on_delete=models.CASCADE,
        related_name='attendance_records',
    )
    week = models.CharField(max_length=64)
    status = models.CharField(max_length=10, choices=AttendanceStatus.choices)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = (('intern', 'week'),)
        ordering = ['-created_at']

    def __str__(self) -> str:
        return f'{self.intern_id} {self.week}: {self.status}'


class WeekDay(models.TextChoices):
    MONDAY = 'monday', 'Monday'
    TUESDAY = 'tuesday', 'Tuesday'
    WEDNESDAY = 'wednesday', 'Wednesday'
    THURSDAY = 'thursday', 'Thursday'
    FRIDAY = 'friday', 'Friday'
    SATURDAY = 'saturday', 'Saturday'
    SUNDAY = 'sunday', 'Sunday'


class Schedule(models.Model):
    department = models.ForeignKey(
        'interns.Department',
        on_delete=models.CASCADE,
        related_name='schedules',
    )
    day = models.CharField(max_length=10, choices=WeekDay.choices)
    start_time = models.TimeField()
    end_time = models.TimeField()
    subject = models.CharField(max_length=255)

    class Meta:
        ordering = ['day', 'start_time']

    def __str__(self) -> str:
        return f'{self.department.name} {self.day} {self.start_time}-{self.end_time}'
