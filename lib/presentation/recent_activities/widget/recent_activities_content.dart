import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_bloc.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_event.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class RecentActivitiesContent extends StatelessWidget {
  const RecentActivitiesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, dashState) {
        final loaded = _tryResolve(dashState);
        if (loaded == null) {
          return const Center(
            child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
          );
        }
        return _RecentActivitiesBody(
          tickets: loaded.tickets,
          isWide: loaded.isWide,
          screenWidth: loaded.screenWidth,
        );
      },
    );
  }

  DashboardLoaded? _tryResolve(DashboardState s) {
    if (s is DashboardLoaded) return s;
    if (s is DashboardActionError) return s.previousState;
    if (s is DashboardActionSuccess) return s.previousState;
    if (s is TicketDetailLoaded) return s.previousState;
    return null;
  }
}

class _RecentActivitiesBody extends StatefulWidget {
  final List<TicketModel> tickets;
  final bool isWide;
  final double screenWidth;

  const _RecentActivitiesBody({
    required this.tickets,
    required this.isWide,
    required this.screenWidth,
  });

  @override
  State<_RecentActivitiesBody> createState() => _RecentActivitiesBodyState();
}

class _RecentActivitiesBodyState extends State<_RecentActivitiesBody> {
  List<TicketModel>? _lastTickets;

  @override
  Widget build(BuildContext context) {
    if (!identical(_lastTickets, widget.tickets)) {
      _lastTickets = widget.tickets;
      context.read<RecentActivitiesBloc>().add(
        LoadRecentActivities(
          tickets: widget.tickets,
          isWide: widget.isWide,
          screenWidth: widget.screenWidth,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        final bloc = context.read<RecentActivitiesBloc>();
        final currentState = bloc.state;
        if (currentState is RecentActivitiesLoaded &&
            (currentState.isWide != isWide ||
                currentState.screenWidth != constraints.maxWidth)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              bloc.add(UpdateRecentScreenSize(isWide, constraints.maxWidth));
            }
          });
        }

        return BlocBuilder<RecentActivitiesBloc, RecentActivitiesState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            if (state is! RecentActivitiesLoaded) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.unifiedPrimary,
                ),
              );
            }
            final isWide = state.isWide;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 28 : 16,
                0,
                isWide ? 28 : 16,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActivityHeader(total: state.allTickets.length),
                  const SizedBox(height: 20),
                  Expanded(
                    child: state.allTickets.isEmpty
                        ? const _ActivityEmptyState()
                        : ListView.builder(
                            itemCount:
                                state.pagedTickets.length +
                                (state.totalPages > 1 ? 1 : 0),
                            padding: const EdgeInsets.only(top: 4),
                            itemBuilder: (context, index) {
                              if (index < state.pagedTickets.length) {
                                return _ActivityTicketCard(
                                  ticket: state.pagedTickets[index],
                                );
                              }
                              return _ActivityPagination(
                                page: state.currentPage,
                                totalPages: state.totalPages,
                                onPrev: state.currentPage > 1
                                    ? () => context
                                          .read<RecentActivitiesBloc>()
                                          .add(
                                            RecentPageChanged(
                                              state.currentPage - 1,
                                            ),
                                          )
                                    : null,
                                onNext: state.currentPage < state.totalPages
                                    ? () => context
                                          .read<RecentActivitiesBloc>()
                                          .add(
                                            RecentPageChanged(
                                              state.currentPage + 1,
                                            ),
                                          )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Color get _tint => CommonStatus.ticketStatusColor(ticket.status);

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          Text(dateStr, style: AppTextStyles.micro),
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
                          const Icon(
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
                          const Icon(
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
                            const Icon(
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
          label: ConstStrings.previous,
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
              color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
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
          label: ConstStrings.next,
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
        ? ThemeColors.unifiedTextMuted.withValues(alpha: 0.3)
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
                ? ThemeColors.unifiedBorder.withValues(alpha: 0.5)
                : ThemeColors.unifiedPrimary.withValues(alpha: 0.3),
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
  const _ActivityEmptyState();

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
