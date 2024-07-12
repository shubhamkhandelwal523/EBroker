import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final Color? color;
  final Widget child;
  final BorderRadius? borderRadius;
  final BoxShape? shape;
  final void Function() onTap;
  const CustomInkWell(
      {super.key,
      this.color,
      required this.child,
      required this.onTap,
      this.borderRadius,
      this.shape});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        clipBehavior: Clip.antiAlias,
        // color: color,
        decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            shape: shape ?? BoxShape.rectangle),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}
