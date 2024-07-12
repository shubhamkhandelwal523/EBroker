import 'package:ebroker/ui/screens/subscription/widget/package_tile.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

class SubscriptionFeatureLine extends StatelessWidget {
  final String title;
  final PackageLimit? limit;
  final bool? isTime;
  final String? timeLimit;
  const SubscriptionFeatureLine(
      {super.key,
      required this.title,
      required this.limit,
      this.isTime,
      this.timeLimit});

  @override
  Widget build(BuildContext context) {
    if (limit?.get(context) is NotAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: SizedBox(
          width: context.screenWidth * 0.57,
          child: Row(
            children: [
              bulletPoint(context),
              SizedBox(
                width: 5.rw(context),
              ),
              if (isTime == true) ...{
                Text("$title "),
                Text("$timeLimit "),
              } else ...{
                Text("$title "),
                Text((limit?.get(context).value ?? "").toString())
              }
            ],
          )),
    );
  }

  Widget bulletPoint(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: context.color.textColorDark,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
