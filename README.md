# Pro-Link — Enterprise Internship & Skill Tracking

A Flutter-based professional management app that bridges the gap between university and the corporate world. Pro-Link streamlines the internship process by allowing companies to track student progress, manage corporate IDs, and evaluate professional skills in a centralized environment.

> Built for the Mobile Development module — Constantine 2 University (Abdelhamid Mehri), Department of Fundamental Computing and its Applications (IFA), 2025–2026.

---

## Features

### Admin (HR / University Coordinator)
- Manage and validate intern registrations
- Assign interns to departments and mentors
- Upload office schedules and policy handbooks

### Mentor (Professional Supervisor / Teacher)
- Evaluate intern performance and submit marks
- Upload training modules and resources
- Track weekly attendance for assigned groups

### Intern (Student)
- Register and await admin validation
- View Digital Work ID card with photo and department info
- Access shift schedules, training files, and skill evaluations

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend | REST API (Laravel / Node.js) |
| Database | MySQL / PostgreSQL |
| Auth | JWT (JSON Web Tokens) |
| File storage | Server-side upload (multipart/form-data) |

> Note: SQLite is not used per project requirements.

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── intern.dart
│   └── evaluation.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   └── assign_intern_screen.dart
│   ├── mentor/
│   │   ├── mentor_dashboard.dart
│   │   └── mark_evaluation_screen.dart
│   └── intern/
│       ├── intern_dashboard.dart
│       └── work_id_screen.dart
├── services/
│   └── api_service.dart
└── widgets/
    ├── work_id_card.dart
    └── search_bar.dart
```

---

---

## Sprints

| Sprint | Focus | Points |
|--------|-------|--------|
| Sprint 1 | Frontend UI & role dashboards | 3 pts |
| Sprint 2 | Core functions per role | 2.5 pts |
| Sprint 3 | Backend, auth & data handling | 2.5 pts |
| Sprint 4 | Search & responsive design | 1 pt |
| Creativity | Extra APIs, notifications, design | 2 pts |

---

## License

This project is submitted as academic work for Constantine 2 University. All rights reserved by the project team.

---

## Backend Team Setup

The backend authentication foundation for the team now lives in `pro_link_backend/`.

### Backend stack
- Django REST Framework
- PostgreSQL
- JWT with `djangorestframework-simplejwt`
- `django-cors-headers`
- `python-decouple`

### Folder

```text
pro_link_backend/
├── manage.py
├── requirements.txt
├── .env.example
├── pro_link/
│   ├── settings.py
│   └── urls.py
└── users/
    ├── models.py
    ├── serializers.py
    ├── views.py
    ├── urls.py
    └── permissions.py
```

### Team workflow
- The `users` app owns authentication and the custom `User` model.
- Other backend teammates should import role guards from `users/permissions.py`.
- Interns and mentors apps should use `settings.AUTH_USER_MODEL` for any user relation.
- Auth routes are mounted under `/api/auth/`.

### Setup
1. Create a virtual environment inside `pro_link_backend/`.
2. Install packages from `requirements.txt`.
3. Copy `.env.example` to `.env` and update `SECRET_KEY`, `DEBUG`, and `DATABASE_URL`.
4. Run `python manage.py makemigrations users`.
5. Run `python manage.py migrate`.
6. Start the server with `python manage.py runserver`.

### Available auth endpoints
- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `GET /api/auth/me/`
- `POST /api/auth/token/refresh/`
