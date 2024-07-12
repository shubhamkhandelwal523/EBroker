// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/utils/api.dart';

import '../../../exports/main_export.dart';
import '../../../utils/encryption/rsa.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());

      Map<String, dynamic> result = await Api.get(
        url: Api.getPaymentApiKeys,
        queryParameters: {},
      );

      List data = (result['data'] as List);
      var razorpayKey = _getDataFromKey(data, "razor_key");
      var razorPaySecret = _getDataFromKey(data, "razor_secret");
      var paystackPublicKey = _getDataFromKey(data, "paystack_public_key");
      var paystackSecretKey = _getDataFromKey(data, "paystack_secret_key");
      var paystackCurrency = _getDataFromKey(data, "paystack_currency");
      var stripeCurrency = _getDataFromKey(data, "stripe_currency");
      var stripePublishableKey =
          _getDataFromKey(data, "stripe_publishable_key");
      var stripeSecretKey = _getDataFromKey(data, "stripe_secret_key");
      String enabledGatway = "";

      if (_getDataFromKey(data, "paypal_gateway") == "1") {
        enabledGatway = "paypal";
      } else if (_getDataFromKey(data, "razorpay_gateway") == "1") {
        enabledGatway = "razorpay";
      } else if (_getDataFromKey(data, "paystack_gateway") == "1") {
        enabledGatway = "paystack";
      } else if (_getDataFromKey(data, "stripe_gateway") == "1") {
        enabledGatway = "stripe";
      }

      emit(GetApiKeysSuccess(
          razorPayKey: razorpayKey ?? "",
          enabledPaymentGatway: enabledGatway,
          razorPaySecret: razorPaySecret ?? "",
          paystackPublicKey: paystackPublicKey ?? "",
          paystackCurrency: paystackCurrency ?? "",
          paystackSecret: paystackSecretKey ?? "",
          stripeCurrency: stripeCurrency ?? "",
          stripePublishableKey: stripePublishableKey ?? "",
          stripeSecretKey: stripeSecretKey ?? ""));
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  void setAPIKeys() {
    //setKeys
    if (state is GetApiKeysSuccess) {
      GetApiKeysSuccess _state = (state as GetApiKeysSuccess);

      AppSettings.paystackKey = _state.paystackPublicKey;
      AppSettings.razorpayKey = _state.razorPayKey;
      AppSettings.enabledPaymentGatway = _state.enabledPaymentGatway;
      AppSettings.paystackCurrency = _state.paystackCurrency;
      AppSettings.stripeCurrency = _state.stripeCurrency;
      AppSettings.stripePublishableKey = _state.stripePublishableKey;
      AppSettings.stripeSecrateKey = RSAEncryption().decrypt(
        privateKey: Constant.keysDecryptionPasswordRSA,
        encryptedData: _state.stripeSecretKey,
      );
      paystack.init(AppSettings.paystackKey);
    }
    if (state is GetApiKeysFail) {
      log((state as GetApiKeysFail).error.toString(), name: "API KEY FAIL");
    }
  }

  dynamic _getDataFromKey(List data, String key) {
    try {
      return data.where((element) => element['type'] == key).first['data'];
    } catch (e) {
      if (e.toString().contains("Bad state")) {
        throw "The key>>> $key is not comming from API";
      }
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  final String razorPayKey;
  final String razorPaySecret;
  final String paystackPublicKey;
  final String paystackSecret;
  final String paystackCurrency;
  final String enabledPaymentGatway;
  final String stripeCurrency;
  final String stripePublishableKey;
  final String stripeSecretKey;
  GetApiKeysSuccess({
    required this.razorPayKey,
    required this.razorPaySecret,
    required this.paystackPublicKey,
    required this.paystackSecret,
    required this.paystackCurrency,
    required this.enabledPaymentGatway,
    required this.stripeCurrency,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
  });

  @override
  String toString() {
    return 'GetApiKeysSuccess(razorPayKey: $razorPayKey, razorPaySecret: $razorPaySecret, paystackPublicKey: $paystackPublicKey, paystackSecret: $paystackSecret, paystackCurrency: $paystackCurrency, enabledPaymentGatway: $enabledPaymentGatway, stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey)';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;
  GetApiKeysFail(this.error);
}
