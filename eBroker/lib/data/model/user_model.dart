// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class UserModel {
  String? address;
  String? createdAt;
  int? customertotalpost;
  String? email;
  String? fcmId;
  String? firebaseId;
  int? id;
  int? isActive;
  bool? isProfileCompleted;
  String? logintype;
  String? mobile;
  String? name;
  int? notification;
  String? profile;
  String? token;
  String? updatedAt;

  UserModel(
      {this.address,
      this.createdAt,
      this.customertotalpost,
      this.email,
      this.fcmId,
      this.firebaseId,
      this.id,
      this.isActive,
      this.isProfileCompleted,
      this.logintype,
      this.mobile,
      this.name,
      this.notification,
      this.profile,
      this.token,
      this.updatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    createdAt = json['created_at'];
    customertotalpost = Adapter.forceInt(json['customertotalpost']);
    email = json['email'];
    fcmId = json['fcm_id'];
    firebaseId = json['firebase_id'];
    id = json['id'];
    isActive = Adapter.forceInt(json['isActive']);
    isProfileCompleted = json['isProfileCompleted'];
    logintype = json['logintype'];
    mobile = json['mobile'];
    name = json['name'];
    notification = (json['notification'] is int)
        ? json['notification']
        : int.parse((json['notification'] ?? "0"));
    profile = json['profile'];
    token = json['token'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['created_at'] = createdAt;
    data['customertotalpost'] = customertotalpost;
    data['email'] = email;
    data['fcm_id'] = fcmId;
    data['firebase_id'] = firebaseId;
    data['id'] = id;
    data['isActive'] = isActive;
    data['isProfileCompleted'] = isProfileCompleted;
    data['logintype'] = logintype;
    data['mobile'] = mobile;
    data['name'] = name;
    data['notification'] = notification;
    data['profile'] = profile;
    data['token'] = token;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  String toString() {
    return 'UserModel(address: $address, createdAt: $createdAt, customertotalpost: $customertotalpost, email: $email, fcmId: $fcmId, firebaseId: $firebaseId, id: $id, isActive: $isActive, isProfileCompleted: $isProfileCompleted, logintype: $logintype, mobile: $mobile, name: $name, notification: $notification, profile: $profile, token: $token, updatedAt: $updatedAt)';
  }
}
