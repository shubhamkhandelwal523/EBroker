// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/utils/api.dart';

class HomeSlider {
  String? id;
  String? image;
  String? categoryId;
  String? propertysId;
  bool? promoted;

  HomeSlider(
      {this.id, this.image, this.categoryId, this.propertysId, this.promoted});

  HomeSlider.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    categoryId = json[Api.categoryId].toString();
    image = json[Api.image];
    propertysId = json[Api.propertysId].toString();
    promoted = json[Api.promoted];
  }

  @override
  String toString() {
    return 'HomeSlider(id: $id, image: $image, categoryId: $categoryId, propertysId: $propertysId, promoted: $promoted)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'categoryId': categoryId,
      'propertysId': propertysId,
      'promoted': promoted,
    };
  }

  factory HomeSlider.fromMap(Map<String, dynamic> map) {
    return HomeSlider(
      id: map['id'] != null ? map['id'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      categoryId:
          map['categoryId'] != null ? map['categoryId'] as String : null,
      propertysId:
          map['propertysId'] != null ? map['propertysId'] as String : null,
      promoted: map['promoted'] != null ? map['promoted'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());
}
