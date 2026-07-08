import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_status_color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class ChildDetailCard extends StatelessWidget {
  final ChildTicketModel child;
  const ChildDetailCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: CommonStatusColor.statusColor(child.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  child.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: CommonStatusColor.statusColor(
                    child.status,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  child.status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: CommonStatusColor.statusColor(child.status),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (child.ticketNumber.isNotEmpty) ...[
                Icon(
                  Icons.tag_rounded,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  child.ticketNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.business_outlined,
                size: 11,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 3),
              Text(
                child.deptCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (child.assigneeName != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  child.assigneeName!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (child.hasActiveChildren)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HAS SUB-TASKS',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C3AED),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              if (child.immediateChildCount > 0 && !child.hasActiveChildren)
                Text(
                  '${child.immediateChildCount} sub-task${child.immediateChildCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
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
