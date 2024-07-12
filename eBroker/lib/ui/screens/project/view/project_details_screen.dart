import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/project/delete_project_cubit.dart';
import 'package:ebroker/data/cubits/project/fetchMyProjectsListCubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/cloud_state/cloud_state.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:ebroker/utils/video_player/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/model/project_model.dart';
import '../../../../ui/screens/widgets/blurred_dialoge_box.dart';
import '../../../../utils/typedefs.dart';
import '../../proprties/property_details.dart';
import '../../widgets/gallery_view.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  static route(RouteSettings settings) {
    Map? arguement = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => DeleteProjectCubit(),
          child: ProjectDetailsScreen(
            project: arguement?['project'],
          ),
        );
      },
    );
  }

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  CloudState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends CloudState<ProjectDetailsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool isMyProject = false;
  late ProjectModel project;

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(project.latitude!),
      double.parse(project.longitude!),
    ),
    zoom: 14.4746,
  );

  @override
  void initState() {
    project = widget.project;
    isMyProject = checkIsProjectMine();

    super.initState();
  }

  bool checkIsProjectMine() {
    return project.addedBy.toString() == HiveUtils.getUserId();
  }

  bool hasFloors() {
    return project.plans!.isNotEmpty;
  }

  bool hasDocuments() {
    return project.documents!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      bottomNavigationBar: BottomAppBar(
        color: context.color.secondaryColor,
        child: bottomNavigation(context),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: EdgeInsets.zero,
          child: BlocListener<DeleteProjectCubit, DeleteProjectState>(
            listener: (context, state) {
              if (state is DeleteProjectInProgress) {
                Widgets.showLoader(context);
              }

              if (state is DeleteProjectSuccess) {
                Widgets.hideLoder(context);
                context.read<FetchMyProjectsListCubit>().delete(state.id);

                Navigator.pop(
                  context,
                );
              }
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                    backgroundColor: context.color.secondaryColor,
                    leading: Material(
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
                    systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent),
                    expandedHeight: context.screenHeight * 0.45,
                    // toolbarHeight: 0,
                    primary: true,
                    automaticallyImplyLeading: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // forceMaterialTransparency: true,
                    floating: false,
                    pinned: true,

                    // title: Text("I am title"),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: EdgeInsets.zero,
                      background: ProjectImageCareusel(
                        images: [
                          ...{project.image!},
                          ...project.gallaryImages!.map((e) => e.name!)
                        ],
                      ),
                    )),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            categoryCard(context, project),
                            const Spacer(),
                            Text(project.type!.translate(context))
                                .bold()
                                .size(context.font.small),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(project.title!)
                            .size(context.font.larger)
                            .bold(weight: FontWeight.w400),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(project.description!.trim()).color(
                            context.color.textColorDark.withOpacity(0.89)),
                        const SizedBox(
                          height: 18,
                        ),

                        ContactDetailsWidget(
                            url: project.customer?.profile ?? "",
                            number: project.customer!.mobile!,
                            name: project.customer!.name!,
                            email: project.customer!.email!),
                        const SizedBox(
                          height: 14,
                        ),
                        if (project.videoLink != null &&
                            project.videoLink!.isNotEmpty)
                          VideoPlayerWideget(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            url: project.videoLink!,
                          ),
                        if (hasDocuments()) ...[
                          Text("Documents".translate(context))
                              .size(context.font.large)
                              .bold(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Document? document = project.documents?[index];

                              return DownloadableDocument(
                                url: document!.name!,
                              );
                              // return ListTile(
                              //   dense: true,
                              //   title: Text(name).size(context.font.large).color(
                              //       context.color.textColorDark.withOpacity(0.9)),
                              //   trailing: IconButton(
                              //     icon: const Icon(Icons.download),
                              //     onPressed: () {},
                              //   ),
                              // );
                            },
                            itemCount: project.documents?.length ?? 0,
                          ),
                        ],
                        const SizedBox(
                          height: 15,
                        ),
                        if (hasFloors()) ...[
                          Text("Floor Plans".translate(context))
                              .size(context.font.large)
                              .bold(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: project.plans?.length ?? 0,
                            itemBuilder: (context, index) {
                              Plan floor = project.plans![index];
                              return CustomExpansionTile(
                                title: floor.title!,
                                children: [Image.network(floor.document!)],
                              );
                            },
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                        ],

                        // Container(
                        //   width: context.screenWidth,
                        //   height: 210,
                        //   child: YoutubeExplode,
                        //   decoration: BoxDecoration(
                        //       color: context.color.tertiaryColor,
                        //       borderRadius: BorderRadius.circular(10)),
                        // ),

                        Text("projectLocation".translate(context))
                            .size(context.font.large)
                            .bold(),

                        const SizedBox(
                          height: 15,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("locationLbl".translate(context)).bold(),
                                  Text(project.location!)
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text("cityProj".translate(context)).bold(),
                                  Text(project.city!)
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text("stateProj".translate(context)).bold(),
                                  Text(project.state!)
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text("countryProj".translate(context)).bold(),
                                  Text(project.country!)
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          height: 175,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                                        Navigator.push(context, BlurredRouter(
                                          builder: (context) {
                                            return Scaffold(
                                              extendBodyBehindAppBar: true,
                                              appBar: AppBar(
                                                elevation: 0,
                                                iconTheme: IconThemeData(
                                                    color: context
                                                        .color.tertiaryColor),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                              body: GoogleMapScreen(
                                                latitude: double.parse(
                                                    project.latitude!),
                                                longitude: double.parse(
                                                    project.longitude!),
                                                kInitialPlace: _kInitialPlace,
                                                controller: _controller,
                                              ),
                                            );
                                          },
                                        ));
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      color: context.color.tertiaryColor,
                                      elevation: 0,
                                      child:
                                          Text(("viewMap".translate(context)))
                                              .color(
                                        context.color.buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget bottomNavigation(BuildContext context) {
    if (isMyProject) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 65.rh(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: UiUtils.buildButton(context,
                      // padding: const EdgeInsets.symmetric(horizontal: 1),
                      outerPadding: const EdgeInsets.all(1), onPressed: () {
                    if (Constant.isDemoModeOn) {
                      HelperUtils.showSnackBarMessage(
                          context, "Not valid in demo mode");

                      return;
                    }

                    Navigator.pushNamed(context, Routes.addProjectDetails,
                        arguments: {
                          "id": project.id,
                          "category_id": project.category!.id!,
                          "project": project.toMap(),
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
                    print("is demo mode ${Constant.isDemoModeOn}");
                    if (Constant.isDemoModeOn) {
                      HelperUtils.showSnackBarMessage(
                          context, "Not valid in demo mode");

                      return;
                    }

                    UiUtils.showBlurredDialoge(context,
                        dialoge: BlurredDialogBox(
                            title: "areYouSure".translate(context),
                            onAccept: () async {
                              context
                                  .read<DeleteProjectCubit>()
                                  .delete(project.id!);
                            },
                            content: Text(
                                "projectWillNotRecover".translate(context))));
                  },
                      fontSize: context.font.normal,
                      width: context.screenWidth / 3.2,
                      buttonTitle: UiUtils.translate(context, "deleteBtnLbl")),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

Widget categoryCard(BuildContext context, ProjectModel project) {
  return Container(
    decoration: BoxDecoration(
        // color: context.color.tertiaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          height: 35,
          child: SvgPicture.network(project.category!.image!),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(project.category!.category!).size(context.font.large)
      ],
    ),
  );
}

class ProjectImageCareusel extends StatefulWidget {
  final List<String> images;
  const ProjectImageCareusel({
    super.key,
    required this.images,
  });

  @override
  State<ProjectImageCareusel> createState() => _ProjectImageCareuselState();
}

class _ProjectImageCareuselState extends State<ProjectImageCareusel>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _sliderIndex = ValueNotifier(0);
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  late Timer _timer;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_sliderIndex.value < widget.images.length - 1) {
        _sliderIndex.value++;
      } else {
        _sliderIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _sliderIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sliderIndex.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        PageView.builder(
            itemCount: widget.images.length,
            controller: _pageController,
            clipBehavior: Clip.antiAlias,
            physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast,
            ),
            onPageChanged: (index) {
              _sliderIndex.value = index;
            },
            itemBuilder: (context, index) {
              List images = widget.images;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      BlurredRouter(
                        builder: (context) => GalleryViewWidget(
                          images: images,
                          initalIndex: index,
                        ),
                      ));
                },
                child: ProjectCateuseItem(
                  url: widget.images[index],
                ),
              );
            }),
        Align(
          alignment: Alignment.bottomCenter.add(const Alignment(0, -0.05)),
          child: ValueListenableBuilder(
              valueListenable: _sliderIndex,
              builder: (context, val, ch) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                        widget.images.length,
                        (index) => Container(
                              width: 7,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == val
                                    ? context.color.tertiaryColor
                                    : Colors.white,
                              ),
                            )),
                  ],
                );
              }),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ProjectCateuseItem extends StatelessWidget {
  final String url;

  const ProjectCateuseItem({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        Image.network(
          url,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final Widgetss children;
  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title)
          .size(context.font.large)
          .color(context.color.textColorDark.withOpacity(0.9)),
      dense: true,
      collapsedTextColor: context.color.textColorDark,
      textColor: context.color.textColorDark,
      iconColor: context.color.tertiaryColor,
      collapsedIconColor: context.color.tertiaryColor,
      trailing: AnimatedCrossFade(
        firstChild: const Icon(Icons.add),
        secondChild: const Icon(Icons.remove),
        duration: const Duration(milliseconds: 250),
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
      onExpansionChanged: (value) {
        isExpanded = value;
        setState(() {});
      },
      controlAffinity: ListTileControlAffinity.trailing,
      children: widget.children,
    );
  }
}

class ContactDetailsWidget extends StatelessWidget {
  final String url;
  final String name;
  final String email;
  final String number;

  const ContactDetailsWidget(
      {super.key,
      required this.url,
      required this.name,
      required this.email,
      required this.number});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("contactUS".translate(context)).size(context.font.large).bold(),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                UiUtils.showFullScreenImage(context,
                    provider: NetworkImage(url));
              },
              child: Container(
                  width: 70,
                  height: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10)),
                  child: UiUtils.getImage(url, fit: BoxFit.cover)

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
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name)
                      .size(context.font.large)
                      .bold()
                      .setMaxLines(lines: 1),
                  Text(email).setMaxLines(lines: 1),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                // color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await launchUrl(Uri.parse("tel:+$number"));
                        },
                        icon: Icon(
                          Icons.call,
                          color: context.color.tertiaryColor,
                        )),
                    IconButton(
                        onPressed: () async {
                          await launchUrl(Uri.parse("mailto:$email"));
                        },
                        icon: Icon(
                          Icons.email,
                          color: context.color.tertiaryColor,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DownloadableDocument extends StatefulWidget {
  final String url;
  const DownloadableDocument({super.key, required this.url});

  @override
  State<DownloadableDocument> createState() => _DownloadableDocumentState();
}

class _DownloadableDocumentState extends State<DownloadableDocument> {
  bool downloaded = false;
  Dio dio = Dio();
  ValueNotifier<double> percentage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  Future<String?>? path() async {
    String? downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.url.split("/").last;
    return ListTile(
      dense: true,
      title: Text(name)
          .size(context.font.large)
          .color(context.color.textColorDark.withOpacity(0.9)),
      trailing: ValueListenableBuilder(
          valueListenable: percentage,
          builder: (context, value, child) {
            if (value != 0.0 && value != 1.0) {
              return SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  value: value,
                  color: context.color.tertiaryColor,
                ),
              );
            }
            if (downloaded) {
              return IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerRight,
                  splashRadius: 1,
                  icon: const Icon(Icons.file_open),
                  onPressed: () async {
                    String? downloadPath = await path();

                    await OpenFilex.open("$downloadPath/$name");
                  });
            }
            return IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              splashRadius: 1,
              icon: const Icon(Icons.download),
              onPressed: () async {
                String? downloadPath = await path();
                bool storagePermission =
                    await HelperUtils.hasStoragePermissionGiven();
                if (storagePermission) {
                  await dio.download(
                    widget.url,
                    "$downloadPath/$name",
                    onReceiveProgress: (count, total) async {
                      percentage.value = count / total;
                      if (percentage.value == 1.0) {
                        downloaded = true;
                        setState(() {});
                        await OpenFilex.open("$downloadPath/$name");
                      }
                    },
                  );
                } else {
                  HelperUtils.showSnackBarMessage(
                      context, "Storage Permission denied!");
                }
              },
            );
          }),
    );
  }
}
