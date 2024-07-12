import 'package:flutter/material.dart';

import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';

class AnalyticsScreen extends StatelessWidget {
  final String interestUserCount;
  const AnalyticsScreen({super.key, required this.interestUserCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: context.screenWidth,
              height: 100,
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(UiUtils.translate(context, "interestedUserCount"))
                        .color(context.color.textColorDark)
                        .size(context.font.larger)
                        .bold(),
                    Center(
                      child: Text(interestUserCount)
                          .color(context.color.textColorDark)
                          .size(context.font.extraLarge)
                          .italic(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
