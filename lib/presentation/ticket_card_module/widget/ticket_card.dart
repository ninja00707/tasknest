import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/common_baged.dart';
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

    final shadowAlpha = pulseActive ? 0.18 : 0.06;
    final shadowBlur = pulseActive ? 20.0 : 12.0;
    final borderAlpha = pulseActive ? 0.35 : 0.18;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/ticket/${t.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: t.isOverdue
                  ? ThemeColors.unifiedDanger.withValues(alpha: 0.35)
                  : priorityColor.withValues(alpha: borderAlpha),
              width: 2,
            ),
            boxShadow: [
              if (pulseActive)
                BoxShadow(
                  color: statusColor.withValues(alpha: shadowAlpha),
                  blurRadius: shadowBlur,
                  offset: const Offset(0, 3),
                ),
              BoxShadow(
                color: priorityColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Priority accent bar (left edge)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: priorityColor),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: id + flags (wrap) ── priority + status ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IdChip(
                                label: t.ticketNumber.isNotEmpty
                                    ? t.ticketNumber
                                    : '#${t.id}',
                              ),
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
                              if (t.isDisputed)
                                FlagChip(
                                  label: 'DISPUTED',
                                  bg: const Color(0xFFFEE2E2),
                                  fg: const Color(0xFFDC2626),
                                  icon: Icons.gavel_rounded,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        PriorityBadge(priority: t.priority),
                        const SizedBox(width: 6),
                        StatusBadge(status: t.status),
                      ],
                    ),

                    if (t.deptJourney.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DeptJourneySection(journey: t.deptJourney),
                    ],

                    const SizedBox(height: 10),

                    // ── Title / description ──
                    if (t.hasParent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right_rounded,
                              size: 12,
                              color: ThemeColors.unifiedTextMuted.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'CHILD OF ${t.parentTicketNumber ?? "#${t.parentTicketId}"} ${t.parentTicketTitle ?? ""}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.unifiedTextMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      t.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: ThemeColors.unifiedTextMuted,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    if (t.isSubTicket) ...[
                      SubTicketProgressSection(ticket: t, user: user),
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      Container(
                        height: 1,
                        color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (t.children.isNotEmpty) ...[
                      ChildTicketsList(children: t.children, user: user),
                      const SizedBox(height: 8),
                    ],

                    if (t.lastActedByName != null &&
                        t.lastActedByName != 'System') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSurface.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: ThemeColors.unifiedBorder.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 11,
                              color: ThemeColors.unifiedTextMuted.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _buildLastUpdatedLabel(t),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: ThemeColors.unifiedTextMuted
                                      .withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Footer: dept/assignee meta ── actions ──
                    Row(
                      children: [
                        if (!t.isSubTicket)
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                MetaChip(
                                  icon: Icons.arrow_forward_rounded,
                                  iconColor: ThemeColors.unifiedSecondary,
                                  label: t.assignedDeptCode,
                                ),
                                if (t.assignedToName != null)
                                  MetaChip(
                                    icon: Icons.person_outline_rounded,
                                    iconColor: ThemeColors.unifiedTextMuted,
                                    label: t.assignedToName!,
                                  ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),
                        TicketActions(ticket: t, user: user),
                      ],
                    ),
                  ],
                ),
              ),

              // ── "Just updated" corner ribbon (fixed, non-overlapping) ──
              if (pulseActive)
                Positioned(
                  top: 70,
                  right: 18,
                  child: CommonBadge(
                    label: 'Just Updated',
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
