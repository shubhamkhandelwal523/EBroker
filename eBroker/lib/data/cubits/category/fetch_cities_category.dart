// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/repositories/cities_repository.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/Extensions/lib/list.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../utils/Network/networkAvailability.dart';

abstract class FetchCityCategoryState {}

class FetchCityCategoryInitial extends FetchCityCategoryState {}

class FetchCityCategoryInProgress extends FetchCityCategoryState {}

class FetchCityCategorySuccess extends FetchCityCategoryState {
  final List<City> cities;
  final int total;
  FetchCityCategorySuccess({
    required this.cities,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'cities': cities.map((e) => e.toMap()).toList(),
      'total': total,
    };
  }

  factory FetchCityCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchCityCategorySuccess(
      cities: (map['cities'] as List)
          .map(
            (e) => City.fromMap(e),
          )
          .toList(),
      total: map['total'] as int,
    );
  }
}

class FetchCityCategoryFail extends FetchCityCategoryState {
  final dynamic error;

  FetchCityCategoryFail(this.error);
}

class FetchCityCategoryCubit extends Cubit<FetchCityCategoryState>
    with HydratedMixin {
  FetchCityCategoryCubit() : super(FetchCityCategoryInitial());
  final CitiesRepository _citiesRepository = CitiesRepository();
  void fetchCityCategory({bool? forceRefresh, bool? loadWithoutDelay}) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchCityCategorySuccess) {
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(Duration(
              seconds: loadWithoutDelay == true
                  ? 0
                  : AppSettings.hiddenAPIProcessDelay));
          // });
        } else {
          emit(FetchCityCategoryInProgress());
        }
      } else {
        emit(FetchCityCategoryInProgress());
      }

      // emit(FetchCityCategoryInProgress());

      if (forceRefresh == true) {
        DataOutput<City> result = await _citiesRepository.fetchCitiesData();

        emit(FetchCityCategorySuccess(
            cities: result.modelList, total: result.total));
      } else {
        if (state is! FetchCityCategorySuccess) {
          DataOutput<City> result = await _citiesRepository.fetchCitiesData();

          emit(FetchCityCategorySuccess(
              cities: result.modelList, total: result.total));
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<City> result =
                  await _citiesRepository.fetchCitiesData();

              emit(FetchCityCategorySuccess(
                  cities: result.modelList, total: result.total));
            },
            onNoInternet: () {
              emit(FetchCityCategorySuccess(
                  cities: (state as FetchCityCategorySuccess).cities,
                  total: (state as FetchCityCategorySuccess).total));
            },
          );
        }
      }
    } catch (error) {
      emit(FetchCityCategoryFail(error));
    }
  }

  dynamic getCount() {
    if (state is FetchCityCategorySuccess) {
      return (state as FetchCityCategorySuccess).cities.sum((e) => e.count);
    } else {
      return "--";
    }
  }

  @override
  FetchCityCategoryState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchCityCategorySuccess") {
        FetchCityCategorySuccess fetchCityCategory =
            FetchCityCategorySuccess.fromMap(json);

        return fetchCityCategory;
      }
    } catch (e, st) {}
  }

  @override
  Map<String, dynamic>? toJson(FetchCityCategoryState state) {
    try {
      if (state is FetchCityCategorySuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchCityCategorySuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
