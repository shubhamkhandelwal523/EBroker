import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ChooseLocationMap extends StatefulWidget {
  final num? latitude;
  final num? longitude;
  const ChooseLocationMap({super.key, this.latitude, this.longitude});
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return ChooseLocationMap(
          latitude: arguments?['latitude'],
          longitude: arguments?['longitude'],
        );
      },
    );
  }

  @override
  State<ChooseLocationMap> createState() => _ChooseLocationMapState();
}

class _ChooseLocationMapState extends State<ChooseLocationMap> {
  final TextEditingController _searchController = TextEditingController();
  String previouseSearchQuery = "";
  LatLng? citylatLong;
  Timer? _timer;
  Marker? marker;
  Map map = {};
  GoogleMapController? _googleMapController;
  Completer<GoogleMapController> completer = Completer();
  final FocusNode _searchFocus = FocusNode();
  List<GooglePlaceModel>? cities;
  int selectedMarker = 999999999999999;
  int? propertyId;
  ValueNotifier<bool> isLoadingProperty = ValueNotifier<bool>(false);
  PropertyModel? activePropertyModal;
  ValueNotifier<bool> loadintCitiesInProgress = ValueNotifier<bool>(false);
  bool showSellRentLables = false;
  bool showGoogleMap = false;
  Future<void> searchDelayTimer() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    _timer = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (_searchController.text.isNotEmpty) {
          if (previouseSearchQuery != _searchController.text) {
            try {
              loadintCitiesInProgress.value = true;
              cities = await GooglePlaceRepository().serchCities(
                _searchController.text,
              );
              loadintCitiesInProgress.value = false;
            } catch (e) {
              loadintCitiesInProgress.value = false;
            }

            setState(() {});
            previouseSearchQuery = _searchController.text;
          }
        } else {
          cities = null;
        }
      },
    );
    setState(() {});
  }

  late var assigned = LatLng(
    widget.latitude?.toDouble() ?? 42.42345651793833,
    widget.longitude?.toDouble() ?? 23.906250000000004,
  );
  late LatLng cameraPosition = assigned;

  Future setCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      Future<void> animateCamera = (await completer.future).animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude), zoom: 7),
        ),
      );
    } else {
      await Geolocator.requestPermission();
    }

    marker = Marker(
        markerId: const MarkerId("9999999"),
        position: LatLng(position.latitude, position.longitude));
    Future.delayed(
      Duration.zero,
      () {
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    _searchController.addListener(() {
      searchDelayTimer();
    });
    if (widget.latitude != null && widget.longitude != null) {
      marker = Marker(markerId: const MarkerId("9999999"), position: assigned);
      setState(() {});
    } else {
      setCurrentLocation();
    }
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        showGoogleMap = true;
        setState(() {});
      },
    );

    super.initState();
  }

  Future<void> onTapCity(int index) async {
    Widgets.showLoader(context);

    LatLng? latLng = await getCityLatLong(index);
    //Animate camera to location
    (await completer.future).animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng!, zoom: 7),
      ),
    );

    marker = (Marker(
        markerId: MarkerId(
          index.toString(),
        ),
        position: latLng));

    _searchFocus.unfocus();
    HelperUtils.unfocus();
    Future.delayed(
      Duration.zero,
      () {
        Widgets.hideLoder(context);
      },
    );

    cities = null;
    setState(() {});
  }

  Future<void> fetchProperty(int id) async {
    try {
      isLoadingProperty.value = true;
      DataOutput<PropertyModel> result =
          await PropertyRepository().fetchPropertyFromPropertyId(id);
      activePropertyModal = result.modelList.first;
      setState(() {});
      isLoadingProperty.value = false;
    } catch (e) {
      isLoadingProperty.value = false;

      HelperUtils.showSnackBarMessage(context, "error".translate(context));
    }
  }

  Future<LatLng?>? getCityLatLong(index) async {
    var rawCityLatLong = await GooglePlaceRepository()
        .getPlaceDetailsFromPlaceId(cities?.elementAt(index).placeId ?? "");

    var citylatLong = LatLng(rawCityLatLong['lat'], rawCityLatLong['lng']);
    return citylatLong;
  }

  @override
  void dispose() async {
    _googleMapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? getComponent(List data, dynamic dm) {
    // log("CALLED");
    try {
      return data.where((element) {
        return (element['types'] as List).contains(dm);
      }).first['long_name'];
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: UiUtils.getSvg(AppIcons.search,
              color: context.color.tertiaryColor));
    }

    return WillPopScope(
      onWillPop: () async {
        _googleMapController?.dispose();
        (await completer.future).dispose();
        showGoogleMap = false;
        setState(() {});

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: SizedBox(
            child: MaterialButton(
              height: 50,
              color: context.color.tertiaryColor,
              onPressed: marker == null
                  ? null
                  : () async {
                      try {
                        String? state = "";
                        String? city = "";
                        String? country = "";
                        String? sublocality = "";
                        String? pointofinterest = "";
                        Response response = await Dio().get(
                            "https://maps.googleapis.com/maps/api/geocode/json?key=${Constant.googlePlaceAPIkey}&latlng=${marker?.position.latitude},${marker?.position.longitude}");

                        if ((response.data as Map)
                            .containsKey("error_message")) {
                          throw response.data;
                        }
                        List component = List.from(
                            response.data['results'][0]['address_components']);

                        city = getComponent(
                          component,
                          "locality",
                        );
                        state = getComponent(
                            component, "administrative_area_level_1");
                        country = getComponent(component, "country");
                        sublocality = getComponent(component, "sublocality");

                        pointofinterest =
                            getComponent(component, "point_of_interest");

                        bool? startsWith = pointofinterest?.contains(",");
                        if (startsWith ?? false) {
                          pointofinterest =
                              pointofinterest?.replaceFirst(",", "");
                        }

                        Placemark place = Placemark(
                            locality: city,
                            administrativeArea: state,
                            country: country,
                            subLocality: sublocality,
                            street: pointofinterest);

                        showGoogleMap = false;
                        setState(() {});

                        Future.delayed(
                          const Duration(milliseconds: 0),
                          () {
                            Navigator.pop<Map>(context, {
                              "latlng": LatLng(marker!.position.latitude,
                                  marker!.position.longitude),
                              "place": place
                            });
                          },
                        );
                      } catch (e) {
                        if (e is Map) {
                          if (e.containsKey("error_message")) {
                            HelperUtils.showSnackBarMessage(
                                context, e['error_message'],
                                messageDuration: 5);
                          }
                        }

                        if (e.toString().contains("IO_ERROR")) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("pleaseChangeNetwork"
                                  .translate(context)
                                  .toString())));
                        }
                      }
                    },
              child: Text("proceed".translate(context)).color(marker == null
                  ? context.color.textColorDark
                  : context.color.buttonColor),
            ),
          ),
          backgroundColor: context.color.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            titleSpacing: 0,
            actions: [
              FittedBox(
                  fit: BoxFit.none,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: ValueListenableBuilder(
                        valueListenable: loadintCitiesInProgress,
                        builder: (context, va, c) {
                          if (va == false) {
                            return const SizedBox.shrink();
                          }
                          return CircularProgressIndicator(
                            color: context.color.tertiaryColor,
                            strokeWidth: 1.5,
                          );
                        }),
                  ))
            ],
            leading: cities != null
                ? IconButton(
                    onPressed: () {
                      cities = null;
                      _searchController.text = "";
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.close,
                      color: context.color.tertiaryColor,
                    ))
                : Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    type: MaterialType.circle,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: UiUtils.getSvg(AppIcons.arrowLeft,
                            fit: BoxFit.none,
                            color: context.color.tertiaryColor),
                      ),
                    ),
                  ),
            title: Container(
                width: 270.rw(context),
                height: 50.rh(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: context.color.secondaryColor),
                child: TextFormField(
                    focusNode: _searchFocus,
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none, //OutlineInputBorder()
                      fillColor: Theme.of(context).colorScheme.secondaryColor,
                      hintText: UiUtils.translate(context, "searhCity"),
                      prefixIcon: buildSearchIcon(),
                      prefixIconConstraints:
                          const BoxConstraints(minHeight: 5, minWidth: 5),
                    ),
                    enableSuggestions: true,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                    onTap: () {
                      //change prefix icon color to primary
                    })),
          ),
          body: Stack(
            children: [
              SizedBox(
                height: context.screenHeight,
                width: context.screenWidth,
                child: showGoogleMap == true
                    ? GoogleMap(
                        markers: marker == null ? {} : {marker!},
                        onMapCreated: (controller) {
                          completer.complete(controller);
                          showSellRentLables = true;
                          setState(() {});
                        },
                        onTap: (argument) {
                          activePropertyModal = null;
                          selectedMarker = 99999999999999;

                          marker = Marker(
                              markerId: const MarkerId("0"),
                              position: LatLng(
                                  argument.latitude, argument.longitude));
                          setState(() {});
                        },
                        mapType: AppSettings.googleMapType,
                        compassEnabled: false,
                        scrollGesturesEnabled: true,
                        mapToolbarEnabled: false,
                        trafficEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        initialCameraPosition:
                            CameraPosition(target: cameraPosition, zoom: 7),
                        key: const Key("G-map"),
                      )
                    : const SizedBox.shrink(),
              ),
              if (cities != null)
                Container(
                  color: context.color.backgroundColor,
                  child: ListView.builder(
                    itemCount: cities?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          activePropertyModal = null;
                          setState(() {});
                          onTapCity(index);
                        },
                        leading: SvgPicture.asset(
                          AppIcons.location,
                          color: context.color.textColorDark,
                        ),
                        title: Text(cities?.elementAt(index).city ?? ""),
                        subtitle: Text(
                            "${cities?.elementAt(index).state ?? ""},${cities?.elementAt(index).country ?? ""}"),
                      );
                    },
                  ),
                ),
              // PositionedDirectional(
              //     bottom: 0,
              //     child: ValueListenableBuilder(
              //         valueListenable: isLoadingProperty,
              //         builder: (context, val, child) {
              //           if (cities != null) {
              //             return const SizedBox.shrink();
              //           }
              //           if (val == true) {
              //             return SizedBox(
              //               width: MediaQuery.of(context).size.width,
              //               child: Padding(
              //                 padding: const EdgeInsets.all(20.0),
              //                 child: Row(
              //                   children: const [
              //                     CustomShimmer(
              //                       width: 100,
              //                       height: 110,
              //                     ),
              //                     SizedBox(
              //                       width: 5,
              //                     ),
              //                     Expanded(
              //                       child: CustomShimmer(
              //                         height: 110,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             );
              //           } else {
              //             if (activePropertyModal != null) {
              //               return SizedBox(
              //                 width: MediaQuery.of(context).size.width,
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(20),
              //                   child: GestureDetector(
              //                     onTap: () {
              //                       Navigator.pushNamed(
              //                           context, Routes.propertyDetails,
              //                           arguments: {
              //                             'propertyData': activePropertyModal,
              //                             'fromMyProperty': true,
              //                           });
              //                     },
              //                     child: PropertyHorizontalCard(
              //                         showLikeButton: false,
              //                         property: activePropertyModal!),
              //                   ),
              //                 ),
              //               );
              //             } else {
              //               return Container();
              //             }
              //           }
              //         }))
            ],
          ),
        ),
      ),
    );
  }

  Padding sellRentLable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: Colors.green,
          ),
          const SizedBox(
            width: 3,
          ),
          const Text("Sell").color(context.color.buttonColor),
          const SizedBox(
            width: 10,
          ),
          Container(
            width: 20,
            height: 20,
            color: Colors.orange,
          ),
          const SizedBox(
            width: 3,
          ),
          const Text("Rent").color(context.color.buttonColor),
        ],
      ),
    );
  }
}
