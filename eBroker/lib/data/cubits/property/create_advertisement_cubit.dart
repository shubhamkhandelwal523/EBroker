// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/advertisement_repository.dart';

abstract class CreateAdvertisementState {}

class CreateAdvertisementInitial extends CreateAdvertisementState {}

class CreateAdvertisementInProgress extends CreateAdvertisementState {}

class CreateAdvertisementSuccess extends CreateAdvertisementState {
  final dynamic proeprtyId;
  final PropertyModel property;
  CreateAdvertisementSuccess({
    required this.property,
    required this.proeprtyId,
  });
}

class CreateAdvertisementFailure extends CreateAdvertisementState {
  final String errorMessage;
  CreateAdvertisementFailure(
    this.errorMessage,
  );
}

class CreateAdvertisementCubit extends Cubit<CreateAdvertisementState> {
  final AdvertisementRepository _advertisementRepository =
      AdvertisementRepository();

  CreateAdvertisementCubit()
      : super(
          CreateAdvertisementInitial(),
        );

  Future<void> create({
    required String type,
    required String propertyId,
    File? image,
  }) async {
    try {
      emit(CreateAdvertisementInProgress());
      Map<String, dynamic> result = await _advertisementRepository.create(
        propertyId: propertyId,
        type: type,
        image: image,
      );
      emit(CreateAdvertisementSuccess(
          proeprtyId: propertyId,
          property: PropertyModel.fromMap(result['data'][0])));
    } catch (e) {
      emit(CreateAdvertisementFailure(e.toString()));
    }
  }
}
