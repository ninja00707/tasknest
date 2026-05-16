import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/models.dart';
import 'package:tasknest/core/theme/color.dart';

// ── Sample Data ───────────────────────────────────────────────────────────────
final _sampleTickets = [
  Ticket(
    id: 'TKT-001',
    title: 'Update employee records',
    description: 'Please update the Q4 employee attendance records.',
    createdByDept: Department.hr,
    assignedToDept: Department.finance,
    status: TicketStatus.open,
    priority: TicketPriority.high,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    createdByName: 'Sara Ahmed',
  ),
  Ticket(
    id: 'TKT-002',
    title: 'Fix network issues in Block C',
    description: 'Internet connectivity is down in Block C server room.',
    createdByDept: Department.it,
    assignedToDept: Department.la,
    status: TicketStatus.inProgress,
    priority: TicketPriority.urgent,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    createdByName: 'Omar Khalid',
  ),
  Ticket(
    id: 'TKT-003',
    title: 'Procurement of lab supplies',
    description: 'Urgent procurement of reagents for lab testing.',
    createdByDept: Department.procurement,
    assignedToDept: Department.fmas,
    status: TicketStatus.open,
    priority: TicketPriority.medium,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    createdByName: 'Aisha Malik',
  ),
  Ticket(
    id: 'TKT-004',
    title: 'Facility maintenance request',
    description: 'HVAC system needs servicing in main hall.',
    createdByDept: Department.admin,
    assignedToDept: Department.fm,
    status: TicketStatus.completed,
    priority: TicketPriority.low,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    createdByName: 'Bilal Hassan',
  ),
  Ticket(
    id: 'TKT-005',
    title: 'Feed stock inventory check',
    description: 'Monthly inventory audit of all feed stock.',
    createdByDept: Department.feed,
    assignedToDept: Department.lara,
    status: TicketStatus.open,
    priority: TicketPriority.medium,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    createdByName: 'Fatima Raza',
  ),
];

// ── Sample current user (change to test different roles) ──────────────────────
const _currentUser = AppUser(
  id: 'U001',
  name: 'Zaid Khan',
  email: 'zaid@umenterprises.com',
  role: UserRole.ceo,
  department: Department.hr,
  company: 'UM Enterprises',
);

// ── Dashboard Screen ──────────────────────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  final ValueNotifier<TicketStatus?> _filterStatus = ValueNotifier(null);

  List<Ticket> _visibleTickets(AppUser user) {
    switch (user.role) {
      case UserRole.ceo:
        return _sampleTickets; // CEO sees everything
      case UserRole.upperManagement:
        // Upper mgmt sees tickets THEY created
        return _sampleTickets
            .where((t) => t.createdByDept == user.department)
            .toList();
      case UserRole.lowerDepartment:
        // Lower dept sees only tickets assigned TO them
        return _sampleTickets
            .where((t) => t.assignedToDept == user.department)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    final tickets = _visibleTickets(_currentUser);

    return Scaffold(
      backgroundColor: ThemeColors.navyTextWhite,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  _Sidebar(user: _currentUser, selectedIndex: _selectedIndex),
                  Expanded(
                    child: _MainContent(
                      user: _currentUser,
                      tickets: tickets,
                      filterStatus: _filterStatus,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _TopAppBar(user: _currentUser),
                  Expanded(
                    child: _MainContent(
                      user: _currentUser,
                      tickets: tickets,
                      filterStatus: _filterStatus,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                  _BottomNav(selectedIndex: _selectedIndex),
                ],
              ),
      ),
    );
  }
}

// ── Sidebar (wide screens) ────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final AppUser user;
  final ValueNotifier<int> selectedIndex;

  const _Sidebar({required this.user, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColors.cardWhite,
        border: Border(right: BorderSide(color: ThemeColors.borderGreen)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ThemeColors.lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'TK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Taskify',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: ThemeColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // User info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.backgroundGreen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.borderGreen),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: ThemeColors.primaryGreen,
                  child: Text(
                    user.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ThemeColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _roleLabel(user),
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nav items
          ValueListenableBuilder<int>(
            valueListenable: selectedIndex,
            builder: (_, idx, __) => Column(
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  selected: idx,
                  onTap: (i) => selectedIndex.value = i,
                ),
                _NavItem(
                  icon: Icons.task_alt_outlined,
                  label: 'My Tickets',
                  index: 1,
                  selected: idx,
                  onTap: (i) => selectedIndex.value = i,
                ),
                if (user.role == UserRole.upperManagement ||
                    user.role == UserRole.lowerDepartment)
                  _NavItem(
                    icon: Icons.add_circle_outline,
                    label: 'Create Ticket',
                    index: 2,
                    selected: idx,
                    onTap: (i) => selectedIndex.value = i,
                  ),
                if (user.role == UserRole.ceo)
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Analytics',
                    index: 2,
                    selected: idx,
                    onTap: (i) => selectedIndex.value = i,
                  ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  index: 3,
                  selected: idx,
                  onTap: (i) => selectedIndex.value = i,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 4,
                  selected: idx,
                  onTap: (i) => selectedIndex.value = i,
                ),
              ],
            ),
          ),
          const Spacer(),

          // Company badge
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeColors.backgroundGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ThemeColors.borderGreen),
            ),
            child: Text(
              user.company,
              style: const TextStyle(
                fontSize: 11,
                color: ThemeColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(AppUser user) {
    if (user.role == UserRole.ceo) return 'CEO';
    return '${user.department.displayName} · ${user.role == UserRole.upperManagement ? "Upper Mgmt" : "Department"}';
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : ThemeColors.textMuted,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : ThemeColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top App Bar (mobile) ──────────────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  final AppUser user;
  const _TopAppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: ThemeColors.cardWhite,
        border: Border(bottom: BorderSide(color: ThemeColors.borderGreen)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ThemeColors.lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'TK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Taskify',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ThemeColors.primaryGreen,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: ThemeColors.textMuted,
            ),
            onPressed: () {},
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: ThemeColors.primaryGreen,
            child: Text(
              user.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav (mobile) ───────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;
  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (_, idx, __) => Container(
        decoration: const BoxDecoration(
          color: ThemeColors.cardWhite,
          border: Border(top: BorderSide(color: ThemeColors.borderGreen)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              index: 0,
              selected: idx,
              onTap: (i) => selectedIndex.value = i,
            ),
            _BottomNavItem(
              icon: Icons.task_alt_outlined,
              label: 'Tickets',
              index: 1,
              selected: idx,
              onTap: (i) => selectedIndex.value = i,
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Create',
              index: 2,
              selected: idx,
              onTap: (i) => selectedIndex.value = i,
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              index: 4,
              selected: idx,
              onTap: (i) => selectedIndex.value = i,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final void Function(int) onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? ThemeColors.primaryGreen
                  : ThemeColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? ThemeColors.primaryGreen
                    : ThemeColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Content ──────────────────────────────────────────────────────────────
class _MainContent extends StatelessWidget {
  final AppUser user;
  final List<Ticket> tickets;
  final ValueNotifier<TicketStatus?> filterStatus;
  final ValueNotifier<int> selectedIndex;

  const _MainContent({
    required this.user,
    required this.tickets,
    required this.filterStatus,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (_, idx, __) {
        if (idx == 1)
          return _TicketListView(
            tickets: tickets,
            filterStatus: filterStatus,
            user: user,
          );
        if (idx == 2 && user.role != UserRole.ceo)
          return const _CreateTicketView();
        return _DashboardView(
          user: user,
          tickets: tickets,
          filterStatus: filterStatus,
          selectedIndex: selectedIndex,
        );
      },
    );
  }
}

// ── Dashboard View ────────────────────────────────────────────────────────────
class _DashboardView extends StatelessWidget {
  final AppUser user;
  final List<Ticket> tickets;
  final ValueNotifier<TicketStatus?> filterStatus;
  final ValueNotifier<int> selectedIndex;

  const _DashboardView({
    required this.user,
    required this.tickets,
    required this.filterStatus,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final open = tickets.where((t) => t.status == TicketStatus.open).length;
    final inProgress = tickets
        .where((t) => t.status == TicketStatus.inProgress)
        .length;
    final completed = tickets
        .where((t) => t.status == TicketStatus.completed)
        .length;
    final urgent = tickets
        .where((t) => t.priority == TicketPriority.urgent)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.name.split(' ').first} 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.primaryGreen,
                    ),
                  ),
                  Text(
                    _greetingSubtitle(user),
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (user.role == UserRole.upperManagement ||
                  user.role == UserRole.lowerDepartment)
                ElevatedButton.icon(
                  onPressed: () => selectedIndex.value = 2,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Role badge
          _RoleBadge(user: user),
          const SizedBox(height: 24),

          // Stats cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                label: 'Open',
                count: open,
                color: const Color(0xFF1877F2),
                icon: Icons.inbox_outlined,
              ),
              _StatCard(
                label: 'In Progress',
                count: inProgress,
                color: const Color(0xFFF59E0B),
                icon: Icons.pending_outlined,
              ),
              _StatCard(
                label: 'Completed',
                count: completed,
                color: ThemeColors.primaryGreen,
                icon: Icons.check_circle_outline,
              ),
              _StatCard(
                label: 'Urgent',
                count: urgent,
                color: const Color(0xFFEF4444),
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent tickets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent tickets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () => selectedIndex.value = 1,
                child: const Text(
                  'View all',
                  style: TextStyle(color: ThemeColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tickets.take(3).map((t) => _TicketCard(ticket: t, user: user)),
        ],
      ),
    );
  }

  String _greetingSubtitle(AppUser user) {
    switch (user.role) {
      case UserRole.ceo:
        return 'You have full visibility across all departments.';
      case UserRole.upperManagement:
        return 'Manage tickets for ${user.department.displayName}.';
      case UserRole.lowerDepartment:
        return 'Tickets assigned to ${user.department.displayName}.';
    }
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final AppUser user;
  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;
    switch (user.role) {
      case UserRole.ceo:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF5B21B6);
        label = 'CEO — Full access';
        icon = Icons.visibility_outlined;
        break;
      case UserRole.upperManagement:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        label =
            '${user.department.displayName} — Upper management · ${user.company}';
        icon = Icons.manage_accounts_outlined;
        break;
      case UserRole.lowerDepartment:
        bg = ThemeColors.backgroundGreen;
        fg = ThemeColors.primaryGreen;
        label = '${user.department.displayName} — Department · ${user.company}';
        icon = Icons.badge_outlined;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final AppUser user;

  const _TicketCard({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.id,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _PriorityBadge(priority: ticket.priority),
              const SizedBox(width: 8),
              _StatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ThemeColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: const TextStyle(fontSize: 13, color: ThemeColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: ThemeColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'From: ${ticket.createdByDept.displayName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_downward_rounded,
                size: 14,
                color: ThemeColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'To: ${ticket.assignedToDept.displayName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                ticket.createdByName,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Priority Badge ────────────────────────────────────────────────────────────
class _PriorityBadge extends StatelessWidget {
  final TicketPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (priority) {
      case TicketPriority.low:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case TicketPriority.medium:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case TicketPriority.high:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFEA580C);
        break;
      case TicketPriority.urgent:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case TicketStatus.open:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case TicketStatus.inProgress:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case TicketStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case TicketStatus.closed:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Ticket List View ──────────────────────────────────────────────────────────
class _TicketListView extends StatelessWidget {
  final List<Ticket> tickets;
  final ValueNotifier<TicketStatus?> filterStatus;
  final AppUser user;

  const _TicketListView({
    required this.tickets,
    required this.filterStatus,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TicketStatus?>(
      valueListenable: filterStatus,
      builder: (_, filter, __) {
        final filtered = filter == null
            ? tickets
            : tickets.where((t) => t.status == filter).toList();
        return Column(
          children: [
            // Filter bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: ThemeColors.cardWhite,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: filter == null,
                      onTap: () => filterStatus.value = null,
                    ),
                    _FilterChip(
                      label: 'Open',
                      selected: filter == TicketStatus.open,
                      onTap: () => filterStatus.value = TicketStatus.open,
                    ),
                    _FilterChip(
                      label: 'In Progress',
                      selected: filter == TicketStatus.inProgress,
                      onTap: () => filterStatus.value = TicketStatus.inProgress,
                    ),
                    _FilterChip(
                      label: 'Completed',
                      selected: filter == TicketStatus.completed,
                      onTap: () => filterStatus.value = TicketStatus.completed,
                    ),
                    _FilterChip(
                      label: 'Closed',
                      selected: filter == TicketStatus.closed,
                      onTap: () => filterStatus.value = TicketStatus.closed,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No tickets found.',
                        style: TextStyle(color: ThemeColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _TicketCard(ticket: filtered[i], user: user),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.primaryGreen
              : ThemeColors.backgroundGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ThemeColors.primaryGreen
                : ThemeColors.borderGreen,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : ThemeColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Create Ticket View ────────────────────────────────────────────────────────
class _CreateTicketView extends StatelessWidget {
  const _CreateTicketView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create new ticket',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ThemeColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in the details below to create and assign a ticket.',
            style: TextStyle(fontSize: 14, color: ThemeColors.textMuted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.borderGreen),
            ),
            child: Column(
              children: [
                _FormField(
                  label: 'Ticket Title',
                  hint: 'Enter a clear, descriptive title',
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Description',
                  hint: 'Describe the task in detail...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _DropdownField(
                  label: 'Assign to Department',
                  items: Department.values
                      .where((d) => d.isLowerDepartment)
                      .map((d) => d.displayName)
                      .toList(),
                ),
                const SizedBox(height: 16),
                _DropdownField(
                  label: 'Priority',
                  items: TicketPriority.values
                      .map((p) => p.displayName)
                      .toList(),
                ),
                const SizedBox(height: 16),
                _FormField(label: 'Due Date', hint: 'Select due date'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ── Form Field ────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: ThemeColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ThemeColors.textMuted.withOpacity(0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: ThemeColors.backgroundGreen,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.borderGreen),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.borderGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ThemeColors.primaryGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dropdown Field ────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;

  const _DropdownField({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ThemeColors.backgroundGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ThemeColors.borderGreen),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.first,
              isExpanded: true,
              dropdownColor: ThemeColors.cardWhite,
              style: const TextStyle(fontSize: 14, color: ThemeColors.textDark),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: ThemeColors.textMuted,
              ),
              items: items
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
