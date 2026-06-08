import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketListView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketListView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterBar(state: state),
        Expanded(
          child: _TicketBody(state: state, user: user),
        ),
      ],
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final DashboardLoaded state;
  const _FilterBar({required this.state});

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

// ── Ticket body ───────────────────────────────────────────────────────────────
class _TicketBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const _TicketBody({required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    if (state.tickets.isEmpty) {
      return _EmptyState(
        filterActive:
            state.filterStatus != null || state.filterPriority != null,
        onClear: () => context.read<DashboardBloc>().add(
          FilterTickets(status: null, priority: null),
        ),
      );
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Result summary strip ────────────────────────
              if (state.filterStatus != null || state.filterPriority != null)
                _ResultSummary(state: state),
              const SizedBox(height: 4),

              // ── Ticket grid / list ──────────────────────────
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: state.tickets
                    .map(
                      (t) => SizedBox(
                        width: cardWidth,
                        child: TicketCard(ticket: t, user: user),
                      ),
                    )
                    .toList(),
              ),
              // ── Pagination ────────────────────────────────
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
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
                          horizontal: 14, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ThemeColors.unifiedBorder,
                          ),
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

// ── Result summary ────────────────────────────────────────────────────────────
class _ResultSummary extends StatelessWidget {
  final DashboardLoaded state;
  const _ResultSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (state.filterStatus != null)
      parts.add(state.filterStatus!.replaceAll('_', ' ').toUpperCase());
    if (state.filterPriority != null)
      parts.add(state.filterPriority!.toUpperCase() + ' PRIORITY');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              'Showing ${state.tickets.length} result${state.tickets.length == 1 ? '' : 's'}'
              ' · ${parts.join(' · ')}',
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

