import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/cubits/category/fetch_category_cubit.dart';
import '../../../../data/cubits/property/fetch_most_liked_properties.dart';
import '../../../../data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import '../../../../data/cubits/property/fetch_nearby_property_cubit.dart';
import '../../../../data/cubits/property/fetch_promoted_properties_cubit.dart';
import '../../../../data/cubits/slider_cubit.dart';

class HomePageStateListener {
  Connectivity connectivity = Connectivity();
  bool isNetworkAvailable = true;
  bool isPromotedPropertyEmpty = false;
  bool isCategoryEmpty = false;
  bool isSliderEmpty = false;
  bool isMostViewdPropertyEmpty = false;
  bool isNearbyPropertiesEmpty = false;
  bool isMostLikedPropertiesEmpty = false;
  void init(setState, {required VoidCallback onNetAvailable}) {
    connectivity.onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        isNetworkAvailable = false;
        setState(() {});
      } else {
        onNetAvailable.call();
        isNetworkAvailable = true;
        setState(() {});
      }
    });
  }

  void setNetworkState(setState, isAvailable) {
    isNetworkAvailable = isAvailable;
    setState(() {});
  }

  HomeScreenDataBinding listen(BuildContext context) {
    bool hasPromotedPropertyError = false;
    bool hasMostViewdPropertyError = false;
    bool hasCategoryError = false;

    bool hasNearbyPropertyError = false;
    bool hasMostLikedPropertyError = false;

    bool categorySuccess = false,
        promotedSuccess = false,
        mostVSuccess = false,
        sliderSuccess = false;

    var fetchPromotedPropertiesWatch =
        context.watch<FetchPromotedPropertiesCubit>().state;
    var fetchMostViewedPropertiesWatch =
        context.watch<FetchMostViewedPropertiesCubit>().state;
    var mostLikedPropertiesWatch =
        context.watch<FetchMostLikedPropertiesCubit>().state;
    var nearbyPropertiesWatch =
        context.watch<FetchNearbyPropertiesCubit>().state;

    ///Watching if data is available or not
    if ((fetchPromotedPropertiesWatch is FetchPromotedPropertiesSuccess)) {
      promotedSuccess = true;
      isPromotedPropertyEmpty =
          (fetchPromotedPropertiesWatch).properties.isEmpty;
    }
    if ((fetchMostViewedPropertiesWatch is FetchMostViewedPropertiesSuccess)) {
      mostVSuccess = true;
      isMostViewdPropertyEmpty =
          (fetchMostViewedPropertiesWatch).properties.isEmpty;
    }

    if ((mostLikedPropertiesWatch is FetchMostLikedPropertiesSuccess)) {
      isMostLikedPropertiesEmpty =
          (mostLikedPropertiesWatch).properties.isEmpty;
    }

    if ((nearbyPropertiesWatch is FetchNearbyPropertiesSuccess)) {
      isNearbyPropertiesEmpty = (nearbyPropertiesWatch).properties.isEmpty;
    }

    ///End: Listning to data availability

    ///Listning to realtime state change
    if ((context.watch<FetchCategoryCubit>().state is FetchCategorySuccess)) {
      categorySuccess = true;
    }
    if ((context.watch<SliderCubit>().state is SliderFetchSuccess)) {
      sliderSuccess = true;
    }

    ///End: Listning to realtime state change

    ///Listning to Error
    if ((fetchPromotedPropertiesWatch is FetchPromotedPropertiesFailure)) {
      hasPromotedPropertyError = true;
    }
    if ((fetchMostViewedPropertiesWatch is FetchMostViewedPropertiesFailure)) {
      hasMostViewdPropertyError = true;
    }
    if ((context.watch<FetchCategoryCubit>().state is FetchCategoryFailure)) {
      hasCategoryError = true;
    }

    if (nearbyPropertiesWatch is FetchNearbyPropertiesFailure) {
      hasNearbyPropertyError = true;
    }
    if ((mostLikedPropertiesWatch is FetchMostLikedPropertiesFailure)) {
      hasMostLikedPropertyError = true;
    }

    var dataAvailability = DataAvailibility(
      isPromotedPropertyEmpty: isPromotedPropertyEmpty,
      isCategoryEmpty: isCategoryEmpty,
      isSliderEmpty: isSliderEmpty,
      isMostViewdPropertyEmpty: isMostViewdPropertyEmpty,
      isNearbyPropertiesEmpty: isNearbyPropertiesEmpty,
      isMostLikedPropertiesEmpty: isMostLikedPropertiesEmpty,
    );
    ({
      "hasCategoryError": hasCategoryError,
      "hasMostViewdPropertyError": hasMostViewdPropertyError,
      "hasPromotedPropertyError": hasPromotedPropertyError,
      "hasMostLikedPropertyError": hasMostLikedPropertyError,
      "hasNearbyPropertyError": hasNearbyPropertyError
    }).mlog("HomeScreenState");
    if ((hasCategoryError ||
            hasMostViewdPropertyError ||
            hasPromotedPropertyError ||
            hasMostLikedPropertyError ||
            hasNearbyPropertyError) &&
        isNetworkAvailable) {
      return HomeScreenDataBinding(
          state: HomeScreenDataState.fail, dataAvailability: dataAvailability);
    } else if (sliderSuccess &&
        categorySuccess &&
        promotedSuccess &&
        mostVSuccess) {
      return HomeScreenDataBinding(
          state: HomeScreenDataState.success,
          dataAvailability: dataAvailability);
    } else if (isCategoryEmpty == true &&
        isMostViewdPropertyEmpty == true &&
        isSliderEmpty == true &&
        isPromotedPropertyEmpty == true) {
      return HomeScreenDataBinding(
          state: HomeScreenDataState.nodata,
          dataAvailability: dataAvailability);
    } else if (isNetworkAvailable == false) {
      return HomeScreenDataBinding(
          state: HomeScreenDataState.nointernet,
          dataAvailability: dataAvailability);
    } else {
      return HomeScreenDataBinding(
          state: HomeScreenDataState.normal,
          dataAvailability: dataAvailability);
    }
  }
}

enum HomeScreenDataState { normal, success, nodata, nointernet, fail }

class DataAvailibility {
  final bool isPromotedPropertyEmpty;
  final bool isCategoryEmpty;
  final bool isSliderEmpty;
  final bool isMostViewdPropertyEmpty;
  final bool isNearbyPropertiesEmpty;
  final bool isMostLikedPropertiesEmpty;
  DataAvailibility({
    required this.isPromotedPropertyEmpty,
    required this.isCategoryEmpty,
    required this.isSliderEmpty,
    required this.isMostViewdPropertyEmpty,
    required this.isNearbyPropertiesEmpty,
    required this.isMostLikedPropertiesEmpty,
  });

  @override
  String toString() {
    return 'DataAvailibility(isPromotedPropertyEmpty: $isPromotedPropertyEmpty, isCategoryEmpty: $isCategoryEmpty, isSliderEmpty: $isSliderEmpty, isMostViewdPropertyEmpty: $isMostViewdPropertyEmpty, isNearbyPropertiesEmpty: $isNearbyPropertiesEmpty, isMostLikedPropertiesEmpty: $isMostLikedPropertiesEmpty)';
  }
}

class HomeScreenDataBinding {
  final HomeScreenDataState state;
  final DataAvailibility dataAvailability;
  HomeScreenDataBinding({
    required this.state,
    required this.dataAvailability,
  });

  @override
  String toString() =>
      'HomeScreenDataBinding(state: $state, dataAvailability: $dataAvailability)';
}
