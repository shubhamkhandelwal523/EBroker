import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class ChatGlobals {
  ChatGlobals._();

  static void init() async {
    documentPath = "${(await getApplicationDocumentsDirectory()).path}/";
  }

  static const double borderRadius = 27;
  static const double defaultPadding = 8;
  static String documentPath = '';
  static GlobalKey<AnimatedListState> audioListKey =
      GlobalKey<AnimatedListState>();
}
