import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_history_timeline.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/appbar_print_button.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/common_baged.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_comment_section.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_child_card.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_table_raw.dart';
import 'package:tasknest/presentation/ticket/widgets/sub_ticket_detail_section.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';

/// Trello-style card popup for the project module.
///
/// Opens the full ticket detail inside a dialog (instead of navigating to the
/// standalone [TicketDetailScreen]) and clears the loaded detail afterwards.
Future<void> showProjectTicketDetailDialog(
  BuildContext context, {
  required int ticketId,
  required UserModel user,
}) async {
  final bloc = context.read<TicketBloc>();
  bloc.add(LoadTicketDetail(ticketId));
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => ProjectTicketDetailDialog(ticketId: ticketId, user: user),
  );
  bloc.add(ClearTicketDetail());
}

String _statusName(String status) {
  switch (status) {
    case 'open':
      return 'Open';
    case 'in_progress':
      return 'In Progress';
    default:
      return 'Closed';
  }
}

class ProjectTicketDetailDialog extends StatefulWidget {
  final int ticketId;
  final UserModel user;

  const ProjectTicketDetailDialog({
    super.key,
    required this.ticketId,
    required this.user,
  });

  @override
  State<ProjectTicketDetailDialog> createState() =>
      _ProjectTicketDetailDialogState();
}

class _ProjectTicketDetailDialogState extends State<ProjectTicketDetailDialog> {
  TicketModel? _ticket;
  String? _loadError;

  void _retry() {
    setState(() => _loadError = null);
    context.read<TicketBloc>().add(LoadTicketDetail(widget.ticketId));
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: ThemeColors.unifiedBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1120, maxHeight: maxHeight),
        child: BlocConsumer<TicketBloc, TicketState>(
          listenWhen: (prev, curr) =>
              curr is TicketActionSuccess || curr is TicketActionError,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state is TicketActionSuccess) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ThemeColors.unifiedPrimary,
                ),
              );
            } else if (state is TicketActionError) {
              if (_ticket != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ThemeColors.unifiedDanger,
                  ),
                );
              } else if (mounted) {
                setState(() => _loadError = state.message);
              }
            }
          },
          buildWhen: (prev, curr) =>
              curr is TicketDetailLoaded ||
              prev is TicketDetailLoaded ||
              curr is TicketActionError ||
              prev is TicketActionError,
          builder: (context, state) {
            if (state is TicketDetailLoaded) {
              _ticket = state.ticket;
              _loadError = null;
            }
            final ticket = _ticket;
            if (ticket == null) {
              return Column(
                children: [
                  const _CoverBand(ticket: null, user: null),
                  Expanded(
                    child: _loadError == null
                        ? const Center(child: CircularProgressIndicator())
                        : _LoadErrorPanel(message: _loadError!, onRetry: _retry),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _CoverBand(ticket: ticket, user: widget.user),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 62,
                        child: _LeftPane(ticket: ticket, user: widget.user),
                      ),
                      Container(
                        width: 1,
                        color: ThemeColors.unifiedBorder.withValues(alpha: 0.6),
                      ),
                      Expanded(
                        flex: 38,
                        child: _RightPane(ticket: ticket, user: widget.user),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LoadErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedDanger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 26,
                color: ThemeColors.unifiedDanger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You may not have access to this task, or it may no longer exist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeColors.unifiedTextPrimary,
                    side: const BorderSide(color: ThemeColors.unifiedBorder),
                  ),
                  child: const Text('Try again'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top cover band ────────────────────────────────────────────────────────────
class _CoverBand extends StatelessWidget {
  final TicketModel? ticket;
  final UserModel? user;
  const _CoverBand({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = ticket;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          if (t == null)
            const Text('Loading task…', style: AppTextStyles.bodySmallMuted)
          else ...[
            _StatusChip(ticket: t),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'in ${_statusName(t.status)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          if (t != null && user != null) ...[
            PrintButton(ticket: t, userName: t.createdByName),
            const SizedBox(width: 8),
            _OverflowMenu(ticket: t, user: user!),
            const SizedBox(width: 8),
          ],
          _RoundIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            filled: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Status pill acting as the "list" chip — also lets you change status.
class _StatusChip extends StatelessWidget {
  final TicketModel ticket;
  const _StatusChip({required this.ticket});

  String get _label =>
      ticket.status.toUpperCase().replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    final color = CommonStatus.ticketStatusColor(ticket.status);
    return PopupMenuButton<String>(
      tooltip: 'Change status',
      onSelected: (value) => _changeStatus(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'open', child: Text('Move to Open')),
        PopupMenuItem(value: 'in_progress', child: Text('Move to In Progress')),
        PopupMenuItem(value: 'closed', child: Text('Move to Closed')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 7),
            Text(
              _label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _changeStatus(BuildContext context, String target) {
    if (target == ticket.status) return;
    final bloc = context.read<TicketBloc>();
    if (target != 'closed') {
      bloc.add(UpdateTicketStatus(ticket.id, target));
      return;
    }
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add remark before close'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Summary of the work done…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ConstStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              final remark = controller.text.trim();
              if (remark.isEmpty) return;
              Navigator.pop(dialogContext);
              bloc.add(UpdateTicketStatus(ticket.id, 'closed', remark: remark));
            },
            child: const Text(ConstStrings.submit),
          ),
        ],
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _OverflowMenu({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return _RoundIconButton(
      icon: Icons.more_horiz_rounded,
      tooltip: 'More options',
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: ThemeColors.unifiedSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit task'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditor(context, ticket, user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Reload task'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<TicketBloc>().add(
                        LoadTicketDetail(ticket.id, silent: true),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Close'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, TicketModel t, UserModel u) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditTaskDialog(ticket: t, user: u),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ThemeColors.unifiedTextPrimary : ThemeColors.unifiedBackground,
            shape: BoxShape.circle,
            border: Border.all(color: ThemeColors.unifiedBorder),
          ),
          child: Icon(
            icon,
            size: 17,
            color: filled ? ThemeColors.unifiedSurface : ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Left pane ─────────────────────────────────────────────────────────────────
class _LeftPane extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _LeftPane({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleRow(
              ticket: ticket,
              onEdit: () => _openEditor(context),
            ),
            const SizedBox(height: 14),
            _BadgeRow(ticket: ticket),
            const SizedBox(height: 18),
            _SectionLabel('Actions', icon: Icons.bolt_rounded),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TicketActions(ticket: ticket, user: user),
            ),
            const SizedBox(height: 20),
            CommonSectionCardContainer(
              icon: Icons.article_outlined,
              title: ConstStrings.description,
              trailing: _SectionEditButton(onEdit: () => _openEditor(context)),
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
            const SizedBox(height: 16),
            _ProjectDetailsCard(ticket: ticket),
            if (ticket.isSubTicket) ...[
              const SizedBox(height: 16),
              SubTicketDetailSection(ticket: ticket, user: user),
            ],
            if (ticket.children.isNotEmpty) ...[
              const SizedBox(height: 16),
              CommonSectionCardContainer(
                icon: Icons.account_tree_outlined,
                title: 'Sub-tickets (${ticket.children.length})',
                child: Column(
                  children: [
                    for (final child in ticket.children) ...[
                      ChildDetailCard(child: child),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _ProgressCard(ticket: ticket),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditTaskDialog(ticket: ticket, user: user),
    );
  }
}

/// Project tasks only surface the creator, the department that owns the task
/// and the person responsible for it.
class _ProjectDetailsCard extends StatelessWidget {
  final TicketModel ticket;
  const _ProjectDetailsCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = ticket;

    final department = t.assignedDeptName.isNotEmpty
        ? t.assignedDeptName
        : (t.assignedDeptCode.isNotEmpty ? t.assignedDeptCode : '—');

    final creator = t.createdByName.isNotEmpty ? t.createdByName : '—';

    final String assignee;
    if (t.myAssignedToName != null && t.myAssignedToName!.isNotEmpty) {
      assignee = t.myAssignedToName!;
    } else if (t.assignedToName != null && t.assignedToName!.isNotEmpty) {
      assignee = t.assignedToName!;
    } else {
      assignee = ConstStrings.unassigned;
    }

    return CommonSectionCardContainer(
      icon: Icons.info_outline_rounded,
      title: 'Details',
      child: Column(
        children: [
          DetailRow(label: 'Created by', value: creator),
          DetailRow(label: 'Assigned department', value: department),
          DetailRow(
            label: 'Responsible person',
            value: assignee,
            isLast: true,
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InitialsAvatar(name: assignee, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    assignee,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onEdit;
  const _TitleRow({required this.ticket, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final statusColor = CommonStatus.ticketStatusColor(ticket.status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: ticket.isClosed
                ? Icon(Icons.check_rounded, size: 14, color: statusColor)
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 10),
          _RoundIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit task',
            onTap: onEdit!,
          ),
        ],
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final TicketModel ticket;
  const _BadgeRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CommonBadge(
          label: ticket.isMultiTaskTicket
              ? ConstStrings.multiTaskLabel
              : ticket.isSubTicket
                  ? ConstStrings.subTicketLabel
                  : ConstStrings.standardLabel,
          color: ThemeColors.navyAccentLight,
        ),
        CommonBadge(
          label: ticket.priority,
          color: CommonStatus.ticketPriorityColor(ticket.priority),
        ),
        if (ticket.isDisputed)
          CommonBadge(
            label: ConstStrings.disputed,
            color: ThemeColors.unifiedDanger,
          ),
        _MetaChip(
          icon: Icons.person_outline_rounded,
          label: ticket.assignedToName ?? ConstStrings.unassigned,
        ),
        if (ticket.dueDate != null)
          _MetaChip(
            icon: Icons.schedule_rounded,
            label: CommonDateFormat.formatDate(ticket.dueDate!),
            danger: ticket.dueDate!.isBefore(DateTime.now()) && !ticket.isClosed,
          ),
        if (ticket.ticketNumber.isNotEmpty)
          _MetaChip(icon: Icons.tag_rounded, label: ticket.ticketNumber),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? ThemeColors.unifiedDanger
        : ThemeColors.unifiedTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: danger ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final TicketModel ticket;
  const _ProgressCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final raw = ticket.status == 'closed'
        ? 100
        : ticket.overallProgress.clamp(0, 100);
    final progress = raw / 100.0;
    final color = CommonStatus.ticketStatusColor(ticket.status);

    return CommonSectionCardContainer(
      icon: Icons.percent_rounded,
      title: 'Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$raw%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                raw == 100 ? 'Completed' : 'In progress',
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionLabel(this.text, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: ThemeColors.unifiedTextMuted),
        const SizedBox(width: 7),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
      ],
    );
  }
}

// ── Right pane: comments and activity ─────────────────────────────────────────
class _RightPane extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;
  const _RightPane({required this.ticket, required this.user});

  @override
  State<_RightPane> createState() => _RightPaneState();
}

class _RightPaneState extends State<_RightPane> {
  final _controller = TextEditingController();
  bool _showDetails = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canComment {
    final t = widget.ticket;
    if (t.isClosed) return false;
    if (t.canComment) return true;
    final uid = widget.user.id;
    if (uid == t.createdById) return true;
    if (t.myAssignedToId != null && uid == t.myAssignedToId) return true;
    if (t.assignedToId != null && uid == t.assignedToId) return true;
    if (t.subDepartments.any((sd) => sd.assignedToId == uid)) return true;
    if (t.assignedDeptId != null && t.assignedDeptId == widget.user.departmentId) {
      return true;
    }
    return false;
  }

  void _submit() {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;
    context.read<TicketBloc>().add(AddTicketComment(widget.ticket.id, msg));
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added!'),
        backgroundColor: ThemeColors.unifiedPrimary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.ticket.comments;
    final history = widget.ticket.history ?? const [];

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.forum_outlined,
                  size: 16,
                  color: ThemeColors.unifiedTextPrimary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Comments and activity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ThemeColors.unifiedBorder),
                    foregroundColor: ThemeColors.unifiedTextPrimary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(_showDetails ? 'Hide details' : 'Show details'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: _canComment
                    ? ThemeColors.unifiedSurface
                    : ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.unifiedBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    enabled: _canComment,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _canComment
                          ? 'Write a comment…'
                          : ConstStrings.commentsClosed,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  Container(height: 1, color: ThemeColors.unifiedBorder),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          ConstStrings.commentsCount(comments.length),
                          style: AppTextStyles.micro,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _canComment ? _submit : null,
                          icon: const Icon(Icons.send_rounded, size: 14),
                          label: const Text(ConstStrings.post),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.unifiedPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.ticket.isClosed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInfo.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ThemeColors.unifiedInfo.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: ThemeColors.unifiedInfo,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ConstStrings.commentsClosedForTicket,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedInfo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (comments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  ConstStrings.noCommentsYet,
                  style: AppTextStyles.bodySmallMuted,
                ),
              )
            else
              for (final comment in comments)
                CommentTile(comment: comment),
            if (_showDetails) ...[
              const SizedBox(height: 20),
              CommonSectionCardContainer(
                icon: Icons.history_rounded,
                title: ConstStrings.history,
                child: TicketHistoryTimeline(history: history),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Task editing ──────────────────────────────────────────────────────────────
class _SectionEditButton extends StatelessWidget {
  final VoidCallback onEdit;
  const _SectionEditButton({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onEdit,
      icon: const Icon(
        Icons.edit_outlined,
        size: 14,
        color: ThemeColors.unifiedPrimary,
      ),
      label: const Text(
        'Edit',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedPrimary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// One dialog to edit a project task: title, description, priority, due date
/// and (for managers / CEO) the member responsible for it.
class _EditTaskDialog extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;
  const _EditTaskDialog({required this.ticket, required this.user});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  static const List<String> _priorities = ['low', 'medium', 'high', 'urgent'];

  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _priority;
  DateTime? _dueDate;
  int? _assigneeId;
  List<EmployeeModel> _employees = [];
  bool _loadingEmployees = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TicketModel get ticket => widget.ticket;
  UserModel get user => widget.user;

  /// Backend only lets the creator touch the description while it is open.
  bool get _canEditDescription =>
      ticket.isOpen && ticket.createdById == user.id;

  /// `PATCH /tickets/:id/assign` is manager / CEO only.
  bool get _canAssign => user.roleId == 0 || user.roleId == 1;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: ticket.title);
    _description = TextEditingController(text: ticket.description);
    _priority = _priorities.contains(ticket.priority)
        ? ticket.priority
        : 'medium';
    _dueDate = ticket.dueDate;
    _assigneeId = ticket.assignedToId;
    if (_canAssign) _loadEmployees();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    final repo = sl<TicketRepositoryImpl>();
    var list = <EmployeeModel>[];
    try {
      list = await repo.getEmployees(departmentId: ticket.assignedDeptId);
      if (list.isEmpty) list = await repo.getEmployees();
      if (_assigneeId != null && !list.any((e) => e.id == _assigneeId)) {
        final all = await repo.getEmployees();
        if (all.any((e) => e.id == _assigneeId)) list = all;
      }
    } catch (_) {
      list = <EmployeeModel>[];
    }
    if (!mounted) return;
    setState(() {
      _employees = list;
      _loadingEmployees = false;
    });
  }

  String _dateLabel(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _dateIso(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) =>
          Theme(data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: ThemeColors.unifiedPrimary)), child: child!),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fields = <String, dynamic>{};
    final newTitle = _title.text.trim();
    final newDescription = _description.text.trim();

    if (newTitle != ticket.title) fields['title'] = newTitle;
    if (_priority != ticket.priority) fields['priority'] = _priority;
    if (_dueDate != ticket.dueDate) {
      fields['due_date'] = _dueDate == null ? null : _dateIso(_dueDate!);
    }
    if (_canEditDescription && newDescription != ticket.description) {
      fields['description'] = newDescription;
    }

    final assignChanged =
        _canAssign && _assigneeId != null && _assigneeId != ticket.assignedToId;

    if (fields.isEmpty && !assignChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      Navigator.pop(context);
      return;
    }

    final bloc = context.read<TicketBloc>();
    if (fields.isNotEmpty) {
      bloc.add(UpdateTicketDetails(ticket.id, fields));
    }
    if (assignChanged) {
      bloc.add(AssignTicketToEmployee(ticket.id, _assigneeId!));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: ThemeColors.unifiedTextPrimary,
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, size: 21, color: ThemeColors.unifiedPrimary),
          SizedBox(width: 10),
          Text(
            'Edit task',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 470,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'What needs to be done?',
                  ),
                  style: titleStyle,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  enabled: _canEditDescription,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the task in detail',
                    helperText: _canEditDescription
                        ? null
                        : 'Only the creator can edit the description while the task is open.',
                    helperMaxLines: 2,
                  ),
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _priority,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: [
                          for (final p in _priorities)
                            DropdownMenuItem(
                              value: p,
                              child: Text(
                                p[0].toUpperCase() + p.substring(1),
                                style: titleStyle,
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _priority),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _pickDueDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Due date',
                            suffixIcon: _dueDate == null
                                ? const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 17,
                                    color: ThemeColors.unifiedTextMuted,
                                  )
                                : IconButton(
                                    tooltip: 'Clear due date',
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 17,
                                      color: ThemeColors.unifiedTextMuted,
                                    ),
                                    onPressed: () =>
                                        setState(() => _dueDate = null),
                                  ),
                          ),
                          child: Text(
                            _dueDate == null
                                ? 'No due date'
                                : _dateLabel(_dueDate!),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _dueDate == null
                                  ? ThemeColors.unifiedTextMuted
                                  : ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_canAssign) ...[
                  const SizedBox(height: 14),
                  if (_loadingEmployees)
                    const Row(
                      children: [
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ThemeColors.unifiedPrimary,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Loading members…',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ],
                    )
                  else
                    DropdownButtonFormField<int?>(
                      initialValue: _employees.any((e) => e.id == _assigneeId)
                          ? _assigneeId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Responsible person (member)',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                      hint: const Text(
                        'Select a member',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      items: [
                        for (final e in _employees)
                          DropdownMenuItem<int?>(
                            value: e.id,
                            child: Text(
                              e.deptCode.isEmpty
                                  ? e.name
                                  : '${e.name}  ·  ${e.deptCode}',
                              style: titleStyle,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _assigneeId = v),
                    ),
                  if (!_loadingEmployees && _employees.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No members found for this department.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            ConstStrings.cancel,
            style: TextStyle(color: ThemeColors.unifiedTextMuted),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _handleSave,
          icon: const Icon(Icons.check_rounded, size: 17),
          label: const Text(ConstStrings.save),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.unifiedPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ],
    );
  }
}
