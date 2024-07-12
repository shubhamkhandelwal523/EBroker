import 'package:ebroker/data/cubits/Report/property_report_cubit.dart';
import 'package:ebroker/data/model/report_property/reason_model.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cubits/Report/fetch_property_report_reason_list.dart';

class ReportPropertyScreen extends StatefulWidget {
  final int propertyId;
  const ReportPropertyScreen({Key? key, required this.propertyId})
      : super(key: key);

  @override
  State<ReportPropertyScreen> createState() => _ReportPropertyScreenState();
}

class _ReportPropertyScreenState extends State<ReportPropertyScreen> {
  List<ReportReason>? reasons = [];
  late int selectedId;
  TextEditingController _reportmessageController = TextEditingController();
  @override
  void initState() {
    reasons =
        context.read<FetchPropertyReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Report property").size(context.font.larger),
            SizedBox(
              height: 15,
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: reasons?.length ?? 0,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (selectedId == reasons![index].id) {
                      // selectedId = -10;
                    } else {
                      selectedId = reasons![index].id;
                    }
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.color.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selectedId == reasons?[index].id
                              ? context.color.tertiaryColor
                              : context.color.borderColor,
                          width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(reasons?[index].reason.firstUpperCase() ?? "")
                          .color(selectedId == reasons?[index].id
                              ? context.color.tertiaryColor
                              : context.color.textColorDark),
                    ),
                  ),
                );
              },
            ),
            if (selectedId.isNegative)
              Padding(
                padding: EdgeInsets.only(
                    bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                    left: 0,
                    right: 0),
                child: TextField(
                  maxLines: null,
                  controller: _reportmessageController,
                  cursorColor: context.color.tertiaryColor,
                  decoration: InputDecoration(
                      hintText: "writeReasonHere".translate(context),
                      focusColor: context.color.tertiaryColor,
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: context.color.tertiaryColor))),
                ),
              ),
            SizedBox(
              height: 14,
            ),
            BlocConsumer<PropertyReportCubit, PropertyReportState>(
                listener: (context, state) {
              if (state is PropertyReportInSuccess) {
                HelperUtils.showSnackBarMessage(context, state.responseMessage);

                Navigator.pop(context);
              }
            }, builder: (context, state) {
              return Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaterialButton(
                      height: 40,
                      minWidth: 104.rw(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: context.color.borderColor,
                            width: 1.5,
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("cancelLbl".translate(context))
                          .color(context.color.tertiaryColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MaterialButton(
                      height: 40,
                      minWidth: 104.rw(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      color: context.color.tertiaryColor,
                      onPressed: () async {
                        if (selectedId.isNegative) {
                          context.read<PropertyReportCubit>().report(
                              property_id: widget.propertyId,
                              reason_id: selectedId,
                              message: _reportmessageController.text);
                        } else {
                          context.read<PropertyReportCubit>().report(
                              property_id: widget.propertyId,
                              reason_id: selectedId);
                        }
                      },
                      child: (state is PropertyReportInProgress)
                          ? UiUtils.progress(width: 24, height: 24)
                          : Text("report".translate(context))
                              .color(context.color.buttonColor),
                    ),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
