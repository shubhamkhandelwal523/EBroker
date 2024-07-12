import 'package:ebroker/app/routes.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

class GuestChecker {
  static final ValueNotifier<bool?> _isGuest = ValueNotifier(null);
  static BuildContext? _context;

  static void set({required bool isGuest}) {
    _isGuest.value = isGuest;
  }

  static void setContext(BuildContext context) {
    _context = context;
  }

  static void check({required Function() onNotGuest}) {
    if (_context == null) {
      throw "please set context";
    }

    if (_isGuest.value == true) {
      _loginBox();
    } else {
      onNotGuest.call();
    }
  }

  static bool get value {
    return _isGuest.value ?? true;
  }

  static ValueNotifier<bool?> listen() {
    return _isGuest;
  }

  static Widget updateUI({
    required Function(bool? isGuest) onChangeStatus,
  }) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _isGuest,
      builder: (context, value, c) {
        return onChangeStatus.call(value);
      },
    );
  }

  static _loginBox() {
    showModalBottomSheet(
      context: _context!,
      isScrollControlled: false,
      backgroundColor: _context?.color.primaryColor.darken(-5),
      enableDrag: false,
      builder: (context) {
        return Container(
          // height: 200,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Login is required to access this feature.")
                    .size(context.font.larger),
                const SizedBox(
                  height: 5,
                ),
                const Text("Tap on login to authorize")
                    .size(context.font.small),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  elevation: 0,
                  color: _context?.color.tertiaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.login,
                        arguments: {"popToCurrent": true});
                  },
                  child: const Text("Login now").color(
                    _context?.color.buttonColor ?? Colors.white,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
