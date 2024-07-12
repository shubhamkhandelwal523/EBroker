import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../widgets/shimmerLoadingContainer.dart';

class SliderShimmer extends StatelessWidget {
  const SliderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          CustomShimmer(
            height: 130.rh(context),
            width: context.screenWidth,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class PromotedPropertiesShimmer extends StatelessWidget {
  const PromotedPropertiesShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 261,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: CustomShimmer(
                  height: 272.rh(context),
                  width: 250.rw(context),
                ),
              );
            }));
  }
}

class MostLikedPropertiesShimmer extends StatelessWidget {
  const MostLikedPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 162.rw(context) / 274.rh(context),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: 2),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: CustomShimmer(),
        );
      },
    );
  }
}

class NearbyPropertiesShimmer extends StatelessWidget {
  const NearbyPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: const CustomShimmer(
                  height: 200,
                  width: 300,
                ),
              );
            }));
  }
}

class MostViewdPropertiesShimmer extends StatelessWidget {
  const MostViewdPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 162.rw(context) / 274.rh(context),
            mainAxisSpacing: 15,
            crossAxisCount: 2),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomShimmer(),
          );
        });
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        itemBuilder: (context, index) {
          return CustomShimmer(
            width: 100.rw(context),
            height: 44.rh(context),
            margin: const EdgeInsetsDirectional.only(end: 10, bottom: 5),
          );
        });
  }
}
