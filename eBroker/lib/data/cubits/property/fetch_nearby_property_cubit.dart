// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../utils/Network/networkAvailability.dart';
import '../../model/data_output.dart';
import '../../model/property_model.dart';
import '../../repositories/property_repository.dart';

abstract class FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInitial extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInProgress extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesSuccess extends FetchNearbyPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchNearbyPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchNearbyPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchNearbyPropertiesSuccess(
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

  factory FetchNearbyPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchNearbyPropertiesSuccess(
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

  factory FetchNearbyPropertiesSuccess.fromJson(String source) =>
      FetchNearbyPropertiesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  set isLoadingMore(bool _isLoadingMore) {
    // TODO: implement isLoadingMore
  }

  @override
  set properties(List<PropertyModel> _properties) {
    // TODO: implement properties
  }
}

class FetchNearbyPropertiesFailure extends FetchNearbyPropertiesState
    implements PropertyErrorStateWireframe {
  final dynamic error;
  FetchNearbyPropertiesFailure(this.error);

  @override
  set error(_error) {
    // TODO: implement error
  }
}

class FetchNearbyPropertiesCubit extends Cubit<FetchNearbyPropertiesState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchNearbyPropertiesCubit() : super(FetchNearbyPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    // if (state is FetchNearbyPropertiesSuccess) {
    //   return;
    // }
    if (forceRefresh != true) {
      if (state is FetchNearbyPropertiesSuccess) {
        await Future.delayed(Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay));
      } else {
        emit(FetchNearbyPropertiesInProgress());
      }
    } else {
      emit(FetchNearbyPropertiesInProgress());
    }

    try {
      if (forceRefresh == true) {
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchNearByProperty(
          offset: 0,
        );
        emit(FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total));
      } else {
        if (state is! FetchNearbyPropertiesSuccess) {
          DataOutput<PropertyModel> result =
              await _propertyRepository.fetchNearByProperty(
            offset: 0,
          );
          emit(FetchNearbyPropertiesSuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total));
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<PropertyModel> result =
                  await _propertyRepository.fetchNearByProperty(
                offset: 0,
              );
              emit(FetchNearbyPropertiesSuccess(
                  isLoadingMore: false,
                  loadingMoreError: false,
                  properties: result.modelList,
                  offset: 0,
                  total: result.total));
            },
            onNoInternet: () {
              emit(
                FetchNearbyPropertiesSuccess(
                    total: (state as FetchNearbyPropertiesSuccess).total,
                    offset: (state as FetchNearbyPropertiesSuccess).offset,
                    isLoadingMore:
                        (state as FetchNearbyPropertiesSuccess).isLoadingMore,
                    loadingMoreError: (state as FetchNearbyPropertiesSuccess)
                        .loadingMoreError,
                    properties:
                        (state as FetchNearbyPropertiesSuccess).properties),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchNearbyPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchNearbyPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchNearbyPropertiesSuccess).properties;

      var index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchNearbyPropertiesSuccess)
          .copyWith(properties: properties));
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchNearbyPropertiesSuccess) {
        if ((state as FetchNearbyPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchNearbyPropertiesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchNearByProperty(
          offset: (state as FetchNearbyPropertiesSuccess).properties.length,
          // sendCityName: true
        );

        FetchNearbyPropertiesSuccess propertiesState =
            (state as FetchNearbyPropertiesSuccess);
        propertiesState.properties.addAll(result.modelList);
        emit(FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset: (state as FetchNearbyPropertiesSuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchNearbyPropertiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchNearbyPropertiesSuccess) {
      return (state as FetchNearbyPropertiesSuccess).properties.length <
          (state as FetchNearbyPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchNearbyPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      var state = json['cubit_state'];

      if (state == "FetchNearbyPropertiesSuccess") {
        return FetchNearbyPropertiesSuccess.fromMap(json);
      }
    } catch (e) {}

    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchNearbyPropertiesState state) {
    if (state is FetchNearbyPropertiesSuccess) {
      Map<String, dynamic> map = state.toMap();
      map['cubit_state'] = "FetchNearbyPropertiesSuccess";
      return map;
    }
    return null;
  }
}
