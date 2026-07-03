import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

const int _pageSize = 15;

class RecentTicketsView extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel? userModel;

  const RecentTicketsView({
    super.key,
    required this.state,
    required this.userModel,
  });

  @override
  State<RecentTicketsView> createState() => _RecentTicketsViewState();
}

class _RecentTicketsViewState extends State<RecentTicketsView> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final all = [...widget.state.tickets];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final totalPages = (all.length / _pageSize).ceil().clamp(1, 9999);
    if (_page > totalPages) _page = totalPages;

    final start = (_page - 1) * _pageSize;
    final end = start + _pageSize;
    final pageTickets = all.sublist(start, end > all.length ? all.length : end);
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
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ...pageTickets.map(
                            (t) => _ActivityTicketCard(ticket: t),
                          ),
                          if (totalPages > 1) ...[
                            const SizedBox(height: 16),
                            _ActivityPagination(
                              page: _page,
                              totalPages: totalPages,
                              onPrev: _page > 1
                                  ? () => setState(() => _page--)
                                  : null,
                              onNext: _page < totalPages
                                  ? () => setState(() => _page++)
                                  : null,
                            ),
                          ],
                        ],
                      ),
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
                'Recent Activity',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$total tickets · sorted by newest first',
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeColors.unifiedTextMuted,
                ),
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

  Color get _tint {
    switch (ticket.status) {
      case 'open':
        return ThemeColors.unifiedSecondary;
      case 'in_progress':
        return ThemeColors.unifiedWarning;
      case 'completed':
        return ThemeColors.unifiedAccent;
      case 'closed':
        return ThemeColors.unifiedTextMuted;
      default:
        return ThemeColors.unifiedPrimary;
    }
  }

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: _tint.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _tint.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(_icon, size: 13, color: _tint),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ThemeColors.unifiedBorder.withOpacity(0.5),
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
                      color: ThemeColors.unifiedBorder.withOpacity(0.7),
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
                            style: const TextStyle(
                              fontSize: 10,
                              color: ThemeColors.unifiedTextMuted,
                            ),
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
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ThemeColors.unifiedTextMuted,
                                ),
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
      ),
    );
  }
}

class _ActivityPagination extends StatelessWidget {
  final int page, totalPages;
  final VoidCallback? onPrev, onNext;
  const _ActivityPagination({
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageBtn(
          icon: Icons.chevron_left,
          label: 'Previous',
          disabled: onPrev == null,
          onTap: onPrev ?? () {},
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ThemeColors.unifiedBorder.withOpacity(0.5),
            ),
          ),
          child: Text(
            'Page $page of $totalPages',
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
          label: 'Next',
          disabled: onNext == null,
          onTap: onNext ?? () {},
        ),
      ],
    );
  }
}

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
            if (icon == Icons.chevron_left) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (icon == Icons.chevron_right) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: color),
            ],
          ],
        ),
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
            color: ThemeColors.unifiedTextMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ticket activity will appear here as updates come in',
            style: TextStyle(fontSize: 12, color: ThemeColors.unifiedTextMuted),
          ),
        ],
      ),
    );
  }
}
