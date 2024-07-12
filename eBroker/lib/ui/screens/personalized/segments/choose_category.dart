part of '../personalized_property_screen.dart';

class CategoryInterestChoose extends StatefulWidget {
  final PageController controller;
  final VoidCallback onClearFilter;
  final PersonalizedVisitType type;
  final Function(List<int> selectedCategoryId) onInteraction;
  const CategoryInterestChoose(
      {super.key,
      required this.controller,
      required this.onInteraction,
      required this.type,
      required this.onClearFilter});

  @override
  State<CategoryInterestChoose> createState() => _CategoryInterestChooseState();
}

class _CategoryInterestChooseState extends State<CategoryInterestChoose>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedCategoryId = personalizedInterestSettings.categoryIds;

  @override
  Widget build(BuildContext context) {
    bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    super.build(context);
    return Column(
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
            Text("chooseYourInterest".translate(context))
                .color(context.color.textColorDark)
                .size(context.font.xxLarge)
                .centerAlign(),
            const Spacer(
              flex: 1,
            ),
            if (!isFirstTime)
              GestureDetector(
                  onTap: () {
                    widget.onClearFilter.call();
                  },
                  child: Chip(
                      label: Text("Clear".translate(context))
                          .color(context.color.buttonColor))),
            if (isFirstTime)
              GestureDetector(
                  onTap: () {
                    HelperUtils.killPreviousPages(
                        context, Routes.main, {"from": "login"});
                  },
                  child: Chip(
                      label: Text("skip".translate(context))
                          .color(context.color.buttonColor))),
            const SizedBox(
              width: 14,
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Wrap(
          children: List.generate(
              (context.watch<FetchCategoryCubit>().getCategories().length),
              (index) {
            Category categorie =
                context.watch<FetchCategoryCubit>().getCategories()[index];
            bool isSelected =
                selectedCategoryId.contains(int.parse(categorie.id!));
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: GestureDetector(
                onTap: () {
                  selectedCategoryId.addOrRemove(int.parse(categorie.id!));
                  widget.onInteraction.call(selectedCategoryId);
                  setState(() {});
                },
                child: Chip(
                    shape: StadiumBorder(
                        side: BorderSide(color: context.color.borderColor)),
                    backgroundColor: isSelected
                        ? context.color.tertiaryColor
                        : context.color.secondaryColor,
                    padding: const EdgeInsets.all(5),
                    label: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(categorie.category.toString()).color(
                          isSelected
                              ? context.color.buttonColor
                              : context.color.textColorDark),
                    )),
              ),
            );
          }),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
