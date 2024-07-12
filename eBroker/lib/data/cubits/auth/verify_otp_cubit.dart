// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/utils/errorFilter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final UserCredential credential;
  VerifyOtpSuccess({
    required this.credential,
  });
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;

  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOTP(
      {required String verificationId, required String otp}) async {
    try {
      emit(VerifyOtpInProgress());

      UserCredential userCredential = await _authRepository.verifyOTP(
          otpVerificationId: verificationId, otp: otp);

      emit(VerifyOtpSuccess(credential: userCredential));
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error));
    } catch (e, st) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  void setInitialState() {
    emit(VerifyOtpInitial());
  }
}
