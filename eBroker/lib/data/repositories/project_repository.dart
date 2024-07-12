import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';

import '../model/project_model.dart';

class ProjectRepository {
  createProject(Map projectPayload) async {
    try {
      Map<String, dynamic> multipartedData = _multipartImages(projectPayload);
      // multipartedData['image']=multipartedData['main_image'];
      var images = projectPayload['gallery_images'];
      multipartedData.remove("gallery_images");
      Map<String, dynamic> galleryImages = {};
      if (images != null) {
        galleryImages =
            ((images as MultiValue).value).fold({}, (previousValue, element) {
          if (element.value is! String) {
            previousValue.addAll({
              "gallery_images[${previousValue.length}]":
                  MultipartFile.fromFileSync((element.value as File).path)
            });
          }

          return previousValue;
        });
      }

      multipartedData.addAll(galleryImages);
      print(galleryImages);
      Map<String, dynamic> map =
          await Api.post(url: Api.postProject, parameter: multipartedData);
      print("PRINT MAP $map");
      return map;
    } catch (e, st) {
      // throw e;
    }
  }

  Future<DataOutput<ProjectModel>> getMyProjects({required int offset}) async {
    Map<String, dynamic> result = await Api.get(
        url: Api.getProjects,
        queryParameters: {"userid": HiveUtils.getUserId(), "offset": offset});
    List<ProjectModel> list =
        (result['data'] as List).map((e) => ProjectModel.fromMap(e)).toList();

    return DataOutput(total: result['total'] ?? 0, modelList: list);
  }

  Future<DataOutput<ProjectModel>> getProjects({int? offset}) async {
    Map<String, dynamic> result = await Api.get(
        url: Api.getProjects, queryParameters: {"offset": offset});
    List<ProjectModel> list =
        (result['data'] as List).map((e) => ProjectModel.fromMap(e)).toList();

    return DataOutput(total: result['total'] ?? 0, modelList: list);
  }

  Map<String, dynamic> _multipartImages(Map data) {
    return data.map((key, value) {
      if (value is FileValue) {
        return MapEntry(key, MultipartFile.fromFileSync(value.value.path));
      }
      if (value is MultiValue && key != "gallery_images") {
        List<MultipartFile?> images = value.value.map((image) {
          if (image is FileValue) {
            return MultipartFile.fromFileSync(image.value.path);
          }
        }).toList();
        return MapEntry(key, images);
      }
      if (value is List<File>) {
        List<MultipartFile> files =
            value.map((e) => MultipartFile.fromFileSync(e.path)).toList();
        return MapEntry(key, files);
      }
      if (value is Map) {
        var v = _multipartImages(value);
        return MapEntry(key, v);
      }
      if (value is List) {
        List<Map> list = value.map((e) {
          if (e is Map) {
            return _multipartImages(e);
          }
          return {};
        }).toList();
        return MapEntry(key, list);
      }

      return MapEntry(key, value);
    });
  }
}
