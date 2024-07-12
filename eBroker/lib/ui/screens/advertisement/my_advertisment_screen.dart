import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/bannerAdLoadWidget.dart';
import 'package:flutter/material.dart';

import '../../../data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import '../../../data/repositories/advertisement_repository.dart';

class MyAdvertismentScreen extends StatefulWidget {
  const MyAdvertismentScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => FetchMyPromotedPropertysCubit(),
          child: const MyAdvertismentScreen(),
        );
      },
    );
  }

  @override
  State<MyAdvertismentScreen> createState() => _MyAdvertismentScreenState();
}

class _MyAdvertismentScreenState extends State<MyAdvertismentScreen> {
  final ScrollController _pageScrollController = ScrollController();
  Map<int, String>? statusMap;
  @override
  void initState() {
    context.read<FetchMyPromotedPropertysCubit>().fetchMyPromotedPropertys();

    Future.delayed(
      Duration.zero,
      () {
        statusMap = {
          0: UiUtils.translate(context, "approved"),
          1: UiUtils.translate(context, "pending"),
          2: UiUtils.translate(context, "rejected")
        };
      },
    );

    _pageScrollController.addListener(_pageScroll);
    super.initState();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedPropertysCubit>().hasMoreData()) {
        context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertysMore();
      }
    }
  }

  @override
  void didChangeDependencies() {
    statusMap = {
      0: UiUtils.translate(context, "approved"),
      1: UiUtils.translate(context, "pending"),
      2: UiUtils.translate(context, "rejected")
    };
    super.didChangeDependencies();
  }

  Color? statusColor(status) {
    if (status == 0) {
      return Colors.green;
    } else if (status == 1) {
      return Colors.purple;
    } else if (status == 2) {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: UiUtils.translate(context, "myAds")),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: BlocBuilder<FetchMyPromotedPropertysCubit,
          FetchMyPromotedPropertysState>(
        builder: (context, state) {
          if (state is FetchMyPromotedPropertysInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyPromotedPropertysFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchMyPromotedPropertysCubit>()
                      .fetchMyPromotedPropertys();
                },
              );
            }

            return const SomethingWentWrong();
          }
          if (state is FetchMyPromotedPropertysSuccess) {
            if (state.propertymodel.isEmpty) {
              return NoDataFound(
                title: "noFeaturedAdsYes".translate(context),
                description: "noFeaturedDescription".translate(context),
                onTap: () {
                  context
                      .read<FetchMyPromotedPropertysCubit>()
                      .fetchMyPromotedPropertys();
                  setState(() {});
                },
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _pageScrollController,
                    itemCount: state.propertymodel.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      PropertyModel property = state.propertymodel[index];

                      property =
                          context.watch<PropertyEditCubit>().get(property);
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.propertyDetails,
                            arguments: {
                              'propertyData': property,
                              'fromMyProperty': true
                            },
                          );
                        },
                        child: BlocProvider(
                          create: (context) => DeleteAdvertismentCubit(
                              AdvertisementRepository()),
                          child: PropertyHorizontalCard(
                            property: property,
                            useRow: true,
                            onLikeChange: (type) {
                              if (type == FavoriteType.add) {
                                context
                                    .read<FetchFavoritesCubit>()
                                    .add(state.propertymodel[index]);
                              } else {
                                context
                                    .read<FetchFavoritesCubit>()
                                    .remove(state.propertymodel[index].id);
                              }
                            },
                            additionalHeight: 50,
                            addBottom: [
                              SizedBox(
                                width: 10.rw(context),
                              ),
                              Row(children: [
                                Text(UiUtils.translate(context, "status")),
                                SizedBox(
                                  width: 5.rw(context),
                                ),
                                SizedBox(
                                  child: Chip(
                                    label: Text(
                                      statusMap![property.advertisment[0]
                                              ['status']]
                                          .toString()
                                          .firstUpperCase(),
                                    )
                                        .size(context.font.small)
                                        .color(context.color.buttonColor),
                                    backgroundColor: statusColor(
                                      property.advertisment[0]['status'],
                                    ),
                                    visualDensity:
                                        const VisualDensity(horizontal: 1),
                                    padding: EdgeInsets.zero,
                                  ),
                                )
                              ]),
                              SizedBox(
                                width: 10.rw(context),
                              ),
                              Row(
                                children: [
                                  Text(UiUtils.translate(context, "type")),
                                  SizedBox(
                                    width: 5.rw(context),
                                  ),
                                  Chip(
                                      label: Text(property.advertisment[0]
                                              ['type']
                                          .toString()))
                                ],
                              ),
                              const Spacer(),
                              BlocConsumer<DeleteAdvertismentCubit,
                                  DeleteAdvertismentState>(
                                listener: (context, state) {
                                  if (state is DeleteAdvertismentSuccess) {
                                    context
                                        .read<FetchMyPromotedPropertysCubit>()
                                        .delete(property.id);
                                  }
                                },
                                builder: (BuildContext context,
                                    DeleteAdvertismentState state) {
                                  ///it will only show delete button when status is pending it means 1.

                                  if (property.advertisment[0]['status'] != 1) {
                                    return Container();
                                  }

                                  return IconButton(
                                      onPressed: () {
                                        UiUtils.showBlurredDialoge(context,
                                            dialoge: BlurredDialogBox(
                                                title: UiUtils.translate(
                                                    context, "deleteBtnLbl"),
                                                onAccept: () async {
                                                  if (Constant.isDemoModeOn) {
                                                    HelperUtils.showSnackBarMessage(
                                                        context,
                                                        UiUtils.translate(
                                                            context,
                                                            "thisActionNotValidDemo"));
                                                  } else {
                                                    context
                                                        .read<
                                                            DeleteAdvertismentCubit>()
                                                        .delete(property
                                                                .advertisment[0]
                                                            ["id"]);
                                                  }
                                                },
                                                content: Text(UiUtils.translate(
                                                    context,
                                                    "confirmDeleteAdvert"))));
                                      },
                                      icon: (state
                                              is DeleteAdvertismentInProgress)
                                          ? UiUtils.progress()
                                          : Icon(
                                              Icons.delete,
                                              color:
                                                  context.color.textColorDark,
                                            ));
                                },
                              ),
                              SizedBox(
                                width: 10.rw(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
