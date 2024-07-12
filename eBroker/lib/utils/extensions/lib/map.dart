extension MapExt on Map {
  void removeEmptyKeys() {
    removeWhere((key, value) => value.isEmpty || value == "" || value == null);
  }

  dynamic get(dynamic key) {
    return this[key];
  }
}

extension ListExt on List<Map> {
  Map findByKey(dynamic key, {dynamic equals}) {
    return where((element) {
      return element[key] == equals;
    }).first;
  }
}
