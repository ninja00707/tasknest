import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket_card_module/widget/ticket_card.dart';

class TicketTypeGridScreen extends StatelessWidget {
  final List<TicketModel> tickets;
  final String title;
  final UserModel user;

  const TicketTypeGridScreen({
    super.key,
    required this.tickets,
    required this.title,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: ThemeColors.unifiedSurface,
        surfaceTintColor: ThemeColors.unifiedSurface,
      ),
      body: tickets.isEmpty
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
                final cardWidth =
                    (constraints.maxWidth -
                        totalPadding -
                        spacing * (crossAxisCount - 1)) /
                    crossAxisCount;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: tickets
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
    );
  }
}
