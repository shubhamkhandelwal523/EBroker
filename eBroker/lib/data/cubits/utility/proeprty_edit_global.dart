import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PropertyEditGlobal {
  final List<PropertyModel> list;

  PropertyEditGlobal(this.list);
}

class PropertyEditCubit extends Cubit<PropertyEditGlobal> {
  PropertyEditCubit() : super(PropertyEditGlobal([]));

  void add(PropertyModel model) {
    var list = state.list;
    int indexOfElemeent = list.indexWhere((element) => element.id == model.id);
    if (indexOfElemeent != -1) list.removeAt(indexOfElemeent);

    list.add(model);
    emit(PropertyEditGlobal(list));
  }

  PropertyModel get(PropertyModel model) {
    return state.list.firstWhere((element) => element.id == model.id,
        orElse: () {
      return model;
    });
  }

  void remove() {}
}
