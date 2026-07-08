import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class ResolutionMetricsRow extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const ResolutionMetricsRow({super.key, required this.s, required this.isWide});

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
        label: ConstStrings.avgResolutionTime,
        value: _avgTime(),
        sub: ConstStrings.perTicketClosed,
        color: ThemeColors.unifiedSecondary,
      ),
      ResolItem(
        icon: Icons.check_circle_outline_rounded,
        label: ConstStrings.completionRate,
        value: '$completionRate%',
        sub: '${s.completed} of ${s.total} tickets',
        color: ThemeColors.unifiedAccent,
      ),
      ResolItem(
        icon: Icons.access_time_rounded,
        label: ConstStrings.overdueRate,
        value: '$overdueRate%',
        sub: '${s.overdue} ${ConstStrings.overdueTickets}',
        color: ThemeColors.unifiedDanger,
      ),
      ResolItem(
        icon: Icons.warning_amber_rounded,
        label: ConstStrings.criticalLoad,
        value: '${s.urgent}',
        sub: ConstStrings.urgentTicketsOpen,
        color: ThemeColors.unifiedHighPriority,
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
  const ResolutionTile({super.key, required this.item});

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
            color: item.color.withValues(alpha: 0.08),
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
                      item.color.withValues(alpha: 0.18),
                      item.color.withValues(alpha: 0.06),
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
