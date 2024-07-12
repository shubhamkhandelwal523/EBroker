import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/Extensions/extensions.dart';
import '../../utils/ui_utils.dart';

class Widgets {
  static bool isLoaderShowing = false;
  static void showLoader(BuildContext context) async {
    if (isLoaderShowing == true) return;

    isLoaderShowing = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.black.withOpacity(0),
            ),
            child: SafeArea(
              child: WillPopScope(
                child: Center(
                  child: UiUtils.progress(
                    normalProgressColor: context.color.tertiaryColor,
                  ),
                ),
                onWillPop: () {
                  return Future(
                    () => false,
                  );
                },
              ),
            ),
          );
        });
  }

  static void hideLoder(BuildContext context) {
    if (!isLoaderShowing) return;
    isLoaderShowing = false;
    Navigator.of(context).pop();
  }

  static Center noDataFound(String errorMsg) {
    return Center(child: Text(errorMsg));
  }
}
