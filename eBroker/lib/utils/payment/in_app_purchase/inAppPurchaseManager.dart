import 'package:ebroker/data/cubits/subscription/assign_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseManager {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  String? packageId;
  String? productId;
  Future<ProductDetails> getProductByProductId(String productId) async {
    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails({productId});
    return productDetailsResponse.productDetails.first;
  }

  void onSuccessfulPurchase(
      BuildContext context, PurchaseDetails purchase) async {
    purchaseCompleteDialog(context);
  }

  void onPurchaseCancel(BuildContext context, PurchaseDetails purchase) async {
    paymentCancelDialog(context);
  }

  void onErrorPurchase(BuildContext context, PurchaseDetails purchase) async {
    paymentErrorDialog(context, purchase);
  }

  void onPendingPurchase(PurchaseDetails purchase) async {
    await _inAppPurchase.completePurchase(purchase);
  }

  void onRestoredPurchase(PurchaseDetails purchase) async {}
  Future completePending(event) async {
    for (var _purchaseDetails in event) {
      if (_purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(_purchaseDetails);
      }
    }
  }

  static getPendings() {
    _inAppPurchase.purchaseStream.listen((event) {
      ;

      print("GET PENDINGS ${event.toList()}");
    });
  }

  void listenIAP(BuildContext context) {
    _inAppPurchase.purchaseStream.listen((event) async {
      await completePending(event);
      for (PurchaseDetails inAppPurchaseEvent in event) {
        if (inAppPurchaseEvent.error != null) {}
        if (inAppPurchaseEvent.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(inAppPurchaseEvent);
        }
        Future.delayed(
          Duration.zero,
          () {
            if (inAppPurchaseEvent.status == PurchaseStatus.purchased) {
              onSuccessfulPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.canceled) {
              onPurchaseCancel(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.error) {
              onErrorPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.pending) {
              onPendingPurchase(inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.restored) {
              onRestoredPurchase(inAppPurchaseEvent);
            }
          },
        );
      }
    });
  }

  Future<void> buy(String productId, String packageId) async {
    bool _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      ProductDetails productDetails = await getProductByProductId(productId);
      // _inAppPurchase._inAppPurchase.completePurchase();
      this.packageId = packageId;
      this.productId = productId;
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
    }
  }

  void purchaseCompleteDialog(BuildContext context) async {
    context
        .read<AssignInAppPackageCubit>()
        .assign(packageId: this.packageId!, productId: this.productId!);
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "Purchase completed",
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const Text("Your purchase has completed successfully"),
      ),
    );
  }

  void paymentCancelDialog(BuildContext context) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "Purchase canceled",
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const Text("Your purchase has been canceled"),
      ),
    );
  }

  void paymentErrorDialog(BuildContext context, PurchaseDetails purchase) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "Purchase error",
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: Text("${purchase.error?.message}"),
      ),
    );
  }
}
