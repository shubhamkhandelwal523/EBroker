import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/data/repositories/articles_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/deep_link/blueprint.dart';
import 'package:flutter/material.dart';

class NativeDeepLinkManager extends NativeDeepLinkUtility {
  @override
  void handle(Uri uri, ProcessResult? result) {
    if (uri.toString().startsWith("http") ||
        uri.toString().startsWith("https")) {
      if (result?.result is PropertyModel) {
        Navigator.pushReplacementNamed(
          Constant.navigatorKey.currentContext!,
          Routes.propertyDetails,
          arguments: {
            'propertyData': result?.result as PropertyModel,
            'propertiesList': []
          },
        );
      }

      if (result?.result is ArticleModel) {
        Navigator.pushReplacementNamed(
          Constant.navigatorKey.currentContext!,
          Routes.articleDetailsScreenRoute,
          arguments: {
            "model": result?.result,
          },
        );
      }
    }
  }

  @override
  Future<ProcessResult?> process(Uri uri) async {
    //
    if (uri.pathSegments.contains("properties-details")) {
      String slug = uri.pathSegments[1];
      PropertyModel propertyModel =
          await PropertyRepository().fetchBySlug(slug);
      return ProcessResult<PropertyModel>(propertyModel);
    }
    if (uri.pathSegments.contains("article-details")) {
      String slug = uri.pathSegments[1];
      ArticleModel articleModel =
          await ArticlesRepository().fetchArticlesBySlugId(slug);

      return ProcessResult<ArticleModel>((articleModel));
    }

    return null;
  }
}

class NativeLinkWidget extends StatefulWidget {
  final RouteSettings settings;
  const NativeLinkWidget({super.key, required this.settings});
  static BlurredRouter render(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return Scaffold(
          body: NativeLinkWidget(
            settings: settings,
          ),
        );
      },
    );
  }

  @override
  State<NativeLinkWidget> createState() => _NativeLinkWidgetState();
}

class _NativeLinkWidgetState extends State<NativeLinkWidget> {
  @override
  void initState() {
    super.initState();

    NativeDeepLinkManager().handleLink(widget.settings.name ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.tertiaryColor,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text("Please Wait...")
          ],
        ),
      ),
    );
  }
}
