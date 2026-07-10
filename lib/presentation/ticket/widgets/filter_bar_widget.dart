import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';

// ── Filter bar ────────────────────────────────────────────────────────────────
class FilterBarWidget extends StatelessWidget {
  final DashboardLoaded state;
  const FilterBarWidget({super.key, required this.state});

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
                    color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
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
                  ConstStrings.tickets,
                  style: AppTextStyles.sectionHeader,
                ),
                const Spacer(),
                // Active filter indicator
                if (state.filterStatus != null || state.filterPriority != null)
                  GestureDetector(
                    onTap: () => context.read<DashboardBloc>().add(
                      FilterTickets(
                        status: null,
                        priority: null,
                        teamOnly: state.filterTeam,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedDanger.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeColors.unifiedDanger.withValues(
                            alpha: 0.2,
                          ),
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
                            ConstStrings.clearFilters,
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
                    color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
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
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = statuses[i];
                final active =
                    (s.name == 'All' && state.filterStatus == null) ||
                    s.name == state.filterStatus;
                return FilterChip(
                  label: s.name == 'All' ? 'All' : s.name.replaceAll('_', ' '),
                  active: active,
                  color: ticketStatusColor(s.name),
                  onTap: () => context.read<DashboardBloc>().add(
                    FilterTickets(
                      status: s.name == 'All' ? null : s.name,
                      priority: state.filterPriority,
                      teamOnly: state.filterTeam,
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
                    FilterTickets(
                      status: state.filterStatus,
                      priority: state.filterPriority,
                      teamOnly: !state.filterTeam,
                    ),
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
                                color: const Color(
                                  0xFF0EA5E9,
                                ).withValues(alpha: 0.3),
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
                          ConstStrings.myTeam,
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
                    ConstStrings.ticketsFromYourTeam,
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeColors.unifiedTextMuted.withValues(
                        alpha: 0.7,
                      ),
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
                    child: PriorityDot(
                      label: 'All',
                      active: active,
                      color: ThemeColors.unifiedTextMuted,
                      onTap: () => context.read<DashboardBloc>().add(
                        FilterTickets(
                          status: state.filterStatus,
                          priority: null,
                          teamOnly: state.filterTeam,
                        ),
                      ),
                    ),
                  );
                }
                final p = priorities[i - 1];
                final active = p.name == state.filterPriority;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: PriorityDot(
                    label: p.name[0].toUpperCase() + p.name.substring(1),
                    active: active,
                    color: ticketPriorityColor(p.name),
                    onTap: () => context.read<DashboardBloc>().add(
                      FilterTickets(
                        status: state.filterStatus,
                        priority: p.name,
                        teamOnly: state.filterTeam,
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
class PageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;
  final VoidCallback onTap;

  const PageBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = disabled
        ? ThemeColors.unifiedTextMuted.withValues(alpha: 0.3)
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
                ? ThemeColors.unifiedBorder.withValues(alpha: 0.5)
                : ThemeColors.unifiedPrimary.withValues(alpha: 0.3),
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
class FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const FilterChip({
    super.key,
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
                  colors: [color, color.withValues(alpha: 0.75)],
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
                    color: color.withValues(alpha: 0.3),
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

// ── Priority dot ──────────────────────────────────────────────────────────────
class PriorityDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const PriorityDot({
    super.key,
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
              ? color.withValues(alpha: 0.12)
              : ThemeColors.unifiedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : ThemeColors.unifiedBorder,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
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
