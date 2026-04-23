import 'package:pro_link/models/attendance_record.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/skill_evaluation.dart';
import 'package:pro_link/models/timetable_entry.dart';
import 'package:pro_link/models/training_document.dart';

const List<Department> fakeDepartments = [
  Department(id: 'dep-hr', name: 'Human Resources'),
  Department(id: 'dep-eng', name: 'Engineering'),
  Department(id: 'dep-it', name: 'Information Technology'),
  Department(id: 'dep-ops', name: 'Operations'),
];

const List<MentorProfile> fakeMentors = [
  MentorProfile(
    id: 'mentor-1',
    name: 'Lucas Abdo',
    department: 'Engineering',
    email: 'mentor@prolink.edu',
  ),
  MentorProfile(
    id: 'mentor-2',
    name: 'Sophie Martin',
    department: 'Human Resources',
    email: 'sophie.martin@prolink.edu',
  ),
  MentorProfile(
    id: 'mentor-3',
    name: 'Daniel Novak',
    department: 'Information Technology',
    email: 'daniel.novak@prolink.edu',
  ),
];

const List<TrainingDocument> fakeTrainingDocuments = [
  TrainingDocument(
    id: 'doc-1',
    fileName: 'Workplace_Onboarding_Guide.pdf',
    category: 'Orientation',
  ),
  TrainingDocument(
    id: 'doc-2',
    fileName: 'Internship_Code_of_Conduct.pdf',
    category: 'Policy',
  ),
  TrainingDocument(
    id: 'doc-3',
    fileName: 'Weekly_Report_Template.docx',
    category: 'Reporting',
  ),
  TrainingDocument(
    id: 'doc-4',
    fileName: 'Security_Basics_Training.pptx',
    category: 'Compliance',
  ),
];

final List<Intern> fakeInterns = [
  Intern(
    id: 'intern-1',
    name: 'Mohamed Lamine',
    email: 'intern@prolink.edu',
    universityId: 'PRL-2026-001',
    departmentId: 'dep-eng',
    departmentName: 'Engineering',
    mentorId: 'mentor-1',
    mentorName: 'Lucas Abdo',
    registrationPending: false,
    performanceScore: 16.5,
    performanceComment: 'Shows strong initiative and consistent delivery.',
    skillEvaluations: const [
      SkillEvaluation(
        title: 'Technical Skills',
        score: 17.0,
        feedback: 'Reliable implementation quality and good debugging habits.',
      ),
      SkillEvaluation(
        title: 'Communication',
        score: 15.5,
        feedback: 'Professional updates and responsive collaboration.',
      ),
      SkillEvaluation(
        title: 'Time Management',
        score: 16.0,
        feedback: 'Keeps deadlines visible and follows through well.',
      ),
    ],
    timetable: const [
      TimetableEntry(
        day: 'Sunday',
        morning: 'Backend Review',
        afternoon: 'Mentor Check-in',
      ),
      TimetableEntry(
        day: 'Monday',
        morning: 'Development Tasks',
        afternoon: 'Documentation',
      ),
      TimetableEntry(
        day: 'Tuesday',
        morning: 'UI Testing',
        afternoon: 'Project Work',
      ),
      TimetableEntry(
        day: 'Wednesday',
        morning: 'Department Standup',
        afternoon: 'Learning Session',
      ),
      TimetableEntry(
        day: 'Thursday',
        morning: 'Code Review',
        afternoon: 'Weekly Report',
      ),
    ],
    attendance: const [
      AttendanceRecord(weekLabel: 'Week 1', isPresent: true),
      AttendanceRecord(weekLabel: 'Week 2', isPresent: true),
      AttendanceRecord(weekLabel: 'Week 3', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 4', isPresent: true),
    ],
  ),
  Intern(
    id: 'intern-2',
    name: 'Emma Boussaid',
    email: 'emma.boussaid@prolink.edu',
    universityId: 'PRL-2026-002',
    departmentId: 'dep-it',
    departmentName: 'Information Technology',
    mentorId: 'mentor-3',
    mentorName: 'Daniel Novak',
    registrationPending: false,
    performanceScore: 14.0,
    performanceComment: 'Good learning curve and steady participation.',
    skillEvaluations: const [
      SkillEvaluation(
        title: 'Technical Skills',
        score: 14.0,
        feedback:
            'Solid fundamentals with room for deeper system understanding.',
      ),
      SkillEvaluation(
        title: 'Adaptability',
        score: 15.0,
        feedback: 'Responds well to new tasks and shifting priorities.',
      ),
      SkillEvaluation(
        title: 'Teamwork',
        score: 13.0,
        feedback:
            'Collaborates well and asks clarifying questions when needed.',
      ),
    ],
    timetable: const [
      TimetableEntry(
        day: 'Sunday',
        morning: 'Infrastructure Briefing',
        afternoon: 'System Access Setup',
      ),
      TimetableEntry(
        day: 'Monday',
        morning: 'Ticket Resolution',
        afternoon: 'Database Practice',
      ),
      TimetableEntry(
        day: 'Tuesday',
        morning: 'Security Workshop',
        afternoon: 'Project Support',
      ),
      TimetableEntry(
        day: 'Wednesday',
        morning: 'Lab Session',
        afternoon: 'Mentor Review',
      ),
      TimetableEntry(
        day: 'Thursday',
        morning: 'Documentation',
        afternoon: 'Weekly Debrief',
      ),
    ],
    attendance: const [
      AttendanceRecord(weekLabel: 'Week 1', isPresent: true),
      AttendanceRecord(weekLabel: 'Week 2', isPresent: true),
      AttendanceRecord(weekLabel: 'Week 3', isPresent: true),
      AttendanceRecord(weekLabel: 'Week 4', isPresent: true),
    ],
  ),
  Intern(
    id: 'intern-3',
    name: 'Yanis Haddad',
    email: 'yanis.haddad@prolink.edu',
    universityId: 'PRL-2026-003',
    departmentId: 'dep-ops',
    departmentName: 'Operations',
    mentorId: 'mentor-2',
    mentorName: 'Sophie Martin',
    registrationPending: true,
    performanceScore: null,
    performanceComment: null,
    skillEvaluations: const [
      SkillEvaluation(
        title: 'Professional Conduct',
        score: 0,
        feedback: 'Pending registration approval.',
      ),
    ],
    timetable: const [
      TimetableEntry(
        day: 'Sunday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Monday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Tuesday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Wednesday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Thursday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
    ],
    attendance: const [
      AttendanceRecord(weekLabel: 'Week 1', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 2', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 3', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 4', isPresent: false),
    ],
  ),
  Intern(
    id: 'intern-4',
    name: 'Sara Belkacem',
    email: 'sara.belkacem@prolink.edu',
    universityId: 'PRL-2026-004',
    departmentId: 'dep-hr',
    departmentName: 'Human Resources',
    mentorId: 'mentor-2',
    mentorName: 'Sophie Martin',
    registrationPending: true,
    performanceScore: null,
    performanceComment: null,
    skillEvaluations: const [
      SkillEvaluation(
        title: 'Professional Conduct',
        score: 0,
        feedback: 'Pending registration approval.',
      ),
    ],
    timetable: const [
      TimetableEntry(
        day: 'Sunday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Monday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Tuesday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Wednesday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
      TimetableEntry(
        day: 'Thursday',
        morning: 'Pending Approval',
        afternoon: 'Pending Approval',
      ),
    ],
    attendance: const [
      AttendanceRecord(weekLabel: 'Week 1', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 2', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 3', isPresent: false),
      AttendanceRecord(weekLabel: 'Week 4', isPresent: false),
    ],
  ),
];
