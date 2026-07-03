import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// Full-page centered loading spinner.
class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline small loading indicator (for buttons, inline sections).
class AppLoadingInline extends StatelessWidget {
  final double size;

  const AppLoadingInline({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: ThemeColors.unifiedPrimary,
      ),
    );
  }
}
