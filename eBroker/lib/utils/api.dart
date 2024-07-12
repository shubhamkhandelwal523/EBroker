import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/utils/Network/Interseptors/network_request_interseptor.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'constant.dart';
import 'errorFilter.dart';
import 'guestChecker.dart';
import 'hive_keys.dart';

enum StatusCode {
  badRequest, // 400
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  conflict, // 409
  internalServerError; // 500
}

extension StatusCodeExtension on StatusCode {
  int get code {
    switch (this) {
      case StatusCode.badRequest:
        return 400;
      case StatusCode.unauthorized:
        return 401;
      case StatusCode.forbidden:
        return 403;
      case StatusCode.notFound:
        return 404;
      case StatusCode.conflict:
        return 409;
      case StatusCode.internalServerError:
        return 500;
      default:
        throw Exception("Unknown status code");
    }
  }
}

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  static const String postProject = "post_project";
  static const String getProjects = "get_projects";
  static const String deleteProject = "delete_project";
  static Map<String, dynamic> headers() {
    if (GuestChecker.value == true) {
      return {};
    } else {
      String jwtToken = Hive.box(HiveKeys.userDetailsBox).get(
        HiveKeys.jwtToken,
      );
      print("JWT : $jwtToken");
      if (kDebugMode) {
        return {
          "Authorization": "Bearer $jwtToken",
        };
      }
      return {
        "Authorization": "Bearer $jwtToken",
      };
    }
  }

  //Place API
  static const String _placeApiBaseUrl =
      "https://maps.googleapis.com/maps/api/place/";
  static String placeApiKey = "key";
  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${_placeApiBaseUrl}autocomplete/json";
  static String placeApiDetails = "${_placeApiBaseUrl}details/json";
//

  static String stripeIntentAPI = "https://api.stripe.com/v1/payment_intents";
  //api fun
  static String apiLogin = "user_signup";
  static String apiUpdateProfile = "update_profile";
  static String apiGetSlider = "get_slider";
  static String apiGetCategories = "get_categories";
  static String apiGetUnit = "get_unit";
  static String apiGetProprty = "get_property";
  static String apiPostProperty = "post_property";
  static String apiUpdateProperty = "update_post_property";
  static String apiGetHouseType = "get_house_type";
  static String apiGetNotificationList = "get_notification_list";
  static String setPropertyView = "set_property_total_click";
  static String apiDeleteUser = "delete_user";
  static String paypal = "paypal";
  static String getArticles = "get_articles";
  static String getCountByCitiesCategory = "get_count_by_cities_categoris";
  static String getNearByProperties = "get_nearby_properties";
  static String addFavourite = "add_favourite";
  static String removeFavorite = "delete_favourite";
  static String getPackage = "get_package";
  static String userPurchasePackage = "user_purchase_package";
  static String deleteInquiry = "delete_inquiry";
  static String getLanguagae = "get_languages";
  static String getPaymentApiKeys = "get_payment_settings";
  static String apiGetSystemSettings = "get_system_settings";
  static String apiSetPropertyEnquiry = "set_property_inquiry";
  static String apiGetPropertyEnquiry = "get_property_inquiry";
  static String apiGetNotifications = "get_notification_list";
  static String apiRemovePostImages = "remove_post_images";
  static String apigetUserbyId = "get_user_by_id";
  static String getFavoriteProperty = "get_favourite_property";
  static String interestedUsers = "interested_users";
  static String storeAdvertisement = "store_advertisement";
  static String getLimitsOfPackage = "get_limits";
  static String getPaymentDetails = "get_payment_details";
  static String deleteAdvertisement = "delete_advertisement";
  static String updatePropertyStatus = "update_property_status";
  static String deleteChatMessage = "delete_chat_message";
  static String getOutdoorFacilites = "get_facilities";
  static String getReportReasons = "get_report_reasons";
  static String addReports = "add_reports";
  static String addEditUserInterest = "add_edit_user_interest";
  static String getUserRecommendation = "get_user_recommendation";
  static String assignPackage = "assign_package";
  static String getAppSettings = "get_app_settings";
  static String getInterestedUsers = "get_interested_users";

  ///Personalized Feed APIs NEW
  static String personalisedFields = "personalised-fields";

  ///
  static String createPaymentIntent = "createPaymentIntent";

  //Chat module apis
  static String getChatList = "get_chats";
  static String sendMessage = "send_message";
  static String getMessages = "get_messages";

  //params
  static String id = "id";
  static String mobile = "mobile";
  static String type = "type";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String error = "error";
  static String message = "message";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String userid = "userid";
  static String categoryId = "category_id";
  static String title = "title";
  static String description = "description";
  static String price = "price";
  static String titleImage = "title_image";
  static String postCreated = "post_created";
  static String galleryImages = "gallery_images";
  static String typeId = "type_id";
  static String propertyType = "property_type";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String totalView = "total_view";
  static String addedBy = "added_by";
  static String languageCode = "language_code";
  static String aboutApp = "about_app";
  static String termsAndConditions = "terms_conditions";
  static String privacyPolicy = "privacy_policy";
  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String actionType = "action_type";
  static String propertyId = "property_id";
  static String customerId = "customer_id";
  static String propertysId = "propertys_id";
  static String customersId = "customers_id";
  static String enqStatus = "status";
  static String search = "search";
  static String createdAt = "created_at";
  static String created = "created";
  static String compName = "company_name";
  static String compWebsite = "company_website";
  static String compEmail = "company_email";
  static String compAdrs = "company_address";
  static String tele1 = "company_tel1";
  static String tele2 = "company_tel2";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String property = "property";
  static String offset = "offset";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String limit = "limit";
  static String packageId = "package_id";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";

  //not in use yet
  // static String offset = "offset";
  // static String limit = "limit";
  static final Dio dio = Dio();
  static int apiRequestCount = 0;
  static int apiErrorCount = 0;

  static List<String> currentlyCallingAPI = [];

  static void initInterceptors() {
    if (kDebugMode) {
      // dio.interceptors.add(ThrottleInterceptor(minInterval: 1000));
    }

    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    //     apiRequestCount++;
    //     print("REQUEST COUNT: $apiRequestCount ${options.uri.toString()}");
    //
    //     // if (!currentlyCallingAPI.contains(options.uri.toString())) {
    //     //   currentlyCallingAPI.add(options.uri.toString());
    //     return handler.next(options);
    //     // } else {}
    //   },
    //   onResponse: (Response e, ResponseInterceptorHandler handler) {
    //     currentlyCallingAPI.remove(e.realUri.toString());
    //     return handler.next(e);
    //   },
    //   onError: (DioError e, ErrorInterceptorHandler handler) {
    //     apiErrorCount++;
    //     currentlyCallingAPI.remove(e.requestOptions.uri.toString());
    //     return handler.next(e);
    //   },
    // ));

    dio.interceptors.add(NetworkRequestInterseptor());
  }

  static Future<Map<String, dynamic>> delete(
      {required String url, bool? useAuthToken, bool? useBaseUrl}) async {
    try {
      Response response =
          await dio.delete(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              options: (useAuthToken ?? true)
                  ? Options(
                      contentType: "multipart/form-data",
                      headers: headers(),
                    )
                  : Options(
                      contentType: "multipart/form-data",
                    ));

      var resp = response.data;

      if (resp['error'] ?? false) {
        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(
      {required String url,
      required Map<String, dynamic> parameter,
      Options? options,
      bool? useAuthToken,
      bool? useBaseUrl}) async {
    try {
      final FormData formData = FormData.fromMap(
        parameter,
        ListFormat.multiCompatible,
      );

      log("Request-API:$url  and $parameter ");
      final response =
          await dio.post(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              data: formData,
              options: (useAuthToken ?? true)
                  ? Options(
                      contentType: "multipart/form-data",
                      headers: headers(),
                    )
                  : Options(
                      contentType: "multipart/form-data",
                    ));
      var resp = response.data;

      if (resp['error'] ?? false) {
        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
      {required String url,
      bool? useAuthToken,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      final response = await dio.get(
          ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
          queryParameters: queryParameters,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}

abstract class Error {
  StackTrace? stackTrace;
  DioException? error;
}

Error _handleDioError(DioException error) {
  if (error.error is SocketException) {
    return NoInternetConnectionError(error, stackTrace: error.stackTrace);
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutError(error, stackTrace: error.stackTrace);
    case DioExceptionType.badResponse:
      final int? statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode == StatusCode.badRequest.code) {
          return BadRequestError(error, stackTrace: error.stackTrace);
        } else if (statusCode == StatusCode.unauthorized.code ||
            statusCode == StatusCode.forbidden.code) {
          return UnauthorizedError(error, stackTrace: error.stackTrace);
        } else if (statusCode == StatusCode.notFound.code) {
          return NotFoundError(error, stackTrace: error.stackTrace);
        } else if (statusCode == StatusCode.conflict.code) {
          return ConflictError(error, stackTrace: error.stackTrace);
        } else if (statusCode == StatusCode.internalServerError.code) {
          return InternalServerError(error, stackTrace: error.stackTrace);
        } else {
          return UnknownError(error, stackTrace: error.stackTrace);
        }
      }
      break;
    case DioExceptionType.cancel:
      break;
    case DioExceptionType.unknown:
      return NoInternetConnectionError(error, stackTrace: error.stackTrace);
    case DioExceptionType.badCertificate:
      return BadCertificateError(error, stackTrace: error.stackTrace);
    case DioExceptionType.connectionError:
      return ConnectionError(error);
    default:
      return UnknownError(error, stackTrace: error.stackTrace);
  }
  return UnknownError(error, stackTrace: error.stackTrace);
}

class TimeoutError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  TimeoutError(this.error, {this.stackTrace});

  @override
  String toString() => "Timeout occurred while sending or receiving\n$error";
}

class BadRequestError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  BadRequestError(this.error, {this.stackTrace});

  @override
  String toString() => "Bad Request\n$error";
}

class UnauthorizedError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  UnauthorizedError(this.error, {this.stackTrace});

  @override
  String toString() => "Unauthorized\n$error";
}

class NotFoundError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  NotFoundError(this.error, {this.stackTrace});

  @override
  String toString() => "Not Found\n$error";
}

class ConflictError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  ConflictError(this.error, {this.stackTrace});

  @override
  String toString() => "Conflict\n$error";
}

class InternalServerError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  InternalServerError(this.error, {this.stackTrace});

  @override
  String toString() => "Internal Server Error\n$error";
}

class NoInternetConnectionError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  NoInternetConnectionError(this.error, {this.stackTrace});

  @override
  String toString() => "No Internet Connection";
}

class BadCertificateError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  BadCertificateError(this.error, {this.stackTrace});

  @override
  String toString() => "Bad Certificate\n$error";
}

class ConnectionError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  ConnectionError(this.error, {this.stackTrace});

  @override
  String toString() => "Connection Error\n$error";
}

class UnknownError extends Error {
  @override
  final StackTrace? stackTrace;
  @override
  final DioException error;

  UnknownError(this.error, {this.stackTrace});

  @override
  String toString() => "Unknown Error\n$error";
}
