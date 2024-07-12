import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class ManageFloorPlansScreen extends StatefulWidget {
  final List<Map>? floorPlans;

  static route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return ManageFloorPlansScreen(
          floorPlans: arguments?['floorPlan'],
        );
      },
    );
  }

  const ManageFloorPlansScreen({super.key, required this.floorPlans});

  @override
  CloudState<ManageFloorPlansScreen> createState() =>
      _ManageFloorPlansScreenState();
}

class _ManageFloorPlansScreenState extends CloudState<ManageFloorPlansScreen> {
  List<FloorPlan> floorPlans = [];
  List<int> removePlanId = [];

  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    if (widget.floorPlans != null) {
      widget.floorPlans?.forEach((value) {
        FloorPlan floorPlan = FloorPlan(
          planKey: value['id'] is int ? ValueKey(value['id']) : value['id'],
          key: UniqueKey(),
          title: value['title'],
          imagePickerValue: value['image'] is String
              ? UrlValue(value['image'])
              : value['image'],
          onClose: (e) {
            removeFromListWhere(
              listKey: 'floorsList',
              whereKey: 'id',
              equals: e,
            );
            if (e is ValueKey) {
              removePlanId.add(e.value);
            }
            floorPlans.removeWhere((element) => element.planKey == e);
            setState(() {});
          },
        );
        floorPlans.add(floorPlan);
      });
      setState(() {});
    } else {
      FloorPlan floorPlan = FloorPlan(
        planKey: GlobalKey(),
        key: UniqueKey(),
        onClose: (key) {
          removeFromGroup('floors', key);
          if (key is ValueKey) {
            removePlanId.add(key.value);
          }
          floorPlans.removeWhere((element) => element.planKey == key);
          setState(() {});
        },
      );
      floorPlans.add(floorPlan);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        clearGroup('floors');
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true, title: "FloorPlans".translate(context)),
        bottomNavigationBar: BottomAppBar(
          color: context.color.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: context.color.tertiaryColor,
              onPressed: () {
                List<Map>? floors = getCloudData("floorsList") as List<Map>?;

                Navigator.pop(context, {
                  "floorPlans": floors,
                  "removed": removePlanId,
                });
              },
              height: 50,
              child: Text("continue".translate(context))
                  .color(context.color.secondaryColor),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              width: context.screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...floorPlans,
                  MaterialButton(
                    color: context.color.tertiaryColor,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FloorPlan floorPlan = FloorPlan(
                          planKey: GlobalKey(),
                          key: UniqueKey(),
                          onClose: (e) {
                            removeFromListWhere(
                                listKey: 'floorsList',
                                whereKey: 'id',
                                equals: e);
                            if (e is ValueKey) {
                              removePlanId.add(e.value);
                            }
                            floorPlans
                                .removeWhere((element) => element.planKey == e);
                            setState(() {});
                          },
                        );
                        floorPlans.add(floorPlan);
                        setState(() {});
                      }
                    },
                    elevation: 0,
                    minWidth: context.screenWidth * 0.45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text("Add".translate(context))
                        .color(context.color.buttonColor),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloorPlan extends StatefulWidget {
  Key planKey;
  final String? title;
  final ImagePickerValue? imagePickerValue;
  final Function(Key e) onClose;

  FloorPlan({
    super.key,
    this.title,
    required this.planKey,
    required this.onClose,
    this.imagePickerValue,
  });

  @override
  CloudState<FloorPlan> createState() {
    return FloorPlanState();
  }
}

class FloorPlanState extends CloudState<FloorPlan> {
  ImagePickerValue? imagePickerValue;

  late final TextEditingController floorTitle =
      TextEditingController(text: widget.title);

  @override
  void initState() {
    imagePickerValue = widget.imagePickerValue;
    super.initState();
  }

  @override
  void dispose() {
    floorTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Floor Title".translate(context)),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    widget.onClose.call(widget.planKey);
                  },
                  icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextFormField(
            controller: floorTitle,
            autovalidate: AutovalidateMode.onUserInteraction,
            validator: CustomTextFieldValidator.nullCheck,
            onChange: (value) {
              appendToListWhere(
                  listKey: "floorsList",
                  whereKey: "id",
                  equals: widget.planKey,
                  add: {
                    "title": value,
                    "id": widget.planKey,
                    "image": imagePickerValue
                  });
            },
            hintText: "title".translate(context),
          ),
          const SizedBox(height: 10),
          AdaptiveImagePickerWidget(
            multiImage: false,
            isRequired: true,
            value: imagePickerValue,
            title: "pickFloorMap".translate(context),
            onSelect: (ImagePickerValue? selected) {
              if (selected is FileValue) {
                imagePickerValue = selected;
              }

              // appendToList("floorsList", {
              //   "title": floorTitle.text,
              //   "key": widget.key,
              //   "image": imagePickerValue
              // });
              appendToListWhere(
                  listKey: "floorsList",
                  whereKey: "id",
                  equals: widget.planKey,
                  add: {
                    "title": floorTitle.text,
                    "id": widget.planKey,
                    "image": imagePickerValue
                  });
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
