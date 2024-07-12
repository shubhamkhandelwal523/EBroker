import 'package:flutter/material.dart';

import '../../exports/main_export.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => BlocProvider(
        create: (context) => FetchFavoritesCubit(),
        child: const FavoritesScreen(),
      ),
    );
  }

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ScrollController _pageScrollController = ScrollController();
  @override
  void initState() {
    _pageScrollController.addListener(_pageScrollListen);
    context.read<FetchFavoritesCubit>().fetchFavorites();
    super.initState();
  }

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchFavoritesCubit>().hasMoreData()) {
        context.read<FetchFavoritesCubit>().fetchFavoritesMore();
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: context.color.tertiaryColor,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: UiUtils.translate(
            context,
            "favorites",
          ),
        ),
        body: BlocBuilder<FetchFavoritesCubit, FetchFavoritesState>(
          builder: (context, state) {
            if (state is FetchFavoritesInProgress) {
              return shimmerEffect();
            }
            if (state is FetchFavoritesFailure) {
              if (state.errorMessage is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchFavoritesCubit>().fetchFavorites();
                  },
                );
              }

              return const SomethingWentWrong();
            }
            if (state is FetchFavoritesSuccess) {
              if (state.propertymodel.isEmpty) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: context.screenHeight - 100.rh(context),
                    child: Center(
                      child: NoDataFound(
                        onTap: () {
                          context.read<FetchFavoritesCubit>().fetchFavorites();
                        },
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _pageScrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.propertymodel.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        PropertyModel property = state.propertymodel[index];
                        context.read<LikedPropertiesCubit>().add(property.id);
                        return BlocProvider(
                          create: (context) => AddToFavoriteCubitCubit(),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.propertyDetails,
                                arguments: {
                                  'propertyData': property,
                                  'fromMyProperty': true,
                                },
                              );
                            },
                            child: PropertyHorizontalCard(
                              property: property,
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore)
                    UiUtils.progress(
                      normalProgressColor: context.color.tertiaryColor,
                    )
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          vertical: 10 + defaultPadding, horizontal: defaultPadding),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CustomShimmer(height: 90, width: 90),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth - 50,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomShimmer(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth / 1.2,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: CustomShimmer(
                            width: c.maxWidth / 4,
                          ),
                        ),
                      ],
                    );
                  }),
                )
              ]),
        );
      },
    );
  }
}
