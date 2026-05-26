import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TransferedDepartTicket extends StatelessWidget {
  const TransferedDepartTicket({
    super.key,
    required this.state,
    required this.user,
  });
  final DashboardLoaded state;
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    // If no tickets are available, we return an empty widget to save space
    if (state.sentTickets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommaonSectionHeader(
            icon: Icons.sync_alt_rounded,
            title: 'Transferred From Your Department',
            trailing: Text(
              '${state.sentTickets.length} tickets',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: state.sentTickets
                .take(5)
                .map((t) => TicketCard(ticket: t, user: user))
                .toList(),
          ),
        ],
      ),
    );
  }
}
