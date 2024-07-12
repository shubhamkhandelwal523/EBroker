import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../ui/Theme/theme.dart';
import '../../utils/constant.dart';

const double defaultPadding = 20;

Widget setTextbutton(String titleTxt, Color txtColor, FontWeight? fontWeight,
    VoidCallback onPressed, BuildContext context) {
  return TextButton(
    onPressed: onPressed,
    child: Text(titleTxt,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: txtColor,
              fontWeight: fontWeight,
              letterSpacing: 0.5,
            )),
  );
}

Widget setTitleText(String titleTxt, BuildContext context) {
  return Text(
    titleTxt,
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Theme.of(context).colorScheme.textColorDark,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5),
    textAlign: TextAlign.center,
  );
}

Widget setMessageText(
    {required String titleTxt,
    required Color txtColor,
    required TextStyle? txtStyle,
    required BuildContext context,
    FontWeight fontWeight = FontWeight.w400,
    TextAlign txtAlign = TextAlign.center,
    double? textheight,
    int? txtmaxline,
    TextOverflow? txtoverflow}) {
  return Text(
    titleTxt, //Theme.of(context).textTheme.titleMedium?
    style: txtStyle?.copyWith(
        color: txtColor,
        fontWeight: fontWeight,
        letterSpacing: 0.5,
        height: textheight),
    maxLines: txtmaxline, overflow: txtoverflow,
    textAlign: txtAlign,
  );
}

Widget setNetworkImg(String? murl,
    {double? height,
    double? width,
    Color? imgColor,
    BoxFit boxFit = BoxFit.contain,
    BoxFit? placeboxfit}) {
  String url = murl ??= "";
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: boxFit,
    errorWidget: (context, url, error) {
      return setSVGImage("placeholder",
          height: height, width: width, boxFit: placeboxfit ??= boxFit);
    },
    placeholder: (context, url) {
      return Center(
          child: setSVGImage("placeholder",
              height: height, width: width, boxFit: placeboxfit ??= boxFit));
    },
  );
}

Widget setSVGImage(String imageName,
    {double? height,
    double? width,
    Color? imgColor,
    BoxFit boxFit = BoxFit.contain}) {
  String path = "$svgPath$imageName.svg";
  return SvgPicture.asset(
    path,
    height: height,
    width: width,
    color: imgColor,
    fit: boxFit,
  );
}

/* showSnackBar(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Theme.of(context).colorScheme.textColor),      ),
      duration: const Duration(milliseconds: 1000), //bydefault 4000 ms
      backgroundColor: Theme.of(context).colorScheme.bgColor,      elevation: 1.0,
    ),
  );
} */

///textStyles
TextStyle setTextStyle(
    {required Color color,
    // required double? fontSize,
    required FontWeight fontW,
    required double? letterSpace,
    required BuildContext context}) {
  return TextStyle(
    //Theme.of(context).textTheme.headlineSmall?.copyWith(),
    color:
        color, //Theme.of(context).colorScheme.blackColor,    // fontSize: fontSize, //20,
    fontWeight: fontW, //FontWeight.w700,
    letterSpacing: letterSpace,
  );
}

///border
RoundedRectangleBorder setRoundedBorder(double bradius,
    {bool isboarder = false, Color bordercolor = Colors.transparent}) {
  return RoundedRectangleBorder(
      side: BorderSide(color: bordercolor, width: isboarder ? 1.0 : 0),
      borderRadius: BorderRadius.circular(bradius));
}

///appbar with or without back & action button
AppBar appBarWidget(BuildContext context, String titleText,
    {IconData backButtonIcon = Icons.arrow_back}) {
  return AppBar(
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    title: setMessageText(
        context: context,
        titleTxt: titleText,
        txtColor: Theme.of(context).colorScheme.blackColor,
        txtStyle: Theme.of(context).textTheme.titleMedium,
        fontWeight: FontWeight.w700),
    leading: addBackButton(context, backButtonIcon),
  );
}

IconButton addBackButton(BuildContext context, IconData backButtonIcon) {
  return IconButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    icon: Icon(
      backButtonIcon,
      color: Theme.of(context).colorScheme.backgroundColor,
    ), //Icons.arrow_back
  );
}

AppBar appBarWithActionWidget(
    BuildContext context, String titleText, Widget actionWidget,
    {IconData backButtonIcon = Icons.arrow_back}) {
  return AppBar(
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    title: setMessageText(
        context: context,
        titleTxt: titleText,
        txtColor: Theme.of(context).colorScheme.blackColor,
        txtStyle: Theme.of(context).textTheme.titleMedium,
        fontWeight: FontWeight.w700),
    leading: addBackButton(context, backButtonIcon),
    actions: [actionWidget],
  );
}

///gradient Container
Container setGradientContainer(
    {required Color gradientColor1,
    required Color gradientColor2,
    required BoxShape shape,
    Radius? radius,
    required Widget child}) {
  return Container(
      //MediaQuery.of(context).size.width
      // height: 20,
      // width: 20,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [gradientColor1, gradientColor2]),
      ),
      /*  BoxDecoration(
        // borderRadius: BorderRadius.all(radius),
        shape: shape,
        /* ShapeDecoration(
          shape: CircleBorder(),*/
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [gradientColor1, gradientColor2]),
      ), */
      child: child);
}

///blurred background for buttons & text
ClipRRect setBlurBg(
    {required BuildContext context, required Widget childWidget}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), //circular(25.0),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: childWidget));
  /*,
    VoidCallback? callBack
    GestureDetector(
      onTap: callBack,
      child: */
}

///url to file converter for images @ AddProperty -- not working as expected
/* Future<File> urlToFile(String imageUrl) async {
// generate random number.
  var rng = Random();
// get temporary directory of device.
  Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
  String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
  File file = File('$tempPath${rng.nextInt(100)}.png');
// call http.get method and pass imageUrl into it to get response.
  Response response = await get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
  await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
  return file;
} */
