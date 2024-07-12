import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../lib/login_status.dart';
import '../lib/login_system.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;

  @override
  void init() async {
    print("loginSystem");
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      GoogleSignInAccount? googleSignIn = await _googleSignIn?.signIn();

      if (googleSignIn == null) {
        throw ErrorDescription("google-terminated");
      }
      GoogleSignInAuthentication? googleAuth =
          await googleSignIn.authentication;

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(authCredential);
      emit(MSuccess(userCredential, type: "google"));

      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == "network_error") {
        emit(MFail("noInternet".translate(context!)));
      }
    } on FirebaseAuthException catch (e) {
      emit(MFail(ErrorFilter.check(e.code)));
    } catch (e, st) {
      emit(MFail(e.toString()));
    }
  }

  @override
  void onEvent(MLoginState state) {
    // TODO: implement onEvent
  }
}
