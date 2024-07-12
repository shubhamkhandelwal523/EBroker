import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../../../utils/area_converter.dart';

class AreaCalculator extends StatefulWidget {
  const AreaCalculator({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const AreaCalculator();
      },
    );
  }

  @override
  State<AreaCalculator> createState() => _AreaCalculatorState();
}

class _AreaCalculatorState extends State<AreaCalculator> {
  List<String> values = UnitTypes.values.map((e) => e.name).toList();

  late final ValueNotifier _from = ValueNotifier(values[0]);
  late final ValueNotifier _to = ValueNotifier(values[1]);

  final TextEditingController _fromTextController = TextEditingController();
  final TextEditingController _toTextController = TextEditingController();
  final TextEditingController _resultController =
      TextEditingController(text: "00");

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _fromTextController.dispose();
    _resultController.dispose();
    _toTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.translate(context, "areaConvertor")),
      body: Padding(
        padding: const EdgeInsets.all(010.0),
        child: Container(
          decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10)),
          width: context.screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15.rh(context),
                ),
                Text("${UiUtils.translate(context, "convert")} ${_placeSpaceBeforeCapital(_from.value)} to  ${_placeSpaceBeforeCapital(_to.value)}")
                    .size(context.font.large)
                    .color(context.color.textColorDark),
                SizedBox(
                  height: 3.rh(context),
                ),
                const Text("Enter the value and select desired unit")
                    .size(context.font.small)
                    .color(context.color.textLightColor),
                SizedBox(
                  height: 15.rh(context),
                ),
                ValueListenableBuilder(
                    valueListenable: _from,
                    builder: (context, value, child) {
                      return buildField(
                        context,
                        controller: _fromTextController,
                        value: value,
                        hint: "from",
                        valueListanable: _from,
                      );
                    }),
                SizedBox(
                  height: 15.rh(context),
                ),
                ValueListenableBuilder(
                    valueListenable: _to,
                    builder: (context, value, child) {
                      return buildField(
                        context,
                        controller: _toTextController,
                        isReadOnly: true,
                        value: value,
                        hint: "to",
                        valueListanable: _to,
                      );
                    }),
                SizedBox(
                  height: 20.rh(context),
                ),
                CustomTextFormField(
                  isReadOnly: true,
                  controller: _resultController,
                  fillColor: context.color.textColorDark.withOpacity(0.03),
                ),
                SizedBox(
                  height: 20.rh(context),
                ),
                UiUtils.buildButton(context, onPressed: () {
                  if (_fromTextController.text.isEmpty) {
                    return;
                  }

                  var convert = AreaConverter().convert(
                      num.parse(_fromTextController.text),
                      from: getEnum(_from.value),
                      to: getEnum(_to.value));

                  _toTextController.text = convert.toString();

                  _resultController.text =
                      "${_fromTextController.text} ${_placeSpaceBeforeCapital(_from.value)} = $convert ${_placeSpaceBeforeCapital(_to.value)}";
                }, buttonTitle: UiUtils.translate(context, "convert"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(
    BuildContext context, {
    required dynamic value,
    required ValueNotifier valueListanable,
    bool? isReadOnly,
    String? hint,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.textColorDark.withOpacity(0.03),
        border: Border.all(width: 1.5, color: context.color.borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 55.rh(context),
      width: context.screenWidth,
      child: buildConvertTextFieldWithDropdown(context,
          hint: hint,
          controller: controller,
          isReadOnly: isReadOnly, onChange: (value) {
        valueListanable.value = value;
      }, value: value),
    );
  }

  Widget buildConvertTextFieldWithDropdown(BuildContext context,
      {required Function(dynamic value) onChange,
      String? hint,
      bool? isReadOnly,
      required TextEditingController controller,
      dynamic value}) {
    return Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        Expanded(
            child: TextField(
          controller: controller,
          readOnly: isReadOnly ?? false,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
          ],
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: UiUtils.translate(context, hint ?? "")),
        )),
        VerticalDivider(
          color: context.color.textColorDark,
          endIndent: 5,
          indent: 5,
        ),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: List.generate(values.length, (index) {
              return DropdownMenuItem(
                value: values[index],
                child: Text(_placeSpaceBeforeCapital(values[index])),
              );
            }),
            onChanged: (value) {
              onChange.call(value);
              setState(() {});
            },
          ),
        )
      ],
    );
  }

  String _placeSpaceBeforeCapital(String value) {
// if(value=="Square feet")

    if (value == "squareMeter") {
      return "Sq. m";
    }
    if (value == "squareFeet") {
      return "Sq. ft";
    }
    return value.toString().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) {
        return " ${value[match.start]}";
      },
    ).firstUpperCase();
  }
}
