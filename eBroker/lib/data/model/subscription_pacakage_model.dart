// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/utils/helper_utils.dart';

class SubscriptionPackageModel {
  int? id;
  String? iosProductId;
  String? name;
  int? duration;
  num? price;
  int? status;
  dynamic propertyLimit;
  dynamic advertisementLimit;
  String? createdAt;
  String? updatedAt;
  int? isActive;
  int? usedLimitForProperty;
  int? usedLimitForAdvertisement;
  int? propertyStatus;
  int? advertisementStatus;
  String? startDate;
  String? endDate;
  int? remainingDays;
  String? type;
  SubscriptionPackageModel(
      {this.id,
      this.iosProductId,
      this.name,
      this.duration,
      this.price,
      this.status,
      this.propertyLimit,
      this.advertisementLimit,
      this.createdAt,
      this.updatedAt,
      this.isActive,
      this.usedLimitForProperty,
      this.usedLimitForAdvertisement,
      this.propertyStatus,
      this.advertisementStatus,
      this.startDate,
      this.type,
      this.endDate,
      this.remainingDays});

  SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    iosProductId = json['ios_product_id'];
    name = json['name'];
    duration = json['duration'];
    price = json['price'];
    status = json['status'];
    propertyLimit = json['property_limit'];
    advertisementLimit = json['advertisement_limit'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isActive = json['is_active'];
    usedLimitForProperty = json['used_limit_for_property'];
    usedLimitForAdvertisement = json['used_limit_for_advertisement'];
    propertyStatus = json['property_status'];
    advertisementStatus = json['advertisement_status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    remainingDays = json['remaining_days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['type'] = type;
    data['ios_product_id'] = iosProductId;
    data['name'] = name;
    data['duration'] = duration;
    data['price'] = price;
    data['status'] = status;
    data['property_limit'] = propertyLimit;
    data['advertisement_limit'] = advertisementLimit;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_active'] = isActive;
    data['used_limit_for_property'] = usedLimitForProperty;
    data['used_limit_for_advertisement'] = usedLimitForAdvertisement;
    data['property_status'] = propertyStatus;
    data['advertisement_status'] = advertisementStatus;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['remaining_days'] = remainingDays;
    return data;
  }
}
