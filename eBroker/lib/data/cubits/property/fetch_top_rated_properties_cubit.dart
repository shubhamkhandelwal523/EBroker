// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchTopRatedPropertiesState {}

class FetchTopRatedPropertiesInitial extends FetchTopRatedPropertiesState {}

class FetchTopRatedPropertiesInProgress extends FetchTopRatedPropertiesState {}

class FetchTopRatedPropertiesSuccess extends FetchTopRatedPropertiesState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> properties;

  FetchTopRatedPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.properties,
  });

  FetchTopRatedPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    List<PropertyModel>? properties,
  }) =>
      FetchTopRatedPropertiesSuccess(
        total: total ?? this.total,
        offset: offset ?? this.offset,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasError: hasMoreData ?? hasError,
        properties: properties ?? this.properties,
      );
}

class FetchTopRatedPropertiesFailure extends FetchTopRatedPropertiesState {
  final String errorMessage;

  FetchTopRatedPropertiesFailure(this.errorMessage);
}

class FetchTopRatedPropertiesCubit extends Cubit<FetchTopRatedPropertiesState> {
  FetchTopRatedPropertiesCubit() : super(FetchTopRatedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchTopRatedProperty() async {
    try {
      emit(FetchTopRatedPropertiesInProgress());
      DataOutput<PropertyModel> result =
          await _propertyRepository.fetchTopRatedProperty();

      emit(
        FetchTopRatedPropertiesSuccess(
          total: result.total,
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          properties: result.modelList,
        ),
      );
    } catch (e) {
      emit(FetchTopRatedPropertiesFailure(e.toString()));
    }
  }
}
