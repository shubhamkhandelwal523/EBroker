// import 'package:ebroker/data/model/data_output.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../Models/dashboard_property.dart' as p;
// import '../Repository/dashboard_repository.dart';
//
// abstract class DashboardPropertyListState {}
//
// class DashboardPropertyListInitial extends DashboardPropertyListState {}
//
// class DashboardPropertyListInProgress extends DashboardPropertyListState {}
//
// class DashboardPropertyListSuccess extends DashboardPropertyListState {
//   final List<p.DashboardPropertyModal> list;
//   final int total;
//   final int offset;
//   final bool isLoadingMore;
//   final bool hasError;
//
//   DashboardPropertyListSuccess({
//     required this.list,
//     required this.total,
//     required this.offset,
//     required this.isLoadingMore,
//     required this.hasError,
//   });
// }
//
// class DashboardPropertyListFailiur extends DashboardPropertyListState {
//   final dynamic error;
//   DashboardPropertyListFailiur(this.error);
// }
//
// class DashboardPropertyListCubit extends Cubit<DashboardPropertyListState> {
//   DashboardPropertyListCubit() : super(DashboardPropertyListInitial());
//   final DashboardRepositoryIMPL _repositoryIMPL = DashboardRepositoryIMPL();
//   void fetch(DashboardPropertyParameters parameters) async {
//     try {
//       emit(DashboardPropertyListInProgress());
//
//       DataOutput<p.DashboardPropertyModal> dataOutput =
//           await _repositoryIMPL.fetch(parameters, Parameter(0));
//
//       emit(DashboardPropertyListSuccess(
//           hasError: false,
//           isLoadingMore: false,
//           list: dataOutput.modelList,
//           total: dataOutput.total,
//           offset: 0));
//     } catch (e) {
//       emit(DashboardPropertyListFailiur(e));
//     }
//   }
// }
