import 'dart:convert';

import 'package:ebroker/utils/Extensions/extensions.dart';

import '../../helper/custom_exception.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';

abstract class EnquiryState {}

class EnquiryInitial extends EnquiryState {}

class EnquirySetProgress extends EnquiryState {}

class EnquirySetSuccess extends EnquiryState {
  String msg = '';
  EnquirySetSuccess(this.msg);
}

class EnquirySetFailure extends EnquiryState {
  final String errmsg;
  EnquirySetFailure(this.errmsg);
}

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryInitial());

void setEnquiry(BuildContext context,
      {String? actionType, String? propertyId, String? status}) {
    emit(EnquirySetProgress());
    setEnquiryFromDb(context, actionType!, propertyId!, status!)
        .then((value) => emit(EnquirySetSuccess(value)))
        .catchError((e) => emit(EnquirySetFailure(e.toString())));
  }

  Future<String> setEnquiryFromDb(
    BuildContext context,
    String actionType,
    String propertyId,
    String status,
  ) async {
    if (actionType == '0') {
    } else {
      // ApiParams.id: '',
      // ApiParams.enqStatus: ''
    }
    Map<String, String> body = {
      //Add
      Api.actionType: actionType,
      Api.propertyId: propertyId,
      Api.customerId: HiveUtils.getUserId().toString(),
    };

    var response = await HelperUtils.sendApiRequest(
        Api.apiSetPropertyEnquiry, body, true, context,
        passUserid: false);
    var getdata = json.decode(response);
    if (getdata != null) {
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }
    return getdata[Api.message];
  }
}
