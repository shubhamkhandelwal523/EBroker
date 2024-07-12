import '../../utils/api.dart';

class HouseType {
  String? id;
  String? type;

  HouseType({this.id, this.type});

  HouseType.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}
