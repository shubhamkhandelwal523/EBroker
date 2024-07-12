import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../utils/AppIcon.dart';

class NoDataFound extends StatelessWidget {
  final double? height;
  final VoidCallback? onTap;
  final String? title;
  final String? description;
  const NoDataFound(
      {super.key, this.onTap, this.height, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // height: height ?? 200,
            child: SvgPicture.asset(AppIcons.no_data_found),
          ),
          SizedBox(
            height: 20,
          ),
          Text(title ?? "nodatafound".translate(context))
              .size(context.font.extraLarge)
              .color(context.color.tertiaryColor)
              .bold(weight: FontWeight.w600),
          const SizedBox(
            height: 14,
          ),
          Text(description??"sorryLookingFor".translate(context))
              .size(context.font.larger)
              .centerAlign(),
          // Text(UiUtils.getTranslatedLabel(context, "nodatafound")),
          // TextButton(
          //     onPressed: onTap,
          //     style: ButtonStyle(
          //         overlayColor: MaterialStateProperty.all(
          //             context.color.teritoryColor.withOpacity(0.2))),
          //     child: const Text("Retry").color(context.color.teritoryColor))
        ],
      ),
    );
  }
}
