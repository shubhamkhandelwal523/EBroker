import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../settings.dart';

class CacheData {
  final Connectivity _connectivity = Connectivity();

  Future<void> getData<T>(
      {required bool forceRefresh,
      required VoidCallback onProgress,
      required Future<T> Function() onNetworkRequest,
      required T Function() onOfflineData,
      required Function(T data) onSuccess,
      required bool hasData,
      int? delay}) async {
    if (forceRefresh != true) {
      if (hasData) {
        await Future.delayed(
            Duration(seconds: delay ?? AppSettings.hiddenAPIProcessDelay));
      } else {
        onProgress.call();
      }
    } else {
      onProgress.call();
    }
    if (forceRefresh) {
      T result = await onNetworkRequest.call();
      onSuccess.call(result);
    } else {
      if (!hasData) {
        T result = await onNetworkRequest.call();
        onSuccess.call(result);
      } else {
        if (await _hasInternet()) {
          T result = await onNetworkRequest.call();
          onSuccess.call(result);
        } else {
          T result = onOfflineData.call();
          onSuccess.call(result);
        }
      }
    }
  }

  Future<bool> _hasInternet() async {
    List<ConnectivityResult> connectionResult =
        await _connectivity.checkConnectivity();
    return !connectionResult.contains(ConnectivityResult.none);
  }
}
