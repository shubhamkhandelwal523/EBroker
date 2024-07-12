import 'package:ebroker/utils/payment/lib/payment.dart';

///This is Modal to store Payment gatway with its key
class Gatway {
  final String key;
  final Payment instance;
  Gatway({
    required this.key,
    required this.instance,
  });
}
