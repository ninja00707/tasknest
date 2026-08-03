import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_comment_section.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_progress_timeline.dart';

class RightColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const RightColumn({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!ticket.isDisputed)
          CommonSectionCardContainer(
            icon: Icons.bolt_rounded,
            title: ConstStrings.actions,
            child: Center(
              child: TicketActions(ticket: ticket, user: user),
            ),
          ),
        if (!ticket.isDisputed) const SizedBox(height: 16),
        CommonSectionCardContainer(
          icon: Icons.timeline_rounded,
          title: ConstStrings.progress,
          child: ProgressTimeline(status: ticket.status),
        ),
        const SizedBox(height: 16),
        CommentSection(ticket: ticket, user: user),
      ],
    );
  }
}
