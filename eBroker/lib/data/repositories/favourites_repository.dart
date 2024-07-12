import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../model/data_output.dart';
import '../model/property_model.dart';

class FavoriteRepository {
  Future<void> addToFavorite(int id, String type) async {
    Map<String, dynamic> paramerters = {Api.propertyId: id, Api.type: type};

    Map<String, dynamic> map =
        await Api.post(url: Api.addFavourite, parameter: paramerters);
  }

  Future<void> removeFavorite(int id) async {
    Map<String, dynamic> paramerters = {
      Api.propertyId: id,
    };

    await Api.post(url: Api.removeFavorite, parameter: paramerters);
  }

  Future<DataOutput<PropertyModel>> fechFavorites({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> response = await Api.get(
      url: Api.getFavoriteProperty,
      queryParameters: parameters,
    );

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput<PropertyModel>(
        total: response['total'] ?? 0, modelList: modelList);
  }
}
