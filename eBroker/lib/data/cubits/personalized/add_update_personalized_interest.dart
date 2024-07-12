import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

abstract class AddUpdatePersonalizedInterestState {}

class AddUpdatePersonalizedInterestInitial
    extends AddUpdatePersonalizedInterestState {}

class AddUpdatePersonalizedInterestInProgress
    extends AddUpdatePersonalizedInterestState {}

class AddUpdatePersonalizedInterestSuccess
    extends AddUpdatePersonalizedInterestState {}

class AddUpdatePersonalizedInterestFail
    extends AddUpdatePersonalizedInterestState {
  final dynamic error;

  AddUpdatePersonalizedInterestFail(this.error);
}

class AddUpdatePersonalizedInterest
    extends Cubit<AddUpdatePersonalizedInterestState> {
  AddUpdatePersonalizedInterest()
      : super(AddUpdatePersonalizedInterestInitial());
  PersonalizedFeedRepository personalizedFeedRepository =
      PersonalizedFeedRepository();
  void addOrUpdate({
    required PersonalizedFeedAction action,
    required List<int> categoryIds,
    List<int>? outdoorFacilityList,
    RangeValues? priceRange,
    List<int>? selectedPropertyType,
    String? city,
  }) async {
    try {
      emit(AddUpdatePersonalizedInterestInProgress());
      await personalizedFeedRepository.addOrUpdate(
          action: action,
          categoryIds: categoryIds,
          outdoorFacilityList: outdoorFacilityList,
          priceRange: priceRange,
          city: city,
          selectedPropertyType: selectedPropertyType);
      emit(AddUpdatePersonalizedInterestSuccess());
    } catch (e) {
      emit(AddUpdatePersonalizedInterestFail(e));
    }
  }
}
