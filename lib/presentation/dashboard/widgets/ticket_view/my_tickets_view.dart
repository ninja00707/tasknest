import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class MyTicketsView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const MyTicketsView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    // Filter tickets assigned specifically to the logged-in user from the total state
    final myTickets = state.tickets
        .where((t) => t.assignedToId == user.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned to Me',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Detailed list of all tasks specifically assigned to you.",
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.unifiedTextMuted.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            // 7) Card shape centered layout for Web
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: myTickets.isEmpty
                    ? const Center(
                        child: Text(
                          'You currently have no assigned tickets.',
                          style: TextStyle(color: ThemeColors.unifiedTextMuted),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: myTickets.length,
                          itemBuilder: (context, index) {
                            return TicketCard(
                              ticket: myTickets[index],
                              user: user,
                            );
                          },
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
