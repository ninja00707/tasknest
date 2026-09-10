import 'package:flutter/material.dart';

import 'trading_screen.dart';

void main() {
  runApp(const AiTraderApp());
}

class AiTraderApp extends StatelessWidget {
  const AiTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Trader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF161B22),
          primary: const Color(0xFF26A69A),
          secondary: const Color(0xFFEF5350),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: const TradingScreen(),
    );
  }
}
