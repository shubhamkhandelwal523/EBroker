// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GooglePlaceModel {
  final String city;
  final String description;
  final String placeId;
  final String latitude;
  final String longitude;
  final String state;
  final String country;

  GooglePlaceModel({
    required this.state,
    required this.country,
    required this.city,
    required this.description,
    required this.placeId,
    required this.latitude,
    required this.longitude,
  });

  GooglePlaceModel copyWith(
      {String? name,
      String? cityName,
      String? placeId,
      String? latitude,
      String? longitude,
      String? state,
      String? country}) {
    return GooglePlaceModel(
      city: name ?? city,
      state: state ?? this.state,
      country: country ?? this.country,
      description: cityName ?? description,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': city,
      'desctiption': description,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'country': country
    };
  }

  factory GooglePlaceModel.fromMap(Map<String, dynamic> map) {
    return GooglePlaceModel(
      country: map['country'] as String,
      state: map['state'] as String,
      city: map['name'] as String,
      description: map['cityName'] as String,
      placeId: map['placeId'] as String,
      latitude: map['latitude'] as String,
      longitude: map['longitude'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GooglePlaceModel.fromJson(String source) =>
      GooglePlaceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GooglePlaceModel(city: $city, description: $description, placeId: $placeId, latitude: $latitude, longitude: $longitude, state: $state, country: $country)';
  }

  @override
  bool operator ==(covariant GooglePlaceModel other) {
    if (identical(this, other)) return true;

    return other.city == city &&
        other.description == description &&
        other.placeId == placeId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return city.hashCode ^
        description.hashCode ^
        placeId.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
