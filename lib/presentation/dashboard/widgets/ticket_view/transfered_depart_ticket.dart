import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_grid_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

const int _pageSize = 15;

class TransferedDepartTicket extends StatefulWidget {
  const TransferedDepartTicket({
    super.key,
    required this.state,
    required this.user,
  });
  final DashboardLoaded state;
  final UserModel user;

  @override
  State<TransferedDepartTicket> createState() => _TransferedDepartTicketState();
}

class _TransferedDepartTicketState extends State<TransferedDepartTicket> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final allTickets = widget.state.sentTickets;
    final totalPages = (allTickets.length / _pageSize).ceil().clamp(1, 9999);
    if (_page > totalPages) _page = totalPages;

    final start = (_page - 1) * _pageSize;
    final end = start + _pageSize;
    final pageTickets = allTickets.sublist(start, end > allTickets.length ? allTickets.length : end);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommaonSectionHeader(
            icon: Icons.hub_outlined,
            title: 'Sub-Tickets from Your Department',
            trailing: Text(
              '${allTickets.length} tickets',
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: allTickets.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No sub-tickets created for other departments',
                        style: TextStyle(color: ThemeColors.unifiedTextMuted),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: pageTickets.map((t) {
                            final cardWidth = (screenWidth - 32 - (crossAxisCount - 1) * 12) / crossAxisCount;
                            return SizedBox(
                              width: cardWidth,
                              child: TicketGridCard(ticket: t),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (totalPages > 1)
                          _PaginationBar(
                            page: _page,
                            totalPages: totalPages,
                            onPrev: _page > 1 ? () => setState(() => _page--) : null,
                            onNext: _page < totalPages ? () => setState(() => _page++) : null,
                          ),
                      ],
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
