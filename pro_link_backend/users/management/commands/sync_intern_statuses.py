from django.core.management.base import BaseCommand
from django.db import transaction

from interns.models import Intern, InternStatus
from users.models import UserRole


class Command(BaseCommand):
    help = "Sync Intern.status from users approval flags (keeps rejected interns rejected)."

    def handle(self, *args, **options):
        with transaction.atomic():
            updated_to_approved = 0
            updated_to_pending = 0

            qs = Intern.objects.select_related("user").all()
            for intern in qs:
                user = intern.user
                if getattr(user, "role", None) != UserRole.INTERN:
                    continue

                # Never override explicit rejections.
                if intern.status == InternStatus.REJECTED:
                    continue

                desired = (
                    InternStatus.APPROVED
                    if getattr(user, "is_approved", False)
                    else InternStatus.PENDING
                )
                if intern.status != desired:
                    intern.status = desired
                    intern.save(update_fields=["status"])
                    if desired == InternStatus.APPROVED:
                        updated_to_approved += 1
                    else:
                        updated_to_pending += 1

            self.stdout.write(
                self.style.SUCCESS(
                    f"Synced interns. To approved: {updated_to_approved}. To pending: {updated_to_pending}."
                )
            )

