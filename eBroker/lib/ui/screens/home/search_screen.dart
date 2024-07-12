import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/bannerAdLoadWidget.dart';
import 'package:flutter/material.dart';

import '../../../data/helper/filter.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocus;
  final bool openFilterScreen;
  const SearchScreen(
      {Key? key, required this.autoFocus, required this.openFilterScreen})
      : super(key: key);
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SearchScreen(
          autoFocus: arguments?['autoFocus'],
          openFilterScreen: arguments?['openFilterScreen'],
        );
      },
    );
  }

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  bool isFocused = false;
  String previouseSearchQuery = "";
  static TextEditingController searchController = TextEditingController();
  int offset = 0;
  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List idlist = [];
  Timer? _searchDelay;
  FilterApply? selectedFilter;
  bool showContent = true;
  @override
  void initState() {
    super.initState();
    if (widget.openFilterScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamed(context, Routes.filterScreen);
      });
    }
    context
        .read<SearchPropertyCubit>()
        .searchProperty("", offset: 0, filter: selectedFilter);
    searchController = TextEditingController();
    searchController.addListener(searchPropertyListener);
    controller = ScrollController()..addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<SearchPropertyCubit>().hasMoreData()) {
        context.read<SearchPropertyCubit>().fetchMoreSearchData();
      }
    }
  }

//this will listen and manage search
  void searchPropertyListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), propertySearch);
  }

  ///This will call api after some delay
  void propertySearch() {
    // if (searchController.text.isNotEmpty) {
    if (previouseSearchQuery != searchController.text) {
      context.read<SearchPropertyCubit>().searchProperty(searchController.text,
          offset: 0, filter: selectedFilter);
      previouseSearchQuery = searchController.text;
    }
    // } else {
    // context.read<SearchPropertyCubit>().clearSearch();
    // }
  }

  Widget filterOptionsBtn() {
    return IconButton(
        onPressed: () {
          print("Ok bro");
          Navigator.pushNamed(context, Routes.filterScreen).then((value) {
            print("Filter value is $value");
            if (value != null && searchController.text != "") {
              print("Helo $value");
              selectedFilter = value as FilterApply;
              context.read<SearchPropertyCubit>().searchProperty(
                  searchController.text,
                  offset: 0,
                  filter: value);
            }
          });
        },
        icon: Icon(
          Icons.filter_list_rounded,
          color: Theme.of(context).colorScheme.blackColor,
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: context.color.tertiaryColor,
        ),
        elevation: 0,
        backgroundColor: context.color.primaryColor,
        title: searchTextField(),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          // BlocBuilder<PropertyCubit, PropertyState>(
          //   builder: (context, state) {
          //     log("state isss $state");
          //     if (state is PropertyFetchSuccess) {
          //       return SingleChildScrollView(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Padding(
          //               padding: EdgeInsets.symmetric(horizontal: 16.0),
          //               child: Text("Latest properties"),
          //             ),
          //             ListView.builder(
          //               shrinkWrap: true,
          //               physics: const NeverScrollableScrollPhysics(),
          //               padding: const EdgeInsets.symmetric(horizontal: 16),
          //               itemCount: state.propertylist.length,
          //               itemBuilder: (context, index) {
          //                 return PropertyHorizontalCard(
          //                     property: state.propertylist[index]);
          //               },
          //             ),
          //           ],
          //         ),
          //       );
          //     }
          //     if (state is PropertyFetchFailure) {
          //       log(state.errmsg);
          //       return Container(
          //         child: Text(state.errmsg.toString()),
          //       );
          //     }
          //     return Container();
          //   },
          // ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchPropertyCubit, SearchPropertyState>(
              builder: (context, state) {
                return listWidget(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget(SearchPropertyState state) {
    if (state is SearchPropertyFetchProgress) {
      return Center(
        child:
            UiUtils.progress(normalProgressColor: context.color.tertiaryColor),
      );
    }
    if (state is SearchPropertyFailure) {
      if (state.errorMessage is NoInternetConnectionError) {
        return NoInternet(
          onRetry: () {
            context
                .read<SearchPropertyCubit>()
                .searchProperty("", offset: 0, filter: selectedFilter);
          },
        );
      }

      return const SomethingWentWrong();
    }

    if (state is SearchPropertySuccess) {
      if (state.searchedroperties.isEmpty) {
        return Center(
          child: Text(
            UiUtils.translate(context, "nodatafound"),
          ),
        );
      }
      // if (searchController.text == "") {
      //   return Center(
      //     child: Text(
      //       UiUtils.getTranslatedLabel(context, "nodatafound"),
      //     ),
      //   );
      // }
      return SingleChildScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Wrap(
                direction: Axis.horizontal,
                children:
                    List.generate(state.searchedroperties.length, (index) {
                  PropertyModel property = state.searchedroperties[index];
                  List propertiesList = state.searchedroperties;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        HelperUtils.goToNextPage(
                            Routes.propertyDetails, context, false, args: {
                          'propertyData': property,
                          'propertiesList': propertiesList
                        });
                      },
                      child: PropertyHorizontalCard(property: property),
                    ),
                  );
                }),
              ),
              if (state.isLoadingMore) UiUtils.progress()
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search,
            color: context.color.tertiaryColor));
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  Widget searchTextField() {
    return LayoutBuilder(builder: (context, c) {
      return SizedBox(
        width: c.maxWidth,
        child: FittedBox(
          fit: BoxFit.none,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 270.rw(context),
                  height: 50.rh(context),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.5, color: context.color.borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: context.color.secondaryColor),
                  child: TextFormField(
                      autofocus: widget.autoFocus,
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none, //OutlineInputBorder()
                        fillColor: Theme.of(context).colorScheme.secondaryColor,
                        hintText: UiUtils.translate(context, "searchHintLbl"),
                        prefixIcon: setSearchIcon(),
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 5, minWidth: 5),
                      ),
                      enableSuggestions: true,
                      onEditingComplete: () {
                        setState(
                          () {
                            isFocused = false;
                          },
                        );
                        FocusScope.of(context).unfocus();
                      },
                      onTap: () {
                        //change prefix icon color to primary
                        setState(() {
                          isFocused = true;
                        });
                      })),
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.filterScreen,
                      arguments: {"filter": selectedFilter}).then((value) {
                    if (value != null) {
                      selectedFilter = value as FilterApply;
                      context.read<SearchPropertyCubit>().searchProperty(
                          searchController.text,
                          offset: 0,
                          filter: value);
                      setState(() {});

                      // context.read<SearchPropertyCubit>().searchProperty(
                      //     searchController.text,
                      //     offset: 0,
                      //     filter: selectedFilter);
                    }
                  });
                },
                child: Container(
                  width: 50.rw(context),
                  height: 50.rh(context),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor),
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: UiUtils.getSvg(AppIcons.filter,
                        color: context.color.tertiaryColor),
                  ),
                ),
              ),
              SizedBox(
                width: c.maxWidth * 0.06,
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
