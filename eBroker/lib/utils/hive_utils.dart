import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../app/app_theme.dart';
import '../app/routes.dart';
import '../data/model/user_model.dart';
import 'helper_utils.dart';
import 'hive_keys.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static initBoxes() async {
    await Hive.initFlutter();

    await Hive.openBox(HiveKeys.userDetailsBox);
    await Hive.openBox(HiveKeys.authBox);
    await Hive.openBox(HiveKeys.languageBox);
    await Hive.openBox(HiveKeys.themeBox);
    await Hive.openBox(HiveKeys.svgBox);
    await Hive.openBox(HiveKeys.themeColorBox);
  }

  static String? getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void dontShowChooseLocationDialoge() {
    Hive.box(HiveKeys.userDetailsBox).put("showChooseLocationDialoge", false);
  }

  static bool isGuest() {
    return Hive.box(HiveKeys.userDetailsBox).get("isGuest") ?? true;
  }

  static void setAppThemeSetting(Map<String, dynamic> data) {
    Hive.box(HiveKeys.themeColorBox).putAll(data);
  }

  static Map<String, dynamic> getAppThemeSettings() {
    return Map<String, dynamic>.from(Hive.box(HiveKeys.themeColorBox).toMap());
  }

  static void setIsNotGuest() {
    Hive.box(HiveKeys.userDetailsBox).put("isGuest", false);
  }

  static void setIsGuest() {
    Hive.box(HiveKeys.userDetailsBox).put("isGuest", true);
  }

  static bool isShowChooseLocationDialoge() {
    var value = Hive.box(HiveKeys.userDetailsBox).get(
      "showChooseLocationDialoge",
    );

    if (value == null) {
      return true;
    }
    return false;
  }

  static String? getUserId() {
    if (Hive.box(HiveKeys.userDetailsBox).get("id") == null) {
      return null;
    }
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static AppTheme getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == "light") {
      return AppTheme.light;
    }
    if (current == "dark") {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static dynamic getCountryCode() {
    return Hive.box(HiveKeys.userDetailsBox).toMap()['countryCode'];
  }

  static void setProfileNotCompleted() async {
    await Hive.box(HiveKeys.userDetailsBox)
        .put(HiveKeys.isProfileCompleted, false);
  }

  static setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = "light";
    } else {
      newTheme = "dark";
    }
    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  static LoginType getUserLoginType() {
    return LoginType.values.firstWhere((element) =>
        element.name == Hive.box(HiveKeys.userDetailsBox).get("type"));
  }

  static dynamic getCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  static dynamic getCityPlaceId() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.cityPlaceId);
  }

  static dynamic getStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  static dynamic getCountryName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
        Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()));
  }

  static void setUserIsAuthenticated() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
  }

  static setUserIsNotAuthenticated() async {
    await Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
  }

  static Future<void> setUserIsNotNew() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static bool isLocationFilled() {
    var city = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
    var state = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
    var country = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);

    if (city == null && state == null && country == null) {
      return false;
    } else {
      return true;
    }
  }

  static void setLocation(
      {required String city,
      required String state,
      required double? latitude,
      required double? longitude,
      required String country,
      required String placeId}) async {
    try {
      // await Hive.box(HiveKeys.userDetailsBox).putAll({
      //   HiveKeys.city: city,
      //   HiveKeys.stateKey: state,
      //   HiveKeys.countryKey: country,
      //   HiveKeys.cityPlaceId: placeId
      // });

      await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.city, city);
      await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.stateKey, state);
      await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.countryKey, country);

      if (latitude != null) {
        await Hive.box(HiveKeys.userDetailsBox)
            .put(HiveKeys.latitude, latitude);
      }
      if (longitude != null) {
        await Hive.box(HiveKeys.userDetailsBox)
            .put(HiveKeys.longitude, longitude);
      }
    } catch (e) {
      e.toString().log("issue here is");
    }
  }

  static void clearLocation() async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: null,
      HiveKeys.stateKey: null,
      HiveKeys.countryKey: null,
    });
  }

  static Future<bool> storeLanguage(
    dynamic data,
  ) async {
    Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, data);
    // ..put("language", data);
    return true;
  }

  static dynamic getLanguage() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }

  // static s(context) {
  //   HiveUtils.setUserIsNotAuthenticated();
  //   HiveUtils.clear();

  //   Future.delayed(
  //     Duration.zero,
  //     () {
  //       HelperUtils.killPreviousPages(context, Routes.login, {});
  //     },
  //   );
  // }

  @visibleForTesting
  static Future<void> setUserIsNew() {
    //Only testing purpose // not in production
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    //log(Hive.box(HiveKeys.authBox).toMap().toString());
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static logoutUser(context,
      {required VoidCallback onLogout, bool? isRedirect}) async {
    await setUserIsNotAuthenticated();
    await Hive.box(HiveKeys.userDetailsBox).clear();
    onLogout.call();
    HiveUtils.setUserIsNotAuthenticated();
    HiveUtils.clear();

    Future.delayed(
      Duration.zero,
      () {
        if (isRedirect ?? true) {
          HelperUtils.killPreviousPages(context, Routes.login, {});
        }
      },
    );
  }

  static void clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
  }
}
