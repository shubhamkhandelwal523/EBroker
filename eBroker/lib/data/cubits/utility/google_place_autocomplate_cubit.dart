// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/location_repository.dart';
import '../../model/google_place_model.dart';

abstract class GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteInitial extends GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteInProgress extends GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteSuccess extends GooglePlaceAutocompleteState {
  List<GooglePlaceModel> autocompleteResult;

  GooglePlaceAutocompleteSuccess(this.autocompleteResult);
}

class GooglePlaceAutocompleteFail extends GooglePlaceAutocompleteState {
  dynamic error;

  GooglePlaceAutocompleteFail(this.error);
}

class GooglePlaceAutocompleteCubit extends Cubit<GooglePlaceAutocompleteState> {
  GooglePlaceAutocompleteCubit() : super(GooglePlaceAutocompleteInitial());
  final GooglePlaceRepository _googlePlaceAutocomplete =
      GooglePlaceRepository();

  ///This method will search location from text,
  ///We use it for search location
  Future<void> getLocationFromText({required String text}) async {
    try {
      emit(GooglePlaceAutocompleteInProgress());
      List<GooglePlaceModel> googlePlaceAutocompleteResponse =
          await _googlePlaceAutocomplete.serchCities(text);
      emit(GooglePlaceAutocompleteSuccess(googlePlaceAutocompleteResponse));
    } catch (e) {
      emit(GooglePlaceAutocompleteFail(e));
      rethrow;
    }
  }

  ///this will clear all data and set it to its initial state so,
  ///When we don't need these all data we clear it.
  void clearCubit() {
    emit(GooglePlaceAutocompleteSuccess([]));
    Future.delayed(const Duration(microseconds: 300), () {
      emit(GooglePlaceAutocompleteInitial());
    });
  }
}
