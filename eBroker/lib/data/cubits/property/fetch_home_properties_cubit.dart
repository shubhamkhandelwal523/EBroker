// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchHomePropertiesState {}

class FetchHomePropertiesInitial extends FetchHomePropertiesState {}

class FetchHomePropertiesInProgress extends FetchHomePropertiesState {}

class FetchHomePropertiesSuccess extends FetchHomePropertiesState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> property;

  FetchHomePropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.property,
  });

  FetchHomePropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    List<PropertyModel>? property,
  }) {
    return FetchHomePropertiesSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasMoreData ?? hasError,
      property: property ?? this.property,
    );
  }
}

class FetchHomePropertiesFailure extends FetchHomePropertiesState {
  final String errorMessage;

  FetchHomePropertiesFailure(this.errorMessage);
}

class FetchHomePropertiesCubit extends Cubit<FetchHomePropertiesState> {
  final PropertyRepository _propertyRepository = PropertyRepository();
  FetchHomePropertiesCubit() : super(FetchHomePropertiesInitial());

  void fetchProperty() async {
    try {
      emit(FetchHomePropertiesInProgress());
      DataOutput<PropertyModel> result =
          await _propertyRepository.fetchProperty(offset: 0);
      emit(FetchHomePropertiesSuccess(
        hasError: false,
        isLoadingMore: false,
        offset: 0,
        property: result.modelList,
        total: result.total,
      ));
    } catch (e) {
      emit(FetchHomePropertiesFailure(e.toString()));
    }
  }

  Future<void> fetchMoreProperty() async {
    try {
      if (state is FetchHomePropertiesSuccess) {
        if ((state as FetchHomePropertiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchHomePropertiesSuccess)
            .copyWith(isLoadingMore: true));

        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchProperty(
          offset: (state as FetchHomePropertiesSuccess).property.length,
        );

        FetchHomePropertiesSuccess bookingsState =
            (state as FetchHomePropertiesSuccess);
        bookingsState.property.addAll(result.modelList);
        emit(
          FetchHomePropertiesSuccess(
            isLoadingMore: false,
            hasError: false,
            property: bookingsState.property,
            offset: (state as FetchHomePropertiesSuccess).property.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchHomePropertiesSuccess).copyWith(
          isLoadingMore: false,
          hasMoreData: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchHomePropertiesSuccess) {
      return (state as FetchHomePropertiesSuccess).property.length <
          (state as FetchHomePropertiesSuccess).total;
    }
    return false;
  }
}
