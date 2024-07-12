import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/development/debugger.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class NetworkRequestInterseptor extends Interceptor {
  int totalAPICallTimes = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Map<String, dynamic> map = {};

    Debugger.addRequest(ApiRequest(
      ValueKey(options.hashCode),
      options.path,
      {},
    ));
    if (options.data != null) {
      map = (Map.fromEntries((options.data ?? {} as FormData).fields)
        ..addEntries(Iterable.castFrom((options.data as FormData).files)));
    }
    log("${options.path} : ${options.queryParameters}", name: "Request-API");

    // totalAPICallTimes++;
    // ({
    //   "URL": options.path,
    //   "Parameters": options.method == "POST" ? map : options.queryParameters,
    //   "Method": options.method,
    //   "_total_api_calls": totalAPICallTimes
    // }).mlog("Request-API");
    // try {
    //   String prettyJsonEncode = _prettyJsonEncode(options.data);
    //   print("ENCODED ${json.encode(options.data)}");
    //   print(prettyJsonEncode);
    // } catch (e) {
    //   print("INTERSEPTOR ERROR $e");
    // }

    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    ({
      "URL": err.response?.requestOptions.path ?? "",
      "Type": err.type,
      "Error": err.error,
      "Message": err.message,
    }).mlog("API-Error");

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ({
      "URL": response.requestOptions.path,
      "Method": response.requestOptions.method,
      "status": response.statusCode,
      "statusMessage": response.statusMessage,
      "response": response.data,
    }).mlog("Response-API");
    print("RESPONSE HASH CODE ${response.requestOptions.hashCode}");
    Debugger.updateRequest(
        requestHash: response.requestOptions.hashCode,
        statusCode: response!.statusCode!,
        response: response.data);
    handler.next(response);
  }
}

String _prettyJsonEncode(dynamic data) {
  try {
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);
    return jsonString;
  } catch (e) {
    return data.toString();
  }
}
