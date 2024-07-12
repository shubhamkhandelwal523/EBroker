import 'package:flutter/material.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorder(double bradius, bool isboarder,
      {Color bordercolor = Colors.transparent}) {
    return RoundedRectangleBorder(
        side: BorderSide(color: bordercolor, width: isboarder ? 1.0 : 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static BoxDecoration boxDecorationBorder(
      {required Color color,
      required double radius,
      Color? borderColor,
      double? borderWidth}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor, width: borderWidth ?? 1),
    );
  }
}
