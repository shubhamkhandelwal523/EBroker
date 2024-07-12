// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';

class ErrorFilter {
  final dynamic error;
  static BuildContext? _context;
  ErrorFilter(this.error);
  static void setContext(BuildContext context) {
    _context = context;
  }

  ///set this in error filters so you can get translated errors
  factory ErrorFilter.check(errorCode) {
    switch (errorCode) {
      case "network-request-failed":
        return ErrorFilter("Please check internet connection");
      case "app-not-authorized":
        return ErrorFilter("Add SHA keys in Firebase and Playstore");
      case "no-internet":
        return ErrorFilter("Please check internet connection");
      case "email-already-in-use":
        return ErrorFilter("This email is already registered.");
      case "wrong-password":
        return ErrorFilter("The password is wrong.");
      case "user-not-found":
        return ErrorFilter("This email is not registered. Please try signup.");
      case "invalid-email":
        return ErrorFilter("This email is not valid.");
      case "invalid-phone-number":
        return ErrorFilter("Phone number is invalid.");
      case "invalid-verification-code":
        return ErrorFilter("OTP is incorrect.");
      case "too-many-requests":
        return ErrorFilter("Unusual activity detected. Please try again later");
      case "session-expired":
        return ErrorFilter(
            "The otp code has expired. Please re-send the verification code to try again");
      default:
        return ErrorFilter(errorCode);
    }
  }
}
