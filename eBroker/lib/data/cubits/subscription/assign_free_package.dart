import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class AssignFreePackageState {}

class AssignFreePackageInitial extends AssignFreePackageState {}

class AssignFreePackageInProgress extends AssignFreePackageState {}

class AssignFreePackageSuccess extends AssignFreePackageState {}

class AssignFreePackageFail extends AssignFreePackageState {
  final dynamic error;
  AssignFreePackageFail(this.error);
}

class AssignFreePackageCubit extends Cubit<AssignFreePackageState> {
  AssignFreePackageCubit() : super(AssignFreePackageInitial());

  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  void assign(int packageId) async {
    try {
      emit(AssignFreePackageInProgress());
      await _subscriptionRepository.assignFreePackage(packageId);
      emit(AssignFreePackageSuccess());
    } catch (e) {
      emit(AssignFreePackageFail(e.toString()));
    }
  }
}
