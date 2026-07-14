import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_pagination_listview.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';

class RecentTicketsView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel? userModel;

  const RecentTicketsView({
    super.key,
    required this.state,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final all = [...state.tickets];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final isWide = MediaQuery.of(context).size.width > 900;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActivityHeader(total: all.length),
            const SizedBox(height: 20),
            Expanded(
              child: all.isEmpty
                  ? _ActivityEmptyState()
                  : CommonPaginationListView(
                      items: all,
                      pageSize: 10,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4),
                      itemBuilder: (context, t, index) =>
                          _ActivityTicketCard(ticket: t),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  final int total;
  const _ActivityHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                ConstStrings.navRecentActivities,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$total tickets · sorted by newest first',
                style: AppTextStyles.bodySmallMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTicketCard extends StatelessWidget {
  final TicketModel ticket;
  const _ActivityTicketCard({required this.ticket});

  Color get _tint => ticketStatusColor(ticket.status);

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            // Timeline line + dot
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _tint.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _tint.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(_icon, size: 13, color: _tint),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/ticket/${ticket.id}'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ticket.ticketNumber.isNotEmpty
                                ? ticket.ticketNumber
                                : '#${ticket.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          PriorityBadge(priority: ticket.priority),
                          const SizedBox(width: 4),
                          StatusBadge(status: ticket.status),
                          const Spacer(),
                           Text(
                             dateStr,
                             style: AppTextStyles.micro,
                           ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ticket.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ticket.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 11,
                            color: ThemeColors.unifiedPrimary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ticket.createdByDeptCode,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: ThemeColors.unifiedSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ticket.assignedDeptCode,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                          if (ticket.assignedToName != null) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.person_outline_rounded,
                              size: 11,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                ticket.assignedToName!,
                                style: AppTextStyles.micro,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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

class _ActivityEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            ConstStrings.noRecentActivity,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            ConstStrings.ticketActivityWillAppear,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
