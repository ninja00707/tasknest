import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class PriorityCard extends StatelessWidget {
  final DashboardStats s;
  const PriorityCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final items = [
      PriorityItem(
        ConstStrings.statUrgent,
        s.urgent,
        ThemeColors.unifiedDanger,
      ),
      PriorityItem('High', s.highPriority, ThemeColors.unifiedHighPriority),
      PriorityItem(
        ConstStrings.priorityMediumLow,
        total - s.urgent - s.highPriority,
        ThemeColors.unifiedPrimary,
      ),
    ];

    return BaseCard(
      icon: Icons.flag_outlined,
      title: ConstStrings.priorityDistribution,
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
  const PriorityBar({super.key, required this.item, required this.total});

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
            backgroundColor: item.color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

class StatusSummaryCard extends StatelessWidget {
  final DashboardStats s;
  const StatusSummaryCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final rows = [
      StatusItem(
        ConstStrings.statusOpen,
        s.open,
        total,
        ThemeColors.unifiedSecondary,
        ThemeColors.statusOpenBg,
        ThemeColors.statusOpenFg,
      ),
      StatusItem(
        ConstStrings.statusInProgress,
        s.inProgress,
        total,
        ThemeColors.unifiedWarning,
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
      ),
      StatusItem(
        ConstStrings.statusCompleted,
        s.completed,
        total,
        ThemeColors.unifiedAccent,
        ThemeColors.statusDoneBg,
        ThemeColors.statusDoneFg,
      ),
      StatusItem(
        ConstStrings.statusClosed,
        s.closed,
        total,
        ThemeColors.unifiedTextMuted,
        ThemeColors.statusClosedBg,
        ThemeColors.statusClosedFg,
      ),
    ];

    return BaseCard(
      icon: Icons.donut_small_outlined,
      title: ConstStrings.statusSummary,
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
  const StatusRow({super.key, required this.item});

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
    super.key,
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
            color: Colors.black.withValues(alpha: 0.05),
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
                        ThemeColors.unifiedPrimary.withValues(alpha: 0.16),
                        ThemeColors.unifiedPrimary.withValues(alpha: 0.06),
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
