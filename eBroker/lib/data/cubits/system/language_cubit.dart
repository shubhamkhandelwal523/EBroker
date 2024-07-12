// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../utils/hive_keys.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  final bool isRTL;
  final dynamic languageCode;

  LanguageLoader(this.languageCode, {required this.isRTL});
}

class LanguageLoadFail extends LanguageState {
  final dynamic error;
  LanguageLoadFail({required this.error});
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    var language =
        Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
    if (language != null) {
      emit(LanguageLoader(language['code'], isRTL: language['isRTL'] ?? false));
    } else {
      emit(LanguageLoader("en", isRTL: false));
    }
  }

  dynamic currentLanguageCode() {
    return Hive.box(HiveKeys.languageBox)
        .get(HiveKeys.currentLanguageKey)['code'];
  }
}
