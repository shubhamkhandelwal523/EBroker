import 'package:flutter/material.dart';

import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/ui_utils.dart';

class NoInternet extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoInternet({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SizedBox(
          height: context.screenHeight,
          width: context.screenWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  // width: 100,
                  // height: 150,
                  child: UiUtils.getSvg(AppIcons.no_internet)),
              SizedBox(
                height: 20,
              ),
              Text("noInternet".translate(context))
                  .size(context.font.extraLarge)
                  .color(context.color.tertiaryColor)
                  .bold(weight: FontWeight.w600),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: context.screenWidth * 0.8,
                  child: Text(
                    UiUtils.translate(context, "noInternetErrorMsg"),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: onRetry,
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          context.color.tertiaryColor.withOpacity(0.2))),
                  child: Text(UiUtils.translate(context, "retry"))
                      .color(context.color.tertiaryColor))
            ],
          ),
        ),
      ),
    );
  }
}
