import 'dart:convert';

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../../../data/helper/custom_exception.dart';
import '../../../data/helper/design_configs.dart';
import '../../../data/model/notification_data.dart';

late NotificationData selectedNotification;

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  NotificationsState createState() => NotificationsState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const Notifications(),
    );
  }
}

class NotificationsState extends State<Notifications> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchNotificationsCubit>().hasMoreData()) {
          context.read<FetchNotificationsCubit>().fetchNotificationsMore();
        }
      }
    });
  List<PropertyModel> propertyData = [];
  @override
  void initState() {
    super.initState();
    context.read<FetchNotificationsCubit>().fetchNotifications();
  }

  @override
  void dispose() {
    Routes.currentRoute = Routes.previousCustomerRoute;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, "notifications"),
        showBackButton: true,
      ),
      body: BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
          builder: (context, state) {
        if (state is FetchNotificationsInProgress) {
          return buildNotificationShimmer();
        }
        if (state is FetchNotificationsFailure) {
          if (state.errorMessage is NoInternetConnectionError) {
            return NoInternet(
              onRetry: () {
                context.read<FetchNotificationsCubit>().fetchNotifications();
              },
            );
          }
          return const SomethingWentWrong();
        }

        if (state is FetchNotificationsSuccess) {
          if (state.notificationdata.isEmpty) {
            return NoDataFound(
              onTap: () {
                context.read<FetchNotificationsCubit>().fetchNotifications();
              },
            );
          }

          return buildNotificationlistWidget(state);
        }

        return const SizedBox.square();
      }),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
        padding: const EdgeInsets.all(10),
        separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
        itemCount: 20,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 55,
            child: Row(
              children: <Widget>[
                const CustomShimmer(
                  width: 50,
                  height: 50,
                  borderRadius: 11,
                ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomShimmer(
                      height: 7,
                      width: 200.rw(context),
                    ),
                    const SizedBox(height: 5),
                    CustomShimmer(
                      height: 7,
                      width: 100.rw(context),
                    ),
                    const SizedBox(height: 5),
                    CustomShimmer(
                      height: 7,
                      width: 150.rw(context),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  buildNotificationlistWidget(FetchNotificationsSuccess state) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 2,
                  ),
              itemCount: state.notificationdata.length,
              itemBuilder: (context, index) {
                NotificationData notificationData =
                    state.notificationdata[index];
                return GestureDetector(
                  onTap: () {
                    selectedNotification = notificationData;
                    if (notificationData.type == Constant.enquiryNotification) {
                    } else {
                      HelperUtils.goToNextPage(
                          Routes.notificationDetailPage, context, false);
                    }
                  },
                  child: Container(
                    decoration: DesignConfig.boxDecorationBorder(
                        color: Theme.of(context).colorScheme.secondaryColor,
                        borderWidth: 1.5,
                        borderColor: context.color.borderColor,
                        radius: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(children: <Widget>[
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: UiUtils.getImage(notificationData.image!,
                            height: 53.rh(context),
                            width: 53.rw(context),
                            fit: BoxFit.fill),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            Text(
                              notificationData.title!.firstUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .merge(const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ),
                            Text(
                              notificationData.message!.firstUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!,
                            ),
                            Text(notificationData.createdAt!
                                    .formatDate()
                                    .toString())
                                .size(context.font.smaller)
                                .color(context.color.textLightColor)
                          ])),
                    ]),
                  ),
                );
              }),
        ),
        if (state.isLoadingMore) UiUtils.progress()
      ],
    );
  }

  Future<List<PropertyModel>> getPropertyById() async {
    Map<String, dynamic> body = {
      // ApiParams.id: propertysId,//String propertysId
    };

    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty, body, true, context,
        passUserid: true);
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        List list = getdata['data'];
        propertyData =
            list.map((model) => PropertyModel.fromMap(model)).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException(UiUtils.translate(context, "nodatafound"));
        },
      );
    }
    return propertyData;
  }
}
