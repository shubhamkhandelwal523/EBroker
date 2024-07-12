import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../../utils/Network/networkAvailability.dart';

abstract class FetchRecentPropertiesState {}

class FetchRecentProepertiesInitial extends FetchRecentPropertiesState {}

class FetchRecentPropertiesInProgress extends FetchRecentPropertiesState {}

class FetchRecentPropertiesSuccess extends FetchRecentPropertiesState
    implements PropertySuccessStateWireframe {
  final int total;
  final int offset;
  @override
  final bool isLoadingMore;
  final bool hasError;
  @override
  final List<PropertyModel> properties;

  FetchRecentPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.properties,
  });

  FetchRecentPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    List<PropertyModel>? properties,
  }) {
    return FetchRecentPropertiesSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      properties: properties ?? this.properties,
    );
  }

  @override
  set properties(List<PropertyModel> _properties) {
    // TODO: implement properties
  }

  @override
  set isLoadingMore(bool _isLoadingMore) {
    // TODO: implement isLoadingMore
  }

  Map<String, dynamic> toMap() {
    return {
      'total': this.total,
      'offset': this.offset,
      'isLoadingMore': this.isLoadingMore,
      'hasError': this.hasError,
      'properties': properties.map((e) => e.toMap()).toList(),
    };
  }

  factory FetchRecentPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchRecentPropertiesSuccess(
      total: map['total'] as int,
      offset: map['offset'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      properties: (map['properties'] as List)
          .map((e) => PropertyModel.fromMap(e))
          .toList(),
    );
  }
}

class FetchRecentPropertiesFailur extends FetchRecentPropertiesState
    implements PropertyErrorStateWireframe {
  final dynamic error;

  FetchRecentPropertiesFailur(this.error);

  @override
  set error(_error) {}
}

class FetchRecentPropertiesCubit extends Cubit<FetchRecentPropertiesState>
    with HydratedMixin
    implements PropertyCubitWireframe {
  FetchRecentPropertiesCubit() : super(FetchRecentProepertiesInitial()) {
    hydrate();
  }

  final PropertyRepository _propertyRepository = PropertyRepository();
  @override
  void fetch({bool? forceRefresh, bool? loadWithoutDelay}) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchRecentPropertiesSuccess) {
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(Duration(
              seconds: loadWithoutDelay == true
                  ? 0
                  : AppSettings.hiddenAPIProcessDelay));
          // });
        } else {
          emit(FetchRecentPropertiesInProgress());
        }
      } else {
        emit(FetchRecentPropertiesInProgress());
      }

      if (forceRefresh == true) {
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchRecentProperties(offset: 0);
        // log("API RESULT IS $result");
        emit(
          FetchRecentPropertiesSuccess(
              total: result.total,
              offset: 0,
              isLoadingMore: false,
              hasError: false,
              properties: result.modelList),
        );
      } else {
        if (state is! FetchRecentPropertiesSuccess) {
          DataOutput<PropertyModel> result =
              await _propertyRepository.fetchRecentProperties(offset: 0);
          emit(
            FetchRecentPropertiesSuccess(
                total: result.total,
                offset: 0,
                isLoadingMore: false,
                hasError: false,
                properties: result.modelList),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              DataOutput<PropertyModel> result =
                  await _propertyRepository.fetchRecentProperties(offset: 0);
              emit(
                FetchRecentPropertiesSuccess(
                    total: result.total,
                    offset: 0,
                    isLoadingMore: false,
                    hasError: false,
                    properties: result.modelList),
              );
            },
            onNoInternet: () {
              emit(
                FetchRecentPropertiesSuccess(
                    total: (state as FetchRecentPropertiesSuccess).total,
                    offset: (state as FetchRecentPropertiesSuccess).offset,
                    isLoadingMore:
                        (state as FetchRecentPropertiesSuccess).isLoadingMore,
                    hasError: (state as FetchRecentPropertiesSuccess).hasError,
                    properties:
                        (state as FetchRecentPropertiesSuccess).properties),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchRecentPropertiesFailur(e.toString()));
    }
  }

  @override
  void fetchMore() async {
    if (state is FetchRecentPropertiesSuccess) {
      FetchRecentPropertiesSuccess mystate =
          (state as FetchRecentPropertiesSuccess);
      if (mystate.isLoadingMore) {
        return;
      }
      emit((state as FetchRecentPropertiesSuccess)
          .copyWith(isLoadingMore: true));
      DataOutput<PropertyModel> result =
          await _propertyRepository.fetchRecentProperties(
        offset: (state as FetchRecentPropertiesSuccess).properties.length,
      );
      FetchRecentPropertiesSuccess propertymodelState =
          (state as FetchRecentPropertiesSuccess);
      propertymodelState.properties.addAll(result.modelList);
      emit(FetchRecentPropertiesSuccess(
          isLoadingMore: false,
          hasError: false,
          properties: propertymodelState.properties,
          offset: (state as FetchRecentPropertiesSuccess).properties.length,
          total: result.total));
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchRecentPropertiesSuccess) {
      return (state as FetchRecentPropertiesSuccess).properties.length <
          (state as FetchRecentPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchRecentPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchRecentPropertiesSuccess") {
        FetchRecentPropertiesSuccess fetchRecentPropertiesSuccess =
            FetchRecentPropertiesSuccess.fromMap(json);

        return fetchRecentPropertiesSuccess;
      }
    } catch (e, st) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchRecentPropertiesState state) {
    try {
      if (state is FetchRecentPropertiesSuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchRecentPropertiesSuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
