import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

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

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _pageScrollController = ScrollController();
  @override
  void initState() {
    _pageScrollController.addListener(pageScrollListen);
    context.read<FetchFavoritesCubit>().fetchFavorites();
    super.initState();
  }

  void pageScrollListen() {
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

  Widget buildFavoritePropertyShimmer() {
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
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth / 4,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        context.read<FetchFavoritesCubit>().fetchFavorites();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backgroundColor,
        body: BlocBuilder<FetchFavoritesCubit, FetchFavoritesState>(
          builder: (context, state) {
            if (state is FetchFavoritesInProgress) {
              return buildFavoritePropertyShimmer();
            }
            if (state is FetchFavoritesFailure) {
              return Center(
                child: Text(state.errorMessage.toString()),
              );
            }
            if (state is FetchFavoritesSuccess) {
              if (state.propertymodel.isEmpty) {
                return NoDataFound(
                  onTap: () {
                    context.read<FetchFavoritesCubit>().fetchFavorites();
                  },
                );
              }

              return RefreshIndicator(
                color: context.color.tertiaryColor,
                onRefresh: () async {
                  context.read<FetchFavoritesCubit>().fetchFavorites();
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _pageScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: state.propertymodel.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          PropertyModel property = state.propertymodel[index];
                          context.read<LikedPropertiesCubit>().add(property.id);

                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                  onTap: () {
                                    // return;
                                    Navigator.pushNamed(
                                        context, Routes.propertyDetails,
                                        arguments: {
                                          'propertyData': property,
                                          'fromMyProperty': true
                                        }).then((value) {});
                                  },
                                  child: BlocProvider(
                                    create: (context) =>
                                        AddToFavoriteCubitCubit(),
                                    child: PropertyHorizontalCard(
                                      property: property,
                                      onLikeChange: (type) {
                                        context
                                            .read<FetchFavoritesCubit>()
                                            .remove(property.id);
                                      },
                                    ),
                                  )));
                        },
                      ),
                    ),
                    if (state.isLoadingMore) UiUtils.progress()
                  ],
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
