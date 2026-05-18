import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

// ── Dashboard Screen ──────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is TicketActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is TicketActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedDanger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          body: SafeArea(
            child: isWide
                ? Row(
                    children: [
                      _Sidebar(
                        selectedIndex: _selectedIndex,
                        onNav: (i) => setState(() => _selectedIndex = i),
                      ),
                      Expanded(child: _buildBody(state)),
                    ],
                  )
                : Column(
                    children: [
                      _MobileTopBar(),
                      Expanded(child: _buildBody(state)),
                      _BottomNav(
                        selectedIndex: _selectedIndex,
                        onNav: (i) => setState(() => _selectedIndex = i),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardState state) {
    DashboardLoaded? loadedState;

    if (state is DashboardLoaded) {
      loadedState = state;
    } else if (state is TicketActionSuccess) {
      loadedState = state.previousState;
    } else if (state is TicketActionError) {
      loadedState = state.previousState;
    }

    if (state is DashboardLoading || state is DashboardInitial) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      );
    }

    if (state is DashboardError) {
      return Center(child: Text(state.message));
    }

    if (loadedState == null) {
      return const Center(child: Text("Something went wrong"));
    }

    switch (_selectedIndex) {
      case 0:
        return _DashboardView(state: loadedState);

      case 1:
        return _TicketListView(state: loadedState);

      case 2:
        return _CreateTicketView(departments: loadedState.departments);

      default:
        return _DashboardView(state: loadedState);
    }
  }
  // Widget _buildBody(DashboardState state) {
  //   if (state is DashboardLoading || state is DashboardInitial) {
  //     return const Center(
  //       child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
  //     );
  //   }
  //   if (state is DashboardError) {
  //     return Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(
  //             Icons.wifi_off_rounded,
  //             size: 48,
  //             color: ThemeColors.unifiedTextMuted,
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             state.message,
  //             style: const TextStyle(color: ThemeColors.unifiedTextMuted),
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: () =>
  //                 context.read<DashboardBloc>().add(LoadDashboard()),
  //             child: const Text('Retry'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   final loaded = state is DashboardLoaded
  //       ? state
  //       : state is TicketActionSuccess
  //       ? state.previousState
  //       : (state as TicketActionError).previousState;

  //   switch (_selectedIndex) {
  //     case 0:
  //       return _DashboardView(state: loaded);
  //     case 1:
  //       return _TicketListView(state: loaded);
  //     case 2:
  //       return _CreateTicketView(departments: loaded.departments);
  //     default:
  //       return _DashboardView(state: loaded);
  //   }
  // }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  const _Sidebar({required this.selectedIndex, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(right: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Column(
        children: [
          // Logo gradient bar
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nav items
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            index: 0,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _NavItem(
            icon: Icons.task_alt_outlined,
            label: 'Tickets',
            index: 1,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _NavItem(
            icon: Icons.add_circle_outline,
            label: 'New Ticket',
            index: 2,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            index: 3,
            selected: selectedIndex,
            onTap: onNav,
          ),

          const Spacer(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: ThemeColors.unifiedPrimary,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      Text(
                        'Finance Dept',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
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
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? Colors.white : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile Top Bar ────────────────────────────────────────────────────────────
class _MobileTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Taskify',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  const _BottomNav({required this.selectedIndex, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(top: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BotItem(
            icon: Icons.dashboard_outlined,
            label: 'Home',
            index: 0,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _BotItem(
            icon: Icons.task_alt_outlined,
            label: 'Tickets',
            index: 1,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _BotItem(
            icon: Icons.add_circle_outline,
            label: 'New',
            index: 2,
            selected: selectedIndex,
            onTap: onNav,
          ),
          _BotItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            index: 3,
            selected: selectedIndex,
            onTap: onNav,
          ),
        ],
      ),
    );
  }
}

class _BotItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected;
  final void Function(int) onTap;
  const _BotItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSel
                  ? ThemeColors.unifiedPrimary
                  : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSel
                    ? ThemeColors.unifiedPrimary
                    : ThemeColors.unifiedTextMuted,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard View ────────────────────────────────────────────────────────────
class _DashboardView extends StatelessWidget {
  final DashboardLoaded state;
  const _DashboardView({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state.stats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manager Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  Text(
                    'Your department ticket overview',
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.unifiedPrimary,
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

          // Role info badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart.withOpacity(0.1),
                  ThemeColors.unifiedGradEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ThemeColors.unifiedPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Manager · Finance Department · UM Enterprises',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Full dept visibility',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stat cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    label: 'Total',
                    count: s.total,
                    color: ThemeColors.unifiedAccent,
                    icon: Icons.inbox_outlined,
                  ),
                  _StatCard(
                    label: 'Open',
                    count: s.open,
                    color: ThemeColors.unifiedSecondary,
                    icon: Icons.radio_button_unchecked,
                  ),
                  _StatCard(
                    label: 'In Progress',
                    count: s.inProgress,
                    color: ThemeColors.unifiedWarning,
                    icon: Icons.pending_outlined,
                  ),
                  _StatCard(
                    label: 'Completed',
                    count: s.completed,
                    color: ThemeColors.unifiedPrimary,
                    icon: Icons.check_circle_outline,
                  ),
                  _StatCard(
                    label: 'Closed',
                    count: s.closed,
                    color: ThemeColors.unifiedTextMuted,
                    icon: Icons.lock_outline,
                  ),
                  _StatCard(
                    label: 'Urgent',
                    count: s.urgent,
                    color: ThemeColors.unifiedDanger,
                    icon: Icons.warning_amber_rounded,
                  ),
                  _StatCard(
                    label: 'High Pri.',
                    count: s.highPriority,
                    color: const Color(0xFFEA580C),
                    icon: Icons.priority_high,
                  ),
                  _StatCard(
                    label: 'Overdue',
                    count: s.overdue,
                    color: ThemeColors.unifiedDanger,
                    icon: Icons.access_time_rounded,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent tickets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Tickets',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all',
                  style: TextStyle(color: ThemeColors.unifiedSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...state.tickets.take(5).map((t) => _TicketCard(ticket: t)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: ThemeColors.unifiedTextMuted,
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
  final TicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ticket.isOverdue
              ? ThemeColors.unifiedDanger.withOpacity(0.4)
              : ThemeColors.unifiedBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top color accent based on priority
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: _priorityColor(ticket.priority),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${ticket.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ticket.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeColors.unifiedDanger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const Spacer(),
                    _PriorityBadge(priority: ticket.priority),
                    const SizedBox(width: 6),
                    _StatusBadge(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 13,
                      color: ThemeColors.unifiedPrimary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ticket.createdByDeptCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: ThemeColors.unifiedSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ticket.assignedDeptCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    if (ticket.assignedToName != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.person_outline,
                        size: 13,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ticket.assignedToName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Action buttons
                    _TicketActions(ticket: ticket),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent':
        return ThemeColors.unifiedDanger;
      case 'high':
        return const Color(0xFFEA580C);
      case 'medium':
        return ThemeColors.unifiedWarning;
      default:
        return ThemeColors.unifiedPrimary;
    }
  }
}

// ── Ticket Actions ────────────────────────────────────────────────────────────
class _TicketActions extends StatelessWidget {
  final TicketModel ticket;
  const _TicketActions({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Self-assign (only open, not yet assigned)
        if (ticket.isOpen && ticket.assignedToId == null)
          _ActionBtn(
            icon: Icons.person_add_outlined,
            tooltip: 'Self Assign',
            color: ThemeColors.unifiedSecondary,
            onTap: () =>
                context.read<DashboardBloc>().add(SelfAssignTicket(ticket.id)),
          ),

        // Mark as completed
        if (ticket.isInProgress)
          _ActionBtn(
            icon: Icons.check_circle_outline,
            tooltip: 'Mark Completed',
            color: ThemeColors.unifiedPrimary,
            onTap: () => context.read<DashboardBloc>().add(
              UpdateTicketStatus(ticket.id, 'completed'),
            ),
          ),

        // Close ticket (manager or resolver)
        if (ticket.isCompleted)
          _ActionBtn(
            icon: Icons.lock_outline,
            tooltip: 'Close Ticket',
            color: ThemeColors.unifiedTextMuted,
            onTap: () => context.read<DashboardBloc>().add(
              UpdateTicketStatus(ticket.id, 'closed'),
            ),
          ),

        // Transfer
        if (!ticket.isClosed)
          _ActionBtn(
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Transfer',
            color: ThemeColors.unifiedWarning,
            onTap: () => _showTransferDialog(context, ticket),
          ),

        // Reopen
        if ((ticket.isClosed || ticket.isCompleted) && ticket.reopenCount < 1)
          _ActionBtn(
            icon: Icons.replay_rounded,
            tooltip: 'Reopen',
            color: ThemeColors.unifiedAccent,
            onTap: () =>
                context.read<DashboardBloc>().add(ReopenTicket(ticket.id)),
          ),
      ],
    );
  }

  void _showTransferDialog(BuildContext context, TicketModel ticket) {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    if (state is! DashboardLoaded) return;

    final depts = state.departments.where((d) => d.tier == 'lower').toList();
    int? selectedDeptId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Transfer Ticket',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Target Department',
                filled: true,
                fillColor: ThemeColors.unifiedInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ThemeColors.unifiedBorder,
                  ),
                ),
              ),
              items: depts
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedDeptId = v),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedDeptId == null
                ? null
                : () {
                    bloc.add(TransferTicket(ticket.id, selectedDeptId!));
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 4),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Priority Badge ────────────────────────────────────────────────────────────
class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (priority) {
      case 'urgent':
        bg = ThemeColors.priorityUrgentBg;
        fg = ThemeColors.priorityUrgentFg;
        break;
      case 'high':
        bg = ThemeColors.priorityHighBg;
        fg = ThemeColors.priorityHighFg;
        break;
      case 'medium':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
        break;
      default:
        bg = ThemeColors.priorityLowBg;
        fg = ThemeColors.priorityLowFg;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'open':
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
        label = 'Open';
        break;
      case 'in_progress':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
        label = 'In Progress';
        break;
      case 'completed':
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
        label = 'Completed';
        break;
      default:
        bg = ThemeColors.statusClosedBg;
        fg = ThemeColors.statusClosedFg;
        label = 'Closed';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Ticket List View ──────────────────────────────────────────────────────────
class _TicketListView extends StatelessWidget {
  final DashboardLoaded state;
  const _TicketListView({required this.state});

  @override
  Widget build(BuildContext context) {
    final statuses = ['All', 'open', 'in_progress', 'completed', 'closed'];
    final priorities = ['All', 'urgent', 'high', 'medium', 'low'];

    return Column(
      children: [
        // Filter bar
        Container(
          color: ThemeColors.unifiedSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Status filter
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((s) {
                      final active =
                          (s == 'All' && state.filterStatus == null) ||
                          s == state.filterStatus;
                      return GestureDetector(
                        onTap: () => context.read<DashboardBloc>().add(
                          FilterTickets(
                            status: s == 'All' ? null : s,
                            priority: state.filterPriority,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      ThemeColors.unifiedGradStart,
                                      ThemeColors.unifiedGradEnd,
                                    ],
                                  )
                                : null,
                            color: active
                                ? null
                                : ThemeColors.unifiedBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : ThemeColors.unifiedBorder,
                            ),
                          ),
                          child: Text(
                            s == 'All'
                                ? 'All'
                                : s.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : ThemeColors.unifiedTextMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ticket list
        Expanded(
          child: state.tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No tickets found.',
                    style: TextStyle(color: ThemeColors.unifiedTextMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.tickets.length,
                  itemBuilder: (_, i) => _TicketCard(ticket: state.tickets[i]),
                ),
        ),
      ],
    );
  }
}

// ── Create Ticket View ────────────────────────────────────────────────────────
class _CreateTicketView extends StatefulWidget {
  final List<DepartmentModel> departments;
  const _CreateTicketView({required this.departments});

  @override
  State<_CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<_CreateTicketView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _priority = 'medium';
  int? _deptId;
  String? _dueDate;

  final _priorities = ['low', 'medium', 'high', 'urgent'];

  @override
  Widget build(BuildContext context) {
    final lowerDepts = widget.departments
        .where((d) => d.tier == 'lower')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Ticket',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fill details and assign to a department.',
            style: TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient top strip
                Container(
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart,
                        ThemeColors.unifiedGradEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                _FormLabel('Title'),
                const SizedBox(height: 6),
                _Field(
                  controller: _title,
                  hint: 'Enter a clear, descriptive title',
                ),
                const SizedBox(height: 16),

                _FormLabel('Description'),
                const SizedBox(height: 6),
                _Field(
                  controller: _description,
                  hint: 'Describe the task in detail...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                _FormLabel('Assign to Department'),
                const SizedBox(height: 6),
                _DropDown<int>(
                  value: _deptId,
                  hint: 'Select department',
                  items: lowerDepts
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _deptId = v),
                ),
                const SizedBox(height: 16),

                _FormLabel('Priority'),
                const SizedBox(height: 6),
                _DropDown<String>(
                  value: _priority,
                  items: _priorities
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 16),

                _FormLabel('Due Date (optional)'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null)
                      setState(
                        () => _dueDate = picked
                            .toIso8601String()
                            .split('T')
                            .first,
                      );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeColors.unifiedBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: ThemeColors.unifiedAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _dueDate ?? 'Pick a due date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _dueDate != null
                                ? ThemeColors.unifiedTextPrimary
                                : ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ThemeColors.unifiedGradStart,
                          ThemeColors.unifiedGradEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_title.text.isEmpty || _description.text.isEmpty || _deptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
      return;
    }
    context.read<DashboardBloc>().add(
      CreateTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority,
        assignedDeptId: _deptId!,
        dueDate: _dueDate,
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ThemeColors.unifiedTextPrimary,
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 14, color: ThemeColors.unifiedTextPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: ThemeColors.unifiedTextMuted,
        fontSize: 14,
      ),
      filled: true,
      fillColor: ThemeColors.unifiedInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: ThemeColors.unifiedPrimary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

class _DropDown<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  const _DropDown({
    this.value,
    this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: ThemeColors.unifiedInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: ThemeColors.unifiedPrimary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dropdownColor: ThemeColors.unifiedSurface,
    style: const TextStyle(fontSize: 14, color: ThemeColors.unifiedTextPrimary),
    icon: const Icon(
      Icons.keyboard_arrow_down,
      color: ThemeColors.unifiedTextMuted,
    ),
    items: items,
    onChanged: onChanged,
  );
}
