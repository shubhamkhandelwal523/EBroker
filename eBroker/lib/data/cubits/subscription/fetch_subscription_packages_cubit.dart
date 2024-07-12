// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInitial extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInProgress
    extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesSuccess extends FetchSubscriptionPackagesState {
  final List<SubscriptionPackageModel> subscriptionPacakges;
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;

  FetchSubscriptionPackagesSuccess({
    required this.subscriptionPacakges,
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
  });

  FetchSubscriptionPackagesSuccess copyWith({
    List<SubscriptionPackageModel>? subscriptionPacakges,
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
  }) {
    return FetchSubscriptionPackagesSuccess(
      subscriptionPacakges: subscriptionPacakges ?? this.subscriptionPacakges,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchSubscriptionPackagesFailure extends FetchSubscriptionPackagesState {
  final dynamic errorMessage;

  FetchSubscriptionPackagesFailure(this.errorMessage);
}

class FetchSubscriptionPackagesCubit
    extends Cubit<FetchSubscriptionPackagesState> {
  FetchSubscriptionPackagesCubit() : super(FetchSubscriptionPackagesInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  Future<void> fetchPackages() async {
    try {
      emit(FetchSubscriptionPackagesInProgress());
      DataOutput<SubscriptionPackageModel> result =
          await _subscriptionRepository.getSubscriptionPackages(offset: 0);
      emit(FetchSubscriptionPackagesSuccess(
          subscriptionPacakges: result.modelList,
          offset: 0,
          isLoadingMore: false,
          total: result.total,
          hasError: false));
    } catch (e) {
      emit(FetchSubscriptionPackagesFailure(e));
    }
  }

  bool hasMore() {
    if (state is FetchSubscriptionPackagesSuccess) {
      return (state as FetchSubscriptionPackagesSuccess)
              .subscriptionPacakges
              .length <
          (state as FetchSubscriptionPackagesSuccess).total;
    }
    return false;
  }

  fetchMorePackages() async {
    if (state is FetchSubscriptionPackagesInProgress) {
      return;
    }
    try {
      if (state is FetchSubscriptionPackagesSuccess) {
        emit((state as FetchSubscriptionPackagesSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<SubscriptionPackageModel> result =
            await _subscriptionRepository.getSubscriptionPackages(
          offset: (state as FetchSubscriptionPackagesSuccess)
              .subscriptionPacakges
              .length,
        );

        List<SubscriptionPackageModel> subscriptionPacakges =
            (state as FetchSubscriptionPackagesSuccess).subscriptionPacakges;
        subscriptionPacakges.addAll(result.modelList);

        emit(FetchSubscriptionPackagesSuccess(
            subscriptionPacakges: subscriptionPacakges,
            isLoadingMore: false,
            hasError: false,
            offset: subscriptionPacakges.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchSubscriptionPackagesSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }
}
