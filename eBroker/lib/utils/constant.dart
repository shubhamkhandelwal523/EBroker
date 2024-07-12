// ignore_for_file: file_names
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../data/model/propery_filter_model.dart';

const String svgPath = 'assets/svg/';

abstract class Constant {
  static const String appName = AppSettings.applicationName;
  static const String androidPackageName = AppSettings.androidPackageName;
  static const String iOSAppId = AppSettings.iOSAppId;
  static const String playstoreURLAndroid = AppSettings.playstoreURLAndroid;
  static const String appstoreURLios = AppSettings.appstoreURLios;
  static const String shareappText = AppSettings.shareAppText;

  //backend url
  static String baseUrl = AppSettings.baseUrl;

  //Do not add anything here
  static String googlePlaceAPIkey = "";

  ///These task IDs are for load task parallel into the isolate .
  static int? languageTaskId;
  static int? appSettingTaskId;

  ///admob
  static bool isAdmobAdsEnabled = false;
  //Banner
  static String admobBannerAndroid = "";
  static String admobBannerIos = "";
  //Interstitial
  static String admobInterstitialAndroid = "";
  static String admobInterstitialIos = "";

  ////Payment gateway API keys
  static String razorpayKey = AppSettings.razorpayKey;

//paystack
  static String paystackKey = AppSettings.paystackKey;
// public key
  static String paystackCurrency = AppSettings.paystackCurrency;

  ///Paypal
  static String paypalClientId = AppSettings.paypalClientId;
  static String paypalServerKey = AppSettings.paypalServerKey; //secrete

  static bool isSandBoxMode = AppSettings.isSandBoxMode; //testing mode
  static String paypalCancelURL = AppSettings.paypalCancelURL;
  static String paypalReturnURL = AppSettings.paypalReturnURL;

  /////////////////////////////////

  // static late Session session;
  static String currencySymbol = "\u{20B9}";
  //
  static int otpTimeOutSecond = AppSettings.otpTimeOutSecond; //otp time out
  static int otpResendSecond = AppSettings.otpResendSecond; // resend otp timer
  //

  static String logintypeMobile = "1"; //always 1
  //
  static String maintenanceMode = "0"; //OFF
  static bool isUserDeactivated = false;
  //
  static String valSellBuy = "0";
  static String valRent = "1";
  //
  static int loadLimit = AppSettings.apiDataLoadLimit;

  static const String defaultCountryCode = AppSettings.defaultCountryCode;

  ///This maxCategoryLength is for show limited number of categories and show "More" button,
  ///You have to set less than [loadLimit] constant

  static const int maxCategoryLength =
      AppSettings.maxCategoryShowLengthInHomeScreen;

  //

  ///Lottie animation
  static const String progressLottieFile = AppSettings.progressLottieFile;
  static const String progressLottieFileWhite = AppSettings
      .progressLottieFileWhite; //When there is dark background and you want to show progress so it will be used

  static const String maintenanceModeLottieFile =
      AppSettings.maintenanceModeLottieFile;

  ///

  ///Put your loading json file in assets/lottie/ folder
  static const bool useLottieProgress = AppSettings
      .useLottieProgress; //if you don't want to use lottie progress then set it to false'

  static const String notificationChannel = AppSettings.notificationChannel;
  static int uploadImageQuality = AppSettings.uploadImageQuality; //0 to 100

  static String? subscriptionPackageId;
  static PropertyFilterModel? propertyFilter;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String typeRent = "rent";
  static String generalNotification = "0";
  static String enquiryNotification = "1";
  static String notificationPropertyEnquiry = "property_inquiry";
  static String notificationDefault = "default";
  //0: last_week   1: yesterday
  static String filterLastWeek = "0";
  static String filterYesterday = "1";
  static String filterAll = "";
//

  //

  static List<int> interestedPropertyIds = [];
  static List<int> favoritePropertyList = [];

  static Map<dynamic, dynamic> addProperty = {};

  static Map<SystemSetting, String> systemSettingKeys = {
    SystemSetting.currencySymball: "currency_symbol",
    SystemSetting.privacyPolicy: "privacy_policy",
    SystemSetting.contactUs: "",
    SystemSetting.maintenanceMode: "maintenance_mode",
    SystemSetting.termsConditions: "terms_conditions",
    SystemSetting.subscription: "subscription",
    SystemSetting.language: "languages",
    SystemSetting.defaultLanguage: "default_language",
    SystemSetting.forceUpdate: "force_update",
    SystemSetting.androidVersion: "android_version",
    SystemSetting.numberWithSuffix: "number_with_suffix",
    SystemSetting.iosVersion: "ios_version"
  };

  ///This is limit of minimum chat messages load count , make sure you set it grater than 25;
  static int minChatMessages = 35;

  //assets/riveAnimations
  static const riveAnimation = "rive_animation.riv";

  static bool showExperimentals = true;
  //Don't touch this settings
  static bool isUpdateAvailable = false;
  static String newVersionNumber = "";
  static bool isNumberWithSuffix = false;

  static List<Type> hydratedCubits = [
    FetchCategoryCubit,
    FetchCityCategoryCubit,
    FetchPromotedPropertiesCubit
  ];

//do not change
  static String keysDecryptionPasswordRSA = '''-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCozdEM159wmJo4
7L2gDx22jTNQfHL94HqHLikJXkimhv1IUihVFlEdudaX+z1PNtcH5A8vLCDSL5RL
kuCkAsJP8W95556Wxcqsxd6KUjg4xRsmLfwVx3eNQ11mMxn9qc3+InHoLj/HPhRR
aRSfKy/G0ZDM5/78O1nXpwLo0u/mnyQnYt/PexfKCFaqosGWErKXUNWLAeFVkhYg
wSIquGsB4VR3eOOADBQq+sEr4zyuZFCcZXVI0JqdUd3h/Ds0tTymsG1RB0+0VMK9
XqdtSI95iDlI4qE2BIkL/vnwJCHjn3jymr2w2kzLzeOSafisl8g2AgUQIUAvyc+5
DLP/VcZlAgMBAAECggEABwQ1EV5WECv7qcGSDo409eKlHyOTyQs0tJvof0KbbPaV
SRVce/rsk2UnLxPgRBkQs5Euc2TCFtJ89241vFjUAwF+A3hrQ7OZfXh6YU/9FRkA
9vji2Unm+tNxv/7Vm1EHUQNVWOlb4819XTaWXEOt3aBWLzo2blK45N6aNPDC9thA
Xm7P4X1UKs0IYWVxnQ9OMtSQEydKrd3hesqEoWTZNwDRQhXGfR/ctxeZvbUrQY/s
kmnacC17QxG94niiaE9p+45hS0GeArUPhxsIKJ0R1PoGJh64aVwDxr8B5q5Xaps6
5BZVGaneXrK3S96IJDqHchLObc/BrD2YwKYziDDIyQKBgQC8NXDLQwbNpRDoh649
n3doABcuC0uSijiNn94BGF9ZMmY27BfvxS2uekVtZmXPVeVj9nncMNL3RO5xLJPz
UXJdnJPq/oEY1gsiDjd7QMIr7xlzvGkt5ngq3vDxVnRN/Zz8GrNIjZtvgDuNTVuw
S20RWw9GTM36wp+nRR8SXch6aQKBgQDlmxQgCE2ykEzghUFnLsHkNsfbiqRBq3Jn
imsQ2nMTP+2+BMMQgwmEJpqDOWEcvTLAaoS7KkbZ+uOg8IhQkfL4sqnVJF3bjiR0
GaV3x7KuL2QJ6TXS0JPFfI5KOaq+bAGsZ6TPgR2L7cBe0EhV80rOexGFs0bqLOoJ
CqPBr+6UnQKBgQCFmgH5qBjaPkSkbDxZ7itbHkVWIBqDaa7/ie6UJHL65HX+otXT
FMt6wb0rDbdT2Qu/TCXxEo+Pi9UfbZ+Q584heZbfB88ojDjW8fScf7nWaiJNMAAR
3zqKZDvxdYeWHWQk6ec+p5chLYwYoENoAALqgRN0uey2BxZCLSUDaqN3kQKBgQCh
XZMQTCWnCCkvZheoF8FmzWU6kz6LdJ3rzOkgKBbWAYjpkdkxwpYujR7seKgalZGU
j4gHLlgrHFtcIY/76Ab16ELZrDxWcJiIC/oxq2SVbHMHUCJmrfYcxkQOQGcSez/V
1eWLfDeyvv4C5Kjh1yHM6ctPxsZhD/3PKu4Z0rZ/NQKBgDuQfusBa4xlb4VpBqtu
x+vyqlTpCOmdRwpk9XkcfR0/gFef5i2uass0r5ia7RQBHEeHpIRDcxJQ1HmDtUVA
VuZQHUHFms2+Jh5UHp5JjrsSt3DYSva7iNe8xkqeE2sgS1g1wWJRR73rJX3FtIXd
modM8h9DRzp9OaAJqxfP960q
-----END PRIVATE KEY-----''';

  //Demo mode settings
  static bool isDemoModeOn = false;
  static String demoCountryCode = "91";
  static String demoMobileNumber = "1234567890";
  static String demoFirebaseID = "6a1Zdl2TxORQGbCazj4XDGfgBBG3";
  static String demoModeOTP = "123456";

  static bool adaptThemeColorSvg = true;

  static const String terminalLogMode = "debug";
}
