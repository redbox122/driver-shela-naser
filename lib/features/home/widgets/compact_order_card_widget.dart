import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/helper/order_helper.dart';
import 'package:shellafood_delivery/common/widgets/animated_shimmer_widget.dart';
import 'package:get/get.dart';

/// Compact order card widget for displaying secondary orders
/// Shows essential order information in a smaller, condensed format
class CompactOrderCardWidget extends StatelessWidget {
  final OrderModel orderModel;
  final VoidCallback? onNavigate;
  final VoidCallback? onViewDetails;
  final int orderIndex;
  final bool isLoading;

  const CompactOrderCardWidget({
    super.key,
    required this.orderModel,
    required this.orderIndex,
    this.onNavigate,
    this.onViewDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CompactCardShimmerWidget();
    }

    final isInDeliveryPhase = OrderHelper.isInDeliveryPhase(orderModel);
    final contextualLocation = OrderHelper.getContextualLocation(orderModel);
    final contextualLabel = OrderHelper.getContextualLabel(orderModel);
    final statusColor = OrderHelper.getStatusColor(orderModel);
    final parcel = orderModel.orderType == 'parcel';

    return Semantics(
      label: 'order_${orderModel.id}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onViewDetails?.call();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHero,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusModern),
            border: Border.all(
              color: AppColors.glassFrostBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLayer1,
                blurRadius: Dimensions.elevationLow,
                offset: const Offset(
                    Dimensions.shadowOffsetX, Dimensions.shadowOffsetY / 4),
              ),
              BoxShadow(
                color: AppColors.shadowLayer2,
                blurRadius: Dimensions.elevationMedium,
                offset: const Offset(
                    Dimensions.shadowOffsetX, Dimensions.shadowOffsetY / 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewDetails,
              borderRadius: BorderRadius.circular(Dimensions.radiusModern),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with order ID and status
                    Row(
                      children: [
                        // Order ID
                        Expanded(
                          child: Text(
                            '${parcel ? 'delivery_id'.tr : 'order_id'.tr}: #${orderModel.id}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBackgroundColor(statusColor),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(
                              color: _getStatusBorderColor(statusColor),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(statusColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                orderModel.orderStatus?.tr ?? 'unknown'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: _getStatusColor(statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Location info
                    Row(
                      children: [
                        Icon(
                          isInDeliveryPhase ? Icons.home : Icons.store,
                          size: Dimensions.iconSizeSmall,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contextualLabel,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                contextualLocation,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Action buttons row
                    Row(
                      children: [
                        // Navigate button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onNavigate?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.navigation,
                                    size: Dimensions.iconSizeSmall,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    'navigate'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        // View details button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onViewDetails?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.onSurface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                border: Border.all(
                                  color: AppColors.onSurface.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: Dimensions.iconSizeSmall,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    'details'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'urgent':
        return AppColors.error;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.primary; // Use primary color instead of info
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color _getStatusBackgroundColor(String statusColor) {
    switch (statusColor) {
      case 'urgent':
        return AppColors.error.withOpacity(0.1);
      case 'success':
        return AppColors.success.withOpacity(0.1);
      case 'warning':
        return AppColors.warning.withOpacity(0.1);
      case 'info':
        return AppColors.primary
            .withOpacity(0.1); // Use primary color instead of info
      default:
        return AppColors.onSurfaceVariant.withOpacity(0.1);
    }
  }

  Color _getStatusBorderColor(String statusColor) {
    switch (statusColor) {
      case 'urgent':
        return AppColors.error.withOpacity(0.3);
      case 'success':
        return AppColors.success.withOpacity(0.3);
      case 'warning':
        return AppColors.warning.withOpacity(0.3);
      case 'info':
        return AppColors.primary
            .withOpacity(0.3); // Use primary color instead of info
      default:
        return AppColors.onSurfaceVariant.withOpacity(0.3);
    }
  }
}

/// Compact card shimmer widget
class CompactCardShimmerWidget extends StatelessWidget {
  const CompactCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.paddingSizeSmall,
      ),
      height: Dimensions.cardHeightSmall,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusModern),
        color: AppColors.surfaceVariant,
      ),
      child: const AnimatedShimmerWidget(
        enabled: true,
        child: SizedBox(),
      ),
    );
  }
}
