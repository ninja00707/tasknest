import 'package:flutter/material.dart';

class ThemeColors {
  ThemeColors._();

  // ── UM Enterprises — Green ────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color backgroundGreen = Color(0xFFF1F8F1);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderGreen = Color(0xFFC8E6C9);
  static const Color textDark = Color(0xFF1B5E20);
  static const Color textMuted = Color(0xFF558B5A);

  // ── Matrix Pharma — Navy ──────────────────────────────────────────────────
  static const Color navyPrimary = Color(0xFF0D1B2A);
  static const Color navySecondary = Color(0xFF1B2E40);
  static const Color navyAccent = Color(0xFF1E88E5);
  static const Color navyAccentLight = Color(0xFF42A5F5);
  static const Color navyBorder = Color(0xFF1E3A5F);
  static const Color navyCardBg = Color(0xFF162232);
  static const Color navyTextWhite = Color(0xFFECF0F1);
  static const Color navyTextMuted = Color(0xFF8EACC4);
  static const Color navyInputBg = Color(0xFF1A2F45);
  static const Color navySurface = Color(0xFF112030);

  // ── Unified Dual-Brand Palette ────────────────────────────────────────────
  // Background: very light teal-green — feels like both brands exist together
  static const Color unifiedBackground = Color(0xFFF0F6F8);

  // Surface (cards, topbar): clean white with a faint blue-green tint
  static const Color unifiedSurface = Color(0xFFFFFFFF);

  // Primary action: UM green — the dominant brand colour
  static const Color unifiedPrimary = Color(0xFF2E7D32);

  // Secondary action: Matrix navy accent blue — used for CTAs, links, badges
  static const Color unifiedSecondary = Color(0xFF1E88E5);

  // Accent: mid-teal blend of both brands
  static const Color unifiedAccent = Color(0xFF1A8A72);

  // Top bar gradient start (green) → end (navy)
  static const Color unifiedGradStart = Color(0xFF2E7D32);
  static const Color unifiedGradEnd = Color(0xFF0D47A1);

  // Borders: soft teal — blends green border + navy hint
  static const Color unifiedBorder = Color(0xFFB2D8D8);

  // Input background: lightest teal tint
  static const Color unifiedInputBg = Color(0xFFF4F9FA);

  // Primary text: deep navy-green (readable on both white and light backgrounds)
  static const Color unifiedTextPrimary = Color(0xFF0D2B1F);

  // Secondary text: muted teal-grey
  static const Color unifiedTextMuted = Color(0xFF4A7B7B);

  // Success / positive state: UM green
  static const Color unifiedSuccess = Color(0xFF43A047);

  // Info / highlight state: Matrix blue
  static const Color unifiedInfo = Color(0xFF1E88E5);

  // Warning
  static const Color unifiedWarning = Color(0xFFF59E0B);

  // Danger / error
  static const Color unifiedDanger = Color(0xFFEF4444);

  // Status badge backgrounds
  static const Color statusOpenBg = Color(0xFFE3F2FD); // light blue
  static const Color statusOpenFg = Color(0xFF1565C0);
  static const Color statusProgressBg = Color(0xFFFFF8E1); // amber
  static const Color statusProgressFg = Color(0xFFF57F17);
  static const Color statusDoneBg = Color(0xFFE8F5E9); // green
  static const Color statusDoneFg = Color(0xFF2E7D32);
  static const Color statusClosedBg = Color(0xFFF3F4F6); // grey
  static const Color statusClosedFg = Color(0xFF6B7280);

  // Priority badge backgrounds
  static const Color priorityLowBg = Color(0xFFE8F5E9);
  static const Color priorityLowFg = Color(0xFF2E7D32);
  static const Color priorityMedBg = Color(0xFFFFF8E1);
  static const Color priorityMedFg = Color(0xFFF57F17);
  static const Color priorityHighBg = Color(0xFFFFEDD5);
  static const Color priorityHighFg = Color(0xFFEA580C);
  static const Color priorityUrgentBg = Color(0xFFFEE2E2);
  static const Color priorityUrgentFg = Color(0xFFDC2626);

  // ── FlutterMaterialTheme helper ───────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: unifiedAccent,
      primary: unifiedPrimary,
      secondary: unifiedSecondary,
      surface: unifiedSurface,
      background: unifiedBackground,
    ),
    scaffoldBackgroundColor: unifiedBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: unifiedSurface,
      foregroundColor: unifiedTextPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: unifiedPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: unifiedInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: unifiedBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: unifiedBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: unifiedPrimary, width: 2),
      ),
      hintStyle: const TextStyle(color: unifiedTextMuted, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerColor: unifiedBorder,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: unifiedTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: unifiedTextPrimary, fontSize: 14),
      bodySmall: TextStyle(color: unifiedTextMuted, fontSize: 12),
    ),
  );
}
