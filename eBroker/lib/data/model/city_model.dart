import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class City {
  final String name;
  final int count;
  final String image;
  City({
    required this.name,
    required this.count,
    required this.image,
  });

  @override
  String toString() => 'City(name: $name, count: $count, image: $image)';

  City copyWith({String? name, int? count, String? image}) {
    return City(
        name: name ?? this.name,
        count: count ?? this.count,
        image: image ?? this.image);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'City': name, 'Count': count, "image": image};
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
        name: map['City'] as String,
        count: map['Count'] as int,
        image: map['image']);
  }

  String toJson() => json.encode(toMap());

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);
}
