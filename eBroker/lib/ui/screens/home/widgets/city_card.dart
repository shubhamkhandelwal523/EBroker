import 'dart:math';

import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  const CityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
          Random().nextInt(255), 1),
    );
  }
}
