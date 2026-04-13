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

## Getting Started

### Prerequisites
- Flutter SDK >= 3.x
- Dart >= 3.x
- A running backend API (see `/backend` folder or API docs)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/pro-link.git
cd pro-link

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Setup

Create a `.env` file or update `lib/services/api_service.dart` with your API base URL:

```dart
const String baseUrl = 'http://your-server.com/api';
```

---

## Team & Branch Strategy

| Member | Responsibility | Branch |
|--------|---------------|--------|
| Person 1 | Admin screens + API setup | `feature/admin-*` |
| Person 2 | Mentor screens + database | `feature/mentor-*` |
| Person 3 | Intern screens + UI/design | `feature/intern-*` |

### Git workflow

```bash
# Always pull before starting work
git pull origin dev

# Create your feature branch
git checkout -b feature/your-feature-name

# Commit and push
git add .
git commit -m "Short description of what you did"
git push origin feature/your-feature-name

# Open a Pull Request into dev on GitHub
```

Never push directly to `main`. All changes go through `dev` first.

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
