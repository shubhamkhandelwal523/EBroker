// import 'package:ebroker/ui/screens/Dashboard/Cubits/property_list_cubit_dashboard.dart';
// import 'package:ebroker/ui/screens/Dashboard/Repository/dashboard_repository.dart';
// import 'package:ebroker/ui/screens/Dashboard/property_list.dart';
// import 'package:ebroker/ui/screens/Dashboard/widgets/mTabbar.dart';
// import 'package:ebroker/ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
// import 'package:ebroker/utils/Extensions/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../utils/AppIcon.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key? key}) : super(key: key);
//   static Route route(RouteSettings settings) {
//     return BlurredRouter(
//       builder: (context) {
//         return BlocProvider<DashboardPropertyListCubit>(
//             create: (context) {
//               return DashboardPropertyListCubit();
//             },
//             child: DashboardScreen());
//       },
//     );
//   }
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen>
//     with SingleTickerProviderStateMixin {
//   final PageController _pageController = PageController();
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           backgroundColor: context.color.secondaryColor,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Material(
//                 elevation: 3,
//                 child: Container(
//                   color: context.color.primaryColor,
//                   child: Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: 150,
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: CountsCard(
//                                   number: "120",
//                                   title: "Total Property",
//                                   icon: AppIcons.properties,
//                                   onTap: () {},
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 5,
//                               ),
//                               Expanded(
//                                 child: CountsCard(
//                                   number: "120",
//                                   title: "Total Views",
//                                   icon: AppIcons.properties,
//                                   materialIcon: Icons.remove_red_eye,
//                                   onTap: () {},
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         SizedBox(
//                           height: 150,
//                           width: context.screenWidth,
//                           child: CountsCard(
//                             number: "120",
//                             icon: AppIcons.favorites,
//                             // materialIcon: Icons.favorite,
//                             title: "Total Favorites",
//                             onTap: () {},
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               SizedBox(
//                 height: 40,
//                 child: MTabBar(
//                     onChange: (page) {
//                       DashboardRepositoryIMPL().fetch(All(), Parameter(0));
//                     },
//                     controller: _pageController,
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     activeTabDecoration: RoundedMTabDecoration(
//                         buttonColor: context.color.tertiaryColor,
//                         borderColor: widgetsBorderColorLight,
//                         tColor: context.color.buttonColor,
//                         radius: 10),
//                     deactiveTabDecoration: RoundedMTabDecoration(
//                       borderColor: Colors.transparent,
//                       radius: 10,
//                     ),
//                     tabs: [
//                       MTab(title: "All"),
//                       MTab(title: "Sell"),
//                       MTab(title: "Rent"),
//                       MTab(title: "Sold"),
//                       MTab(title: "Rented"),
//                       MTab(title: "Featured"),
//                       // MTab(title: "Featured"),
//                     ]),
//               ),
//               SizedBox(
//                 height: 12,
//               ),
//               Expanded(
//                 child: MTabView(controller: _pageController, pages: [
//                   BlocProvider(
//                       create: (context) => DashboardPropertyListCubit(),
//                       child: PropertyListDashboard(parameters: All())),
//                   BlocProvider(
//                       create: (context) => DashboardPropertyListCubit(),
//                       child: PropertyListDashboard(parameters: Sell())),
//                   BlocProvider(
//                       create: (context) => DashboardPropertyListCubit(),
//                       child: PropertyListDashboard(parameters: Rent())),
//                   BlocProvider(
//                       create: (context) => DashboardPropertyListCubit(),
//                       child: PropertyListDashboard(parameters: Sold())),
//                   BlocProvider(
//                       create: (context) => DashboardPropertyListCubit(),
//                       child: PropertyListDashboard(parameters: Rented())),
//                 ]),
//               )
//             ],
//           )),
//     );
//   }
// }
//
// class CountsCard extends StatelessWidget {
//   final String title;
//   final String number;
//   final String icon;
//   final IconData? materialIcon;
//
//   final void Function() onTap;
//
//   const CountsCard({
//     super.key,
//     required this.title,
//     required this.number,
//     required this.onTap,
//     required this.icon,
//     this.materialIcon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         onTap.call();
//       },
//       child: Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: context.color.secondaryColor,
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () {},
//             child: Container(
//               decoration: BoxDecoration(
//                   border:
//                       Border.all(color: context.color.borderColor, width: 1.5),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Row(
//                       children: [
//                         if (materialIcon != null) ...[
//                           Icon(materialIcon!,
//                               size: context.font.xxLarge,
//                               color: context.color.tertiaryColor)
//                         ] else ...[
//                           SvgPicture.asset(
//                             icon,
//                             height: context.font.xxLarge,
//                             width: context.font.xxLarge,
//                             color: context.color.tertiaryColor,
//                           ),
//                         ],
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         Text(number).size(context.font.xxLarge),
//                       ],
//                     ),
//                     Text(title).size(context.font.large),
//                     const Divider(),
//                     const Row(
//                       children: [
//                         Text("VIEW"),
//                         Spacer(),
//                         Icon(Icons.chevron_right)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
