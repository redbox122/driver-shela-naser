import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/profile/domain/models/profile_model.dart';

/// Service to filter orders based on delivery man's permissions and restrictions
/// Implements client-side security to prevent showing orders that cannot be accepted
class OrderFilterService {
  /// Filter latest orders based on delivery man's zone and restrictions
  static List<OrderModel> filterLatestOrders(
      List<OrderModel> orders, ProfileModel? deliveryManProfile) {
    if (deliveryManProfile == null) {
      return [];
    }

    return orders
        .where((order) => _canAcceptOrder(order, deliveryManProfile))
        .toList();
  }

  /// Check if delivery man can accept a specific order
  static bool _canAcceptOrder(
      OrderModel order, ProfileModel deliveryManProfile) {
    // 1. Check delivery man status
    if (!_isDeliveryManActive(deliveryManProfile)) {
      return false;
    }

    // 2. Check order type restrictions
    if (!_isValidOrderType(order)) {
      return false;
    }

    // 3. Check zone restrictions for zone-wise delivery men
    if (!_isOrderInValidZone(order, deliveryManProfile)) {
      return false;
    }

    // 4. Check if order is already assigned
    if (_isOrderAlreadyAssigned(order)) {
      return false;
    }

    return true;
  }

  /// Check if delivery man is active and approved
  static bool _isDeliveryManActive(ProfileModel deliveryManProfile) {
    // Check if delivery man is active (status = 1)
    if (deliveryManProfile.active != 1) {
      return false;
    }

    // Additional checks can be added here for application status
    // For now, we assume active = 1 means approved
    return true;
  }

  /// Check if order type is valid for delivery men
  static bool _isValidOrderType(OrderModel order) {
    // Take-away orders should not be shown to delivery men
    if (order.orderType == 'take_away') {
      return false;
    }

    // Only show delivery orders
    return order.orderType == 'delivery' || order.orderType == null;
  }

  /// Check if order is in delivery man's valid zone
  static bool _isOrderInValidZone(
      OrderModel order, ProfileModel deliveryManProfile) {
    // If delivery man has no zone assigned, they can accept any order
    if (deliveryManProfile.zoneId == null) {
      return true;
    }

    // For zone-wise delivery men, check if order's zone matches
    if (deliveryManProfile.type == 'zone_wise') {
      // Check if order has zone information
      if (order.deliveryAddress?.zoneId != null) {
        return order.deliveryAddress!.zoneId == deliveryManProfile.zoneId;
      }

      // If order doesn't have zone info, we can't determine validity
      // Let the backend handle this case
      return true;
    }

    // For restaurant-wise delivery men, check store assignment
    if (deliveryManProfile.type == 'restaurant_wise') {
      // This would require store_id in profile model
      // For now, let backend handle store-wise validation
      return true;
    }

    // Default: allow all orders (backend will validate)
    return true;
  }

  /// Check if order is already assigned to another delivery man
  static bool _isOrderAlreadyAssigned(OrderModel order) {
    return order.deliveryManId != null && order.deliveryManId != 0;
  }

  /// Get filtered orders count for UI display
  static int getFilteredOrdersCount(
      List<OrderModel> orders, ProfileModel? deliveryManProfile) {
    return filterLatestOrders(orders, deliveryManProfile).length;
  }

  /// Check if delivery man should see any orders at all
  static bool shouldShowOrders(ProfileModel? deliveryManProfile) {
    if (deliveryManProfile == null) {
      return false;
    }

    // Don't show orders if delivery man is not active
    if (deliveryManProfile.active != 1) {
      return false;
    }

    return true;
  }

  /// Get status message for delivery man
  static String getDeliveryManStatusMessage(ProfileModel? deliveryManProfile) {
    if (deliveryManProfile == null) {
      return 'profile_not_loaded'.tr;
    }

    if (deliveryManProfile.active != 1) {
      return 'account_not_active'.tr;
    }

    return 'ready_to_accept_orders'.tr;
  }
}
