abstract class LoginPayload {}

class MultiLoginPayload {
  final Map<String, LoginPayload> payloads;

  MultiLoginPayload(this.payloads);
}

enum EmailLoginType { login, signup }

class EmailLoginPayload extends LoginPayload {
  final String email;
  final String password;
  final EmailLoginType type;

  EmailLoginPayload(
      {required this.email, required this.password, required this.type});
}

class GoogleLoginPayload extends LoginPayload {
  GoogleLoginPayload();
}

int? forceResendingtoken;

class PhoneLoginPayload extends LoginPayload {
  final String phoneNumber;
  final String countryCode;
  String? otp;
  PhoneLoginPayload(this.phoneNumber, this.countryCode);
  void setOTP(String value) {
    this.otp = value;
  }

  String? getOTP() {
    return otp;
  }
}
