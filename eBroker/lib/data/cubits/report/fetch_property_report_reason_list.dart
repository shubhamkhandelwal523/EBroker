import 'dart:developer';

import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/report_property/reason_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../settings.dart';
import '../../repositories/report_property_repository.dart';

abstract class FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsInitial
    extends FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsInProgress
    extends FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsSuccess
    extends FetchPropertyReportReasonsListState {
  final int total;
  final List<ReportReason> reasons;

  FetchPropertyReportReasonsSuccess(
      {required this.total, required this.reasons});

  Map<String, dynamic> toMap() {
    return {
      'total': this.total,
      'reasons': this.reasons.map((e) => e.toMap()).toList(),
    };
  }

  factory FetchPropertyReportReasonsSuccess.fromMap(Map<String, dynamic> map) {
    return FetchPropertyReportReasonsSuccess(
      total: map['total'] as int,
      reasons:
          (map['reasons'] as List).map((e) => ReportReason.fromMap(e)).toList(),
    );
  }
}

class FetchPropertyReportReasonsFailure
    extends FetchPropertyReportReasonsListState {
  final dynamic error;

  FetchPropertyReportReasonsFailure(this.error);
}

class FetchPropertyReportReasonsListCubit
    extends Cubit<FetchPropertyReportReasonsListState> with HydratedMixin {
  FetchPropertyReportReasonsListCubit()
      : super(FetchPropertyReportReasonsInitial());
  ReportPropertyRepository _repository = ReportPropertyRepository();
  void fetch({bool? forceRefresh}) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchPropertyReportReasonsSuccess) {
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(
              const Duration(seconds: AppSettings.hiddenAPIProcessDelay));
          // });
        } else {
          emit(FetchPropertyReportReasonsInProgress());
        }
      } else {
        emit(FetchPropertyReportReasonsInProgress());
      }

      if (forceRefresh == true) {
        DataOutput<ReportReason> result =
            await _repository.fetchReportReasonsList();

        result.modelList.add(ReportReason(id: -10, reason: "Other"));

        emit(FetchPropertyReportReasonsSuccess(
          reasons: result.modelList,
          total: result.total,
        ));
      } else {
        if (state is! FetchPropertyReportReasonsSuccess) {
          DataOutput<ReportReason> result =
              await _repository.fetchReportReasonsList();

          result.modelList.add(ReportReason(id: -10, reason: "Other"));

          emit(FetchPropertyReportReasonsSuccess(
            reasons: result.modelList,
            total: result.total,
          ));
        }
      }

      // emit(FetchPropertyReportReasonsInProgress());
    } catch (e) {
      log("REPORT REASON ERROR IS $e");
      emit(FetchPropertyReportReasonsFailure(e));
    }
  }

  List<ReportReason>? getList() {
    if (state is FetchPropertyReportReasonsSuccess) {
      return (state as FetchPropertyReportReasonsSuccess).reasons;
    }
    return null;
  }

  @override
  FetchPropertyReportReasonsListState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchPropertyReportReasonsSuccess") {
        FetchPropertyReportReasonsSuccess fetchPropertyReportReasonsSuccess =
            FetchPropertyReportReasonsSuccess.fromMap(json);

        return fetchPropertyReportReasonsSuccess;
      }
    } catch (e, st) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchPropertyReportReasonsListState state) {
    try {
      if (state is FetchPropertyReportReasonsSuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchPropertyReportReasonsSuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
