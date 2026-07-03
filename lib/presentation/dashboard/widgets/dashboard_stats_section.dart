import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class DashboardStatsSection extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const DashboardStatsSection({super.key, required this.s, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommaonSectionHeader(
          icon: Icons.bar_chart_rounded,
          title: 'Overview',
        ),
        const SizedBox(height: 12),
        StatsGrid(s: s, isWide: isWide),
        const SizedBox(height: 28),
        CommaonSectionHeader(
          icon: Icons.av_timer_rounded,
          title: 'Resolution Metrics',
        ),
        const SizedBox(height: 12),
        ResolutionMetricsRow(s: s, isWide: isWide),
        const SizedBox(height: 28),
        CommaonSectionHeader(
          icon: Icons.flag_outlined,
          title: 'Priority Breakdown',
        ),
        const SizedBox(height: 12),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: PriorityCard(s: s)),
                  const SizedBox(width: 16),
                  Expanded(child: StatusSummaryCard(s: s)),
                ],
              )
            : Column(
                children: [
                  PriorityCard(s: s),
                  const SizedBox(height: 16),
                  StatusSummaryCard(s: s),
                ],
              ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const StatsGrid({super.key, required this.s, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      StatItem('Total', s.total, ThemeColors.unifiedPrimary, Icons.inbox_outlined),
      StatItem('Open', s.open, ThemeColors.unifiedSecondary, Icons.radio_button_unchecked_rounded),
      StatItem('In Progress', s.inProgress, ThemeColors.unifiedWarning, Icons.autorenew_rounded),
      StatItem('Completed', s.completed, ThemeColors.unifiedAccent, Icons.check_circle_outline_rounded),
      StatItem('Closed', s.closed, ThemeColors.unifiedTextMuted, Icons.lock_outline_rounded),
      StatItem('Urgent', s.urgent, ThemeColors.unifiedDanger, Icons.warning_amber_rounded),
      StatItem('High Pri.', s.highPriority, const Color(0xFFEA580C), Icons.priority_high_rounded),
      StatItem('Overdue', s.overdue, ThemeColors.unifiedDanger, Icons.access_time_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide
            ? 4
            : (MediaQuery.sizeOf(context).width > 480 ? 2 : 1),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isWide ? 3.0 : 2.1,
      ),
      itemBuilder: (_, i) => StatCard(item: items[i]),
    );
  }
}

class StatItem {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const StatItem(this.label, this.value, this.color, this.icon);
}

class StatCard extends StatelessWidget {
  final StatItem item;
  const StatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemeColors.unifiedBorder.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color.withOpacity(0.16),
                    item.color.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 19, color: item.color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: StatTextContent(value: item.value, label: item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTextContent extends StatelessWidget {
  final int value;
  final String label;
  const StatTextContent({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: ThemeColors.unifiedTextMuted,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ResolutionMetricsRow extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const ResolutionMetricsRow({required this.s, required this.isWide});

  String _avgTime() {
    final resolved = s.completed + s.closed;
    if (resolved == 0) return '\u2014';
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = s.total > 0
        ? ((s.completed / s.total) * 100).toStringAsFixed(1)
        : '0.0';
    final overdueRate = s.total > 0
        ? ((s.overdue / s.total) * 100).toStringAsFixed(1)
        : '0.0';

    final tiles = [
      ResolItem(
        icon: Icons.av_timer_rounded,
        label: 'Avg. Resolution Time',
        value: _avgTime(),
        sub: 'per ticket closed',
        color: ThemeColors.unifiedSecondary,
      ),
      ResolItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Completion Rate',
        value: '$completionRate%',
        sub: '${s.completed} of ${s.total} tickets',
        color: ThemeColors.unifiedAccent,
      ),
      ResolItem(
        icon: Icons.access_time_rounded,
        label: 'Overdue Rate',
        value: '$overdueRate%',
        sub: '${s.overdue} overdue tickets',
        color: ThemeColors.unifiedDanger,
      ),
      ResolItem(
        icon: Icons.warning_amber_rounded,
        label: 'Critical Load',
        value: '${s.urgent}',
        sub: 'urgent tickets open',
        color: const Color(0xFFEA580C),
      ),
    ];

    return isWide
        ? Row(
            children: tiles
                .map(
                  (t) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: tiles.indexOf(t) < tiles.length - 1 ? 12 : 0,
                      ),
                      child: ResolutionTile(item: t),
                    ),
                  ),
                )
                .toList(),
          )
        : GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: tiles.map((t) => ResolutionTile(item: t)).toList(),
          );
  }
}

class ResolItem {
  final IconData icon;
  final String label, value, sub;
  final Color color;
  const ResolItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}

class ResolutionTile extends StatelessWidget {
  final ResolItem item;
  const ResolutionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withOpacity(0.18),
                      item.color.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, size: 17, color: item.color),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: item.color,
              letterSpacing: -0.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.sub,
            style: const TextStyle(
              fontSize: 11,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityCard extends StatelessWidget {
  final DashboardStats s;
  const PriorityCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final items = [
      PriorityItem('Urgent', s.urgent, ThemeColors.unifiedDanger),
      PriorityItem('High', s.highPriority, const Color(0xFFEA580C)),
      PriorityItem(
        'Medium & Low',
        total - s.urgent - s.highPriority,
        ThemeColors.unifiedPrimary,
      ),
    ];

    return BaseCard(
      icon: Icons.flag_outlined,
      title: 'Priority Distribution',
      child: Column(
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PriorityBar(item: e, total: total),
              ),
            )
            .toList(),
      ),
    );
  }
}

class PriorityItem {
  final String label;
  final int value;
  final Color color;
  const PriorityItem(this.label, this.value, this.color);
}

class PriorityBar extends StatelessWidget {
  final PriorityItem item;
  final int total;
  const PriorityBar({required this.item, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? item.value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${item.value} (${(pct * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: item.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

class StatusSummaryCard extends StatelessWidget {
  final DashboardStats s;
  const StatusSummaryCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final rows = [
      StatusItem('Open', s.open, total, ThemeColors.unifiedSecondary, ThemeColors.statusOpenBg, ThemeColors.statusOpenFg),
      StatusItem('In Progress', s.inProgress, total, ThemeColors.unifiedWarning, ThemeColors.statusProgressBg, ThemeColors.statusProgressFg),
      StatusItem('Completed', s.completed, total, ThemeColors.unifiedAccent, ThemeColors.statusDoneBg, ThemeColors.statusDoneFg),
      StatusItem('Closed', s.closed, total, ThemeColors.unifiedTextMuted, ThemeColors.statusClosedBg, ThemeColors.statusClosedFg),
    ];

    return BaseCard(
      icon: Icons.donut_small_outlined,
      title: 'Status Summary',
      child: Column(children: rows.map((e) => StatusRow(item: e)).toList()),
    );
  }
}

class StatusItem {
  final String label;
  final int count, total;
  final Color dotColor, badgeBg, badgeFg;
  const StatusItem(
    this.label,
    this.count,
    this.total,
    this.dotColor,
    this.badgeBg,
    this.badgeFg,
  );
}

class StatusRow extends StatelessWidget {
  final StatusItem item;
  const StatusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct = item.total > 0
        ? ((item.count / item.total) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: item.badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${item.count}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.badgeFg,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BaseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const BaseCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeColors.unifiedBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.unifiedPrimary.withOpacity(0.16),
                        ThemeColors.unifiedPrimary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
