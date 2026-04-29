from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('interns', '0002_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='ScheduleFile',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('file', models.FileField(upload_to='schedule_files/')),
                ('file_name', models.CharField(max_length=255)),
                ('uploaded_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'ordering': ['-uploaded_at'],
            },
        ),
    ]
