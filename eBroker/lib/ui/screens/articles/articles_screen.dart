import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

import '../../../data/model/article_model.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ArticlesScreen();
      },
    );
  }

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    context.read<FetchArticlesCubit>().fetchArticles();
    _pageScrollController.addListener(pageScrollListen);
    super.initState();
  }

  void pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchArticlesCubit>().hasMoreData()) {
        context.read<FetchArticlesCubit>().fetchArticlesMore();
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        context.read<FetchArticlesCubit>().fetchArticles();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: UiUtils.translate(
            context,
            "articles",
          ),
        ),
        body: BlocBuilder<FetchArticlesCubit, FetchArticlesState>(
          builder: (context, state) {
            if (state is FetchArticlesInProgress) {
              return buildArticlesShimmer();
            }
            if (state is FetchArticlesFailure) {
              if (state.errorMessage is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchArticlesCubit>().fetchArticles();
                  },
                );
              }

              return const SomethingWentWrong();
            }
            if (state is FetchArticlesSuccess) {
              if (state.articlemodel.isEmpty) {
                return const NoDataFound();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        controller: _pageScrollController,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.articlemodel.length,
                        itemBuilder: (context, index) {
                          ArticleModel article = state.articlemodel[index];

                          return buildArticleCard(context, article);

                          // return article(state, index);
                        }),
                  ),
                  if (state.isLoadingMore) const CircularProgressIndicator(),
                  if (state.loadingMoreError)
                    Text(UiUtils.translate(context, "somethingWentWrng"))
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildArticleCard(BuildContext context, ArticleModel article) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.articleDetailsScreenRoute,
            arguments: {
              "model": article,
            },
          );
        },
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            // height: 290,
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              border: Border.all(
                width: 1.5,
                color: context.color.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(12.0, 12, 12, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: UiUtils.getImage(
                      article.image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(12.0, 12, 12, 6),
                  child: Text(
                    (article.title ?? "").firstUpperCase(),
                  )
                      .color(
                        context.color.textColorDark,
                      )
                      .size(context.font.normal)
                      .setMaxLines(
                        lines: 2,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Text(stripHtmlTags(article.description ?? "").trim())
                      .setMaxLines(lines: 3)
                      .size(context.font.small)
                      .color(context.color.textLightColor),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4, 12, 6),
                  child: Text(
                    article.date == null ? "" : article.date.toString(),
                  )
                      .size(context.font.smaller)
                      .color(context.color.textLightColor),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  Widget buildArticlesShimmer() {
    return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 287.rh(context),
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(
                      width: double.infinity,
                      height: 160.rh(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 100.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 160.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 150.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Container article(FetchArticlesSuccess state, int index) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: double.infinity,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(state.articlemodel[index].title!).color(Colors.black),
              const Divider(),
              if (state.articlemodel[index].image != "") ...[
                Image.network(state.articlemodel[index].image!)
              ],
              const Divider(),
              Html(data: state.articlemodel[index].description!)
            ],
          ),
        ),
      ),
    );
  }
}
