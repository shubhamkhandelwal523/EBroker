import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/cubits/system/user_details.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/ui_utils.dart';

class CircularProfileImageWidget extends StatelessWidget {
  const CircularProfileImageWidget({super.key});
  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
          color: context.color.tertiaryColor.withOpacity(0.1),
          shape: BoxShape.circle),
      child: Center(
        child: UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.showFullScreenImage(
          context,
          provider: NetworkImage(
            context.read<UserDetailsCubit>().state.user?.profile ?? "",
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.only(bottom: 5),
        child: FittedBox(
          fit: BoxFit.cover,
          child: GestureDetector(
            onTap: () {
              if (context.read<UserDetailsCubit>().state.user?.profile !=
                  null) {
                UiUtils.showFullScreenImage(context,
                    provider: NetworkImage(
                        context.read<UserDetailsCubit>().state.user?.profile ??
                            ""));
              }

              // MainActivityState.pageCntrlr.jumpToPage(4);
            },
            child: (context.watch<UserDetailsCubit>().state.user?.profile ?? "")
                    .trim()
                    .isEmpty
                ? FittedBox(
                    fit: BoxFit.none,
                    child: buildDefaultPersonSVG(
                      context,
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      context.watch<UserDetailsCubit>().state.user?.profile ??
                          "",
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget? child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child!;
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
