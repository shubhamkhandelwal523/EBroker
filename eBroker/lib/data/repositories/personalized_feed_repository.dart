import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Extensions/lib/map.dart';
import 'package:flutter/material.dart';

enum PersonalizedFeedAction { add, edit, get }

class PersonalizedFeedRepository {
  Future<void> addOrUpdate({
    required PersonalizedFeedAction action,
    required List<int> categoryIds,
    List<int>? outdoorFacilityList,
    RangeValues? priceRange,
    List<int>? selectedPropertyType,
    String? city,
  }) async {
    ////List to String
    String categoryStringArray = categoryIds.join(",");
    String outdoorFacilityStringArray = outdoorFacilityList?.join(",") ?? "";
    String priceRangeString = "${priceRange?.start},${priceRange?.end}";
    String propertyTypeString = "";
    if (selectedPropertyType!.length > 1) {
      propertyTypeString = "";
    } else {
      propertyTypeString = selectedPropertyType.join(",");
    }

    Map<String, dynamic> parameters = {
      "category_ids": categoryStringArray,
      "outdoor_facilitiy_ids": outdoorFacilityStringArray,
      "price_range": priceRangeString,
      "property_type": propertyTypeString,
      "city": city?.toLowerCase()
    };

    parameters.removeEmptyKeys();

    Map<String, dynamic> result =
        await Api.post(url: Api.personalisedFields, parameter: parameters);

    try {
      personalizedInterestSettings =
          PersonalizedInterestSettings.fromMap(result['data']);
    } catch (e) {}
  }

  Future<void> clearPersonalizedSettings(BuildContext context) async {
    try {
      Widgets.showLoader(context);

      ///
      postFrame((t) async {
        await Api.delete(url: Api.personalisedFields);
      });

      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(context, "Successfully cleared",
          type: MessageType.success);
      Navigator.pop(context);
    } catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(context, "Error while clearing settings");
    }
  }

  Future<PersonalizedInterestSettings> getUserPersonalizedSettings() async {
    try {
      Map<String, dynamic> userPersonalization = await Api.get(
        url: Api.personalisedFields,
      );

      return PersonalizedInterestSettings.fromMap(
        userPersonalization['data'],
      );
    } catch (e) {
      return PersonalizedInterestSettings.empty();
    }
  }

  Future<DataOutput<PropertyModel>> getPersonalizedProeprties({
    required int offset,
  }) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getUserRecommendation,
      queryParameters: {
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
      },
    );

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
