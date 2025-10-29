import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class ConfirmationDialogWidget extends StatefulWidget {
  final String icon;
  final double iconSize;
  final String? title;
  final String description;
  final List? iDs;
  final Function onYesPressed;
  final bool isLogOut;
  final bool hasCancel;

  const ConfirmationDialogWidget(
      {super.key,
      required this.icon,
      this.iconSize = 50,
      this.title,
      required this.description,
      required this.onYesPressed,
      this.isLogOut = false,
      this.hasCancel = true,
      this.iDs});

  @override
  State<ConfirmationDialogWidget> createState() =>
      _ConfirmationDialogWidgetState();
}

class _ConfirmationDialogWidgetState extends State<ConfirmationDialogWidget> {
  Timer? _timeoutTimer;
  Timer? _cancelButtonTimer;
  bool _showCancelButton = false;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _cancelButtonTimer?.cancel();
    super.dispose();
  }

  void _startTimers() {
    // Show cancel button after 5 seconds
    _cancelButtonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showCancelButton = true;
        });
      }
    });

    // Auto-close dialog after 15 seconds
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
        });
        _forceResetLoadingState();
        Get.back();
      }
    });
  }

  void _forceResetLoadingState() {
    try {
      final orderController = Get.find<OrderController>();
      if (orderController.isLoading) {
        orderController.initLoading();
        debugPrint('Emergency: Reset OrderController loading state');
      }
    } catch (e) {
      debugPrint('Error resetting loading state: $e');
    }
  }

  void _onCancelPressed() {
    _forceResetLoadingState();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(widget.icon,
                width: widget.iconSize, height: widget.iconSize),
          ),
          widget.title != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Colors.red),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(widget.description,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (widget.iDs?.isNotEmpty == true) Text("IdOfOtherOrders".tr),
          if (widget.iDs?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Text(widget.iDs!.join(","),
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  textAlign: TextAlign.center),
            ),
          GetBuilder<OrderController>(builder: (orderController) {
            // Show timeout message if dialog timed out
            if (_isTimedOut) {
              return Column(
                children: [
                  Text(
                    'Dialog timed out. Please try again.',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomButtonWidget(
                    buttonText: 'ok'.tr,
                    onPressed: _onCancelPressed,
                    height: 40,
                  ),
                ],
              );
            }

            return !orderController.isLoading
                ? Row(children: [
                    // Show cancel button if timeout is approaching or user requests it
                    (widget.hasCancel || _showCancelButton)
                        ? Expanded(
                            child: TextButton(
                            onPressed: () => widget.isLogOut
                                ? widget.onYesPressed()
                                : _onCancelPressed(),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .disabledColor
                                  .withOpacity(0.3),
                              minimumSize: const Size(1170, 40),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall)),
                            ),
                            child: Text(
                              widget.isLogOut ? 'yes'.tr : 'cancel'.tr,
                              textAlign: TextAlign.center,
                              style: robotoBold.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                            ),
                          ))
                        : const SizedBox(),
                    SizedBox(
                        width: (widget.hasCancel || _showCancelButton)
                            ? Dimensions.paddingSizeLarge
                            : 0),
                    Expanded(
                        child: CustomButtonWidget(
                      buttonText: widget.isLogOut
                          ? 'no'.tr
                          : (widget.hasCancel || _showCancelButton)
                              ? 'yes'.tr
                              : 'ok'.tr,
                      onPressed: () =>
                          widget.isLogOut ? Get.back() : widget.onYesPressed(),
                      height: 40,
                    )),
                  ])
                : Column(
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      if (_showCancelButton) ...[
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text(
                          'Taking longer than expected...',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        CustomButtonWidget(
                          buttonText: 'cancel'.tr,
                          onPressed: _onCancelPressed,
                          height: 35,
                        ),
                      ],
                    ],
                  );
          }),
        ]),
      ),
    );
  }
}
