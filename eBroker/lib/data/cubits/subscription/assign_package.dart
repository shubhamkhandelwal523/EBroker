import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class AssignInAppPackageState {}

class AssignInAppPackageInitial extends AssignInAppPackageState {}

class AssignInAppPackageInProgress extends AssignInAppPackageState {}

class AssignInAppPackageSuccess extends AssignInAppPackageState {}

class AssignInAppPackageFail extends AssignInAppPackageState {
  final dynamic error;
  AssignInAppPackageFail(this.error);
}

class AssignInAppPackageCubit extends Cubit<AssignInAppPackageState> {
  AssignInAppPackageCubit() : super(AssignInAppPackageInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  ///
  ///This will assign in app product
  void assign({required String packageId, required String productId}) async {
    try {
      emit(AssignInAppPackageInProgress());
      await _subscriptionRepository.assignPackage(
        packageId: packageId,
        productId: productId,
      );
      emit(AssignInAppPackageSuccess());
    } catch (e) {
      emit(AssignInAppPackageFail(e));
    }
  }
}
