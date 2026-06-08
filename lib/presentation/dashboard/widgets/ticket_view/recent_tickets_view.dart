import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_grid_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

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
    final allTickets = [...widget.state.tickets];
    allTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final totalPages = (allTickets.length / _pageSize).ceil().clamp(1, 9999);
    if (_page > totalPages) _page = totalPages;

    final start = (_page - 1) * _pageSize;
    final end = start + _pageSize;
    final pageTickets = allTickets.sublist(start, end > allTickets.length ? allTickets.length : end);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : 2;
    final cardWidth = (screenWidth - 48 - (crossAxisCount - 1) * 12) / crossAxisCount;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Tickets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "View the most recently logged activity and tracking updates.",
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.unifiedTextMuted.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: allTickets.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent activity found.',
                          style: TextStyle(color: ThemeColors.unifiedTextMuted),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: pageTickets.map((ticket) => SizedBox(
                                width: cardWidth,
                                child: TicketGridCard(ticket: ticket),
                              )).toList(),
                            ),
                            if (totalPages > 1) ...[
                              const SizedBox(height: 16),
                              _PaginationBar(
                                page: _page,
                                totalPages: totalPages,
                                onPrev: _page > 1 ? () => setState(() => _page--) : null,
                                onNext: _page < totalPages ? () => setState(() => _page++) : null,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
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
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
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
        const SizedBox(width: 16),
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
