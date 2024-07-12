import 'dart:convert';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../helper/custom_exception.dart';
import '../../model/notification_data.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationSetProgress extends NotificationState {}

class NotificationSetSuccess extends NotificationState {
  List<NotificationData> notificationlist = [];
  NotificationSetSuccess(this.notificationlist);
}

class NotificationSetFailure extends NotificationState {
  final String errmsg;
  NotificationSetFailure(this.errmsg);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void getNotification(
    BuildContext context,
  ) {
    emit(NotificationSetProgress());
    getNotificationFromDb(
      context,
    )
        .then((value) => emit(NotificationSetSuccess(value)))
        .catchError((e) => emit(NotificationSetFailure(e.toString())));
  }

  Future<List<NotificationData>> getNotificationFromDb(
    BuildContext context,
  ) async {
    Map<String, String> body = {};
    List<NotificationData> notificationList = [];
    var response = await HelperUtils.sendApiRequest(
      Api.apiGetNotificationList,
      body,
      false,
      context,
    );
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        List list = getdata['data'];
        notificationList =
            list.map((model) => NotificationData.fromJson(model)).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }
    return notificationList;
  }
}
