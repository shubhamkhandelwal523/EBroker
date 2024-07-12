import 'package:connectivity_plus/connectivity_plus.dart';

class CheckInternet {
  CheckInternet();
  static Connectivity connectivity = Connectivity();
  static Future<void> check(
      {required Function() onInternet, Function()? onNoInternet}) async {
    List<ConnectivityResult> connectivityResult =
        await connectivity.checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) {
      onNoInternet?.call();
    } else {
      onInternet.call();
    }
  }
}
