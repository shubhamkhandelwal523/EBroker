// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../model/data_output.dart';
import '../../model/property_model.dart';
import '../../repositories/property_repository.dart';

abstract class FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInitial extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInProgress extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesSuccess extends FetchPromotedPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchPromotedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchPromotedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: propertymodel ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isLoadingMore': isLoadingMore,
      'loadingMoreError': loadingMoreError,
      'propertymodel': properties.map((x) => x.toMap()).toList(),
      'offset': offset,
      'total': total,
    };
  }

  factory FetchPromotedPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      loadingMoreError: map['loadingMoreError'] as bool,
      properties: List<PropertyModel>.from(
        (map['propertymodel'] as List).map<PropertyModel>(
          (x) => PropertyModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchPromotedPropertiesSuccess.fromJson(String source) =>
      FetchPromotedPropertiesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  set isLoadingMore(bool _isLoadingMore) {}

  @override
  set properties(List<PropertyModel> _properties) {}
}

class FetchPromotedPropertiesFailure extends FetchPromotedPropertiesState
    implements PropertyErrorStateWireframe {
  final String error;
  FetchPromotedPropertiesFailure(this.error);

  @override
  set error(_error) {}
}

class FetchPromotedPropertiesCubit extends Cubit<FetchPromotedPropertiesState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchPromotedPropertiesCubit() : super(FetchPromotedPropertiesInitial()) {
    hydrate();
  }

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    print("State is $state");
    try {
      await CacheData().getData(
          forceRefresh: forceRefresh == true,
          onProgress: () {
            emit(FetchPromotedPropertiesInProgress());
          },
          delay: loadWithoutDelay == true ? 0 : null,
          onNetworkRequest: () async {
            DataOutput<PropertyModel> result =
                await _propertyRepository.fetchPromotedProperty(
              offset: 0,
              sendCityName: true,
            );
            return FetchPromotedPropertiesSuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total,
            );
          },
          onOfflineData: () {
            return FetchPromotedPropertiesSuccess(
                total: (state as FetchPromotedPropertiesSuccess).total,
                offset: (state as FetchPromotedPropertiesSuccess).offset,
                isLoadingMore:
                    (state as FetchPromotedPropertiesSuccess).isLoadingMore,
                loadingMoreError:
                    (state as FetchPromotedPropertiesSuccess).loadingMoreError,
                properties:
                    (state as FetchPromotedPropertiesSuccess).properties);
          },
          onSuccess: (data) {
            emit(data);
          },
          hasData: state is FetchPromotedPropertiesSuccess);
    } catch (e) {
      print("Promoted properties $e");
      emit(FetchPromotedPropertiesFailure(e.toString()));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchPromotedPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchPromotedPropertiesSuccess).properties;

      var index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchPromotedPropertiesSuccess)
          .copyWith(propertymodel: properties));
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchPromotedPropertiesSuccess) {
        if ((state as FetchPromotedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchPromotedPropertiesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchPromotedProperty(
                offset:
                    (state as FetchPromotedPropertiesSuccess).properties.length,
                sendCityName: true);

        FetchPromotedPropertiesSuccess propertymodelState =
            (state as FetchPromotedPropertiesSuccess);
        propertymodelState.properties.addAll(result.modelList);
        emit(FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertymodelState.properties,
            offset: (state as FetchPromotedPropertiesSuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchPromotedPropertiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchPromotedPropertiesSuccess) {
      return (state as FetchPromotedPropertiesSuccess).properties.length <
          (state as FetchPromotedPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchPromotedPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      FetchPromotedPropertiesSuccess fetchPromotedPropertiesSuccess =
          FetchPromotedPropertiesSuccess.fromMap(json);

      return fetchPromotedPropertiesSuccess;
    } catch (e, st) {}
  }

  @override
  Map<String, dynamic>? toJson(FetchPromotedPropertiesState state) {
    if (state is FetchPromotedPropertiesSuccess) {
      Map<String, dynamic> mapped = state.toMap();
      mapped['cubit_state'] = "FetchPromotedPropertiesSuccess";
      return mapped;
    }

    return null;
  }
}
