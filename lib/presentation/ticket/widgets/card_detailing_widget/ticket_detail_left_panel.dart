import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_history_timeline.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_child_card.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_table.dart';

class LeftColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const LeftColumn({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsCard(ticket: ticket),

        //Sub Tckets Section
        if (ticket.children.isNotEmpty) ...[
          const SizedBox(height: 16),
          CommonSectionCardContainer(
            icon: Icons.account_tree_outlined,
            title: 'Sub Tickets (${ticket.children.length})',
            child: Column(
              children: ticket.children
                  .map((child) => ChildDetailCard(child: child))
                  .toList(),
            ),
          ),
        ],
        //history timeline Section
        if (ticket.history != null &&
            ticket.history!.isNotEmpty &&
            !ticket.isSubTicket) ...[
          const SizedBox(height: 16),
          CommonSectionCardContainer(
            icon: Icons.history_rounded,
            title: ConstStrings.history,
            child: TicketHistoryTimeline(history: ticket.history!),
          ),
        ],
      ],
    );
  }
}
