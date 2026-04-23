import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/services/app_data_provider.dart';
import 'package:pro_link/services/auth_provider.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  static const routeName = '/mentor';

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dataProvider = context.watch<AppDataProvider>();
    final mentorName = authProvider.currentUser?.name ?? 'Mentor User';
    final assignedInterns = dataProvider.internsForMentor(mentorName);

    if (dataProvider.isLoading && dataProvider.interns.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _MentorOverview(mentorName: mentorName, assignedInterns: assignedInterns),
      _AssignedInternList(interns: assignedInterns),
      _PerformanceMarksScreen(interns: assignedInterns),
      _MentorTrainingFilesScreen(
        selectedFileName: dataProvider.mentorTrainingFileName,
      ),
      _AttendanceTrackerScreen(interns: assignedInterns),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: SingleChildScrollView(
            key: ValueKey(_currentIndex),
            padding: const EdgeInsets.all(20),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Interns',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon: Icon(Icons.grade),
            label: 'Marks',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}

class _MentorOverview extends StatelessWidget {
  const _MentorOverview({
    required this.mentorName,
    required this.assignedInterns,
  });

  final String mentorName;
  final List<Intern> assignedInterns;

  @override
  Widget build(BuildContext context) {
    final submittedMarks = assignedInterns
        .where((intern) => intern.performanceScore != null)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mentor Workspace',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your assigned interns, evaluations, file uploads, and attendance records.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        _MentorMetricCard(
          label: 'Signed In',
          value: mentorName,
          icon: Icons.manage_accounts_outlined,
        ),
        const SizedBox(height: 14),
        _MentorMetricCard(
          label: 'Assigned Interns',
          value: assignedInterns.length.toString(),
          icon: Icons.groups_2_outlined,
        ),
        const SizedBox(height: 14),
        _MentorMetricCard(
          label: 'Submitted Performance Marks',
          value: submittedMarks.toString(),
          icon: Icons.rate_review_outlined,
        ),
      ],
    );
  }
}

class _AssignedInternList extends StatelessWidget {
  const _AssignedInternList({required this.interns});

  final List<Intern> interns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Interns',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Overview of interns currently assigned to this mentor.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        if (interns.isEmpty)
          const _MentorEmptyState(
            title: 'No assigned interns',
            subtitle: 'Assignments created by the admin will appear here.',
          )
        else
          ...interns.map((intern) => _MentorInternCard(intern: intern)),
      ],
    );
  }
}

class _PerformanceMarksScreen extends StatelessWidget {
  const _PerformanceMarksScreen({required this.interns});

  final List<Intern> interns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Marks',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Submit or update an evaluation score and comment for each assigned intern.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        if (interns.isEmpty)
          const _MentorEmptyState(
            title: 'No evaluations available',
            subtitle:
                'Intern evaluations will appear when mentor assignments exist.',
          )
        else
          ...interns.map((intern) => _PerformanceFormCard(intern: intern)),
      ],
    );
  }
}

class _MentorTrainingFilesScreen extends StatelessWidget {
  const _MentorTrainingFilesScreen({required this.selectedFileName});

  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Training Files',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a supporting file for interns. For now, only the selected file name is stored.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (!context.mounted ||
                      result == null ||
                      result.files.isEmpty) {
                    return;
                  }

                  context.read<AppDataProvider>().setMentorTrainingFileName(
                    result.files.single.name,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved ${result.files.single.name} to local mentor state.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Select Training File'),
              ),
              const SizedBox(height: 16),
              Text(
                selectedFileName == null
                    ? 'No training file selected yet.'
                    : 'Selected file: $selectedFileName',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475467),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceTrackerScreen extends StatelessWidget {
  const _AttendanceTrackerScreen({required this.interns});

  final List<Intern> interns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Attendance Tracker',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Toggle present or absent for each intern by week.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        if (interns.isEmpty)
          const _MentorEmptyState(
            title: 'No attendance records',
            subtitle:
                'Attendance tracking becomes available once interns are assigned.',
          )
        else
          ...interns.map((intern) => _AttendanceCard(intern: intern)),
      ],
    );
  }
}

class _MentorMetricCard extends StatelessWidget {
  const _MentorMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF1B263B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorInternCard extends StatelessWidget {
  const _MentorInternCard({required this.intern});

  final Intern intern;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intern.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${intern.departmentName} • ${intern.email}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 12),
          Text(
            'Current mark: ${intern.performanceScore?.toStringAsFixed(1) ?? 'Not submitted'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PerformanceFormCard extends StatefulWidget {
  const _PerformanceFormCard({required this.intern});

  final Intern intern;

  @override
  State<_PerformanceFormCard> createState() => _PerformanceFormCardState();
}

class _PerformanceFormCardState extends State<_PerformanceFormCard> {
  late final TextEditingController _scoreController;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.intern.performanceScore?.toStringAsFixed(1) ?? '',
    );
    _commentController = TextEditingController(
      text: widget.intern.performanceComment ?? '',
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.intern.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Score',
              hintText: 'Enter a mark out of 20',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comment',
              hintText: 'Add a short professional evaluation',
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                final score = double.tryParse(_scoreController.text.trim());
                if (score == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid score.'),
                    ),
                  );
                  return;
                }

                context.read<AppDataProvider>().savePerformanceMark(
                  internId: widget.intern.id,
                  score: score,
                  comment: _commentController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved performance mark for ${widget.intern.name}.',
                    ),
                  ),
                );
              },
              child: const Text('Save Mark'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.intern});

  final Intern intern;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intern.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...intern.attendance.map(
            (record) => SwitchListTile(
              value: record.isPresent,
              contentPadding: EdgeInsets.zero,
              title: Text(record.weekLabel),
              subtitle: Text(record.isPresent ? 'Present' : 'Absent'),
              onChanged: (value) {
                context.read<AppDataProvider>().updateAttendance(
                  internId: intern.id,
                  weekLabel: record.weekLabel,
                  isPresent: value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorEmptyState extends StatelessWidget {
  const _MentorEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}
