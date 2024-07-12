// ignore_for_file: invalid_return_type_for_catch_error

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:google_maps_webservice/directions.dart';

import '../../../utils/api.dart';
import '../../model/property_model.dart';

abstract class PropertyState {}

class PropertyInitial extends PropertyState {}

class PropertyFetchProgress extends PropertyState {}

class PropertyFetchSuccess extends PropertyState {
  List<PropertyModel> propertylist = [];
  int total = 0;
  PropertyFetchSuccess(this.propertylist, this.total);
}

class PropertyFetchFailure extends PropertyState {
  final String errmsg;
  PropertyFetchFailure(this.errmsg);
}

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit() : super(PropertyInitial());

  void fetchProperty(BuildContext context, Map<String, dynamic> mbodyparam,
      {bool fromUserlist = false}) {
    emit(PropertyFetchProgress());
    fetchPropertyFromDb(context, mbodyparam, fromUserlist: fromUserlist)
        .then((value) {
      emit(PropertyFetchSuccess(value['list'], value['total']));
    }).catchError((e, st) => emit(PropertyFetchFailure(st.toString())));
  }

  Future<Map> fetchPropertyFromDb(
    BuildContext context,
    Map<String, dynamic> bodyparam, {
    bool fromUserlist = false,
  }) async {
    //String? propertyId,
    Map result = {};
    List<PropertyModel> propertylist = [];
    int mtotal = 0;
    var response = await Api.post(url: Api.apiGetProprty, parameter: {});
    // log("server data $map");
    // var response = await HelperUtils.sendApiRequest(
    //   Api.apiGetProprty,
    //   bodyparam,
    //   true,
    //   context,
    //   passUserid: fromUserlist,
    // );
    // var getdata = json.decode(response);
    List list = response['data'];
    mtotal = response["total"];
    result['total'] = mtotal;
    propertylist = list.map((model) => PropertyModel.fromMap(model)).toList();

    result['list'] = propertylist;
    return result;
  }
}
