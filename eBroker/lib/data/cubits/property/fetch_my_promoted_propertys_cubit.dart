import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/data_output.dart';
import '../../model/property_model.dart';
import '../../repositories/property_repository.dart';

abstract class FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInitial extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInProgress
    extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysSuccess extends FetchMyPromotedPropertysState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<PropertyModel> propertymodel;
  final int offset;
  final int total;
  FetchMyPromotedPropertysSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.propertymodel,
    required this.offset,
    required this.total,
  });

  FetchMyPromotedPropertysSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchMyPromotedPropertysSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      propertymodel: propertymodel ?? this.propertymodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchMyPromotedPropertysFailure extends FetchMyPromotedPropertysState {
  final dynamic errorMessage;
  FetchMyPromotedPropertysFailure(this.errorMessage);
}

class FetchMyPromotedPropertysCubit
    extends Cubit<FetchMyPromotedPropertysState> {
  FetchMyPromotedPropertysCubit() : super(FetchMyPromotedPropertysInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> fetchMyPromotedPropertys() async {
    try {
      emit(FetchMyPromotedPropertysInProgress());

      DataOutput<PropertyModel> result =
          await _propertyRepository.fetchMyPromotedProeprties(offset: 0);

      emit(
        FetchMyPromotedPropertysSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          propertymodel: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchMyPromotedPropertysFailure(e));
    }
  }

  void delete(dynamic id) {
    if (state is FetchMyPromotedPropertysSuccess) {
      List<PropertyModel> propertymodel =
          (state as FetchMyPromotedPropertysSuccess).propertymodel;
      propertymodel.removeWhere((element) => element.id == id);

      emit((state as FetchMyPromotedPropertysSuccess)
          .copyWith(propertymodel: propertymodel));
    }
  }

  Future<void> fetchMyPromotedPropertysMore() async {
    try {
      if (state is FetchMyPromotedPropertysSuccess) {
        if ((state as FetchMyPromotedPropertysSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMyPromotedPropertysSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchMyPromotedProeprties(
          offset:
              (state as FetchMyPromotedPropertysSuccess).propertymodel.length,
        );

        FetchMyPromotedPropertysSuccess propertymodelState =
            (state as FetchMyPromotedPropertysSuccess);
        propertymodelState.propertymodel.addAll(result.modelList);
        emit(FetchMyPromotedPropertysSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            propertymodel: propertymodelState.propertymodel,
            offset:
                (state as FetchMyPromotedPropertysSuccess).propertymodel.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchMyPromotedPropertysSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPromotedPropertysSuccess) {
      return (state as FetchMyPromotedPropertysSuccess).propertymodel.length <
          (state as FetchMyPromotedPropertysSuccess).total;
    }
    return false;
  }

  void update(PropertyModel model) {
    if (state is FetchMyPromotedPropertysSuccess) {
      List<PropertyModel> properties =
          (state as FetchMyPromotedPropertysSuccess).propertymodel;

      var index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit((state as FetchMyPromotedPropertysSuccess)
          .copyWith(propertymodel: properties));
    }
  }
}
