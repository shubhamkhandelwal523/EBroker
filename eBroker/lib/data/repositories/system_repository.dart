import 'package:ebroker/exports/main_export.dart';

class SystemRepository {
  Future<Map> fetchSystemSettings({required bool isAnonymouse}) async {
    Map<String, dynamic> parameters = {};

    ///Passing user id here because we will hide sensitive details if there is no user id,
    ///With user id we will get user subscription package details
    if (!isAnonymouse) {
      if (HiveUtils.getUserId() != null) {
        print("UID IS ${HiveUtils.getUserId()}");
        parameters['user_id'] = HiveUtils.getUserId();
      }
    }

    Map<String, dynamic> response = await Api.post(
        url: Api.apiGetSystemSettings,
        parameter: parameters,
        useAuthToken: !isAnonymouse);

    return response;
  }
}
