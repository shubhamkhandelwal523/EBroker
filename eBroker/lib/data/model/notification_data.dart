import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class NotificationData {
  String? id;
  String? title;
  String? message;
  String? image;
  String? type;
  int? sendType;
  String? customersId;
  String? propertysId;
  String? createdAt;
  String? created;

  NotificationData(
      {this.id,
      this.title,
      this.message,
      this.image,
      this.type,
      this.sendType,
      this.customersId,
      this.propertysId,
      this.createdAt,
      this.created});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    message = json['message'];
    image = json['image'];
    type = json['type'].toString();
    sendType = Adapter.forceInt(json['send_type']);
    customersId = json['customers_id'];
    propertysId = json['propertys_id'].toString();
    createdAt = json['created_at'];
    created = json['created'];
  }
}
