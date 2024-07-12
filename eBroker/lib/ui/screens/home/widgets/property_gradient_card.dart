import 'package:ebroker/app/routes.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/ui_utils.dart';

class PropertyGradiendCard extends StatefulWidget {
  final PropertyModel model;
  final bool? isFirst;
  final bool? showEndPadding;
  const PropertyGradiendCard(
      {super.key, required this.model, this.isFirst, this.showEndPadding});

  @override
  State<PropertyGradiendCard> createState() => _PropertyGradiendCardState();
}

class _PropertyGradiendCardState extends State<PropertyGradiendCard> {
  List<Widget> paramterList(PropertyModel propertie) {
    List<Parameter>? parameters = propertie.parameters;

    List<Widget>? icons = parameters?.map((e) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: SizedBox(
          width: 15,
          height: 15,
          child: SvgPicture.network(
            e.image!,
            color: Constant.adaptThemeColorSvg
                ? context.color.tertiaryColor
                : null,
          ),
        ),
      );
    }).toList();

    Iterable<Widget>? filterd = icons?.take(4);

    return filterd?.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.propertyDetails, arguments: {
          'propertyData': widget.model,
          'propertiesList': [],
          'fromMyProperty': false,
        });
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: (widget.isFirst ?? false) ? 0 : 5.0,
          end: (widget.showEndPadding ?? true) ? 5.0 : 0,
        ),
        child: Container(
          height: 200,
          width: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(builder: (context, c) {
            PropertyModel propertie = widget.model;
            return Stack(
              children: [
                UiUtils.getImage(
                  propertie.titleImage ?? "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.72),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.2,
                          0.4,
                          0.7
                        ]),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: c.maxHeight,
                    width: c.maxWidth,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          child: Row(
                            children: [
                              Container(
                                height: 19,
                                decoration: BoxDecoration(
                                    color: secondaryColorDark.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      propertie.properyType!.translate(context),
                                    )
                                        .color(
                                          context.color.buttonColor,
                                        )
                                        .bold()
                                        .size(context.font.smaller),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              if (propertie.promoted ?? false)
                                Container(
                                  height: 19,
                                  decoration: BoxDecoration(
                                      color: context.color.tertiaryColor,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Center(
                                      child: PromotedCard(
                                          color: Colors.transparent,
                                          type: PromoteCardType.icon),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        PositionedDirectional(
                            bottom: 0,
                            start: 0,
                            child: SizedBox(
                              height: c.maxHeight * 0.35,
                              width: c.maxWidth - 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            UiUtils.imageType(
                                                propertie.category?.image ?? "",
                                                color:
                                                    Constant.adaptThemeColorSvg
                                                        ? context
                                                            .color.tertiaryColor
                                                        : null,
                                                width: 20,
                                                height: 20),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                              child: Text((propertie.category!
                                                          .category) ??
                                                      "")
                                                  .setMaxLines(lines: 1)
                                                  .color(context
                                                      .color.buttonColor),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(((propertie.title) ?? ""))
                                            .setMaxLines(lines: 1)
                                            .size(context.font.large)
                                            .color(context.color.buttonColor),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.location,
                                              color: context.color.buttonColor
                                                  .withOpacity(0.8),
                                              width: 12,
                                              height: 12,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                child: Text(propertie.address!
                                                        .toString())
                                                    .setMaxLines(lines: 1)
                                                    .size(context.font.small)
                                                    .color(context
                                                        .color.buttonColor),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Spacer(),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(propertie.price!
                                                  .priceFormate(
                                                      disabled: Constant
                                                              .isNumberWithSuffix ==
                                                          false)
                                                  .toString()
                                                  .formatAmount(
                                                    prefix: true,
                                                  ))
                                              .bold()
                                              .setMaxLines(lines: 1)
                                              .size(context.font.extraLarge)
                                              .color(context.color.buttonColor),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: paramterList(propertie),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                ),

                // const PositionedDirectional(
                //     child: PromotedCard(type: PromoteCardType.icon))
              ],
            );
          }),
        ),
      ),
    );
  }
}
