import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// Widget to display delivery man status and order availability information
class DeliveryManStatusWidget extends StatelessWidget {
  const DeliveryManStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        return GetBuilder<ProfileController>(
          builder: (profileController) {
            final profile = profileController.profileModel;

            if (profile == null) {
              return _buildStatusCard(
                context,
                'profile_not_loaded'.tr,
                'loading_profile'.tr,
                AppColors.pending,
                Icons.person_outline,
              );
            }

            if (profile.active != 1) {
              return _buildStatusCard(
                context,
                'account_not_active'.tr,
                'contact_support_for_activation'.tr,
                AppColors.offline,
                Icons.account_circle_outlined,
                showRefreshButton: true,
                onRefresh: () => profileController.getProfile(),
              );
            }

            final canShowOrders = orderController.canShowOrders();
            final statusMessage = orderController.getDeliveryManStatusMessage();

            if (!canShowOrders) {
              return _buildStatusCard(
                context,
                'account_not_active'.tr,
                statusMessage,
                AppColors.offline,
                Icons.warning_outlined,
                showRefreshButton: true,
                onRefresh: () => orderController.refreshOrdersWithValidation(),
              );
            }

            return _buildStatusCard(
              context,
              'ready_to_accept_orders'.tr,
              'orders_available_in_your_zone'.tr,
              AppColors.online,
              Icons.check_circle_outline,
              showRefreshButton: true,
              onRefresh: () => orderController.refreshOrdersWithValidation(),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon, {
    bool showRefreshButton = false,
    VoidCallback? onRefresh,
  }) {
    return Container(
      margin: EdgeInsets.all(Dimensions.paddingSizeSmall),
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: color,
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      subtitle,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (showRefreshButton && onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: color,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
