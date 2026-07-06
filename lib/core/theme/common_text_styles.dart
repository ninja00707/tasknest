import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Page Titles ──
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: ThemeColors.unifiedTextPrimary,
  );

  // ── Section Headers ──
  static const sectionHeader = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: ThemeColors.unifiedTextPrimary,
    letterSpacing: -0.2,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ThemeColors.unifiedTextPrimary,
  );

  // ── Body ──
  static const body = TextStyle(
    fontSize: 14,
    color: ThemeColors.unifiedTextPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    color: ThemeColors.unifiedTextPrimary,
  );

  static const bodyMuted = TextStyle(
    fontSize: 14,
    color: ThemeColors.unifiedTextMuted,
  );

  static const bodySmallMuted = TextStyle(
    fontSize: 13,
    color: ThemeColors.unifiedTextMuted,
  );

  // ── Captions & Labels ──
  static const caption = TextStyle(
    fontSize: 12,
    color: ThemeColors.unifiedTextMuted,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ThemeColors.unifiedTextMuted,
  );

  static const micro = TextStyle(
    fontSize: 10,
    color: ThemeColors.unifiedTextMuted,
  );

  // ── Buttons ──
  static const button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ThemeColors.unifiedPrimary,
  );

  // ── Badges & Chips ──
  static const badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ── Stat Numbers ──
  static const statNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: ThemeColors.unifiedTextPrimary,
  );

  static const statLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ThemeColors.unifiedTextMuted,
    letterSpacing: 0.3,
  );

  // ── Nav ──
  static const navLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ThemeColors.unifiedTextPrimary,
  );

  static const navLabelActive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: ThemeColors.unifiedPrimary,
  );

  // ── Subtitle / Description ──
  static const subtitle = TextStyle(
    fontSize: 14,
    color: ThemeColors.unifiedTextMuted,
    height: 1.5,
  );

  // ── Validation ──
  static const error = TextStyle(
    fontSize: 12,
    color: ThemeColors.unifiedDanger,
  );

  // ── Print / HTML ──
  static const printLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  static const printValue = TextStyle(
    fontSize: 12,
    color: Color(0xFF4B5563),
  );
}
