import 'dart:convert';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../helper/custom_exception.dart';
import '../../../utils/helper_utils.dart';
import '../../model/house_type.dart';

abstract class HouseTypeState {}

class HouseTypeInitial extends HouseTypeState {}

class HouseTypeFetchProgress extends HouseTypeState {}

class HouseTypeFetchSuccess extends HouseTypeState {
  List<HouseType> houseTypelist = [];

  HouseTypeFetchSuccess(this.houseTypelist);
}

class ChangeSelectedHouseType extends HouseTypeState {
  HouseType selectedHouseType;

  ChangeSelectedHouseType(this.selectedHouseType);
}

class HouseTypeFetchFailure extends HouseTypeState {
  final String errmsg;
  HouseTypeFetchFailure(this.errmsg);
}

class HouseTypeCubit extends Cubit<HouseTypeState> {
  HouseTypeCubit() : super(HouseTypeInitial());

  void fetchHouseType(BuildContext context) {
    emit(HouseTypeFetchProgress());
    fetchHouseTypeFromDb(context)
        .then((value) => emit(HouseTypeFetchSuccess(value)))
        .catchError((e) => emit(HouseTypeFetchFailure(e.toString())));
  }

  void changeSelectedHouseType(HouseType houseType) {
    emit(ChangeSelectedHouseType(houseType));
  }

  Future<List<HouseType>> fetchHouseTypeFromDb(BuildContext context) async {
    List<HouseType> housetypelist = [];
    Map<String, String> body = {};

    var response = await HelperUtils.sendApiRequest(
        Api.apiGetHouseType, body, true, context);
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        List list = getdata['data'];

        housetypelist = list.map((model) => HouseType.fromJson(model)).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }

    return housetypelist;
  }
}
