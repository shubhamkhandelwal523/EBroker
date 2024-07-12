// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../data/model/subscription_pacakage_model.dart';

///THIS IS MAIN ABSTRACTION FOR [Payment].
///Inherit Payment to add new payment gateway , like class GooglePay extends Payment{}
///
///This payment gateway code is written by Muzammil Sumra
abstract class Payment {
  ///This will open paymentgatway
  void pay(BuildContext context);

  ///This is status listener for payment
  final ValueNotifier<PaymentStatus> _stateListener = ValueNotifier(INITIAL());

  ///This abstraction will call when status change
  void onEvent(BuildContext context, covariant PaymentStatus currentStatus);

  ///This will change payment status
  @protected
  void emit(PaymentStatus status) {
    _stateListener.value = status;
  }

  ///This is internal method to listen status for payment
  @nonVirtual
  void listen(void Function(PaymentStatus status) listener) {
    _stateListener.addListener(() {
      listener.call(_stateListener.value);
    });
  }

  ///This will set current subscription modal .
  Payment setPackage(SubscriptionPackageModel modal);
}

bool isPaymentGatewayOpen = false;

///THESE STATUS ARE PAYMENT STATUS
abstract class PaymentStatus {}

class Success extends PaymentStatus {
  final String message;
  final Map? extraData;
  Success({
    required this.message,
    this.extraData,
  });
}

class Failure extends PaymentStatus {
  final String message;
  final Map? extraData;
  Failure({
    required this.message,
    this.extraData,
  });
}

class INITIAL extends PaymentStatus {}
