# Pro-Link -Enterprise Internship & Skill Tracking

**Pro-Link** is a Flutter-based internship management platform designed to strengthen collaboration between universities and organizations. It provides a centralized system for managing internships, monitoring student progress, evaluating professional skills, and issuing digital work IDs.

The project was developed collaboratively as part of a university mobile development project.

## Features

### Admin

* Manage and validate intern registrations
* Assign interns to departments and mentors
* Upload office schedules and policy documents
* Oversee internship activities and records

### Mentor

* Evaluate intern performance
* Submit assessments and marks
* Upload training materials and resources
* Track attendance for assigned interns

### Intern

* Register and await approval
* View a digital work ID card
* Access schedules and training resources
* Review evaluations and skill assessments

---

## Tech Stack

| Layer          | Technology            |
| -------------- | --------------------- |
| Frontend       | Flutter (Dart)        |
| Backend        | Django REST Framework |
| Authentication | JWT (JSON Web Tokens) |
| Database       | PostgreSQL            |
| File Storage   | Server-side uploads   |

---

## 📁 Project Structure

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

---

## 🚀 Getting Started

### Frontend

```bash
flutter pub get
flutter run
```

### Backend

```bash
cd pro_link_backend

python -m venv venv

# Activate the virtual environment
# Windows:
venv\Scripts\activate

# Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Create a `.env` file (or copy `.env.example`) and configure the required environment variables before running the backend.

---

## 🔐 Authentication API

| Method | Endpoint                   | Description                        |
| ------ | -------------------------- | ---------------------------------- |
| POST   | `/api/auth/register/`      | Register a new user                |
| POST   | `/api/auth/login/`         | Authenticate and obtain JWT tokens |
| GET    | `/api/auth/me/`            | Retrieve current user information  |
| POST   | `/api/auth/token/refresh/` | Refresh an access token            |

---

## 📌 Key Highlights

* Multi-role access (Admin, Mentor, Intern)
* JWT-based authentication
* Internship tracking and management
* Digital work ID generation
* Skill evaluation and performance monitoring
* Training resources and schedule management

---

## Team Project

This repository represents a collaborative academic project developed by multiple contributors. Both the mobile application and backend services were designed to work together to provide a complete internship management solution.

---

## License

This project is intended for educational purposes. Feel free to explore the code and adapt it for learning or personal projects in accordance with the repository license.
