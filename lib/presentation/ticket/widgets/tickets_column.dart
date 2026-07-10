import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_card.dart';

class KanbanColumn extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final List<TicketModel> tickets;
  final UserModel user;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.label,
    required this.color,
    required this.tickets,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.85),
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 32,
                          color: ThemeColors.unifiedTextMuted.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No tickets',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.unifiedTextMuted.withValues(
                              alpha: 0.5,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: CommonListViewBuilder<TicketModel>(
                      items: tickets,
                      itemBuilder: (context, ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TicketCard(ticket: ticket, user: user),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
