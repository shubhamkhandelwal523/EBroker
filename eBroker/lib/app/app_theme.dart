// ignore_for_file: deprecated_member_use

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final appThemeData = {
  AppTheme.light: ThemeData(
    useMaterial3: false,
    // scaffoldBackgroundColor: pageBackgroundColor,
    brightness: Brightness.light,
    //textTheme
    fontFamily: "Manrope",
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.green,
      cursorColor: Colors.green,
      selectionHandleColor: Colors.green,
    ),
    errorColor: errorMessageColor,
    // textSelectionTheme:
    //     const TextSelectionThemeData(selectionHandleColor: teritoryColor_),
    switchTheme: SwitchThemeData(
      thumbColor: const MaterialStatePropertyAll(tertiaryColor_),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return tertiaryColor_.withOpacity(0.3);
        }
        return primaryColorDark;
      }),
    ),
  ),
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    fontFamily: "Manrope",
    errorColor: errorMessageColor.withOpacity(0.7),
    textSelectionTheme:
        const TextSelectionThemeData(selectionHandleColor: tertiaryColorDark),
    switchTheme: SwitchThemeData(
        thumbColor: const MaterialStatePropertyAll(tertiaryColor_),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return tertiaryColor_.withOpacity(0.3);
          }
          return primaryColor_.withOpacity(0.2);
        })),
  )
};
