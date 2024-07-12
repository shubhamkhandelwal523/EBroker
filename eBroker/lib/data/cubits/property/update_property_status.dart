// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdatePropertyStatusState {}

class UpdatePropertyStatusInitial extends UpdatePropertyStatusState {}

class UpdatePropertyStatusInProgress extends UpdatePropertyStatusState {}

class UpdatePropertyStatusSuccess extends UpdatePropertyStatusState {}

class UpdatePropertyStatusFail extends UpdatePropertyStatusState {
  final dynamic error;
  UpdatePropertyStatusFail({
    required this.error,
  });
}

class UpdatePropertyStatusCubit extends Cubit<UpdatePropertyStatusState> {
  UpdatePropertyStatusCubit() : super(UpdatePropertyStatusInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  void update({required dynamic propertyId, required dynamic status}) async {
    try {
      emit(UpdatePropertyStatusInProgress());
      await _propertyRepository.updatePropertyStatus(
          propertyId: propertyId, status: status);
      emit(UpdatePropertyStatusSuccess());
    } catch (e) {
      emit(UpdatePropertyStatusFail(error: e.toString()));
    }
  }
}
