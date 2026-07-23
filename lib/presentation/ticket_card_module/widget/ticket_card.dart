import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_card_base.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_bloc.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_state.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final Function()? onTap;
  const TicketCard({
    super.key,
    required this.ticket,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TicketCardBloc, TicketCardState, bool>(
      selector: (state) => state.recentlyUpdatedIds.contains(ticket.id),
      builder: (context, isRecent) {
        if (!isRecent) return _buildCard(context, false);
        return BlocBuilder<TicketCardBloc, TicketCardState>(
          buildWhen: (prev, curr) => prev.pulseActive != curr.pulseActive,
          builder: (context, blocState) {
            return _buildCard(context, blocState.pulseActive);
          },
        );
      },
    );
  }

  String _buildLastUpdatedLabel(TicketModel t) {
    final name = t.lastActedByName ?? '';
    final dept = t.lastActedByDeptName;
    final action = t.lastAction ?? '';
    if (dept != null && dept.isNotEmpty) {
      return 'Last updated by $dept - $name - $action';
    }
    return 'Last updated by $name - $action';
  }

  Widget _buildCard(BuildContext context, bool pulseActive) {
    final t = ticket;
    final statusColor = CommonStatus.ticketStatusColor(t.status);
    final priorityColor = CommonStatus.ticketPriorityColor(t.priority);

    final shadowAlpha = pulseActive ? 0.18 : 0.08;
    final shadowBlur = pulseActive ? 22.0 : 16.0;
    final borderAlpha = pulseActive ? 0.35 : 0.2;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/ticket/${t.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.isOverdue
                  ? ThemeColors.unifiedDanger.withValues(alpha: 0.35)
                  : priorityColor.withValues(alpha: borderAlpha),
              width: 1.5,
            ),
            boxShadow: [
              if (pulseActive)
                BoxShadow(
                  color: statusColor.withValues(alpha: shadowAlpha),
                  blurRadius: shadowBlur,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: priorityColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IdChip(
                                label: t.ticketNumber.isNotEmpty
                                    ? t.ticketNumber
                                    : '#${t.id}',
                              ),
                              const SizedBox(width: 8),
                              if (t.isStandardTicket)
                                FlagChip(
                                  label: 'STANDARD',
                                  bg: ThemeColors.unifiedPrimary.withValues(
                                    alpha: 0.08,
                                  ),
                                  fg: ThemeColors.unifiedPrimary,
                                  icon: Icons.article_rounded,
                                )
                              else if (t.isMultiTaskTicket)
                                FlagChip(
                                  label: 'MULTI TASK',
                                  bg: const Color(0xFFEDE9FE),
                                  fg: const Color(0xFF7C3AED),
                                  icon: Icons.hub_rounded,
                                ),
                              if (t.children.isNotEmpty)
                                FlagChip(
                                  label: 'SUB',
                                  bg: const Color(0xFFFEF3C7),
                                  fg: const Color(0xFFD97706),
                                  icon: Icons.account_tree_rounded,
                                ),
                              const Spacer(),
                              PriorityBadge(priority: t.priority),
                              const SizedBox(width: 6),
                              StatusBadge(status: t.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (t.deptJourney.isNotEmpty) ...[
                            DeptJourneySection(journey: t.deptJourney),
                            const SizedBox(height: 16),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.hasParent)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.subdirectory_arrow_right_rounded,
                                        size: 13,
                                        color: ThemeColors.unifiedTextMuted
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'CHILD OF ${t.parentTicketNumber ?? "#${t.parentTicketId}"} ${t.parentTicketTitle ?? ""}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: ThemeColors.unifiedTextMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.unifiedTextPrimary,
                                  letterSpacing: -0.3,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ThemeColors.unifiedTextMuted,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (t.isSubTicket) ...[
                            SubTicketProgressSection(ticket: t, user: user),
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: ThemeColors.unifiedBorder.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ] else ...[
                            Container(
                              height: 1,
                              color: ThemeColors.unifiedBorder.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (t.children.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ChildTicketsList(children: t.children, user: user),
                          ],
                          const SizedBox(height: 12),
                          if (t.lastActedByName != null && t.lastActedByName != 'System')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: ThemeColors.unifiedSurface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ThemeColors.unifiedBorder.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 12,
                                    color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _buildLastUpdatedLabel(t),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (!t.isSubTicket) ...[
                                MetaDivider(),
                                MetaChip(
                                  icon: Icons.arrow_forward_rounded,
                                  iconColor: ThemeColors.unifiedSecondary,
                                  label: t.assignedDeptCode,
                                ),
                                if (t.assignedToName != null) ...[
                                  MetaDivider(),
                                  MetaChip(
                                    icon: Icons.person_outline_rounded,
                                    iconColor: ThemeColors.unifiedTextMuted,
                                    label: t.assignedToName!,
                                  ),
                                ],
                              ],
                              const Spacer(),
                              TicketActions(ticket: t, user: user),
                              // if (pulseActive)
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 4,
                              //       vertical: 3,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: statusColor.withValues(alpha: 0.12),
                              //       borderRadius: BorderRadius.circular(6),
                              //       border: Border.all(
                              //         color: statusColor.withValues(
                              //           alpha: 0.25,
                              //         ),
                              //         width: 1,
                              //       ),
                              //     ),
                              //     child: const Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         Icon(
                              //           Icons.bolt_rounded,
                              //           size: 11,
                              //           color: Colors.redAccent,
                              //         ),
                              //         SizedBox(width: 3),
                              //         Text(
                              //           'JUST UPDATED',
                              //           style: TextStyle(
                              //             fontSize: 8,
                              //             fontWeight: FontWeight.w800,
                              //             color: Colors.redAccent,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // if (pulseActive) const SizedBox(width: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (pulseActive) ...[
                Positioned(
                  left: 50,
                  right: 50,
                  top: 150,
                  bottom: 150,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 11,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 3),
                          CommonText(
                            'JUST UPDATED',
                            customeStyle: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (pulseActive) const SizedBox(width: 6),
              ],
              // Positioned(
              //   left: 0,
              //   top: 0,
              //   bottom: 0,
              //   child: Container(
              //     width: 4,
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           CommonStatus.ticketPriorityColor(t.priority),
              //           CommonStatus.ticketPriorityColor(
              //             t.priority,
              //           ).withValues(alpha: 0.4),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
