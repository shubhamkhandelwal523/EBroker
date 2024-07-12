import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../utils/Extensions/extensions.dart';

//This will open image crop SDK
class CropImage {
  static BuildContext? _context;

  static void init(BuildContext context) {
    _context = context;
  }

  static Future<CroppedFile?>? crop({required String filePath}) async {
    if (_context == null) {
      return null;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: _context!.color.tertiaryColor,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: false,
            activeControlsWidgetColor: _context!.color.tertiaryColor,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: _context!,
        ),
      ],
    );

    return croppedFile;
  }
}
