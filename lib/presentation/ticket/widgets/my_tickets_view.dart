import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_grid_card.dart';

class MyTicketsView extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel user;

  const MyTicketsView({super.key, required this.state, required this.user});

  @override
  State<MyTicketsView> createState() => _MyTicketsViewState();
}

class _MyTicketsViewState extends State<MyTicketsView> {
  String _filter = 'All';

  List<TicketModel> get _myTickets => widget.state.tickets
      .where((t) => t.assignedToId == widget.user.id)
      .toList();

  List<TicketModel> get _filtered {
    if (_filter == 'All') return _myTickets;
    return _myTickets.where((t) => t.status == _filter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = _myTickets;
    int open = 0, inProgress = 0, completed = 0;
    for (final t in all) {
      if (t.status == 'open') {
        open++;
      } else if (t.status == 'in_progress') {
        inProgress++;
      } else if (t.status == 'completed') {
        completed++;
      }
    }
    final filtered = _filtered;
    final isWide = MediaQuery.of(context).size.width > 900;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              all: all,
              open: open,
              inProgress: inProgress,
              completed: completed,
            ),
            const SizedBox(height: 20),
            _FilterTabs(
              filter: _filter,
              onChanged: (v) => setState(() {
                _filter = v;
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(filter: _filter)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isWide ? 3 : 2;
                        const spacing = 12.0;
                        final cardWidth =
                            (constraints.maxWidth -
                                spacing * (crossAxisCount - 1)) /
                            crossAxisCount;
                        final rowCount =
                            ((filtered.length + crossAxisCount - 1) /
                                    crossAxisCount)
                                .floor();

                        return ListView.builder(
                          itemCount: rowCount,
                          itemBuilder: (context, rowIndex) {
                            final start = rowIndex * crossAxisCount;
                            final end = (start + crossAxisCount).clamp(
                              0,
                              filtered.length,
                            );

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: rowIndex < rowCount - 1 ? spacing : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = start; i < end; i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: i < end - 1 ? spacing : 0,
                                      ),
                                      child: SizedBox(
                                        width: cardWidth,
                                        child: TicketGridCard(
                                          ticket: filtered[i],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final List<TicketModel> all;
  final int open, inProgress, completed;
  const _Header({
    required this.all,
    required this.open,
    required this.inProgress,
    required this.completed,
  });

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
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_ind_rounded,
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
                    ConstStrings.navMyTickets,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${all.length} assigned tickets',
                    style: AppTextStyles.bodySmallMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _MiniStat(
              label: 'Open',
              count: open,
              color: ThemeColors.unifiedSecondary,
            ),
            const SizedBox(width: 10),
            _MiniStat(
              label: 'In Progress',
              count: inProgress,
              color: ThemeColors.unifiedWarning,
            ),
            const SizedBox(width: 10),
            _MiniStat(
              label: 'Completed',
              count: completed,
              color: ThemeColors.unifiedAccent,
            ),
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
  const _MiniStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onChanged;
  const _FilterTabs({required this.filter, required this.onChanged});

  static const _tabs = ['All', 'Open', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.map((t) {
          final active = filter == t;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? ThemeColors.unifiedPrimary
                      : ThemeColors.unifiedSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? ThemeColors.unifiedPrimary
                        : ThemeColors.unifiedBorder,
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No ${filter.toLowerCase()} tickets assigned to you',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            ConstStrings.newTicketsWillAppear,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
