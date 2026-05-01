import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:pro_link/services/app_data_provider.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final dataProvider = context.watch<AppDataProvider>();
    final currentUser = authProvider.currentUser;
    final intern = currentUser == null
        ? null
        : dataProvider.internByEmail(currentUser.email);

    if (dataProvider.isLoading && dataProvider.interns.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _InternOverview(intern: intern),
      _SkillMarksScreen(intern: intern),
      _ScheduleScreen(
        intern: intern,
        scheduleFiles: dataProvider.scheduleFiles,
      ),
      _DocumentsScreen(documents: dataProvider.trainingDocuments),
      _DigitalIdScreen(intern: intern, photoUrl: currentUser?.photoUrl),
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
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: SingleChildScrollView(
            key: ValueKey(_currentIndex),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dataProvider.errorMessage != null)
                  _DashboardErrorBanner(message: dataProvider.errorMessage!),
                pages[_currentIndex],
              ],
            ),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon: Icon(Icons.grade),
            label: 'Marks',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Docs',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Work ID',
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) {
      return;
    }
    context.read<AppDataProvider>().clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}

class _InternOverview extends StatelessWidget {
  const _InternOverview({required this.intern});

  final Intern? intern;

  @override
  Widget build(BuildContext context) {
    if (intern == null) {
      return const _InternEmptyState(
        title: 'No intern profile found',
        subtitle: 'A matching backend intern account could not be loaded.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intern Placement Overview',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'See your department, assigned mentor, and current internship details.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        _OverviewCard(label: 'Intern Name', value: intern!.name),
        const SizedBox(height: 14),
        _OverviewCard(label: 'Department', value: intern!.departmentName),
        const SizedBox(height: 14),
        _OverviewCard(label: 'Assigned Mentor', value: intern!.mentorName),
        const SizedBox(height: 14),
        _OverviewCard(label: 'University ID', value: intern!.universityId),
      ],
    );
  }
}

class _SkillMarksScreen extends StatelessWidget {
  const _SkillMarksScreen({required this.intern});

  final Intern? intern;

  @override
  Widget build(BuildContext context) {
    if (intern == null) {
      return const _InternEmptyState(
        title: 'No evaluations available',
        subtitle: 'Skill evaluation data is not available for this account.',
      );
    }

    if (intern!.skillEvaluations.isEmpty) {
      return const _InternEmptyState(
        title: 'No marks available yet',
        subtitle:
            'Evaluation marks will appear here after your mentor submits them.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Evaluation Marks',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Clean summary of your current evaluation results.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = intern!.skillEvaluations.map(
              (evaluation) => Container(
                width: double.infinity,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            evaluation.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          evaluation.score.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B263B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evaluation.feedback,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList();

            if (constraints.maxWidth > 600 && cards.isNotEmpty) {
              return Wrap(
                spacing: 14,
                runSpacing: 0,
                children: cards.map((card) => SizedBox(
                  width: (constraints.maxWidth - 14) / 2,
                  child: card,
                )).toList(),
              );
            }
            return Column(children: cards);
          },
        ),
      ],
    );
  }
}

class _ScheduleScreen extends StatelessWidget {
  const _ScheduleScreen({required this.intern, required this.scheduleFiles});

  final Intern? intern;
  final List<String> scheduleFiles;

  @override
  Widget build(BuildContext context) {
    if (intern == null) {
      return const _InternEmptyState(
        title: 'No schedule available',
        subtitle: 'Weekly timetable data is not available for this account.',
      );
    }

    if (intern!.timetable.isEmpty && scheduleFiles.isEmpty) {
      return const _InternEmptyState(
        title: 'No timetable returned yet',
        subtitle:
            'Your schedule will appear here once the backend provides timetable data.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Timetable',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Structured weekly schedule loaded from the backend.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        if (scheduleFiles.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = scheduleFiles.map(
                (fileName) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.table_chart_outlined),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList();

              if (constraints.maxWidth > 600) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 0,
                    children: cards.map((card) => SizedBox(
                      width: (constraints.maxWidth - 14) / 2,
                      child: card,
                    )).toList(),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(children: cards),
              );
            },
          ),
        if (intern!.timetable.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Table(
              border: TableBorder.all(color: const Color(0xFFE4E7EC)),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.6),
                2: FlexColumnWidth(1.6),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                  children: [
                    _TableHeaderCell(text: 'Day'),
                    _TableHeaderCell(text: 'Morning'),
                    _TableHeaderCell(text: 'Afternoon'),
                  ],
                ),
                ...intern!.timetable.map(
                  (entry) => TableRow(
                    children: [
                      _TableValueCell(text: entry.day),
                      _TableValueCell(text: entry.morning),
                      _TableValueCell(text: entry.afternoon),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DocumentsScreen extends StatefulWidget {
  const _DocumentsScreen({required this.documents});

  final List<TrainingDocument> documents;

  @override
  State<_DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<_DocumentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = widget.documents.where((doc) {
      final query = _searchQuery.toLowerCase();
      return doc.fileName.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Documents',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Available training files for interns with placeholder download actions.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search training files by name...',
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = widget.documents.isEmpty
                ? const [_InternEmptyState(
                    title: 'No training documents available',
                    subtitle: 'Shared training files will appear here when they are returned by the backend.',
                  )]
                : filteredDocuments.isEmpty
                    ? const [_InternEmptyState(
                        title: 'No results found',
                        subtitle: 'Try adjusting your search query.',
                      )]
                    : filteredDocuments.map(
                        (document) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE4E7EC)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.description_outlined),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      document.fileName,
                                      style: Theme.of(context).textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      document.category,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Download placeholder for ${document.fileName}.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download_outlined),
                              ),
                            ],
                          ),
                        ),
                      ).toList();

            if (constraints.maxWidth > 600 && widget.documents.isNotEmpty && filteredDocuments.isNotEmpty) {
              return Wrap(
                spacing: 14,
                runSpacing: 0,
                children: cards.map((card) => SizedBox(
                  width: (constraints.maxWidth - 14) / 2,
                  child: card,
                )).toList(),
              );
            }
            return Column(children: cards);
          },
        ),
      ],
    );
  }
}

class _DigitalIdScreen extends StatelessWidget {
  const _DigitalIdScreen({required this.intern, this.photoUrl});

  final Intern? intern;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (intern == null) {
      return const _InternEmptyState(
        title: 'No work ID available',
        subtitle: 'Intern identity data is not available for this account.',
      );
    }

    return Column(
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
          'Official digital identity card for internship verification.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        WorkIdCard(
          name: intern!.name,
          department: intern!.departmentName,
          email: intern!.email,
          photoUrl: photoUrl,
        ),
      ],
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDA29B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB42318),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.label, required this.value});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TableValueCell extends StatelessWidget {
  const _TableValueCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475467)),
      ),
    );
  }
}

class _InternEmptyState extends StatelessWidget {
  const _InternEmptyState({required this.title, required this.subtitle});

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
