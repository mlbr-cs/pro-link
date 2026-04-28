from django.conf import settings
from django.db import models


class Mentor(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='mentor_profile',
    )
    department = models.ForeignKey(
        'interns.Department',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='mentors',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return self.user.email


class Evaluation(models.Model):
    intern = models.ForeignKey(
        'interns.Intern',
        on_delete=models.CASCADE,
        related_name='evaluations',
    )
    mentor = models.ForeignKey(
        'mentors.Mentor',
        on_delete=models.CASCADE,
        related_name='evaluations',
    )
    score = models.DecimalField(max_digits=5, decimal_places=2)
    comment = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self) -> str:
        return f'{self.intern_id} {self.score}'


class TrainingFile(models.Model):
    mentor = models.ForeignKey(
        'mentors.Mentor',
        on_delete=models.CASCADE,
        related_name='training_files',
    )
    file = models.FileField(upload_to='training_files/')
    file_name = models.CharField(max_length=255)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-uploaded_at']

    @property
    def file_url(self):
        try:
            return self.file.url
        except Exception:
            return ''

    def __str__(self) -> str:
        return self.file_name
