import 'dart:io';

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize bannerSize;

  const BannerAdWidget({Key? key, this.bannerSize = AdSize.largeBanner})
      : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  late String adUnitId;

  /// Loads a banner ad.
  void loadAd() {
    if (Constant.isAdmobAdsEnabled == false) {
      return;
    }
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: widget.bannerSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {});
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          _bannerAd = null;
          setState(() {});

          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    adUnitId = Platform.isAndroid
        ? Constant.admobBannerAndroid
        : Constant.admobBannerIos;
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_bannerAd != null)
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }
}
