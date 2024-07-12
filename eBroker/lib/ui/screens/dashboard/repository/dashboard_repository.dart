// import 'package:ebroker/ui/screens/Dashboard/Models/dashboard_property.dart';
// import 'package:ebroker/data/model/data_output.dart';
// import 'package:ebroker/utils/api.dart';
// import 'package:ebroker/utils/constant.dart';
//
// mixin DashboardPropertyParameters {
//   abstract Map<String, dynamic> parameters;
// }
//
// class Parameter {
//   final int offset;
//
//   Parameter(this.offset);
// }
//
// class All with DashboardPropertyParameters {
//   @override
//   Map<String, dynamic> parameters = {};
// }
//
// class Sell with DashboardPropertyParameters {
//   @override
//   Map<String, dynamic> parameters = {"property_type": "0"};
// }
//
// class Rent with DashboardPropertyParameters {
//   @override
//   Map<String, dynamic> parameters = {"property_type": "1"};
// }
//
// class Sold with DashboardPropertyParameters {
//   @override
//   Map<String, dynamic> parameters = {"property_type": "2"};
// }
//
// class Rented with DashboardPropertyParameters {
//   @override
//   Map<String, dynamic> parameters = {"property_type": "3"};
// }
//
// abstract class DashboardRepository {
//   Future<DataOutput<DashboardPropertyModal>> fetch(
//       DashboardPropertyParameters p, Parameter parameter);
// }
//
// class DashboardRepositoryIMPL extends DashboardRepository {
//   @override
//   Future<DataOutput<DashboardPropertyModal>> fetch(
//       DashboardPropertyParameters p, Parameter parameter) async {
//     Map<String, dynamic> parameters = {};
//     parameters.addAll({
//       "offset": parameter.offset,
//       "limit": Constant.loadLimit,
//     });
//
//     parameters.addAll(p.parameters);
//
//     Map<String, dynamic> result =
//         await Api.post(url: Api.apiGetProprty, parameter: parameters);
//
//     List<DashboardPropertyModal> list = (result['data'] as List).map((e) {
//       return DashboardPropertyModal.fromMap(e);
//     }).toList();
//
//     return DataOutput<DashboardPropertyModal>(
//       total: result['total'] ?? 0,
//       modelList: list,
//     );
//   }
// }
