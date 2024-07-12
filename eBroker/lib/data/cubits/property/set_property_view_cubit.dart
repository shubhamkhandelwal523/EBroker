import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/property_repository.dart';

abstract class SetPropertyViewState {}

class SetPropertyViewInitial extends SetPropertyViewState {}

class SetPropertyViewInProgress extends SetPropertyViewState {}

class SetPropertyViewSuccess extends SetPropertyViewState {}

class SetPropertyViewFailure extends SetPropertyViewState {
  final String errorMessage;

  SetPropertyViewFailure(this.errorMessage);
}

class SetPropertyViewCubit extends Cubit<SetPropertyViewState> {
  final PropertyRepository _propertyRepository = PropertyRepository();

  SetPropertyViewCubit() : super(SetPropertyViewInitial());

  Future<void> set(String propertyId) async {
    try {
      emit(SetPropertyViewInProgress());
      await _propertyRepository.setProeprtyView(propertyId);
      emit(SetPropertyViewSuccess());
    } catch (e) {
      emit(SetPropertyViewFailure(e.toString()));
    }
  }
}
