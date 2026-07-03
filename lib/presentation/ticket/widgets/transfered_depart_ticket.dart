import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_grid_card.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

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
    final all = widget.state.sentTickets;
    final totalPages = (all.length / _pageSize).ceil().clamp(1, 9999);
    if (_page > totalPages) _page = totalPages;

    final start = (_page - 1) * _pageSize;
    final end = start + _pageSize;
    final pageTickets = all.sublist(start, end > all.length ? all.length : end);
    final isWide = MediaQuery.of(context).size.width > 900;

    final pending = all.where((t) => t.status == 'open' || t.status == 'in_progress').length;
    final completed = all.where((t) => t.status == 'completed' || t.status == 'closed').length;

    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, 0, isWide ? 28 : 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SentHeader(total: all.length, pending: pending, completed: completed),
          const SizedBox(height: 20),
          Expanded(
            child: all.isEmpty
                ? _SentEmptyState()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: pageTickets.map((t) => SizedBox(
                            width: isWide
                                ? (MediaQuery.of(context).size.width - 104) / 3
                                : (MediaQuery.of(context).size.width - 56) / 2,
                            child: TicketGridCard(ticket: t),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (totalPages > 1)
                          _SentPagination(
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

class _SentHeader extends StatelessWidget {
  final int total, pending, completed;
  const _SentHeader({required this.total, required this.pending, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sent Sub-Tickets', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                  const SizedBox(height: 2),
                  Text('$total tickets forwarded to other departments', style: const TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _MiniStat(label: 'Total Sent', count: total, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 10),
            _MiniStat(label: 'Active', count: pending, color: ThemeColors.unifiedWarning),
            const SizedBox(width: 10),
            _MiniStat(label: 'Completed', count: completed, color: ThemeColors.unifiedAccent),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class _SentPagination extends StatelessWidget {
  final int page, totalPages;
  final VoidCallback? onPrev, onNext;
  const _SentPagination({required this.page, required this.totalPages, this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageBtn(icon: Icons.chevron_left, label: 'Previous', disabled: onPrev == null, onTap: onPrev ?? () {}),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
          ),
          child: Text('Page $page of $totalPages',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextMuted)),
        ),
        const SizedBox(width: 12),
        _PageBtn(icon: Icons.chevron_right, label: 'Next', disabled: onNext == null, onTap: onNext ?? () {}),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;
  final VoidCallback onTap;
  const _PageBtn({required this.icon, required this.label, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = disabled ? ThemeColors.unifiedTextMuted.withOpacity(0.3) : ThemeColors.unifiedPrimary;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: disabled ? ThemeColors.unifiedBackground : ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: disabled ? ThemeColors.unifiedBorder.withOpacity(0.5) : ThemeColors.unifiedPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.chevron_left) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 4)],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            if (icon == Icons.chevron_right) ...[const SizedBox(width: 4), Icon(icon, size: 16, color: color)],
          ],
        ),
      ),
    );
  }
}

class _SentEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.share_outlined, size: 64, color: ThemeColors.unifiedTextMuted.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('No sub-tickets sent yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
          const SizedBox(height: 4),
          const Text('Sub-tickets created for other departments will appear here', style: TextStyle(fontSize: 12, color: ThemeColors.unifiedTextMuted)),
        ],
      ),
    );
  }
}
