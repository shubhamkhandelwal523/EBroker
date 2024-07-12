import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

import '../../../utils/Extensions/extensions.dart';

class PanaromaImageScreen extends StatelessWidget {
  final String imageUrl;
  final bool? isFileImage;
  const PanaromaImageScreen(
      {super.key, required this.imageUrl, this.isFileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Panorama(
          sensitivity: 2,
          sensorControl: SensorControl.None,
          latitude: 4,
          child: (isFileImage ?? false)
              ? Image.file(File(imageUrl))
              : Image.network(
                  imageUrl,
                ),
        ),
      ),
    );
  }
}
