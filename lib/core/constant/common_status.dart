import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';

class CommonStatus {
  const CommonStatus._();

  static const statuses = ['open', 'in_progress', 'completed', 'closed'];

  // ── Labels ──────────────────────────────────────────────────────────────

  static String statusLabel(String s) {
    switch (s) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return s.replaceAll('_', ' ');
    }
  }

  // ── Weights (for sorting) ───────────────────────────────────────────────

  static int priorityWeight(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'urgent':
        return 0;
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 4;
    }
  }

  static int statusWeight(String? s) {
    final idx = statuses.indexOf(s ?? '');
    return idx == -1 ? statuses.length : idx;
  }

  // ── Kanban column color ─────────────────────────────────────────────────

  static Color columnColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF22C55E);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  // ── Timeline history helpers ────────────────────────────────────────────

  static Color actionColor(String action) {
    switch (action) {
      case 'created':
        return ThemeColors.timelineCreated;
      case 'assigned':
        return ThemeColors.timelineAssigned;
      case 'transferred':
        return ThemeColors.timelineTransferred;
      case 'status_changed':
        return ThemeColors.timelineStatusChanged;
      case 'closed':
        return ThemeColors.timelineClosed;
      case 'reopened':
        return ThemeColors.timelineReopened;
      case 'comment_added':
        return ThemeColors.timelineComment;
      default:
        return Colors.grey;
    }
  }

  static String actionTitle(String action) {
    switch (action) {
      case 'created':
        return ConstStrings.historyInitiated;
      case 'assigned':
        return ConstStrings.historyAssigned;
      case 'transferred':
        return ConstStrings.historyTransferred;
      case 'sub_ticket_created':
        return ConstStrings.historySubTicket;
      case 'status_changed':
        return ConstStrings.historyUpdated;
      case 'comment_added':
        return ConstStrings.historyComment;
      case 'reopened':
        return ConstStrings.historyReopened;
      default:
        return action.toUpperCase().replaceAll('_', ' ');
    }
  }

  static String actionNote(
    String action,
    String? oldV,
    String? newV,
    String note,
    String? currentDept,
  ) {
    switch (action) {
      case 'transferred':
        return "${oldV ?? ConstStrings.historyOrigin} ➔ ${ConstStrings.historyTransferredTo} ${newV ?? ConstStrings.historyTarget}";
      case 'assigned':
        final prev = (oldV == null || oldV == ConstStrings.historyUnassigned)
            ? ConstStrings.historyUnassigned
            : oldV;
        return "${currentDept ?? ''}: ${ConstStrings.historyAssignedTo} ${newV ?? ConstStrings.historyPersonnel} (${ConstStrings.historyPrev} $prev)";
      case 'status_changed':
        return "Status: ${oldV?.toUpperCase()} ➔ ${newV?.toUpperCase()}";
      case 'created':
        return "${ConstStrings.historyBornIn} ${currentDept ?? ConstStrings.historyDepartment}";
      case 'reopened':
        return "Returned to ${newV?.toUpperCase()} state for further work.";
      default:
        return note;
    }
  }

  // ── Sub-department status helpers ───────────────────────────────────────

  static String subDeptStatusLabel({
    required bool isCompleted,
    required bool isApproved,
    required bool isPendingApproval,
    required bool isInProgress,
  }) {
    if (isCompleted) return 'COMPLETED';
    if (isApproved) return 'APPROVED';
    if (isPendingApproval) return 'PENDING APPROVAL';
    if (isInProgress) return 'IN PROGRESS';
    return 'OPEN';
  }

  static Color subDeptStatusColor({
    required bool isCompleted,
    required bool isApproved,
    required bool isPendingApproval,
    required bool isInProgress,
  }) {
    if (isCompleted) return const Color(0xFF16A34A);
    if (isApproved) return const Color(0xFF2563EB);
    if (isPendingApproval) return const Color(0xFFF59E0B);
    if (isInProgress) return const Color(0xFF7C3AED);
    return ThemeColors.unifiedTextMuted;
  }
}
