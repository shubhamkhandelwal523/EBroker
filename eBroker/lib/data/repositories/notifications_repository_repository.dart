import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/hive_utils.dart';
import '../model/data_output.dart';
import '../model/notification_data.dart';

class NotificationsRepository {
  Future<DataOutput<NotificationData>> fetchNotifications(
      {required int offset}) async {
    try {
      Map<String, dynamic> parameters = {
        Api.userid: HiveUtils.getUserId(),
        Api.offset: offset,
        Api.limit: Constant.loadLimit
      };
      Map<String, dynamic> response = await Api.get(
        url: Api.apiGetNotifications,
        queryParameters: parameters,
      );

      List<NotificationData> modelList = (response['data'] as List).map((e) {
        return NotificationData.fromJson(e);
      }).toList();

      return DataOutput(
        total: 0,
        modelList: modelList,
      );
    } catch (e) {
      rethrow;
    }
  }
}
