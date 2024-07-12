import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/notifications_repository_repository.dart';
import '../model/data_output.dart';
import '../model/notification_data.dart';

abstract class FetchNotificationsState {}

class FetchNotificationsInitial extends FetchNotificationsState {}

class FetchNotificationsInProgress extends FetchNotificationsState {}

class FetchNotificationsSuccess extends FetchNotificationsState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<NotificationData> notificationdata;
  final int offset;
  final int total;
  FetchNotificationsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.notificationdata,
    required this.offset,
    required this.total,
  });

  FetchNotificationsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<NotificationData>? notificationdata,
    int? offset,
    int? total,
  }) {
    return FetchNotificationsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      notificationdata: notificationdata ?? this.notificationdata,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchNotificationsFailure extends FetchNotificationsState {
  final dynamic errorMessage;
  FetchNotificationsFailure(this.errorMessage);
}

class FetchNotificationsCubit extends Cubit<FetchNotificationsState> {
  FetchNotificationsCubit() : super(FetchNotificationsInitial());

  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  Future fetchNotifications() async {
    try {
      emit(FetchNotificationsInProgress());

      DataOutput<NotificationData> result =
          await _notificationsRepository.fetchNotifications(offset: 0);

      emit(FetchNotificationsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          notificationdata: result.modelList,
          offset: 0,
          total: result.total));
    } catch (e) {
      emit(FetchNotificationsFailure(e));
    }
  }

  Future<void> fetchNotificationsMore() async {
    try {
      if (state is FetchNotificationsSuccess) {
        if ((state as FetchNotificationsSuccess).isLoadingMore) {
          return;
        }
        emit(
            (state as FetchNotificationsSuccess).copyWith(isLoadingMore: true));
        DataOutput<NotificationData> result =
            await _notificationsRepository.fetchNotifications(
          offset: (state as FetchNotificationsSuccess).notificationdata.length,
        );

        FetchNotificationsSuccess notificationdataState =
            (state as FetchNotificationsSuccess);
        notificationdataState.notificationdata.addAll(result.modelList);
        emit(FetchNotificationsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            notificationdata: notificationdataState.notificationdata,
            offset:
                (state as FetchNotificationsSuccess).notificationdata.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchNotificationsSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchNotificationsSuccess) {
      return (state as FetchNotificationsSuccess).notificationdata.length <
          (state as FetchNotificationsSuccess).total;
    }
    return false;
  }
}
