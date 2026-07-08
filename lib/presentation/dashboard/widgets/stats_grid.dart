import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const StatsGrid({super.key, required this.s, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      StatItem(ConstStrings.statTotal, s.total, ThemeColors.unifiedPrimary, Icons.inbox_outlined),
      StatItem(ConstStrings.statOpen, s.open, ThemeColors.unifiedSecondary, Icons.radio_button_unchecked_rounded),
      StatItem(ConstStrings.statInProgress, s.inProgress, ThemeColors.unifiedWarning, Icons.autorenew_rounded),
      StatItem(ConstStrings.statCompleted, s.completed, ThemeColors.unifiedAccent, Icons.check_circle_outline_rounded),
      StatItem(ConstStrings.statClosed, s.closed, ThemeColors.unifiedTextMuted, Icons.lock_outline_rounded),
      StatItem(ConstStrings.statUrgent, s.urgent, ThemeColors.unifiedDanger, Icons.warning_amber_rounded),
      StatItem(ConstStrings.statHighPri, s.highPriority, ThemeColors.unifiedHighPriority, Icons.priority_high_rounded),
      StatItem(ConstStrings.statOverdue, s.overdue, ThemeColors.unifiedDanger, Icons.access_time_rounded),
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
          color: ThemeColors.unifiedBorder.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.06),
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
                    item.color.withValues(alpha: 0.16),
                    item.color.withValues(alpha: 0.06),
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
  const StatTextContent({super.key, required this.value, required this.label});

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
