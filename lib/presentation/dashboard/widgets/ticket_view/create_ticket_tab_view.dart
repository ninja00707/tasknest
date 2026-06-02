import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/create_sub_ticket.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/create_ticket.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class CreateTicketTabView extends StatelessWidget {
  final UserModel user;
  const CreateTicketTabView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isManager = user.roleId == 1;

    if (!isManager) {
      return CreateTicketView(user: user);
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: const TabBar(
              labelColor: ThemeColors.unifiedPrimary,
              unselectedLabelColor: ThemeColors.unifiedTextMuted,
              indicatorColor: ThemeColors.unifiedPrimary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: 'Standard Ticket'),
                Tab(text: 'Sub-Ticket'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                CreateTicketView(user: user),
                CreateSubTicketView(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
