import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchMyProjectsListState {}

class FetchMyProjectsListInitial extends FetchMyProjectsListState {}

class FetchMyProjectsListInProgress extends FetchMyProjectsListState {}

class FetchMyProjectsListSuccess extends FetchMyProjectsListState {
  final bool isLoadingMore;
  final bool hasError;
  final int total;
  final List<ProjectModel> projects;
  final int offset;

  FetchMyProjectsListSuccess({
    required this.isLoadingMore,
    required this.hasError,
    required this.total,
    required this.projects,
    required this.offset,
  });

  FetchMyProjectsListSuccess copyWith({
    bool? isLoadingMore,
    bool? hasError,
    int? total,
    List<ProjectModel>? projects,
    int? offset,
  }) {
    return FetchMyProjectsListSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      total: total ?? this.total,
      projects: projects ?? this.projects,
      offset: offset ?? this.offset,
    );
  }
}

class FetchMyProjectsListFail extends FetchMyProjectsListState {
  final dynamic error;
  FetchMyProjectsListFail(this.error);
}

class FetchMyProjectsListCubit extends Cubit<FetchMyProjectsListState> {
  FetchMyProjectsListCubit() : super(FetchMyProjectsListInitial());
  final ProjectRepository _projectRepository = ProjectRepository();

  void fetch() async {
    try {
      emit(FetchMyProjectsListInProgress());
      DataOutput<ProjectModel> dataOutput =
          await _projectRepository.getMyProjects(offset: 0);

      emit(FetchMyProjectsListSuccess(
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: dataOutput.total,
          projects: dataOutput.modelList));
    } catch (e) {
      emit(FetchMyProjectsListFail(e));
    }
  }

  delete(int id) {
    if (state is FetchMyProjectsListSuccess) {
      int indexWhere = (state as FetchMyProjectsListSuccess)
          .projects
          .indexWhere((element) => element.id == id);
      (state as FetchMyProjectsListSuccess).projects.removeAt(indexWhere);
      emit((state as FetchMyProjectsListSuccess)
          .copyWith(projects: (state as FetchMyProjectsListSuccess).projects));
    }
  }

  bool hasMore() {
    if (state is FetchMyProjectsListSuccess) {
      return (state as FetchMyProjectsListSuccess).projects.length <
          (state as FetchMyProjectsListSuccess).total;
    }
    return false;
  }

  void update(ProjectModel model) {
    if (state is FetchMyProjectsListSuccess) {
      int indexWhere = (state as FetchMyProjectsListSuccess)
          .projects
          .indexWhere((element) => element.id == model.id);
      if (indexWhere.isNegative) {
        (state as FetchMyProjectsListSuccess).projects.add(model);
      } else {
        (state as FetchMyProjectsListSuccess).projects[indexWhere] = model;
      }
      emit((state as FetchMyProjectsListSuccess)
          .copyWith(projects: (state as FetchMyProjectsListSuccess).projects));
    }
  }

  void fetchMore() async {
    if (state is FetchMyProjectsListInProgress) {
      return;
    }
    try {
      if (state is FetchMyProjectsListSuccess) {
        emit((state as FetchMyProjectsListSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<ProjectModel> result =
            await _projectRepository.getMyProjects(
          offset: (state as FetchMyProjectsListSuccess).projects.length,
        );

        List<ProjectModel> projects =
            (state as FetchMyProjectsListSuccess).projects;
        projects.addAll(result.modelList);

        emit(FetchMyProjectsListSuccess(
            projects: projects,
            isLoadingMore: false,
            hasError: false,
            offset: projects.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchMyProjectsListSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }
}
