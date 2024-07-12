import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CityHeadingCard extends StatelessWidget {
  const CityHeadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 211,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/city.jpg", fit: BoxFit.cover),
          Directionality(
            textDirection: Directionality.of(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.centerLeft,
                  radius: 3,
                  focalRadius: 1,
                  colors: [
                    Colors.black.withOpacity(0.97),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 50,
            start: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 34,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Popular cities").color(Colors.white).size(32),
                  ],
                ),
                Text("${context.watch<FetchCityCategoryCubit>().getCount() ?? 0}+ Properties")
                    .color(Colors.white)
              ],
            ),
          )
        ],
      ),
    );
  }
}
