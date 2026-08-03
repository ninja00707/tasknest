import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_bloc.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_event.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';

Future<void> showRaiseDisputeDialog(
  BuildContext context, {
  required int ticketId,
}) async {
  final bloc = context.read<DisputeBloc>();
  final reasonController = TextEditingController();
  final descController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedReason;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (stfContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.gavel_rounded,
                  size: 20,
                  color: ThemeColors.unifiedDanger,
                ),
                SizedBox(width: 10),
                Text(
                  ConstStrings.raiseDispute,
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
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: reasonController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: ConstStrings.reasonLabel,
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down_rounded,
                          ),
                        ),
                        onTap: () {
                          FocusScope.of(stfContext).unfocus();
                          showModalBottomSheet<String>(
                            context: stfContext,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (sheetContext) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final label
                                      in DisputeReasonLabels.labels)
                                    ListTile(
                                      leading: const Icon(
                                        Icons.rule_rounded,
                                        color: ThemeColors.unifiedAccent,
                                      ),
                                      title: Text(label),
                                      onTap: () =>
                                          Navigator.pop(sheetContext, label),
                                    ),
                                ],
                              ),
                            ),
                          ).then((label) {
                            if (label != null) {
                              setState(() {
                                selectedReason =
                                    DisputeReasonLabels.valueFor(label);
                                reasonController.text = label;
                              });
                            }
                          });
                        },
                      ),
                      if (selectedReason == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            ConstStrings.selectReason,
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeColors.unifiedDanger,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: ConstStrings.describeDispute,
                          hintText: ConstStrings.describeDisputeHint,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 10) {
                            return ConstStrings.describeDisputeRequired;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
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
                  if (selectedReason == null) return;
                  if (!formKey.currentState!.validate()) return;
                  bloc.add(
                    RaiseDisputeEvent(
                      ticketId: ticketId,
                      reason: selectedReason!,
                      description: descController.text.trim(),
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.unifiedDanger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(ConstStrings.raiseDispute),
              ),
            ],
          );
        },
      );
    },
  );
}
