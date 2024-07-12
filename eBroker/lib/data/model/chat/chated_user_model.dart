import 'dart:developer';

import 'package:flutter/material.dart';

class ChatedUser {
  int? propertyId;
  String? title;
  String? titleImage;
  int? userId;
  String? name;
  String? profile;
  String? firebaseId;
  String? fcmId;

  ChatedUser(
      {this.propertyId,
      this.title,
      this.titleImage,
      this.userId,
      this.name,
      this.profile,
      this.firebaseId,
      this.fcmId});

  ChatedUser.fromJson(Map<String, dynamic> json, {BuildContext? context}) {
    if (context != null) {
      precacheImage(NetworkImage(json['profile']), context);
      precacheImage(NetworkImage(json['title_image']), context);
    }
    propertyId = json['property_id'];
    title = json['title'];
    titleImage = json['title_image'];
    userId = json['user_id'];
    name = json['name'];
    profile = json['profile'];
    firebaseId = json['firebase_id'];
    fcmId = json['fcm_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['property_id'] = propertyId;
    data['title'] = title;
    data['title_image'] = titleImage;
    data['user_id'] = userId;
    data['name'] = name;
    data['profile'] = profile;
    data['firebase_id'] = firebaseId;
    data['fcm_id'] = fcmId;
    return data;
  }
}
