import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/constant.dart';
import '../../../../../utils/helper_utils.dart';
import '../../../../../utils/ui_utils.dart';

class CustomFileField extends CustomField {
  @override
  String type = "file";
  String? pickedFilePath;
  MultipartFile? selectedFile;
  @override
  backValue() {
    return selectedFile;
  }

  Future<File?> pickFile() async {
    FilePickerResult? picker = await FilePicker.platform.pickFiles();
    if (picker != null) {
      File file = File(
        picker.files.single.path!,
      );
      return file;
    }
    return null;
  }

  @override
  void init() {
    id = data['id'];
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: 24,
                width: 24,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: UiUtils.imageType(data['image'],
                      color: Constant.adaptThemeColorSvg
                          ? context.color.tertiaryColor
                          : null,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Text(data['name'])
                .size(context.font.large)
                .bold(weight: FontWeight.w500)
                .color(context.color.textColorDark),
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        GestureDetector(
          onTap: () async {
            File? file = await pickFile();
            if (file != null) {
              MultipartFile multipartFile =
                  await MultipartFile.fromFile(file.path);
              selectedFile = multipartFile;
              pickedFilePath = file.path;
              update(() {});

              /// Add data to static Map
              // AbstractField.fieldsData
              //     .addAll({parameters['id']: multipartFile});
            }
          },
          child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              color: context.color.textLightColor,
              strokeCap: StrokeCap.round,
              padding: const EdgeInsets.all(5),
              dashPattern: const [3, 3],
              child: Container(
                width: double.infinity,
                height: 43,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Add File")
                        .color(context.color.textLightColor)
                        .size(context.font.large)
                  ],
                ),
              )),
        ),
        Builder(builder: (context) {
          if (pickedFilePath == null) {
            return const SizedBox.shrink();
          }
          return Container(
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pickedFilePath!.split("/").last)
                            .setMaxLines(lines: 1)
                            .bold(weight: FontWeight.w500),
                        if (!(pickedFilePath!.startsWith("http") ||
                            pickedFilePath!.startsWith("https")))
                          Text(HelperUtils.getFileSizeString(
                            bytes: File(pickedFilePath!).lengthSync(),
                          ).toUpperCase())
                              .size(context.font.smaller)
                      ],
                    )),
                const Spacer(flex: 1),
                IconButton(
                    onPressed: () {
                      // AbstractField.fieldsData.remove(parameters['id']);
                      pickedFilePath = null;
                      update(() {});
                      // picked.value = null;
                    },
                    icon: Icon(Icons.close))
              ],
            ),
          );
        })
      ],
    );
  }
}
