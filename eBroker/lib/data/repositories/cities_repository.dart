import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';

import '../model/city_model.dart';

class CitiesRepository {
  Future<DataOutput<City>> fetchCitiesData() async {
    try {
      Map<String, dynamic> response =
          await Api.get(url: Api.getCountByCitiesCategory, queryParameters: {});

      List cities = response['city_data'];
      List<City> citiesList = cities.map((e) => City.fromMap(e)).toList();
      return DataOutput(total: citiesList.length, modelList: citiesList);
    } catch (e, sr) {
      throw sr;
    }
  }
}
