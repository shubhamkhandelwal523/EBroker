import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// class InterstitialAdManager {
//   InterstitialAd? _interstitialAd;
//
//   void load({VoidCallback? onAdLoad}) {
//     InterstitialAd.load(
//         adUnitId: "",
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//           // Called when an ad is successfully received.
//           onAdLoaded: (InterstitialAd ad) {
//             log('$ad loaded.');
//             onAdLoad?.call();
//             // Keep a reference to the ad so you can show it later.
//             _interstitialAd = ad;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (LoadAdError error) {
//             log('InterstitialAd failed to load: $error');
//           },
//         ));
//   }
//
//   Future<void> show() async {
//     if (_interstitialAd != null) {
//       await _interstitialAd!.show();
//     }
//   }
// }
// import 'package:flutter/foundation.dart';

// class InterstitialAdManager {
//   InterstitialAd? _interstitialAd;
//   int _adCount = 0;
//
//   void load({VoidCallback? onAdLoad}) {
//     InterstitialAd.load(
//       adUnitId: "",
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           print('$ad loaded.');
//           onAdLoad?.call();
//           _interstitialAd = ad;
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('InterstitialAd failed to load: $error');
//         },
//       ),
//     );
//   }
//
//   Future<void> show() async {
//     if (_interstitialAd != null) {
//       log("SHOWING HEHE");
//       await _interstitialAd!.show();
//       _adCount++;
//       if (_adCount == 4) {
//         _adCount = 0; // Reset the count after showing the ad
//       }
//     }
//   }
// }
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constant.dart';

class InterstitialAdManager {
  static int _adCount = 0;
  static InterstitialAd? _interstitialAd;

  void load({VoidCallback? onAdLoad}) {
    if (Constant.isAdmobAdsEnabled == false) {
      return;
    }

    InterstitialAd.load(
      adUnitId: (Platform.isAndroid
          ? Constant.admobInterstitialAndroid
          : Constant.admobInterstitialIos),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded.');
          onAdLoad?.call();
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> show() async {
    if (Constant.isAdmobAdsEnabled == false) {
      return;
    }
    if (_interstitialAd != null) {
      _adCount++;
      if (_adCount == 4) {
        await _interstitialAd!.show();

        _adCount = 0; // Reset the count after showing the ad
      }
    }
  }
}
