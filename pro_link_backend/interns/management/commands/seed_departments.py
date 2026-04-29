from django.core.management.base import BaseCommand

from interns.models import Department


class Command(BaseCommand):
    help = "Seed a few default departments (safe to re-run)."

    DEFAULTS = [
        ("Computer Science", "Computer science department."),
        ("Computer Security", "Computer security / cybersecurity department."),
        ("Information Systems", "Information systems department."),
        ("Software Engineering", "Software engineering department."),
        ("Networks", "Networks and systems department."),
    ]

    def handle(self, *args, **options):
        created = 0
        for name, description in self.DEFAULTS:
            _, was_created = Department.objects.get_or_create(
                name=name,
                defaults={"description": description},
            )
            created += int(was_created)

        self.stdout.write(self.style.SUCCESS(f"Departments created: {created}"))

