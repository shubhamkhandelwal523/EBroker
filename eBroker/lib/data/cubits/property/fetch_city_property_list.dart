import '../../../exports/main_export.dart';
import '../../../ui/screens/proprties/viewAll.dart';

abstract class FetchCityPropertyListState {}

class FetchCityPropertyInitial extends FetchCityPropertyListState {}

class FetchCityPropertyInProgress extends FetchCityPropertyListState {}

class FetchCityPropertySuccess extends FetchCityPropertyListState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  final String cityName;
  FetchCityPropertySuccess(
      {required this.isLoadingMore,
      required this.loadingMoreError,
      required this.properties,
      required this.cityName,
      required this.offset,
      required this.total});

  @override
  set isLoadingMore(bool _isLoadingMore) {
    // TODO: implement isLoadingMore
  }

  @override
  set properties(List<PropertyModel> _properties) {
    // TODO: implement properties
  }

  FetchCityPropertySuccess copyWith(
      {bool? isLoadingMore,
      bool? loadingMoreError,
      List<PropertyModel>? properties,
      int? offset,
      int? total,
      String? cityName}) {
    return FetchCityPropertySuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      cityName: cityName ?? this.cityName,
    );
  }
}

class FetchCityPropertyFail extends FetchCityPropertyListState
    implements PropertyErrorStateWireframe {
  final dynamic error;
  FetchCityPropertyFail(this.error);

  @override
  set error(_error) {
    // TODO: implement error
  }
}

class FetchCityPropertyList extends Cubit<FetchCityPropertyListState>
    implements PropertyCubitWireframe {
  FetchCityPropertyList() : super(FetchCityPropertyInitial());
  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  void fetch({bool? forceRefresh, String? cityName}) async {
    if (forceRefresh != true) {
      if (state is FetchCityPropertySuccess) {
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(
            const Duration(seconds: AppSettings.hiddenAPIProcessDelay));
        // });
      } else {
        emit(FetchCityPropertyInProgress());
      }
    } else {
      emit(FetchCityPropertyInProgress());
    }
    try {
      DataOutput<PropertyModel> result = await _propertyRepository
          .fetchPropertiesFromCityName(cityName!, offset: 0);
      // log("###THESE ARE ${result.modelList}");
      emit(FetchCityPropertySuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          properties: result.modelList,
          offset: 0,
          cityName: cityName,
          total: result.total));
    } catch (e) {
      emit(FetchCityPropertyFail(e as dynamic));
    }
  }

  @override
  void fetchMore() async {
    try {
      if (state is FetchCityPropertySuccess) {
        if ((state as FetchCityPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCityPropertySuccess).copyWith(isLoadingMore: true));
        DataOutput<PropertyModel> result =
            await _propertyRepository.fetchPropertiesFromCityName(
          (state as FetchCityPropertySuccess).cityName,
          offset: (state as FetchCityPropertySuccess).properties.length,
        );

        FetchCityPropertySuccess propertiesState =
            (state as FetchCityPropertySuccess);
        propertiesState.properties.addAll(result.modelList);
        emit(FetchCityPropertySuccess(
            cityName: (state as FetchCityPropertySuccess).cityName,
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset: (state as FetchCityPropertySuccess).properties.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchCityPropertySuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchCityPropertySuccess) {
      return (state as FetchCityPropertySuccess).properties.length <
          (state as FetchCityPropertySuccess).total;
    }
    return false;
  }
}
