import 'package:dio/dio.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class NetworkToLocalSvg {
  final Dio dio = Dio();
  Future<String?> convert(String url) async {
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw "Error while load svg";
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget svg(String url, {Color? color, double? width, double? height}) {
    if (Hive.box(HiveKeys.svgBox).containsKey(url) &&
        Hive.box(HiveKeys.svgBox).get(url).toString().isNotEmpty) {
      return SvgPicture.string(
        Hive.box(HiveKeys.svgBox).get(url) ?? "",
        color: color,
        width: width,
        height: height,
      );
    } else {
      return FutureBuilder<String?>(
        future: convert(url),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (Hive.box(HiveKeys.svgBox).containsKey(url)) {
            if (Hive.box(HiveKeys.svgBox).get(url) == null) {
              Hive.box(HiveKeys.svgBox).put(url, snapshot.data);
              return SvgPicture.string(
                snapshot.data ?? "",
                color: color,
                width: width,
                height: height,
              );
            } else {
              return SvgPicture.string(
                Hive.box(HiveKeys.svgBox).get(url) ?? "",
                color: color,
                width: width,
                height: height,
              );
            }
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              Hive.box(HiveKeys.svgBox).put(url, snapshot.data);
              return SvgPicture.string(
                snapshot.data ?? "",
                color: color,
                width: width,
                height: height,
              );
            } else {
              return Container();
            }
          }
        },
      );
    }
  }
}

class _SVGBUILDER extends StatefulWidget {
  const _SVGBUILDER({super.key});

  @override
  State<_SVGBUILDER> createState() => _SVGBUILDERState();
}

class _SVGBUILDERState extends State<_SVGBUILDER> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
