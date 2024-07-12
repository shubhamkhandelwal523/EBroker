// import 'package:ebroker/ui/screens/Dashboard/Cubits/property_list_cubit_dashboard.dart';
// import 'package:ebroker/ui/screens/Dashboard/Models/dashboard_property.dart';
// import 'package:ebroker/ui/screens/Dashboard/Repository/dashboard_repository.dart';
// import 'package:ebroker/ui/screens/widgets/Erros/no_data_found.dart';
// import 'package:ebroker/ui/screens/widgets/shimmerLoadingContainer.dart';
// import 'package:ebroker/utils/Extensions/extensions.dart';
// import 'package:ebroker/utils/string_extenstion.dart';
// import 'package:ebroker/utils/ui_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../app/routes.dart';
// import '../../../data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
// import '../../../data/cubits/property/delete_property_cubit.dart';
// import '../../../data/model/category.dart';
// import '../../../utils/AppIcon.dart';
// import '../../../utils/constant.dart';
// import '../../../utils/helper_utils.dart';
// import '../widgets/blurred_dialoge_box.dart';
//
// class PropertyListDashboard extends StatefulWidget {
//   final DashboardPropertyParameters parameters;
//   const PropertyListDashboard({Key? key, required this.parameters})
//       : super(key: key);
//
//   @override
//   State<PropertyListDashboard> createState() => _PropertyListDashboardState();
// }
//
// class _PropertyListDashboardState extends State<PropertyListDashboard>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   void initState() {
//     context.read<DashboardPropertyListCubit>().fetch(widget.parameters);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     return BlocBuilder<DashboardPropertyListCubit, DashboardPropertyListState>(
//         builder: (context, state) {
//       if (state is DashboardPropertyListInProgress) {
//         return ListView.builder(
//           itemCount: 5,
//           padding: const EdgeInsets.all(15),
//           itemBuilder: (context, index) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: 3),
//               child: CustomShimmer(
//                 height: 100,
//               ),
//             );
//           },
//         );
//       }
//       if (state is DashboardPropertyListSuccess) {
//         if (state.list.isEmpty) {
//           return const SizedBox(
//             width: 100,
//             height: 100,
//             child: NoDataFound(
//               height: 100,
//             ),
//           );
//         }
//         return ListView.builder(
//             itemCount: state.list.length,
//             itemBuilder: (context, index) {
//               DashboardPropertyModal model = state.list[index];
//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                 child: Container(
//                   height: 65,
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           model.titleImage ?? "",
//                           width: 65,
//                           height: 65,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 8,
//                       ),
//                       Expanded(
//                         flex: 5,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Text((model.title.toString().firstUpperCase()) ??
//                                     "")
//                                 .setMaxLines(lines: 1),
//                             Text((model.description
//                                         .toString()
//                                         .firstUpperCase()) ??
//                                     "")
//                                 .size(context.font.small)
//                                 .setMaxLines(lines: 1),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.remove_red_eye,
//                                   color: context.color.textLightColor,
//                                   size: (context.font.small),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 Text(model.totalView.toString().priceFormate())
//                                     .size(context.font.small),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 Icon(
//                                   Icons.favorite,
//                                   color: context.color.textLightColor,
//                                   size: (context.font.small),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 Text(model.totalFavouriteUsers
//                                         .toString()
//                                         .priceFormate())
//                                     .size(context.font.small)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                           flex: 5,
//                           child: Container(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 IconButton(
//                                     constraints: BoxConstraints(),
//                                     onPressed: () {
//                                       context
//                                           .read<FetchOutdoorFacilityListCubit>()
//                                           .fetch();
//                                       Constant.addProperty.addAll({
//                                         "category": Category(
//                                           category: model.category!.category,
//                                           id: model.category?.id!.toString(),
//                                           image: model.category?.image,
//                                           parameterTypes: {
//                                             "parameters": model.parameters
//                                                 ?.map((e) => e.toMap())
//                                                 .toList()
//                                           },
//                                         )
//                                       });
//                                       // log("GOING THROW IT ${property?.parameters}");
//                                       Navigator.pushNamed(context,
//                                           Routes.addPropertyDetailsScreen,
//                                           arguments: {
//                                             "details": {
//                                               "id": model.id,
//                                               "catId": model.category?.id,
//                                               "propType": model.properyType,
//                                               "name": model.title,
//                                               "desc": model.description,
//                                               "city": model.city,
//                                               "state": model.state,
//                                               "country": model.country,
//                                               "latitude": model.latitude,
//                                               "longitude": model.longitude,
//                                               "address": model.address,
//                                               "client": model.clientAddress,
//                                               "price": model.price,
//                                               'parms': model.parameters,
//                                               "images": model.gallery
//                                                   ?.map((e) => e.imageUrl)
//                                                   .toList(),
//                                               "rentduration":
//                                                   model.rentduration,
//                                               "assign_facilities":
//                                                   model.assignedOutdoorFacility,
//                                               "titleImage": model.titleImage
//                                             }
//                                           });
//                                     },
//                                     icon: Icon(
//                                       Icons.edit,
//                                       // size: 16,
//                                       color: context.color.textLightColor,
//                                     )),
//                                 IconButton(
//                                     constraints: BoxConstraints(),
//                                     // padding: EdgeInsets.zero,
//                                     onPressed: () {},
//                                     // splashRadius: 15,
//                                     icon: SvgPicture.asset(
//                                       AppIcons.promoted,
//                                       // width: 16,
//                                       // height: 16,
//                                       color: context.color.textLightColor,
//                                     )),
//                                 IconButton(
//                                     constraints: BoxConstraints(),
//                                     // padding: EdgeInsets.zero,
//                                     autofocus: false,
//                                     onPressed: () async {
//                                       var delete =
//                                           await UiUtils.showBlurredDialoge(
//                                         context,
//                                         dialoge: BlurredDialogBox(
//                                           title: UiUtils.translate(
//                                             context,
//                                             "deleteBtnLbl",
//                                           ),
//                                           content: Text(
//                                             UiUtils.translate(context,
//                                                 "deletepropertywarning"),
//                                           ),
//                                         ),
//                                       );
//                                       if (delete == true) {
//                                         Future.delayed(
//                                           Duration.zero,
//                                           () {
//                                             if (Constant.isDemoModeOn) {
//                                               HelperUtils.showSnackBarMessage(
//                                                   context,
//                                                   UiUtils.translate(context,
//                                                       "thisActionNotValidDemo"));
//                                             } else {
//                                               context
//                                                   .read<DeletePropertyCubit>()
//                                                   .delete(model!.id!);
//                                             }
//                                           },
//                                         );
//                                       }
//                                     },
//                                     // splashRadius: 15,
//                                     icon: SvgPicture.asset(
//                                       AppIcons.delete,
//                                       // width: 16,
//                                       // height: 16,
//                                       color: context.color.textLightColor,
//                                     )),
//                               ],
//                             ),
//                           ))
//                     ],
//                   ),
//                 ),
//               );
//             });
//       }
//       return Container();
//     });
//   }
//
//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }
