// ignore_for_file: unnecessary_getters_setters, file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'helper_utils.dart';

class PickImage {
  final ImagePicker _picker = ImagePicker();
  final StreamController _imageStreamController = StreamController.broadcast();
  Stream get imageStream => _imageStreamController.stream;
  StreamSink get _sink => _imageStreamController.sink;
  StreamSubscription? subscription;
  File? _pickedFile;
  File? _pickedPreviousFile;
  File? get pickedFile => _pickedFile;

  set pickedFile(File? pickedFile) {
    _pickedFile = pickedFile;
  }

  pick({ImageSource? source, bool? pickMultiple}) async {
    _pickedPreviousFile = pickedFile;

    if (pickMultiple == false || pickMultiple == null) {
      await _picker
          .pickImage(
        source: source ?? ImageSource.gallery,
      )
          .then((XFile? pickedFile) async {
        File file = File(pickedFile!.path);

        int threeMB = 3000000;
        if (await file.length() >= threeMB) {
          File? file2 = (await HelperUtils.compressImageFile(file));
          file = file2!;
        }
        _pickedFile = file;
//adding map to stream
        _sink.add({
          "error": "",
          "file": file,
        });
      }).catchError((error) {
        _sink.add({
          "error": error,
          "file": null,
        });
      });
    } else {
      List<XFile> list = await _picker.pickMultiImage(
        imageQuality: Constant.uploadImageQuality,
      );
      int threeMB = 3000000;

      Iterable<Future<File>> result = list.map((image) async {
        File myImage;
        int length = await image.length();
        if (length >= threeMB) {
          File? file2 = (await HelperUtils.compressImageFile(File(image.path)));
          myImage = file2!;
          // var i = await myImage.length();
        } else {
          myImage = File(image.path);
        }
        return myImage;
      });
      Files templistFile = [];
      await for (Future<File> futureFile in Stream.fromIterable(result)) {
        File file = await futureFile;
        templistFile.add(file);
      }

      _sink.add({
        "error": "",
        "file": templistFile,
      });
      // templistFile.clear();
    }
  }

  /// This widget will listen changes in ui, it is wrapper around Stream builder
  Widget listenChangesInUI(
    dynamic Function(
      BuildContext context,
      dynamic image,
    ) ondata,
  ) {
    return StreamBuilder(
        stream: imageStream,
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data['file'] is File) {
              pickedFile = snapshot.data["file"];
            }

            return ondata.call(
              context,
              snapshot.data["file"],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ondata.call(
              context,
              null,
            );
          }
          return ondata.call(
            context,
            null,
          );
        }));
  }

  void listener(void Function(dynamic)? onData) {
    subscription = imageStream.listen((data) {
      print("PIC#$_pickedPreviousFile $pickedFile");

      log("SUBSCRIPTION ${subscription?.isPaused}");
      if ((subscription?.isPaused == false)) {
        log("CALLING INSIDE");
        onData?.call(data['file']);
      }
    });
  }

  void pauseSubscription() {
    subscription?.pause();
  }

  void resumeSubscription() {
    subscription?.resume();
  }

  void clearImage() {
    pickedFile = null;
    _sink.add(null);
  }

  void dispose() {
    if (!_imageStreamController.isClosed) {
      _imageStreamController.close();
    }
  }
}

enum PickImageStatus { initial, waiting, done, error }
