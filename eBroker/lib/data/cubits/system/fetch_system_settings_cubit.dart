import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:ebroker/utils/encryption/rsa.dart';

import '../../model/system_settings_model.dart';
import '../../repositories/system_repository.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final Map settings;
  FetchSystemSettingsSuccess({
    required this.settings,
  });

  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
    };
  }

  factory FetchSystemSettingsSuccess.fromMap(Map<String, dynamic> map) {
    return FetchSystemSettingsSuccess(
      settings: map['settings'] as Map,
    );
  }
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState>
    with HydratedMixin {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial()) {
    hydrate();
  }
  final SystemRepository _systemRepository = SystemRepository();
  Future<void> fetchSettings(
      {required bool isAnonymouse, bool? forceRefresh}) async {
    try {
      await CacheData().getData(
          forceRefresh: forceRefresh == true,
          delay: 0,
          onProgress: () {
            emit(FetchSystemSettingsInProgress());
          },
          onNetworkRequest: () async {
            try {
              Map settings = await _systemRepository.fetchSystemSettings(
                isAnonymouse: isAnonymouse,
              );
              log("FOUND NEW SETTINGS $settings");
              return settings;
            } catch (e) {
              rethrow;
            }
          },
          onOfflineData: () {
            return (state as FetchSystemSettingsSuccess).settings;
          },
          onSuccess: (Map<dynamic, dynamic>? data) {
            if (data == null) return;
            Constant.currencySymbol =
                _getSetting(data, SystemSetting.currencySymball);
            Constant.googlePlaceAPIkey = RSAEncryption().decrypt(
                privateKey: Constant.keysDecryptionPasswordRSA,
                encryptedData: data['data']['place_api_key']);
            Constant.isAdmobAdsEnabled =
                (data['data']['show_admob_ads'] == "1");
            Constant.adaptThemeColorSvg = (data['data']['svg_clr'] == "1");
            Constant.admobBannerAndroid =
                data['data']?['android_banner_ad_id'] ?? "";
            Constant.admobBannerIos = data['data']?['ios_banner_ad_id'] ?? "";

            Constant.admobInterstitialAndroid =
                data['data']?['android_interstitial_ad_id'] ?? "";
            Constant.admobInterstitialIos =
                data['data']?['ios_interstitial_ad_id'] ?? "";

            emit(FetchSystemSettingsSuccess(settings: data));
          },
          hasData: (state is FetchSystemSettingsSuccess));
    } catch (e, st) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  dynamic getSetting(SystemSetting selected) {
    if (state is FetchSystemSettingsSuccess) {
      Map settings = (state as FetchSystemSettingsSuccess).settings['data'];

      if (selected == SystemSetting.language) {
        return settings['languages'];
      }

      if (selected == SystemSetting.demoMode) {
        if (settings.containsKey("demo_mode")) {
          return settings['demo_mode'];
        } else {
          return false;
        }
      }

      /// where selected is equals to type
      var selectedSettingData =
          (settings[Constant.systemSettingKeys[selected]]);

      return selectedSettingData;
    }
  }

  Map getRawSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings['data'];
    }
    return {};
  }

  dynamic _getSetting(Map settings, SystemSetting selected) {
    var selectedSettingData =
        settings['data'][Constant.systemSettingKeys[selected]];

    return selectedSettingData;
  }

  @override
  FetchSystemSettingsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchSystemSettingsSuccess") {
        FetchSystemSettingsSuccess fetchSystemSettingsSuccess =
            FetchSystemSettingsSuccess.fromMap(json);

        return fetchSystemSettingsSuccess;
      }
    } catch (e, st) {}

    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchSystemSettingsState state) {
    try {
      if (state is FetchSystemSettingsSuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchSystemSettingsSuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
