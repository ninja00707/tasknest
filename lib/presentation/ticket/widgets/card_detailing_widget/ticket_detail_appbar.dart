import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/appbar_print_button.dart';

class TicketDetailAppbar extends StatelessWidget {
  const TicketDetailAppbar({super.key, required this.ticket});
  final TicketModel ticket;
  @override
  Widget build(BuildContext context) {
    // Widget build(TicketModel ticket) {
    final priorityColor = ticketPriorityColor(ticket.priority);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemeColors.unifiedBorder,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
            ),
            child: Text(
              '#${ticket.ticketNumber.isNotEmpty ? ticket.ticketNumber : ticket.id}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ticket.title,
              style: AppTextStyles.sectionHeader,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: priorityColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: priorityColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
            ),
            child: Text(
              ticket.status.toUpperCase().replaceAll('_', ' '),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PrintButton(ticket: ticket, userName: ticket.createdByName),
        ],
      ),
    );
  }
}
