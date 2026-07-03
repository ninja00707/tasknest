import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// Pre-styled [Text] variants for the entire app.
/// Use these instead of raw [Text] to keep styling consistent.
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  // ── Named constructors for common variants ──

  /// Headline / large title
  const AppText.headline(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedTextPrimary,
        );

  /// Section title (medium)
  const AppText.title(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThemeColors.unifiedTextPrimary,
        );

  /// Subtitle
  const AppText.subtitle(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ThemeColors.unifiedTextPrimary,
        );

  /// Body / default text
  const AppText.body(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ThemeColors.unifiedTextPrimary,
        );

  /// Small / caption text
  const AppText.caption(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ThemeColors.unifiedTextMuted,
        );

  /// Muted / less prominent text
  const AppText.muted(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: ThemeColors.unifiedTextMuted,
        );

  /// Bold label
  const AppText.label(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ThemeColors.unifiedTextPrimary,
        );

  /// White text (for use on dark/gradient backgrounds)
  const AppText.white(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : style = const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
