import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/services/auth_provider.dart';
import 'package:pro_link/widgets/work_id_card.dart';

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  static const routeName = '/intern';

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    final pages = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intern Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your internship progress, documents, and schedule in one place.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 24),
          const _InternSummaryCard(
            title: 'Progress Review',
            detail: '3 milestones completed, next mentor check-in on Thursday.',
            icon: Icons.timeline_outlined,
          ),
          const SizedBox(height: 14),
          const _InternSummaryCard(
            title: 'Required Documents',
            detail:
                'Placement agreement, weekly report, and final evaluation placeholder.',
            icon: Icons.folder_copy_outlined,
          ),
          const SizedBox(height: 14),
          const _InternSummaryCard(
            title: 'Attendance',
            detail:
                'This area is ready for future REST API attendance tracking.',
            icon: Icons.access_time_outlined,
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Digital Work ID',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Corporate identity card for internship verification and workplace access.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 24),
          WorkIdCard(
            name: user?.name ?? 'Intern User',
            department: user?.department ?? 'Software Engineering',
            email: user?.email ?? 'intern@prolink.edu',
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Session details and future account settings area.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 24),
          _InternSummaryCard(
            title: 'Name',
            detail: user?.name ?? 'mohamed lamine',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _InternSummaryCard(
            title: 'Email',
            detail: user?.email ?? 'intern@prolink.edu',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 14),
          _InternSummaryCard(
            title: 'Department',
            detail: user?.department ?? 'Computer security Engineering',
            icon: Icons.apartment_outlined,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
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
        child: pages[_currentIndex],
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Work ID',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
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

class _InternSummaryCard extends StatelessWidget {
  const _InternSummaryCard({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
          ),
        ],
      ),
    );
  }
}
