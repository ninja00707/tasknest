import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class CommonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? customeStyle;

  const CommonText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color = ThemeColors.unifiedTextPrimary,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.customeStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style:
          customeStyle ??
          TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
    );
  }
}
