import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../utils/ui_utils.dart';
import '../home_screen.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  bool? enableShowAll;
  TitleHeader(
      {super.key, required this.title, this.onSeeAll, this.enableShowAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0, bottom: 16, start: sidePadding, end: sidePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title)
                .bold(weight: FontWeight.w700)
                .color(context.color.textColorDark)
                .size(context.font.large)
                .setMaxLines(lines: 1),
          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
              },
              child: Text(UiUtils.translate(context, "seeAll"))
                  .size(context.font.small)
                  .color(context.color.textLightColor)
                  .bold(weight: FontWeight.w700),
            )
        ],
      ),
    );
  }
}
