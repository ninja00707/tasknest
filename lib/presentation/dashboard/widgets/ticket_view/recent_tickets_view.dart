import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class RecentTicketsView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel? userModel;

  const RecentTicketsView({
    super.key,
    required this.state,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    // Create a copy and sort by date to ensure the most recent are at the top
    final recentTickets = [...state.tickets];
    recentTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Extract the top 15 most recent tickets
    final displayTickets = recentTickets.take(15).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Tickets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "View the most recently logged activity and tracking updates.",
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
                child: displayTickets.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent activity found.',
                          style: TextStyle(color: ThemeColors.unifiedTextMuted),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = displayTickets[index];
                          return TicketCard(
                            ticket: ticket,
                            user: userModel!,
                            onTap: () => context.push(
                              RouteNames.ticketDetail.replaceAll(
                                ':id',
                                ticket.id.toString(),
                              ),
                            ),
                          );
                          //  Container(
                          //   margin: const EdgeInsets.only(bottom: 12),
                          //   decoration: BoxDecoration(
                          //     color: ThemeColors.unifiedSurface,
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(
                          //       color: ThemeColors.unifiedBorder,
                          //     ),
                          //   ),
                          //   child: ListTile(
                          //     title: Text(
                          //       ticket.title,
                          //       style: const TextStyle(
                          //         fontWeight: FontWeight.w700,
                          //       ),
                          //     ),
                          //     subtitle: Text(
                          //       ticket.description,
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //     trailing: const Icon(
                          //       Icons.arrow_forward_ios,
                          //       size: 14,
                          //     ),
                          //     onTap: () => context.push(
                          //       RouteNames.ticketDetail.replaceAll(
                          //         ':id',
                          //         ticket.id.toString(),
                          //       ),
                          //     ),
                          //   ),
                          // );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
    //           )
    //         )
    //       : ListView.builder(
    //           itemCount: displayTickets.length,
    //           itemBuilder: (context, index) {
    //             final ticket = displayTickets[index];
    //             return Container(
    //               margin: const EdgeInsets.only(bottom: 12),
    //               decoration: BoxDecoration(
    //                 color: ThemeColors.unifiedSurface,
    //                 borderRadius: BorderRadius.circular(12),
    //                 border: Border.all(color: ThemeColors.unifiedBorder),
    //               ),
    //               child: ListTile(
    //                 title: Text(
    //                   ticket.title,
    //                   style: const TextStyle(fontWeight: FontWeight.w700),
    //                 ),
    //                 subtitle: Text(
    //                   ticket.description,
    //                   maxLines: 1,
    //                   overflow: TextOverflow.ellipsis,
    //                 ),
    //                 trailing: const Icon(
    //                   Icons.arrow_forward_ios,
    //                   size: 14,
    //                 ),
    //                 onTap: () => context.push(
    //                   RouteNames.ticketDetail.replaceAll(
    //                     ':id',
    //                     ticket.id.toString(),
    //                   ),
    //                 ),
    //               ),
    //             );
    //           },
    //         ),
    // ),

    //     ],
    //   ),
    // );
  }
}
