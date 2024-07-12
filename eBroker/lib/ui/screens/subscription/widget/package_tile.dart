import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/ui/screens/subscription/widget/subscripton_feature_line.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

abstract class Limit<T> {
  abstract final T value;
}

class StringLimit extends Limit {
  @override
  final String value;

  StringLimit(this.value);
}

class IntLimit extends Limit {
  @override
  final int value;

  IntLimit(this.value);
}

class NotAvailable extends Limit {
  @override
  void value;

  NotAvailable();
}

class PackageLimit {
  final dynamic limit;

  PackageLimit(this.limit);

  Limit get(context) {
    if (limit is int) {
      return IntLimit(limit);
    } else {
      if (isAvailable(context, limit)) {
        if (isUnLimited(context, limit)) {
          return StringLimit("unlimited".translate(context));
        } else {
          //Will not execute but added
          return StringLimit(limit);
        }
      } else {
        return NotAvailable();
      }
    }
  }

  bool isUnLimited(BuildContext context, String value) {
    if (value == "unlimited") {
      return true;
    }
    return false;
  }

  bool isAvailable(BuildContext context, String? value) {
    if (value == "not_available" || value == null) {
      return false;
    }
    return true;
  }
}

class SubscriptionPackageTile extends StatelessWidget {
  final SubscriptionPackageModel package;
  final VoidCallback onTap;
  const SubscriptionPackageTile(
      {super.key, required this.onTap, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: context.color.tertiaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                width: context.screenWidth,
                child: UiUtils.getSvg(AppIcons.headerCurve,
                    color: context.color.tertiaryColor, fit: BoxFit.fitWidth),
              ),
              PositionedDirectional(
                start: 10.rw(context),
                top: 8.rh(context),
                child: Text(package.name ?? "")
                    .size(context.font.larger)
                    .color(context.color.secondaryColor)
                    .bold(weight: FontWeight.w600),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SubscriptionFeatureLine(
            limit: PackageLimit(package.advertisementLimit),
            isTime: false,
            title: UiUtils.translate(context, "adLimitIs"),
          ),
          SizedBox(
            height: 5.rh(context),
          ),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SubscriptionFeatureLine(
                  limit: PackageLimit(package.propertyLimit),
                  isTime: false,
                  title: UiUtils.translate(context, "propertyLimit"),
                ),
                SizedBox(
                  height: 5.rh(context),
                ),
                SubscriptionFeatureLine(
                  limit: null,
                  isTime: true,
                  timeLimit:
                      "${package.duration} ${UiUtils.translate(context, "days")}",
                  title: UiUtils.translate(context, "validity"),
                ),
                // SubscriptionFeatureLine(),
              ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15.0),
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      height: 39.rh(context),
                      constraints: BoxConstraints(
                        minWidth: 80.rw(context),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          package.price == 0
                              ? "Free".translate(context)
                              : ("${package.price}")
                                  .toString()
                                  .formatAmount(prefix: true),
                          style: const TextStyle(fontFamily: "ROBOTO"),
                        )
                            .color(context.color.tertiaryColor)
                            .bold()
                            .size(context.font.large),
                      )),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UiUtils.buildButton(context,
                onPressed: onTap,
                radius: 9,
                height: 33.rh(context),
                buttonTitle: UiUtils.translate(context, "subscribe")),
          ),
        ],
      ),
    );
  }
}

class ViewOnlyPackageCard extends StatelessWidget {
  const ViewOnlyPackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 60,
        child: Center(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(
                  color: context.color.tertiaryColor,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: context.color.tertiaryColor,
                  ),
                ),
                Text("Unlocked Private Properties".translate(context))
                    .bold(weight: FontWeight.w500)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
