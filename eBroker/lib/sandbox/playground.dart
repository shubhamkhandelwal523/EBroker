// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class PlayGround extends StatefulWidget {
  const PlayGround({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const PlayGround(),
    );
  }

  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: STFLW(),
        ),
      ),
    );
  }
}

class STFLW extends StatefulWidget {
  const STFLW({super.key});

  @override
  State<STFLW> createState() => _STFLWState();
}

class _STFLWState extends State<STFLW> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: Hexagon(),
      child: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
      ),
    );
  }
}

class Hexagon extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double spaceFactor = size.width * 00.15;
    path.moveTo(spaceFactor, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
