import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:shellafood_delivery/features/notification/controllers/notification_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';

/// شيت التسليم — يصوّر الكابتن الطلب ثم يطلب رمز التسليم من العميل
class DeliveryProofSheetWidget extends StatelessWidget {
  final OrderModel orderModel;
  const DeliveryProofSheetWidget({super.key, required this.orderModel});

  void _onConfirm(OrderController orderController) {
    final bool cod = orderModel.paymentMethod == 'cash_on_delivery';
    final bool partialPay = orderModel.paymentMethod == 'partial_payment';
    final bool verify =
        Get.find<SplashController>().configModel?.orderDeliveryVerification ??
            false;

    final double amount =
        (partialPay && (orderModel.payments?.length ?? 0) > 1)
            ? orderModel.payments![1].amount!.toDouble()
            : (orderModel.orderAmount ?? 0);

    final bool hasCodInPartial = partialPay &&
        (orderModel.payments?.length ?? 0) > 1 &&
        orderModel.payments![1].paymentMethod == 'cash_on_delivery';

    if (verify) {
      Get.find<NotificationController>()
          .sendDeliveredNotification(orderModel.id);
      Get.bottomSheet(
        VerifyDeliverySheetWidget(
          currentOrderModel: orderModel,
          verify: true,
          orderAmount: amount,
          cod: cod || hasCodInPartial,
        ),
        isScrollControlled: true,
      ).then((isSuccess) {
        if (isSuccess == true && (cod || hasCodInPartial)) {
          Get.bottomSheet(
            CollectMoneyDeliverySheetWidget(
              currentOrderModel: orderModel,
              verify: verify,
              orderAmount: amount,
              cod: cod || hasCodInPartial,
            ),
            isScrollControlled: true,
          );
        }
      });
    } else if (cod) {
      Get.bottomSheet(
        VerifyDeliverySheetWidget(
          currentOrderModel: orderModel,
          verify: false,
          orderAmount: amount,
          cod: true,
          isSetOtp: false,
        ),
        isScrollControlled: true,
      );
    } else {
      orderController.updateOrderStatus(
        orderModel,
        AppConstants.delivered,
        back: false,
        gotoDashboard: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeLarge,
        right: Dimensions.paddingSizeLarge,
        top: Dimensions.paddingSizeLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            Dimensions.paddingSizeLarge,
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        final photos = orderController.pickedPrescriptions;
        final hasPhoto = photos.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle bar
            Center(
              child: Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).disabledColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            // عنوان
            Text('تأكيد التسليم',
                style:
                    robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('صوّر الطلب كدليل على التسليم ثم اطلب الرمز من العميل',
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // منطقة الصورة
            InkWell(
              onTap: hasPhoto
                  ? null
                  : () => orderController.pickPrescriptionImage(
                      isRemove: false, isCamera: true),
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: hasPhoto
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: hasPhoto ? 2 : 1,
                  ),
                ),
                child: hasPhoto
                    ? Stack(children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          child: Image.file(
                            File(photos.first.path),
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: GestureDetector(
                            onTap: () => orderController.pickPrescriptionImage(
                                isRemove: true, isCamera: false),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('تم التصوير',
                                  style: robotoMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeExtraSmall)),
                            ]),
                          ),
                        ),
                      ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 36,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text('اضغط لتصوير الطلب',
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor)),
                          Text('(إلزامي قبل التسليم)',
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).hintColor)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // زر تأكيد التسليم
            CustomButtonWidget(
              buttonText: 'تأكيد التسليم والحصول على رمز العميل',
              icon: Icons.verified_outlined,
              height: 52,
              backgroundColor:
                  hasPhoto ? null : Theme.of(context).disabledColor,
              onPressed: hasPhoto ? () => _onConfirm(orderController) : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],
        );
      }),
    );
  }
}
