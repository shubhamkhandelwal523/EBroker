import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/property_repository.dart';

abstract class DeletePropertyState {}

class DeletePropertyInitial extends DeletePropertyState {}

class DeletePropertyInProgress extends DeletePropertyState {}

class DeletePropertySuccess extends DeletePropertyState {}

class DeletePropertyFailure extends DeletePropertyState {
  final String errorMessage;

  DeletePropertyFailure(this.errorMessage);
}

class DeletePropertyCubit extends Cubit<DeletePropertyState> {
  final PropertyRepository _propertyRepository = PropertyRepository();
  DeletePropertyCubit() : super(DeletePropertyInitial());

  Future<void> delete(int id) async {
    try {
      emit(DeletePropertyInProgress());

      await _propertyRepository.deleteProperty(id);
      emit(DeletePropertySuccess());
    } catch (e) {
      emit(DeletePropertyFailure(e.toString()));
    }
  }
}
