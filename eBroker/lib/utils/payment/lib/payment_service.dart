import 'package:ebroker/utils/payment/lib/gatway.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/model/subscription_pacakage_model.dart';

///This is wrapper class to execute Payment inherited classes.
///We need to call this in code to make payment.
///
class PaymentService {
  ///
  BuildContext? _context;
  SubscriptionPackageModel? _modal;
  String? _targetGatwayKey;
  Gatway? _currentGatway;

  ///
  ///This will set current enabled payment key
  set targetGatwayKey(String key) {
    _targetGatwayKey = key;
  }

  ///This will set package
  PaymentService setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
  }

  ///This will set build context to show Ui related modals and messages
  PaymentService setContext(BuildContext context) {
    _context = context;

    if (_currentGatway == null) {
      throw "Current gatway not been assigned";
    }

    ///We have attached Payment listener to setContext to reduce more boilarplate code and more efficency
    _currentGatway!.instance.listen((PaymentStatus status) {
      ///This mehtod will be called when we call emit() in code. on emit will call listen(), listen will call onEvent
      _currentGatway!.instance.onEvent(context, status);
    });

    return this;
  }

  ///This methods is to list available payment gatways
  PaymentService attachedGatways(List<Gatway> paymentGatways) {
    if (_targetGatwayKey == null) {
      throw "Please set target gatway key";
    }
    for (Gatway gateway in paymentGatways) {
      if (gateway.key == _targetGatwayKey) {
        _currentGatway = gateway;
      }
    }
    return this;
  }

  ///This will open payment gatway
  void pay() async {
    if (_context == null) {
      throw "Please call setContext before use this";
    }
    if (_modal == null) {
      throw "Please call setPackage";
    }
    if (_currentGatway == null) {
      throw "please attach gatways";
    }

    ///This will set package from parent and pay
    _currentGatway!.instance.setPackage(_modal!).pay(_context!);
  }
}
