//For localization of app

import 'dart:convert';

import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;

  //it will hold key of text and it's values in given language
  late Map<String, String> _localizedValues;

  AppLocalization(this.locale);

  //to access app-localization instance any where in app using context
  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  //to load json(language) from assets
  Future loadJson() async {
    // String languageJsonName = locale.countryCode == null
    //     ? locale.languageCode
    //     : "${locale.languageCode}-${locale.countryCode}";
    String jsonStringValues =
        await rootBundle.loadString('assets/languages/template.json');
    // value from root-bundle will be encoded string
    Map<String, dynamic> mappedJson = {};

    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()['data'] == null) {
      mappedJson = json.decode(jsonStringValues);
    } else {
      mappedJson = Map<String, dynamic>.from(HiveUtils.getLanguage()['data']);
    }
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  //to get translated value of given title/key
  String? getTranslatedValues(String? key) {
    return _localizedValues[key!];
  }

  //need to declare custom delegate
  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

//Custom app delegate
class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  //providing all supported languages
  @override
  bool isSupported(Locale locale) {
    //
    return true;
  }

  //load languageCode.json files
  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}
