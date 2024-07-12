import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/api.dart';

abstract class DeleteProjectState {}

class DeleteProjectInitial extends DeleteProjectState {}

class DeleteProjectInProgress extends DeleteProjectState {}

class DeleteProjectSuccess extends DeleteProjectState {
  final int id;
  DeleteProjectSuccess(this.id);
}

class DeleteProjectFail extends DeleteProjectState {
  final dynamic error;
  DeleteProjectFail(this.error);
}

class DeleteProjectCubit extends Cubit<DeleteProjectState> {
  DeleteProjectCubit() : super(DeleteProjectInitial());

  delete(int id) async {
    try {
      emit(DeleteProjectInProgress());
      await Api.post(url: Api.deleteProject, parameter: {"id": id});
      emit(DeleteProjectSuccess(id));
    } catch (e) {
      emit(DeleteProjectFail(e));
    }
  }
}
