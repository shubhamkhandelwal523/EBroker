// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:convert';
import 'dart:ui';

import 'package:ebroker/data/cubits/Report/property_report_cubit.dart';
import 'package:ebroker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:ebroker/data/cubits/property/delete_property_cubit.dart';
import 'package:ebroker/data/cubits/property/update_property_status.dart';
import 'package:ebroker/data/model/interested_user_model.dart';
import 'package:ebroker/data/repositories/interest_repository.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:ebroker/ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/report_property_widget.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/panaroma_image_view.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/cubits/Interested/get_interested_user_cubit.dart';
import '../../../data/model/category.dart';
import '../../../utils/AdMob/interstitialAdManager.dart';
import '../analytics/analytics_screen.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/video_view_screen.dart';

Map<String, String> rentDurationMap = {
  "Quarterly": "Quarter",
  "Monthly": "Month",
  "Yearly": "Year",
  "Daily": "Daily",
  "Day": "Day"
};

class PropertyDetails extends StatefulWidget {
  final PropertyModel? property;
  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool fromSlider;
  final bool? fromPropertyAddSuccess;
  const PropertyDetails(
      {Key? key,
      this.fromPropertyAddSuccess,
      required this.property,
      this.fromSlider = false,
      this.fromMyProperty,
      this.fromCompleteEnquiry})
      : super(key: key);

  @override
  PropertyDetailsState createState() => PropertyDetailsState();

  static Route route(RouteSettings routeSettings) {
    try {
      Map? arguments = routeSettings.arguments as Map?;
      return BlurredRouter(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChangeInterestInPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => UpdatePropertyStatusCubit(),
            ),
            BlocProvider(
              create: (context) => DeletePropertyCubit(),
            ),
            BlocProvider(
              create: (context) => PropertyReportCubit(),
            ),
            BlocProvider(
              create: (context) => GetInterestedUserCubit(),
            ),
          ],
          child: PropertyDetails(
            property: arguments?['propertyData'],
            fromMyProperty: arguments?['fromMyProperty'] ?? false,
            fromSlider: arguments?['fromSlider'] ?? false,
            fromCompleteEnquiry: arguments?['fromCompleteEnquiry'] ?? false,
            fromPropertyAddSuccess: arguments?['fromSuccess'] ?? false,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FlickManager? flickManager;
  ValueNotifier<bool> shouldShowSubscriptionOverlay = ValueNotifier(false);
  // late Property propertyData;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List promotedProeprtiesIds = [];
  bool toggleEnqButton = false;
  PropertyModel? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;
  BannerAd? _bannerAd;
  @override
  bool get wantKeepAlive => true;
  GlobalKey appBarKey = GlobalKey();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Gallery>? gallary;
  String youtubeVideoThumbnail = "";
  bool? _isLoaded;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  bool isPremiumProperty = true;
  bool isPremiumUser = false;
  bool isReported = false;

  bool shouldRestrictPropertyAccess() {
    if (isPremiumProperty && !isPremiumUser) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    context
        .read<GetSubsctiptionPackageLimitsCubit>()
        .getLimits(SubscriptionLimitType.property);
    isPremiumProperty = widget.property?.allPropData['is_premium'] ?? false;

    isPremiumUser = context
            .read<FetchSystemSettingsCubit>()
            .getRawSettings()['is_premium'] ??
        false;
    isReported = widget.property?.allPropData?['is_reported'] ?? false;

    loadAd();
    // Future.delayed(
    //   Duration(milliseconds: 50),
    //   () {
    //     Map<String, double> widgetInfo =
    //         UiUtils.getWidgetInfo(context, appBarKey);
    //     bottomAppBarHeight = widgetInfo['height'] ?? 0;
    //     setState(() {});
    //   },
    // );
    interstitialAdManager.load();
    // customListenerForConstant();
    //add title image along with gallery images
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    context.read<GetInterestedUserCubit>().fetch("${widget.property?.id}");
    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gallary = List.from(widget.property!.gallery!);
      if (widget.property?.video != "") {
        injectVideoInGallery();
        setState(() {});
      }
    });

    if (widget.fromSlider) {
      getProperty();
    } else {
      property = widget.property;
      setData();
    }

    setViewdProperty();
    if (widget.property?.video != "" &&
        widget.property?.video != null &&
        !HelperUtils.isYoutubeVideo(widget.property?.video ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
          property!.video!,
        ),
      );
      flickManager?.onVideoEnd = () {};
    }

    if (widget.property?.video != "" &&
        widget.property?.video != null &&
        HelperUtils.isYoutubeVideo(widget.property?.video ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(property!.video!);
      String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
    }
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: Constant.admobBannerAndroid,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> getProperty() async {
    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty,
        {
          Api.id: widget.property!.id,
        },
        true,
        context,
        passUserid: false);
    if (response != null) {
      var getdata = json.decode(response);
      if (!getdata[Api.error]) {
        getdata['data'];
        setData();
        setState(() {});
      }
    }
  }

  void setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  void setViewdProperty() {
    if (property!.addedBy.toString() != HiveUtils.getUserId()) {
      context.read<SetPropertyViewCubit>().set(property!.id!.toString());
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        (property?.latitude ?? "0"),
      ),
      double.parse(
        (property?.longitude ?? "0"),
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    flickManager?.dispose();

    super.dispose();
  }

  void injectVideoInGallery() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (widget.property?.video != null) {
        gallary?.add(Gallery(
            id: 99999999999,
            image: property!.video ?? "",
            imageUrl: "",
            isVideo: true));
      }
    } else {
      gallary?.insert(
          0,
          Gallery(
              id: 99999999999,
              image: property!.video!,
              imageUrl: "",
              isVideo: true));
    }

    setState(() {});
  }

  String? _statusFilter(String value) {
    if (value == "Sell" || value == "sell") {
      return "sold".translate(context);
    }
    if (value == "Rent" || value == "rent") {
      return "Rented".translate(context);
    }

    return null;
  }

  int? _getStatus(type) {
    int? value;
    if (type == "Sell" || type == "sell") {
      value = 2;
    } else if (type == "Rent" || type == "rent") {
      value = 3;
    } else if (type == "Rented" || type == "rented") {
      value = 1;
    }
    return value;
  }

//main build
  @override
  Widget build(BuildContext context) {
    super.build(context);

    print("ISRENTED ${isPremiumProperty} nd ${isPremiumUser}");

    String rentPrice = (property!.price!
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
        )
        .toString()
        .formatAmount(prefix: true));

    if (property?.rentduration != "" && property?.rentduration != null) {
      rentPrice =
          ("$rentPrice / ") + (rentDurationMap[property!.rentduration] ?? "");
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          await interstitialAdManager.show();
          if (widget.fromPropertyAddSuccess ?? false) {
            Navigator.popUntil(context, (route) => route.isFirst);
            return false;
          }

          showGoogleMap = false;
          setState(() {});

          return true;
        },
        child: AnnotatedRegion(
          value: UiUtils.getSystemUiOverlayStyle(
            context: context,
          ),
          child: SafeArea(
              child: BlocListener<GetSubsctiptionPackageLimitsCubit,
                  GetSubscriptionPackageLimitsState>(
            listener: (context, state) {
              if (state is GetSubscriptionPackageLimitsSuccess) {
                isPremiumUser = state.packageLimit.isPremium;
                setState(() {});
              }
            },
            child: Stack(
              children: [
                Scaffold(
                  appBar: UiUtils.buildAppBar(context,
                      hideTopBorder: true,
                      showBackButton: true,
                      actions: [
                        if (!HiveUtils.isGuest()) ...[
                          if (int.parse(HiveUtils.getUserId() ?? "0") ==
                              property?.addedBy)
                            IconButton(
                                onPressed: () async {
                                  DataOutput<InterestedUserModel> interestUser =
                                      await InterestRepository()
                                          .getInterestUser(
                                              property!.id!.toString(),
                                              offset: 0);

                                  GetInterestedUserCubit
                                      interestedUserCubitReference =
                                      context.read<GetInterestedUserCubit>();

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    enableDrag: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: context
                                        .color.secondaryColor
                                        .withOpacity(0.86),
                                    constraints: BoxConstraints(
                                        minWidth: double.infinity,
                                        maxHeight: context.screenHeight * 0.7,
                                        minHeight: context.screenHeight * 0.3),
                                    builder: (context) {
                                      return InterestedUserListWidget(
                                          totalCount:
                                              "${widget.property?.totalInterestedUsers}",
                                          interestedUserCubitReference:
                                              interestedUserCubitReference);
                                    },
                                  );

                                  return;
                                  Navigator.push(context, BlurredRouter(
                                    builder: (context) {
                                      return AnalyticsScreen(
                                        interestUserCount: widget
                                            .property!.totalInterestedUsers
                                            .toString(),
                                      );
                                    },
                                  ));
                                },
                                icon: Icon(
                                  Icons.analytics,
                                  color: context.color.tertiaryColor,
                                )),
                        ],
                        IconButton(
                          onPressed: () {
                            HelperUtils.share(
                                context, property!.id!, property?.slugId ?? "");
                          },
                          icon: Icon(
                            Icons.share,
                            color: context.color.tertiaryColor,
                          ),
                        ),
                        if (property?.addedBy.toString() ==
                                HiveUtils.getUserId() &&
                            property!.properyType != "Sold" &&
                            property?.status == 1)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              var action = await UiUtils.showBlurredDialoge(
                                context,
                                dialoge: BlurredDialogBuilderBox(
                                    title: "changePropertyStatus"
                                        .translate(context),
                                    acceptButtonName:
                                        "change".translate(context),
                                    contentBuilder: (context, s) {
                                      return FittedBox(
                                        fit: BoxFit.none,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: context
                                                      .color.tertiaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              width: s.maxWidth / 4,
                                              height: 50,
                                              child: Center(
                                                  child: Text(property!
                                                          .properyType!
                                                          .translate(context))
                                                      .color(context
                                                          .color.buttonColor)),
                                            ),
                                            Text(
                                              "toArrow".translate(context),
                                            ),
                                            Container(
                                              width: s.maxWidth / 4,
                                              decoration: BoxDecoration(
                                                  color: context
                                                      .color.tertiaryColor
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: 50,
                                              child: Center(
                                                  child: Text(_statusFilter(
                                                              property!
                                                                  .properyType!) ??
                                                          "")
                                                      .color(context
                                                          .color.buttonColor)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              );
                              if (action == true) {
                                Future.delayed(Duration.zero, () {
                                  context
                                      .read<UpdatePropertyStatusCubit>()
                                      .update(
                                        propertyId: property!.id,
                                        status:
                                            _getStatus(property!.properyType),
                                      );
                                });
                              }
                            },
                            color: context.color.secondaryColor,
                            itemBuilder: (BuildContext context) {
                              return {
                                'changeStatus'.translate(context),
                              }.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  textStyle: TextStyle(
                                      color: context.color.textColorDark),
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: context.color.tertiaryColor,
                              ),
                            ),
                          ),
                        const SizedBox(
                          width: 10,
                        )
                      ]),
                  backgroundColor: context.color.backgroundColor,
                  floatingActionButton: (property == null ||
                          property!.addedBy.toString() == HiveUtils.getUserId())
                      ? const SizedBox.shrink()
                      : Container(),
                  bottomNavigationBar: isPlayingYoutubeVideo == false
                      ? BottomAppBar(
                          key: appBarKey,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          color: context.color.secondaryColor,
                          child: bottomNavBar())
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  body: BlocListener<DeletePropertyCubit, DeletePropertyState>(
                    listener: (context, state) {
                      if (state is DeletePropertyInProgress) {
                        Widgets.showLoader(context);
                      }

                      if (state is DeletePropertySuccess) {
                        Widgets.hideLoder(context);
                        Future.delayed(
                          const Duration(milliseconds: 1000),
                          () {
                            Navigator.pop(context, true);
                          },
                        );
                      }
                      if (state is DeletePropertyFailure) {
                        Widgets.showLoader(context);
                      }
                    },
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: BlocListener<UpdatePropertyStatusCubit,
                            UpdatePropertyStatusState>(
                          listener: (context, state) {
                            if (state is UpdatePropertyStatusInProgress) {
                              Widgets.showLoader(context);
                            }

                            if (state is UpdatePropertyStatusSuccess) {
                              Widgets.hideLoder(context);
                              Fluttertoast.showToast(
                                  msg: "statusUpdated".translate(context),
                                  backgroundColor: successMessageColor,
                                  gravity: ToastGravity.TOP,
                                  toastLength: Toast.LENGTH_LONG);

                              (cubitReference as FetchMyPropertiesCubit)
                                  .updateStatus(
                                      property!.id!, property!.properyType!);
                              setState(() {});
                            }
                            if (state is UpdatePropertyStatusFail) {
                              Widgets.hideLoder(context);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isPlayingYoutubeVideo == false ? 20.0 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),

                                if (!isPlayingYoutubeVideo)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SizedBox(
                                          height: 227.rh(context),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // google map doesn't allow blur so we hide it:)
                                                  showGoogleMap = false;
                                                  setState(() {});
                                                  UiUtils.showFullScreenImage(
                                                    context,
                                                    provider: NetworkImage(
                                                      property!.titleImage!,
                                                    ),
                                                    then: () {
                                                      showGoogleMap = true;
                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                child: UiUtils.getImage(
                                                  property!.titleImage!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 227.rh(context),
                                                  showFullScreenImage: true,
                                                ),
                                              ),
                                              PositionedDirectional(
                                                top: 20,
                                                end: 20,
                                                child: LikeButtonWidget(
                                                  onStateChange:
                                                      (AddToFavoriteCubitState
                                                          state) {
                                                    if (state
                                                        is AddToFavoriteCubitInProgress) {
                                                      favoriteInProgress = true;
                                                      setState(
                                                        () {},
                                                      );
                                                    } else {
                                                      favoriteInProgress =
                                                          false;
                                                      setState(
                                                        () {},
                                                      );
                                                    }
                                                  },
                                                  property: property!,
                                                ),
                                              ),
                                              PositionedDirectional(
                                                bottom: 5,
                                                end: 18,
                                                child: Visibility(
                                                  visible:
                                                      property?.threeDImage !=
                                                          "",
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        BlurredRouter(
                                                          builder: (context) =>
                                                              PanaromaImageScreen(
                                                            imageUrl: property!
                                                                .threeDImage!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: context.color
                                                            .secondaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      height: 40.rh(context),
                                                      width: 40.rw(context),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: UiUtils.getSvg(
                                                            AppIcons.v360Degree,
                                                            color: context.color
                                                                .tertiaryColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              advertismentLable()
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        UiUtils.imageType(
                                            property?.category!.image ?? "",
                                            width: 18,
                                            height: 18,
                                            color: Constant.adaptThemeColorSvg
                                                ? context.color.tertiaryColor
                                                : null),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 158.rw(context),
                                          child: Text(
                                                  property!.category!.category!)
                                              .setMaxLines(lines: 1)
                                              .size(
                                                context.font.normal,
                                              )
                                              .bold(
                                                weight: FontWeight.w400,
                                              )
                                              .color(UiUtils.makeColorLight(
                                                  context.color.textColorDark)),
                                        ),
                                        const Spacer(),
                                        Container(
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3.5),
                                              color:
                                                  context.color.tertiaryColor),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Center(
                                                child: Text(
                                              property!.properyType
                                                  .toString()
                                                  .toLowerCase()
                                                  .translate(context),
                                            ).size(context.font.small).color(
                                                    context.color.buttonColor)),
                                          ),
                                        )
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(property!.title!
                                                    .firstUpperCase())
                                                .color(
                                                    context.color.textColorDark)
                                                .size(18)
                                                .bold(weight: FontWeight.w600),
                                          ),
                                          Text(property?.postCreated ?? "")
                                              .color(context.color.textColorDark
                                                  .withOpacity(0.6)),
                                        ],
                                      ),
                                      const SizedBox(height: 13),
                                      Row(
                                        children: [
                                          if (property!.properyType
                                                  .toString()
                                                  .toLowerCase() ==
                                              "rent") ...[
                                            Text(rentPrice)
                                                .color(
                                                    context.color.tertiaryColor)
                                                .size(18)
                                                .bold(weight: FontWeight.w700),
                                          ] else ...[
                                            Text(property!.price!
                                                    .priceFormate(
                                                        disabled: Constant
                                                                .isNumberWithSuffix ==
                                                            false)
                                                    .formatAmount(prefix: true))
                                                .color(
                                                    context.color.tertiaryColor)
                                                .size(18)
                                                .bold(weight: FontWeight.w700),
                                          ],
                                          if (Constant.isNumberWithSuffix) ...[
                                            if (property!.properyType
                                                    .toString()
                                                    .toLowerCase() !=
                                                "rent") ...[
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text("(${property!.price!})")
                                                  .color(context
                                                      .color.tertiaryColor)
                                                  .size(18)
                                                  .bold(
                                                      weight: FontWeight.w500),
                                            ]
                                          ]
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Wrap(
                                        direction: Axis.horizontal,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        runAlignment: WrapAlignment.start,
                                        alignment: WrapAlignment.start,
                                        children: List.generate(
                                            property?.parameters?.length ?? 0,
                                            (index) {
                                          Parameter? parameter =
                                              property?.parameters![index];
                                          bool isParameterValueEmpty =
                                              (parameter?.value == "" ||
                                                  parameter?.value == "0" ||
                                                  parameter?.value == null ||
                                                  parameter?.value == "null");

                                          ///If it has no value
                                          if (isParameterValueEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minWidth:
                                                    (context.screenWidth / 2) -
                                                        40),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 8, 8),
                                              child: SizedBox(
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 36.rw(context),
                                                        height: 36.rh(context),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: context.color
                                                                .tertiaryColor
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: SizedBox(
                                                          height:
                                                              20.rh(context),
                                                          width: 20.rw(context),
                                                          child: FittedBox(
                                                            child: UiUtils
                                                                .imageType(
                                                              parameter
                                                                      ?.image ??
                                                                  "",
                                                              fit: BoxFit.cover,
                                                              color: Constant
                                                                      .adaptThemeColorSvg
                                                                  ? context
                                                                      .color
                                                                      .tertiaryColor
                                                                  : null,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10.rw(context),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(parameter
                                                                      ?.name ??
                                                                  "")
                                                              .size(12)
                                                              .color(context
                                                                  .color
                                                                  .textColorDark
                                                                  .withOpacity(
                                                                      0.8)),
                                                          if (parameter
                                                                  ?.typeOfParameter ==
                                                              "file") ...{
                                                            InkWell(
                                                              onTap: () async {
                                                                await urllauncher.launchUrl(
                                                                    Uri.parse(
                                                                        parameter!
                                                                            .value),
                                                                    mode: LaunchMode
                                                                        .externalApplication);
                                                              },
                                                              child: Text(
                                                                UiUtils.translate(
                                                                    context,
                                                                    "viewFile"),
                                                              )
                                                                  .underline()
                                                                  .color(context
                                                                      .color
                                                                      .tertiaryColor),
                                                            ),
                                                          } else if (parameter
                                                                  ?.value
                                                              is List) ...{
                                                            Container(
                                                              color: Colors.red,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              child: Text((parameter
                                                                          ?.value
                                                                      as List)
                                                                  .join(",")),
                                                            )
                                                          } else ...[
                                                            if (parameter
                                                                    ?.typeOfParameter ==
                                                                "textarea") ...[
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.7,
                                                                child: Text(
                                                                        "${parameter?.value}")
                                                                    .size(14)
                                                                    .bold(
                                                                      weight: FontWeight
                                                                          .w600,
                                                                    ),
                                                              )
                                                            ] else ...[
                                                              ConstrainedBox(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.7,
                                                                ),
                                                                child: Text(
                                                                        "${parameter?.value}")
                                                                    .size(14)
                                                                    .bold(
                                                                      weight: FontWeight
                                                                          .w600,
                                                                    ),
                                                              )
                                                            ]
                                                          ]
                                                        ],
                                                      )
                                                    ]),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      UiUtils.getDivider(),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      Text(UiUtils.translate(
                                              context, "aboutThisPropLbl"))
                                          .color(context.color.textColorDark)
                                          .size(16)
                                          .bold(weight: FontWeight.w600),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      ReadMoreText(
                                          text: property?.description ?? "",
                                          style: TextStyle(
                                              color: context.color.textColorDark
                                                  .withOpacity(0.7)),
                                          readMoreButtonStyle: TextStyle(
                                              color:
                                                  context.color.tertiaryColor)),
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      //TODO:
                                      if (_bannerAd != null &&
                                          Constant.isAdmobAdsEnabled)
                                        SizedBox(
                                            width: _bannerAd?.size.width
                                                .toDouble(),
                                            height: _bannerAd?.size.height
                                                .toDouble(),
                                            child: AdWidget(ad: _bannerAd!)),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (widget
                                              .property
                                              ?.assignedOutdoorFacility
                                              ?.isNotEmpty ??
                                          false) ...[
                                        Text(UiUtils.translate(
                                                context, "outdoorFacilities"))
                                            .color(context.color.textColorDark)
                                            .size(16)
                                            .bold(weight: FontWeight.w600),
                                        const SizedBox(height: 10),
                                      ],
                                      OutdoorFacilityListWidget(
                                          outdoorFacilityList: widget.property
                                                  ?.assignedOutdoorFacility ??
                                              []),

                                      Text(UiUtils.translate(
                                              context, "listedBy"))
                                          .color(context.color.textColorDark)
                                          .size(16)
                                          .bold(weight: FontWeight.w600),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: AgentProfileWidget(
                                          hideDetails:
                                              shouldRestrictPropertyAccess(),
                                          widget: widget,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (gallary?.isNotEmpty ?? false) ...[
                                        Text(UiUtils.translate(
                                                context, "gallery"))
                                            .color(context.color.textColorDark)
                                            .size(16)
                                            .bold(weight: FontWeight.w600),
                                        SizedBox(
                                          height: 10.rh(context),
                                        ),
                                      ],
                                      if (gallary?.isNotEmpty ?? false) ...[
                                        Row(
                                            children: List.generate(
                                          (gallary?.length.clamp(0, 4)) ?? 0,
                                          (index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (gallary?[index]
                                                                .isVideo ==
                                                            true) return;

                                                        //google map doesn't allow blur so we hide it:)
                                                        showGoogleMap = false;
                                                        setState(() {});

                                                        var images = gallary
                                                            ?.map((e) =>
                                                                e.imageUrl)
                                                            .toList();

                                                        UiUtils
                                                            .imageGallaryView(
                                                          context,
                                                          images: images!,
                                                          initalIndex: index,
                                                          then: () {
                                                            showGoogleMap =
                                                                true;
                                                            setState(() {});
                                                          },
                                                        );
                                                      },
                                                      child: SizedBox(
                                                        width: 76.rw(context),
                                                        height: 76.rh(context),
                                                        child: gallary?[index]
                                                                    .isVideo ==
                                                                true
                                                            ? Container(
                                                                child: UiUtils.getImage(
                                                                    youtubeVideoThumbnail,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              )
                                                            : UiUtils.getImage(
                                                                gallary?[index]
                                                                        .imageUrl ??
                                                                    "",
                                                                fit: BoxFit
                                                                    .cover),
                                                      ),
                                                    ),
                                                    if (gallary?[index]
                                                            .isVideo ==
                                                        true)
                                                      Positioned.fill(
                                                          child:
                                                              GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                            builder: (context) {
                                                              return VideoViewScreen(
                                                                videoUrl: gallary?[
                                                                            index]
                                                                        .image ??
                                                                    "",
                                                                flickManager:
                                                                    flickManager,
                                                              );
                                                            },
                                                          ));
                                                        },
                                                        child: Container(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          child: FittedBox(
                                                            fit: BoxFit.none,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: context
                                                                      .color
                                                                      .tertiaryColor
                                                                      .withOpacity(
                                                                          0.8)),
                                                              width: 30,
                                                              height: 30,
                                                              child: const Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                    if (index == 3)
                                                      Positioned.fill(
                                                          child:
                                                              GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              BlurredRouter(
                                                            builder: (context) {
                                                              return AllGallaryImages(
                                                                  youtubeThumbnail:
                                                                      youtubeVideoThumbnail,
                                                                  images: property
                                                                          ?.gallery ??
                                                                      []);
                                                            },
                                                          ));
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          child: Text(
                                                                  "+${(property?.gallery?.length ?? 0) - 3}")
                                                              .color(
                                                                Colors.white,
                                                              )
                                                              .size(context
                                                                  .font.large)
                                                              .bold(),
                                                        ),
                                                      ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ))
                                      ],
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(UiUtils.translate(
                                              context, "locationLbl"))
                                          .color(context.color.textColorDark)
                                          .size(context.font.large)
                                          .bold(weight: FontWeight.w600),
                                      SizedBox(
                                        height: 10.rh(context),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("${UiUtils.translate(context, "addressLbl")} :")
                                              .size(context.font.normal)
                                              .color(
                                                  context.color.textColorDark),
                                          // .bold(weight: FontWeight.w600),
                                          SizedBox(
                                            height: 5.rh(context),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              UiUtils.getSvg(AppIcons.location,
                                                  color: context
                                                      .color.tertiaryColor),
                                              SizedBox(
                                                width: 5.rw(context),
                                              ),
                                              Expanded(
                                                child: HideDetailsBlur(
                                                  hide:
                                                      shouldRestrictPropertyAccess(),
                                                  child: Text(
                                                      "${property?.address!}"),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.rh(context),
                                      ),
                                      SizedBox(
                                        height: 175,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(
                                                "assets/map.png",
                                                fit: BoxFit.cover,
                                              ),
                                              BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 4.0,
                                                  sigmaY: 4.0,
                                                ),
                                                child: Center(
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      if (shouldRestrictPropertyAccess()) {
                                                        GuestChecker.check(
                                                          onNotGuest: () {
                                                            shouldShowSubscriptionOverlay
                                                                .value = true;
                                                            return;
                                                          },
                                                        );
                                                        return;
                                                      }

                                                      Navigator.push(context,
                                                          BlurredRouter(
                                                        builder: (context) {
                                                          return Scaffold(
                                                            extendBodyBehindAppBar:
                                                                true,
                                                            appBar: AppBar(
                                                              elevation: 0,
                                                              iconTheme: IconThemeData(
                                                                  color: context
                                                                      .color
                                                                      .tertiaryColor),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            ),
                                                            body: GoogleMapScreen(
                                                                latitude: double
                                                                    .parse((property
                                                                            ?.latitude ??
                                                                        "0")),
                                                                longitude: double
                                                                    .parse((property
                                                                            ?.longitude ??
                                                                        "0")),
                                                                kInitialPlace:
                                                                    _kInitialPlace,
                                                                controller:
                                                                    _controller),
                                                          );
                                                        },
                                                      ));
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    color: context
                                                        .color.tertiaryColor,
                                                    elevation: 0,
                                                    child:
                                                        shouldRestrictPropertyAccess()
                                                            ? Icon(
                                                                Icons
                                                                    .lock_open_outlined,
                                                                color: context
                                                                    .color
                                                                    .secondaryColor
                                                                    .withOpacity(
                                                                        0.8),
                                                              )
                                                            : Text(("viewMap"
                                                                    .translate(
                                                                        context)))
                                                                .color(
                                                                context.color
                                                                    .buttonColor,
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      if (!HiveUtils.isGuest()) ...[
                                        if (int.parse(
                                                HiveUtils.getUserId() ?? "0") !=
                                            property?.addedBy)
                                          Row(
                                            children: [
                                              // sendEnquiryButtonWithState(),
                                              setInterest(),
                                            ],
                                          ),
                                      ],
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      if (!reportedProperties
                                              .contains(widget.property!.id) &&
                                          widget.property!.addedBy.toString() !=
                                              HiveUtils.getUserId() &&
                                          !isReported)
                                        ReportPropertyButton(
                                          propertyId: property!.id!,
                                          onSuccess: () {
                                            setState(
                                              () {},
                                            );
                                          },
                                        )
                                    ],
                                  ),

                                //here
                                SizedBox(
                                  height: 20.rh(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: shouldShowSubscriptionOverlay,
                    builder: (context, value, child) {
                      return SizedBox(
                        height: context.screenHeight,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: value == true ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: !value,
                            child: GestureDetector(
                              onTap: () {
                                shouldShowSubscriptionOverlay.value = false;
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        getBottomNavigationBarHeight(context)),
                                child: Container(
                                  // height: context.screenHeight - .rh(context),

                                  child: ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaY: 5, sigmaX: 4),
                                      child: Container(
                                          color: Colors.black.withOpacity(0.5),
                                          width: double.infinity,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: Text(
                                                        "toAccessSubscribe"
                                                            .translate(context),
                                                        style: const TextStyle(
                                                            shadows: <Shadow>[
                                                              Shadow(
                                                                offset: Offset(
                                                                    1.0, 1.0),
                                                                blurRadius: 3.0,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              ),
                                                            ]),
                                                      )
                                                          .size(context
                                                              .font.larger)
                                                          .bold()
                                                          .centerAlign()
                                                          .color(context.color
                                                              .secondaryColor),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    MaterialButton(
                                                      height: 48,
                                                      minWidth:
                                                          context.screenWidth *
                                                              0.5,
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            Routes
                                                                .subscriptionPackageListRoute,
                                                            arguments: {
                                                              "from": Routes
                                                                  .propertyDetails
                                                            }).then((value) {
                                                          context
                                                              .read<
                                                                  GetSubsctiptionPackageLimitsCubit>()
                                                              .getLimits(
                                                                  SubscriptionLimitType
                                                                      .property);
                                                          shouldShowSubscriptionOverlay
                                                              .value = false;
                                                        });
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      color: context
                                                          .color.secondaryColor,
                                                      elevation: 0,
                                                      child: const Text(
                                                              "Subscribe")
                                                          .color(context.color
                                                              .tertiaryColor),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    // bottomNavBar()
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                      return const SizedBox.shrink();
                    })
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget advertismentLable() {
    // if (property?.promoted == false || property?.promoted == null) {
    //   return const SizedBox.shrink();
    // }

    return PositionedDirectional(
        start: 20,
        top: 20,
        child: SizedBox(
          height: 32,
          child: Row(
            children: [
              if ((property?.promoted == true &&
                  property?.promoted != null)) ...[
                Container(
                  width: 83,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: context.color.tertiaryColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(UiUtils.translate(context, 'featured'))
                      .color(context.color.buttonColor)
                      .size(context.font.small),
                ),
                const SizedBox(
                  width: 4,
                )
              ],
              if (property != null &&
                  property?.allPropData['is_premium'] == true) ...[
                Container(
                  height: 32,
                  width: 32,
                  // margin: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                      color: context.color.tertiaryColor,
                      borderRadius: BorderRadius.circular(6)),
                  child: FittedBox(
                      fit: BoxFit.none,
                      child: SvgPicture.asset(AppIcons.promoted)),
                ),
              ]
            ],
          ),
        ));
  }

  double getBottomNavigationBarHeight(BuildContext context) {
    try {
      final RenderBox? renderBox =
          appBarKey.currentContext?.findRenderObject() as RenderBox?;
      return renderBox?.size.height ?? 0.0;
    } catch (e) {
      return 0;
    }
  }

  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (!HiveUtils.isGuest()) {
      if (int.parse(HiveUtils.getUserId() ?? "0") == property?.addedBy) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 65.rh(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
              child:
                  BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
                builder: (context, state) {
                  PropertyModel? model;

                  if (state is FetchMyPropertiesSuccess) {
                    model = state.myProperty
                        .where((element) => element.id == property?.id)
                        .first;
                  }

                  model ??= widget.property;

                  var isPromoted = (model?.promoted);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!HiveUtils.isGuest()) ...[
                        if (isPromoted == false &&
                            (property?.status.toString() != "0")) ...[
                          Expanded(
                              child: UiUtils.buildButton(
                            context,
                            disabled: (property?.status.toString() == "0"),
                            // padding: const EdgeInsets.symmetric(horizontal: 1),
                            outerPadding: const EdgeInsets.all(
                              1,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.createAdvertismentScreenRoute,
                                arguments: {
                                  "model": property,
                                },
                              ).then(
                                (value) {
                                  setState(() {});
                                },
                              );
                            },
                            prefixWidget: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: SvgPicture.asset(
                                AppIcons.promoted,
                                width: 14,
                                height: 14,
                              ),
                            ),

                            fontSize: context.font.normal,
                            width: context.screenWidth / 3,
                            buttonTitle: UiUtils.translate(context, "feature"),
                          )),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ],
                      Expanded(
                        child: UiUtils.buildButton(context,
                            // padding: const EdgeInsets.symmetric(horizontal: 1),
                            outerPadding: const EdgeInsets.all(1),
                            onPressed: () async {
                          Category category = await context
                              .read<FetchCategoryCubit>()
                              .get(property!.category!.id!);

// Extract parameter IDs from category
                          List<dynamic>? parameterIds = category.parameterTypes;

// Map parameters
                          List<dynamic>? mappedParameters =
                              parameterIds?.map((dynamic id) {
                            // Find index of parameter in property parameters list
                            int index = property?.parameters?.indexWhere(
                                    (element) => element.id == id['id']) ??
                                -1;

                            // If parameter found, return it; otherwise, return the original value
                            return index != -1
                                ? property!.parameters![index]
                                : id;
                          }).toList();
                          Constant.addProperty.addAll({
                            "category": Category(
                              category: property?.category!.category,
                              id: property?.category?.id!.toString(),
                              image: property?.category?.image,
                              parameterTypes: mappedParameters,
                            )
                          });

                          Navigator.pushNamed(
                              context, Routes.addPropertyDetailsScreen,
                              arguments: {
                                "details": {
                                  "id": property?.id,
                                  "catId": property?.category?.id,
                                  "propType": property?.properyType,
                                  "name": property?.title,
                                  "desc": property?.description,
                                  "city": property?.city,
                                  "state": property?.state,
                                  "country": property?.country,
                                  "latitude": property?.latitude,
                                  "longitude": property?.longitude,
                                  "address": property?.address,
                                  "client": property?.clientAddress,
                                  "price": property?.price,
                                  'parms': property?.parameters,
                                  "allPropData": property?.allPropData,
                                  "images": property?.gallery
                                      ?.map((e) => e.imageUrl)
                                      .toList(),
                                  "gallary_with_id": property?.gallery,
                                  "rentduration": property?.rentduration,
                                  "assign_facilities":
                                      property?.assignedOutdoorFacility,
                                  "titleImage": property?.titleImage
                                }
                              });
                        },
                            fontSize: context.font.normal,
                            width: context.screenWidth / 3,
                            prefixWidget: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: SvgPicture.asset(AppIcons.edit),
                            ),
                            buttonTitle: UiUtils.translate(context, "edit")),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: UiUtils.buildButton(context,
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            outerPadding: const EdgeInsets.all(1),
                            prefixWidget: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: SvgPicture.asset(
                                AppIcons.delete,
                                color: context.color.buttonColor,
                                width: 14,
                                height: 14,
                              ),
                            ), onPressed: () async {
                          // //THIS IS FOR DEMO MODE
                          bool isPropertyActive =
                              property?.status.toString() == "1";

                          bool isDemoNumber = HiveUtils.getUserDetails()
                                  .mobile ==
                              "${Constant.demoCountryCode}${Constant.demoMobileNumber}";

                          if (Constant.isDemoModeOn &&
                              isPropertyActive &&
                              isDemoNumber) {
                            HelperUtils.showSnackBarMessage(context,
                                "Active property cannot be deleted in demo app.");

                            return;
                          }

                          var delete = await UiUtils.showBlurredDialoge(
                            context,
                            dialoge: BlurredDialogBox(
                              title: UiUtils.translate(
                                context,
                                "deleteBtnLbl",
                              ),
                              content: Text(
                                UiUtils.translate(
                                    context, "deletepropertywarning"),
                              ),
                            ),
                          );
                          if (delete == true) {
                            Future.delayed(
                              Duration.zero,
                              () {
                                // if (Constant.isDemoModeOn) {
                                //   HelperUtils.showSnackBarMessage(
                                //       context,
                                //       UiUtils.getTranslatedLabel(
                                //           context, "thisActionNotValidDemo"));
                                // } else {
                                context
                                    .read<DeletePropertyCubit>()
                                    .delete(property!.id!);
                                // }
                              },
                            );
                          }
                        },
                            fontSize: context.font.normal,
                            width: context.screenWidth / 3.2,
                            buttonTitle:
                                UiUtils.translate(context, "deleteBtnLbl")),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 65.rh(context),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(child: callButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: messageButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: chatButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String statusText(String text) {
    if (text == "1") {
      return UiUtils.translate(context, "active");
    } else if (text == "0") {
      return UiUtils.translate(context, "deactive");
    }
    return "";
  }

  Widget setInterest() {
    // check if list has this id or not
    bool interestedProperty =
        Constant.interestedPropertyIds.contains(widget.property?.id);

    /// default icon
    dynamic icon = AppIcons.interested;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.property?.isInterested == 1) {
      /// If list has id or our property is interested so we are gonna show icon of No Interest
      icon = Icons.not_interested_outlined;
    }

    return BlocConsumer<ChangeInterestInPropertyCubit,
        ChangeInterestInPropertyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChangeInterestInPropertySuccess) {
          if (state.interest == PropertyInterest.interested) {
            //If interested show no interested icon
            icon = Icons.not_interested_outlined;
          } else {
            icon = AppIcons.interested;
          }
        }

        return Expanded(
          flex: 1,
          child: UiUtils.buildButton(
            context,
            height: 48,
            outerPadding: const EdgeInsets.all(1),
            isInProgress: state is ChangeInterestInPropertyInProgress,
            onPressed: () {
              PropertyInterest interest;

              bool contains =
                  Constant.interestedPropertyIds.contains(widget.property!.id!);

              if (contains == true || widget.property!.isInterested == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                  propertyId: widget.property!.id!.toString(),
                  interest: interest);
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.translate(context, "interested")
                : UiUtils.translate(context, "interest")),
            fontSize: context.font.large,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: (icon is String)
                  ? SvgPicture.asset(
                      icon,
                      width: 22,
                      height: 22,
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).colorScheme.buttonColor,
                      size: 22,
                    ),
            ),
          ),
        );
      },
    );
  }

  bool isDisabledEnquireButton(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool showIcon(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  String setLable(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return UiUtils.translate(
          context,
          "sent",
        );
      } else {
        return UiUtils.translate(
          context,
          "sendEnqBtnLbl",
        );
      }
    }
    return "";
  }

  Widget callButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.translate(context, "call"),
        width: 35,
        onPressed: _onTapCall,
        prefixWidget: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: SizedBox(
              width: 16,
              height: 16,
              child: UiUtils.getSvg(AppIcons.call, color: Colors.white)),
        ));
  }

  Widget messageButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.translate(context, "sms"),
        width: 35,
        onPressed: _onTapMessage,
        prefixWidget: SizedBox(
          width: 16,
          height: 16,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: UiUtils.getSvg(AppIcons.message,
                color: context.color.buttonColor),
          ),
        ));
  }

  Widget chatButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.translate(context, "chat"),
        width: 35,
        onPressed: _onTapChat,
        prefixWidget: SizedBox(
          width: 16,
          height: 16,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child:
                UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
          ),
        ));
  }

  _onTapCall() async {
    if (isPremiumProperty && !isPremiumUser) {
      GuestChecker.check(onNotGuest: () {
        shouldShowSubscriptionOverlay.value = true;

        return;
      });
      return;
    }

    var contactNumber = widget.property?.customerNumber;

    var url = Uri.parse("tel: +$contactNumber"); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onTapMessage() async {
    if (isPremiumProperty && !isPremiumUser) {
      GuestChecker.check(
        onNotGuest: () {
          shouldShowSubscriptionOverlay.value = true;

          return;
        },
      );
      return;
    }

    var contactNumber = widget.property?.customerNumber;

    Uri url = Uri.parse("sms: +$contactNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onTapChat() {
    CheckInternet.check(
      onInternet: () {
        GuestChecker.check(onNotGuest: () {
          if (isPremiumProperty && !isPremiumUser) {
            shouldShowSubscriptionOverlay.value = true;
            return;
          }
          Navigator.push(context, BlurredRouter(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => SendMessageCubit(),
                  ),
                  BlocProvider(
                    create: (context) => LoadChatMessagesCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMessageCubit(),
                  ),
                ],
                child: ChatScreen(
                  profilePicture: property?.customerProfile ?? "",
                  userName: property?.customerName ?? "",
                  propertyImage: property?.titleImage ?? "",
                  proeprtyTitle: property?.title ?? "",
                  userId: (property?.addedBy).toString(),
                  from: "property",
                  propertyId: (property?.id).toString(),
                ),
              );
            },
          ));
        });
      },
      onNoInternet: () {
        HelperUtils.showSnackBarMessage(
            context, "noInternet".translate(context));
      },
    );
  }
}

class InterestedUserListWidget extends StatefulWidget {
  const InterestedUserListWidget({
    super.key,
    required this.totalCount,
    required this.interestedUserCubitReference,
  });
  final String totalCount;
  final GetInterestedUserCubit interestedUserCubitReference;

  @override
  State<InterestedUserListWidget> createState() =>
      _InterestedUserListWidgetState();
}

class _InterestedUserListWidgetState extends State<InterestedUserListWidget> {
  final ScrollController _bottomSheetScrollController = ScrollController();
  @override
  void initState() {
    _bottomSheetScrollController.addListener(() {
      if (_bottomSheetScrollController.isEndReached()) {
        if (widget.interestedUserCubitReference.hasMoreData()) {
          widget.interestedUserCubitReference.fetchMore();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 10,
        ),
        child: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: SingleChildScrollView(
            controller: _bottomSheetScrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: const Text("Interested Users")
                      .size(context.font.larger)
                      .bold(),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // SizedBox(
                //   child: Container(
                //     width: context.screenWidth,
                //     child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: [
                //           Text("Interested User Count")
                //               .size(context.font.large)
                //               .bold(),
                //           Text("${widget.totalCount}")
                //         ]),
                //     // color: Colors.red,
                //   ),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                BlocBuilder<GetInterestedUserCubit, GetInterestedUserState>(
                  bloc: widget.interestedUserCubitReference,
                  builder: (context, state) {
                    if (state is GetInterestedUserInProgress) {
                      return Center(child: UiUtils.progress());
                    }

                    if (state is GetInterestedUserSuccess) {
                      if (state.list.isEmpty) {
                        return const Center(
                          child: Text("No data found"),
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          InterestedUserModel interestedUser =
                              state.list[index];

                          return InterestedUserCard(
                              interestedUser: interestedUser);
                        },
                        itemCount: state.list.length,
                        shrinkWrap: true,
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InterestedUserCard extends StatelessWidget {
  const InterestedUserCard({
    super.key,
    required this.interestedUser,
  });

  final InterestedUserModel interestedUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        child: Row(
          children: [
            // CircleAvatar(radius: 25, backgroundImage: SvgPro),
            Container(
              width: 50,
              height: 50,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.red,
              ),
              child: UiUtils.getImage(interestedUser.image ?? ""),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 3,
              child: Text(interestedUser.name ?? "").setMaxLines(lines: 1),
            ),
            const SizedBox(
              width: 10,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse("mailto:${interestedUser.email}"),
                          mode: LaunchMode.externalApplication);
                    },
                    icon: Icon(
                      Icons.email,
                      color: context.color.tertiaryColor,
                    )),
                IconButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse("tel:${interestedUser.mobile}"),
                          mode: LaunchMode.externalApplication);
                    },
                    color: context.color.tertiaryColor,
                    icon: const Icon(Icons.call)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GoogleMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  const GoogleMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required CameraPosition kInitialPlace,
    required Completer<GoogleMapController> controller,
  })  : _kInitialPlace = kInitialPlace,
        _controller = controller;

  final CameraPosition _kInitialPlace;
  final Completer<GoogleMapController> _controller;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isGoogleMapVisible = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      isGoogleMapVisible = true;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        isGoogleMapVisible = false;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
        Future.delayed(
          Duration.zero,
          () {
            Navigator.pop(context);
          },
        );
        return false;
      },
      child: Builder(builder: (context) {
        if (!isGoogleMapVisible) {
          return Center(child: UiUtils.progress());
        }
        return GoogleMap(
          myLocationButtonEnabled: false,
          gestureRecognizers: <f.Factory<OneSequenceGestureRecognizer>>{
            f.Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          markers: {
            Marker(
                markerId: const MarkerId("1"),
                position: LatLng(widget.latitude, widget.longitude))
          },
          mapType: AppSettings.googleMapType,
          initialCameraPosition: widget._kInitialPlace,
          onMapCreated: (GoogleMapController controller) {
            if (!widget._controller.isCompleted) {
              widget._controller.complete(controller);
            }
          },
        );
      }),
    );
  }
}

class AgentProfileWidget extends StatelessWidget {
  final bool hideDetails;
  const AgentProfileWidget({
    super.key,
    required this.hideDetails,
    required this.widget,
  });

  final PropertyDetails widget;

  @override
  Widget build(BuildContext context) {
    return HideDetailsBlur(
      hide: hideDetails,
      sigmaX: 4,
      sigmaY: 4,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (hideDetails) return;

              UiUtils.showFullScreenImage(context,
                  provider:
                      NetworkImage(widget.property?.customerProfile ?? ""));
            },
            child: Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10)),
                child: UiUtils.getImage(widget.property?.customerProfile ?? "",
                    fit: BoxFit.cover)

                //  CachedNetworkImage(
                //   imageUrl: widget.propertyData?.customerProfile ?? "",
                //   fit: BoxFit.cover,
                // ),

                ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.property?.customerName ?? "")
                    .size(context.font.large)
                    .bold(),
                Text(widget.property?.customerEmail ?? ""),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OutdoorFacilityListWidget extends StatelessWidget {
  final List<AssignedOutdoorFacility> outdoorFacilityList;
  const OutdoorFacilityListWidget({Key? key, required this.outdoorFacilityList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CrossAxisAlignment getCrossAxisAlignment(int columnIndex) {
      if (columnIndex == 1) {
        return CrossAxisAlignment.center;
      } else if (columnIndex == 2) {
        return CrossAxisAlignment.end;
      } else {
        return CrossAxisAlignment.start;
      }
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: outdoorFacilityList.length,
      itemBuilder: (context, index) {
        AssignedOutdoorFacility facility = outdoorFacilityList[index];

        return Column(
          //crossAxisAlignment: getCrossAxisAlignment(columnIndex),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // width: 60,
                  // height: 60,
                  decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(15),
                      color: context.color.tertiaryColor.withOpacity(0.2)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: UiUtils.imageType(
                        facility.image ?? "",
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null,
                        // fit: BoxFit.cover,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(facility.name ?? "")
                    .centerAlign()
                    .size(context.font.normal)
                    .color(context.color.textColorDark)
                    .setMaxLines(lines: 2),
                const SizedBox(height: 2),
                Text("${facility.distance} KM")
                    .centerAlign()
                    .size(context.font.small)
                    .color(context.color.textLightColor)
                    .setMaxLines(lines: 1)
              ],
            ),
          ],
        );
      },
    );
  }
}

class HideDetailsBlur extends StatelessWidget {
  final Widget child;
  final bool hide;
  final double? sigmaX;
  final double? sigmaY;
  const HideDetailsBlur(
      {super.key,
      required this.child,
      required this.hide,
      this.sigmaX,
      this.sigmaY});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Stack(
      // fit: StackFit.expand,
      children: [
        child,
        if (hide)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaY: sigmaY ?? 3, sigmaX: sigmaX ?? 4),
            child: Container(),
          )
      ],
    ));
  }
}
