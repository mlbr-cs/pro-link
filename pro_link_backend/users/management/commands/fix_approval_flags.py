from django.core.management.base import BaseCommand
from django.db import transaction

from users.models import User


class Command(BaseCommand):
    help = "Fix approval flags: auto-approve staff/superusers; keep normal users pending."

    def handle(self, *args, **options):
        with transaction.atomic():
            admin_qs = User.objects.filter(is_staff=True) | User.objects.filter(is_superuser=True)
            admin_qs = admin_qs.distinct()

            updated_admins = admin_qs.update(is_approved=True, is_active=True)

            self.stdout.write(
                self.style.SUCCESS(f"Updated {updated_admins} staff/superuser accounts to approved+active.")
            )

