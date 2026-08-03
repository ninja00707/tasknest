import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/repositories/ticket/ticket_realtime_repository.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_bloc.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_event.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_state.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';
import 'package:tasknest/presentation/disputes/widgets/raise_dispute_dialog.dart';
import 'package:tasknest/presentation/disputes/widgets/review_dispute_dialog.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class DisputeSection extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;

  const DisputeSection({
    super.key,
    required this.ticket,
    required this.user,
  });

  @override
  State<DisputeSection> createState() => _DisputeSectionState();
}

class _DisputeSectionState extends State<DisputeSection> {
  late final DisputeBloc _bloc;
  StreamSubscription<dynamic>? _disputeSub;
  final TextEditingController _commentController = TextEditingController();
  DisputeModel? _lastRendered;

  @override
  void initState() {
    super.initState();
    _bloc = DisputeBloc(sl<TicketRepositoryImpl>());
    _bloc.add(LoadDisputeByTicket(widget.ticket.id));
    _disputeSub = TicketRealtimeRepository()
        .disputeEvents
        .listen((event) {
          final data = event.data;
          if (data is Map && data['ticketId'] == widget.ticket.id) {
            if (mounted) _bloc.add(LoadDisputeByTicket(widget.ticket.id));
          }
        });
  }

  @override
  void dispose() {
    _disputeSub?.cancel();
    _commentController.dispose();
    _bloc.close();
    super.dispose();
  }

  bool get _isParticipant =>
      widget.ticket.createdById == widget.user.id ||
      widget.ticket.assignedToId == widget.user.id ||
      widget.ticket.assignedDeptId == widget.user.departmentId;

  bool get _canReview {
    if (widget.user.roleId == 0 || widget.user.roleId == 3) return true;
    return widget.user.roleId == 1 &&
        widget.ticket.assignedDeptId == widget.user.departmentId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DisputeBloc>.value(
      value: _bloc,
      child: BlocListener<DisputeBloc, DisputeState>(
        listenWhen: (prev, curr) =>
            curr is DisputeActionSuccess || curr is DisputeActionError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is DisputeActionSuccess
                    ? state.message
                    : (state as DisputeActionError).message,
              ),
              backgroundColor: state is DisputeActionSuccess
                  ? ThemeColors.unifiedPrimary
                  : ThemeColors.unifiedDanger,
            ),
          );
        },
        child: BlocBuilder<DisputeBloc, DisputeState>(
          builder: (context, state) {
            if (state is DisputeLoading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThemeColors.unifiedPrimary,
                    ),
                  ),
                ),
              );
            }
            if (state is DisputeActionError) {
              return _ErrorRetry(
                ticketId: widget.ticket.id,
                message: state.message,
              );
            }
            if (state is DisputeLoaded) {
              _lastRendered = state.dispute;
            }
            if (state is DisputeActionInProgress && _lastRendered != null) {
              return _buildDispute(context, _lastRendered!);
            }
            if (state is DisputeLoaded) {
              final dispute = state.dispute;
              return dispute == null
                  ? _buildEmpty(context)
                  : _buildDispute(context, dispute);
            }
            return _buildEmpty(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final canRaise = _isParticipant && !widget.ticket.isDisputed;
    if (widget.ticket.isDisputed) {
      return const Text(
        ConstStrings.disputedByManagerHint,
        style: TextStyle(
          fontSize: 13,
          color: ThemeColors.unifiedTextMuted,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canRaise) ...[
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    showRaiseDisputeDialog(context, ticketId: widget.ticket.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.unifiedDanger,
                  side: const BorderSide(color: ThemeColors.unifiedDanger),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.gavel_rounded, size: 18),
                label: const Text(
                  ConstStrings.raiseDispute,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ConstStrings.disputeSectionHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ] else
          const Text(
            ConstStrings.noDisputeYet,
            style: TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildDispute(BuildContext context, DisputeModel dispute) {
    final canComment =
        !dispute.isClosedStatus &&
        (dispute.raisedById == widget.user.id ||
            _isParticipant ||
            _canReview);
    final canWithdraw =
        dispute.raisedById == widget.user.id && !dispute.isClosedStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatusBadge(status: dispute.status),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ThemeColors.unifiedBorder),
              ),
              child: Text(
                dispute.reasonLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedAccent,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${ConstStrings.disputeRaisedOn} ${_formatDate(dispute.createdAt)}',
              style: const TextStyle(
                fontSize: 11,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          dispute.description,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 14,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '${ConstStrings.raisedByLabel}: ${dispute.raisedByName}',
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            const SizedBox(width: 18),
            const Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '${ConstStrings.reviewerLabel}: ${dispute.assignedReviewerName ?? ConstStrings.noReviewerAssigned}',
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        if (dispute.resolutionNotes != null &&
            dispute.resolutionNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeColors.unifiedBorder.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ConstStrings.resolutionNotesLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dispute.resolutionNotes!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_canReview && !dispute.isClosedStatus) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dispute.status != 'under_review')
                _ReviewAction(
                  label: ConstStrings.startReview,
                  icon: Icons.visibility_rounded,
                  color: ThemeColors.unifiedSecondary,
                  onTap: () => showReviewDisputeDialog(
                    context,
                    disputeId: dispute.id,
                    action: 'under_review',
                  ),
                ),
              _ReviewAction(
                label: ConstStrings.resolve,
                icon: Icons.verified_rounded,
                color: ThemeColors.unifiedSuccess,
                onTap: () => showReviewDisputeDialog(
                  context,
                  disputeId: dispute.id,
                  action: 'resolved',
                ),
              ),
              _ReviewAction(
                label: ConstStrings.reject,
                icon: Icons.close_rounded,
                color: ThemeColors.unifiedDanger,
                onTap: () => showReviewDisputeDialog(
                  context,
                  disputeId: dispute.id,
                  action: 'rejected',
                ),
              ),
              _ReviewAction(
                label: ConstStrings.escalate,
                icon: Icons.trending_up_rounded,
                color: ThemeColors.unifiedWarning,
                onTap: () => showReviewDisputeDialog(
                  context,
                  disputeId: dispute.id,
                  action: 'escalated',
                ),
              ),
            ],
          ),
        ],
        if (canWithdraw) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _confirmWithdraw(context, dispute),
            style: TextButton.styleFrom(
              foregroundColor: ThemeColors.unifiedTextMuted,
            ),
            icon: const Icon(Icons.undo_rounded, size: 16),
            label: const Text(ConstStrings.withdraw),
          ),
        ],
        if (canComment) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: ConstStrings.writeDisputeComment,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final note = _commentController.text.trim();
                  if (note.isEmpty) return;
                  _bloc.add(
                    AddDisputeCommentEvent(disputeId: dispute.id, note: note),
                  );
                  _commentController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.unifiedPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text(ConstStrings.post),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          ConstStrings.timelineLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        if (dispute.timeline.isEmpty)
          const Text(
            ConstStrings.noHistoryRecords,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.unifiedTextMuted,
            ),
          )
        else
          ...dispute.timeline.map((activity) => _TimelineTile(
                activity: activity,
                isLast: identical(activity, dispute.timeline.last),
              )),
      ],
    );
  }

  Future<void> _confirmWithdraw(
    BuildContext context,
    DisputeModel dispute,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          ConstStrings.withdrawDisputeQuestion,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(ConstStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedDanger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(ConstStrings.withdraw),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _bloc.add(WithdrawDisputeEvent(dispute.id));
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · $h:$min $ampm';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  (Color, Color) get _colors {
    switch (status) {
      case 'open':
        return (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg);
      case 'under_review':
        return (ThemeColors.statusProgressBg, ThemeColors.statusProgressFg);
      case 'resolved':
        return (ThemeColors.statusDoneBg, ThemeColors.statusDoneFg);
      case 'rejected':
        return (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg);
      case 'escalated':
        return (ThemeColors.priorityHighBg, ThemeColors.priorityHighFg);
      case 'disputed':
        return (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg);
      default:
        return (ThemeColors.statusClosedBg, ThemeColors.statusClosedFg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        DisputeStatusLabels.labelFor(status).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}

class _ReviewAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReviewAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final DisputeActivityModel activity;
  final bool isLast;
  const _TimelineTile({required this.activity, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeColors.unifiedAccent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.circle,
                    size: 6,
                    color: ThemeColors.unifiedAccent,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.actionLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(activity.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'by ${activity.actorName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  if (activity.note != null &&
                      activity.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activity.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} · $h:$min $ampm';
  }
}

class _ErrorRetry extends StatelessWidget {
  final int ticketId;
  final String message;
  const _ErrorRetry({required this.ticketId, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: ThemeColors.unifiedDanger,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context
              .read<DisputeBloc>()
              .add(LoadDisputeByTicket(ticketId)),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
