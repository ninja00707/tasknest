import 'package:flutter/material.dart';

class Responsive {
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width > 768;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;
}
