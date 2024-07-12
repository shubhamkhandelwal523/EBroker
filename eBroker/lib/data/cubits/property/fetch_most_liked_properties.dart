// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../utils/Network/networkAvailability.dart';
import '../../model/data_output.dart';
import '../../model/property_model.dart';
import '../../repositories/property_repository.dart';

abstract class FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesInitial extends FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesInProgress
    extends FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesSuccess extends FetchMostLikedPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchMostLikedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchMostLikedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchMostLikedPropertiesSuccess(
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

  factory FetchMostLikedPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchMostLikedPropertiesSuccess(
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

  factory FetchMostLikedPropertiesSuccess.fromJson(String source) =>
      FetchMostLikedPropertiesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  set isLoadingMore(bool _isLoadingMore) {}

  @override
  set properties(List<PropertyModel> _properties) {}
}

class FetchMostLikedPropertiesFailure extends FetchMostLikedPropertiesState
    implements PropertyErrorStateWireframe {
  final dynamic error;
  FetchMostLikedPropertiesFailure(this.error);

  @override
  set error(_error) {
    // TODO: implement error
  }
}

class FetchMostLikedPropertiesCubit extends Cubit<FetchMostLikedPropertiesState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchMostLikedPropertiesCubit() : super(FetchMostLikedPropertiesInitial()) {
    hydrate();
  }

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    if (forceRefresh != true) {
      if (state is FetchMostLikedPropertiesSuccess) {
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay));
        // });
      } else {
        emit(FetchMostLikedPropertiesInProgress());
      }
    } else {
      emit(FetchMostLikedPropertiesInProgress());
    }
    try {
      if (forceRefresh == true) {
        DataOutput<PropertyModel> result = await _propertyRepository
            .fetchMostLikeProperty(offset: 0, sendCityName: true);

        emit(FetchMostLikedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total));
      } else {
        if (state is! FetchMostLikedPropertiesSuccess) {
          DataOutput<PropertyModel> result =
              await _propertyRepository.fetchMostLikeProperty(
            offset: 0,
            sendCityName: true,
          );

          emit(
            FetchMostLikedPropertiesSuccess(
                isLoadingMore: false,
                loadingMoreError: false,
                properties: result.modelList,
                offset: 0,
                total: result.total),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<PropertyModel> result =
                  await _propertyRepository.fetchMostLikeProperty(
                offset: 0,
                sendCityName: true,
              );

              emit(
                FetchMostLikedPropertiesSuccess(
                    isLoadingMore: false,
                    loadingMoreError: false,
                    properties: result.modelList,
                    offset: 0,
                    total: result.total),
              );
            },
            onNoInternet: () {
              print("${state.toString()} state is the");
              emit(
                FetchMostLikedPropertiesSuccess(
                    total: (state as FetchMostLikedPropertiesSuccess).total,
                    offset: (state as FetchMostLikedPropertiesSuccess).offset,
                    isLoadingMore: (state as FetchMostLikedPropertiesSuccess)
                        .isLoadingMore,
                    loadingMoreError: (state as FetchMostLikedPropertiesSuccess)
                        .loadingMoreError,
                    properties:
                        (state as FetchMostLikedPropertiesSuccess).properties),
              );
            },
          );
        }
      }
    } catch (e) {
      print("Error is most liked $e");
      emit(FetchMostLikedPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMostLikedPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchMostLikedPropertiesSuccess).properties;

      var index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchMostLikedPropertiesSuccess)
          .copyWith(properties: properties));
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchMostLikedPropertiesSuccess) {
        if ((state as FetchMostLikedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMostLikedPropertiesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchMostLikeProperty(
                offset: (state as FetchMostLikedPropertiesSuccess)
                    .properties
                    .length,
                sendCityName: true);

        FetchMostLikedPropertiesSuccess propertiesState =
            (state as FetchMostLikedPropertiesSuccess);
        propertiesState.properties.addAll(result.modelList);
        emit(FetchMostLikedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchMostLikedPropertiesSuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchMostLikedPropertiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchMostLikedPropertiesSuccess) {
      return (state as FetchMostLikedPropertiesSuccess).properties.length <
          (state as FetchMostLikedPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchMostLikedPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      var state = json['cubit_state'];

      if (state == "FetchMostLikedPropertiesSuccess") {
        return FetchMostLikedPropertiesSuccess.fromMap(json);
      }
    } catch (e) {}

    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchMostLikedPropertiesState state) {
    if (state is FetchMostLikedPropertiesSuccess) {
      Map<String, dynamic> map = state.toMap();
      map['cubit_state'] = "FetchMostLikedPropertiesSuccess";
      return map;
    }
    return null;
  }
}
