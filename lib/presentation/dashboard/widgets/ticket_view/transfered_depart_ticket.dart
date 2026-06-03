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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      color: ThemeColors.unifiedBackground,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommaonSectionHeader(
            icon: Icons.hub_outlined,
            title: 'Sub-Tickets from Your Department',
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
          state.sentTickets.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No sub-tickets created for other departments',
                      style: TextStyle(color: ThemeColors.unifiedTextMuted),
                    ),
                  ),
                )
              : Column(
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
