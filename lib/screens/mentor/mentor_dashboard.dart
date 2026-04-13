import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final user = context.watch<AuthProvider>().currentUser;

    final sections = [
      const _MentorPanel(
        title: 'Mentor Workspace',
        subtitle: 'Supervise intern progress and review planned milestones.',
        content: Column(
          children: [
            _MentorStatCard(label: 'Assigned Interns', value: '06'),
            SizedBox(height: 14),
            _MentorStatCard(label: 'Reports Awaiting Feedback', value: '04'),
            SizedBox(height: 14),
            _MentorStatCard(label: 'Meetings This Week', value: '03'),
          ],
        ),
      ),
      const _MentorPanel(
        title: 'Evaluation Flow',
        subtitle: 'Placeholder actions ready for the API-backed sprint.',
        content: Column(
          children: [
            _MentorActionTile(
              title: 'Submit performance review',
              detail: 'Quarterly assessment form for current cohort',
            ),
            SizedBox(height: 14),
            _MentorActionTile(
              title: 'Validate attendance logs',
              detail: 'Pending check-in confirmation for 6 interns',
            ),
            SizedBox(height: 14),
            _MentorActionTile(
              title: 'Approve deliverables',
              detail: '2 project files are ready for review',
            ),
          ],
        ),
      ),
      _MentorPanel(
        title: 'Mentor Profile',
        subtitle: 'Current session details for ${user?.name ?? 'Mentor User'}',
        content: Column(
          children: [
            _MentorActionTile(
              title: 'Department',
              detail: user?.department ?? 'Industry Partnerships',
            ),
            const SizedBox(height: 14),
            _MentorActionTile(
              title: 'Email',
              detail: user?.email ?? 'mentor@prolink.edu',
            ),
            const SizedBox(height: 14),
            const _MentorActionTile(
              title: 'Role Access',
              detail:
                  'Mentor dashboard, evaluation queue, and intern follow-up',
            ),
          ],
        ),
      ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: sections[_currentIndex],
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
            icon: Icon(Icons.rule_folder_outlined),
            selectedIcon: Icon(Icons.rule_folder),
            label: 'Reviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Profile',
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

class _MentorPanel extends StatelessWidget {
  const _MentorPanel({
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        content,
      ],
    );
  }
}

class _MentorStatCard extends StatelessWidget {
  const _MentorStatCard({required this.label, required this.value});

  final String label;
  final String value;

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_search_outlined),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B263B),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorActionTile extends StatelessWidget {
  const _MentorActionTile({required this.title, required this.detail});

  final String title;
  final String detail;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF667085),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
