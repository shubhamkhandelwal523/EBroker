// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/outdoorfacility.dart';
import 'package:ebroker/data/model/outdoor_facility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/property_model.dart';

class FetchOutdoorFacilityListState {}

class FetchOutdoorFacilityListInitial extends FetchOutdoorFacilityListState {}

class FetchOutdoorFacilityListInProgress
    extends FetchOutdoorFacilityListState {}

class FetchOutdoorFacilityListSucess extends FetchOutdoorFacilityListState {
  final List<OutdoorFacility> outdoorFacilityList;
  FetchOutdoorFacilityListSucess({
    required this.outdoorFacilityList,
  });

  FetchOutdoorFacilityListSucess copyWith({
    List<OutdoorFacility>? outdoorFacilityList,
  }) {
    return FetchOutdoorFacilityListSucess(
      outdoorFacilityList: outdoorFacilityList ?? this.outdoorFacilityList,
    );
  }
}

class FetchOutdoorFacilityListFailure extends FetchOutdoorFacilityListState {
  final dynamic error;
  FetchOutdoorFacilityListFailure({
    required this.error,
  });
}

class FetchOutdoorFacilityListCubit
    extends Cubit<FetchOutdoorFacilityListState> {
  FetchOutdoorFacilityListCubit() : super(FetchOutdoorFacilityListInitial());
  final OutdoorFacilityRepository _facilityRepository =
      OutdoorFacilityRepository();
  void fetch() async {
    try {
      emit(FetchOutdoorFacilityListInProgress());

      List<OutdoorFacility> facilityList =
          await _facilityRepository.fetchOutdoorFacilityList();
      emit(FetchOutdoorFacilityListSucess(outdoorFacilityList: facilityList));
    } catch (error) {
      emit(FetchOutdoorFacilityListFailure(error: error));
    }
  }

  List<OutdoorFacility> getList() {
    if (state is FetchOutdoorFacilityListSucess) {
      return (state as FetchOutdoorFacilityListSucess).outdoorFacilityList;
    }
    return <OutdoorFacility>[];
  }

  void fetchIfFailed() {
    if (state is FetchOutdoorFacilityListFailure ||
        state is FetchOutdoorFacilityListInitial) {
      fetch();
    }
  }

  fillData(List<AssignedOutdoorFacility> facilities) {
    if (state is FetchOutdoorFacilityListSucess) {
      List<OutdoorFacility> outdoorFacilityList =
          (state as FetchOutdoorFacilityListSucess).outdoorFacilityList;
      List<OutdoorFacility> newFacility = [];

      for (var i = 0; i < facilities.length; i++) {
        newFacility.add(OutdoorFacility(
            name: facilities[i].name,
            id: facilities[i].id,
            distance: facilities[i].distance.toString(),
            image: facilities[i].image));
      }

      emit((state as FetchOutdoorFacilityListSucess)
          .copyWith(outdoorFacilityList: newFacility));
    }
  }
}
