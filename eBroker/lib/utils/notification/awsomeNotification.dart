// ignore_for_file: file_names

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';

class LocalAwsomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();
  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
      null,
      [
        NotificationChannel(
            channelKey: Constant.notificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            importance: NotificationImportance.Max,
            ledColor: Colors.grey),
        NotificationChannel(
            channelKey: "Chat Notification",
            channelName: 'Chat Notifications',
            channelDescription: 'Chat Notifications',
            importance: NotificationImportance.Max,
            ledColor: Colors.grey)
      ],
      channelGroups: [],
    );
    listenTap(context);
  }

  void listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  createNotification(
      {required RemoteMessage notificationData, required bool isLocked}) async {
    try {
      bool isChat = notificationData.data["type"] == "chat";

      int chatId = int.parse(notificationData.data['sender_id']) +
          int.parse(notificationData.data['property_id']);

      await notification.createNotification(
        content: NotificationContent(
          id: isChat ? chatId : Random().nextInt(5000),
          title: notificationData.data["title"],

          // icon: AppIcons.aboutUs,
          hideLargeIconOnExpand: true,
          summary: notificationData.data["type"] == "chat"
              ? "${notificationData.data['username']}"
              : null,
          locked: isLocked,
          payload: Map.from(notificationData.data),
          autoDismissible: true,

          body: notificationData.data["body"],
          wakeUpScreen: true,

          notificationLayout: notificationData.data["type"] == "chat"
              ? NotificationLayout.MessagingGroup
              : NotificationLayout.Default,
          groupKey: notificationData.data["id"],
          channelKey: notificationData.data["type"] == "chat"
              ? "Chat Notification"
              : Constant.notificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: Constant.notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );
      await notification.requestPermissionToSendNotifications(
        channelKey: "Chat Notification",
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload;

    if (payload?['type'] == "chat") {
      var username = payload?['username'];
      var propertyTitleImage = payload?['property_title_image'];
      var propertyTitle = payload?['title'];
      var userProfile = payload?['user_profile'];
      var senderId = payload?['sender_id'];
      var propertyId = payload?['property_id'];
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => LoadChatMessagesCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMessageCubit(),
                  ),
                ],
                child: Builder(builder: (context) {
                  return ChatScreen(
                      profilePicture: userProfile!,
                      userName: username ?? "",
                      propertyImage: propertyTitleImage ?? "",
                      proeprtyTitle: propertyTitle ?? "",
                      userId: senderId ?? "",
                      propertyId: propertyId ?? "");
                }),
              );
            },
          ));
        },
      );
    } else {
      String id = receivedAction.payload?["id"] ?? "";

      DataOutput<PropertyModel> property =
          await PropertyRepository().fetchPropertyFromPropertyId(id);

      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.goToNextPage(Routes.propertyDetails,
              Constant.navigatorKey.currentContext!, false,
              args: {
                'propertyData': property.modelList[0],
                'propertiesList': property.modelList,
                'fromMyProperty': false,
              });
        },
      );
    }
  }
}
