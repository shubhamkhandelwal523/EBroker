import '../../utils/api.dart';
import '../model/outdoor_facility.dart';

class OutdoorFacilityRepository {
  Future<List<OutdoorFacility>> fetchOutdoorFacilityList() async {
    Map<String, dynamic> result =
        await Api.get(url: Api.getOutdoorFacilites, queryParameters: {});

    List<OutdoorFacility> outdoorFacilities =
        (result['data'] as List).map((element) {
      return OutdoorFacility.fromJson(element);
    }).toList();

    return List.from(outdoorFacilities);
  }
}
