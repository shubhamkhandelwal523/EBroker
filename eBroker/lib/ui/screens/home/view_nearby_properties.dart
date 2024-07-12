import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:flutter/material.dart';

class NearbyAllPropertiesScreen extends StatefulWidget {
  const NearbyAllPropertiesScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (context) {
        return const NearbyAllPropertiesScreen();
      },
    );
  }

  @override
  State<NearbyAllPropertiesScreen> createState() =>
      _NearbyAllPropertiesScreenState();
}

class _NearbyAllPropertiesScreenState extends State<NearbyAllPropertiesScreen> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScollController = ScrollController();
  @override
  void initState() {
    _pageScollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScollController.isEndReached()) {
      if (context.read<FetchNearbyPropertiesCubit>().hasMoreData()) {
        context.read<FetchNearbyPropertiesCubit>().fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        backgroundColor: context.color.secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
        title: Text(
                "${UiUtils.translate(context, "NearbyProperties")}(${HiveUtils.getCityName()})")
            .color(context.color.tertiaryColor)
            .size(context.font.large),
      ),
      body: BlocBuilder<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
        builder: (context, state) {
          if (state is FetchNearbyPropertiesInProgress) {
            return Center(
              child: UiUtils.progress(
                  normalProgressColor: context.color.tertiaryColor),
            );
          }
          if (state is FetchNearbyPropertiesFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchNearbyPropertiesSuccess) {
            if (state.properties.isEmpty) {
              return Center(
                child: NoDataFound(
                  onTap: () {
                    context.read<FetchNearbyPropertiesCubit>().fetch();
                  },
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: RemoveGlow(),
                    child: ListView.builder(
                      controller: _pageScollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.properties.length,
                      itemBuilder: (context, index) {
                        PropertyModel property = state.properties[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: PropertyGradiendCard(
                            model: property,
                          ),
                        );
                      },
                    ),
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
