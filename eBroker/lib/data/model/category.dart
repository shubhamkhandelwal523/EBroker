// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/utils/api.dart';

class Category {
  String? id;
  String? category;
  String? image;
  //String? typeids;
  //List<Type>? type;
  List? parameterTypes;
  //List<Map> fields = [];
  Category({this.id, this.category, this.image, this.parameterTypes});

  Category.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    category = json[Api.category];
    image = json[Api.image] ?? "";
    parameterTypes = json[Api.parameterTypes] is Map
        ? json[Api.parameterTypes]['parameters']
        : (json[Api.parameterTypes] ?? []);
  }

  Category.fromProperty(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    category = json[Api.category];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'image': image,
      'parameterTypes': parameterTypes,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] != null ? map['id'] as String : null,
      category: map['category'] != null ? map['category'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      parameterTypes: map['parameterTypes'],
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Category(id: $id, category: $category, image: $image, parameterTypes: $parameterTypes)';
  }
}

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}
