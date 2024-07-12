import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

mixin BlurDialoge {}

///This dialoge box will blur background of screen
///This is normaly a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBox extends StatelessWidget implements BlurDialoge {
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget content;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;
  const BlurredDialogBox({
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    required this.title,
    required this.content,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.barrierDismissable,
    this.isAcceptContainesPush,
  });

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.black.withOpacity(0)),
      child: Stack(
        children: [
          //Make dialoge box's background lighter black
          GestureDetector(
            onTap: () {
              if (barrierDismissable ?? false) {
                Navigator.pop(context);
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.14),
            ),
          ),
          WillPopScope(
            onWillPop: () async {
              if (backAllowedButton == false) {
                return false;
              }
              return true;
            },
            child: LayoutBuilder(builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor ??
                    makeColorDark(
                      context.color.primaryColor,
                    ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 186 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withOpacity(0.1),
                        child: SizedBox(
                            // width: 87 / 2,
                            // height: 87 / 2,
                            child: UiUtils.getSvg(
                          svgImagePath!,
                          color: svgImageColor,
                        )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    Text(title.firstUpperCase(), textAlign: TextAlign.center),
                  ],
                ),
                content: content,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancleButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor:
                          cancelButtonColor ?? context.color.primaryColor,
                      buttonName: cancelButtonName ??
                          UiUtils.translate(context, "cancelBtnLbl"),
                      textColor: cancelTextColor ?? context.color.textColorDark,
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context, false);
                      },
                    ),

                    // const Spacer(),
                  ],
                  Builder(builder: (context) {
                    if (showCancleButton == false) {
                      return Center(
                        child: SizedBox(
                          width: context.screenWidth / 2,
                          child: button(
                            context,
                            constraints: constraints,
                            buttonColor: acceptButtonColor ??
                                context.color.tertiaryColor,
                            buttonName: acceptButtonName ??
                                UiUtils.translate(context, "ok"),
                            textColor:
                                acceptTextColor ?? context.color.textColorDark,
                            onTap: () async {
                              await onAccept?.call();

                              if (isAcceptContainesPush == false ||
                                  isAcceptContainesPush == null) {
                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }
                    return button(
                      context,
                      constraints: constraints,
                      buttonColor:
                          acceptButtonColor ?? context.color.tertiaryColor,
                      buttonName:
                          acceptButtonName ?? UiUtils.translate(context, "ok"),
                      textColor: acceptTextColor ??
                          const Color.fromARGB(255, 255, 255, 255),
                      onTap: () async {
                        await onAccept?.call();
                        if (isAcceptContainesPush == false ||
                            isAcceptContainesPush == null) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              Navigator.pop(context, true);
                            },
                          );
                        }
                      },
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  Widget button(BuildContext context,
      {required BoxConstraints constraints,
      required Color buttonColor,
      required String buttonName,
      required Color textColor,
      required VoidCallback onTap}) {
    return SizedBox(
      width: (constraints.maxWidth / 3),
      child: MaterialButton(
        elevation: 0,

        height: 39.rh(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: context.color.borderColor)),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,

        onPressed: onTap,
        child: Text(buttonName).color(textColor),
      ),
    );
  }
}

///This dialoge box will blur background of screen
///This is normaly a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBuilderBox extends StatelessWidget implements BlurDialoge {
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget? Function(BuildContext context, BoxConstraints constrains)
      contentBuilder;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? isAcceptContainesPush;
  const BlurredDialogBuilderBox({
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    required this.title,
    required this.contentBuilder,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.isAcceptContainesPush,
  });

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.black.withOpacity(0)),
      child: Stack(
        children: [
          //Make dialoge box's background lighter black
          Container(
            color: Colors.black.withOpacity(0.14),
          ),
          WillPopScope(
            onWillPop: () async {
              if (backAllowedButton == false) {
                return false;
              }
              return true;
            },
            child: LayoutBuilder(builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: makeColorDark(context.color.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 98 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withOpacity(0.1),
                        child: SizedBox(
                            width: 87 / 2,
                            height: 87 / 2,
                            child: UiUtils.getSvg(svgImagePath!,
                                color: svgImageColor)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    Text(title.firstUpperCase(), textAlign: TextAlign.center),
                  ],
                ),
                content: contentBuilder.call(context, constraints),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancleButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor: cancelButtonColor ??
                          context.color.tertiaryColor.withOpacity(.10),
                      buttonName: cancelButtonName ??
                          UiUtils.translate(context, "cancelBtnLbl"),
                      textColor: cancelTextColor ?? context.color.textColorDark,
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context, false);
                      },
                    ),

                    // const Spacer(),
                  ],
                  Builder(builder: (context) {
                    if (showCancleButton == false) {
                      return Center(
                        child: SizedBox(
                          width: context.screenWidth / 2,
                          child: button(
                            context,
                            constraints: constraints,
                            buttonColor: acceptButtonColor ??
                                context.color.tertiaryColor,
                            buttonName: acceptButtonName ??
                                UiUtils.translate(context, "ok"),
                            textColor:
                                acceptTextColor ?? context.color.textColorDark,
                            onTap: () async {
                              await onAccept?.call();

                              if (isAcceptContainesPush == false ||
                                  isAcceptContainesPush == null) {
                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }
                    return button(
                      context,
                      constraints: constraints,
                      buttonColor:
                          acceptButtonColor ?? context.color.tertiaryColor,
                      buttonName:
                          acceptButtonName ?? UiUtils.translate(context, "ok"),
                      textColor: acceptTextColor ??
                          const Color.fromARGB(255, 255, 255, 255),
                      onTap: () async {
                        await onAccept?.call();
                        if (isAcceptContainesPush == false ||
                            isAcceptContainesPush == null) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              Navigator.pop(context, true);
                            },
                          );
                        }
                      },
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  Widget button(BuildContext context,
      {required BoxConstraints constraints,
      required Color buttonColor,
      required String buttonName,
      required Color textColor,
      required VoidCallback onTap}) {
    return SizedBox(
      width: (constraints.maxWidth / 3),
      child: MaterialButton(
        elevation: 0,
        height: 39.rh(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,

        onPressed: onTap,
        child: Text(buttonName).color(textColor),
      ),
    );
  }
}

class EmptyDialogBox extends StatelessWidget with BlurDialoge {
  final Widget child;
  final bool? barrierDismisable;
  const EmptyDialogBox({Key? key, required this.child, this.barrierDismisable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (barrierDismisable ?? true) Navigator.pop(context);
          },
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Center(child: child),
      ],
    ));
  }
}
