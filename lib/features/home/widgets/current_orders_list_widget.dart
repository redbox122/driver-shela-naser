import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/helper/order_helper.dart';
import 'package:shellafood_delivery/features/home/widgets/hero_order_card_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/compact_order_card_widget.dart';
import 'package:shellafood_delivery/features/order/screens/order_details_screen.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/common/services/quick_action_service.dart';
import 'package:get/get.dart';

/// Main widget managing all active orders display
/// Shows hero card for highest priority order and expandable list for others
class CurrentOrdersListWidget extends StatefulWidget {
  final List<OrderModel> orders;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const CurrentOrdersListWidget({
    super.key,
    required this.orders,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<CurrentOrdersListWidget> createState() =>
      _CurrentOrdersListWidgetState();
}

class _CurrentOrdersListWidgetState extends State<CurrentOrdersListWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true; // Secondary orders list expanded by default
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start expanded by default
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const OrdersListShimmerWidget();
    }

    if (widget.orders.isEmpty) {
      return _buildEmptyState();
    }

    final sortedOrders = OrderHelper.sortOrdersByPriority(widget.orders);
    final primaryOrder = sortedOrders.first;
    final secondaryOrders = sortedOrders.skip(1).toList();

    return Column(
      children: [
        // Primary order (hero card)
        HeroOrderCardWidget(
          orderModel: primaryOrder,
          isRunningOrder: true,
          orderIndex: 0,
          onNavigate: () => _navigateToOrder(primaryOrder),
          onViewDetails: () => _viewOrderDetails(primaryOrder, 0),
        ),

        // Secondary orders (collapsible list)
        if (secondaryOrders.isNotEmpty)
          _buildSecondaryOrdersSection(secondaryOrders),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Card(
        elevation: Dimensions.elevationMedium,
        color: Colors.black87, // Dark background for visibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delivery_dining_rounded,
                  size: Dimensions.iconSizeHero + 8,
                  color: Colors.white, // White icon for contrast
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'no_active_orders'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Colors.white, // White text for visibility
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'You will be notified when new orders arrive',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color:
                      Colors.white.withOpacity(0.8), // Light white for subtitle
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryOrdersSection(List<OrderModel> secondaryOrders) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Card(
        elevation: Dimensions.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusModern),
        ),
        child: Column(
          children: [
            // Header with expand/collapse button
            InkWell(
              onTap: _toggleExpansion,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusModern),
                topRight: Radius.circular(Dimensions.radiusModern),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: Dimensions.iconSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'other_orders'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      ' (${secondaryOrders.length})',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    // Capacity indicator - only show if there are assigned orders
                    if (widget.orders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color:
                              OrderHelper.hasReachedMaxCapacity(widget.orders)
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(
                            color:
                                OrderHelper.hasReachedMaxCapacity(widget.orders)
                                    ? AppColors.error.withOpacity(0.3)
                                    : AppColors.success.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          OrderHelper.hasReachedMaxCapacity(widget.orders)
                              ? 'max_capacity'.tr
                              : 'capacity_${OrderHelper.getRemainingCapacity(widget.orders)}'
                                  .tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color:
                                OrderHelper.hasReachedMaxCapacity(widget.orders)
                                    ? AppColors.error
                                    : AppColors.success,
                          ),
                        ),
                      ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: Dimensions.iconSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  const Divider(height: 1),
                  ...secondaryOrders.asMap().entries.map((entry) {
                    final index = entry.key;
                    final order = entry.value;
                    return CompactOrderCardWidget(
                      orderModel: order,
                      orderIndex:
                          index + 1, // +1 because primary order is index 0
                      onNavigate: () => _navigateToOrder(order),
                      onViewDetails: () => _viewOrderDetails(order, index + 1),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrder(OrderModel order) {
    QuickActionService.navigateToActiveOrder();
  }

  void _viewOrderDetails(OrderModel order, int orderIndex) {
    Get.toNamed(
      RouteHelper.getOrderDetailsRoute(order.id),
      arguments: OrderDetailsScreen(
        orderId: order.id,
        isRunningOrder: true,
        orderIndex: orderIndex,
      ),
    );
  }
}

/// Shimmer widget for orders list loading state
class OrdersListShimmerWidget extends StatelessWidget {
  const OrdersListShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero card shimmer
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHero,
            vertical: Dimensions.paddingSizeSmall,
          ),
          height: Dimensions.cardHeightHero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusHero),
            color: Colors.grey[300],
          ),
        ),
        // Secondary cards shimmer
        ...List.generate(
            2,
            (index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeHero,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  height: Dimensions.cardHeightSmall,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusModern),
                    color: Colors.grey[300],
                  ),
                )),
      ],
    );
  }
}
