import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_status_color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class ChildDetailCard extends StatelessWidget {
  final ChildTicketModel child;
  const ChildDetailCard({super.key, required this.child});

  void _showDetailDialog(BuildContext context) {
    final statusColor = CommonStatusColor.statusColor(child.status);
    final statusBg = statusColor.withValues(alpha: 0.12);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SUB-TICKET',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C3AED),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            child.status.toUpperCase().replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      child.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.unifiedTextPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (child.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ThemeColors.unifiedBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            child.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeColors.unifiedTextPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                      if (child.description.isNotEmpty)
                        const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _detailTile(
                            Icons.tag_rounded,
                            'Ticket #',
                            child.ticketNumber,
                          ),
                          _detailTile(
                            Icons.flag_outlined,
                            'Priority',
                            child.priority.toUpperCase(),
                            valueColor: CommonStatusColor.statusColor(
                              child.priority,
                            ),
                          ),
                          _detailTile(
                            Icons.business_outlined,
                            'Department',
                            child.deptCode,
                          ),
                          if (child.deptName.isNotEmpty)
                            _detailTile(
                              Icons.domain_outlined,
                              'Dept Name',
                              child.deptName,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _detailTile(
                            Icons.calendar_today_outlined,
                            'Created',
                            '${_dayName(child.createdAt)} ${child.createdAt.day}/${child.createdAt.month}/${child.createdAt.year}',
                          ),
                          _detailTile(
                            Icons.person_outline,
                            'Created by',
                            child.createdByName,
                          ),
                          if (child.assigneeName != null)
                            _detailTile(
                              Icons.person_pin_outlined,
                              'Assigned to',
                              child.assigneeName!,
                            ),
                        ],
                      ),
                      if (child.immediateChildCount > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFF7C3AED,
                              ).withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_tree_outlined,
                                size: 16,
                                color: Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${child.immediateChildCount} sub-task${child.immediateChildCount > 1 ? 's' : ''} ${child.hasActiveChildren ? '(active)' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeColors.unifiedTextMuted,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayName(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(d.weekday - 1) % 7];
  }

  Widget _detailTile(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.unifiedBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThemeColors.unifiedTextMuted),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? ThemeColors.unifiedTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
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
                    ).withValues(alpha: 0.2),
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
                  const Icon(
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
                const Icon(
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
                  const Icon(
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
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
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
      ),
    );
  }
}
