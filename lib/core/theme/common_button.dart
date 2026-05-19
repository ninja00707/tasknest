import 'package:flutter/material.dart';

import 'package:tasknest/core/theme/common_decoration.dart';
import 'package:tasknest/core/theme/common_text.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onTap,
    required this.buttonName,
    this.icon,
    this.height,
    this.width,
  });
  final Function onTap;
  final String buttonName;
  final Icon? icon;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap,
      child: Container(
        width: width ?? 300,
        height: height ?? 50,
        decoration: CommonDecoration().boxDecorationWithGradient(),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon!.icon, color: Colors.white),
                  const SizedBox(width: 8),
                  CommonText(
                    buttonName,
                    customeStyle: CommonDecoration().textStyleButton(),
                  ),
                ],
              )
            : CommonText(
                buttonName,
                customeStyle: CommonDecoration().textStyleButton(),
              ),
      ),
    );

    // SizedBox(
    //   width: double.infinity,
    //   height: 50,
    //   child: DecoratedBox(
    //     decoration: BoxDecoration(
    //       gradient: const LinearGradient(
    //         colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
    //       ),
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //     child: ElevatedButton(
    //       onPressed: () => onTap,
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.transparent,
    //         shadowColor: Colors.transparent,
    //         foregroundColor: Colors.white,
    //         elevation: 0,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //       ),
    //       child: icon != null
    //           ? Row(
    //               children: [
    //                 icon!,
    //                 const SizedBox(width: 8),
    //                 CommonText(
    //                   buttonName,
    //                   customeStyle: CommonDecoration().textStyleButton(),
    //                 ),
    //               ],
    //             )
    //           : CommonText(
    //               buttonName,
    //               customeStyle: CommonDecoration().textStyleButton(),
    //             ),
    //     ),
    //   ),
    // );
  }
}
