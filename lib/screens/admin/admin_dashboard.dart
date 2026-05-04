import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/services/app_data_provider.dart';
import 'package:pro_link/services/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static const routeName = '/admin';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dataProvider = context.watch<AppDataProvider>();
    final user = authProvider.currentUser;

    if (dataProvider.isLoading && dataProvider.interns.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _AdminOverview(
        adminName: user?.name ?? 'Admin',
        approvedInternCount: dataProvider.approvedInterns.length,
        pendingCount: dataProvider.pendingRegistrations.length,
        mentorCount: dataProvider.mentors.length,
        departmentCount: dataProvider.departments.length,
      ),
      _InternDirectory(interns: dataProvider.interns),
      _AssignmentScreen(
        interns: dataProvider.approvedInterns,
        departments: dataProvider.departments,
        mentors: dataProvider.mentors,
      ),
      _OfficeTimetableScreen(
        selectedFileName: dataProvider.officeTimetableFileName,
      ),
      _PendingRegistrationsScreen(interns: dataProvider.pendingRegistrations),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Interns',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind),
            label: 'Assign',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            selectedIcon: Icon(Icons.upload_file),
            label: 'Uploads',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Approvals',
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

class _AdminOverview extends StatelessWidget {
  const _AdminOverview({
    required this.adminName,
    required this.approvedInternCount,
    required this.pendingCount,
    required this.mentorCount,
    required this.departmentCount,
  });

  final String adminName;
  final int approvedInternCount;
  final int pendingCount;
  final int mentorCount;
  final int departmentCount;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $adminName',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Operational summary for $formattedDate',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.18,
          children: [
            _MetricCard(
              icon: Icons.groups_2_outlined,
              label: 'Approved Interns',
              value: approvedInternCount.toString(),
            ),
            _MetricCard(
              icon: Icons.fact_check_outlined,
              label: 'Pending Registrations',
              value: pendingCount.toString(),
            ),
            _MetricCard(
              icon: Icons.supervisor_account_outlined,
              label: 'Mentors',
              value: mentorCount.toString(),
            ),
            _MetricCard(
              icon: Icons.apartment_outlined,
              label: 'Departments',
              value: departmentCount.toString(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _InfoPanel(
          title: 'Connected Admin Functions',
          subtitle:
              'Manage interns, departments, mentors, schedules, and registration updates from one workspace.',
        ),
      ],
    );
  }
}

class _InternDirectory extends StatefulWidget {
  const _InternDirectory({required this.interns});

  final List<Intern> interns;

  @override
  State<_InternDirectory> createState() => _InternDirectoryState();
}

class _InternDirectoryState extends State<_InternDirectory> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInterns = widget.interns.where((intern) {
      final query = _searchQuery.toLowerCase();
      final status = intern.isPending
          ? 'pending'
          : intern.isRejected
          ? 'rejected'
          : 'approved';
      return intern.name.toLowerCase().contains(query) ||
          intern.departmentName.toLowerCase().contains(query) ||
          intern.email.toLowerCase().contains(query) ||
          intern.universityId.toLowerCase().contains(query) ||
          status.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Interns',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Central directory for current intern accounts and assignments.',
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
            hintText: 'Search by name, department, email, ID, or status...',
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
            final cards = widget.interns.isEmpty
                ? const [_EmptyStateCard(
                    title: 'No interns available yet',
                    subtitle: 'Intern records will appear here after registration approval.',
                  )]
                : filteredInterns.isEmpty
                    ? const [_EmptyStateCard(
                        title: 'No results found',
                        subtitle: 'Try adjusting your search query.',
                      )]
                    : filteredInterns.map((intern) => _DirectoryCard(intern: intern)).toList();

            if (constraints.maxWidth > 600 && widget.interns.isNotEmpty && filteredInterns.isNotEmpty) {
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

class _AssignmentScreen extends StatelessWidget {
  const _AssignmentScreen({
    required this.interns,
    required this.departments,
    required this.mentors,
  });

  final List<Intern> interns;
  final List<Department> departments;
  final List<MentorProfile> mentors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign Department and Mentor',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Update internship placement details for approved interns.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = interns.isEmpty
                ? const [_EmptyStateCard(
                    title: 'No approved interns available',
                    subtitle: 'Approved intern assignments will appear here once registration is validated.',
                  )]
                : interns.map(
                    (intern) => _AssignmentCard(
                      intern: intern,
                      departments: departments,
                      mentors: mentors,
                    ),
                  ).toList();

            if (constraints.maxWidth > 600 && interns.isNotEmpty) {
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

class _OfficeTimetableScreen extends StatelessWidget {
  const _OfficeTimetableScreen({required this.selectedFileName});

  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Office Timetable',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a timetable document and upload it for interns.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        _UploadPanel(
          buttonLabel: 'Select Timetable File',
          selectedFileName: selectedFileName,
          emptyState: 'No office timetable selected yet.',
          onPick: () async {
            final result = await FilePicker.platform.pickFiles(withData: true);
            if (!context.mounted || result == null || result.files.isEmpty) {
              return;
            }

            final file = result.files.single;
            try {
              await context.read<AppDataProvider>().uploadOfficeTimetable(file);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Uploaded ${file.name} successfully.')),
              );
            } catch (error) {
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
        ),
      ],
    );
  }
}

class _PendingRegistrationsScreen extends StatelessWidget {
  const _PendingRegistrationsScreen({required this.interns});

  final List<AppUser> interns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Registrations',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Approve or reject new intern registrations.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = interns.isEmpty
                ? const [_EmptyStateCard(
                    title: 'No pending registrations',
                    subtitle: 'All current registrations have already been reviewed.',
                  )]
                : interns.map((intern) => _PendingRegistrationCard(intern: intern)).toList();

            if (constraints.maxWidth > 600 && interns.isNotEmpty) {
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1B263B)),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF667085),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({required this.intern});

  final Intern intern;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  intern.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(
                label: intern.isPending
                    ? 'Pending'
                    : intern.isRejected
                    ? 'Rejected'
                    : 'Approved',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            intern.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaChip(label: 'ID', value: intern.universityId),
              _MetaChip(label: 'Department', value: intern.departmentName),
              _MetaChip(label: 'Mentor', value: intern.mentorName),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatefulWidget {
  const _AssignmentCard({
    required this.intern,
    required this.departments,
    required this.mentors,
  });

  final Intern intern;
  final List<Department> departments;
  final List<MentorProfile> mentors;

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  String? _selectedDepartmentId;
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.intern.departmentId.isEmpty
        ? null
        : widget.intern.departmentId;
    _selectedMentorId = widget.intern.mentorId.isEmpty
        ? null
        : widget.intern.mentorId;
  }

  @override
  void didUpdateWidget(covariant _AssignmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intern.departmentId != widget.intern.departmentId) {
      _selectedDepartmentId = widget.intern.departmentId.isEmpty
          ? null
          : widget.intern.departmentId;
    }
    if (oldWidget.intern.mentorId != widget.intern.mentorId) {
      _selectedMentorId = widget.intern.mentorId.isEmpty
          ? null
          : widget.intern.mentorId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            widget.intern.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDepartmentId,
            decoration: const InputDecoration(labelText: 'Department'),
            hint: const Text('Select a department'),
            items: widget.departments
                .map(
                  (department) => DropdownMenuItem(
                    value: department.id,
                    child: Text(department.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartmentId = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedMentorId,
            decoration: const InputDecoration(labelText: 'Mentor'),
            hint: const Text('Select a mentor'),
            items: widget.mentors
                .map(
                  (mentor) => DropdownMenuItem(
                    value: mentor.id,
                    child: Text(mentor.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMentorId = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                if (_selectedDepartmentId == null ||
                    _selectedMentorId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please choose both a department and a mentor.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await context.read<AppDataProvider>().assignIntern(
                    internId: widget.intern.id,
                    departmentId: _selectedDepartmentId!,
                    mentorId: _selectedMentorId!,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Updated assignment for ${widget.intern.name}.',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              child: const Text('Save Assignment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.buttonLabel,
    required this.selectedFileName,
    required this.emptyState,
    required this.onPick,
  });

  final String buttonLabel;
  final String? selectedFileName;
  final String emptyState;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              await onPick();
            },
            icon: const Icon(Icons.attach_file_outlined),
            label: Text(buttonLabel),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              selectedFileName == null
                  ? emptyState
                  : 'Selected file: $selectedFileName',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475467)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingRegistrationCard extends StatelessWidget {
  const _PendingRegistrationCard({required this.intern});

  final AppUser intern;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            intern.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            intern.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await context.read<AppDataProvider>().rejectRegistration(
                        intern.id,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rejected ${intern.name}.')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  },
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await context.read<AppDataProvider>().approveRegistration(
                        intern.id,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Approved ${intern.name}.')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  },
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isPending = label == 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFDF1E8) : const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPending ? const Color(0xFFB54708) : const Color(0xFF027A48),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF475467)),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

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
          const Icon(Icons.check_circle_outline, size: 36),
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
