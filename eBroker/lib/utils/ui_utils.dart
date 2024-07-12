import 'dart:math';

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class UiUtils {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static SvgPicture getSvg(String path,
      {Color? color, BoxFit? fit, double? width, double? height}) {
    return SvgPicture.asset(
      path,
      color: color,
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }

  static SvgPicture networkSvg(String url, {Color? color, BoxFit? fit}) {
    return SvgPicture.network(
      url,
      color: color,
      fit: fit ?? BoxFit.contain,
    );
  }

  static String translate(BuildContext context, String labelKey) {
    return (AppLocalization.of(context)!.getTranslatedValues(labelKey) ??
            labelKey)
        .trim();
  }

  static Map<String, double> getWidgetInfo(
      BuildContext context, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;

    final Size size = renderBox.size; // or _widgetKey.currentContext?.size
    print('Size: ${size.width}, ${size.height}');
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    print('Offset: ${offset.dx}, ${offset.dy}');
    print(
        'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');

    return {
      "x": (offset.dx),
      "y": (offset.dy),
      "width": size.width,
      "height": size.height,
      "offX": offset.dx,
      "offY": offset.dy
    };
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static Widget getDivider() {
    return const Divider(
      endIndent: 0,
      indent: 0,
    );
  }

  static Widget getImage(String url,
      {double? width,
      double? height,
      BoxFit? fit,
      String? blurHash,
      bool? showFullScreenImage}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) {
        return Container(
            width: width,
            color: context.color.tertiaryColor.withOpacity(0.1),
            height: height,
            alignment: Alignment.center,
            child: FittedBox(
                child: SizedBox(
                    width: 70,
                    height: 70,
                    child: LoadAppSettings().svg(
                      appSettings.placeholderLogo!,
                    ))));
      },
      errorWidget: (context, url, error) {
        return Container(
            width: width,
            color: context.color.tertiaryColor.withOpacity(0.1),
            height: height,
            alignment: Alignment.center,
            child: FittedBox(
                child: SizedBox(
                    width: 70,
                    height: 70,
                    child: LoadAppSettings().svg(appSettings.placeholderLogo!,
                        color: context.color.tertiaryColor))));
      },
    );
  }

  static Widget progress(
      {double? width,
      double? height,
      Color? normalProgressColor,
      bool? showWhite}) {
    if (Constant.useLottieProgress) {
      return LottieBuilder.asset(
        "assets/lottie/${showWhite == true ? Constant.progressLottieFileWhite : Constant.progressLottieFile}",
        width: width ?? 45,
        height: height ?? 45,
        delegates: LottieDelegates(values: [
          ValueDelegate.color(
            [
              "Layer 5 Outlines",
              "Group 1",
              "**",
            ],
            value: _context?.color.tertiaryColor,
          ),
          ValueDelegate.color(
            [
              "cube 4 Outlines",
              "Group 1",
              "**",
            ],
            value: _context?.color.tertiaryColor,
          ),
          ValueDelegate.color(
            [
              "cube 2 Outlines",
              "Group 1",
              "**",
            ],
            value: Colors.grey.shade100,
          ),
          ValueDelegate.color(
            [
              "cube 3 Outlines",
              "Group 1",
              "**",
            ],
            value: Colors.grey.shade100,
          ),
        ]),
      );
    } else {
      return CircularProgressIndicator(
        color: normalProgressColor,
      );
    }
  }

  static CachedNetworkImage setNetworkImage(String imgUrl,
      {double? hh, double? ww}) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      matchTextDirection: true,
      fit: BoxFit.cover,
      height: hh,
      width: ww,
      placeholder: ((context, url) {
        return Image.asset("assets/images/png/placeholder.png");
      }),
      errorWidget: (context, url, error) {
        return Image.asset("assets/images/png/placeholder.png");
      },
    );
  }

  ///Divider / Container

  static SystemUiOverlayStyle getSystemUiOverlayStyle(
      {required BuildContext context}) {
    // print("theme is ${context.watch<AppThemeCubit>().state.appTheme}");
    return SystemUiOverlayStyle(
        systemNavigationBarDividerColor: Colors.transparent,
        // systemNavigationBarColor: Theme.of(context).colorScheme.secondaryColor,
        systemNavigationBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
        //
        statusBarColor: Theme.of(context).colorScheme.primaryColor,
        statusBarBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark);
  }

  static PreferredSize buildAppBar(BuildContext context,
      {String? title,
      bool? showBackButton,
      List<Widget>? actions,
      List<Widget>? bottom,
      double? bottomHeight,
      bool? hideTopBorder,
      VoidCallback? onbackpress}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(55 + (bottomHeight ?? 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: RoundedBorderOnSomeSidesWidget(
              borderColor: context.color.borderColor,
              borderRadius: 20,
              borderWidth: 1.5,
              contentBackgroundColor: context.color.secondaryColor,
              bottomLeft: true,
              bottomRight: true,
              topLeft: false,
              topRight: false,
              child: Container(
                alignment: Alignment.bottomLeft,
                // decoration: BoxDecoration(
                // border: (hideTopBorder ?? false)
                //     ? Border(
                //         left: BorderSide(
                //             width: 1.5, color: context.color.borderColor),
                //         right: BorderSide(
                //             width: 1.5, color: context.color.borderColor),
                //         bottom: BorderSide(
                //             width: 1.5, color: context.color.borderColor))
                //     : Border.all(
                //         width: 1.5, color: context.color.borderColor),
                // borderRadius: (hideTopBorder ?? false)
                //     ? BorderRadius.only(
                //         bottomLeft: Radius.circular(20),
                //         bottomRight: Radius.circular(20))
                //     : BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: (showBackButton ?? false) ? 0 : 20,
                      vertical: (showBackButton ?? false) ? 0 : 18),
                  child: Row(
                    children: [
                      if (showBackButton ?? false) ...[
                        Material(
                          clipBehavior: Clip.antiAlias,
                          color: Colors.transparent,
                          type: MaterialType.circle,
                          child: InkWell(
                            onTap: () {
                              onbackpress?.call();
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: UiUtils.getSvg(AppIcons.arrowLeft,
                                  fit: BoxFit.none,
                                  color: context.color.tertiaryColor),
                            ),
                          ),
                        ),
                      ],
                      Text(
                        title ?? "",
                      )
                          .color(context.color.textColorDark)
                          .bold(weight: FontWeight.w600)
                          .size(18),
                      if (actions != null) ...[const Spacer(), ...actions],
                    ],
                  ),
                ),
              ),
            ),
          ),
          ...bottom ?? [const SizedBox.shrink()]
        ],
      ),
    );
  }

  static Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  static Color makeColorLight(Color color) {
    Color color0 = color;

    int red = color0.red + 10;
    int green = color0.green + 10;
    int blue = color0.blue + 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  static Widget buildButton(BuildContext context,
      {double? height,
      double? width,
      BorderSide? border,
      String? titleWhenProgress,
      bool? isInProgress,
      double? fontSize,
      double? radius,
      bool? autoWidth,
      Widget? prefixWidget,
      EdgeInsetsGeometry? padding,
      required VoidCallback onPressed,
      required String buttonTitle,
      bool? showProgressTitle,
      double? progressWidth,
      double? progressHeight,
      bool? showElevation,
      Color? textColor,
      Color? buttonColor,
      EdgeInsets? outerPadding,
      Color? disabledColor,
      VoidCallback? onTapDisabledButton,
      bool? disabled}) {
    String title = "";

    if (isInProgress == true) {
      title = titleWhenProgress ?? buttonTitle;
    } else {
      title = buttonTitle;
    }

    return Padding(
      padding: outerPadding ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          if (disabled == true) {
            onTapDisabledButton?.call();
          }
        },
        child: MaterialButton(
          minWidth: autoWidth == true ? null : (width ?? double.infinity),
          height: height ?? 56.rh(context),
          padding: padding,
          shape: RoundedRectangleBorder(
              side: border ?? BorderSide.none,
              borderRadius: BorderRadius.circular(radius ?? 16)),
          elevation: (showElevation ?? true) ? 0.5 : 0,
          color: buttonColor ?? context.color.tertiaryColor,
          disabledColor: disabledColor ?? context.color.tertiaryColor,
          onPressed: (isInProgress == true || (disabled ?? false))
              ? null
              : () {
                  HelperUtils.unfocus();
                  onPressed.call();
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isInProgress == true) ...{
                UiUtils.progress(
                    width: progressWidth ?? 16,
                    height: progressHeight ?? 16,
                    showWhite: true),
              },
              if (isInProgress != true) prefixWidget ?? const SizedBox.shrink(),
              if (isInProgress != true) ...[
                Text(title)
                    .color(textColor ?? context.color.buttonColor)
                    .size(fontSize ?? context.font.larger),
              ] else ...[
                if (showProgressTitle ?? false)
                  Text(title)
                      .color(context.color.buttonColor)
                      .size(fontSize ?? context.font.larger),
              ]
            ],
          ),
        ),
      ),
    );
  }

  static String removeDoubleSlashUrl(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = List.from(uri.pathSegments);
    segments.removeWhere((element) => element == "");
    return Uri(
            host: uri.host,
            pathSegments: segments,
            scheme: uri.scheme,
            fragment: uri.fragment,
            queryParameters: uri.queryParameters,
            port: uri.port,
            query: uri.query,
            userInfo: uri.userInfo)
        .toString();
  }

  static Widget imageType(String url,
      {double? width, double? height, BoxFit? fit, Color? color}) {
    String? ext = url.split(".").last.toLowerCase();
    if (ext == "svg") {
      return NetworkToLocalSvg().svg(
        UiUtils.removeDoubleSlashUrl(url) ?? "",
        color: color,
        width: 20,
        height: 20,
      );
    } else {
      return getImage(
        url,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }

  static void showFullScreenImage(BuildContext context,
      {required ImageProvider provider,
      VoidCallback? then,
      bool? downloadOption,
      VoidCallback? onTapDownload}) {
    Navigator.of(context)
        .push(BlurredRouter(
            sigmaX: 10,
            sigmaY: 10,
            barrierDismiss: true,
            builder: (BuildContext context) => FullScreenImageView(
                provider: provider,
                showDownloadButton: downloadOption,
                onTapDownload: onTapDownload)))
        .then((value) {
      then?.call();
    });
  }

  static void imageGallaryView(BuildContext context,
      {required List images, VoidCallback? then, required int initalIndex}) {
    Navigator.of(context)
        .push(BlurredRouter(
            sigmaX: 10,
            sigmaY: 10,
            builder: (BuildContext context) => GalleryViewWidget(
                  initalIndex: initalIndex,
                  images: images,
                )))
        .then((value) {
      then?.call();
    });
  }

  static Future showBlurredDialoge(BuildContext context,
      {required BlurDialoge dialoge, double? sigmaX, double? sigmaY}) async {
    return await Navigator.push(
      context,
      BlurredRouter(
          barrierDismiss: true,
          builder: (context) {
            if (dialoge is BlurredDialogBox) {
              return dialoge;
            } else if (dialoge is BlurredDialogBuilderBox) {
              return dialoge;
            } else if (dialoge is EmptyDialogBox) {
              return dialoge;
            }

            return Container();
          },
          sigmaX: sigmaX,
          sigmaY: sigmaY),
    );
  }

//AAA is color theory's point it means if color is AAA then it will be perfect for your app
  static bool isColorMatchAAA(Color textColor, Color background) {
    double contrastRatio = (textColor.computeLuminance() + 0.05) /
        (background.computeLuminance() + 0.05);
    if (contrastRatio < 4.5) {
      return false;
    } else {
      return true;
    }
  }

  static double getRadiansFromDegree(double radians) {
    return radians * 180 / pi;
  }

  static Color getAdaptiveTextColor(Color color) {
    int d = 0;

// Counting the perceptive luminance - human eye favors green color...
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5) {
      d = 0;
    } else {
      d = 255;
    } // dark colors - white font

    return Color.fromARGB(color.alpha, d, d, d);
  }

  static String time24to12hour(String time24) {
    DateTime tempDate = DateFormat("hh:mm").parse(time24);
    var dateFormat = DateFormat("h:mm a");
    return dateFormat.format(tempDate);
  }
}

///Format string
extension FormatAmount on String {
  String formatAmount({bool prefix = false}) {
    return (prefix)
        ? "${Constant.currencySymbol}${toString()}"
        : "${toString()}${Constant.currencySymbol}"; // \u{20B9}"; //currencySymbol
  }

  String formatDate({
    String? format,
  }) {
    DateFormat dateFormat = DateFormat(format ?? "MMM d, yyyy");
    String formatted = dateFormat.format(DateTime.parse(this));
    return formatted;
  }

  String formatPercentage() {
    return "${toString()} %";
  }

  String formatId() {
    return " # ${toString()} "; // \u{20B9}"; //currencySymbol
  }

  String firstUpperCase() {
    String upperCase = "";
    var suffix = "";
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return (upperCase + suffix);
  }
}

//scroll controller extenstion

extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    if (offset >= position.maxScrollExtent) {
      return true;
    }
    return false;
  }
}

class RemoveGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class RoundedBorderOnSomeSidesWidget extends StatelessWidget {
  /// Color of the content behind this widget
  final Color contentBackgroundColor;
  final Color borderColor;
  final Widget child;

  final double borderRadius;
  final double borderWidth;

  /// The sides where we want the rounded border to be
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const RoundedBorderOnSomeSidesWidget({
    required this.borderColor,
    required this.contentBackgroundColor,
    required this.child,
    required this.borderRadius,
    required this.borderWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? Radius.circular(borderRadius) : Radius.zero,
          topRight: topRight ? Radius.circular(borderRadius) : Radius.zero,
          bottomLeft: bottomLeft ? Radius.circular(borderRadius) : Radius.zero,
          bottomRight:
              bottomRight ? Radius.circular(borderRadius) : Radius.zero,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          top: topLeft || topRight ? borderWidth : 0,
          left: topLeft || bottomLeft ? borderWidth : 0,
          bottom: bottomLeft || bottomRight ? borderWidth : 0,
          right: topRight || bottomRight ? borderWidth : 0,
        ),
        decoration: BoxDecoration(
          color: contentBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: topLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            topRight: topRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomLeft: bottomLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomRight: bottomRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
          ),
        ),
        child: child,
      ),
    );
  }
}
