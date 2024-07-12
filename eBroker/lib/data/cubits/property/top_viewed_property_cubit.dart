import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../helper/custom_exception.dart';
import '../../../utils/helper_utils.dart';
import '../../model/property_model.dart';

abstract class TopPropertyState {}

class TopPropertyInitial extends TopPropertyState {}

class TopPropertyFetchProgress extends TopPropertyState {}

class TopPropertyFetchSuccess extends TopPropertyState {
  List<PropertyModel> propertylist = [];
  TopPropertyFetchSuccess(this.propertylist);
}

class TopPropertyFetchFailure extends TopPropertyState {
  final String errmsg;
  TopPropertyFetchFailure(this.errmsg);
}

class TopViewedPropertyCubit extends Cubit<TopPropertyState> {
  TopViewedPropertyCubit() : super(TopPropertyInitial());

  void fetchTopProperty(BuildContext context,
      {String? categoryId, bool fromUserlist = false}) {
    emit(TopPropertyFetchProgress());
    fetchTopPropertyFromDb(context)
        .then((value) => emit(TopPropertyFetchSuccess(value)))
        .catchError((e) => emit(TopPropertyFetchFailure(e.toString())));
  }

  Future<List<PropertyModel>> fetchTopPropertyFromDb(
    BuildContext context,
  ) async {
    //String? propertyId,
    List<PropertyModel> propertylist = [];
    Map<String, dynamic> body = {
      Api.topRated: "1",
      Api.offset: "0",
      Api.limit: "10",
    };

    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty, body, true, context,
        passUserid: false);
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        getdata['data'];
        // propertylist =
        //     list.map((model) => PropertyModel.fromJson(model)).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      throw CustomException("nodatafound");
    }

    return propertylist;
  }
}
