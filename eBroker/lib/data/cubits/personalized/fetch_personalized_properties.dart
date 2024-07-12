import 'dart:developer';

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/personalized_feed_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../ui/screens/proprties/viewAll.dart';
import '../../../utils/network/networkAvailability.dart';
import '../../model/data_output.dart';

abstract class FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertyInitial
    extends FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertyInProgress
    extends FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertySuccess
    extends FetchPersonalizedPropertyListState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchPersonalizedPropertySuccess(
      {required this.isLoadingMore,
      required this.loadingMoreError,
      required this.properties,
      required this.offset,
      required this.total});

  @override
  set isLoadingMore(bool _isLoadingMore) {}

  @override
  set properties(List<PropertyModel> _properties) {}

  FetchPersonalizedPropertySuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
    String? cityName,
  }) {
    return FetchPersonalizedPropertySuccess(
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadingMoreError: loadingMoreError ?? this.loadingMoreError,
        properties: properties ?? this.properties,
        offset: offset ?? this.offset,
        total: total ?? this.total);
  }

  Map<String, dynamic> toMap() {
    return {
      'isLoadingMore': this.isLoadingMore,
      'loadingMoreError': this.loadingMoreError,
      'properties': properties.map((e) => e.toMap()).toList(),
      'offset': this.offset,
      'total': this.total,
    };
  }

  factory FetchPersonalizedPropertySuccess.fromMap(Map<String, dynamic> map) {
    return FetchPersonalizedPropertySuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      loadingMoreError: map['loadingMoreError'] as bool,
      properties: (map['properties'] as List)
          .map((e) => PropertyModel.fromMap(e))
          .toList(),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }
}

class FetchPersonalizedPropertyFail extends FetchPersonalizedPropertyListState
    implements PropertyErrorStateWireframe {
  final dynamic error;
  FetchPersonalizedPropertyFail(this.error);

  @override
  set error(_error) {}
}

class FetchPersonalizedPropertyList
    extends Cubit<FetchPersonalizedPropertyListState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchPersonalizedPropertyList() : super(FetchPersonalizedPropertyInitial()) {
    hydrate();
  }
  final PersonalizedFeedRepository _personalizedFeedRepository =
      PersonalizedFeedRepository();

  @override
  void fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    if (forceRefresh != true) {
      if (state is FetchPersonalizedPropertySuccess) {
        await Future.delayed(Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay));
      } else {
        emit(FetchPersonalizedPropertyInProgress());
      }
    } else {
      emit(FetchPersonalizedPropertyInProgress());
    }
    try {
      if (forceRefresh == true) {
        DataOutput<PropertyModel> result = await _personalizedFeedRepository
            .getPersonalizedProeprties(offset: 0);

        emit(FetchPersonalizedPropertySuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total));
      } else {
        if (state is! FetchPersonalizedPropertySuccess) {
          DataOutput<PropertyModel> result = await _personalizedFeedRepository
              .getPersonalizedProeprties(offset: 0);

          emit(FetchPersonalizedPropertySuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total));
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<PropertyModel> result =
                  await _personalizedFeedRepository.getPersonalizedProeprties(
                      offset: 0);

              emit(FetchPersonalizedPropertySuccess(
                  isLoadingMore: false,
                  loadingMoreError: false,
                  properties: result.modelList,
                  offset: 0,
                  total: result.total));
            },
            onNoInternet: () {
              emit(
                FetchPersonalizedPropertySuccess(
                    total: (state as FetchPersonalizedPropertySuccess).total,
                    offset: (state as FetchPersonalizedPropertySuccess).offset,
                    isLoadingMore: (state as FetchPersonalizedPropertySuccess)
                        .isLoadingMore,
                    loadingMoreError:
                        (state as FetchPersonalizedPropertySuccess)
                            .loadingMoreError,
                    properties:
                        (state as FetchPersonalizedPropertySuccess).properties),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchPersonalizedPropertyFail(e as dynamic));
    }
  }

  @override
  void fetchMore() async {
    try {
      if (state is FetchPersonalizedPropertySuccess) {
        if ((state as FetchPersonalizedPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchPersonalizedPropertySuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _personalizedFeedRepository.getPersonalizedProeprties(
          offset: (state as FetchPersonalizedPropertySuccess).properties.length,
        );

        FetchPersonalizedPropertySuccess propertiesState =
            (state as FetchPersonalizedPropertySuccess);
        propertiesState.properties.addAll(result.modelList);
        emit(FetchPersonalizedPropertySuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchPersonalizedPropertySuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchPersonalizedPropertySuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchPersonalizedPropertySuccess) {
      return (state as FetchPersonalizedPropertySuccess).properties.length <
          (state as FetchPersonalizedPropertySuccess).total;
    }
    return false;
  }

  @override
  FetchPersonalizedPropertyListState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchPersonalizedPropertySuccess") {
        FetchPersonalizedPropertySuccess fetchPersonalizedPropertySuccess =
            FetchPersonalizedPropertySuccess.fromMap(json);

        return fetchPersonalizedPropertySuccess;
      }
    } catch (e, st) {
      log("ERROR WHILE lOAD JSON TO MODEL $st");
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchPersonalizedPropertyListState state) {
    try {
      if (state is FetchPersonalizedPropertySuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchPersonalizedPropertySuccess";
        return mapped;
      }
    } catch (e) {
      log("ISSUE ISSSS $e");
    }

    return null;
  }
}
