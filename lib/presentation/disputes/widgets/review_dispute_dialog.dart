import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_bloc.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_event.dart';

/// action: 'under_review' | 'resolved' | 'rejected' | 'escalated'
Future<void> showReviewDisputeDialog(
  BuildContext context, {
  required int disputeId,
  required String action,
}) async {
  final bloc = context.read<DisputeBloc>();
  final noteController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isTerminal = action == 'resolved' || action == 'rejected';
  final noteRequired = isTerminal;

  final (title, submitLabel, icon, color) = switch (action) {
    'under_review' => (
        ConstStrings.startReview,
        ConstStrings.startReview,
        Icons.visibility_rounded,
        ThemeColors.unifiedSecondary,
      ),
    'resolved' => (
        ConstStrings.resolve,
        ConstStrings.resolve,
        Icons.verified_rounded,
        ThemeColors.unifiedSuccess,
      ),
    'rejected' => (
        ConstStrings.reject,
        ConstStrings.reject,
        Icons.close_rounded,
        ThemeColors.unifiedDanger,
      ),
    _ => (
        ConstStrings.escalate,
        ConstStrings.escalate,
        Icons.trending_up_rounded,
        ThemeColors.unifiedWarning,
      ),
  };

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: noteRequired
                    ? ConstStrings.resolutionNote
                    : '${ConstStrings.resolutionNote} (optional)',
                hintText: ConstStrings.resolutionNoteHint,
              ),
              validator: noteRequired
                  ? (v) {
                      if (v == null || v.trim().length < 10) {
                        return ConstStrings.resolutionNoteRequired;
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ConstStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteRequired && !formKey.currentState!.validate()) return;
              final note = noteController.text.trim();
              bloc.add(
                UpdateDisputeStatusEvent(
                  disputeId: disputeId,
                  status: action,
                  note: note.isEmpty ? null : note,
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(submitLabel),
          ),
        ],
      );
    },
  );
}
