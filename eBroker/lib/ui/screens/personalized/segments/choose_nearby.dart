part of '../personalized_property_screen.dart';

class NearbyInterest extends StatefulWidget {
  final PageController controller;

  final PersonalizedVisitType type;
  final Function(List<int> selectedNearbyPlacesIds) onInteraction;
  const NearbyInterest({
    super.key,
    required this.controller,
    required this.onInteraction,
    required this.type,
  });

  @override
  State<NearbyInterest> createState() => _NearbyInterestState();
}

class _NearbyInterestState extends State<NearbyInterest>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedIds = personalizedInterestSettings.outdoorFacilityIds;
  @override
  void initState() {
    context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    Future.delayed(
      Duration(seconds: 1),
      () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    var facilityList = context.watch<FetchOutdoorFacilityListCubit>().getList();
    int facilityLength = facilityList.length;
    FetchOutdoorFacilityListState state =
        context.watch<FetchOutdoorFacilityListCubit>().state;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(
                flex: 2,
              ),
              Text("chooseNearbyPlaces".translate(context))
                  .color(context.color.textColorDark)
                  .size(context.font.xxLarge)
                  .centerAlign(),
              Spacer(
                flex: isFirstTime ? 1 : 2,
              ),

              if (isFirstTime)
                GestureDetector(
                    onTap: () {
                      HelperUtils.killPreviousPages(
                        context,
                        Routes.main,
                        {"from": "login"},
                      );
                    },
                    child: Chip(
                        label: Text("skip".translate(context))
                            .color(context.color.buttonColor))),
              // const Chip(label: Text("Skip")),
              const SizedBox(
                width: 14,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text("getRecommandation".translate(context))
              .color(context.color.textColorDark.withOpacity(0.6))
              .centerAlign()
              .size(context.font.small),
          const SizedBox(
            height: 15,
          ),
          if (state is FetchOutdoorFacilityListInProgress) ...{
            UiUtils.progress()
          },
          Wrap(
            children: List.generate((facilityLength), (index) {
              OutdoorFacility facility = facilityList[index];
              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: GestureDetector(
                  onTap: () {
                    selectedIds.addOrRemove(facility.id!);
                    widget.onInteraction.call(selectedIds);
                    setState(() {});
                  },
                  child: Chip(
                      shape: StadiumBorder(
                          side: BorderSide(color: context.color.borderColor)),
                      backgroundColor: selectedIds.contains(facility.id!)
                          ? context.color.tertiaryColor
                          : context.color.secondaryColor,
                      padding: const EdgeInsets.all(5),
                      label: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(facility.name.toString()).color(
                            selectedIds.contains(facility.id!)
                                ? context.color.buttonColor
                                : context.color.textColorDark),
                      )),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
