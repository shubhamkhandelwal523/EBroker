import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/outdoor_facility.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Extensions/lib/list.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../data/cubits/Personalized/add_update_personalized_interest.dart';

part 'segments/choose_category.dart';
part 'segments/choose_nearby.dart';
part 'segments/other_interest.dart';

enum PersonalizedVisitType { FirstTime, Normal }

class PersonalizedPropertyScreen extends StatefulWidget {
  final PersonalizedVisitType type;

  const PersonalizedPropertyScreen({Key? key, required this.type})
      : super(key: key);

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) => PersonalizedPropertyScreen(
        type: args?['type'],
      ),
    );
  }

  @override
  State<PersonalizedPropertyScreen> createState() =>
      _PersonalizedPropertyScreenState();
}

class _PersonalizedPropertyScreenState
    extends State<PersonalizedPropertyScreen> {
  List<int> selectedCategoryId = personalizedInterestSettings.categoryIds;
  List<int> selectedNearbyPlacesId = [];
  int selectedPage = 0;
  RangeValues? _selectedPriceRange;
  String selectedLocation = "";
  List<int> selectedPropertyType = [];

  @override
  void initState() {
    context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    super.initState();
  }

  final PageController _pageController = PageController();

  Future<void> onClearFilter() async {
    await PersonalizedFeedRepository().clearPersonalizedSettings(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: BlocConsumer<AddUpdatePersonalizedInterest,
          AddUpdatePersonalizedInterestState>(listener: (context, state) {
        if (state is AddUpdatePersonalizedInterestInProgress) {
          Widgets.showLoader(context);
        }
        if (state is AddUpdatePersonalizedInterestFail) {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(
              context, "unableToSave".translate(context));
        }
        if (state is AddUpdatePersonalizedInterestSuccess) {
          Widgets.hideLoder(context);
          context.read<FetchPersonalizedPropertyList>().fetch(
                forceRefresh: true,
              );
          if (widget.type == PersonalizedVisitType.FirstTime) {
            Future.delayed(
              Duration.zero,
              () {
                HelperUtils.showSnackBarMessage(
                  context,
                  "successfullyAdded".translate(context),
                  type: MessageType.success,
                );
                HelperUtils.killPreviousPages(
                  context,
                  Routes.main,
                  {"from": "login"},
                );
              },
            );
          } else {
            HelperUtils.showSnackBarMessage(
              context,
              "successfullySaved".translate(context),
              type: MessageType.success,
            );
            Navigator.pop(context);
          }
        }
      }, builder: (context, state) {
        return SafeArea(
          child: SizedBox(
            width: context.screenWidth,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              children: [
                CategoryInterestChoose(
                  controller: _pageController,
                  onClearFilter: onClearFilter,
                  type: widget.type,
                  onInteraction: _onCategoryInteraction,
                ),
                NearbyInterest(
                  controller: _pageController,
                  type: widget.type,
                  onInteraction: _onNearbyInteraction,
                ),
                OtherInterests(
                  type: widget.type,
                  onInteraction: _onOtherInterestsInteraction,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: context.color.primaryColor,
      child: Row(
        children: [
          if (selectedPage > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(15, 5, 5, 5),
                child: _buildNavigationButton(
                  onPressed: selectedCategoryId.isEmpty
                      ? null
                      : () {
                          _pageController.animateToPage(
                            --selectedPage,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear,
                          );
                        },
                  buttonTextColor: (selectedCategoryId.isEmpty
                      ? context.color.textColorDark
                      : null),
                  label: "previouslbl".translate(context),
                  color: context.color.tertiaryColor.withOpacity(0.5),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 15, 5),
              child: _buildNavigationButton(
                onPressed: selectedCategoryId.isEmpty
                    ? null
                    : () {
                        if (selectedPage < 2) {
                          _pageController.animateToPage(
                            ++selectedPage,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _updatePersonalizedFeed();
                        }
                      },
                label: "next".translate(context),
                buttonTextColor: selectedCategoryId.isEmpty
                    ? context.color.textColorDark
                    : null,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      {VoidCallback? onPressed,
      required String label,
      required Color color,
      Color? buttonTextColor}) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onPressed,
      height: 48,
      color: color,
      child: Text(label).color(buttonTextColor ?? context.color.buttonColor),
    );
  }

  void _updatePersonalizedFeed() async {
    context.read<AddUpdatePersonalizedInterest>().addOrUpdate(
        action: PersonalizedFeedAction.add,
        categoryIds: selectedCategoryId,
        outdoorFacilityList: selectedNearbyPlacesId,
        priceRange: _selectedPriceRange,
        city: selectedLocation,
        selectedPropertyType: selectedPropertyType);
  }

  void _onPageChanged(int value) {
    selectedPage = value;
    setState(() {});
  }

  void _onCategoryInteraction(List<int> id) {
    selectedCategoryId = id;
    setState(() {});
  }

  void _onNearbyInteraction(List<int> idlist) {
    selectedNearbyPlacesId = idlist;
    setState(() {});
  }

  void _onOtherInterestsInteraction(
      RangeValues priceRange, String location, List<int> propertyTypes) {
    _selectedPriceRange = priceRange;
    selectedLocation = location;
    selectedPropertyType = propertyTypes;

    setState(() {});
  }
}
