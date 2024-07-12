import 'dart:ui';

class APICallTrigger {
  APICallTrigger._();
  static List<VoidCallback> _triggerableList = [];
  static void onTrigger(VoidCallback fn) {
    _triggerableList.add(fn);
  }

  static void trigger() {
    for (VoidCallback i in _triggerableList) {
      i.call();
    }
  }
}
