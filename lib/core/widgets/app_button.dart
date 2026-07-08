import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// Pre-styled button variants.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double? width;
  final bool loading;
  final bool disabled;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.width,
    this.loading = false,
    this.disabled = false,
    this.variant = AppButtonVariant.primary,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.width,
    this.loading = false,
    this.disabled = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.width,
    this.loading = false,
    this.disabled = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.width,
    this.loading = false,
    this.disabled = false,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.width,
    this.loading = false,
    this.disabled = false,
  }) : variant = AppButtonVariant.textOnly;

  bool get _isActive => onPressed != null && !loading && !disabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => _buildElevated(),
        AppButtonVariant.secondary => _buildSecondary(),
        AppButtonVariant.outline => _buildOutline(),
        AppButtonVariant.textOnly => _buildTextOnly(),
      },
    );
  }

  Widget _buildElevated() {
    return ElevatedButton(
      onPressed: _isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.unifiedPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ThemeColors.unifiedPrimary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildSecondary() {
    return ElevatedButton(
      onPressed: _isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.unifiedSecondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ThemeColors.unifiedSecondary.withValues(alpha: 0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildOutline() {
    return OutlinedButton(
      onPressed: _isActive ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeColors.unifiedPrimary,
        side: const BorderSide(color: ThemeColors.unifiedPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildTextOnly() {
    return TextButton(
      onPressed: _isActive ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: ThemeColors.unifiedPrimary,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}

enum AppButtonVariant { primary, secondary, outline, textOnly }
