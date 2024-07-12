import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../helper_utils.dart';
import '../../ui_utils.dart';

class PurchasePackage {
  Future<void> purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          context.read<FetchSystemSettingsCubit>().fetchSettings(
                isAnonymouse: false,
                forceRefresh: true,
              );
          context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

          HelperUtils.showSnackBarMessage(
              context, UiUtils.translate(context, "success"),
              type: MessageType.success, messageDuration: 5);

          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.translate(context, "purchaseFailed"),
          type: MessageType.error);
    }
  }
}
