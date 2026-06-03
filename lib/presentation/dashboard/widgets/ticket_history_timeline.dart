import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_date_format.dart';

/// A widget that displays the audit trail/history of a ticket in a timeline format.
class TicketHistoryTimeline extends StatelessWidget {
  final List<dynamic> history;

  const TicketHistoryTimeline({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "No history records found for this ticket.",
            style: TextStyle(color: ThemeColors.unifiedTextMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final log = history[index];
        final isLast = index == history.length - 1;

        // Extracting fields from the history array returned by the backend
        final String action = log['action'] ?? 'unknown';
        final String? oldValue = log['old_value'];
        final String? newValue = log['new_value'];
        final String note = log['note'] ?? '';
        final String actor = log['acted_by_name'] ?? 'System';
        final String? dept = log['dept_name'];
        final DateTime date = DateTime.parse(log['created_at']).toLocal();

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getActionColor(action),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: ThemeColors.unifiedBorder,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Format the action title based on the type of movement
                      Text(
                        _getDisplayTitle(action, oldValue, newValue, dept),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDisplayNote(action, oldValue, newValue, note, dept),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "By $actor ${dept != null ? '($dept)' : ''} • ${CommonDateFormat.formatShortDateTime(date)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDisplayTitle(
    String action,
    String? oldV,
    String? newV,
    String? dept,
  ) {
    switch (action) {
      case 'created':
        return "TICKET INITIATED";
      case 'assigned':
        return "PERSONNEL ASSIGNMENT";
      case 'transferred':
        return "DEPARTMENTAL TRANSFER";
      case 'status_changed':
        return "WORKFLOW UPDATE";
      case 'comment_added':
        return "NEW COMMENT";
      case 'reopened':
        return "TICKET REOPENED";
      default:
        return action.toUpperCase().replaceAll('_', ' ');
    }
  }

  String _getDisplayNote(
    String action,
    String? oldV,
    String? newV,
    String note,
    String? currentDept,
  ) {
    switch (action) {
      case 'transferred':
        // Shows: "HR ➔ Transferred to IT"
        return "${oldV ?? 'Origin'} ➔ Transferred to ${newV ?? 'Target'}";
      case 'assigned':
        // Shows: "IT: Assigned to Alice (Previously: Unassigned)"
        final prev = (oldV == null || oldV == 'Unassigned')
            ? 'Unassigned'
            : oldV;
        return "${currentDept ?? 'Dept'}: Assigned to ${newV ?? 'Personnel'} (Prev: $prev)";
      case 'status_changed':
        // Shows: "Status: OPEN ➔ IN PROGRESS"
        return "Status: ${oldV?.toUpperCase()} ➔ ${newV?.toUpperCase()}";
      case 'created':
        return "Ticket born in ${currentDept ?? 'Department'}";
      case 'reopened':
        return "Returned to ${newV?.toUpperCase()} state for further work.";
      default:
        return note;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'created':
        return Colors.blue;
      case 'assigned':
        return Colors.orange;
      case 'transferred':
        return Colors.purple;
      case 'status_changed':
        return Colors.green;
      case 'closed':
        return Colors.black54;
      case 'reopened':
        return Colors.red;
      case 'comment_added':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
