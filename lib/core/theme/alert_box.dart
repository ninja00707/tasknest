import 'package:flutter/material.dart';

import 'package:tasknest/core/theme/color.dart';

class AppAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,

    bool isError = true,
  }) {
    return showDialog(
      context: context,

      barrierDismissible: true,

      builder: (_) {
        return Container(
          height: 450,
          width: 450,
          child: Dialog(
            backgroundColor: Colors.transparent,

            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: ThemeColors.unifiedSurface,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: isError
                      ? Colors.red.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),

                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    width: 72,
                    height: 72,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: isError
                          ? Colors.red.withOpacity(0.12)
                          : Colors.green.withOpacity(0.12),
                    ),

                    child: Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,

                      size: 38,

                      color: isError ? Colors.redAccent : Colors.green,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,

                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    message,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,

                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(
                        elevation: 0,

                        backgroundColor: isError
                            ? Colors.redAccent
                            : Colors.green,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        'OK',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
