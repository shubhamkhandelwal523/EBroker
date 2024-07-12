import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/advertisement_repository.dart';

abstract class DeleteAdvertismentState {}

class DeleteAdvertismentInitial extends DeleteAdvertismentState {}

class DeleteAdvertismentInProgress extends DeleteAdvertismentState {}

class DeleteAdvertismentSuccess extends DeleteAdvertismentState {}

class DeleteAdvertismentFailure extends DeleteAdvertismentState {
  final String errorMessage;

  DeleteAdvertismentFailure(this.errorMessage);
}

class DeleteAdvertismentCubit extends Cubit<DeleteAdvertismentState> {
  final AdvertisementRepository _advertisementRepository;

  DeleteAdvertismentCubit(this._advertisementRepository)
      : super(DeleteAdvertismentInitial());

  void delete(dynamic id) async {
    try {
      emit(DeleteAdvertismentInProgress());
      await _advertisementRepository.deleteAdvertisment(id);
      emit(DeleteAdvertismentSuccess());
    } catch (e) {
      emit(DeleteAdvertismentFailure(e.toString()));
    }
  }
}
