import 'package:flutter/cupertino.dart';

import '../../ui_utils.dart';

extension TranslateString on String {
  String translate(BuildContext context) {
    return UiUtils.translate(context, this);
  }
}
