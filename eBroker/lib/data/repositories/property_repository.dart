import 'dart:developer';

import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/hive_utils.dart';
import '../helper/filter.dart';
import '../model/data_output.dart';
import '../model/property_model.dart';

class PropertyRepository {
  ///This method will add property
  Future createProperty({required Map<String, dynamic> parameters}) async {
    var api = Api.apiPostProperty;
    if (parameters['action_type'] == "0") {
      api = Api.apiUpdateProperty;

      if (parameters.containsKey("gallery_images")) {
        if ((parameters['gallery_images'] as List).isEmpty) {
          parameters.remove("gallery_images");
        }
      }

      if (parameters['title_image'] == null ||
          parameters['title_image'] == "") {
        parameters.remove("title_image");
      }
      if (parameters['meta_image'] == null || parameters['meta_image'] == "") {
        parameters.remove("title_image");
      }
    }

    return await Api.post(url: api, parameter: parameters);
  }

  /// it will get all proerpties
  Future<DataOutput<PropertyModel>> fetchProperty({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchRecentProperties(
      {required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchPropertyFromPropertyId(
      dynamic id) async {
    Map<String, dynamic> parameters = {
      Api.id: id,
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<void> deleteProperty(int id) async {
    await Api.post(
        url: Api.apiUpdateProperty,
        parameter: {Api.id: id, Api.actionType: "1"});
  }

  Future<DataOutput<PropertyModel>> fetchTopRatedProperty() async {
    Map<String, dynamic> parameters = {
      Api.topRated: "1",
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///fetch most viewed properties
  Future<DataOutput<PropertyModel>> fetchMostViewedProperty(
      {required int offset, required bool sendCityName}) async {
    Map<String, dynamic> parameters = {
      Api.topRated: "1",
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId()
    };
    try {
      if (sendCityName) {
        // if (HiveUtils.getCityName() != null) {
        //   if (!Constant.isDemoModeOn) {
        //     parameters['city'] = HiveUtils.getCityName();
        //   }
        // }
      }

      Map<String, dynamic> response = await Api.get(
        url: Api.apiGetProprty,
        queryParameters: parameters,
      );

      List<PropertyModel> modelList = (response['data'] as List)
          .map((e) => PropertyModel.fromMap(e))
          .toList();
      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      print("issue is $e");
      throw e;
    }
  }

  ///fetch advertised properties
  Future<DataOutput<PropertyModel>> fetchPromotedProperty(
      {required int offset, required bool sendCityName}) async {
    ///
    Map<String, dynamic> parameters = {
      Api.promoted: true,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(
      total: response['total'] ?? 0,
      modelList: modelList,
    );
  }

  Future<DataOutput<PropertyModel>> fetchNearByProperty(
      {required int offset}) async {
    try {
      if (HiveUtils.getCityName() == null ||
          HiveUtils.getCityName().toString().isEmpty) {
        return Future.value(DataOutput(
          total: 0,
          modelList: [],
        ));
      }
      Map<String, dynamic> result = await Api.get(
        url: Api.apiGetProprty,
        queryParameters: {
          "city": HiveUtils.getCityName(),
          Api.offset: offset,
          "limit": Constant.loadLimit,
          "current_user": HiveUtils.getUserId()
        },
      );

      List<PropertyModel> dataList = (result['data'] as List).map((e) {
        return PropertyModel.fromMap(e);
      }).toList();

      return DataOutput<PropertyModel>(
        total: result['total'] ?? 0,
        modelList: dataList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<PropertyModel>> fetchMostLikeProperty({
    required int offset,
    required bool sendCityName,
  }) async {
    Map<String, dynamic> parameters = {
      "most_liked": 1,
      "limit": Constant.loadLimit,
      "offset": offset,
      "current_user": HiveUtils.getUserId()
    };
    if (sendCityName) {
      // if (HiveUtils.getCityName() != null) {
      //   if (!Constant.isDemoModeOn) {
      //     parameters['city'] = HiveUtils.getCityName();
      //   }
      // }
    }
    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List).map((e) {
      return PropertyModel.fromMap(e);
    }).toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchMyPromotedProeprties(
      {required int offset}) async {
    Map<String, dynamic> parameters = {
      "users_promoted": 1,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId()
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);
    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///Search proeprty
  Future<DataOutput<PropertyModel>> searchProperty(String searchQuery,
      {required int offset, FilterApply? filter}) async {
    Map<String, dynamic> parameters = {
      Api.search: searchQuery,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId(),
      ...filter?.getFilter() ?? {}
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///to get my properties which i had added to sell or rent
  Future<DataOutput<PropertyModel>> fetchMyProperties(
      {required int offset, required String type}) async {
    try {
      String? propertyType = _findPropertyType(type.toLowerCase());

      Map<String, dynamic> parameters = {
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
        Api.userid: HiveUtils.getUserId(),
        Api.propertyType: propertyType,
        "current_user": HiveUtils.getUserId()
      };
      Map<String, dynamic> response =
          await Api.get(url: Api.apiGetProprty, queryParameters: parameters);
      List<PropertyModel> modelList = (response['data'] as List)
          .map((e) => PropertyModel.fromMap(e))
          .toList();

      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      throw e;
    }
  }

  String? _findPropertyType(String type) {
    if (type == "sell") {
      return "0";
    } else if (type == "rent") {
      return "1";
    }
    return null;
  }

  Future<DataOutput<PropertyModel>> fetchProperyFromCategoryId({
    required int id,
    required int offset,
    FilterApply? filter,
    bool? showPropertyType,
  }) async {
    Map<String, dynamic> parameters = {
      Api.categoryId: id,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      "current_user": HiveUtils.getUserId(),
      ...filter?.getFilter() ?? {}
    };

    // if (filter != null) {
    //   // parameters.addAll(Constant.propertyFilter!.toMap());
    //   if (Constant.propertyFilter?.categoryId == "") {
    //     if (showPropertyType ?? true) {
    //       parameters.remove(Api.categoryId);
    //     } else {
    //       parameters[Api.categoryId] = id;
    //     }
    //   }
    // }

    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<void> setProeprtyView(String propertyId) async {
    await Api.post(
        url: Api.setPropertyView, parameter: {Api.propertyId: propertyId});
  }

  Future updatePropertyStatus(
      {required dynamic propertyId, required dynamic status}) async {
    await Api.post(
        url: Api.updatePropertyStatus,
        parameter: {"status": status, "property_id": propertyId});
  }

  Future<PropertyModel> fetchBySlug(String slug) async {
    Map<String, dynamic> result = await Api.get(
        url: Api.apiGetProprty, queryParameters: {"slug_id": slug});

    return PropertyModel.fromMap(result['data'][0]);
  }

  Future<DataOutput<PropertyModel>> fetchPropertiesFromCityName(
    String cityName, {
    required int offset,
  }) async {
    Map<String, dynamic> response =
        await Api.get(url: Api.apiGetProprty, queryParameters: {
      "city": cityName,
      Api.limit: Constant.loadLimit,
      Api.offset: offset,
      "current_user": HiveUtils.getUserId()
    });

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
