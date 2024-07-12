// import 'package:flutter/material.dart';
// import 'package:palette_generator/palette_generator.dart';
//
// class GradientedShadowImage extends StatefulWidget {
//   final String imageUrl;
//
//   GradientedShadowImage({required this.imageUrl});
//
//   @override
//   _GradientedShadowImageState createState() => _GradientedShadowImageState();
// }
//
// class _GradientedShadowImageState extends State<GradientedShadowImage> {
//   PaletteGenerator? _paletteGenerator;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPalette();
//   }
//
//   Future<void> _loadPalette() async {
//     final imageProvider = NetworkImage(widget.imageUrl);
//     _paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: _paletteGenerator?.dominantColor?.color.withOpacity(0.4) ??
//                 Colors.transparent,
//             blurRadius: 8.0,
//             spreadRadius: 6.0,
//           ),
//         ],
//         gradient: LinearGradient(
//           colors: [
//             _paletteGenerator?.dominantColor?.color ?? Colors.transparent,
//             Colors.transparent,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Image.network(widget.imageUrl,width: 200,height: 200,),
//     );
//   }
// }
