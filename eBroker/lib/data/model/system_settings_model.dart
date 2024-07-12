enum SystemSetting {
  maintenanceMode,
  currencySymball,
  subscription,
  privacyPolicy,
  termsConditions,
  contactUs,
  language,
  defaultLanguage,
  forceUpdate,
  androidVersion,
  numberWithSuffix,
  iosVersion,
  demoMode
}




















  /// we made this method because from our api all data comes in {'type':"<setting>",'data':"demo data"} this formate so we have list of these data and instead of create different methods and parse in it we have made enum and checking where condition in list
  // T getSetting<T>(SystemSetting setting) {
  //   if (setting == SystemSetting.subscription) {
  //     if (subscription == true) {
  //       return package as T;
  //     } else {
  //       return null as T;
  //     }
  //   }
  //   return data!
  //       .where((Data element) =>
  //           element.type == Constant.systemSettingKey[setting])
  //       .toList()[0] as T;
  // }