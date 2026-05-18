import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class CommonDecoration {
  InputDecorationTheme textFornDecorationTheme() {
    return InputDecorationTheme(
      fillColor: const Color(0xFFF8F9FA),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  BoxDecoration boxDecorationWithShadow() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  TextStyle textStyleButton() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  }

  BoxDecoration boxDecorationWithGradient() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // AppBar theme
  AppBarTheme appBarTheme() {
    return const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: ThemeColors.unifiedTextPrimary),
      titleTextStyle: TextStyle(
        color: ThemeColors.unifiedTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Gradient top strip
  Container commonTopGradStrip = Container(
    height: 4,
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
      ),
      borderRadius: BorderRadius.circular(4),
    ),
  );

  //Common Form Title
  TextStyle commonFormLabelStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ThemeColors.unifiedTextPrimary,
  );
}
