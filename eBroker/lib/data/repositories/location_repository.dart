// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:ebroker/utils/constant.dart';

import '../../utils/api.dart';
import '../model/google_place_model.dart';

class GooglePlaceRepository {
  //This will search places from google place api
  //We use this to search location while adding new property
  Future<List<GooglePlaceModel>> serchCities(
    String text,
  ) async {
    try {
      ///
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: "(cities)",
        "language": "en"
      };

      ///************************ */

      Map<String, dynamic> apiResponse = await Api.get(
        url: Api.placeAPI,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );
      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  ///this will convert normal response to List of models so we can use it easily in code
  List<GooglePlaceModel> _buildPlaceModelList(
      Map<String, dynamic> apiResponse) {
    ///loop throuh predictions list,
    ///this will create List of GooglePlaceModel
    try {
      var filterdResult = (apiResponse["predictions"] as List).map((details) {
        String name = details['description'];
        String placeId = details['place_id'];
        ///////
        ////
        String city = getLocationComponent(details, "locality");
        String country = getLocationComponent(details, "geocode");
        String state = getLocationComponent(details, "political");

        ///
        ///
        GooglePlaceModel placeModel = GooglePlaceModel(
          city: city,
          description: name,
          placeId: placeId,
          state: state,
          country: country,
          latitude: '',
          longitude: '',
        );
        return placeModel;
      }).toList();

      return filterdResult;
    } catch (e) {
      rethrow;
    }
  }

  String getLocationComponent(Map details, String component) {
    int index = (details['types'] as List)
        .indexWhere((element) => element == component);
    if ((details['terms'] as List).length > index) {
      return (details['terms'] as List).elementAt(index)['value'];
    } else {
      return "";
    }
  }

  ///Google Place Autocomplete api will give us Place Id.
  ///We will use this place id to get Place Details
  Future<dynamic> getPlaceDetailsFromPlaceId(String placeId) async {
    Map<String, dynamic> queryParameters = {
      Api.placeApiKey: Constant.googlePlaceAPIkey,
      Api.placeid: placeId,
      "language": "en"
    };
    Map<String, dynamic> response = await Api.get(
      url: Api.placeApiDetails,
      queryParameters: queryParameters,
      useBaseUrl: false,
      useAuthToken: false,
    );

    return response['result']['geometry']['location'];
  }
}
