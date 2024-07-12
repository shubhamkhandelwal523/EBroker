import 'package:ebroker/data/cubits/Report/property_report_cubit.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/AppIcon.dart';
import '../../../../utils/guestChecker.dart';
import '../../report/report_property_screen.dart';

class ReportPropertyButton extends StatefulWidget {
  final int propertyId;
  final Function() onSuccess;
  const ReportPropertyButton(
      {Key? key, required this.propertyId, required this.onSuccess})
      : super(key: key);

  @override
  State<ReportPropertyButton> createState() => _ReportPropertyButtonState();
}

class _ReportPropertyButtonState extends State<ReportPropertyButton> {
  bool shouldReport = true;
  void _onTapYes(int propertyId) {
    _bottomSheet(propertyId);
  }

  _onTapNo() {
    shouldReport = false;
    setState(() {});
  }

  void _bottomSheet(int propertyId) {
    PropertyReportCubit cubit = BlocProvider.of<PropertyReportCubit>(context);
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: BlocProvider.value(
            value: cubit,
            child: ReportPropertyScreen(propertyId: propertyId),
          ),
        ))).then((value) {
      widget.onSuccess.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (shouldReport == false) {
      return SizedBox.shrink();
    }
    return Container(
      height: 135,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark
                  ? widgetsBorderColorLight.withOpacity(0.1)
                  : widgetsBorderColorLight,
              width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("didYoufindProblem".translate(context))
                      .setMaxLines(lines: 2)
                      .bold(weight: FontWeight.w100)
                      .size(context.font.larger),
                  const Spacer(),
                  Row(
                    children: [
                      MaterialButton(
                          onPressed: () {
                            GuestChecker.check(onNotGuest: () {
                              _onTapYes.call(widget.propertyId);
                            });
                          },
                          textColor: context.color.tertiaryColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? widgetsBorderColorLight.withOpacity(0.1)
                                      : widgetsBorderColorLight),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("yes".translate(context))),
                      const SizedBox(
                        width: 10,
                      ),
                      MaterialButton(
                          onPressed: _onTapNo,
                          textColor: context.color.tertiaryColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? widgetsBorderColorLight.withOpacity(0.1)
                                      : widgetsBorderColorLight),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("notReally".translate(context)))
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? AppIcons.reportDark
                  : AppIcons.report,
            )
          ],
        ),
      ),
    );
  }
}
