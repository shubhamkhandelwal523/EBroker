// // ignore_for_file: public_member_api_docs, sort_constructors_first, unused_import
// // To parse this JSON data, do
// //
// //     final DashboardPropertyModal = DashboardPropertyModalFromMap(jsonString);
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';
// import 'package:ebroker/utils/Extensions/lib/string.dart';
//
// class DashboardPropertyModal {
//   DashboardPropertyModal(
//       {this.id,
//       this.title,
//       this.customerName,
//       this.customerEmail,
//       this.customerNumber,
//       this.customerProfile,
//       this.price,
//       this.category,
//       this.builtUpArea,
//       this.plotArea,
//       this.hectaArea,
//       this.acre,
//       this.houseType,
//       this.furnished,
//       this.unitType,
//       this.description,
//       this.address,
//       this.clientAddress,
//       this.properyType,
//       this.titleImage,
//       this.postCreated,
//       this.gallery,
//       this.totalView,
//       this.status,
//       this.state,
//       this.city,
//       this.country,
//       this.addedBy,
//       this.inquiry,
//       this.promoted,
//       this.isFavourite,
//       this.rentduration,
//       this.isInterested,
//       this.favouriteUsers,
//       this.interestedUsers,
//       this.totalInterestedUsers,
//       this.totalFavouriteUsers,
//       this.parameters,
//       this.latitude,
//       this.longitude,
//       this.threeDImage,
//       this.advertisment,
//       this.video,
//       this.assignedOutdoorFacility,
//       this.titleimagehash});
//
//   final int? id;
//   final String? title;
//   final String? price;
//   final String? customerName;
//   final String? customerEmail;
//   final String? customerProfile;
//   final String? customerNumber;
//   final String? rentduration;
//   final Categorys? category;
//   final dynamic builtUpArea;
//   final dynamic plotArea;
//   final dynamic hectaArea;
//   final dynamic acre;
//   final dynamic houseType;
//   final dynamic furnished;
//   final UnitType? unitType;
//   final String? description;
//   final String? address;
//   final String? clientAddress;
//   String? properyType;
//   final String? titleImage;
//   final String? titleimagehash;
//   final String? postCreated;
//   final List<Gallery>? gallery;
//   final int? totalView;
//   final int? status;
//   final String? state;
//   final String? city;
//   final String? country;
//   final int? addedBy;
//   final bool? inquiry;
//   final bool? promoted;
//   final int? isFavourite;
//   final int? isInterested;
//   final List<dynamic>? favouriteUsers;
//   final List<dynamic>? interestedUsers;
//   final int? totalInterestedUsers;
//   final int? totalFavouriteUsers;
//   final List<Parameter>? parameters;
//   final List<AssignedOutdoorFacility>? assignedOutdoorFacility;
//   final String? latitude;
//   final String? longitude;
//   final String? threeDImage;
//   final String? video;
//   final dynamic advertisment;
//   DashboardPropertyModal copyWith(
//           {int? id,
//           String? title,
//           String? price,
//           Categorys? category,
//           dynamic builtUpArea,
//           dynamic plotArea,
//           dynamic hectaArea,
//           dynamic acre,
//           dynamic houseType,
//           dynamic furnished,
//           UnitType? unitType,
//           String? description,
//           String? address,
//           String? clientAddress,
//           String? properyType,
//           String? titleImage,
//           String? postCreated,
//           List<Gallery>? gallery,
//           int? totalView,
//           int? status,
//           String? state,
//           String? city,
//           String? country,
//           int? addedBy,
//           bool? inquiry,
//           bool? promoted,
//           int? isFavourite,
//           int? isInterested,
//           List<dynamic>? favouriteUsers,
//           List<dynamic>? interestedUsers,
//           int? totalInterestedUsers,
//           int? totalFavouriteUsers,
//           List<Parameter>? parameters,
//           List<AssignedOutdoorFacility>? assignedOutdoorFacility,
//           String? latitude,
//           String? longitude,
//           String? threeDimage,
//           String? video,
//           dynamic advertisment,
//           String? rentduration,
//           String? titleImageHash}) =>
//       DashboardPropertyModal(
//           id: id ?? this.id,
//           rentduration: rentduration ?? this.rentduration,
//           advertisment: advertisment ?? this.advertisment,
//           latitude: latitude ?? this.latitude,
//           longitude: longitude ?? this.longitude,
//           title: title ?? this.title,
//           price: price ?? this.price,
//           category: category ?? this.category,
//           builtUpArea: builtUpArea ?? this.builtUpArea,
//           plotArea: plotArea ?? this.plotArea,
//           hectaArea: hectaArea ?? this.hectaArea,
//           acre: acre ?? this.acre,
//           houseType: houseType ?? this.houseType,
//           furnished: furnished ?? this.furnished,
//           unitType: unitType ?? this.unitType,
//           description: description ?? this.description,
//           address: address ?? this.address,
//           clientAddress: clientAddress ?? this.clientAddress,
//           properyType: properyType ?? this.properyType,
//           titleImage: titleImage ?? this.titleImage,
//           postCreated: postCreated ?? this.postCreated,
//           gallery: gallery ?? this.gallery,
//           totalView: totalView ?? this.totalView,
//           status: status ?? this.status,
//           state: state ?? this.state,
//           city: city ?? this.city,
//           country: country ?? this.country,
//           addedBy: addedBy ?? this.addedBy,
//           inquiry: inquiry ?? this.inquiry,
//           promoted: promoted ?? this.promoted,
//           isFavourite: isFavourite ?? this.isFavourite,
//           isInterested: isInterested ?? this.isInterested,
//           favouriteUsers: favouriteUsers ?? this.favouriteUsers,
//           interestedUsers: interestedUsers ?? this.interestedUsers,
//           totalInterestedUsers:
//               totalInterestedUsers ?? this.totalInterestedUsers,
//           totalFavouriteUsers: totalFavouriteUsers ?? this.totalFavouriteUsers,
//           parameters: parameters ?? this.parameters,
//           threeDImage: threeDimage ?? threeDImage,
//           video: video ?? this.video,
//           assignedOutdoorFacility:
//               assignedOutdoorFacility ?? this.assignedOutdoorFacility,
//           titleimagehash: titleImageHash ?? titleimagehash);
//
//   factory DashboardPropertyModal.fromMap(Map<String, dynamic> json) {
//     "PROPERTY DATA:$json".log;
//
//     return DashboardPropertyModal(
//         id: json["id"],
//         rentduration: json['rentduration'],
//         customerEmail: json['email'],
//         customerProfile: json['profile'],
//         customerNumber: json['mobile'],
//         customerName: json['customer_name'],
//         video: json['video_link'],
//         threeDImage: json['threeD_image'],
//         latitude: json['latitude'].toString(),
//         longitude: json["longitude"].toString(),
//         title: json["title"].toString(),
//         price: json["price"].toString(),
//         category: json["category"] == null
//             ? null
//             : Categorys.fromMap(json["category"]),
//         builtUpArea: json["built_up_area"],
//         plotArea: json["plot_area"],
//         hectaArea: json["hecta_area"],
//         acre: json["acre"],
//         houseType: json["house_type"],
//         furnished: json["furnished"],
//         advertisment: json['advertisement'],
//         unitType: json["unit_type"] == null
//             ? null
//             : UnitType.fromMap(json["unit_type"]),
//         description: json["description"],
//         address: json["address"],
//         clientAddress: json["client_address"],
//         properyType: json["property_type"].toString(),
//         titleImage: json["title_image"],
//         postCreated: json["post_created"],
//         gallery: List<Gallery>.from(
//             (json["gallery"] as List).map((x) => Gallery.fromMap(x))),
//         totalView: Adapter.forceInt((json["total_view"] as dynamic)),
//         status: Adapter.forceInt(json["status"]),
//         state: json["state"],
//         city: json["city"],
//         country: json["country"],
//         addedBy: Adapter.forceInt((json["added_by"] as dynamic)),
//         inquiry: json["inquiry"],
//         promoted: json["promoted"],
//         isFavourite: Adapter.forceInt(json["is_favourite"]),
//         isInterested: Adapter.forceInt(json["is_interested"]),
//         favouriteUsers: json["favourite_users"] == null
//             ? null
//             : List<dynamic>.from(json["favourite_users"].map((x) => x)),
//         interestedUsers: json["interested_users"] == null
//             ? null
//             : List<dynamic>.from(json["interested_users"].map((x) => x)),
//         totalInterestedUsers: Adapter.forceInt(json["total_interested_users"]),
//         totalFavouriteUsers: Adapter.forceInt(json["total_favourite_users"]),
//         parameters: json["parameters"] == null
//             ? []
//             : List<Parameter>.from((json["parameters"] as List).map((x) {
//                 return Parameter.fromMap(x);
//               })),
//         assignedOutdoorFacility: json["assign_facilities"] == null
//             ? []
//             : List<AssignedOutdoorFacility>.from(
//                 (json["assign_facilities"] as List).map((x) {
//                 return AssignedOutdoorFacility.fromJson(x);
//               })),
//         titleimagehash: json['title_image_hash']);
//   }
//
//   Map<String, dynamic> toMap() => {
//         "id": id,
//         "rentduration": rentduration,
//         "mobile": customerNumber,
//         "email": customerEmail,
//         "customer_name": customerName,
//         "profile": customerProfile,
//         "threeD_image": threeDImage,
//         "title": title,
//         "latitude": latitude,
//         "longitude": longitude,
//         "advertisment": advertisment,
//         'video_link': video,
//         "price": price,
//         "category": category?.toMap() ?? {},
//         "built_up_area": builtUpArea,
//         "plot_area": plotArea,
//         "hecta_area": hectaArea,
//         "acre": acre,
//         "house_type": houseType,
//         "furnished": furnished,
//         "unit_type": unitType?.toMap() ?? {},
//         "description": description,
//         "address": address,
//         "client_address": clientAddress,
//         "property_type": properyType,
//         "title_image": titleImage,
//         "post_created": postCreated,
//         "gallery": List<Gallery>.from(gallery?.map((x) => x) ?? []),
//         "total_view": totalView,
//         "status": status,
//         "state": state,
//         "city": city,
//         "country": country,
//         "added_by": addedBy,
//         "inquiry": inquiry,
//         "promoted": promoted,
//         "is_favourite": isFavourite,
//         "is_interested": isInterested,
//         "favourite_users": favouriteUsers == null
//             ? null
//             : List<dynamic>.from(favouriteUsers?.map((x) => x) ?? []),
//         "interested_users": interestedUsers == null
//             ? null
//             : List<dynamic>.from(interestedUsers?.map((x) => x) ?? []),
//         "total_interested_users": totalInterestedUsers,
//         "total_favourite_users": totalFavouriteUsers,
//         "assign_facilities": assignedOutdoorFacility == null
//             ? null
//             : List<dynamic>.from(
//                 assignedOutdoorFacility?.map((e) => e.toJson()) ?? []),
//         "parameters": parameters == null
//             ? null
//             : List<dynamic>.from(parameters?.map((x) => x.toMap()) ?? []),
//         "title_image_hash": titleimagehash
//       };
//
//   @override
//   String toString() {
//     return 'DashboardPropertyModal(id: $id,rentduration:$rentduration , title: $title,assigned_facilities:[$assignedOutdoorFacility]  advertisment:$advertisment, price: $price, category: $category,, builtUpArea: $builtUpArea, plotArea: $plotArea, hectaArea: $hectaArea, acre: $acre, houseType: $houseType, furnished: $furnished, unitType: $unitType, description: $description, address: $address, clientAddress: $clientAddress, properyType: $properyType, titleImage: $titleImage, title_image_hash: $titleimagehash, postCreated: $postCreated, gallery: $gallery, totalView: $totalView, status: $status, state: $state, city: $city, country: $country, addedBy: $addedBy, inquiry: $inquiry, promoted: $promoted, isFavourite: $isFavourite, isInterested: $isInterested, favouriteUsers: $favouriteUsers, interestedUsers: $interestedUsers, totalInterestedUsers: $totalInterestedUsers, totalFavouriteUsers: $totalFavouriteUsers, parameters: $parameters, latitude: $latitude, longitude: $longitude, threeD_image: $threeDImage, video: $video)';
//   }
// }
//
// class Categorys {
//   Categorys({
//     this.id,
//     this.category,
//     this.image,
//   });
//
//   final int? id;
//   final String? category;
//   final String? image;
//
//   Categorys copyWith({
//     int? id,
//     String? category,
//     String? image,
//   }) =>
//       Categorys(
//         id: id ?? this.id,
//         category: category ?? this.category,
//         image: image ?? this.image,
//       );
//
//   factory Categorys.fromJson(String str) => Categorys.fromMap(json.decode(str));
//
//   String toJson() => json.encode(toMap());
//
//   factory Categorys.fromMap(Map<String, dynamic> json) => Categorys(
//         id: json["id"],
//         category: json["category"],
//         image: json["image"],
//       );
//
//   Map<String, dynamic> toMap() => {
//         "id": id,
//         "category": category,
//         "image": image,
//       };
// }
//
// class Parameter {
//   Parameter({
//     this.id,
//     this.name,
//     this.typeOfParameter,
//     this.typeValues,
//     this.image,
//     this.value,
//   });
//
//   final int? id;
//   final String? name;
//   final String? typeOfParameter;
//   final dynamic typeValues;
//   final String? image;
//   final dynamic value;
//
//   Parameter copyWith({
//     int? id,
//     String? name,
//     String? typeOfParameter,
//     dynamic typeValues,
//     String? image,
//     dynamic value,
//   }) =>
//       Parameter(
//         id: id ?? this.id,
//         name: name ?? this.name,
//         typeOfParameter: typeOfParameter ?? this.typeOfParameter,
//         typeValues: typeValues ?? this.typeValues,
//         image: image ?? this.image,
//         value: value ?? this.value,
//       );
//
//   static dynamic ifListConvertToString(dynamic value) {
//     if (value is List) {
//       return value.join(",");
//     }
//     return value;
//   }
//
//   factory Parameter.fromMap(Map<String, dynamic> json) {
//     return Parameter(
//       id: json["id"],
//       name: json["name"],
//       typeOfParameter: json["type_of_parameter"],
//       typeValues: json["type_values"],
//       image: json["image"],
//       value: ifListConvertToString(json['value']),
//     );
//   }
//
//   Map<String, dynamic> toMap() => {
//         "id": id,
//         "name": name,
//         "type_of_parameter": typeOfParameter,
//         "type_values": typeValues,
//         "image": image,
//         "value": value,
//       };
//
//   @override
//   String toString() {
//     return 'Parameter(id: $id, name: $name, typeOfParameter: $typeOfParameter, typeValues: $typeValues, image: $image, value: $value)';
//   }
// }
//
// class UnitType {
//   UnitType({
//     this.id,
//     this.measurement,
//   });
//
//   final int? id;
//   final String? measurement;
//
//   UnitType copyWith({
//     int? id,
//     String? measurement,
//   }) =>
//       UnitType(
//         id: id ?? this.id,
//         measurement: measurement ?? this.measurement,
//       );
//
//   factory UnitType.fromJson(String str) => UnitType.fromMap(json.decode(str));
//
//   String toJson() => json.encode(toMap());
//
//   factory UnitType.fromMap(Map<String, dynamic> json) => UnitType(
//         id: json["id"],
//         measurement: json["measurement"],
//       );
//
//   Map<String, dynamic> toMap() => {
//         "id": id,
//         "measurement": measurement,
//       };
// }
//
// class Gallery {
//   final int id;
//   final String image;
//   final String imageUrl;
//   final bool? isVideo;
//   Gallery(
//       {required this.id,
//       required this.image,
//       required this.imageUrl,
//       this.isVideo});
//
//   Gallery copyWith({
//     int? id,
//     String? image,
//     String? imageUrl,
//   }) {
//     return Gallery(
//       id: id ?? this.id,
//       image: image ?? this.image,
//       imageUrl: imageUrl ?? this.imageUrl,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'image': image,
//       'image_url': imageUrl,
//     };
//   }
//
//   factory Gallery.fromMap(Map<String, dynamic> map) {
//     return Gallery(
//       id: map['id'] as int,
//       image: map['image'] as String,
//       imageUrl: map['image_url'] ?? "",
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory Gallery.fromJson(String source) =>
//       Gallery.fromMap(json.decode(source) as Map<String, dynamic>);
//
//   @override
//   String toString() => 'Gallery(id: $id, image: $image, imageUrl: $imageUrl)';
//
//   @override
//   bool operator ==(covariant Gallery other) {
//     if (identical(this, other)) return true;
//
//     return other.id == id && other.image == image && other.imageUrl == imageUrl;
//   }
//
//   @override
//   int get hashCode => id.hashCode ^ image.hashCode ^ imageUrl.hashCode;
// }
//
// class AssignedOutdoorFacility {
//   int? id;
//   int? propertyId;
//   int? facilityId;
//   int? distance;
//   String? image;
//   String? name;
//   String? createdAt;
//   String? updatedAt;
//
//   AssignedOutdoorFacility(
//       {this.id,
//       this.propertyId,
//       this.facilityId,
//       this.distance,
//       this.createdAt,
//       this.name,
//       this.image,
//       this.updatedAt});
//
//   AssignedOutdoorFacility.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     propertyId = json['property_id'];
//     facilityId = json['facility_id'];
//     distance = json['distance'];
//     createdAt = json['created_at'];
//     image = json['image'];
//     name = json['name'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['id'] = this.id;
//     data['property_id'] = this.propertyId;
//     data['facility_id'] = this.facilityId;
//     data['distance'] = this.distance;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['image'] = image;
//     data['name'] = name;
//     return data;
//   }
//
//   @override
//   String toString() {
//     return 'AssignedOutdoorFacility{id: $id, propertyId: $propertyId, facilityId: $facilityId, distance: $distance, image: $image, name: $name, createdAt: $createdAt, updatedAt: $updatedAt}';
//   }
// }
