import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketListView extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketListView({super.key, required this.state, required this.user});

  @override
  State<TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<TicketListView> {
  bool _boardView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(state: widget.state),
        _FilterBar(
          state: widget.state,
          boardView: _boardView,
          onToggleView: () => setState(() => _boardView = !_boardView),
        ),
        if (_boardView)
          _KanbanBoard(state: widget.state, user: widget.user)
        else
          _TicketBody(state: widget.state, user: widget.user),
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final DashboardLoaded state;
  const _SearchBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tickets by #, name, dept, date...',
          hintStyle: TextStyle(
            color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: ThemeColors.unifiedTextMuted,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  onPressed: () =>
                      context.read<DashboardBloc>().add(SearchTickets('')),
                )
              : null,
          filled: true,
          fillColor: ThemeColors.unifiedBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ThemeColors.unifiedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemeColors.unifiedBorder.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: ThemeColors.unifiedPrimary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (v) => context.read<DashboardBloc>().add(SearchTickets(v)),
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final DashboardLoaded state;
  final bool boardView;
  final VoidCallback onToggleView;
  const _FilterBar({
    required this.state,
    required this.boardView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 15,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tickets',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                // ── View toggle ──────────────────────────────
                GestureDetector(
                  onTap: onToggleView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: boardView
                          ? ThemeColors.unifiedPrimary.withOpacity(0.1)
                          : ThemeColors.unifiedBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: boardView
                            ? ThemeColors.unifiedPrimary
                            : ThemeColors.unifiedBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          boardView
                              ? Icons.view_list_rounded
                              : Icons.dashboard_rounded,
                          size: 13,
                          color: boardView
                              ? ThemeColors.unifiedPrimary
                              : ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          boardView ? 'List' : 'Board',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: boardView
                                ? ThemeColors.unifiedPrimary
                                : ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Active filter indicator
                if (state.filterStatus != null || state.filterPriority != null)
                  GestureDetector(
                    onTap: () => context.read<DashboardBloc>().add(
                      FilterTickets(status: null, priority: null),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedDanger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeColors.unifiedDanger.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.filter_alt_off_rounded,
                            size: 12,
                            color: ThemeColors.unifiedDanger,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Ticket count pill
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.tickets.length} / ${state.totalPages > 0 ? "~${state.totalPages * 15}" : state.tickets.length} tickets',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Status filters ────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = statuses[i];
                final active =
                    (s.name == 'All' && state.filterStatus == null) ||
                    s.name == state.filterStatus;
                return _FilterChip(
                  label: s.name == 'All' ? 'All' : s.name.replaceAll('_', ' '),
                  active: active,
                  color: ticketStatusColor(s.name),
                  onTap: () => context.read<DashboardBloc>().add(
                    FilterTickets(
                      status: s.name == 'All' ? null : s.name,
                      priority: state.filterPriority,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Team filter ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.read<DashboardBloc>().add(
                    ToggleTeamFilter(!state.filterTeam),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: state.filterTeam
                          ? const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: state.filterTeam
                          ? null
                          : ThemeColors.unifiedBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.filterTeam
                            ? Colors.transparent
                            : ThemeColors.unifiedBorder,
                        width: 1.5,
                      ),
                      boxShadow: state.filterTeam
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 14,
                          color: state.filterTeam
                              ? Colors.white
                              : ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'MY TEAM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: state.filterTeam
                                ? Colors.white
                                : ThemeColors.unifiedTextMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (state.filterTeam) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.filterTeam) ...[
                  const SizedBox(width: 8),
                  Text(
                    'tickets from your team',
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Priority filters ──────────────────────────────────
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: priorities.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  final active = state.filterPriority == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PriorityDot(
                      label: 'All',
                      active: active,
                      color: ThemeColors.unifiedTextMuted,
                      onTap: () => context.read<DashboardBloc>().add(
                        FilterTickets(
                          status: state.filterStatus,
                          priority: null,
                        ),
                      ),
                    ),
                  );
                }
                final p = priorities[i - 1];
                final active = p.name == state.filterPriority;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _PriorityDot(
                    label: p.name[0].toUpperCase() + p.name.substring(1),
                    active: active,
                    color: ticketPriorityColor(p.name),
                    onTap: () => context.read<DashboardBloc>().add(
                      FilterTickets(
                        status: state.filterStatus,
                        priority: p.name,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Pagination Button ──────────────────────────────────────────────
class _PageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;
  final VoidCallback onTap;

  const _PageBtn({
    required this.icon,
    required this.label,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = disabled
        ? ThemeColors.unifiedTextMuted.withOpacity(0.3)
        : ThemeColors.unifiedPrimary;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: disabled
              ? ThemeColors.unifiedBackground
              : ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: disabled
                ? ThemeColors.unifiedBorder.withOpacity(0.5)
                : ThemeColors.unifiedPrimary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status filter chip ────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : ThemeColors.unifiedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : ThemeColors.unifiedBorder,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : ThemeColors.unifiedTextMuted,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _PriorityDot({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          // ← never use Colors.transparent — use a real color with opacity 0
          color: active
              ? color.withOpacity(0.12)
              : ThemeColors.unifiedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : ThemeColors.unifiedBorder,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? color : ThemeColors.unifiedTextMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? color : ThemeColors.unifiedTextMuted,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TICKET BODY — now sorted by urgency and grouped by status for clarity
// ══════════════════════════════════════════════════════════════════════════════
class _TicketBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const _TicketBody({required this.state, required this.user});

  static const List<String> _statusFlow = [
    'open',
    'in_progress',
    'completed',
    'closed',
  ];

  static int _priorityWeight(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'urgent':
        return 0;
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 4;
    }
  }

  static int _statusWeight(String? s) {
    final idx = _statusFlow.indexOf(s ?? '');
    return idx == -1 ? _statusFlow.length : idx;
  }

  /// Tickets are never lost — only re-ordered. Urgent/high priority surfaces
  /// first, then earlier-stage statuses (open before closed), so the most
  /// actionable work is always at the top.
  List<TicketModel> _sorted(List<TicketModel> tickets) {
    final list = List<TicketModel>.from(tickets);
    list.sort((a, b) {
      final p = _priorityWeight(
        a.priority,
      ).compareTo(_priorityWeight(b.priority));
      if (p != 0) return p;
      return _statusWeight(a.status).compareTo(_statusWeight(b.status));
    });
    return list;
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return s.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        state.filterStatus != null ||
        state.filterPriority != null ||
        state.searchQuery.isNotEmpty;

    final allSorted = _sorted(state.filteredTickets);

    if (allSorted.isEmpty) {
      return _EmptyState(
        filterActive: hasFilters,
        onClear: () {
          context.read<DashboardBloc>().add(
            FilterTickets(status: null, priority: null),
          );
          context.read<DashboardBloc>().add(SearchTickets(''));
        },
      );
    }

    // Group by status only in the default (unfiltered) view, so every ticket
    // sits under a clear, labeled section instead of one long jumbled list.
    final Map<String, List<TicketModel>> grouped = {};
    if (!hasFilters) {
      for (final t in allSorted) {
        grouped.putIfAbsent(t.status, () => []).add(t);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 700
            ? 2
            : 1;
        const spacing = 12.0;
        const padding = 16.0;
        final cardWidth =
            (constraints.maxWidth -
                padding * 2 -
                spacing * (crossAxisCount - 1)) /
            crossAxisCount;

        Widget buildGrid(List<TicketModel> tickets) {
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: tickets
                .map(
                  (t) => SizedBox(
                    width: cardWidth,
                    child: TicketCard(ticket: t, user: user),
                  ),
                )
                .toList(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Result summary strip (filtered view) ────────
              if (hasFilters) ...[
                _ResultSummary(state: state, count: allSorted.length),
                const SizedBox(height: 12),
                buildGrid(allSorted),
              ] else
                // ── Grouped-by-status sections (default view) ──
                for (final status in _statusFlow)
                  if ((grouped[status]?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusSectionHeader(
                            status: status,
                            label: _statusLabel(status),
                            count: grouped[status]!.length,
                          ),
                          const SizedBox(height: 10),
                          buildGrid(grouped[status]!),
                        ],
                      ),
                    ),

              // ── Pagination ────────────────────────────────
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PageBtn(
                        icon: Icons.chevron_left_rounded,
                        label: 'Previous',
                        disabled: state.currentPage <= 1,
                        onTap: () {
                          if (state.currentPage > 1) {
                            context.read<DashboardBloc>().add(
                              LoadDashboard(page: state.currentPage - 1),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ThemeColors.unifiedBorder),
                        ),
                        child: Text(
                          'Page ${state.currentPage} of ${state.totalPages}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PageBtn(
                        icon: Icons.chevron_right_rounded,
                        label: 'Next',
                        disabled: state.currentPage >= state.totalPages,
                        onTap: () {
                          if (state.currentPage < state.totalPages) {
                            context.read<DashboardBloc>().add(
                              LoadDashboard(page: state.currentPage + 1),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Status section header (groups tickets visually) ────────────────────────────
class _StatusSectionHeader extends StatelessWidget {
  final String status;
  final String label;
  final int count;
  const _StatusSectionHeader({
    required this.status,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = ticketStatusColor(status);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: ThemeColors.unifiedBorder.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ── Result summary ────────────────────────────────────────────────────────────
class _ResultSummary extends StatelessWidget {
  final DashboardLoaded state;
  final int count;
  const _ResultSummary({required this.state, this.count = 0});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (state.filterStatus != null)
      parts.add(state.filterStatus!.replaceAll('_', ' ').toUpperCase());
    if (state.filterPriority != null)
      parts.add(state.filterPriority!.toUpperCase() + ' PRIORITY');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 14,
            color: ThemeColors.unifiedPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing $count result${count == 1 ? '' : 's'}'
              ' · ${parts.join(' · ')}'
              '${state.searchQuery.isNotEmpty ? ' · "${state.searchQuery}"' : ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KANBAN BOARD VIEW (Trello-like columns by status) — now priority-sorted too
// ══════════════════════════════════════════════════════════════════════════════
class _KanbanBoard extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const _KanbanBoard({required this.state, required this.user});

  static const _statuses = ['open', 'in_progress', 'completed', 'closed'];

  static Color _columnColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF22C55E);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return s;
    }
  }

  static int _priorityWeight(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'urgent':
        return 0;
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = state.filteredTickets;
    final grouped = <String, List<TicketModel>>{};
    for (final s in _statuses) {
      final list = all.where((t) => t.status == s).toList()
        ..sort(
          (a, b) => _priorityWeight(
            a.priority,
          ).compareTo(_priorityWeight(b.priority)),
        );
      grouped[s] = list;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _statuses.map((status) {
          final tickets = grouped[status]!;
          return _KanbanColumn(
            status: status,
            label: _statusLabel(status),
            color: _columnColor(status),
            tickets: tickets,
            user: user,
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final List<TicketModel> tickets;
  final UserModel user;

  const _KanbanColumn({
    required this.status,
    required this.label,
    required this.color,
    required this.tickets,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // ── Column header ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Ticket list ────────────────────────────────────
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No tickets',
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    itemCount: tickets.length,
                    itemBuilder: (context, i) =>
                        _KanbanCard(ticket: tickets[i], user: user),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _KanbanCard({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final pColor = ticketPriorityColor(ticket.priority);
    return GestureDetector(
      onTap: () => context.push('/ticket/${ticket.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: pColor, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket number + priority
            Row(
              children: [
                Flexible(
                  child: Text(
                    ticket.ticketNumber.isNotEmpty
                        ? ticket.ticketNumber
                        : '#${ticket.id}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Bottom row: assignee + dept
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    ticket.assignedToName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 10,
                      color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool filterActive;
  final VoidCallback onClear;

  const _EmptyState({required this.filterActive, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ThemeColors.unifiedPrimary.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                filterActive
                    ? Icons.filter_alt_off_rounded
                    : Icons.inbox_rounded,
                size: 34,
                color: ThemeColors.unifiedPrimary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filterActive ? 'No matching tickets' : 'No tickets yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filterActive
                  ? 'Try adjusting or clearing your filters'
                  : 'Tickets assigned to your department will appear here',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextMuted,
                height: 1.5,
              ),
            ),
            if (filterActive) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart,
                        ThemeColors.unifiedGradEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColors.unifiedPrimary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.filter_alt_off_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Clear Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tasknest/core/constant/const_dep.dart';
// import 'package:tasknest/core/theme/color.dart';
// import 'package:tasknest/core/theme/common_helpers.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
// import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
// import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
// import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
// import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
// import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

// class TicketListView extends StatefulWidget {
//   final DashboardLoaded state;
//   final UserModel user;

//   const TicketListView({super.key, required this.state, required this.user});

//   @override
//   State<TicketListView> createState() => _TicketListViewState();
// }

// class _TicketListViewState extends State<TicketListView> {
//   bool _boardView = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SearchBar(state: widget.state),
//         _FilterBar(
//           state: widget.state,
//           boardView: _boardView,
//           onToggleView: () => setState(() => _boardView = !_boardView),
//         ),
//         if (_boardView)
//           _KanbanBoard(state: widget.state, user: widget.user)
//         else
//           _TicketBody(state: widget.state, user: widget.user),
//       ],
//     );
//   }
// }

// // ── Search bar ────────────────────────────────────────────────────────────────
// class _SearchBar extends StatelessWidget {
//   final DashboardLoaded state;
//   const _SearchBar({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         border: Border(
//           bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search tickets by #, name, dept, date...',
//           hintStyle: TextStyle(
//             color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
//             fontSize: 13,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 20,
//             color: ThemeColors.unifiedTextMuted,
//           ),
//           suffixIcon: state.searchQuery.isNotEmpty
//               ? IconButton(
//                   icon: Icon(
//                     Icons.clear_rounded,
//                     size: 18,
//                     color: ThemeColors.unifiedTextMuted,
//                   ),
//                   onPressed: () =>
//                       context.read<DashboardBloc>().add(SearchTickets('')),
//                 )
//               : null,
//           filled: true,
//           fillColor: ThemeColors.unifiedBackground,
//           contentPadding: const EdgeInsets.symmetric(vertical: 10),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: ThemeColors.unifiedBorder),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(
//               color: ThemeColors.unifiedBorder.withOpacity(0.5),
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: ThemeColors.unifiedPrimary,
//               width: 1.5,
//             ),
//           ),
//         ),
//         onChanged: (v) => context.read<DashboardBloc>().add(SearchTickets(v)),
//       ),
//     );
//   }
// }

// // ── Filter bar ────────────────────────────────────────────────────────────────
// class _FilterBar extends StatelessWidget {
//   final DashboardLoaded state;
//   final bool boardView;
//   final VoidCallback onToggleView;
//   const _FilterBar({
//     required this.state,
//     required this.boardView,
//     required this.onToggleView,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         border: Border(
//           bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header row ────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: const Icon(
//                     Icons.task_alt_rounded,
//                     size: 15,
//                     color: ThemeColors.unifiedPrimary,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Tickets',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: ThemeColors.unifiedTextPrimary,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                 const Spacer(),
//                 // ── View toggle ──────────────────────────────
//                 GestureDetector(
//                   onTap: onToggleView,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: boardView
//                           ? ThemeColors.unifiedPrimary.withOpacity(0.1)
//                           : ThemeColors.unifiedBackground,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: boardView
//                             ? ThemeColors.unifiedPrimary
//                             : ThemeColors.unifiedBorder,
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           boardView
//                               ? Icons.view_list_rounded
//                               : Icons.dashboard_rounded,
//                           size: 13,
//                           color: boardView
//                               ? ThemeColors.unifiedPrimary
//                               : ThemeColors.unifiedTextMuted,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           boardView ? 'List' : 'Board',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: boardView
//                                 ? ThemeColors.unifiedPrimary
//                                 : ThemeColors.unifiedTextMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Active filter indicator
//                 if (state.filterStatus != null || state.filterPriority != null)
//                   GestureDetector(
//                     onTap: () => context.read<DashboardBloc>().add(
//                       FilterTickets(status: null, priority: null),
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: ThemeColors.unifiedDanger.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: ThemeColors.unifiedDanger.withOpacity(0.2),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(
//                             Icons.filter_alt_off_rounded,
//                             size: 12,
//                             color: ThemeColors.unifiedDanger,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             'Clear',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: ThemeColors.unifiedDanger,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 // Ticket count pill
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${state.tickets.length} / ${state.totalPages > 0 ? "~${state.totalPages * 15}" : state.tickets.length} tickets',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: ThemeColors.unifiedPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // ── Status filters ────────────────────────────────────
//           SizedBox(
//             height: 34,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: statuses.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (context, i) {
//                 final s = statuses[i];
//                 final active =
//                     (s.name == 'All' && state.filterStatus == null) ||
//                     s.name == state.filterStatus;
//                 return _FilterChip(
//                   label: s.name == 'All' ? 'All' : s.name.replaceAll('_', ' '),
//                   active: active,
//                   color: ticketStatusColor(s.name),
//                   onTap: () => context.read<DashboardBloc>().add(
//                     FilterTickets(
//                       status: s.name == 'All' ? null : s.name,
//                       priority: state.filterPriority,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ── Team filter ──────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => context.read<DashboardBloc>().add(
//                     ToggleTeamFilter(!state.filterTeam),
//                   ),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: state.filterTeam
//                           ? const LinearGradient(
//                               colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : null,
//                       color: state.filterTeam
//                           ? null
//                           : ThemeColors.unifiedBackground,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: state.filterTeam
//                             ? Colors.transparent
//                             : ThemeColors.unifiedBorder,
//                         width: 1.5,
//                       ),
//                       boxShadow: state.filterTeam
//                           ? [
//                               BoxShadow(
//                                 color: const Color(0xFF0EA5E9).withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                           : null,
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.groups_rounded,
//                           size: 14,
//                           color: state.filterTeam
//                               ? Colors.white
//                               : ThemeColors.unifiedTextMuted,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           'MY TEAM',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w800,
//                             color: state.filterTeam
//                                 ? Colors.white
//                                 : ThemeColors.unifiedTextMuted,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         if (state.filterTeam) ...[
//                           const SizedBox(width: 4),
//                           const Icon(
//                             Icons.check_circle_rounded,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (state.filterTeam) ...[
//                   const SizedBox(width: 8),
//                   Text(
//                     'tickets from your team',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // ── Priority filters ──────────────────────────────────
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 30,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: priorities.length + 1,
//               itemBuilder: (context, i) {
//                 if (i == 0) {
//                   final active = state.filterPriority == null;
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 6),
//                     child: _PriorityDot(
//                       label: 'All',
//                       active: active,
//                       color: ThemeColors.unifiedTextMuted,
//                       onTap: () => context.read<DashboardBloc>().add(
//                         FilterTickets(
//                           status: state.filterStatus,
//                           priority: null,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 final p = priorities[i - 1];
//                 final active = p.name == state.filterPriority;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 6),
//                   child: _PriorityDot(
//                     label: p.name[0].toUpperCase() + p.name.substring(1),
//                     active: active,
//                     color: ticketPriorityColor(p.name),
//                     onTap: () => context.read<DashboardBloc>().add(
//                       FilterTickets(
//                         status: state.filterStatus,
//                         priority: p.name,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }

// // ── Pagination Button ──────────────────────────────────────────────
// class _PageBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool disabled;
//   final VoidCallback onTap;

//   const _PageBtn({
//     required this.icon,
//     required this.label,
//     required this.disabled,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = disabled
//         ? ThemeColors.unifiedTextMuted.withOpacity(0.3)
//         : ThemeColors.unifiedPrimary;
//     return GestureDetector(
//       onTap: disabled ? null : onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: disabled
//               ? ThemeColors.unifiedBackground
//               : ThemeColors.unifiedSurface,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: disabled
//                 ? ThemeColors.unifiedBorder.withOpacity(0.5)
//                 : ThemeColors.unifiedPrimary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Status filter chip ────────────────────────────────────────────────────────
// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color color;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.label,
//     required this.active,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           gradient: active
//               ? LinearGradient(
//                   colors: [color, color.withOpacity(0.75)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//           color: active ? null : ThemeColors.unifiedBackground,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: active ? Colors.transparent : ThemeColors.unifiedBorder,
//             width: 1.5,
//           ),
//           boxShadow: active
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           label.toUpperCase(),
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: active ? Colors.white : ThemeColors.unifiedTextMuted,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _PriorityDot extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color color;
//   final VoidCallback onTap;

//   const _PriorityDot({
//     required this.label,
//     required this.active,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         decoration: BoxDecoration(
//           // ← never use Colors.transparent — use a real color with opacity 0
//           color: active
//               ? color.withOpacity(0.12)
//               : ThemeColors.unifiedBackground,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: active ? color : ThemeColors.unifiedBorder,
//             width: 1.5,
//           ),
//           boxShadow: active
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.2),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: active ? color : ThemeColors.unifiedTextMuted,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const SizedBox(width: 5),
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 180),
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//                 color: active ? color : ThemeColors.unifiedTextMuted,
//               ),
//               child: Text(label),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // TICKET BODY — now sorted by urgency and grouped by status for clarity
// // ══════════════════════════════════════════════════════════════════════════════
// class _TicketBody extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;

//   const _TicketBody({required this.state, required this.user});

//   static const List<String> _statusFlow = [
//     'open',
//     'in_progress',
//     'completed',
//     'closed',
//   ];

//   static int _priorityWeight(String? p) {
//     switch ((p ?? '').toLowerCase()) {
//       case 'urgent':
//         return 0;
//       case 'high':
//         return 1;
//       case 'medium':
//         return 2;
//       case 'low':
//         return 3;
//       default:
//         return 4;
//     }
//   }

//   static int _statusWeight(String? s) {
//     final idx = _statusFlow.indexOf(s ?? '');
//     return idx == -1 ? _statusFlow.length : idx;
//   }

//   /// Tickets are never lost — only re-ordered. Urgent/high priority surfaces
//   /// first, then earlier-stage statuses (open before closed), so the most
//   /// actionable work is always at the top.
//   List<TicketModel> _sorted(List<TicketModel> tickets) {
//     final list = List<TicketModel>.from(tickets);
//     list.sort((a, b) {
//       final p = _priorityWeight(
//         a.priority,
//       ).compareTo(_priorityWeight(b.priority));
//       if (p != 0) return p;
//       return _statusWeight(a.status).compareTo(_statusWeight(b.status));
//     });
//     return list;
//   }

//   static String _statusLabel(String s) {
//     switch (s) {
//       case 'open':
//         return 'Open';
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'Completed';
//       case 'closed':
//         return 'Closed';
//       default:
//         return s.replaceAll('_', ' ');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasFilters =
//         state.filterStatus != null ||
//         state.filterPriority != null ||
//         state.searchQuery.isNotEmpty;

//     final allSorted = _sorted(state.filteredTickets);

//     if (allSorted.isEmpty) {
//       return _EmptyState(
//         filterActive: hasFilters,
//         onClear: () {
//           context.read<DashboardBloc>().add(
//             FilterTickets(status: null, priority: null),
//           );
//           context.read<DashboardBloc>().add(SearchTickets(''));
//         },
//       );
//     }

//     // Group by status only in the default (unfiltered) view, so every ticket
//     // sits under a clear, labeled section instead of one long jumbled list.
//     final Map<String, List<TicketModel>> grouped = {};
//     if (!hasFilters) {
//       for (final t in allSorted) {
//         grouped.putIfAbsent(t.status, () => []).add(t);
//       }
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final crossAxisCount = constraints.maxWidth > 1200
//             ? 3
//             : constraints.maxWidth > 700
//             ? 2
//             : 1;
//         const spacing = 12.0;
//         const padding = 16.0;
//         final cardWidth =
//             (constraints.maxWidth -
//                 padding * 2 -
//                 spacing * (crossAxisCount - 1)) /
//             crossAxisCount;

//         Widget buildGrid(List<TicketModel> tickets) {
//           return Wrap(
//             spacing: spacing,
//             runSpacing: spacing,
//             children: tickets
//                 .map(
//                   (t) => SizedBox(
//                     width: cardWidth,
//                     child: TicketCard(ticket: t, user: user),
//                   ),
//                 )
//                 .toList(),
//           );
//         }

//         return Padding(
//           padding: const EdgeInsets.all(padding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Result summary strip (filtered view) ────────
//               if (hasFilters) ...[
//                 _ResultSummary(state: state, count: allSorted.length),
//                 const SizedBox(height: 12),
//                 buildGrid(allSorted),
//               ] else
//                 // ── Grouped-by-status sections (default view) ──
//                 for (final status in _statusFlow)
//                   if ((grouped[status]?.isNotEmpty ?? false))
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 22),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _StatusSectionHeader(
//                             status: status,
//                             label: _statusLabel(status),
//                             count: grouped[status]!.length,
//                           ),
//                           const SizedBox(height: 10),
//                           buildGrid(grouped[status]!),
//                         ],
//                       ),
//                     ),

//               // ── Pagination ────────────────────────────────
//               if (state.totalPages > 1)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8, bottom: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _PageBtn(
//                         icon: Icons.chevron_left_rounded,
//                         label: 'Previous',
//                         disabled: state.currentPage <= 1,
//                         onTap: () {
//                           if (state.currentPage > 1) {
//                             context.read<DashboardBloc>().add(
//                               LoadDashboard(page: state.currentPage - 1),
//                             );
//                           }
//                         },
//                       ),
//                       const SizedBox(width: 12),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: ThemeColors.unifiedSurface,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: ThemeColors.unifiedBorder),
//                         ),
//                         child: Text(
//                           'Page ${state.currentPage} of ${state.totalPages}',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: ThemeColors.unifiedTextPrimary,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       _PageBtn(
//                         icon: Icons.chevron_right_rounded,
//                         label: 'Next',
//                         disabled: state.currentPage >= state.totalPages,
//                         onTap: () {
//                           if (state.currentPage < state.totalPages) {
//                             context.read<DashboardBloc>().add(
//                               LoadDashboard(page: state.currentPage + 1),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Status section header (groups tickets visually) ────────────────────────────
// class _StatusSectionHeader extends StatelessWidget {
//   final String status;
//   final String label;
//   final int count;
//   const _StatusSectionHeader({
//     required this.status,
//     required this.label,
//     required this.count,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = ticketStatusColor(status);
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w800,
//             color: ThemeColors.unifiedTextPrimary,
//             letterSpacing: -0.1,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             '$count',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//               color: color,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Container(
//             height: 1,
//             color: ThemeColors.unifiedBorder.withOpacity(0.6),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Result summary ────────────────────────────────────────────────────────────
// class _ResultSummary extends StatelessWidget {
//   final DashboardLoaded state;
//   final int count;
//   const _ResultSummary({required this.state, this.count = 0});

//   @override
//   Widget build(BuildContext context) {
//     final parts = <String>[];
//     if (state.filterStatus != null)
//       parts.add(state.filterStatus!.replaceAll('_', ' ').toUpperCase());
//     if (state.filterPriority != null)
//       parts.add(state.filterPriority!.toUpperCase() + ' PRIORITY');

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.filter_alt_rounded,
//             size: 14,
//             color: ThemeColors.unifiedPrimary,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'Showing $count result${count == 1 ? '' : 's'}'
//               ' · ${parts.join(' · ')}'
//               '${state.searchQuery.isNotEmpty ? ' · "${state.searchQuery}"' : ''}',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // KANBAN BOARD VIEW (Trello-like columns by status) — now priority-sorted too
// // ══════════════════════════════════════════════════════════════════════════════
// class _KanbanBoard extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;
//   const _KanbanBoard({required this.state, required this.user});

//   static const _statuses = ['open', 'in_progress', 'completed', 'closed'];

//   static Color _columnColor(String status) {
//     switch (status) {
//       case 'open':
//         return const Color(0xFF22C55E);
//       case 'in_progress':
//         return const Color(0xFF3B82F6);
//       case 'completed':
//         return const Color(0xFF10B981);
//       case 'closed':
//         return const Color(0xFF6B7280);
//       default:
//         return Colors.grey;
//     }
//   }

//   static String _statusLabel(String s) {
//     switch (s) {
//       case 'open':
//         return 'Open';
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'Completed';
//       case 'closed':
//         return 'Closed';
//       default:
//         return s;
//     }
//   }

//   static int _priorityWeight(String? p) {
//     switch ((p ?? '').toLowerCase()) {
//       case 'urgent':
//         return 0;
//       case 'high':
//         return 1;
//       case 'medium':
//         return 2;
//       case 'low':
//         return 3;
//       default:
//         return 4;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final all = state.filteredTickets;
//     final grouped = <String, List<TicketModel>>{};
//     for (final s in _statuses) {
//       final list = all.where((t) => t.status == s).toList()
//         ..sort(
//           (a, b) => _priorityWeight(
//             a.priority,
//           ).compareTo(_priorityWeight(b.priority)),
//         );
//       grouped[s] = list;
//     }

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.65,
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: _statuses.map((status) {
//           final tickets = grouped[status]!;
//           return _KanbanColumn(
//             status: status,
//             label: _statusLabel(status),
//             color: _columnColor(status),
//             tickets: tickets,
//             user: user,
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _KanbanColumn extends StatelessWidget {
//   final String status;
//   final String label;
//   final Color color;
//   final List<TicketModel> tickets;
//   final UserModel user;

//   const _KanbanColumn({
//     required this.status,
//     required this.label,
//     required this.color,
//     required this.tickets,
//     required this.user,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       margin: const EdgeInsets.only(right: 12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.04),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.15)),
//       ),
//       child: Column(
//         children: [
//           // ── Column header ──────────────────────────────────
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(13),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: color,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800,
//                     color: color,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     '${tickets.length}',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       color: color,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Ticket list ────────────────────────────────────
//           Expanded(
//             child: tickets.isEmpty
//                 ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Text(
//                         'No tickets',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: color.withOpacity(0.4),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//                     itemCount: tickets.length,
//                     itemBuilder: (context, i) =>
//                         _KanbanCard(ticket: tickets[i], user: user),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _KanbanCard extends StatelessWidget {
//   final TicketModel ticket;
//   final UserModel user;
//   const _KanbanCard({required this.ticket, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final pColor = ticketPriorityColor(ticket.priority);
//     return GestureDetector(
//       onTap: () => context.push('/ticket/${ticket.id}'),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border(left: BorderSide(color: pColor, width: 3)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Ticket number + priority
//             Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     ticket.ticketNumber.isNotEmpty
//                         ? ticket.ticketNumber
//                         : '#${ticket.id}',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF9CA3AF),
//                       letterSpacing: 0.5,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: pColor,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             // Title
//             Text(
//               ticket.title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1F2937),
//                 height: 1.3,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             // Bottom row: assignee + dept
//             Row(
//               children: [
//                 Icon(
//                   Icons.person_outline_rounded,
//                   size: 11,
//                   color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
//                 ),
//                 const SizedBox(width: 3),
//                 Expanded(
//                   child: Text(
//                     ticket.assignedToName ?? 'Unassigned',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Empty state ───────────────────────────────────────────────────────────────
// class _EmptyState extends StatelessWidget {
//   final bool filterActive;
//   final VoidCallback onClear;

//   const _EmptyState({required this.filterActive, required this.onClear});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: ThemeColors.unifiedPrimary.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: ThemeColors.unifiedPrimary.withOpacity(0.15),
//                   width: 1.5,
//                 ),
//               ),
//               child: Icon(
//                 filterActive
//                     ? Icons.filter_alt_off_rounded
//                     : Icons.inbox_rounded,
//                 size: 34,
//                 color: ThemeColors.unifiedPrimary.withOpacity(0.5),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               filterActive ? 'No matching tickets' : 'No tickets yet',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               filterActive
//                   ? 'Try adjusting or clearing your filters'
//                   : 'Tickets assigned to your department will appear here',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: ThemeColors.unifiedTextMuted,
//                 height: 1.5,
//               ),
//             ),
//             if (filterActive) ...[
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: onClear,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 11,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         ThemeColors.unifiedGradStart,
//                         ThemeColors.unifiedGradEnd,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: ThemeColors.unifiedPrimary.withOpacity(0.25),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Icon(
//                         Icons.filter_alt_off_rounded,
//                         size: 15,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 7),
//                       Text(
//                         'Clear Filters',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tasknest/core/constant/const_dep.dart';
// import 'package:tasknest/core/theme/color.dart';
// import 'package:tasknest/core/theme/common_helpers.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
// import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
// import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
// import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
// import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
// import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

// class TicketListView extends StatefulWidget {
//   final DashboardLoaded state;
//   final UserModel user;

//   const TicketListView({super.key, required this.state, required this.user});

//   @override
//   State<TicketListView> createState() => _TicketListViewState();
// }

// class _TicketListViewState extends State<TicketListView> {
//   bool _boardView = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SearchBar(state: widget.state),
//         _FilterBar(state: widget.state, boardView: _boardView, onToggleView: () => setState(() => _boardView = !_boardView)),
//         if (_boardView)
//           _KanbanBoard(state: widget.state, user: widget.user)
//         else
//           _TicketBody(state: widget.state, user: widget.user),
//       ],
//     );
//   }
// }

// // ── Search bar ────────────────────────────────────────────────────────────────
// class _SearchBar extends StatelessWidget {
//   final DashboardLoaded state;
//   const _SearchBar({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         border: Border(
//           bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search tickets by #, name, dept, date...',
//           hintStyle: TextStyle(
//             color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
//             fontSize: 13,
//           ),
//           prefixIcon: Icon(Icons.search_rounded, size: 20, color: ThemeColors.unifiedTextMuted),
//           suffixIcon: state.searchQuery.isNotEmpty
//               ? IconButton(
//                   icon: Icon(Icons.clear_rounded, size: 18, color: ThemeColors.unifiedTextMuted),
//                   onPressed: () => context.read<DashboardBloc>().add(SearchTickets('')),
//                 )
//               : null,
//           filled: true,
//           fillColor: ThemeColors.unifiedBackground,
//           contentPadding: const EdgeInsets.symmetric(vertical: 10),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: ThemeColors.unifiedBorder),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: ThemeColors.unifiedPrimary, width: 1.5),
//           ),
//         ),
//         onChanged: (v) => context.read<DashboardBloc>().add(SearchTickets(v)),
//       ),
//     );
//   }
// }

// // ── Filter bar ────────────────────────────────────────────────────────────────
// class _FilterBar extends StatelessWidget {
//   final DashboardLoaded state;
//   final bool boardView;
//   final VoidCallback onToggleView;
//   const _FilterBar({required this.state, required this.boardView, required this.onToggleView});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         border: Border(
//           bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header row ────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: const Icon(
//                     Icons.task_alt_rounded,
//                     size: 15,
//                     color: ThemeColors.unifiedPrimary,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Tickets',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: ThemeColors.unifiedTextPrimary,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                 const Spacer(),
//                 // ── View toggle ──────────────────────────────
//                 GestureDetector(
//                   onTap: onToggleView,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: boardView ? ThemeColors.unifiedPrimary.withOpacity(0.1) : ThemeColors.unifiedBackground,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: boardView ? ThemeColors.unifiedPrimary : ThemeColors.unifiedBorder,
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           boardView ? Icons.view_list_rounded : Icons.dashboard_rounded,
//                           size: 13,
//                           color: boardView ? ThemeColors.unifiedPrimary : ThemeColors.unifiedTextMuted,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           boardView ? 'List' : 'Board',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: boardView ? ThemeColors.unifiedPrimary : ThemeColors.unifiedTextMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Active filter indicator
//                 if (state.filterStatus != null || state.filterPriority != null)
//                   GestureDetector(
//                     onTap: () => context.read<DashboardBloc>().add(
//                       FilterTickets(status: null, priority: null),
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: ThemeColors.unifiedDanger.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: ThemeColors.unifiedDanger.withOpacity(0.2),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(
//                             Icons.filter_alt_off_rounded,
//                             size: 12,
//                             color: ThemeColors.unifiedDanger,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             'Clear',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: ThemeColors.unifiedDanger,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 // Ticket count pill
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${state.tickets.length} / ${state.totalPages > 0 ? "~${state.totalPages * 15}" : state.tickets.length} tickets',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: ThemeColors.unifiedPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // ── Status filters ────────────────────────────────────
//           SizedBox(
//             height: 34,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: statuses.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (context, i) {
//                 final s = statuses[i];
//                 final active =
//                     (s.name == 'All' && state.filterStatus == null) ||
//                     s.name == state.filterStatus;
//                 return _FilterChip(
//                   label: s.name == 'All' ? 'All' : s.name.replaceAll('_', ' '),
//                   active: active,
//                   color: ticketStatusColor(s.name),
//                   onTap: () => context.read<DashboardBloc>().add(
//                     FilterTickets(
//                       status: s.name == 'All' ? null : s.name,
//                       priority: state.filterPriority,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ── Team filter ──────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => context.read<DashboardBloc>().add(
//                     ToggleTeamFilter(!state.filterTeam),
//                   ),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       gradient: state.filterTeam
//                           ? const LinearGradient(
//                               colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : null,
//                       color: state.filterTeam ? null : ThemeColors.unifiedBackground,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: state.filterTeam
//                             ? Colors.transparent
//                             : ThemeColors.unifiedBorder,
//                         width: 1.5,
//                       ),
//                       boxShadow: state.filterTeam
//                           ? [
//                               BoxShadow(
//                                 color: const Color(0xFF0EA5E9).withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                           : null,
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.groups_rounded,
//                           size: 14,
//                           color: state.filterTeam
//                               ? Colors.white
//                               : ThemeColors.unifiedTextMuted,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           'MY TEAM',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w800,
//                             color: state.filterTeam
//                                 ? Colors.white
//                                 : ThemeColors.unifiedTextMuted,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         if (state.filterTeam) ...[
//                           const SizedBox(width: 4),
//                           const Icon(
//                             Icons.check_circle_rounded,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (state.filterTeam) ...[
//                   const SizedBox(width: 8),
//                   Text(
//                     'tickets from your team',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // ── Priority filters ──────────────────────────────────
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 30,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: priorities.length + 1,
//               itemBuilder: (context, i) {
//                 if (i == 0) {
//                   final active = state.filterPriority == null;
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 6),
//                     child: _PriorityDot(
//                       label: 'All',
//                       active: active,
//                       color: ThemeColors.unifiedTextMuted,
//                       onTap: () => context.read<DashboardBloc>().add(
//                         FilterTickets(
//                           status: state.filterStatus,
//                           priority: null,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 final p = priorities[i - 1];
//                 final active = p.name == state.filterPriority;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 6),
//                   child: _PriorityDot(
//                     label: p.name[0].toUpperCase() + p.name.substring(1),
//                     active: active,
//                     color: ticketPriorityColor(p.name),
//                     onTap: () => context.read<DashboardBloc>().add(
//                       FilterTickets(
//                         status: state.filterStatus,
//                         priority: p.name,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }

// // ── Pagination Button ──────────────────────────────────────────────
// class _PageBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool disabled;
//   final VoidCallback onTap;

//   const _PageBtn({
//     required this.icon,
//     required this.label,
//     required this.disabled,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = disabled
//         ? ThemeColors.unifiedTextMuted.withOpacity(0.3)
//         : ThemeColors.unifiedPrimary;
//     return GestureDetector(
//       onTap: disabled ? null : onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: disabled
//               ? ThemeColors.unifiedBackground
//               : ThemeColors.unifiedSurface,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: disabled
//                 ? ThemeColors.unifiedBorder.withOpacity(0.5)
//                 : ThemeColors.unifiedPrimary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Status filter chip ────────────────────────────────────────────────────────
// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color color;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.label,
//     required this.active,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           gradient: active
//               ? LinearGradient(
//                   colors: [color, color.withOpacity(0.75)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//           color: active ? null : ThemeColors.unifiedBackground,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: active ? Colors.transparent : ThemeColors.unifiedBorder,
//             width: 1.5,
//           ),
//           boxShadow: active
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           label.toUpperCase(),
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: active ? Colors.white : ThemeColors.unifiedTextMuted,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _PriorityDot extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color color;
//   final VoidCallback onTap;

//   const _PriorityDot({
//     required this.label,
//     required this.active,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         decoration: BoxDecoration(
//           // ← never use Colors.transparent — use a real color with opacity 0
//           color: active
//               ? color.withOpacity(0.12)
//               : ThemeColors.unifiedBackground,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: active ? color : ThemeColors.unifiedBorder,
//             width: 1.5,
//           ),
//           boxShadow: active
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.2),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: active ? color : ThemeColors.unifiedTextMuted,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const SizedBox(width: 5),
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 180),
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//                 color: active ? color : ThemeColors.unifiedTextMuted,
//               ),
//               child: Text(label),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Ticket body ───────────────────────────────────────────────────────────────
// class _TicketBody extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;

//   const _TicketBody({required this.state, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final displayTickets = state.filteredTickets;

//     if (displayTickets.isEmpty) {
//       final hasFilters = state.filterStatus != null ||
//           state.filterPriority != null ||
//           state.searchQuery.isNotEmpty;
//       return _EmptyState(
//         filterActive: hasFilters,
//         onClear: () {
//           context.read<DashboardBloc>().add(FilterTickets(status: null, priority: null));
//           context.read<DashboardBloc>().add(SearchTickets(''));
//         },
//       );
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final crossAxisCount = constraints.maxWidth > 1200
//             ? 3
//             : constraints.maxWidth > 700
//             ? 2
//             : 1;
//         const spacing = 12.0;
//         const padding = 16.0;
//         final cardWidth =
//             (constraints.maxWidth -
//                 padding * 2 -
//                 spacing * (crossAxisCount - 1)) /
//             crossAxisCount;

//         return Padding(
//           padding: const EdgeInsets.all(padding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Result summary strip ────────────────────────
//               if (state.filterStatus != null ||
//                   state.filterPriority != null ||
//                   state.searchQuery.isNotEmpty)
//                 _ResultSummary(state: state, count: displayTickets.length),
//               const SizedBox(height: 4),

//               // ── Ticket grid / list ──────────────────────────
//               Wrap(
//                 spacing: spacing,
//                 runSpacing: spacing,
//                 children: displayTickets
//                     .map(
//                       (t) => SizedBox(
//                         width: cardWidth,
//                         child: TicketCard(ticket: t, user: user),
//                       ),
//                     )
//                     .toList(),
//               ),
//               // ── Pagination ────────────────────────────────
//               if (state.totalPages > 1)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 24, bottom: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _PageBtn(
//                         icon: Icons.chevron_left_rounded,
//                         label: 'Previous',
//                         disabled: state.currentPage <= 1,
//                         onTap: () {
//                           if (state.currentPage > 1) {
//                             context.read<DashboardBloc>().add(
//                               LoadDashboard(page: state.currentPage - 1),
//                             );
//                           }
//                         },
//                       ),
//                       const SizedBox(width: 12),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: ThemeColors.unifiedSurface,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: ThemeColors.unifiedBorder,
//                           ),
//                         ),
//                         child: Text(
//                           'Page ${state.currentPage} of ${state.totalPages}',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: ThemeColors.unifiedTextPrimary,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       _PageBtn(
//                         icon: Icons.chevron_right_rounded,
//                         label: 'Next',
//                         disabled: state.currentPage >= state.totalPages,
//                         onTap: () {
//                           if (state.currentPage < state.totalPages) {
//                             context.read<DashboardBloc>().add(
//                               LoadDashboard(page: state.currentPage + 1),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Result summary ────────────────────────────────────────────────────────────
// class _ResultSummary extends StatelessWidget {
//   final DashboardLoaded state;
//   final int count;
//   const _ResultSummary({required this.state, this.count = 0});

//   @override
//   Widget build(BuildContext context) {
//     final parts = <String>[];
//     if (state.filterStatus != null)
//       parts.add(state.filterStatus!.replaceAll('_', ' ').toUpperCase());
//     if (state.filterPriority != null)
//       parts.add(state.filterPriority!.toUpperCase() + ' PRIORITY');

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.filter_alt_rounded,
//             size: 14,
//             color: ThemeColors.unifiedPrimary,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'Showing $count result${count == 1 ? '' : 's'}'
//               ' · ${parts.join(' · ')}'
//               '${state.searchQuery.isNotEmpty ? ' · "${state.searchQuery}"' : ''}',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // KANBAN BOARD VIEW (Trello-like columns by status)
// // ══════════════════════════════════════════════════════════════════════════════
// class _KanbanBoard extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;
//   const _KanbanBoard({required this.state, required this.user});

//   static const _statuses = ['open', 'in_progress', 'completed', 'closed'];

//   static Color _columnColor(String status) {
//     switch (status) {
//       case 'open': return const Color(0xFF22C55E);
//       case 'in_progress': return const Color(0xFF3B82F6);
//       case 'completed': return const Color(0xFF10B981);
//       case 'closed': return const Color(0xFF6B7280);
//       default: return Colors.grey;
//     }
//   }

//   static String _statusLabel(String s) {
//     switch (s) {
//       case 'open': return 'Open';
//       case 'in_progress': return 'In Progress';
//       case 'completed': return 'Completed';
//       case 'closed': return 'Closed';
//       default: return s;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final all = state.filteredTickets;
//     final grouped = <String, List<TicketModel>>{};
//     for (final s in _statuses) {
//       grouped[s] = all.where((t) => t.status == s).toList();
//     }

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.65,
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: _statuses.map((status) {
//           final tickets = grouped[status]!;
//           return _KanbanColumn(
//             status: status,
//             label: _statusLabel(status),
//             color: _columnColor(status),
//             tickets: tickets,
//             user: user,
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _KanbanColumn extends StatelessWidget {
//   final String status;
//   final String label;
//   final Color color;
//   final List<TicketModel> tickets;
//   final UserModel user;

//   const _KanbanColumn({
//     required this.status,
//     required this.label,
//     required this.color,
//     required this.tickets,
//     required this.user,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       margin: const EdgeInsets.only(right: 12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.04),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.15)),
//       ),
//       child: Column(
//         children: [
//           // ── Column header ──────────────────────────────────
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 10, height: 10,
//                   decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800,
//                     color: color,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     '${tickets.length}',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       color: color,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Ticket list ────────────────────────────────────
//           Expanded(
//             child: tickets.isEmpty
//                 ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Text(
//                         'No tickets',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: color.withOpacity(0.4),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//                     itemCount: tickets.length,
//                     itemBuilder: (context, i) => _KanbanCard(
//                       ticket: tickets[i],
//                       user: user,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _KanbanCard extends StatelessWidget {
//   final TicketModel ticket;
//   final UserModel user;
//   const _KanbanCard({required this.ticket, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final pColor = ticketPriorityColor(ticket.priority);
//     return GestureDetector(
//       onTap: () => context.push('/ticket/${ticket.id}'),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border(
//             left: BorderSide(color: pColor, width: 3),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Ticket number + priority
//             Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     ticket.ticketNumber.isNotEmpty
//                         ? ticket.ticketNumber
//                         : '#${ticket.id}',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF9CA3AF),
//                       letterSpacing: 0.5,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   width: 8, height: 8,
//                   decoration: BoxDecoration(
//                     color: pColor,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             // Title
//             Text(
//               ticket.title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1F2937),
//                 height: 1.3,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             // Bottom row: assignee + dept
//             Row(
//               children: [
//                 Icon(
//                   Icons.person_outline_rounded,
//                   size: 11,
//                   color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
//                 ),
//                 const SizedBox(width: 3),
//                 Expanded(
//                   child: Text(
//                     ticket.assignedToName ?? 'Unassigned',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Empty state ───────────────────────────────────────────────────────────────
// class _EmptyState extends StatelessWidget {
//   final bool filterActive;
//   final VoidCallback onClear;

//   const _EmptyState({required this.filterActive, required this.onClear});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: ThemeColors.unifiedPrimary.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: ThemeColors.unifiedPrimary.withOpacity(0.15),
//                   width: 1.5,
//                 ),
//               ),
//               child: Icon(
//                 filterActive
//                     ? Icons.filter_alt_off_rounded
//                     : Icons.inbox_rounded,
//                 size: 34,
//                 color: ThemeColors.unifiedPrimary.withOpacity(0.5),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               filterActive ? 'No matching tickets' : 'No tickets yet',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               filterActive
//                   ? 'Try adjusting or clearing your filters'
//                   : 'Tickets assigned to your department will appear here',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: ThemeColors.unifiedTextMuted,
//                 height: 1.5,
//               ),
//             ),
//             if (filterActive) ...[
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: onClear,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 11,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         ThemeColors.unifiedGradStart,
//                         ThemeColors.unifiedGradEnd,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: ThemeColors.unifiedPrimary.withOpacity(0.25),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Icon(
//                         Icons.filter_alt_off_rounded,
//                         size: 15,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 7),
//                       Text(
//                         'Clear Filters',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
