import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../helper/custom_exception.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  bool isAuthenticated = false;

  Authenticated(this.isAuthenticated);
}

class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure(this.errorMessage);
}

class AuthCubit extends Cubit<AuthState> {
  //late String name, email, profile, address;
  AuthCubit() : super(AuthInitial()) {
    // checkIsAuthenticated();
  }
  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {
      //setUserData();
      emit(Authenticated(true));
    } else {
      emit(Unauthenticated());
    }
  }

  Future updateFCM(BuildContext context) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      await Api.post(
        url: Api.apiUpdateProfile,
        parameter: {
          Api.userid: HiveUtils.getUserId(),
          "fcm_id": token,
        },
      );
    } catch (e) {}
  }

  Future<Map<String, dynamic>> updateUserData(BuildContext context,
      {String? name,
      String? email,
      String? address,
      File? fileUserimg,
      String? fcmToken,
      String? notification,
      double? latitude,
      double? longitude,
      String? city,
      String? state,
      String? phone,
      String? country}) async {
    Map<String, dynamic> parameters = {
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      Api.userid: HiveUtils.getUserId(),
      "mobile": phone,
      Api.notification: notification,
      "city": city ?? HiveUtils.getCityName(),
      "state": state ?? HiveUtils.getStateName(),
      "country": country ?? HiveUtils.getCountryName(),
    };
    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }

    if (latitude != null && longitude != null) {
      parameters.addAll({"latitude": latitude, "longitude": longitude});
    }

    var response =
        await Api.post(url: Api.apiUpdateProfile, parameter: parameters);

    if (!response[Api.error]) {
      HiveUtils.setUserData(response['data']);
      checkIsAuthenticated();
    } else {
      throw CustomException(response[Api.message]);
    }
    return response;
  }

  void getUserById(
    BuildContext context,
  ) async {
    Map<String, String> body = {Api.userid: HiveUtils.getUserId().toString()};

    var response = await HelperUtils.sendApiRequest(
        Api.apigetUserbyId, body, false, context);

    Future.delayed(
      Duration.zero,
      () async {
        response = await HelperUtils.sendApiRequest(
            Api.apiUpdateProfile, body, true, context);
      },
    );

    var getdata = json.decode(response);

    if (getdata != null) {
      if (!getdata[Api.error]) {
        // Constant.session.setUserData(getdata['data'], "");
        checkIsAuthenticated();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }
  }

  void signOut(BuildContext context) async {
    if ((state as Authenticated).isAuthenticated) {
      HiveUtils.logoutUser(context, onLogout: () {});
      emit(Unauthenticated());
    }
  }
}
