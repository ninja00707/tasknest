import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/ticket_card_module/widget/ticket_card.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_grid_card.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_bloc.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_event.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_state.dart';
import 'config.dart';

class TicketListWidget extends StatelessWidget {
  final String configKey;
  final Widget child;

  const TicketListWidget({
    super.key,
    required this.configKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}

class TicketListBody extends StatelessWidget {
  final TicketListConfig config;

  const TicketListBody({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketListBloc, TicketListState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.headerStyle != TicketHeaderStyle.none ||
                config.customHeader != null)
              _buildHeader(context, state),

            if (config.enableFilters &&
                config.statusTabs != null &&
                config.viewType != TicketViewType.kanban)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: _FilterTabs(
                  tabs: config.statusTabs!,
                  active: state.currentFilter,
                  onChanged: (v) => context.read<TicketListBloc>().add(FilterChanged(v)),
                ),
              ),

            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TicketListState state) {
    if (config.customHeader != null) return config.customHeader!;

    switch (config.headerStyle) {
      case TicketHeaderStyle.myTickets:
        return _GradientHeader(
          icon: Icons.assignment_ind_rounded,
          gradientColors: const [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
          title: ConstStrings.navMyTickets,
          subtitle: '${state.allTickets.length} assigned tickets',
          stats: [
            _StatData(label: 'Open', count: state.openCount, color: ThemeColors.unifiedSecondary),
            _StatData(label: 'In Progress', count: state.inProgressCount, color: ThemeColors.unifiedWarning),
            _StatData(label: 'Completed', count: state.completedCount, color: ThemeColors.unifiedAccent),
          ],
        );

      case TicketHeaderStyle.recentActivity:
        return _GradientHeader(
          icon: Icons.history_rounded,
          gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
          title: ConstStrings.navRecentActivities,
          subtitle: '${state.allTickets.length} tickets · sorted by newest first',
        );

      case TicketHeaderStyle.sentSubTickets:
        return _GradientHeader(
          icon: Icons.hub_outlined,
          gradientColors: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
          title: ConstStrings.navSentSubTickets,
          subtitle: '${state.allTickets.length} tickets forwarded to other departments',
          stats: [
            _StatData(label: 'Total Sent', count: state.allTickets.length, color: const Color(0xFF7C3AED)),
            _StatData(label: 'Active', count: state.pendingCount, color: ThemeColors.unifiedWarning),
            _StatData(label: 'Completed', count: state.sentCompletedCount, color: ThemeColors.unifiedAccent),
          ],
        );

      case TicketHeaderStyle.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody(BuildContext context, TicketListState state) {
    final all = state.pagedTickets;

    if (all.isEmpty) {
      return _EmptyState(
        icon: config.emptyIcon,
        title: config.emptyTitle,
        subtitle: config.emptySubtitle,
      );
    }

    switch (config.viewType) {
      case TicketViewType.grid:
        return _buildGrid(context, all, state);
      case TicketViewType.timeline:
        return _buildTimeline(context, all);
      case TicketViewType.kanban:
        return _buildKanban(context, state);
      case TicketViewType.list:
        return _buildList(context, state);
    }
  }

  Widget _buildGrid(BuildContext context, List<TicketModel> tickets, TicketListState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 3
                    : constraints.maxWidth > 700
                    ? 2
                    : 1;
                const spacing = 12.0;
                final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                final rowCount = ((tickets.length + crossAxisCount - 1) / crossAxisCount).floor();

                return ListView.builder(
                  itemCount: rowCount,
                  itemBuilder: (context, rowIndex) {
                    final start = rowIndex * crossAxisCount;
                    final end = (start + crossAxisCount).clamp(0, tickets.length);
                    return Padding(
                      padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? spacing : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = start; i < end; i++)
                            Padding(
                              padding: EdgeInsets.only(right: i < end - 1 ? spacing : 0),
                              child: SizedBox(
                                width: cardWidth,
                                child: config.cardStyle == TicketCardStyle.compact
                                    ? TicketGridCard(ticket: tickets[i])
                                    : TicketCard(ticket: tickets[i], user: config.user),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildPagination(context, state),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<TicketModel> tickets) {
    return Column(
      children: [
        Expanded(
          child: CommonListViewBuilder(
            items: tickets,
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemBuilder: (context, t, index) =>
                _TimelineCard(ticket: t, onTap: () => _onTap(context, t)),
          ),
        ),
        _buildPagination(context, context.read<TicketListBloc>().state),
      ],
    );
  }

  Widget _buildKanban(BuildContext context, TicketListState state) {
    const statuses = ['open', 'in_progress', 'completed', 'closed'];
    final grouped = <String, List<TicketModel>>{};
    for (final s in statuses) {
      grouped[s] = state.allTickets.where((t) => t.status == s).toList()
        ..sort((a, b) => CommonStatus.priorityWeight(a.priority).compareTo(CommonStatus.priorityWeight(b.priority)));
    }

    return Container(
      height: state.screenWidth * 0.65,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: statuses.map((status) {
          final tickets = grouped[status]!;
          return _KanbanColumn(
            status: status,
            label: CommonStatus.statusLabel(status),
            tickets: tickets,
            onTap: (t) => _onTap(context, t),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(BuildContext context, TicketListState state) {
    const statusFlow = ['open', 'in_progress', 'completed', 'closed'];
    final visible = state.allTickets.where((t) => statusFlow.contains(t.status));
    final grouped = <String, List<TicketModel>>{};
    for (final t in visible) {
      grouped.putIfAbsent(t.status, () => []).add(t);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1200 ? 3 : constraints.maxWidth > 700 ? 2 : 1;
          const spacing = 12.0;
          final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final status in statusFlow)
                  if ((grouped[status]?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusHeader(status: status, count: grouped[status]!.length),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: grouped[status]!
                                .map((t) => SizedBox(
                                      width: cardWidth,
                                      child: TicketCard(ticket: t, user: config.user),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                _buildPagination(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagination(BuildContext context, TicketListState state) {
    if (!config.enablePagination) return const SizedBox.shrink();
    final total = state.totalPages;
    if (total <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageBtn(
            icon: Icons.chevron_left,
            label: ConstStrings.previous,
            disabled: state.currentPage <= 1,
            onTap: () => context.read<TicketListBloc>().add(PageChanged(state.currentPage - 1)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder.withValues(alpha: 0.5)),
            ),
            child: Text(
              'Page ${state.currentPage} of $total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _PageBtn(
            icon: Icons.chevron_right,
            label: ConstStrings.next,
            disabled: state.currentPage >= total,
            onTap: () => context.read<TicketListBloc>().add(PageChanged(state.currentPage + 1)),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, TicketModel t) {
    if (config.onTap != null) {
      config.onTap!(t);
    } else {
      context.push('/ticket/${t.id}');
    }
  }
}

class _StatData {
  final String label;
  final int count;
  final Color color;
  const _StatData({required this.label, required this.count, required this.color});
}

class _GradientHeader extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final List<_StatData>? stats;

  const _GradientHeader({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = context.select<TicketListBloc, bool>((b) => b.state.isWide);
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, isWide ? 28 : 16, isWide ? 28 : 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmallMuted),
                  ],
                ),
              ),
            ],
          ),
          if (stats != null) ...[
            const SizedBox(height: 18),
            Row(
              children: stats!
                  .map((s) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: _MiniStat(label: s.label, count: s.count, color: s.color))))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final List<String> tabs;
  final String active;
  final ValueChanged<String> onChanged;

  const _FilterTabs({required this.tabs, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isActive = active == t;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? ThemeColors.unifiedPrimary : ThemeColors.unifiedSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? ThemeColors.unifiedPrimary : ThemeColors.unifiedBorder),
                ),
                child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : ThemeColors.unifiedTextMuted)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyState({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppTextStyles.caption, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;
  final VoidCallback onTap;

  const _PageBtn({required this.icon, required this.label, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = disabled ? ThemeColors.unifiedTextMuted.withValues(alpha: 0.3) : ThemeColors.unifiedPrimary;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: disabled ? ThemeColors.unifiedBackground : ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: disabled ? ThemeColors.unifiedBorder.withValues(alpha: 0.5) : ThemeColors.unifiedPrimary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.chevron_left) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 4)],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            if (icon == Icons.chevron_right) ...[const SizedBox(width: 4), Icon(icon, size: 16, color: color)],
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  const _TimelineCard({required this.ticket, required this.onTap});

  Color get _tint => CommonStatus.ticketStatusColor(ticket.status);

  IconData get _icon {
    if (ticket.isMultiTaskTicket) return Icons.hub_rounded;
    if (ticket.children.isNotEmpty) return Icons.account_tree_rounded;
    return Icons.article_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = ticket.createdAt.toString().substring(0, 10);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: _tint.withValues(alpha: 0.12), shape: BoxShape.circle, border: Border.all(color: _tint.withValues(alpha: 0.4), width: 2)),
                  child: Icon(_icon, size: 13, color: _tint),
                ),
                Expanded(child: Container(width: 2, color: ThemeColors.unifiedBorder.withValues(alpha: 0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeColors.unifiedBorder.withValues(alpha: 0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ticket.ticketNumber.isNotEmpty ? ticket.ticketNumber : '#${ticket.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextMuted)),
                        const SizedBox(width: 6),
                        PriorityBadge(priority: ticket.priority),
                        const SizedBox(width: 4),
                        StatusBadge(status: ticket.status),
                        const Spacer(),
                        Text(dateStr, style: AppTextStyles.micro),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (ticket.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(ticket.description, style: const TextStyle(fontSize: 11, color: ThemeColors.unifiedTextMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 11, color: ThemeColors.unifiedPrimary),
                        const SizedBox(width: 3),
                        Text(ticket.createdByDeptCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 11, color: ThemeColors.unifiedSecondary),
                        const SizedBox(width: 3),
                        Text(ticket.assignedDeptCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
                        if (ticket.assignedToName != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.person_outline_rounded, size: 11, color: ThemeColors.unifiedTextMuted),
                          const SizedBox(width: 3),
                          Flexible(child: Text(ticket.assignedToName!, style: AppTextStyles.micro, overflow: TextOverflow.ellipsis)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String status;
  final String label;
  final List<TicketModel> tickets;
  final void Function(TicketModel) onTap;

  const _KanbanColumn({required this.status, required this.label, required this.tickets, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = CommonStatus.columnColor(status);
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.3)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('${tickets.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                ),
              ],
            ),
          ),
          Expanded(
            child: tickets.isEmpty
                ? Center(child: Text(ConstStrings.noTickets, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.4), fontWeight: FontWeight.w600)))
                : CommonListViewBuilder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    items: tickets,
                    itemBuilder: (context, ticket, index) => _KanbanCard(ticket: ticket, onTap: () => onTap(ticket)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  const _KanbanCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: CommonStatus.ticketPriorityColor(ticket.priority), width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(child: Text(ticket.ticketNumber.isNotEmpty ? ticket.ticketNumber : '#${ticket.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
                const Spacer(),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: CommonStatus.ticketPriorityColor(ticket.priority), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1F2937), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 11, color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(ticket.assignedToName ?? 'Unassigned', style: TextStyle(fontSize: 10, color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.7), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final String status;
  final int count;
  const _StatusHeader({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: CommonStatus.ticketStatusColor(status), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(CommonStatus.statusLabel(status), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary, letterSpacing: -0.1)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: CommonStatus.ticketStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CommonStatus.ticketStatusColor(status))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: ThemeColors.unifiedBorder.withValues(alpha: 0.6))),
      ],
    );
  }
}
