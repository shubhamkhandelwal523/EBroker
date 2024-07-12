part of '../personalized_property_screen.dart';

class OtherInterests extends StatefulWidget {
  final PersonalizedVisitType type;
  final Function(
          RangeValues priceRange, String location, List<int> propertyType)
      onInteraction;
  const OtherInterests({
    super.key,
    required this.onInteraction,
    required this.type,
  });

  @override
  State<OtherInterests> createState() => _OtherInterestsState();
}

class _OtherInterestsState extends State<OtherInterests> {
  String selectedLocation = "";
  final TextEditingController _cityController = TextEditingController();
  late final min = personalizedInterestSettings.priceRange.first;
  late final max = personalizedInterestSettings.priceRange.last;
  RangeValues _priceRangeValues = const RangeValues(0, 100);
  RangeValues _selectedRangeValues = const RangeValues(0, 50);

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();
  List<int> selectedPropertyType = [0, 1];
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        selectedPropertyType = personalizedInterestSettings.propertyType;

        if (personalizedInterestSettings.city.isNotEmpty) {
          _cityController.text =
              personalizedInterestSettings.city.firstUpperCase();
          selectedLocation = personalizedInterestSettings.city;
        }

        widget.onInteraction
            .call(_selectedRangeValues, selectedLocation, selectedPropertyType);
        setState(() {});
        FetchSystemSettingsState state =
            context.read<FetchSystemSettingsCubit>().state;
        if (state is FetchSystemSettingsSuccess) {
          var settingsData = state.settings['data'];
          var minPrice = double.parse(settingsData['min_price']);
          var maxPrice = double.parse(settingsData['max_price']);
          _priceRangeValues = RangeValues(minPrice, maxPrice);
          if (min != 0.0 && max != 0.0) {
            _selectedRangeValues = RangeValues(min, max);
          } else {
            _selectedRangeValues = RangeValues(minPrice, maxPrice / 4);
          }
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Spacer(
                  flex: 2,
                ),
                Text(
                  "selectCityYouWantToSee".translate(context),
                )
                    .color(context.color.textColorDark)
                    .size(context.font.extraLarge)
                    .centerAlign(),
                Spacer(
                  flex: isFirstTime ? 1 : 2,
                ),
                if (isFirstTime)
                  GestureDetector(
                      onTap: () {
                        HelperUtils.killPreviousPages(
                            context, Routes.main, {"from": "login"});
                      },
                      child: Chip(
                          label: Text("skip".translate(context))
                              .color(context.color.buttonColor))),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            buildCitySearchTextField(context),
            const SizedBox(
              height: 10,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text("selectedLocation".translate(context))
                        .color(context.color.textColorDark.withOpacity(0.6)),
                    Expanded(child: Text(selectedLocation))
                  ],
                )),
            const SizedBox(
              height: 20,
            ),
            Text("choosePropertyType".translate(context))
                .color(context.color.textColorDark)
                .size(context.font.extraLarge)
                .centerAlign(),
            const SizedBox(
              height: 10,
            ),
            PropertyTypeSelector(
              onInteraction: (List<int> values) {
                selectedPropertyType = values;
                widget.onInteraction
                    .call(_selectedRangeValues, selectedLocation, values);

                setState(() {});
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              "chooseTheBudeget".translate(context),
            )
                .color(context.color.textColorDark)
                .size(context.font.extraLarge)
                .centerAlign(),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text("minLbl".translate(context)),
                      Text(_selectedRangeValues.start
                          .toInt()
                          .toString()
                          .priceFormate()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: RangeSlider(
                    // labels: RangeLabels(_priceRangeValues.start.toString(), _priceRangeValues.end.toString()),
                    activeColor: context.color.tertiaryColor,
                    values: _selectedRangeValues,
                    onChanged: (RangeValues value) {
                      _selectedRangeValues = value;
                      widget.onInteraction.call(_selectedRangeValues,
                          selectedLocation, selectedPropertyType);
                      setState(() {});
                    },
                    min: _priceRangeValues.start,
                    max: _priceRangeValues.end,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text("maxLbl".translate(context)),
                      Text(_selectedRangeValues.end
                          .toInt()
                          .toString()
                          .priceFormate()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCitySearchTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: TypeAheadField(
        errorBuilder: (context, error) {
          return Container(
            child: Text("Error"),
          );
        },

        loadingBuilder: (context) {
          return Center(child: UiUtils.progress());
        },
        // builder: (context, controller, focusNode) {
        //   return TextField(
        //     controller: controller,
        //     decoration: InputDecoration(
        //       hintText: "searchCity".translate(context),
        //       suffixIcon: GestureDetector(
        //           onTap: () {
        //             _cityController.text = "";
        //           },
        //           child: Icon(
        //             Icons.close,
        //             color: context.color.tertiaryColor,
        //           )),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(10),
        //         borderSide: BorderSide(color: context.color.tertiaryColor),
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(10),
        //         borderSide: BorderSide(color: context.color.tertiaryColor),
        //       ),
        //     ),
        //   );
        // },
        // minCharsForSuggestions: 2,

        // suggestionsBoxDecoration: SuggestionsBoxDecoration(
        //   color: context.color.secondaryColor.withOpacity(1),
        // ),
        itemBuilder: (context, GooglePlaceModel itemData) {
          List<String> address = [
            itemData.city,
            // itemData.state,
            // itemData.country
          ];

          return ListTile(
            title: Text(address.join(",").toString()),
          );
        },

        suggestionsCallback: (String pattern) async {
          print("pattern here $pattern");
          if (pattern.length < 2) {
            return Future.value(<GooglePlaceModel>[]);
          }
          return await googlePlaceRepository.serchCities(pattern);
        },
        onSelected: (GooglePlaceModel suggestion) {
          List<String> addressList = [
            suggestion.city,
            // suggestion.state,
            // suggestion.country
          ];
          String address = addressList.join(",");
          _cityController.text = address;
          selectedLocation = address;
          widget.onInteraction.call(
              _selectedRangeValues, selectedLocation, selectedPropertyType);

          setState(() {});
        },
      ),
    );
  }
}

class PropertyTypeSelector extends StatefulWidget {
  final Function(List<int> values) onInteraction;
  const PropertyTypeSelector({
    super.key,
    required this.onInteraction,
  });

  @override
  State<PropertyTypeSelector> createState() => _PropertyTypeSelectorState();
}

class _PropertyTypeSelectorState extends State<PropertyTypeSelector> {
  List<int> selectedPropertyType = [0, 1];
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        if (personalizedInterestSettings.propertyType.isNotEmpty) {
          selectedPropertyType = personalizedInterestSettings.propertyType;
        }

        widget.onInteraction.call(selectedPropertyType);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAddAll([0, 1]);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label: Text("all".translate(context))
                .size(context.font.large)
                .color(selectedPropertyType.containesAll([0, 1])
                    ? context.color.buttonColor
                    : context.color.textColorDark),
            backgroundColor: selectedPropertyType.containesAll([0, 1])
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(0);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label: Text("sell".translate(context))
                .size(context.font.large)
                .color(selectedPropertyType.isSingleElementAndIs(0)
                    ? context.color.buttonColor
                    : context.color.textColorDark),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(0)
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
            onTap: () {
              selectedPropertyType.clearAndAdd(1);
              widget.onInteraction.call(selectedPropertyType);
              setState(() {});
            },
            child: Chip(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              label: Text("rent".translate(context))
                  .size(context.font.large)
                  .color(selectedPropertyType.isSingleElementAndIs(1)
                      ? context.color.buttonColor
                      : context.color.textColorDark),
              backgroundColor: selectedPropertyType.isSingleElementAndIs(1)
                  ? context.color.tertiaryColor
                  : context.color.secondaryColor,
            )),
      ],
    );
  }
}
