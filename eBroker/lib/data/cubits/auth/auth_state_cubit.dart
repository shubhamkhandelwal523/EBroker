import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/hive_utils.dart';

enum AuthenticationState { initial, authenticated, unAuthenticated, firstTime }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.initial) {
    _checkIfAuthenticated();
  }

  void _checkIfAuthenticated() {
    bool userAuthenticated = HiveUtils.isUserAuthenticated();

    if (userAuthenticated) {
      emit(AuthenticationState.authenticated);
    } else {
      //When user installs app for first time then this firstTime state will be emmited.
      if (HiveUtils.isUserFirstTime()) {
        emit(AuthenticationState.firstTime);
      } else {
        emit(AuthenticationState.unAuthenticated);
      }
    }
  }

  void setUnAuthenticated() {
    emit(AuthenticationState.unAuthenticated);
  }
}
