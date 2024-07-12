import 'package:ebroker/data/repositories/map.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:label_marker/label_marker.dart';

class PropertyMapScreen extends StatefulWidget {
  const PropertyMapScreen({super.key});
  static Route route(RouteSettings settings) {
    // Map? arguments = settings.arguments as Map?;
    return BlurredRouter(builder: (context) {
      return const PropertyMapScreen();
    });
  }

  @override
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String previouseSearchQuery = "";
  LatLng? citylatLong;
  Timer? _timer;
  Set<Marker> marker = {};
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
  bool showGoogleMap = true;

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

  @override
  void initState() {
    loadDefaultCity();
    Fluttertoast.showToast(
        msg: "Please search city",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    _searchController.addListener(() {
      searchDelayTimer();
    });
    super.initState();
  }

  LatLng cameraPosition = const LatLng(
    42.42345651793833,
    23.906250000000004,
  );

  Future<void> loadDefaultCity() async {
    if (HiveUtils.getCityName() == null) return;
    List<MapPoint> pointList = await GMap.getNearByProperty(
        HiveUtils.getCityName() ?? "", HiveUtils.getStateName() ?? "");

    if (pointList.isEmpty) {
      marker = {};
      setState(() {});
    }

    LatLng? latLng = await getCityLatLong(HiveUtils.getCityPlaceId());
    //Animate camera to location
    (await completer.future).animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 7)));
    loopMarker(pointList);
  }

  Future<void> onTapCity(int index) async {
    Widgets.showLoader(context);
    List<MapPoint> pointList = await GMap.getNearByProperty(
        cities?.elementAt(index).city ?? "",
        cities?.elementAt(index).state ?? "");

    if (pointList.isEmpty) {
      marker = {};
      setState(() {});
    }

    LatLng? latLng = await getCityLatLongByIndex(index);
    //Animate camera to location
    (await completer.future).animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng!, zoom: 7),
      ),
    );
    loopMarker(pointList);
    // for (var i = 0; i < pointList.length; i++) {
    //   var element = pointList[i];

    //   //Add markers inside marker list
    //   marker
    //       .addLabelMarker(LabelMarker(
    //     label: r"$" + (element.price).toString().priceFormate(),
    //     markerId: MarkerId("$i"),
    //     onTap: () async {
    //       selectedMarker = i;
    //       setState(() {});
    //     },
    //     position: LatLng(
    //         double.parse(element.latitude), double.parse(element.longitude)),
    //     backgroundColor: selectedMarker == i
    //         ? Colors.red
    //         : (element.propertyType == "sell" ? Colors.green : Colors.orange),
    //   ))
    //       .then(
    //     (value) {
    //       setState(() {});
    //     },
    //   );
    // }

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

  void loopMarker(List<MapPoint> pointList) {
    for (var i = 0; i < pointList.length; i++) {
      var element = pointList[i];
      print("element.propertyType ${element.propertyType}");
      marker
          .addLabelMarker(LabelMarker(
        label:
            Constant.currencySymbol + (element.price).toString().priceFormate(),
        markerId: MarkerId("$i"),
        onTap: () async {
          selectedMarker = i;
          propertyId = element.propertyId;
          marker.clear();
          loopMarker(pointList);
          setState(() {});
          fetchProperty(element.propertyId);
        },
        position: LatLng(
            double.parse(element.latitude), double.parse(element.longitude)),
        backgroundColor: selectedMarker == i
            ? Colors.red
            : (element.propertyType.toLowerCase() == "sell"
                ? Colors.green
                : Colors.orange),
      ))
          .then(
        (value) {
          setState(() {});
        },
      );
    }
  }

  Future<void> fetchProperty(int id) async {
    try {
      isLoadingProperty.value = true;
      DataOutput<PropertyModel> result =
          await PropertyRepository().fetchPropertyFromPropertyId(id);

      if (result.modelList.isNotEmpty) {
        activePropertyModal = result.modelList.first;
      }
      setState(() {});
      isLoadingProperty.value = false;
    } catch (e) {
      isLoadingProperty.value = false;

      HelperUtils.showSnackBarMessage(context, "$e".translate(context));
    }
  }

  Future<LatLng?>? getCityLatLongByIndex(index) async {
    // var rawCityLatLong = await GooglePlaceRepository()
    //     .getPlaceDetailsFromPlaceId(cities?.elementAt(index).placeId ?? "");

    LatLng latLng =
        await getCityLatLong(cities?.elementAt(index).placeId ?? "");
    return latLng;
  }

  Future<LatLng> getCityLatLong(String placeId) async {
    var rawCityLatLong =
        await GooglePlaceRepository().getPlaceDetailsFromPlaceId(placeId);

    var citylatLong = LatLng(rawCityLatLong['lat'], rawCityLatLong['lng']);
    return citylatLong;
  }

  @override
  void dispose() async {
    _googleMapController?.dispose();
    _searchController.dispose();
    super.dispose();
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
                      hintText: UiUtils.translate(context, "searchHintLbl"),
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
              if (showGoogleMap)
                GoogleMap(
                  markers: marker,
                  onMapCreated: (controller) {
                    completer.complete(controller);
                    showSellRentLables = true;
                    setState(() {});
                  },
                  onTap: (argument) {
                    activePropertyModal = null;
                    selectedMarker = 99999999999999;
                    setState(() {});
                  },
                  mapType: AppSettings.googleMapType,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  trafficEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: cameraPosition,
                  ),
                ),
              sellRentLable(context),
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
              PositionedDirectional(
                  bottom: 0,
                  child: ValueListenableBuilder(
                      valueListenable: isLoadingProperty,
                      builder: (context, val, child) {
                        if (cities != null) {
                          return const SizedBox.shrink();
                        }
                        if (val == true) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  CustomShimmer(
                                    width: 100,
                                    height: 110,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: CustomShimmer(
                                      height: 110,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          if (activePropertyModal != null) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.propertyDetails,
                                        arguments: {
                                          'propertyData': activePropertyModal,
                                          'fromMyProperty': true,
                                        });
                                  },
                                  child: PropertyHorizontalCard(
                                      showLikeButton: false,
                                      property: activePropertyModal!),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }
                      }))
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
