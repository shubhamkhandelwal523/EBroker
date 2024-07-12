import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../../home/widgets/project_card_horizontal.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ProjectListScreen();
      },
    );
  }

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<FetchMyProjectsListCubit>().fetch();

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchMyProjectsListCubit>().hasMore()) {
          context.read<FetchMyProjectsListCubit>().fetchMore();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.translate(context, "myProjects")),
      body: BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
        builder: (context, state) {
          if (state is FetchMyProjectsListInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyProjectsListFail) {
            if (state.error is NoInternetConnectionError) {
              return NoInternet(onRetry: () {
                context.read<FetchMyProjectsListCubit>().fetch();
              });
            }
            return const SomethingWentWrong();
          }
          if (state is FetchMyProjectsListSuccess) {
            if (state.projects.isEmpty) {
              return const NoDataFound();
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: state.projects.length,
                  padding: const EdgeInsets.all(14),
                  itemBuilder: (context, index) {
                    ProjectModel project = state.projects[index];

                    return ProjectHorizontalCard(
                      project: project,
                    );
                  },
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
            // return ProjectCard(title: "Hello",categoryIcon: ,);
          }
          if (state is FetchMyProjectsListFail) {
            return Center(
              child: Text(state.error.toString()),
            );
          }

          return Container();
        },
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String url;
  final String title;
  final String description;
  final String categoryIcon;
  final String categoryName;

  final String status;
  const ProjectCard({
    super.key,
    required this.categoryName,
    required this.url,
    required this.title,
    required this.description,
    required this.categoryIcon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
          width: context.screenWidth * 0.9,
          height: 220,
          child: LayoutBuilder(builder: (context, c) {
            return Stack(children: [
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                      width: c.maxWidth,
                      height: c.maxHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: DecorationImage(
                            image: NetworkImage(url), fit: BoxFit.fitWidth),
                      ))),
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                      width: c.maxWidth,
                      height: c.maxHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.1)
                            ]),
                      ))),
              PositionedDirectional(
                bottom: 10,
                start: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.left,
                    )
                        .size(context.font.larger + 2)
                        .color(context.color.buttonColor)
                        .setMaxLines(lines: 1),
                    Text(
                      description,
                      textAlign: TextAlign.left,
                    )
                        .size(context.font.small + 1)
                        .color(context.color.buttonColor)
                        .setMaxLines(lines: 1),
                  ],
                ),
              ),
              Positioned(
                  top: 9,
                  left: 14,
                  child: Row(
                    children: [
                      SvgPicture.network(
                        categoryIcon,
                        color: context.color.tertiaryColor.brighten(20),
                        width: 18,
                        height: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          categoryName,
                          textAlign: TextAlign.left,
                        ).size(13).color(context.color.buttonColor),
                      ),
                    ],
                  )),
              Positioned(
                  top: 12,
                  right: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: context.color.buttonColor.withOpacity(0.8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 7),
                      child: Text(
                        status.translate(context),
                        textAlign: TextAlign.left,
                      )
                          .size(context.font.smaller)
                          .color(context.color.blackColor),
                    ),
                  )),
            ]);
          })),
    );
  }
}
