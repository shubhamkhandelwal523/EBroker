import 'package:ebroker/utils/payment/gatways/razorpay_pay.dart';
import 'package:ebroker/utils/payment/lib/gatway.dart';

import '../gatways/paypal_pay.dart';
import '../gatways/paystack_pay.dart';
import '../gatways/stripe_pay.dart';

Paystack paystack = Paystack();

List<Gatway> gatways = [
  Gatway(key: "stripe", instance: Stripe()),
  Gatway(key: "paypal", instance: Paypal()),
  Gatway(key: "paystack", instance: paystack),
  Gatway(key: "razorpay", instance: RazorpayPay()),
];
