import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// MODELS
// ============================================================

enum UserRole { ceo, admin, manager, user }

enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

enum Department { hr, admin, it, procurement, la, feed, fm, drag, finance }

extension DepartmentExtension on Department {
  String get displayName {
    switch (this) {
      case Department.hr:
        return 'HR';
      case Department.admin:
        return 'Admin';
      case Department.it:
        return 'IT';
      case Department.procurement:
        return 'Procurement';
      case Department.la:
        return 'LA';
      case Department.feed:
        return 'Feed';
      case Department.fm:
        return 'FM';
      case Department.drag:
        return 'DRAG';
      case Department.finance:
        return 'Finance';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final Department department;
  final String company;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.company,
  });
}

class TicketEntity {
  final String id;
  final String title;
  final String description;
  final Department createdDepartment;
  final Department assignedDepartment;
  final TicketStatus status;
  final TicketPriority priority;
  final String createdBy;
  final String? assignedTo;

  const TicketEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDepartment,
    required this.assignedDepartment,
    required this.status,
    required this.priority,
    required this.createdBy,
    this.assignedTo,
  });
}

// ============================================================
// SAMPLE DATA
// ============================================================

const currentUser = AppUser(
  id: '1',
  name: 'Muhammad Qasim',
  email: 'qasim@um.com',
  role: UserRole.manager,
  department: Department.hr,
  company: 'UM Enterprises',
);

final List<TicketEntity> sampleTickets = [
  TicketEntity(
    id: 'TKT-001',
    title: 'Update Employee Records',
    description: 'Please update employee attendance records.',
    createdDepartment: Department.hr,
    assignedDepartment: Department.finance,
    status: TicketStatus.open,
    priority: TicketPriority.high,
    createdBy: 'Sara',
  ),
  TicketEntity(
    id: 'TKT-002',
    title: 'Server Issue',
    description: 'Main server is down.',
    createdDepartment: Department.it,
    assignedDepartment: Department.it,
    status: TicketStatus.inProgress,
    priority: TicketPriority.urgent,
    createdBy: 'Ali',
    assignedTo: 'Usman',
  ),
  TicketEntity(
    id: 'TKT-003',
    title: 'Procurement Approval',
    description: 'Need procurement approval for equipment.',
    createdDepartment: Department.hr,
    assignedDepartment: Department.procurement,
    status: TicketStatus.resolved,
    priority: TicketPriority.medium,
    createdBy: 'Qasim',
  ),
];

// ============================================================
// BLOC
// ============================================================

abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

class ChangeTab extends DashboardEvent {
  final int index;

  ChangeTab(this.index);
}

class FilterTickets extends DashboardEvent {
  final TicketStatus? status;

  FilterTickets(this.status);
}

class DashboardState {
  final bool isLoading;
  final int selectedTab;
  final TicketStatus? filter;
  final List<TicketEntity> tickets;

  const DashboardState({
    this.isLoading = false,
    this.selectedTab = 0,
    this.filter,
    this.tickets = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    int? selectedTab,
    TicketStatus? filter,
    List<TicketEntity>? tickets,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      filter: filter ?? this.filter,
      tickets: tickets ?? this.tickets,
    );
  }
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<LoadDashboard>((event, emit) {
      emit(state.copyWith(tickets: sampleTickets));
    });

    on<ChangeTab>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });

    on<FilterTickets>((event, emit) {
      emit(state.copyWith(filter: event.status));
    });
  }
}

// ============================================================
// THEME COLORS
// ============================================================

class AppColors {
  static const background = Color(0xFFF7F9FB);
  static const card = Colors.white;
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF10B981);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}

// ============================================================
// DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(LoadDashboard()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: const [
              DashboardSidebar(),
              Expanded(child: DashboardContent()),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIDEBAR
// ============================================================

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.card,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'TN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TaskNest',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _navItem(context, Icons.dashboard_outlined, 'Dashboard', 0),
          _navItem(context, Icons.task_alt_outlined, 'Tickets', 1),
          _navItem(context, Icons.add_circle_outline, 'Create Ticket', 2),
          if (currentUser.role == UserRole.manager ||
              currentUser.role == UserRole.admin ||
              currentUser.role == UserRole.ceo)
            _navItem(context, Icons.analytics_outlined, 'Analytics', 3),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    currentUser.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentUser.department.displayName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final selected = state.selectedTab == index;

        return GestureDetector(
          onTap: () {
            context.read<DashboardBloc>().add(ChangeTab(index));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// CONTENT
// ============================================================

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        switch (state.selectedTab) {
          case 1:
            return const TicketsView();
          case 2:
            return const CreateTicketView();
          default:
            return const DashboardHomeView();
        }
      },
    );
  }
}

// ============================================================
// HOME VIEW
// ============================================================

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final open = state.tickets
            .where((e) => e.status == TicketStatus.open)
            .length;

        final progress = state.tickets
            .where((e) => e.status == TicketStatus.inProgress)
            .length;

        final resolved = state.tickets
            .where((e) => e.status == TicketStatus.resolved)
            .length;

        final urgent = state.tickets
            .where((e) => e.priority == TicketPriority.urgent)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${currentUser.name}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentUser.company,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(ChangeTab(2));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Ticket'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                childAspectRatio: 1.6,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: [
                  StatCard(
                    title: 'Open',
                    value: open.toString(),
                    icon: Icons.inbox_outlined,
                  ),
                  StatCard(
                    title: 'In Progress',
                    value: progress.toString(),
                    icon: Icons.pending_outlined,
                  ),
                  StatCard(
                    title: 'Resolved',
                    value: resolved.toString(),
                    icon: Icons.check_circle_outline,
                  ),
                  StatCard(
                    title: 'Urgent',
                    value: urgent.toString(),
                    icon: Icons.warning_amber_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Recent Tickets',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...state.tickets.map((e) => TicketCard(ticket: e)),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// TICKETS VIEW
// ============================================================

class TicketsView extends StatelessWidget {
  const TicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: state.tickets.length,
          itemBuilder: (_, index) {
            return TicketCard(ticket: state.tickets[index]);
          },
        );
      },
    );
  }
}

// ============================================================
// CREATE TICKET VIEW
// ============================================================

class CreateTicketView extends StatelessWidget {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Ticket',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CommonField(title: 'Ticket Title', hint: 'Enter title'),
            const SizedBox(height: 18),
            const CommonField(
              title: 'Description',
              hint: 'Describe issue',
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            const CommonDropdown(title: 'Assign Department'),
            const SizedBox(height: 18),
            const CommonDropdown(title: 'Priority'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Submit Ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMPONENTS
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final TicketEntity ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.id,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket.status.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'From: ${ticket.createdDepartment.displayName}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 18),
              Text(
                'To: ${ticket.assignedDepartment.displayName}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommonField extends StatelessWidget {
  final String title;
  final String hint;
  final int maxLines;

  const CommonField({
    super.key,
    required this.title,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class CommonDropdown extends StatelessWidget {
  final String title;

  const CommonDropdown({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Select',
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Select', child: Text('Select')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

// ## Updated Manager & Employee Business Logic

// ### Manager Permissions
// 1. Manager can see all tickets belonging to their department.
// 2. Manager can see tickets coming from department employees.
// 3. Manager can assign tickets to employees within the same department.
// 4. Manager can update ticket statuses.
// 5. Manager can supervise department workload and queue.
// 6. Manager cannot access unrelated department tickets.

// ### Employee (User) Permissions
// 1. User can see all tickets assigned to their department only.
// 2. User can create tickets.
// 3. User can transfer tickets to another department.
// 4. User cannot assign tickets user-to-user.
// 5. User can self-assign OPEN tickets.
// 6. User cannot see tickets from other departments.
// 7. User can reopen their own ticket once within 48 hours.

// ### CEO / Admin Permissions
// 1. Full visibility across all departments.
// 2. Can monitor both UM Enterprises and Matrix Pharma.
// 3. Can create tickets for any department.
// 4. Can monitor analytics and ticket flow.

// ### Ticket Visibility Rules
// - Department members can only view department tickets.
// - Managers and users share the same department visibility.
// - Cross-department visibility is restricted.
// - Ticket transfer between departments is allowed.
// - Only resolver can close ticket.
// - Creator can reopen once within 48 hours.
