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

## License

This project is submitted as academic work for Constantine 2 University. All rights reserved by the project team.
