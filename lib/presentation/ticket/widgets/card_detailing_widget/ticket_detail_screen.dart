import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_loader.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart'
    hide TicketDetailLoaded;
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
  TicketModel? _ticket;

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
    return BlocConsumer<TicketBloc, TicketState>(
      buildWhen: (prev, curr) {
        if (curr is! TicketDetailLoaded) return false;
        if (prev is! TicketDetailLoaded) return true;
        final a = prev.ticket;
        final b = curr.ticket;
        return a.id != b.id ||
            a.status != b.status ||
            a.isDisputed != b.isDisputed ||
            a.overallProgress != b.overallProgress ||
            a.lastUpdatedAt != b.lastUpdatedAt ||
            a.assignedToId != b.assignedToId ||
            a.reopenCount != b.reopenCount ||
            a.description != b.description ||
            a.children.length != b.children.length ||
            a.comments.length != b.comments.length;
      },
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
      builder: (context, state) {
        if (state is TicketDetailLoaded) {
          _ticket = state.ticket;
        }
        final ticket = state is TicketDetailLoaded ? state.ticket : _ticket;
        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          body: ticket != null ? _buildBody(ticket) : const LoadingScaffold(),
        );
      },
    );
  }

  Widget _buildBody(TicketModel ticket) {
    final bloc = context.read<DashboardBloc>();
    final loaded = bloc.state is DashboardLoaded
        ? bloc.state as DashboardLoaded
        : null;
    final screenWidth = loaded?.screenWidth ?? 1200.0;
    final isWide = loaded?.isWide ?? true;

    return Container(
      // height: 800.0,
      width: screenWidth,
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
                      ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedSurface,
                    borderRadius: isWide
                        ? BorderRadius.circular(20)
                        : BorderRadius.zero,
                    boxShadow: isWide
                        ? [
                            BoxShadow(
                              color: CommonStatus.ticketPriorityColor(
                                ticket.status,
                              ).withValues(alpha: 0.06),
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
                  clipBehavior: isWide ? Clip.hardEdge : Clip.none,
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
                          trailing: ticket.isOpen &&
                                  ticket.createdById == widget.user.id
                              ? _EditDescriptionButton(ticket: ticket)
                              : null,
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
    );
  }
}

class _EditDescriptionButton extends StatelessWidget {
  final TicketModel ticket;
  const _EditDescriptionButton({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showDialog(context),
      icon: const Icon(
        Icons.edit_outlined,
        size: 15,
        color: ThemeColors.unifiedPrimary,
      ),
      tooltip: ConstStrings.editDescription,
      iconSize: 15,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _DescriptionEditDialog(
        ticket: ticket,
        onSave: (newDescription) {
          // Dispatch after the dialog route has fully torn down so the
          // resulting rebuild never overlaps the dialog's deactivation
          // (avoids framework inherited-dependency teardown races).
          Future<void>.delayed(const Duration(milliseconds: 300), () {
            if (!context.mounted) return;
            context.read<TicketBloc>().add(
              UpdateTicketDescription(ticket.id, newDescription),
            );
          });
        },
      ),
    );
  }
}

class _DescriptionEditDialog extends StatefulWidget {
  final TicketModel ticket;
  final void Function(String newDescription) onSave;
  const _DescriptionEditDialog({
    required this.ticket,
    required this.onSave,
  });

  @override
  State<_DescriptionEditDialog> createState() => _DescriptionEditDialogState();
}

class _DescriptionEditDialogState extends State<_DescriptionEditDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.ticket.description);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final newDescription = _controller.text.trim();
    Navigator.pop(context);
    if (newDescription != widget.ticket.description) {
      widget.onSave(newDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 20,
            color: ThemeColors.unifiedPrimary,
          ),
          SizedBox(width: 10),
          Text(
            ConstStrings.editDescription,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: ConstStrings.description,
              hintText: ConstStrings.enterTaskDescription,
              helperText: ConstStrings.editDescriptionHint,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? ConstStrings.descriptionRequired
                : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(ConstStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.unifiedPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text(ConstStrings.save),
        ),
      ],
    );
  }
}
