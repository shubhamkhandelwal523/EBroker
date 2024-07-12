import 'package:flutter/material.dart';

class ScaleUpRouter<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Widget current;
  ScaleUpRouter({
    required this.builder,
    required this.current,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: <Widget>[
        ScaleTransition(
          scale: Tween<double>(
            begin: 1,
            end: 5,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: current,
        ),
        ScaleTransition(
          scale: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: child,
        )
      ],
    );
  }
}
