import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/common/widgets/animated_shimmer_widget.dart';
import 'package:get/get.dart';

/// Hero order card widget - prominent display for active orders
/// Features map preview, swipe actions, and animations
class HeroOrderCardWidget extends StatefulWidget {
  final OrderModel orderModel;
  final bool isRunningOrder;
  final int orderIndex;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onNavigate;
  final VoidCallback? onViewDetails;
  final bool isLoading;

  const HeroOrderCardWidget({
    super.key,
    required this.orderModel,
    required this.isRunningOrder,
    required this.orderIndex,
    this.onCallCustomer,
    this.onNavigate,
    this.onViewDetails,
    this.isLoading = false,
  });

  @override
  State<HeroOrderCardWidget> createState() => _HeroOrderCardWidgetState();
}

class _HeroOrderCardWidgetState extends State<HeroOrderCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.1, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation for urgent orders
    if (_isUrgentOrder()) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  bool _isUrgentOrder() {
    // Consider order urgent if it's been pending for more than 30 minutes
    // or if it's a high-value order
    return widget.orderModel.orderStatus == 'pending' ||
        widget.orderModel.orderStatus == 'confirmed';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const HeroCardShimmerWidget();
    }

    final isUrgent = _isUrgentOrder();
    final parcel = widget.orderModel.orderType == 'parcel';

    return Semantics(
      label: 'active_order'.tr,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isUrgent ? _pulseAnimation.value : 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeHero,
                vertical: Dimensions.cardSpacingVertical,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusHero),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: Dimensions.blurRadiusMedium,
                    sigmaY: Dimensions.blurRadiusMedium,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors
                          .meshGradientPrimary, // Green gradient for hero card
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusHero),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLayer1,
                          blurRadius: Dimensions.elevationLow,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: AppColors.shadowLayer2,
                          blurRadius: Dimensions.elevationMedium,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.shadowLayer3,
                          blurRadius: Dimensions.elevationHigh,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onViewDetails?.call();
                        },
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusHero),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with order ID and status
                                Row(
                                  children: [
                                    // Map preview with glassmorphic effect
                                    Container(
                                      width: Dimensions.mapPreviewSize,
                                      height: Dimensions.mapPreviewSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusModern),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.map_outlined,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeHero),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${parcel ? 'delivery_id'.tr : 'order_id'.tr}: #${widget.orderModel.id}',
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall),
                                                Text(
                                                  widget.orderModel.orderStatus
                                                          ?.tr ??
                                                      'unknown'.tr,
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isUrgent)
                                      Container(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusModern),
                                          border: Border.all(
                                            color: AppColors.warning
                                                .withOpacity(0.3),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.priority_high,
                                          color: AppColors.warning,
                                          size: Dimensions.iconSizeLarge,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeDefault),

                                // Order details
                                _buildOrderDetails(parcel),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(bool parcel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location info
        Row(
          children: [
            Icon(
              parcel
                  ? (widget.orderModel.orderStatus == 'picked_up'
                      ? Icons.person
                      : Icons.store)
                  : Icons.location_on,
              size: Dimensions.iconSizeDefault,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                parcel
                    ? (widget.orderModel.orderStatus == 'picked_up'
                        ? 'receiver_location'.tr
                        : 'customer_location'.tr)
                    : 'store_location'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Address
        Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.iconSizeDefault + Dimensions.paddingSizeSmall),
          child: Text(
            parcel
                ? (widget.orderModel.orderStatus == 'picked_up'
                    ? widget.orderModel.receiverDetails?.address ??
                        'address_not_found'.tr
                    : widget.orderModel.deliveryAddress?.address ??
                        'address_not_found'.tr)
                : widget.orderModel.storeAddress ?? 'address_not_found'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Payment method
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.getPaymentMethodColor(
                    widget.orderModel.paymentMethod ?? ''),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              widget.orderModel.paymentMethod == 'cash_on_delivery'
                  ? 'cod'.tr
                  : widget.orderModel.paymentMethod == 'partial_payment'
                      ? 'partially_pay'.tr
                      : 'digitally_paid'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            if (parcel) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'parcel'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Hero card shimmer widget
class HeroCardShimmerWidget extends StatelessWidget {
  const HeroCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.paddingSizeSmall,
      ),
      height: Dimensions.cardHeightHero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusHero),
        color: AppColors.surfaceVariant,
      ),
      child: const AnimatedShimmerWidget(
        enabled: true,
        child: SizedBox(),
      ),
    );
  }
}
