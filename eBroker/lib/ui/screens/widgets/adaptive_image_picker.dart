import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/custom_validator.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/ui_utils.dart';
import '../proprties/add_propery_screens/add_property_details.dart';

abstract class ImagePickerValue<T> {
  abstract final T value;
}

class UrlValue extends ImagePickerValue {
  @override
  final String value;
  final dynamic metaData;
  UrlValue(this.value, [this.metaData]);
}

class FileValue extends ImagePickerValue<File> {
  @override
  final File value;
  final FileSize? fileSize;
  FileValue(this.value, this.fileSize);
}

class IdentifyValue extends ImagePickerValue {
  @override
  dynamic value;
  IdentifyValue(this.value) {
    if (value is File) {
      var file = value;
      int fileSizeInBytes = file.lengthSync();

      value = FileValue(file, formatFileSize(fileSizeInBytes));
      // value = FileValue(
      //   value,
      // );
    }
    if (value is String) {
      value = UrlValue(value);
    }
  }
}

class MultiValue extends ImagePickerValue {
  List<ImagePickerValue> value;
  MultiValue(this.value);
}

class FileSize {
  final double kb;
  final double mb;
  final double gb;
  final int bytes;

  const FileSize({
    required this.bytes,
    required this.kb,
    required this.mb,
    required this.gb,
  });

  @override
  String toString() {
    return 'FileSize{kb: $kb, mb: $mb, gb: $gb, bytes: $bytes}';
  }
}

class ImageCount {
  final int min;
  final int max;
  ImageCount(this.min, this.max);
}

class AdaptiveImagePickerWidget extends StatefulWidget {
  final String title;
  final ImageCount? count;
  final int? allowedSizeBytes;
  final bool? isRequired;
  final bool? multiImage;
  final ImagePickerValue? value;
  final void Function(dynamic value)? onRemove;
  final void Function(ImagePickerValue? selected) onSelect;

  const AdaptiveImagePickerWidget(
      {super.key,
      this.value,
      required this.onSelect,
      required this.title,
      this.multiImage,
      this.onRemove,
      this.isRequired,
      this.count,
      this.allowedSizeBytes});

  @override
  State<AdaptiveImagePickerWidget> createState() =>
      _AdaptiveImagePickerWidgetState();
}

class _AdaptiveImagePickerWidgetState extends State<AdaptiveImagePickerWidget> {
  ImagePicker imagePicker = ImagePicker();

  Widget currentWidget = Container();
  ImagePickerValue? imagePickedValue;
  dynamic get(ImagePickerValue imagePickerValue) {
    if (imagePickerValue is UrlValue) {
      return Image.network(
        imagePickerValue.value,
        fit: BoxFit.cover,
      );
    }
    if (imagePickerValue is FileValue) {
      return Image.file(
        imagePickerValue.value,
        fit: BoxFit.cover,
      );
    }
    if (imagePickedValue is IdentifyValue) {
      return get(imagePickerValue);
    }
  }

  @override
  void initState() {
    if (widget.value != null) {
      imagePickedValue = widget.value;
    }
    super.initState();
  }

  dynamic getProvider(imagePickedValue) {
    if (imagePickedValue is FileValue) {
      return FileImage(imagePickedValue.value);
    }
    if (imagePickedValue is UrlValue) {
      return NetworkImage(imagePickedValue.value);
    }
    if (imagePickedValue is IdentifyValue) {
      return getProvider(imagePickedValue);
    }
  }

  _onPick(FormFieldState state) async {
    // _pickTitleImage.pick(pickMultiple: false);
    // titleImageURL = "";

    if (widget.multiImage == true) {
      List<XFile> list = await imagePicker.pickMultiImage();

      List<FileValue> multiImages = list.map((e) {
        var file = File(e.path);
        int fileSizeInBytes = file.lengthSync();
        FileValue fv = FileValue(file, formatFileSize(fileSizeInBytes));
        return fv;
      }).toList();

      if (imagePickedValue == null) {
        imagePickedValue = MultiValue(multiImages);
      } else {
        (imagePickedValue as MultiValue?)?.value.addAll(multiImages);
      }

      state.didChange(imagePickedValue);

      widget.onSelect(imagePickedValue! as MultiValue);
      setState(() {});
      return;
    }
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      var file = File(xFile.path);
      int fileSizeInBytes = file.lengthSync();
      imagePickedValue = FileValue(file, formatFileSize(fileSizeInBytes));
      state.didChange(imagePickedValue);
      widget.onSelect(imagePickedValue! as FileValue);
    }

    setState(() {});
  }

  _onRemove(dynamic value, FormFieldState state) {
    if (widget.multiImage == true) {
      if (imagePickedValue is MultiValue) {
        (imagePickedValue as MultiValue).value.remove(value);
        widget.onRemove?.call(value);
      }

      widget.onSelect(imagePickedValue);
    } else {
      imagePickedValue = null;
      state.didChange(null);
      widget.onRemove?.call(null);

      widget.onSelect(null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imagePickedValue is MultiValue) {}
    if (imagePickedValue != null) {
      currentWidget = GestureDetector(
        onTap: () {
          UiUtils.showFullScreenImage(context,
              provider: getProvider(imagePickedValue));
        },
        child: Column(
          children: [
            Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(5),
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: get(imagePickedValue!)),
          ],
        ),
      );
    } else {
      currentWidget = Container();
    }
    return CustomValidator<ImagePickerValue>(
        initialValue: widget.value,
        validator: (value) {
          if (widget.isRequired == true) {
            if (value == null) {
              return "Please pick image";
            }
            if (value is MultiValue) {
              if (value.value.isEmpty) {
                return "Please pick image";
              }
            }

            if (value is FileValue) {
              if (widget.allowedSizeBytes != null &&
                  value.fileSize!.bytes > widget.allowedSizeBytes!) {
                var size = formatFileSize(widget.allowedSizeBytes!);
                return "Max ${size.kb ~/ 1}KB your file size: ${value.fileSize!.kb ~/ 1}KB";
              }
            }
            if (widget.count != null &&
                widget.multiImage == true &&
                widget.isRequired == true) {
              if (imagePickedValue is MultiValue) {
                int images = (imagePickedValue as MultiValue).value.length;
                if (widget.count?.min != null && images < widget.count!.min) {
                  return "Minimum ${widget.count!.min} images required";
                }

                if (widget.count?.max != null && images > widget.count!.max) {
                  return "Maximum ${widget.count!.max} images are allowed";
                }
              }
            }
          }

          return null;
        },
        builder: (state) {
          return Wrap(
            children: [
              if (imagePickedValue == null)
                DottedBorder(
                  color: state.hasError
                      ? context.color.error
                      : context.color.textLightColor,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      _onPick(state);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child: Text(widget.title),
                    ),
                  ),
                ),
              // if (state.hasError)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 4),
              //     child: Text(state.errorText!)
              //         .color(context.color.error)
              //         .size(context.font.small),
              //   ),
              if (imagePickedValue is! MultiValue)
                Stack(
                  children: [
                    currentWidget,
                    closeButton(context, () {
                      _onRemove(null, state);
                    })
                  ],
                ),
              if (imagePickedValue is MultiValue) ...{
                ...(imagePickedValue! as MultiValue)
                    .value
                    .map((ImagePickerValue impvalue) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          UiUtils.showFullScreenImage(context,
                              provider: getProvider(impvalue));
                        },
                        child: Column(
                          children: [
                            Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.all(5),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: get(impvalue!)),
                          ],
                        ),
                      ),
                      closeButton(context, () {
                        _onRemove(impvalue, state);
                      })
                    ],
                  );
                })
              },
              if (imagePickedValue != null)
                uploadPhotoCard(context, onTap: () {
                  _onPick(state);
                })
              // GestureDetector(
              //   onTap: () {
              //     _pickTitleImage.resumeSubscription();
              //     _pickTitleImage.pick(pickMultiple: false);
              //     _pickTitleImage.pauseSubscription();
              //     titleImageURL = "";
              //     setState(() {});
              //   },
              //   child: Container(
              //     width: 100,
              //     height: 100,
              //     margin: const EdgeInsets.all(5),
              //     clipBehavior: Clip.antiAlias,
              //     decoration:
              //         BoxDecoration(borderRadius: BorderRadius.circular(10)),
              //     child: DottedBorder(
              //         borderType: BorderType.RRect,
              //         radius: Radius.circular(10),
              //         child: Container(
              //           alignment: Alignment.center,
              //           child: Text("Upload \n Photo"),
              //         )),
              //   ),
              // ),
              ,
              Row(
                children: [
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(state.errorText!)
                          .color(context.color.error)
                          .size(context.font.small),
                    ),
                ],
              )
            ],
          );
        });
  }
}

FileSize formatFileSize(int fileSizeInBytes) {
  const int KB = 1024;
  const int MB = 1024 * KB;
  const int GB = 1024 * MB;
  return FileSize(
      bytes: fileSizeInBytes,
      mb: fileSizeInBytes / MB,
      gb: fileSizeInBytes / GB,
      kb: fileSizeInBytes / KB);
}
