import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class CommentSection extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;
  const CommentSection({super.key, required this.ticket, required this.user});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _canComment {
    if (widget.ticket.isClosed) return false;
    if (widget.ticket.canComment) return true;
    final uid = widget.user.id;
    if (uid == widget.ticket.createdById) return true;
    if (widget.ticket.myAssignedToId != null &&
        uid == widget.ticket.myAssignedToId) {
      return true;
    }
    if (widget.ticket.assignedToId != null &&
        uid == widget.ticket.assignedToId) {
      return true;
    }
    if (widget.ticket.subDepartments.any((sd) => sd.assignedToId == uid)) {
      return true;
    }
    if (widget.ticket.assignedDeptId != null &&
        widget.ticket.assignedDeptId == widget.user.departmentId) {
      return true;
    }
    return false;
  }

  void _submitComment() {
    final msg = _commentController.text.trim();
    if (msg.isEmpty) return;
    context.read<TicketBloc>().add(AddTicketComment(widget.ticket.id, msg));
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.ticket.comments;

    return CommonSectionCardContainer(
      icon: Icons.chat_outlined,
      title: ConstStrings.commentsCount(comments.length),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _canComment
                  ? ThemeColors.unifiedBackground
                  : ThemeColors.unifiedBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  enabled: _canComment,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _canComment
                        ? ConstStrings.writeCommentHint
                        : ConstStrings.commentsClosed,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                Container(height: 1, color: ThemeColors.unifiedBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _canComment ? _submitComment : null,
                        icon: const Icon(Icons.send_rounded, size: 15),
                        label: const Text(ConstStrings.post),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.unifiedPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.ticket.isClosed)
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
                  Icon(
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
          const SizedBox(height: 16),
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                ConstStrings.noCommentsYet,
                style: AppTextStyles.bodySmallMuted,
              ),
            )
          else
            ...comments.map((c) => CommentTile(comment: c)),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  const CommentTile({super.key, required this.comment});

  bool get _isStatusRemark =>
      comment.message.startsWith('[COMPLETED REMARK]') ||
      comment.message.startsWith('[CLOSED REMARK]');

  bool get _isDeptRemark => RegExp(
    r'^\[DEPT (COMPLETION|APPROVED|COMPLETED|PROGRESS)',
  ).hasMatch(comment.message);

  bool get _isSpecial => _isStatusRemark || _isDeptRemark;

  String get _typeLabel {
    if (_isStatusRemark) {
      return comment.message.startsWith('[COMPLETED REMARK]')
          ? 'MARKS DONE'
          : 'CLOSES';
    }
    if (_isDeptRemark) {
      if (comment.message.contains('COMPLETION')) return 'DEPT DONE';
      if (comment.message.contains('APPROVED')) return 'DEPT OK';
      if (comment.message.contains('COMPLETED')) return 'DEPT FINAL';
      return 'DEPT UPDATE';
    }
    return '';
  }

  IconData get _typeIcon {
    if (_isStatusRemark) return Icons.verified_rounded;
    if (_isDeptRemark) return Icons.workspace_premium_rounded;
    return Icons.person_rounded;
  }

  Color get _tintColor {
    if (_isStatusRemark) return ThemeColors.unifiedAccent;
    if (_isDeptRemark) return const Color(0xFF7C3AED);
    return ThemeColors.unifiedPrimary;
  }

  String get _displayName {
    if (_isStatusRemark) {
      return comment.message.startsWith('[COMPLETED REMARK]')
          ? 'Marked as Done'
          : 'Finalized & Closed';
    }
    if (_isDeptRemark) {
      final match = RegExp(
        r'^\[DEPT \w+ - (.+?)\]',
      ).firstMatch(comment.message);
      return match?.group(1) ?? 'Department';
    }
    return comment.userName;
  }

  String get _cleanMessage {
    return comment.message.replaceAll(RegExp(r'^\[[^\]]*\]:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isSpecial
            ? _tintColor.withValues(alpha: 0.04)
            : ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSpecial
              ? _tintColor.withValues(alpha: 0.2)
              : ThemeColors.unifiedBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _tintColor.withValues(alpha: 0.12),
            child: Icon(_typeIcon, size: 16, color: _tintColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _tintColor,
                      ),
                    ),
                    if (!_isSpecial && comment.deptCode.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${comment.deptCode})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    if (_isSpecial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _tintColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: _tintColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      CommonDateFormat.formatDateTime(comment.createdAt),
                      style: AppTextStyles.micro,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _cleanMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isSpecial
                        ? _tintColor.withValues(alpha: 0.85)
                        : ThemeColors.unifiedTextPrimary,
                    height: 1.5,
                    fontWeight: _isSpecial ? FontWeight.w600 : FontWeight.w400,
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
