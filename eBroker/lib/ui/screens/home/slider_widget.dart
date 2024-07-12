import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../../../data/model/home_slider.dart';
import '../widgets/promoted_widget.dart';
import 'home_screen.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({Key? key}) : super(key: key);

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
  int bannersLength = 0;
  late Timer _timer;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_bannerIndex.value < bannersLength - 1) {
        _bannerIndex.value++;
      } else {
        _bannerIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _bannerIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerIndex.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if ((state is SliderFetchFailure && !state.isUserDeactivated) ||
            state is SliderFetchSuccess) {
          // context.read<SliderCubit>().fetchSlider(context);
        }
      },
      builder: (context, SliderState state) {
        if (state is SliderFetchSuccess) {
          bannersLength = state.sliderlist.length;

          return Column(
            children: <Widget>[
              SizedBox(
                height: 15.rh(context),
              ),
              SizedBox(
                height: 130.rh(context),
                child: PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemCount: state.sliderlist.length,
                  onPageChanged: (index) {
                    _bannerIndex.value = index;
                  },
                  itemBuilder: (context, index) => _buildBanner(
                    state.sliderlist[index],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
          /* } else if (state is SliderFetchFailure &&
                state.isUserDeactivated == true) {
              isUserDeactivated = true; */
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(HomeSlider banner) {
    return GestureDetector(
      onTap: () async {
        try {
          PropertyRepository fetch = PropertyRepository();

          Widgets.showLoader(context);

          DataOutput<PropertyModel> dataOutput =
              await fetch.fetchPropertyFromPropertyId(banner.propertysId);

          Future.delayed(
            Duration.zero,
            () {
              Widgets.hideLoder(context);
              HelperUtils.goToNextPage(
                Routes.propertyDetails,
                context,
                false,
                args: {
                  'propertyData': dataOutput.modelList[0],
                  'propertiesList': dataOutput.modelList,
                  'fromMyProperty': false,
                },
              );
            },
          );
        } catch (e) {
          Widgets.hideLoder(context);

          if (e is NoInternetConnectionError) {
            HelperUtils.showSnackBarMessage(context, e.toString());
          } else {
            HelperUtils.showSnackBarMessage(
                context, UiUtils.translate(context, "somethingWentWrng"));
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              width: context.screenWidth,
              height: context.screenHeight * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(11),
                child: UiUtils.getImage(
                  banner.image.toString(),
                  width: context.screenWidth,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            PositionedDirectional(
                top: 10,
                start: 10,
                child: Visibility(
                    visible: banner.promoted ?? false,
                    child: const PromotedCard(type: PromoteCardType.icon)))
          ],
        ),
      ),
    );
  }

  Row pageindicator({required int index, required int length}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (indexDots) {
          return AnimatedContainer(
              duration: const Duration(microseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: index == indexDots ? 8 : 6,
              height: index == indexDots ? 8 : 6,
              decoration: BoxDecoration(
                  color: index == indexDots
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1)));
        }));
  }
}
