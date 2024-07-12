// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchProjectsState {}

class FetchProjectsInitial extends FetchProjectsState {}

class FetchProjectsInProgress extends FetchProjectsState {}

class FetchProjectsSuccess extends FetchProjectsState {
  final List<ProjectModel> projects;
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;

  FetchProjectsSuccess({
    required this.projects,
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
  });

  FetchProjectsSuccess copyWith({
    List<ProjectModel>? projects,
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
  }) {
    return FetchProjectsSuccess(
      projects: projects ?? this.projects,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchProjectsFailure extends FetchProjectsState {
  final dynamic errorMessage;

  FetchProjectsFailure(this.errorMessage);
}

class FetchProjectsCubit extends Cubit<FetchProjectsState> {
  FetchProjectsCubit() : super(FetchProjectsInitial());
  final ProjectRepository _projectRepository = ProjectRepository();
  Future<void> fetchProjects() async {
    try {
      emit(FetchProjectsInProgress());
      DataOutput<ProjectModel> result =
          await _projectRepository.getProjects(offset: 0);
      emit(FetchProjectsSuccess(
          projects: result.modelList,
          offset: 0,
          isLoadingMore: false,
          total: result.total,
          hasError: false));
    } catch (e) {
      emit(FetchProjectsFailure(e));
    }
  }

  bool hasMore() {
    if (state is FetchProjectsSuccess) {
      return (state as FetchProjectsSuccess).projects.length <
          (state as FetchProjectsSuccess).total;
    }
    return false;
  }

  isProjectEmpty() {
    if (state is FetchProjectsSuccess) {
      return (state as FetchProjectsSuccess).projects.isEmpty;
    }
    return true;
  }

  fetchMoreProjects() async {
    if (state is FetchProjectsInProgress) {
      return;
    }
    try {
      if (state is FetchProjectsSuccess) {
        emit((state as FetchProjectsSuccess).copyWith(isLoadingMore: true));
        DataOutput<ProjectModel> result = await _projectRepository.getProjects(
          offset: (state as FetchProjectsSuccess).projects.length,
        );

        List<ProjectModel> projects = (state as FetchProjectsSuccess).projects;
        projects.addAll(result.modelList);

        emit(FetchProjectsSuccess(
            projects: projects,
            isLoadingMore: false,
            hasError: false,
            offset: projects.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchProjectsSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }
}
