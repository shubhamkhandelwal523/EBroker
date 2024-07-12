// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../utils/Network/networkAvailability.dart';
import '../../model/data_output.dart';
import '../../model/property_model.dart';
import '../../repositories/property_repository.dart';

abstract class FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInitial extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInProgress
    extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesSuccess extends FetchMostViewedPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchMostViewedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchMostViewedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchMostViewedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isLoadingMore': isLoadingMore,
      'loadingMoreError': loadingMoreError,
      'properties': properties.map((x) => x.toMap()).toList(),
      'offset': offset,
      'total': total,
    };
  }

  factory FetchMostViewedPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchMostViewedPropertiesSuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      loadingMoreError: map['loadingMoreError'] as bool,
      properties: List<PropertyModel>.from(
        (map['properties']).map<PropertyModel>(
          (x) => PropertyModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchMostViewedPropertiesSuccess.fromJson(String source) =>
      FetchMostViewedPropertiesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  set properties(List<PropertyModel> _properties) {
    // TODO: implement properties
  }

  @override
  set isLoadingMore(bool _isLoadingMore) {
    // TODO: implement isLoadingMore
  }
}

class FetchMostViewedPropertiesFailure extends FetchMostViewedPropertiesState
    implements PropertyErrorStateWireframe {
  final dynamic error;
  FetchMostViewedPropertiesFailure(this.error);

  @override
  set error(_error) {
    // TODO: implement error
  }
}

class FetchMostViewedPropertiesCubit
    extends Cubit<FetchMostViewedPropertiesState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchMostViewedPropertiesCubit() : super(FetchMostViewedPropertiesInitial()) {
    hydrate();
  }

  final PropertyRepository _propertyRepository = PropertyRepository();

  fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    // if (state is FetchMostViewedPropertiesSuccess) {
    //   return;
    // }
    if (forceRefresh != true) {
      if (state is FetchMostViewedPropertiesSuccess) {
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay));
        // });
      } else {
        emit(FetchMostViewedPropertiesInProgress());
      }
    } else {
      emit(FetchMostViewedPropertiesInProgress());
    }
    try {
      if (forceRefresh == true) {
        DataOutput<PropertyModel> result = await _propertyRepository
            .fetchMostViewedProperty(offset: 0, sendCityName: true);

        emit(FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total));
      } else {
        if (state is! FetchMostViewedPropertiesSuccess) {
          DataOutput<PropertyModel> result = await _propertyRepository
              .fetchMostViewedProperty(offset: 0, sendCityName: true);

          emit(FetchMostViewedPropertiesSuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total));
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<PropertyModel> result = await _propertyRepository
                  .fetchMostViewedProperty(offset: 0, sendCityName: true);

              emit(FetchMostViewedPropertiesSuccess(
                  isLoadingMore: false,
                  loadingMoreError: false,
                  properties: result.modelList,
                  offset: 0,
                  total: result.total));
            },
            onNoInternet: () {
              emit(
                FetchMostViewedPropertiesSuccess(
                    total: (state as FetchMostViewedPropertiesSuccess).total,
                    offset: (state as FetchMostViewedPropertiesSuccess).offset,
                    isLoadingMore: (state as FetchMostViewedPropertiesSuccess)
                        .isLoadingMore,
                    loadingMoreError:
                        (state as FetchMostViewedPropertiesSuccess)
                            .loadingMoreError,
                    properties:
                        (state as FetchMostViewedPropertiesSuccess).properties),
              );
            },
          );
        }
      }
    } catch (e, st) {
      print(st);
      emit(FetchMostViewedPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMostViewedPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchMostViewedPropertiesSuccess).properties;

      var index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchMostViewedPropertiesSuccess)
          .copyWith(properties: properties));
    }
  }

  Future<void> fetchMore() async {
    try {
      if (state is FetchMostViewedPropertiesSuccess) {
        if ((state as FetchMostViewedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMostViewedPropertiesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchMostViewedProperty(
                offset: (state as FetchMostViewedPropertiesSuccess)
                    .properties
                    .length,
                sendCityName: true);

        FetchMostViewedPropertiesSuccess propertiesState =
            (state as FetchMostViewedPropertiesSuccess);
        propertiesState.properties.addAll(result.modelList);
        emit(FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchMostViewedPropertiesSuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchMostViewedPropertiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchMostViewedPropertiesSuccess) {
      return (state as FetchMostViewedPropertiesSuccess).properties.length <
          (state as FetchMostViewedPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchMostViewedPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      var state = json['cubit_state'];

      if (state == "FetchMostViewedPropertiesSuccess") {
        return FetchMostViewedPropertiesSuccess.fromMap(json);
      }
    } catch (e) {}

    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchMostViewedPropertiesState state) {
    if (state is FetchMostViewedPropertiesSuccess) {
      Map<String, dynamic> map = state.toMap();
      map['cubit_state'] = "FetchMostViewedPropertiesSuccess";
      return map;
    }
    return null;
  }
}
