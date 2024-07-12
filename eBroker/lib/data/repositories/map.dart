// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/api.dart';

class GMap {
  static Future<List<MapPoint>> getNearByProperty(
      String city, String state) async {
    try {
      Map<String, dynamic> response = await Api.get(
          url: Api.getNearByProperties,
          queryParameters: {"city": city, "state": state},
          useAuthToken: false);
      response?.mlog("City response");
      List<MapPoint> points = (response['data'] as List).map((e) {
        return MapPoint.fromMap(e);
      }).toList();
      return points;
    } catch (e) {
      rethrow;
    }
  }
}

class MapPoint {
  final String price;
  final String latitude;
  final String longitude;
  final int propertyId;
  final String propertyType;
  MapPoint({
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.propertyId,
    required this.propertyType,
  });

  @override
  String toString() {
    return 'MapPoint(price: $price, latitude: $latitude, longitude: $longitude, propertyId: $propertyId, propertyType: $propertyType)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'id': propertyId,
      'property_type': propertyType,
    };
  }

  factory MapPoint.fromMap(Map<String, dynamic> map) {
    return MapPoint(
      price: map['price'].toString(),
      latitude: map['latitude'].toString(),
      longitude: map['longitude'].toString(),
      propertyId: map['id'] as int,
      propertyType: map['property_type'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MapPoint.fromJson(String source) =>
      MapPoint.fromMap(json.decode(source) as Map<String, dynamic>);
}
