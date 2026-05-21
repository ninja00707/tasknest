import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;

  const TicketCard({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(ticket.priority);
    final isTransferred = ticket.transferredFromCode != null;

    return GestureDetector(
      onTap: () => context.push('/ticket/${ticket.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ticket.isOverdue
                ? ThemeColors.unifiedDanger.withOpacity(0.35)
                : ThemeColors.unifiedBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left priority stripe ──────────────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withOpacity(0.4)],
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Row 1: ID + flags + badges ───────────────────
                      Row(
                        children: [
                          _IdChip(id: ticket.id),
                          const SizedBox(width: 6),
                          if (ticket.isOverdue) const _FlagChip(
                            label: 'OVERDUE',
                            bg: Color(0xFFFEE2E2),
                            fg: ThemeColors.unifiedDanger,
                            icon: Icons.schedule_rounded,
                          ),
                          if (isTransferred) ...[
                            const SizedBox(width: 4),
                            _FlagChip(
                              label: 'FROM ${ticket.transferredFromCode}',
                              bg: ThemeColors.unifiedWarning.withOpacity(0.12),
                              fg: ThemeColors.unifiedWarning,
                              icon: Icons.sync_alt_rounded,
                            ),
                          ],
                          const Spacer(),
                          PriorityBadge(priority: ticket.priority),
                          const SizedBox(width: 6),
                          StatusBadge(status: ticket.status),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Row 2: Title ─────────────────────────────────
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ── Row 3: Description ───────────────────────────
                      Text(
                        ticket.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // ── Divider ──────────────────────────────────────
                      Container(
                        height: 1,
                        color: ThemeColors.unifiedBorder.withOpacity(0.6),
                      ),

                      const SizedBox(height: 10),

                      // ── Row 4: Meta row ──────────────────────────────
                      Row(
                        children: [
                          // From dept
                          _MetaChip(
                            icon: Icons.arrow_upward_rounded,
                            iconColor: ThemeColors.unifiedPrimary,
                            label: ticket.createdByDeptCode,
                          ),
                          _MetaDivider(),
                          // To dept
                          _MetaChip(
                            icon: Icons.arrow_forward_rounded,
                            iconColor: ThemeColors.unifiedSecondary,
                            label: ticket.assignedDeptCode,
                          ),
                          if (ticket.assignedToName != null) ...[
                            _MetaDivider(),
                            _MetaChip(
                              icon: Icons.person_outline_rounded,
                              iconColor: ThemeColors.unifiedTextMuted,
                              label: ticket.assignedToName!,
                            ),
                          ],
                          const Spacer(),
                          TicketActions(ticket: ticket, user: user),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── #ID Chip ──────────────────────────────────────────────────────────────────
class _IdChip extends StatelessWidget {
  final int id;
  const _IdChip({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Text(
        '#$id',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedTextMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Flag Chip (OVERDUE / TRANSFERRED) ────────────────────────────────────────
class _FlagChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData icon;

  const _FlagChip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta chip (dept / assignee) ───────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
      ],
    );
  }
}

// ── Meta divider dot ──────────────────────────────────────────────────────────
class _MetaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Priority color helper ─────────────────────────────────────────────────────
Color _priorityColor(String p) {
  switch (p) {
    case 'urgent': return ThemeColors.unifiedDanger;
    case 'high':   return const Color(0xFFEA580C);
    case 'medium': return ThemeColors.unifiedWarning;
    default:       return ThemeColors.unifiedPrimary;
  }
}