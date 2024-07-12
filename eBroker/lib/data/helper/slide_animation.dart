import 'package:flutter/material.dart';

class AnimationFromRightSide extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimationFromRightSide(
      {super.key, required this.child, required this.delay});

  @override
  AnimationFromRightSideState createState() => AnimationFromRightSideState();
}

class AnimationFromRightSideState extends State<AnimationFromRightSide>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.35, 0.00), end: Offset.zero)
            .animate(curve);

    // if (widget.delay == null) {
    if (mounted) _animController.forward();
    // } else {
    //   Timer(Duration(milliseconds: widget.delay), () {
    //     if (mounted) _animController.forward();
    //   });
    // }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }
}

class AnimationFromBottomSide extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimationFromBottomSide(
      {super.key, required this.child, required this.delay});

  @override
  AnimationFromBottomSideState createState() => AnimationFromBottomSideState();
}

class AnimationFromBottomSideState extends State<AnimationFromBottomSide>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero)
            .animate(curve);

    _animController.forward();
    // Timer(Duration(milliseconds: widget.delay), () {
    //   _animController.forward();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }
}
