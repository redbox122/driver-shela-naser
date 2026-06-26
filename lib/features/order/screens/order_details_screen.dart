import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shellafood_delivery/features/notification/controllers/notification_controller.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:shellafood_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/helper/responsive_helper.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_image_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/camera_button_sheet_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/order_item_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/info_card_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/invoice_sheet_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/captain_stepper_widget.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final bool fromLocationScreen;
  const OrderDetailsScreen(
      {super.key,
      required this.orderId,
      required this.isRunningOrder,
      required this.orderIndex,
      this.fromNotification = false,
      this.fromLocationScreen = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  String _normalizeStatus(String? status) =>
      (status ?? '').toLowerCase().trim();

  bool _isStatus(String? status, String target) =>
      _normalizeStatus(status) == _normalizeStatus(target);

  void _startApiCalling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(widget.orderId!);
    });
  }

  void _showCancelDialog(OrderModel order) {
    final bool isParcel = order.orderType == 'parcel';
    Get.defaultDialog(
      title: 'are_you_sure_to_cancel'.tr,
      middleText: isParcel
          ? 'you_want_to_cancel_this_delivery'.tr
          : 'you_want_to_cancel_this_order'.tr,
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.find<OrderController>().cancelOrder(order.id);
      },
    );
  }

  Future<void> _loadData() async {
    Get.find<OrderController>()
        .pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    if (Get.find<OrderController>().orderModel != null) {
      Get.find<OrderController>().getOrderDetails(widget.orderId,
          Get.find<OrderController>().orderModel!.orderType == 'parcel');
      await Get.find<OrderController>().getLatestOrders();
      if (Get.find<OrderController>().showDeliveryImageField) {
        Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer?.cancel();
  }

  Widget _buildOtpSection(OrderModel order) {
    // Only show OTPs after they've been successfully verified
    // Store OTP: Show only after pickup is complete (status = 'picked_up')
    // Customer OTP: Show only after delivery is complete (status = 'delivered')
    final status = _normalizeStatus(order.orderStatus);
    bool shouldShowStoreOtp =
        status == _normalizeStatus(AppConstants.pickedUp) ||
            status == _normalizeStatus(AppConstants.delivered);
    bool shouldShowCustomerOtp =
        status == _normalizeStatus(AppConstants.delivered);

    // If no OTPs should be shown, return empty widget
    if (!shouldShowStoreOtp && !shouldShowCustomerOtp) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show store OTP only after successful pickup verification
          if (shouldShowStoreOtp && order.otpStore != null) ...[
            _buildOtpCard(
              icon: Icons.store,
              label: 'store_pickup_code'.tr,
              otp: order.otpStore!,
              description: 'verified_at_pickup'.tr,
              color: Theme.of(context).primaryColor,
            ),
          ],
          // Show customer OTP only after successful delivery verification
          if (shouldShowCustomerOtp && order.otp != null) ...[
            _buildOtpCard(
              icon: Icons.person,
              label: 'customer_delivery_code'.tr,
              otp: order.otp!,
              description: 'verified_at_delivery'.tr,
              color: Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderProofUploadSection(OrderModel order) {
    // PICKUP PHOTOS: show for delivery orders assigned to this driver

    // Hide if already picked up
    if (_isStatus(order.orderStatus, AppConstants.pickedUp)) {
      return const SizedBox.shrink();
    }

    assert(() {
      debugPrint('ORDER STATUS RAW = ${order.orderStatus}');
      debugPrint(
          'ORDER STATUS NORMALIZED = ${_normalizeStatus(order.orderStatus)}');
      return true;
    }());

    return GetBuilder<OrderController>(builder: (orderController) {
      final shouldShowPhotos = orderController.canShowPickupPhotos(order);
      if (!shouldShowPhotos) {
        return const SizedBox.shrink();
      }
      final hasUploadedPhotos = order.orderProofFullUrl != null &&
          order.orderProofFullUrl!.isNotEmpty;
      final hasSelectedPhotos =
          orderController.pickedOrderProofImages.isNotEmpty;

      final showHelper = !hasUploadedPhotos && !hasSelectedPhotos;

      return Container(
        margin:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHelper)
              Container(
                margin:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[300]!, width: 1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: Colors.blue[600], size: 28),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'please_take_pickup_photo_first'.tr,
                            style: robotoBold.copyWith(
                              color: Colors.blue[700],
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            'pickup_photo_instruction'.tr,
                            style: robotoRegular.copyWith(
                              color: Colors.blue[600],
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text('pickup_photos'.tr,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'upload_order_proof_description'.tr,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Show already uploaded photos
            if (hasUploadedPhotos) ...[
              Text('uploaded_photos'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.5,
                  crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 5,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.orderProofFullUrl!.length,
                itemBuilder: (BuildContext context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () =>
                          openDialog(context, order.orderProofFullUrl![index]),
                      child: Center(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(
                            image: order.orderProofFullUrl![index],
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            // Show selected photos (not yet uploaded)
            if (hasSelectedPhotos) ...[
              Text('selected_photos'.tr,
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: orderController.pickedOrderProofImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            child: Image.file(
                              File(orderController
                                  .pickedOrderProofImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                orderController.pickOrderProofImages(
                                    isRemove: true, isCamera: false);
                                orderController.pickedOrderProofImages
                                    .removeAt(index);
                                orderController.update();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            // Upload buttons
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        assert(() {
                          debugPrint('PICKUP PHOTO BUTTON TAP');
                          return true;
                        }());
                        Get.bottomSheet(
                          CameraButtonSheetWidget(
                            isOrderProof: true,
                            onCameraTap: () {
                              orderController.pickOrderProofImages(
                                  isRemove: false, isCamera: true);
                            },
                            onGalleryTap: () {
                              orderController.pickOrderProofImages(
                                  isRemove: false, isCamera: false);
                            },
                          ),
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text('select_photos'.tr,
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasSelectedPhotos) ...[
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: CustomButtonWidget(
                      buttonText: 'upload'.tr,
                      onPressed: () async {
                        final success =
                            await orderController.uploadOrderProof(order);
                        if (success) {
                          // Refresh order details
                          await orderController.getOrderDetails(
                              order.id, false);
                          // Refresh the order model
                          await orderController.getOrderWithId(order.id);
                          setState(() {});
                        }
                      },
                      radius: Dimensions.radiusDefault,
                    ),
                  ),
                ],
              ],
            ),
            if (hasSelectedPhotos)
              Padding(
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Text(
                  '${orderController.pickedOrderProofImages.length}/5 photos selected',
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    });
  }

  String _getSliderButtonText({
    bool? parcel,
    bool? accepted,
    bool? cod,
    bool? restConfModel,
    bool? selfDelivery,
    bool? pickedUp,
    bool? handover,
  }) {
    try {
      // Ensure all values are non-null before checking
      final isParcel = parcel ?? false;
      final isAccepted = accepted ?? false;
      final isCod = cod ?? false;
      final isRestConfModel = restConfModel ?? false;
      final isSelfDelivery = selfDelivery ?? false;
      final isPickedUp = pickedUp ?? false;
      final isHandover = handover ?? false;

      String translationKey;
      if (isParcel && isAccepted) {
        translationKey = 'swipe_to_confirm_delivery';
      } else if (isCod && isAccepted && !isRestConfModel && !isSelfDelivery) {
        translationKey = 'swipe_to_confirm_order';
      } else if (isPickedUp) {
        translationKey =
            isParcel ? 'swipe_to_deliver_parcel' : 'swipe_to_deliver_order';
      } else if (isHandover) {
        translationKey =
            isParcel ? 'swipe_to_pick_up_parcel' : 'swipe_to_pick_up_order';
      } else {
        translationKey = 'swipe_to_pick_up_order';
      }

      // Try to translate, fallback to key if translation fails
      final translated = translationKey.tr;
      return translated.isNotEmpty && translated != translationKey
          ? translated
          : translationKey;
    } catch (e) {
      // If anything fails, return a safe default
      return 'Continue';
    }
  }

  Future<String?> _showStoreOtpDialog() async {
    final TextEditingController otpController = TextEditingController();
    String? result;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.store,
                      color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('enter_store_pickup_code'.tr, style: robotoBold),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'ask_vendor_for_code'.tr,
                style:
                    robotoRegular.copyWith(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              TextField(
                controller: otpController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: 28, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: '____',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: CustomButtonWidget(
                      buttonText: 'verify'.tr,
                      onPressed: () {
                        result = otpController.text;
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return result;
  }

  Widget _buildOtpCard({
    required IconData icon,
    required String label,
    required String otp,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: 4),
              Text(
                otp,
                style: robotoBold.copyWith(
                  fontSize: 24,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
              Text(
                description,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool? cancelPermission =
        Get.find<SplashController>().configModel!.canceledByDeliveryman;
    bool selfDelivery =
        Get.find<ProfileController>().profileModel!.type != 'zone_wise';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if ((widget.fromNotification || widget.fromLocationScreen)) {
          Future.delayed(const Duration(milliseconds: 0), () async {
            await Get.offAllNamed(RouteHelper.getInitialRoute());
          });
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(
            title: 'order_details'.tr,
            onBackPressed: () {
              if (widget.fromNotification || widget.fromLocationScreen) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<OrderController>(builder: (orderController) {
              OrderModel? controllerOrderModel = orderController.orderModel;

              bool restConfModel = Get.find<SplashController>()
                      .configModel!
                      .orderConfirmationModel !=
                  'deliveryman';

              bool? parcel,
                  processing,
                  accepted,
                  confirmed,
                  handover,
                  pickedUp,
                  cod,
                  wallet,
                  partialPay,
                  offlinePay;

              late bool showBottomView;
              late bool showSlider;
              bool isUnassignedOrder = false;

              bool showChatPermission = true;
              OrderModel? order = controllerOrderModel;
              if (order != null && orderController.orderDetailsModel != null) {
                if (order.storeBusinessModel == 'commission') {
                  showChatPermission = true;
                } else if (order.storeBusinessModel == 'subscription') {
                  showChatPermission = order.storeChatPermission == 1;
                } else {
                  showChatPermission = true;
                }
              }

              if (controllerOrderModel != null) {
                parcel = controllerOrderModel.orderType == 'parcel';
                final status =
                    _normalizeStatus(controllerOrderModel.orderStatus);
                processing =
                    status == _normalizeStatus(AppConstants.processing);
                accepted = status == _normalizeStatus(AppConstants.accepted);
                confirmed = status == _normalizeStatus(AppConstants.confirmed);
                handover = status == _normalizeStatus(AppConstants.handover);
                pickedUp = status == _normalizeStatus(AppConstants.pickedUp);
                cod = controllerOrderModel.paymentMethod == 'cash_on_delivery';
                wallet = controllerOrderModel.paymentMethod == 'wallet';
                partialPay =
                    controllerOrderModel.paymentMethod == 'partial_payment';
                offlinePay =
                    controllerOrderModel.paymentMethod == 'offline_payment';

                bool restConfModel = Get.find<SplashController>()
                        .configModel!
                        .orderConfirmationModel !=
                    'deliveryman';

                // Check if order is not assigned yet (delivery_man_id is null)
                isUnassignedOrder = controllerOrderModel.deliveryManId == null;

                showBottomView = (parcel && accepted) ||
                    accepted ||
                    confirmed ||
                    processing ||
                    handover ||
                    pickedUp ||
                    isUnassignedOrder ||
                    (widget.isRunningOrder ?? true);
                // Show slider when confirmed AND photos uploaded (any delivery order)
                bool readyForPickupWithPhotos = confirmed &&
                    controllerOrderModel.orderProofFullUrl != null &&
                    controllerOrderModel.orderProofFullUrl!.isNotEmpty;
                showSlider =
                    (cod && accepted && !restConfModel && !selfDelivery) ||
                        handover ||
                        pickedUp ||
                        (parcel && accepted) ||
                        readyForPickupWithPhotos;
              }

              return (orderController.orderDetailsModel != null &&
                      controllerOrderModel != null)
                  ? Column(children: [
                      Expanded(
                          child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          if (parcel != true &&
                              const [
                                'accepted',
                                'confirmed',
                                'processing',
                                'handover',
                                'picked_up'
                              ].contains((controllerOrderModel.orderStatus ?? '')
                                  .toLowerCase()))
                            CaptainStepperWidget(
                              orderStatus: controllerOrderModel.orderStatus,
                              invoiceIssued:
                                  controllerOrderModel.captainInvoiceAmount !=
                                      null,
                            ),
                          // شله كابتن: إيرادات التوصيل (أرباح الكابتن) بارزة كالتصميم المرجعي
                          if (parcel != true)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeDefault),
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.20)),
                              ),
                              child: Row(children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 22),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Text('إيرادات التوصيل',
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault)),
                                const Spacer(),
                                Text(
                                  PriceConverterHelper.convertPrice(
                                      (controllerOrderModel
                                                  .originalDeliveryCharge ??
                                              0) +
                                          (controllerOrderModel.dmTips ?? 0)),
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ]),
                            ),
                          Row(children: [
                            Text(
                                '${parcel! ? 'delivery_id'.tr : 'order_id'.tr}:',
                                style: robotoRegular),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(controllerOrderModel.id.toString(),
                                style: robotoMedium),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            const Expanded(child: SizedBox()),
                            Container(
                                height: 7,
                                width: 7,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green)),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              (controllerOrderModel.orderStatus ?? '').tr,
                              style: robotoRegular,
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Row(children: [
                            Text('${parcel ? 'charge_payer'.tr : 'item'.tr}:',
                                style: robotoRegular),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              parcel
                                  ? (controllerOrderModel.chargePayer ?? '').tr
                                  : orderController.orderDetailsModel!.length
                                      .toString(),
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor),
                            ),
                            const Expanded(child: SizedBox()),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                cod!
                                    ? 'cod'.tr
                                    : wallet!
                                        ? 'wallet'.tr
                                        : partialPay!
                                            ? 'partially_pay'.tr
                                            : offlinePay!
                                                ? 'offline_payment'.tr
                                                : 'digitally_paid'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ]),
                          // شله كابتن: حُذف صف «السكاكين» بناءً على طلب التصميم
                          const SizedBox(),
                          controllerOrderModel.unavailableItemNote != null
                              ? Column(
                                  children: [
                                    const Divider(
                                        height: Dimensions.paddingSizeLarge),
                                    Row(children: [
                                      Text('${'unavailable_item_note'.tr}: ',
                                          style: robotoMedium),
                                      Text(
                                        controllerOrderModel
                                            .unavailableItemNote!,
                                        style: robotoRegular,
                                      ),
                                    ]),
                                  ],
                                )
                              : const SizedBox(),
                          controllerOrderModel.deliveryInstruction != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      const Divider(
                                          height: Dimensions.paddingSizeLarge),
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text:
                                                '${'delivery_instruction'.tr}: ',
                                            style: robotoMedium.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: controllerOrderModel
                                                      .deliveryInstruction!,
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall))
                                            ]),
                                      ),
                                    ])
                              : const SizedBox(),
                          SizedBox(
                              height:
                                  controllerOrderModel.deliveryInstruction !=
                                          null
                                      ? Dimensions.paddingSizeSmall
                                      : 0),
                          // كابتن شله: بعد استلام الطلب من المتجر (picked_up) تختفي
                          // بطاقة المتجر ويظهر العميل فقط (الكابتن متّجه للتسليم)
                          if (parcel == true ||
                              !(_isStatus(controllerOrderModel.orderStatus,
                                      AppConstants.pickedUp) ||
                                  _isStatus(controllerOrderModel.orderStatus,
                                      AppConstants.delivered))) ...[
                          const Divider(height: Dimensions.paddingSizeLarge),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          InfoCardWidget(
                            title: parcel
                                ? 'sender_details'.tr
                                : 'store_details'.tr,
                            address: parcel
                                ? controllerOrderModel.deliveryAddress
                                : DeliveryAddress(
                                    address: controllerOrderModel.storeAddress),
                            image: parcel
                                ? ''
                                : '${controllerOrderModel.storeLogoFullUrl}',
                            name: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.contactPersonName
                                : controllerOrderModel.storeName,
                            phone: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.contactPersonNumber
                                : controllerOrderModel.storePhone,
                            latitude: parcel
                                ? controllerOrderModel.deliveryAddress!.latitude
                                : controllerOrderModel.storeLat,
                            longitude: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.longitude
                                : controllerOrderModel.storeLng,
                            showButton: (!_isStatus(
                                    controllerOrderModel.orderStatus,
                                    AppConstants.delivered) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.failed) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.canceled) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.refunded)),
                            isStore: true,
                            directionLabel: 'اتجاه إلى المطعم',
                            isChatAllow: showChatPermission,
                            messageOnTap: () =>
                                Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(
                                orderId: controllerOrderModel.id,
                                vendorId: orderController
                                    .orderDetailsModel![0].vendorId,
                              ),
                              user: User(
                                id: controllerOrderModel.storeId,
                                fName: controllerOrderModel.storeName,
                                imageFullUrl:
                                    controllerOrderModel.storeLogoFullUrl,
                              ),
                            )),
                            order: order!,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                          InfoCardWidget(
                            title: parcel
                                ? 'receiver_details'.tr
                                : 'customer_contact_details'.tr,
                            address: parcel
                                ? controllerOrderModel.receiverDetails
                                : controllerOrderModel.deliveryAddress,
                            image: parcel
                                ? ''
                                : controllerOrderModel.customer != null
                                    ? '${controllerOrderModel.customer!.imageFullUrl}'
                                    : '',
                            name: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.contactPersonName
                                : controllerOrderModel
                                    .deliveryAddress!.contactPersonName,
                            phone: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.contactPersonNumber
                                : controllerOrderModel
                                    .deliveryAddress!.contactPersonNumber,
                            latitude: parcel
                                ? controllerOrderModel.receiverDetails!.latitude
                                : controllerOrderModel
                                    .deliveryAddress!.latitude,
                            longitude: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.longitude
                                : controllerOrderModel
                                    .deliveryAddress!.longitude,
                            showButton: !_isStatus(
                                    controllerOrderModel.orderStatus,
                                    AppConstants.delivered) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.failed) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.canceled) &&
                                !_isStatus(controllerOrderModel.orderStatus,
                                    AppConstants.refunded),
                            isStore: parcel ? false : true,
                            directionLabel: 'اتجاه إلى العميل',
                            isChatAllow: showChatPermission,
                            messageOnTap: () =>
                                Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(
                                orderId: controllerOrderModel.id,
                                customerId: controllerOrderModel.customer!.id,
                              ),
                              user: User(
                                id: controllerOrderModel.customer!.id,
                                fName: controllerOrderModel.customer!.fName,
                                lName: controllerOrderModel.customer!.lName,
                                imageFullUrl:
                                    controllerOrderModel.customer!.imageFullUrl,
                              ),
                            )),
                            order: order!,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          _buildOtpSection(controllerOrderModel),
                          parcel
                              ? Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    boxShadow: Get.isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                                color: Colors.grey[200]!,
                                                spreadRadius: 1,
                                                blurRadius: 5)
                                          ],
                                  ),
                                  child: controllerOrderModel.parcelCategory !=
                                          null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                              Text('parcel_category'.tr,
                                                  style: robotoRegular),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Row(children: [
                                                ClipOval(
                                                    child: CustomImageWidget(
                                                  image:
                                                      '${controllerOrderModel.parcelCategory!.imageFullUrl}',
                                                  height: 35,
                                                  width: 35,
                                                  fit: BoxFit.cover,
                                                )),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                      Text(
                                                        controllerOrderModel
                                                            .parcelCategory!
                                                            .name!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall),
                                                      ),
                                                      Text(
                                                        controllerOrderModel
                                                            .parcelCategory!
                                                            .description!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                      ),
                                                    ])),
                                              ]),
                                            ])
                                      : SizedBox(
                                          width: context.width,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('parcel_category'.tr,
                                                    style: robotoRegular),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall),
                                                Text(
                                                    'no_parcel_category_data_found'
                                                        .tr,
                                                    style: robotoMedium),
                                              ]),
                                        ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      orderController.orderDetailsModel!.length,
                                  itemBuilder: (context, index) {
                                    return OrderItemWidget(
                                        order: controllerOrderModel,
                                        orderDetails: orderController
                                            .orderDetailsModel![index],
                                        showPrice: false);
                                  },
                                ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controllerOrderModel.orderNote != null)
                                  Column(
                                    children: [
                                      Text('additional_note'.tr,
                                          style: robotoRegular),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      Container(
                                        width: 1170,
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        ),
                                        child: Text(
                                          controllerOrderModel.orderNote ?? "",
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeLarge),
                                    ],
                                  ),
                                (Get.find<SplashController>()
                                                .getModule(controllerOrderModel
                                                    .moduleType)
                                                .orderAttachment ==
                                            true &&
                                        controllerOrderModel
                                                .orderAttachmentFullUrl !=
                                            null &&
                                        controllerOrderModel
                                            .orderAttachmentFullUrl!.isNotEmpty)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Text('prescription'.tr,
                                                style: robotoRegular),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            Center(
                                                child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              child: CustomImageWidget(
                                                image:
                                                    '${controllerOrderModel.orderAttachmentFullUrl![0]}',
                                                width: context.width,
                                              ),
                                            )),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeLarge),
                                          ])
                                    : const SizedBox(),
                              ]),
                          // Order Proof Upload Section (Modules 6/7/8/9 when status is confirmed)
                          _buildOrderProofUploadSection(controllerOrderModel),
                          (_isStatus(controllerOrderModel.orderStatus,
                                      AppConstants.delivered) &&
                                  controllerOrderModel.orderProofFullUrl !=
                                      null &&
                                  controllerOrderModel
                                      .orderProofFullUrl!.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      Text('order_proof'.tr,
                                          style: robotoRegular),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio: 1.5,
                                            crossAxisCount:
                                                ResponsiveHelper.isTab(context)
                                                    ? 5
                                                    : 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 5,
                                          ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: controllerOrderModel
                                              .orderProofFullUrl!.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: InkWell(
                                                onTap: () => openDialog(
                                                    context,
                                                    controllerOrderModel
                                                            .orderProofFullUrl![
                                                        index]),
                                                child: Center(
                                                    child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                  child: CustomImageWidget(
                                                    image: controllerOrderModel
                                                            .orderProofFullUrl![
                                                        index],
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                )),
                                              ),
                                            );
                                          }),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeLarge),
                                    ])
                              : const SizedBox(),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          const SizedBox.shrink(),
                        ]),
                      )),
                      (_isStatus(controllerOrderModel.orderStatus,
                                  AppConstants.pickedUp) ||
                              _isStatus(controllerOrderModel.orderStatus,
                                  AppConstants.handover))
                          ? Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.05),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(
                                        Dimensions.radiusDefault)),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('completed_after_delivery_picture'.tr,
                                        style: robotoRegular),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Container(
                                      height: 80,
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeSmall),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: orderController
                                                .pickedPrescriptions.length +
                                            1,
                                        itemBuilder: (context, index) {
                                          XFile? file = index ==
                                                  orderController
                                                      .pickedPrescriptions
                                                      .length
                                              ? null
                                              : orderController
                                                  .pickedPrescriptions[index];
                                          if (index < 5 &&
                                              index ==
                                                  orderController
                                                      .pickedPrescriptions
                                                      .length) {
                                            return InkWell(
                                              onTap: () {
                                                if (GetPlatform.isIOS) {
                                                  Get.find<OrderController>()
                                                      .pickPrescriptionImage(
                                                          isRemove: false,
                                                          isCamera: false);
                                                } else {
                                                  Get.bottomSheet(
                                                      const CameraButtonSheetWidget());
                                                }
                                              },
                                              child: Container(
                                                height: 60,
                                                width: 60,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1),
                                                ),
                                                child: Icon(
                                                    Icons.camera_alt_sharp,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 32),
                                              ),
                                            );
                                          }
                                          return file != null
                                              ? Container(
                                                  margin: const EdgeInsets.only(
                                                      right: Dimensions
                                                          .paddingSizeSmall),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                  ),
                                                  child: Stack(children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .radiusDefault),
                                                      child: GetPlatform.isWeb
                                                          ? Image.network(
                                                              file.path,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.file(
                                                              File(file.path),
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ]),
                                                )
                                              : const SizedBox();
                                        },
                                      ),
                                    ),
                                  ]),
                            )
                          : const SizedBox(),
                      (cancelPermission == true &&
                              (accepted == true || processing == true) &&
                              !showSlider)
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeSmall),
                              child: CustomButtonWidget(
                                buttonText: 'cancel'.tr,
                                backgroundColor: Colors.red,
                                onPressed: orderController.isLoading
                                    ? null
                                    : () =>
                                        _showCancelDialog(controllerOrderModel),
                              ),
                            )
                          : const SizedBox(),
                      (_isStatus(controllerOrderModel.orderStatus,
                                  AppConstants.pickedUp) ||
                              _isStatus(controllerOrderModel.orderStatus,
                                  AppConstants.handover))
                          ? Column(children: [
                              // ✅ MANDATORY INSTRUCTION
                              if (!orderController.hasPickedDeliveryPhotos())
                                Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  margin: const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    border: Border.all(
                                        color: Colors.orange[400]!, width: 2),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.orange[700], size: 24),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'please_take_delivery_photo_first'
                                                .tr,
                                            style: robotoMedium.copyWith(
                                                color: Colors.orange[700]),
                                          ),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text(
                                            'delivery_requires_photo_proof'.tr,
                                            style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Colors.orange[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              CustomButtonWidget(
                                buttonText: 'complete_delivery'.tr,
                                // MANDATORY: Disable if no delivery photo
                                backgroundColor: (orderController
                                            .hasPickedDeliveryPhotos() &&
                                        (_isStatus(
                                                controllerOrderModel
                                                    .orderStatus,
                                                AppConstants.pickedUp) ||
                                            _isStatus(
                                                controllerOrderModel
                                                    .orderStatus,
                                                AppConstants.handover)))
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[400],
                                onPressed: (orderController
                                            .hasPickedDeliveryPhotos() &&
                                        (_isStatus(
                                                controllerOrderModel
                                                    .orderStatus,
                                                AppConstants.pickedUp) ||
                                            _isStatus(
                                                controllerOrderModel
                                                    .orderStatus,
                                                AppConstants.handover)))
                                    ? () {
                                        if (Get.find<SplashController>()
                                                .configModel
                                                ?.orderDeliveryVerification ??
                                            false) {
                                          Get.find<NotificationController>()
                                              .sendDeliveredNotification(
                                                  controllerOrderModel.id);

                                          Get.bottomSheet(
                                                  VerifyDeliverySheetWidget(
                                                    currentOrderModel:
                                                        controllerOrderModel,
                                                    verify: Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .orderDeliveryVerification,
                                                    orderAmount: (partialPay! &&
                                                            (controllerOrderModel.payments?.length ??
                                                                    0) >
                                                                1)
                                                        ? controllerOrderModel
                                                            .payments![1]
                                                            .amount!
                                                            .toDouble()
                                                        : controllerOrderModel
                                                            .orderAmount,
                                                    cod: cod! ||
                                                        (partialPay &&
                                                            (controllerOrderModel.payments?.length ??
                                                                    0) >
                                                                1 &&
                                                            controllerOrderModel
                                                                    .payments![
                                                                        1]
                                                                    .paymentMethod ==
                                                                'cash_on_delivery'),
                                                  ),
                                                  isScrollControlled: true)
                                              .then((isSuccess) {
                                            if (isSuccess &&
                                                (cod! ||
                                                    (partialPay! &&
                                                        (controllerOrderModel.payments?.length ??
                                                                0) >
                                                            1 &&
                                                        controllerOrderModel
                                                                .payments![1]
                                                                .paymentMethod ==
                                                            'cash_on_delivery'))) {
                                              Get.bottomSheet(
                                                  CollectMoneyDeliverySheetWidget(
                                                    currentOrderModel:
                                                        controllerOrderModel,
                                                    verify: Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .orderDeliveryVerification,
                                                    orderAmount: (partialPay! &&
                                                            (controllerOrderModel.payments?.length ??
                                                                    0) >
                                                                1)
                                                        ? controllerOrderModel
                                                            .payments![1]
                                                            .amount!
                                                            .toDouble()
                                                        : controllerOrderModel
                                                            .orderAmount,
                                                    cod: cod ||
                                                        (partialPay &&
                                                            (controllerOrderModel.payments?.length ??
                                                                    0) >
                                                                1 &&
                                                            controllerOrderModel
                                                                    .payments![
                                                                        1]
                                                                    .paymentMethod ==
                                                                'cash_on_delivery'),
                                                  ),
                                                  isScrollControlled: true,
                                                  isDismissible: false);
                                            }
                                          });
                                        } else {
                                          Get.bottomSheet(
                                              CollectMoneyDeliverySheetWidget(
                                                currentOrderModel:
                                                    controllerOrderModel,
                                                verify: Get.find<
                                                        SplashController>()
                                                    .configModel!
                                                    .orderDeliveryVerification,
                                                orderAmount: (partialPay! &&
                                                        (controllerOrderModel.payments?.length ??
                                                                0) >
                                                            1)
                                                    ? controllerOrderModel
                                                        .payments![1].amount!
                                                        .toDouble()
                                                    : controllerOrderModel
                                                        .orderAmount,
                                                cod: cod! ||
                                                    (partialPay &&
                                                        (controllerOrderModel.payments?.length ??
                                                                0) >
                                                            1 &&
                                                        controllerOrderModel
                                                                .payments![1]
                                                                .paymentMethod ==
                                                            'cash_on_delivery'),
                                              ),
                                              isScrollControlled: true);
                                        }
                                      }
                                    : null, // ❌ DISABLED: No delivery photo taken
                              ),
                            ])
                          : showBottomView
                              ? (isUnassignedOrder
                                  ? Row(children: [
                                      Expanded(
                                        child: CustomButtonWidget(
                                          height: 50,
                                          radius: Dimensions.radiusDefault,
                                          buttonText: 'accept'.tr,
                                          onPressed: () {
                                            Get.dialog(
                                              ConfirmationDialogWidget(
                                                icon: Images.warning,
                                                title:
                                                    'are_you_sure_to_accept'.tr,
                                                description: (parcel ?? false)
                                                    ? 'you_want_to_accept_this_delivery'
                                                        .tr
                                                    : 'you_want_to_accept_this_order'
                                                        .tr,
                                                onYesPressed: () {
                                                  orderController
                                                      .acceptOrder(
                                                          controllerOrderModel
                                                              .id,
                                                          0,
                                                          controllerOrderModel)
                                                      .then((isSuccess) {
                                                    if (isSuccess) {
                                                      Get.back();
                                                      controllerOrderModel
                                                              .orderStatus =
                                                          'accepted';
                                                    } else {
                                                      Get.find<
                                                              OrderController>()
                                                          .getLatestOrders();
                                                    }
                                                  });
                                                },
                                              ),
                                              barrierDismissible: false,
                                            );
                                          },
                                        ),
                                      ),
                                    ])
                                  : ((accepted! &&
                                              !parcel &&
                                              (!cod ||
                                                  restConfModel ||
                                                  selfDelivery)) ||
                                          (processing! ||
                                              (confirmed! &&
                                                  !([
                                                        6,
                                                        7,
                                                        8,
                                                        9
                                                      ].contains(
                                                          controllerOrderModel
                                                              .module_id) &&
                                                      controllerOrderModel
                                                              .orderProofFullUrl !=
                                                          null &&
                                                      controllerOrderModel
                                                          .orderProofFullUrl!
                                                          .isNotEmpty))))
                                      ? Container(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            border: Border.all(
                                                width: 1,
                                                color: Get.isDarkMode
                                                    ? Colors.grey[700]!
                                                    : Colors.grey[200]!),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomButtonWidget(
                                                buttonText: controllerOrderModel
                                                            .captainInvoiceAmount !=
                                                        null
                                                    ? 'تعديل فاتورة'
                                                    : 'اصدار فاتورة',
                                                icon: Icons.receipt_long,
                                                onPressed: () {
                                                  Get.bottomSheet(
                                                    InvoiceSheetWidget(
                                                      orderId:
                                                          controllerOrderModel
                                                              .id!,
                                                      initialAmount:
                                                          controllerOrderModel
                                                              .captainInvoiceAmount,
                                                      hasExistingImage:
                                                          (controllerOrderModel
                                                                      .captainInvoiceImage ??
                                                                  '')
                                                              .isNotEmpty,
                                                    ),
                                                    isScrollControlled: true,
                                                  );
                                                },
                                              ),
                                              // كابتن شله: التسلسل — زر «استلمت من المتجر»
                                              // يظهر فقط بعد إصدار الفاتورة
                                              if (controllerOrderModel
                                                      .captainInvoiceAmount !=
                                                  null) ...[
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                Text(
                                                  'تم إصدار فاتورة بقيمة ${controllerOrderModel.captainInvoiceAmount!.toStringAsFixed(2)} ريال',
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                CustomButtonWidget(
                                                    buttonText:
                                                        'استلمت طلب العميل من المتجر',
                                                    onPressed: () {
                                                      Get.dialog(
                                                        ConfirmationDialogWidget(
                                                          icon: Images.warning,
                                                          title:
                                                              'are_you_sure_to_confirm'
                                                                  .tr,
                                                          description:
                                                              'تأكد من استلام جميع المنتجات قبل خروجك من المتجر',
                                                          onYesPressed:
                                                              () async {
                                                            await orderController
                                                                .updateOrderStatus(
                                                              controllerOrderModel,
                                                              AppConstants
                                                                  .pickedUp,
                                                            );
                                                            await orderController
                                                                .getOrderWithId(
                                                                    controllerOrderModel
                                                                        .id);
                                                          },
                                                        ),
                                                        barrierDismissible:
                                                            false,
                                                      );
                                                    },
                                                  ),
                                              ] else ...[
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                Text(
                                                  'أصدر الفاتورة أولاً لتظهر خطوة «استلمت من المتجر»',
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Theme.of(context)
                                                          .hintColor),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ],
                                          ),
                                        )
                                      : showSlider
                                          ? ((cod &&
                                                      accepted &&
                                                      !restConfModel &&
                                                      cancelPermission! &&
                                                      !selfDelivery) ||
                                                  (parcel &&
                                                      accepted &&
                                                      cancelPermission!))
                                              ? Row(children: [
                                                  Expanded(
                                                      child: TextButton(
                                                    onPressed: () {
                                                      orderController
                                                          .setOrderCancelReason(
                                                              '');
                                                      Get.dialog(
                                                          CancellationDialogueWidget(
                                                              orderId: widget
                                                                  .orderId));
                                                    },
                                                    style: TextButton.styleFrom(
                                                      minimumSize:
                                                          const Size(1170, 40),
                                                      padding: EdgeInsets.zero,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusSmall),
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color!),
                                                      ),
                                                    ),
                                                    child: Text('cancel'.tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: robotoRegular
                                                            .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                        )),
                                                  )),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  Expanded(
                                                      child: CustomButtonWidget(
                                                    buttonText: 'confirm'.tr,
                                                    height: 40,
                                                    onPressed: () {
                                                      Get.dialog(
                                                          ConfirmationDialogWidget(
                                                            icon:
                                                                Images.warning,
                                                            title:
                                                                'are_you_sure_to_confirm'
                                                                    .tr,
                                                            description: parcel!
                                                                ? 'you_want_to_confirm_this_delivery'
                                                                    .tr
                                                                : 'you_want_to_confirm_this_order'
                                                                    .tr,
                                                            onYesPressed: () {
                                                              if (((Get.find<SplashController>()
                                                                              .configModel
                                                                              ?.orderDeliveryVerification ??
                                                                          false) ||
                                                                      cod!) &&
                                                                  !parcel!) {
                                                                orderController
                                                                    .updateOrderStatus(
                                                                  controllerOrderModel,
                                                                  parcel
                                                                      ? AppConstants
                                                                          .handover
                                                                      : AppConstants
                                                                          .confirmed,
                                                                  back: widget
                                                                          .fromLocationScreen
                                                                      ? false
                                                                      : true,
                                                                  gotoDashboard:
                                                                      widget.fromLocationScreen
                                                                          ? true
                                                                          : false,
                                                                );
                                                              } else if (parcel! &&
                                                                  cod! &&
                                                                  controllerOrderModel
                                                                          .chargePayer !=
                                                                      'sender') {
                                                                orderController.updateOrderStatus(
                                                                    controllerOrderModel,
                                                                    AppConstants
                                                                        .handover);
                                                              } else if (parcel &&
                                                                  controllerOrderModel
                                                                          .chargePayer ==
                                                                      'sender' &&
                                                                  cod!) {
                                                                orderController.updateOrderStatus(
                                                                    controllerOrderModel,
                                                                    AppConstants
                                                                        .handover);
                                                              }
                                                            },
                                                          ),
                                                          barrierDismissible:
                                                              false);
                                                    },
                                                  )),
                                                ])
                                              : CustomButtonWidget(
                                                  onPressed: () async {
                                                    if ((cod! &&
                                                            accepted! &&
                                                            !restConfModel &&
                                                            !selfDelivery) ||
                                                        (parcel! &&
                                                            accepted!)) {
                                                      if (orderController
                                                          .isLoading) {
                                                        orderController
                                                            .initLoading();
                                                      }
                                                      Get.dialog(
                                                          ConfirmationDialogWidget(
                                                            icon:
                                                                Images.warning,
                                                            title:
                                                                'are_you_sure_to_confirm'
                                                                    .tr,
                                                            description: parcel!
                                                                ? 'you_want_to_confirm_this_delivery'
                                                                    .tr
                                                                : 'you_want_to_confirm_this_order'
                                                                    .tr,
                                                            onYesPressed: () {
                                                              orderController.updateOrderStatus(
                                                                  controllerOrderModel,
                                                                  parcel!
                                                                      ? AppConstants
                                                                          .handover
                                                                      : AppConstants
                                                                          .confirmed,
                                                                  back: widget
                                                                          .fromLocationScreen
                                                                      ? false
                                                                      : true,
                                                                  gotoDashboard:
                                                                      widget.fromLocationScreen
                                                                          ? true
                                                                          : false);
                                                            },
                                                          ),
                                                          barrierDismissible:
                                                              false);
                                                    }
                                                    if (handover == true) {
                                                      Get.bottomSheet(
                                                              VerifyDeliverySheetWidget(
                                                                currentOrderModel:
                                                                    controllerOrderModel,
                                                                verify: Get.find<
                                                                        SplashController>()
                                                                    .configModel!
                                                                    .orderDeliveryVerification,
                                                                orderAmount: (partialPay! &&
                                                                        (controllerOrderModel.payments?.length ?? 0) >
                                                                            1)
                                                                    ? controllerOrderModel
                                                                        .payments![
                                                                            1]
                                                                        .amount!
                                                                        .toDouble()
                                                                    : controllerOrderModel
                                                                        .orderAmount,
                                                                cod: cod ||
                                                                    (partialPay &&
                                                                        (controllerOrderModel.payments?.length ?? 0) > 1 &&
                                                                        controllerOrderModel.payments![1].paymentMethod ==
                                                                            'cash_on_delivery'),
                                                                isSenderPay:
                                                                    true, // ✅ FIX: Set to true for pickup
                                                              ),
                                                              isScrollControlled:
                                                                  true)
                                                          .then((isSuccess) {});
                                                    } else if (pickedUp!) {
                                                      if (parcel &&
                                                          controllerOrderModel
                                                                  .chargePayer !=
                                                              'sender') {
                                                        assert(() {
                                                          debugPrint(
                                                              '🔧 DELIVERY FLOW: Opening VerifyDeliverySheetWidget for parcel COD delivery');
                                                          return true;
                                                        }());
                                                        Get.bottomSheet(
                                                                VerifyDeliverySheetWidget(
                                                                  currentOrderModel:
                                                                      controllerOrderModel,
                                                                  verify: Get.find<
                                                                          SplashController>()
                                                                      .configModel!
                                                                      .orderDeliveryVerification,
                                                                  orderAmount:
                                                                      controllerOrderModel
                                                                          .orderAmount,
                                                                  cod: true,
                                                                  isParcel:
                                                                      parcel,
                                                                  isSenderPay:
                                                                      false, // ✅ EXPLICIT: Set to false for delivery
                                                                ),
                                                                isScrollControlled:
                                                                    true)
                                                            .then((value) {
                                                          if (value ==
                                                              'show_price_view') {
                                                            Get.bottomSheet(
                                                                VerifyDeliverySheetWidget(
                                                                  currentOrderModel:
                                                                      controllerOrderModel,
                                                                  verify: false,
                                                                  isSetOtp:
                                                                      false,
                                                                  orderAmount:
                                                                      controllerOrderModel
                                                                          .orderAmount,
                                                                  cod: true,
                                                                  isSenderPay:
                                                                      false, // ✅ EXPLICIT: Set to false for delivery
                                                                  isParcel:
                                                                      parcel,
                                                                ),
                                                                isScrollControlled:
                                                                    true);
                                                          }
                                                        });
                                                      } else if (((Get.find<
                                                                          SplashController>()
                                                                      .configModel
                                                                      ?.orderDeliveryVerification ??
                                                                  false) ||
                                                              cod) &&
                                                          !parcel) {
                                                        assert(() {
                                                          debugPrint(
                                                              '🔧 DELIVERY FLOW: Opening VerifyDeliverySheetWidget for delivery');
                                                          debugPrint(
                                                              '   Order Status: ${controllerOrderModel.orderStatus}');
                                                          debugPrint(
                                                              '   COD: $cod');
                                                          debugPrint(
                                                              '   Parcel: $parcel');
                                                          return true;
                                                        }());
                                                        Get.bottomSheet(
                                                            VerifyDeliverySheetWidget(
                                                              currentOrderModel:
                                                                  controllerOrderModel,
                                                              verify: Get.find<
                                                                      SplashController>()
                                                                  .configModel!
                                                                  .orderDeliveryVerification,
                                                              orderAmount:
                                                                  controllerOrderModel
                                                                      .orderAmount,
                                                              cod: cod,
                                                              isSetOtp: true,
                                                              isSenderPay:
                                                                  false, // ✅ EXPLICIT: Set to false for delivery
                                                            ),
                                                            isScrollControlled:
                                                                true);
                                                      } else if (!cod &&
                                                          parcel &&
                                                          controllerOrderModel
                                                                  .chargePayer ==
                                                              'sender') {
                                                        assert(() {
                                                          debugPrint(
                                                              '🔧 DELIVERY FLOW: Opening VerifyDeliverySheetWidget for parcel delivery');
                                                          return true;
                                                        }());
                                                        Get.bottomSheet(
                                                            VerifyDeliverySheetWidget(
                                                              currentOrderModel:
                                                                  controllerOrderModel,
                                                              verify: Get.find<
                                                                      SplashController>()
                                                                  .configModel!
                                                                  .orderDeliveryVerification,
                                                              orderAmount:
                                                                  controllerOrderModel
                                                                      .orderAmount,
                                                              cod: cod,
                                                              isSenderPay:
                                                                  false, // ✅ EXPLICIT: Set to false for delivery
                                                            ),
                                                            isScrollControlled:
                                                                true);
                                                      } else {
                                                        Get.find<
                                                                OrderController>()
                                                            .updateOrderStatus(
                                                                controllerOrderModel,
                                                                AppConstants
                                                                    .delivered,
                                                                back: widget
                                                                        .fromLocationScreen
                                                                    ? false
                                                                    : true,
                                                                gotoDashboard:
                                                                    widget.fromLocationScreen
                                                                        ? true
                                                                        : false);
                                                      }
                                                    } else if (parcel &&
                                                        controllerOrderModel
                                                                .chargePayer ==
                                                            'sender' &&
                                                        cod) {
                                                      Get.bottomSheet(
                                                              VerifyDeliverySheetWidget(
                                                                currentOrderModel:
                                                                    controllerOrderModel,
                                                                verify: Get.find<
                                                                        SplashController>()
                                                                    .configModel!
                                                                    .orderDeliveryVerification,
                                                                orderAmount:
                                                                    controllerOrderModel
                                                                        .orderAmount,
                                                                cod: cod,
                                                                isSenderPay:
                                                                    true,
                                                                isParcel:
                                                                    parcel,
                                                              ),
                                                              isScrollControlled:
                                                                  true)
                                                          .then((value) {
                                                        if (value ==
                                                            'show_price_view') {
                                                          Get.bottomSheet(
                                                              VerifyDeliverySheetWidget(
                                                                currentOrderModel:
                                                                    controllerOrderModel,
                                                                verify: false,
                                                                isSetOtp: false,
                                                                orderAmount:
                                                                    controllerOrderModel
                                                                        .orderAmount,
                                                                cod: cod,
                                                                isSenderPay:
                                                                    true,
                                                                isParcel:
                                                                    parcel,
                                                              ),
                                                              isScrollControlled:
                                                                  true);
                                                        }
                                                      });
                                                    } else if ((confirmed! ||
                                                            handover!) &&
                                                        ![
                                                          AppConstants.canceled,
                                                          AppConstants
                                                              .delivered,
                                                          AppConstants.pickedUp
                                                        ].contains(
                                                            controllerOrderModel
                                                                .orderStatus)) {
                                                      // ✅ GENERAL PICKUP LOGIC - applies to ALL orders
                                                      // بدون قيد module - لأي طلب في حالة confirmed أو handover
                                                      if (Get.find<
                                                                  ProfileController>()
                                                              .profileModel!
                                                              .active ==
                                                          1) {
                                                        // Step 1: Check if module 3 needs OTP
                                                        if (controllerOrderModel
                                                                .module_id ==
                                                            3) {
                                                          // Module 3 - Show store OTP dialog
                                                          String? storeOtp =
                                                              await _showStoreOtpDialog();

                                                          if (storeOtp !=
                                                                  null &&
                                                              storeOtp
                                                                  .isNotEmpty) {
                                                            if (storeOtp
                                                                    .length !=
                                                                4) {
                                                              showCustomSnackBar(
                                                                  'otp_must_be_4_digits'
                                                                      .tr);
                                                              return;
                                                            }

                                                            // Set store OTP in controller
                                                            Get.find<
                                                                    OrderController>()
                                                                .setStoreOtp(
                                                                    storeOtp);
                                                          } else {
                                                            return; // User cancelled OTP
                                                          }
                                                        }

                                                        // Step 2: Check if pickup photos are uploaded
                                                        // ✅ Apply to ALL orders, check status not module
                                                        if (!Get.find<
                                                                OrderController>()
                                                            .hasUploadedRestaurantPhotos(
                                                                controllerOrderModel)) {
                                                          assert(() {
                                                            debugPrint(
                                                                ' ❌ PICKUP BLOCKED: No pickup photos uploaded');
                                                            return true;
                                                          }());
                                                          showCustomSnackBar(
                                                              'please_upload_order_proof_photos_first'
                                                                  .tr,
                                                              isError: true);
                                                          return;
                                                        }

                                                        assert(() {
                                                          debugPrint(
                                                              '✅ PICKUP ALLOWED: All validations passed');
                                                          return true;
                                                        }());
                                                        // Step 3: Update status to 'picked_up'
                                                        Get.find<
                                                                OrderController>()
                                                            .updateOrderStatus(
                                                          controllerOrderModel,
                                                          AppConstants.pickedUp,
                                                          back: false,
                                                          gotoDashboard: false,
                                                        );
                                                      } else {
                                                        showCustomSnackBar(
                                                            'make_yourself_online_first'
                                                                .tr);
                                                      }
                                                    }
                                                  },
                                                  buttonText:
                                                      _getSliderButtonText(
                                                    parcel: parcel,
                                                    accepted: accepted,
                                                    cod: cod,
                                                    restConfModel: restConfModel,
                                                    selfDelivery: selfDelivery,
                                                    pickedUp: pickedUp,
                                                    handover: handover,
                                                  ),
                                                  height: 55,
                                                )
                                          : const SizedBox())
                              : const SizedBox(),
                    ])
                  : const Center(child: CircularProgressIndicator());
            }),
          ),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                child: PhotoView(
                  tightMode: true,
                  imageProvider: NetworkImage(imageUrl),
                  heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    splashRadius: 5,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                  )),
            ]),
          );
        },
      );
}
