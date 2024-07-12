// ignore_for_file: file_names

import 'dart:developer';

import 'package:ebroker/data/model/chat/chated_user_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

import '../../ui/screens/chat/chat_screen.dart';

String currentlyChatingWith = "";
String currentlyChatPropertyId = "";

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwsomeNotification localNotification = LocalAwsomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;
  static requestPermission() async {}

  void updateFCM() async {
    await FirebaseMessaging.instance.getToken();
    // await Api.post(
    //     // url: Api.updateFCMId,
    //     parameter: {Api.fcmId: token},
    //     useAuthToken: true);
  }

  static handleNotification(RemoteMessage? message, [BuildContext? context]) {
    var notificationType = message?.data['type'] ?? "";

    log("@notificaiton data is ${message?.data}");

    if (notificationType == "chat") {
      var senderId = message?.data['sender_id'] ?? "";
      var chatMessage = message?.data['message'] ?? "";
      var attachment = message?.data['file'] ?? "";
      var audioMessage = message?.data['audio'] ?? "";
      var time = message?.data['date'] ?? "";
      var username = message!.data['username'];
      var propertyTitleImage = message.data['property_title_image'];
      var propertyTitle = message.data['title'];
      var userProfile = message.data['user_profile'];
      var propertyId = message.data['property_id'];

      (context as BuildContext).read<GetChatListCubit>().addNewChat(ChatedUser(
            fcmId: "",
            firebaseId: "",
            name: username,
            profile: userProfile,
            propertyId:
                (propertyId is int) ? propertyId : int.parse(propertyId),
            title: propertyTitle,
            userId: (senderId is int) ? senderId : int.parse(senderId),
            titleImage: propertyTitleImage,
          ));

      ///Checking if this is user we are chatiing with
      if (senderId == currentlyChatingWith &&
          propertyId == currentlyChatPropertyId) {
        ChatMessageModel chatMessageModel =
            ChatMessageModel.fromJson(message.data);
        chatMessageModel.setIsSentByMe(false);
        chatMessageModel.setIsSentNow(false);
        ChatMessageHandler.add(chatMessageModel);
        // ChatMessageHandlerOLD.add(
        //   Builder(builder: (context) {
        //     return ChatMessage(
        //       key: ValueKey(DateTime.now().toString().toString()),
        //       message: chatMessage,
        //       isSentByMe: false,
        //       propertyId: "",
        //       reciverId: "",
        //       isChatAudio: audioMessage != null && audioMessage != "",
        //       audioFile: audioMessage,
        //       attachment: attachment,
        //       hasAttachment: attachment != "" && attachment != null,
        //       senderId: senderId,
        //       time: time,
        //     );
        //   }),
        // );
        totalMessageCount++;
      } else {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
        );
      }
    } else if (notificationType == "delete_message") {
      ChatMessageHandlerOLD.removeMessage(
          int.parse(message!.data['message_id']));
    } else {
      localNotification.createNotification(
          isLocked: false, notificationData: message!);
    }
  }

  static void init(context) {
    requestPermission();
    registerListeners(context);
  }

  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    if (message.notification == null) {
      handleNotification(
        message,
      );
    }
  }

  static forgroundNotificationHandler(BuildContext context) async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotification(message, context);
    });
  }

  static terminatedStateNotificationHandler(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.notification == null) {
          handleNotification(message, context);
        }
      },
    );
  }

  static void onTapNotificationHandler(context) {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) async {
      if (message.data['type'] == "chat") {
        var username = message.data['title'];
        var propertyTitleImage = message.data['property_title_image'];
        var propertyTitle = message.data['property_title'];
        var userProfile = message.data['user_profile'];
        var senderId = message.data['sender_id'];
        var propertyId = message.data['property_id'];
        Future.delayed(
          Duration.zero,
          () {
            Navigator.push(Constant.navigatorKey.currentContext!,
                MaterialPageRoute(
              builder: (context) {
                return BlocProvider(
                  create: (context) {
                    return LoadChatMessagesCubit();
                  },
                  child: Builder(builder: (context) {
                    return ChatScreen(
                      profilePicture: userProfile ?? "",
                      userName: username ?? "",
                      propertyImage: propertyTitleImage ?? "",
                      proeprtyTitle: propertyTitle ?? "",
                      userId: senderId ?? "",
                      propertyId: propertyId ?? "",
                    );
                  }),
                );
              },
            ));
          },
        );
      } else {
        String id = message.data["id"] ?? "";
        DataOutput<PropertyModel> property =
            await PropertyRepository().fetchPropertyFromPropertyId(id);
        Future.delayed(Duration.zero, () {
          HelperUtils.goToNextPage(Routes.propertyDetails,
              Constant.navigatorKey.currentContext!, false,
              args: {
                'propertyData': property.modelList[0],
                'propertiesList': property.modelList,
                'fromMyProperty': false,
              });
        });
      }
    }
            // if (message.data["screen"] == "profile") {
            //   Navigator.pushNamed(context, profileRoute);
            // }

            );
  }

  static Future<void> registerListeners(context) async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    await forgroundNotificationHandler(context);
    await terminatedStateNotificationHandler(context);
    onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
