import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../../data/helper/design_configs.dart';
import '../../../../data/model/category.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/ui_utils.dart';

class CategoryCard extends StatelessWidget {
  final bool? frontSpacing;
  final Function(Category category) onTapCategory;
  final Category category;
  const CategoryCard(
      {super.key,
      required this.frontSpacing,
      required this.onTapCategory,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: frontSpacing == true ? 5.0 : 0,
        end: .0,
      ),
      child: GestureDetector(
        onTap: () {
          onTapCategory.call(category);
        },
        child: Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: 100.rw(context),
              ),
              height: 44.rh(context),
              alignment: Alignment.center,
              decoration: DesignConfig.boxDecorationBorder(
                color: context.color.secondaryColor,
                radius: 10,
                borderWidth: 1.5,
                borderColor: context.color.borderColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UiUtils.imageType(category.image!,
                        width: 20,
                        height: 20,
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null),
                    SizedBox(width: 12.rw(context)),
                    SizedBox(
                      child: Text(category.category!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)
                          .size(context.font.small),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
