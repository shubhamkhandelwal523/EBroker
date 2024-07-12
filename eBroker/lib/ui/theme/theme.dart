import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../utils/ui_utils.dart';

///Light Theme Colors
///This color format is different, isn't it? .You can use hex colors here also but you have to remove '#' symbol and add 0xff instead.
const Color primaryColor_ = Color(0xFFFAFAFA);
const Color secondaryColor_ = Color(0xFFFFFFFF);
const Color tertiaryColor_ = Color(0xFF087C7C);
const Color textColor = Color(0xFF4D5454);
Color lightTextColor = const Color(0xFF4D5454).withOpacity(0.5);
Color widgetsBorderColorLight = const Color(0xffEEEEEE).withOpacity(0.6);
Color senderChatColor = const Color.fromARGB(255, 233, 233, 233).darken(22);

///Dark Theme Colors
Color primaryColorDark = const Color(0xff0C0C0C);
Color secondaryColorDark = const Color(0xff1C1C1C);
const Color tertiaryColorDark = Color(0xff53ADAE);
const Color textColorDarkTheme = Color(0xffFDFDFD);
Color lightTextColorDarkTheme = const Color(0xffFDFDFD).withOpacity(0.3);
Color widgetsBorderColorDark = const Color(0x1aFDFDFD);
Color darkSenderChatColor =
    const Color.fromARGB(255, 233, 233, 233).darken(100);

///Messages Color
const Color errorMessageColor = Color.fromARGB(255, 166, 4, 4);
const Color successMessageColor = Color.fromARGB(255, 12, 161, 161);
const Color warningMessageColor = Color(0xFFC2AF6F);

//Button text color
const Color buttonTextColor = Colors.white;

///Advance
//Theme settings
extension ColorPrefs on ColorScheme {
  Color get primaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightPrimary,
        darkColor: appSettings.darkPrimary,
      );
  Color get secondaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightSecondary,
        darkColor: appSettings.darkSecondary,
      );
  Color get tertiaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightTertiary,
        darkColor: appSettings.darkTertiary,
      );

  Color get backgroundColor => _getColor(
        brightness,
        lightColor: appSettings.lightPrimary,
        darkColor: appSettings.darkPrimary,
      );

  Color get buttonColor => buttonTextColor;

  Color get textColorDark => _getColor(
        brightness,
        lightColor: textColor,
        darkColor: textColorDarkTheme,
      );

  Color get textLightColor => _getColor(
        brightness,
        lightColor: lightTextColor,
        darkColor: lightTextColorDarkTheme,
      );

  Color get borderColor => _getColor(brightness,
      lightColor: widgetsBorderColorLight, darkColor: widgetsBorderColorDark);

  Color get chatSenderColor => _getColor(brightness,
      lightColor: senderChatColor, darkColor: darkSenderChatColor);

  ///This will set text color white if background is dark if background is light it will be dark
  Color textAutoAdapt(Color backgroundColor) =>
      UiUtils.getAdaptiveTextColor(backgroundColor);

  Color get blackColor => Colors.black;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);
  Color get shimmerHighlightColor => brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade300;
  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withOpacity(0.85)
      : Colors.white.withOpacity(0.7);
}

// 10pt: Smaller
// 12pt: Small
// 16pt: Large
// 18pt: Larger
// 24pt: Extra large
extension TextThemeForFont on TextTheme {
  Font get font => Font();
}

/// i made this to access font easyly from theme like, Theme.of(context).textTheme.font.small
/// So what is diffrence here?? in Theme.of(context).textTheme.small and Theme.of(context).textTheme.font.small
/// We use saperate class because There will be an exention on BuildContext in [Utils/Extensions/lib] folder so further explaination is there. you can check
class Font {
  ///10
  double get smaller => 10;

  ///12
  double get small => 12;

  ///14
  double get normal => 14;

  ///16
  double get large => 16;

  ///18
  double get larger => 18;

  ///24
  double get extraLarge => 24;

  ///28
  double get xxLarge => 28;
}

//This one is for check current theme and return data accordingly
Color _getColor(Brightness brightness,
    {required Color lightColor, required Color darkColor}) {
  if (Brightness.light == brightness) {
    return lightColor;
  } else {
    return darkColor;
  }
}
