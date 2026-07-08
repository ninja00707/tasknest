import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/core/theme/common_loader.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_appbar.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_header.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_left_panel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_right_panel.dart';
import 'package:tasknest/presentation/ticket/widgets/sub_ticket_detail_section.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  final UserModel user;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.user,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late final TicketBloc _ticketBloc;

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    _ticketBloc.add(LoadTicketDetail(widget.ticketId));
  }

  @override
  void dispose() {
    _ticketBloc.add(ClearTicketDetail());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ThemeColors.unifiedPrimary,
            ),
          );
        } else if (state is TicketActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ThemeColors.unifiedDanger,
            ),
          );
        }
      },
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketDetailLoaded) {
            return _buildScaffold(state.ticket);
          }
          return const LoadingScaffold();
        },
      ),
    );
  }

  Widget _buildScaffold(TicketModel ticket) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > 1000;
    final priorityColor = ticketPriorityColor(ticket.priority);

    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: ThemeColors.unifiedBackground,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TicketDetailAppbar(ticket: ticket),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 1750 : double.infinity,
                  ),
                  child: Container(
                    margin: isWide
                        ? const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          )
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedSurface,
                      borderRadius: isWide
                          ? BorderRadius.circular(20)
                          : BorderRadius.zero,
                      boxShadow: isWide
                          ? [
                              BoxShadow(
                                color: priorityColor.withValues(alpha: 0.06),
                                blurRadius: 40,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    clipBehavior: isWide ? Clip.antiAlias : Clip.none,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 16,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TicketDetailHeader(ticket: ticket),
                          const SizedBox(height: 20),
                          CommonSectionCardContainer(
                            icon: Icons.article_outlined,
                            title: ConstStrings.description,
                            child: CommonText(
                              ticket.description,
                              customeStyle: const TextStyle(
                                fontSize: 14,
                                color: ThemeColors.unifiedTextPrimary,
                                height: 1.7,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          if (ticket.isSubTicket) ...[
                            const SizedBox(height: 24),
                            SubTicketDetailSection(
                              ticket: ticket,
                              user: widget.user,
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: LeftColumn(
                                  ticket: ticket,
                                  user: widget.user,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 1,
                                child: RightColumn(
                                  ticket: ticket,
                                  user: widget.user,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
