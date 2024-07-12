import 'package:firebase_auth/firebase_auth.dart';

import '../../constant.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:ebroker/utils/login/lib/login_system.dart';
import 'package:ebroker/utils/login/lib/payloads.dart';

class PhoneLogin extends LoginSystem {
  String? verificationId;

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId ?? "",
        smsCode: (payload as PhoneLoginPayload).getOTP()!,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      emit(MSuccess(userCredential, type: "phone"));

      return userCredential;
    } catch (e) {
      emit(MFail(e));
    }
    return null;
  }

  @override
  Future<void> requestVerification() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(
        seconds: Constant.otpTimeOutSecond,
      ),
      phoneNumber:
          "+${(payload as PhoneLoginPayload).countryCode}${(payload as PhoneLoginPayload).phoneNumber}",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        emit(MFail(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        super.requestVerification();
        forceResendingtoken = resendToken;
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: forceResendingtoken,
    );
  }

  @override
  void onEvent(MLoginState state) {}
}
