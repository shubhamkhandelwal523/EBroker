import 'dart:io';

import 'package:ebroker/app/app.dart';
import 'package:ebroker/app/default_app_setting.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import '../../constant.dart';
import '../../helper_utils.dart';
import '../../hive_utils.dart';
import '../../ui_utils.dart';

class Paystack extends Payment {
  SubscriptionPackageModel? _model;

  PaystackPlugin paystackPlugin = PaystackPlugin();

  void init(String publicKey) {
    paystackPlugin.initialize(publicKey: publicKey);
  }

  @override
  void onEvent(
      BuildContext context, covariant PaymentStatus currentStatus) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }

  @override
  void pay(BuildContext context) async {
    if (_model == null) {
      throw "Please setPackage";
    }
    isPaymentGatewayOpen = true;
    Charge paystackCharge = Charge()
      ..amount = (_model!.price! * 100).toInt()
      ..email = HiveUtils.getUserDetails().email
      ..currency = Constant.paystackCurrency
      ..reference = generateReference(HiveUtils.getUserDetails().email!)
      ..putMetaData("username", HiveUtils.getUserDetails().name)
      ..putMetaData("package_id", _model!.id)
      ..putMetaData("user_id", HiveUtils.getUserId());

    CheckoutResponse checkoutResponse = await paystackPlugin.checkout(context,
        logo: SizedBox(
            height: 50,
            width: 50,
            child: LoadAppSettings().svg(
              appSettings.placeholderLogo!,
            )),
        charge: paystackCharge,
        method: CheckoutMethod.card);
    isPaymentGatewayOpen = false;
    if (checkoutResponse.status) {
      if (checkoutResponse.verify) {
        Future.delayed(
          Duration.zero,
          () async {
            emit(Success(message: "Success"));
            // await _purchase(context);
          },
        );
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.translate(context, "purchaseFailed"));
        },
      );
    }
  }

  String generateReference(String email) {
    late String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else if (Platform.isAndroid) {
      platform = 'A';
    }
    String reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  @override
  Payment setPackage(SubscriptionPackageModel modal) {
    _model = modal;
    return this;
  }
}
