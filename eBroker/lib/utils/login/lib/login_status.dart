import 'package:firebase_auth/firebase_auth.dart';

abstract class MLoginState {}

class MProgress extends MLoginState {}

class MVerificationPending extends MLoginState {
  // final String target;

  MVerificationPending();
}

class MSuccess extends MLoginState {
  final String type;
  final UserCredential credentials;

  MSuccess(this.credentials, {required this.type});
}

class MFail extends MLoginState {
  final dynamic error;

  MFail(this.error);
}
