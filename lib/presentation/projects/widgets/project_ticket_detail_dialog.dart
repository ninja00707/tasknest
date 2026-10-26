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
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/member_stack.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/appbar_print_button.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/common_baged.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_comment_section.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_table_raw.dart';

/// Strips `Exception(...)` wrappers from error strings for snackbars.
String _friendlyError(Object e) {
  final raw = e.toString();
  final match = RegExp(r'Exception\((.*)\)', dotAll: true).firstMatch(raw);
  final message = match != null ? match.group(1)! : raw;
  return message.isEmpty ? 'The action could not be saved.' : message;
}

/// Trello-style card popup for the project module.
///
/// Opens the full ticket detail inside a dialog (instead of navigating to the
/// standalone [TicketDetailScreen]) and clears the loaded detail afterwards.
Future<void> showProjectTicketDetailDialog(
  BuildContext context, {
  required int ticketId,
  required UserModel user,
  List<ProjectMemberModel> projectTeam = const [],
}) async {
  final bloc = context.read<TicketBloc>();
  bloc.add(LoadTicketDetail(ticketId));
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => ProjectTicketDetailDialog(
      ticketId: ticketId,
      user: user,
      projectTeam: projectTeam,
    ),
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
  final List<ProjectMemberModel> projectTeam;

  const ProjectTicketDetailDialog({
    super.key,
    required this.ticketId,
    required this.user,
    this.projectTeam = const [],
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
                  _CoverBand(
                    ticket: null,
                    user: null,
                    projectTeam: widget.projectTeam,
                  ),
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
                _CoverBand(
                  ticket: ticket,
                  user: widget.user,
                  projectTeam: widget.projectTeam,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 62,
                        child: _LeftPane(
                          ticket: ticket,
                          user: widget.user,
                          projectTeam: widget.projectTeam,
                        ),
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
  final List<ProjectMemberModel> projectTeam;
  const _CoverBand({
    required this.ticket,
    required this.user,
    this.projectTeam = const [],
  });

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
            MemberStack(
              members: t.members,
              size: 28,
              max: 4,
              fallbackName: t.assignedToName ?? '',
            ),
            const SizedBox(width: 14),
            PrintButton(ticket: t, userName: t.createdByName),
            const SizedBox(width: 8),
            _OverflowMenu(
              ticket: t,
              user: user!,
              projectTeam: projectTeam,
            ),
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

  String get _label => switch (ticket.status) {
        'open' => 'TO DO',
        'in_progress' => 'IN PROGRESS',
        'closed' => 'DONE',
        _ => ticket.status.toUpperCase().replaceAll('_', ' '),
      };

  @override
  Widget build(BuildContext context) {
    final color = CommonStatus.ticketStatusColor(ticket.status);
    return PopupMenuButton<String>(
      tooltip: 'Move to another list',
      onSelected: (value) => _changeStatus(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'open', child: Text('To Do')),
        PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
        PopupMenuItem(value: 'closed', child: Text('Done')),
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

  /// Trello style: moving between lists needs no remark and no permission
  /// dance — any project team member can drop the card anywhere.
  void _changeStatus(BuildContext context, String target) {
    if (target == ticket.status) return;
    context.read<TicketBloc>().add(UpdateTicketStatus(ticket.id, target));
  }
}

class _OverflowMenu extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final List<ProjectMemberModel> projectTeam;
  const _OverflowMenu({
    required this.ticket,
    required this.user,
    this.projectTeam = const [],
  });

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
      builder: (_) => _EditTaskDialog(
        ticket: t,
        user: u,
        projectTeam: projectTeam,
      ),
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
  final List<ProjectMemberModel> projectTeam;
  const _LeftPane({
    required this.ticket,
    required this.user,
    this.projectTeam = const [],
  });

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
            _TaskActionsRow(
              ticket: ticket,
              onEdit: () => _openEditor(context),
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
      builder: (_) => _EditTaskDialog(
        ticket: ticket,
        user: user,
        projectTeam: projectTeam,
      ),
    );
  }
}

/// Trello-style action chips for a project task: move it to any list, edit
/// it, or archive it off the board.
class _TaskActionsRow extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onEdit;
  const _TaskActionsRow({required this.ticket, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          tooltip: 'Move to another list',
          onSelected: (value) {
            if (value == ticket.status) return;
            context
                .read<TicketBloc>()
                .add(UpdateTicketStatus(ticket.id, value));
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'open', child: Text('To Do')),
            PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
            PopupMenuItem(value: 'closed', child: Text('Done')),
          ],
          child: const _ActionChip(
            icon: Icons.alt_route_rounded,
            label: 'Move to',
          ),
        ),
        const SizedBox(width: 8),
        _ActionChip(
          icon: Icons.edit_outlined,
          label: 'Edit task',
          onTap: onEdit,
        ),
        const SizedBox(width: 8),
        _ActionChip(
          icon: Icons.archive_outlined,
          label: 'Archive',
          danger: true,
          onTap: () => _confirmArchive(context),
        ),
      ],
    );
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Archive this task?'),
        content: const Text(
          'It will disappear from the board. You can restore it later from '
          'the board\'s Archived list.',
          style: TextStyle(
            fontSize: 13,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedDanger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await sl<TicketRepositoryImpl>().archiveTicket(ticket.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task archived.'),
          backgroundColor: ThemeColors.unifiedPrimary,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e)),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = danger ? ThemeColors.unifiedDanger : ThemeColors.unifiedPrimary;
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: danger
              ? ThemeColors.unifiedDanger.withValues(alpha: 0.45)
              : ThemeColors.unifiedBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: danger ? tint : ThemeColors.unifiedTextPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: danger ? tint : ThemeColors.unifiedTextPrimary,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: content,
    );
  }
}

/// Project tasks only surface the creator, the department that owns the task
/// and the team working on it.
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

    final memberNames = t.members.map((m) => m.name).join(', ');

    return CommonSectionCardContainer(
      icon: Icons.info_outline_rounded,
      title: 'Details',
      child: Column(
        children: [
          DetailRow(label: 'Created by', value: creator),
          DetailRow(label: 'Assigned department', value: department),
          DetailRow(
            label: 'Members',
            value: memberNames.isEmpty ? 'No members yet' : memberNames,
            isLast: true,
            valueWidget: t.members.isEmpty
                ? const Text(
                    'No members yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MemberStack(
                        members: t.members,
                        size: 24,
                        max: 5,
                        showFallbackWhenEmpty: false,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          memberNames,
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
    // Project tasks (Trello style): anyone who can open the task can comment.
    if (t.projectId != null) return true;
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
/// and the team (many members) working on it.
class _EditTaskDialog extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;
  final List<ProjectMemberModel> projectTeam;
  const _EditTaskDialog({
    required this.ticket,
    required this.user,
    this.projectTeam = const [],
  });

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  static const List<String> _priorities = ['low', 'medium', 'high', 'urgent'];

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _memberSearch;
  late String _priority;
  DateTime? _dueDate;
  List<TicketMemberModel> _selected = [];
  List<TicketMemberModel> _candidates = [];
  bool _loadingCandidates = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TicketModel get ticket => widget.ticket;
  UserModel get user => widget.user;
  List<ProjectMemberModel> get projectTeam => widget.projectTeam;

  /// Backend only lets the creator touch the description while it is open —
  /// except on project tasks (Trello style), where everyone can always edit.
  bool get _canEditDescription =>
      ticket.projectId != null ||
      (ticket.isOpen && ticket.createdById == user.id);

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: ticket.title);
    _description = TextEditingController(text: ticket.description);
    _memberSearch = TextEditingController();
    _priority = _priorities.contains(ticket.priority)
        ? ticket.priority
        : 'medium';
    _dueDate = ticket.dueDate;
    _selected = List.of(ticket.members);
    _loadCandidates();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _memberSearch.dispose();
    super.dispose();
  }

  /// Candidate pool = project team (everyone can see it) + the employee
  /// directory (manager/CEO only, 403 quietly ignored).
  Future<void> _loadCandidates() async {
    setState(() => _loadingCandidates = true);
    final byId = <int, TicketMemberModel>{};

    for (final m in projectTeam) {
      byId[m.id] = TicketMemberModel(
        id: m.id,
        name: m.name,
        deptCode: m.code,
        deptName: m.departmentName,
      );
    }

    final repo = sl<TicketRepositoryImpl>();
    try {
      var employees = await repo.getEmployees(
        departmentId: ticket.assignedDeptId,
      );
      if (employees.isEmpty) employees = await repo.getEmployees();
      for (final e in employees) {
        byId[e.id] = TicketMemberModel(
          id: e.id,
          name: e.name,
          deptCode: e.deptCode,
          deptName: e.deptName,
        );
      }
    } catch (_) {
      // Not a manager / CEO — project team is the pool.
    }

    for (final m in _selected) {
      byId.putIfAbsent(m.id, () => m);
    }

    if (!mounted) return;
    setState(() {
      _candidates = byId.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _loadingCandidates = false;
    });
  }

  bool _isSelected(TicketMemberModel m) => _selected.any((e) => e.id == m.id);

  void _addMember(TicketMemberModel m) {
    if (_isSelected(m)) return;
    setState(() => _selected = [..._selected, m]);
  }

  void _removeMember(int id) {
    setState(() => _selected = _selected.where((m) => m.id != id).toList());
  }

  List<TicketMemberModel> get _filteredCandidates {
    final q = _memberSearch.text.trim().toLowerCase();
    final pool = _candidates.where((m) => !_isSelected(m)).toList();
    if (q.isEmpty) return pool;
    return pool
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.deptCode.toLowerCase().contains(q) ||
            m.deptName.toLowerCase().contains(q))
        .toList();
  }

  bool get _membersChanged {
    final before = ticket.members.map((m) => m.id).toSet();
    final after = _selected.map((m) => m.id).toSet();
    return before.length != after.length || !before.containsAll(after);
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

    final membersChanged = _membersChanged;

    if (fields.isEmpty && !membersChanged) {
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
    if (membersChanged) {
      bloc.add(SetTicketMembers(
        ticket.id,
        _selected.map((m) => m.id).toList(),
      ));
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Team members', style: titleStyle),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_selected.length}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selected.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'No members yet. Search below to add your team.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final m in _selected)
                          Chip(
                            avatar: InitialsAvatar(name: m.name, size: 18),
                            label: Text(
                              m.name,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.unifiedTextPrimary,
                              ),
                            ),
                            backgroundColor: ThemeColors.unifiedInputBg,
                            side: const BorderSide(
                              color: ThemeColors.unifiedBorder,
                            ),
                            deleteIcon: const Icon(Icons.close_rounded, size: 15),
                            onDeleted: () => _removeMember(m.id),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _memberSearch,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Search people to add…',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 4),
                if (_loadingCandidates)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ThemeColors.unifiedPrimary,
                        ),
                      ),
                    ),
                  )
                else ...[
                  if (_filteredCandidates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _memberSearch.text.trim().isEmpty
                            ? 'Everyone is already on this task.'
                            : 'No matching people.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filteredCandidates.length > 6
                            ? 6
                            : _filteredCandidates.length,
                        itemBuilder: (ctx, index) {
                          final c = _filteredCandidates[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _addMember(c),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  InitialsAvatar(name: c.name, size: 26),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: titleStyle,
                                        ),
                                        if (c.deptCode.isNotEmpty ||
                                            c.deptName.isNotEmpty)
                                          Text(
                                            c.deptCode.isEmpty
                                                ? c.deptName
                                                : (c.deptName.isEmpty
                                                    ? c.deptCode
                                                    : '${c.deptCode} · ${c.deptName}'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color:
                                                  ThemeColors.unifiedTextMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 18,
                                    color: ThemeColors.unifiedPrimary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
