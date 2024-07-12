import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/string_extenstion.dart';
import '../../../../utils/ui_utils.dart';
import '../../proprties/property_details.dart';
import '../../widgets/like_button_widget.dart';
import '../../widgets/promoted_widget.dart';

class PropertyCardBig extends StatelessWidget {
  final PropertyModel property;
  final bool? isFirst;
  final bool? showEndPadding;
  final Function(FavoriteType type)? onLikeChange;
  const PropertyCardBig(
      {super.key,
      this.onLikeChange,
      required this.property,
      this.isFirst,
      this.showEndPadding});

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.price!
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
        )
        .toString()
        .formatAmount(prefix: true));
    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice =
          ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: (isFirst ?? false) ? 0 : 5.0,
        end: (showEndPadding ?? true) ? 5.0 : 0,
      ),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property?.slugId ?? "");
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: context.color.secondaryColor,
            border: Border.all(
              width: 1.5,
              color: context.color.borderColor,
            ),
          ),
          height: 272,
          width: 250,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 147,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: UiUtils.getImage(
                            property.titleImage!,
                            height: 147,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            blurHash: property.titleimagehash,
                          ),
                        ),
                        PositionedDirectional(
                          start: 10,
                          bottom: 10,
                          child: Container(
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor.withOpacity(
                                0.7,
                              ),
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    property.properyType!
                                        .toLowerCase()
                                        .translate(context),
                                  )
                                      .color(
                                        context.color.textColorDark,
                                      )
                                      .bold()
                                      .size(context.font.smaller),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              UiUtils.imageType(property.category!.image!,
                                  width: 18,
                                  height: 18,
                                  color: Constant.adaptThemeColorSvg
                                      ? context.color.tertiaryColor
                                      : null),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(property.category?.category ?? "")
                                  .size(
                                    context.font.small,
                                  )
                                  .bold(
                                    weight: FontWeight.w400,
                                  )
                                  .color(
                                    context.color.textLightColor,
                                  )
                            ],
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          if (property.properyType.toString().toLowerCase() ==
                              "rent") ...[
                            Text(rentPrice)
                                .size(
                                  context.font.large,
                                )
                                .color(
                                  context.color.tertiaryColor,
                                )
                                .bold(
                                  weight: FontWeight.w700,
                                ),
                          ] else ...[
                            Text(property.price!
                                    .priceFormate(
                                      disabled:
                                          Constant.isNumberWithSuffix == false,
                                    )
                                    .toString()
                                    .formatAmount(prefix: true))
                                .size(context.font.large)
                                .color(context.color.tertiaryColor)
                                .bold(
                                  weight: FontWeight.w700,
                                ),
                          ],
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            property.title ?? "",
                          )
                              .setMaxLines(lines: 1)
                              .size(context.font.large)
                              .color(context.color.textColorDark),
                          if (property.city != "") ...[
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UiUtils.getSvg(AppIcons.location,
                                    color: context.color.textLightColor),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(property.city!)
                                      .color(context.color.textLightColor)
                                      .setMaxLines(lines: 1),
                                )
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  )
                ],
              ),
              PositionedDirectional(
                end: 25,
                top: 128,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(33, 0, 0, 0),
                          offset: Offset(0, 2),
                          blurRadius: 15,
                          spreadRadius: 0)
                    ],
                  ),
                  child: LikeButtonWidget(
                    property: property,
                    onLikeChanged: (type) {
                      onLikeChange?.call(type);
                    },
                  ),
                ),
              ),
              PositionedDirectional(
                start: 10,
                top: 10,
                child: Row(
                  children: [
                    Visibility(
                        visible: property.promoted ?? false,
                        child: const PromotedCard(type: PromoteCardType.text)),
                    // const SizedBox(
                    //   width: 2,
                    // ),
                    // Container(
                    //   height: 24,
                    //   decoration: BoxDecoration(
                    //       color: context.color.secondaryColor.withOpacity(0.9),
                    //       borderRadius: BorderRadius.circular(4)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //     child: Center(
                    //       child: Text(
                    //         UiUtils.getTranslatedLabel(context, "sell"),
                    //       )
                    //           .color(
                    //             context.color.textColorDark,
                    //           )
                    //           .bold()
                    //           .size(context.font.smaller),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
