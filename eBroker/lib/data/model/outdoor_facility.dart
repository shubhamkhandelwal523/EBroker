class OutdoorFacility {
  int? id;
  String? name;
  String? image;
  String? distance;
  String? createdAt;
  String? updatedAt;

  OutdoorFacility(
      {this.id, this.name, this.image, this.createdAt, this.updatedAt,this.distance});

  OutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    distance=json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['distance']=distance;
    return data;
  }

  @override
  String toString() {
    return 'OutdoorFacility{id: $id, name: $name, image: $image, distance: $distance, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
