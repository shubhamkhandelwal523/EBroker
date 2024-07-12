import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/api.dart';
import '../../utils/constant.dart';

enum LoginType {
  google("0"),
  phone("1"),
  apple("2");

  final String value;
  const LoginType(this.value);
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static int? forceResendingToken;
  Future<Map<String, dynamic>> loginWithApi(
      {required LoginType type,
      required String? phone,
      required String uid,
      String? email}) async {
    Map<String, String> parameters = {
      Api.mobile: phone?.replaceAll(" ", "").replaceAll("+", "") ?? "",
      Api.firebaseId: uid,
      if (email != null) "email": email,
      Api.type: type.value,
    };

    if (type == LoginType.phone) {
      parameters.remove("email");
    } else {
      parameters.remove("mobile");
    }

    Map<String, dynamic> response = await Api.post(
      url: Api.apiLogin,
      parameter: parameters,
      useAuthToken: false,
    );

    return {
      "token": response['token'],
      "data": response['data'],
    };
  }

  Future<void> sendOTP(
      {required String phoneNumber,
      required Function(String verificationId) onCodeSent,
      Function(dynamic e)? onError}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(
        seconds: Constant.otpTimeOutSecond,
      ),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        onError?.call(ApiException(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        forceResendingToken = resendToken;
        onCodeSent.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: forceResendingToken,
    );
  }

  Future<UserCredential> verifyOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: otpVerificationId, smsCode: otp);
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential;
  }
}
