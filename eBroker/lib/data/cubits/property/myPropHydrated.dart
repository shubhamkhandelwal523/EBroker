// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';

abstract class FetchMyPropertiesState {}

class FetchMyPropertiesInitial extends FetchMyPropertiesState {}

class FetchMyPropertiesInProgress extends FetchMyPropertiesState {}

class FetchMyPropertiesSuccess extends FetchMyPropertiesState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> myProperty;
  FetchMyPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.myProperty,
  });

  FetchMyPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    List<PropertyModel>? myProperty,
  }) {
    return FetchMyPropertiesSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasMoreData ?? hasError,
      myProperty: myProperty ?? this.myProperty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isLoadingMore': isLoadingMore,
      'loadingMoreError': hasError,
      'properties': myProperty.map((x) => x.toMap()).toList(),
      'offset': offset,
      'total': total,
    };
  }

  factory FetchMyPropertiesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchMyPropertiesSuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['loadingMoreError'] as bool,
      myProperty: List<PropertyModel>.from(
        (map['properties']).map<PropertyModel>(
          (x) => PropertyModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }
}

class FetchMyPropertiesFailure extends FetchMyPropertiesState {
  final dynamic errorMessage;

  FetchMyPropertiesFailure(this.errorMessage);
}

class FetchMyPropertiesCubit extends Cubit<FetchMyPropertiesState>
    with HydratedMixin {
  FetchMyPropertiesCubit() : super(FetchMyPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchMyProperties({
    bool? forceRefresh,
    required String type,
  }) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchMyPropertiesSuccess) {
          await Future.delayed(
              Duration(seconds: AppSettings.hiddenAPIProcessDelay));
        } else {
          emit(FetchMyPropertiesInProgress());
        }
      } else {
        emit(FetchMyPropertiesInProgress());
      }
      if (forceRefresh == true) {
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchMyProperties(
          offset: 0,
          type: type,
        );
        emit(FetchMyPropertiesSuccess(
            hasError: false,
            isLoadingMore: false,
            myProperty: result.modelList,
            total: result.total,
            offset: 0));
      } else {
        if (state is! FetchMyPropertiesSuccess) {
          DataOutput<PropertyModel> result =
              await _propertyRepository.fetchMyProperties(
            offset: 0,
            type: type,
          );
          emit(FetchMyPropertiesSuccess(
              hasError: false,
              isLoadingMore: false,
              myProperty: result.modelList,
              total: result.total,
              offset: 0));
        } else {
          emit(FetchMyPropertiesSuccess(
              total: (state as FetchMyPropertiesSuccess).total,
              offset: (state as FetchMyPropertiesSuccess).offset,
              isLoadingMore: (state as FetchMyPropertiesSuccess).isLoadingMore,
              hasError: (state as FetchMyPropertiesSuccess).hasError,
              myProperty: (state as FetchMyPropertiesSuccess).myProperty));
        }
      }
    } catch (e) {
      emit(FetchMyPropertiesFailure(e));
    }
  }

  void updateStatus(int propertyId, String currentType) {
    try {
      if (state is FetchMyPropertiesSuccess) {
        List<PropertyModel> propertyList =
            (state as FetchMyPropertiesSuccess).myProperty;
        int index = propertyList.indexWhere((element) {
          return element.id == propertyId;
        });

        if (currentType == "Sell") {
          propertyList[index].properyType = "Sold";
        }
        if (currentType == "Rent") {
          propertyList[index].properyType = "Rented";
        }

        if (currentType == "Rented") {
          propertyList[index].properyType = "Rent";
        }
        if (kDebugMode) {
          if (currentType == "Sold") {
            propertyList[index].properyType = "Sell";
          }
        }

        emit((state as FetchMyPropertiesSuccess)
            .copyWith(myProperty: propertyList));
      }
    } catch (e) {}
  }

  void update(PropertyModel model) {
    if (state is FetchMyPropertiesSuccess) {
      List<PropertyModel> properties =
          (state as FetchMyPropertiesSuccess).myProperty;

      var index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
          (state as FetchMyPropertiesSuccess).copyWith(myProperty: properties));
    }
  }

  Future<void> fetchMoreProperties({required String type}) async {
    try {
      if (state is FetchMyPropertiesSuccess) {
        if ((state as FetchMyPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMyPropertiesSuccess).copyWith(isLoadingMore: true));

        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchMyProperties(
                offset: (state as FetchMyPropertiesSuccess).myProperty.length,
                type: type);

        FetchMyPropertiesSuccess bookingsState =
            (state as FetchMyPropertiesSuccess);
        bookingsState.myProperty.addAll(result.modelList);
        emit(
          FetchMyPropertiesSuccess(
            isLoadingMore: false,
            hasError: false,
            myProperty: bookingsState.myProperty,
            offset: (state as FetchMyPropertiesSuccess).myProperty.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchMyPropertiesSuccess).copyWith(
          isLoadingMore: false,
          hasMoreData: true,
        ),
      );
    }
  }

  void addLocal(PropertyModel model) {
    try {
      if (state is FetchMyPropertiesSuccess) {
        List<PropertyModel> myProperty =
            (state as FetchMyPropertiesSuccess).myProperty;
        if (myProperty.isNotEmpty) {
          myProperty.insert(0, model);
        } else {
          myProperty.add(model);
        }

        emit((state as FetchMyPropertiesSuccess)
            .copyWith(myProperty: myProperty));
      }
    } catch (e, st) {
      throw st;
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPropertiesSuccess) {
      return (state as FetchMyPropertiesSuccess).myProperty.length <
          (state as FetchMyPropertiesSuccess).total;
    }
    return false;
  }

  @override
  FetchMyPropertiesState? fromJson(Map<String, dynamic> json) {
    try {
      var state = json['cubit_state'];

      if (state == "FetchMyPropertiesSuccess") {
        return FetchMyPropertiesSuccess.fromMap(json);
      }
    } catch (e) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchMyPropertiesState state) {
    if (state is FetchMyPropertiesSuccess) {
      Map<String, dynamic> map = state.toMap();
      map['cubit_state'] = "FetchMyPropertiesSuccess";
      return map;
    }
    return null;
  }
}
