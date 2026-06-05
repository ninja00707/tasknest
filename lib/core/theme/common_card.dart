import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class UnifiedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const UnifiedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
    this.clipBehavior = Clip.hardEdge,
  });

  static const _defaultShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? ThemeColors.unifiedBorder,
          width: 1.5,
        ),
        boxShadow: boxShadow ?? _defaultShadow,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
