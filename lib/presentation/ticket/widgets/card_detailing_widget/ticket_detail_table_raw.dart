import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;
  final Widget? trailing;
  final bool isLast;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWidget,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeColors.unifiedBorder),
              ),
            ),
      child: Row(
        children: [
          // Left Side Details Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonText(
                      label,
                      customeStyle: const TextStyle(
                        fontSize: 13,
                        color: ThemeColors.unifiedTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null) ...[
                      if (valueWidget != null) valueWidget!,
                      if (valueWidget == null)
                        Flexible(
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color:
                                  valueColor ?? ThemeColors.unifiedTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(width: 6),
                      trailing!,
                    ],
                    // ] else if (valueWidget != null)
                    //   valueWidget!,
                  ],
                ),

                // CommonText(
                //   label,
                //   customeStyle: const TextStyle(
                //     fontSize: 13,
                //     color: ThemeColors.unifiedTextMuted,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                // const Spacer(),
                // if (trailing != null) ...[
                //   if (valueWidget != null) valueWidget!,
                //   if (valueWidget == null)
                //     Flexible(
                //       child: Text(
                //         value,
                //         textAlign: TextAlign.right,
                //         style: TextStyle(
                //           fontSize: 13,
                //           fontWeight: FontWeight.w700,
                //           color: valueColor ?? ThemeColors.unifiedTextPrimary,
                //         ),
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     ),
                //   const SizedBox(width: 6),
                //   trailing!,
                // ] else if (valueWidget != null)
                //   valueWidget!,
              ],
            ),
          ),

          // Right Side Details Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? ThemeColors.unifiedTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Row(
      //   children: [
      //     Text(
      //       label,
      //       style: const TextStyle(
      //         fontSize: 13,
      //         color: ThemeColors.unifiedTextMuted,
      //         fontWeight: FontWeight.w500,
      //       ),
      //     ),
      //     const Spacer(),
      //     if (trailing != null) ...[
      //       if (valueWidget != null) valueWidget!,
      //       if (valueWidget == null)
      //         Flexible(
      //           child: Text(
      //             value,
      //             textAlign: TextAlign.right,
      //             style: TextStyle(
      //               fontSize: 13,
      //               fontWeight: FontWeight.w700,
      //               color: valueColor ?? ThemeColors.unifiedTextPrimary,
      //             ),
      //             overflow: TextOverflow.ellipsis,
      //           ),
      //         ),
      //       const SizedBox(width: 6),
      //       trailing!,
      //     ] else if (valueWidget != null)
      //       valueWidget!
      //     else
      //       Flexible(
      //         child: Text(
      //           value,
      //           textAlign: TextAlign.right,
      //           style: TextStyle(
      //             fontSize: 13,
      //             fontWeight: FontWeight.w700,
      //             color: valueColor ?? ThemeColors.unifiedTextPrimary,
      //           ),
      //           overflow: TextOverflow.ellipsis,
      //         ),
      //       ),
      //   ],
      // ),
    );
  }
}
