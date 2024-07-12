import 'dart:async';
import 'dart:io';

import 'package:ebroker/utils/Queue/queue.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../ui/screens/splash_screen.dart';

class LanguageLoadProcess extends Task {
  @override
  Future<bool> process() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      await getDefaultLanguage(() {});
      return true;
    } catch (e) {
      return false;
    }
  }
}
