import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double? width;

  const AuthCard({super.key, required this.child, this.width});

  static const _shadow = [
    BoxShadow(
      color: Color(0x0F2E7D32),
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0F1E88E5),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 396,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(
          BorderSide(color: ThemeColors.unifiedBorder),
        ),
        boxShadow: _shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : CommonText(
                  label,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class AuthOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeColors.unifiedPrimary,
          side: const BorderSide(
            color: ThemeColors.unifiedPrimary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: CommonText(
          label,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedPrimary,
        ),
      ),
    );
  }
}
