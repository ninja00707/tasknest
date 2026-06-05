import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketListView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const TicketListView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ThemeColors.unifiedSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((s) {
                      final active =
                          (s.name == 'All' && state.filterStatus == null) ||
                          s.name == state.filterStatus;

                      return GestureDetector(
                        onTap: () {
                          context.read<DashboardBloc>().add(
                            FilterTickets(
                              status: s.name == 'All' ? null : s.name,
                              priority: state.filterPriority,
                            ),
                          );
                        },

                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      ThemeColors.unifiedGradStart,
                                      ThemeColors.unifiedGradEnd,
                                    ],
                                  )
                                : null,
                            color: active
                                ? null
                                : ThemeColors.unifiedBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : ThemeColors.unifiedBorder,
                            ),
                          ),
                          child: Text(
                            s.name == 'All'
                                ? 'ALL'
                                : s.name.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : ThemeColors.unifiedTextMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No tickets found.',
                    style: TextStyle(color: ThemeColors.unifiedTextMuted),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : constraints.maxWidth > 700
                            ? 2
                            : 1;
                    final spacing = 14.0;
                    final totalPadding = 32.0;
                    final cardWidth = (constraints.maxWidth -
                            totalPadding -
                            spacing * (crossAxisCount - 1)) /
                        crossAxisCount;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: state.tickets
                            .map(
                              (t) => SizedBox(
                                width: cardWidth,
                                child: TicketCard(ticket: t, user: user),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
