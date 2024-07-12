// part of "../chat_widget.dart";
//
// class LinkPreviw extends StatefulWidget {
//   final String link;
//   final AsyncSnapshot snapshot;
//   const LinkPreviw({
//     super.key,
//     required this.snapshot,
//     required this.link,
//   });
//
//   @override
//   State<LinkPreviw> createState() => _LinkPreviwState();
// }
//
// class _LinkPreviwState extends State<LinkPreviw> {
//   final ValueNotifier<bool> _errorChecker = ValueNotifier<bool>(false);
//
//   @override
//   void dispose() {
//     _errorChecker.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         await launchUrl(Uri.parse(widget.link),
//             mode: LaunchMode.externalApplication);
//       },
//       child: Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4),
//             color: context.color.tertiaryColor),
//         child: Padding(
//           padding: const EdgeInsets.all(3.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ValueListenableBuilder(
//                   valueListenable: _errorChecker,
//                   builder: (context, value, child) {
//                     if (value == true) {
//                       return const SizedBox.shrink();
//                     }
//
//                     return AspectRatio(
//                       aspectRatio: 1 / 0.5,
//                       child: Image.network(
//                         (widget.snapshot.data as Metadata).image!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           WidgetsBinding.instance
//                               .addPostFrameCallback((timeStamp) {
//                             _errorChecker.value = true;
//                           });
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     );
//                   }),
//               Text((widget.snapshot.data as Metadata).title ?? "")
//                   .color(context.color.primaryColor.withOpacity(0.9))
//                   .size(context.font.small),
//               Text((widget.snapshot.data as Metadata).desc ?? "")
//                   .setMaxLines(lines: 1)
//                   .color(context.color.primaryColor.withOpacity(0.8))
//                   .size(context.font.smaller)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
