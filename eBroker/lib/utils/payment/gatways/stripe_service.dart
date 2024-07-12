import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../lib/payment.dart';

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static Map<String, String> getHeaders() => {
        "Authorization": "Bearer ${StripeService.secret}",
        "Content-Type": "application/x-www-form-urlencoded"
      };

  static void init({String? stripePublishable, String? stripeSecrate}) {
    Stripe.publishableKey = stripePublishable ?? "";
    StripeService.secret = stripeSecrate;

    Stripe.merchantIdentifier = 'merchant.flut=ter.stripe.testaaa';
    if (Stripe.publishableKey == "") {
      throw "Please add stripe publishable key";
    } else if (StripeService.secret == null) {
      throw "Please add stripe secret key";
    }
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet({
    required final int amount,
    required final bool isTestEnvironment,
    final String? currency,
    final String? from,
    final BuildContext? context,
    final String? awaitedOrderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      //create Payment intent

      isPaymentGatewayOpen = true;
      final Map<String, dynamic>? paymentIntent =
          await StripeService.createPaymentIntent(
              amount: amount,
              currency: currency,
              from: from,
              context: context,
              metadata: metadata //{"packageId": 123, "userId": 123}
              // awaitedOrderID: awaitedOrderId,
              );

      //setting up Payment Sheet
      if (AppSettings.stripeCurrency == "USD") {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            allowsDelayedPaymentMethods: true,
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
                    address: AddressCollectionMode.full,
                    email: CollectionMode.always,
                    name: CollectionMode.always,
                    phone: CollectionMode.always),
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: AppSettings.applicationName,
          ),
        );
      } else {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            allowsDelayedPaymentMethods: true,
            // billingDetailsCollectionConfiguration:
            //     const BillingDetailsCollectionConfiguration(
            //         address: AddressCollectionMode.full,
            //         email: CollectionMode.always,
            //         name: CollectionMode.always,
            //         phone: CollectionMode.always),
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: AppSettings.applicationName,
          ),
        );
      }

      //open payment sheet
      PaymentSheetPaymentOption? paymentSheetPaymentOption =
          await Stripe.instance.presentPaymentSheet();
      //confirm payment
      final Response response = await Dio().post(
        '${StripeService.paymentApiUrl}/${paymentIntent['id']}',
        options: Options(headers: headers),
      );

      final Map getdata = Map.from(response.data);
      final statusOfTransaction = getdata['status'];
      log("--stripe response ${getdata}");
      if (statusOfTransaction == 'succeeded') {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          status: statusOfTransaction,
        );
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction pending',
          success: true,
          status: statusOfTransaction,
        );
      } else {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
          status: statusOfTransaction,
        );
      }
    } on PlatformException catch (err) {
      log("Platform issue: $err");
      isPaymentGatewayOpen = false;

      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (error) {
      log("Other issue issue: $error");
      isPaymentGatewayOpen = false;
      return StripeTransactionResponse(
        message: 'Transaction failed: $error',
        success: false,
        status: 'fail',
      );
    }
  }

  static StripeTransactionResponse getPlatformExceptionErrorResult(final err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(
      message: message,
      success: false,
      status: 'cancelled',
    );
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(
      {required final int amount,
      final String? currency,
      final String? from,
      final BuildContext? context,
      final String? awaitedOrderID,
      Map<String, dynamic>? metadata}) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        'amount': amount,
        'currency': currency,
        'metadata': metadata,
      };

      // if (from == 'order') parameter['metadata[order_id]'] = awaitedOrderID;

      final Dio dio = Dio();

      final response = await dio.post(
        StripeService.paymentApiUrl,
        data: parameter,
        options: Options(
          headers: StripeService.getHeaders(),
        ),
      );

      return Map.from(response.data);
    } catch (_) {
      if (_ is DioError) {
        log(_.response!.data.toString(), name: "@@@@@@@@@@@SDASDASDASDASD");
      }

      log("STRIPE ISSUE ${_ is DioError}");
    }
    return null;
  }
}

class StripeTransactionResponse {
  StripeTransactionResponse({this.message, this.success, this.status});
  final String? message, status;
  bool? success;
}

Future<void> openStripePaymentGateway(
    {required final double amount,
    required Map<String, dynamic> metadata,
    required VoidCallback onSuccess,
    required Function(dynamic message) onError}) async {
  try {
    StripeService.init(
        stripePublishable: AppSettings.stripePublishableKey,
        stripeSecrate: AppSettings.stripeSecrateKey);

    final response = await StripeService.payWithPaymentSheet(
        amount: (amount * 100).toInt(),
        currency: AppSettings.stripeCurrency,
        isTestEnvironment: true,
        metadata: metadata);

    if (response.status == 'succeeded') {
      onSuccess.call();
    } else {
      onError.call(response.message);
    }
  } catch (_) {
    log("ERROR IS $_");
  }
}
