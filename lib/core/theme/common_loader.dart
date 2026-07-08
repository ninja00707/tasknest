import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        title: const Text(ConstStrings.loading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ThemeColors.unifiedBorder),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      ),
    );
  }
}
