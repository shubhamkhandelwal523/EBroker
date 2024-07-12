import 'package:ebroker/ui/screens/widgets/bottom_sheets/choose_location_bottomsheet.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../data/cubits/auth/auth_cubit.dart';
import '../../../../data/cubits/property/fetch_nearby_property_cubit.dart';
import '../../../../data/model/google_place_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/hive_utils.dart';
import '../../../../utils/ui_utils.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String city = "", state = "", country = "";
  @override
  void initState() {
    Hive.box(HiveKeys.userDetailsBox)
        .listenable(keys: ["city", "state", "country"]).addListener(() {
      city = HiveUtils.getCityName().toString().trim();
      state = HiveUtils.getStateName().toString().trim();
      country = HiveUtils.getCountryName().toString().trim();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    city = HiveUtils.getCityName().toString().trim();
    state = HiveUtils.getStateName().toString().trim();
    country = HiveUtils.getCountryName().toString().trim();

    List<String> locationList = [city, state, country];
    locationList.removeWhere((element) {
      return element.isEmpty;
    });

    String joinedLocation = locationList.join(',');
    return FittedBox(
      fit: BoxFit.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.rw(context),
          ),
          GestureDetector(
            onTap: () async {
              var result = await showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return const ChooseLocatonBottomSheet();
                },
              );
              if (result != null) {
                GooglePlaceModel place = (result as GooglePlaceModel);
                HiveUtils.setLocation(
                    city: place.city,
                    state: place.state,
                    latitude: double.parse(place.latitude),
                    longitude: double.parse(place.longitude),
                    country: place.country,
                    placeId: place.placeId);
                context.read<AuthCubit>().updateUserData(context,
                    city: place.city,
                    state: place.state,
                    country: place.country,
                    latitude: double.parse(place.latitude),
                    longitude: double.parse(place.longitude));
                Future.delayed(
                  Duration.zero,
                  () {
                    // context
                    //     .read<FetchMostViewedPropertiesCubit>()
                    //     .fetch();
                    // context
                    //     .read<FetchPromotedPropertiesCubit>()
                    //     .fetch();
                    // context.read<SliderCubit>().fetchSlider(context);
                    context
                        .read<FetchNearbyPropertiesCubit>()
                        .fetch(forceRefresh: true);
                  },
                );

                // city = place.city;
                // country = place.country;
                // _state = place.state;
              }

              // const ChooseLocatonBottomSheet();
            },
            child: Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10.rw(context),
          ),
          ValueListenableBuilder(
              valueListenable: Hive.box(HiveKeys.userDetailsBox).listenable(),
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(UiUtils.translate(context, "locationLbl"))
                        .color(context.color.textColorDark)
                        .size(
                          context.font.small,
                        ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        joinedLocation,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )
                          .color(context.color.textColorDark)
                          .size(context.font.small)
                          .bold(weight: FontWeight.w600),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
