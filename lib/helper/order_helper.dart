import 'package:flutter/foundation.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:get/get.dart';

/// Order helper utility class for sorting and priority management
/// Provides methods to determine order priority and sort orders accordingly
class OrderHelper {
  /// Maximum number of orders a delivery person can handle simultaneously
  /// This can be configured based on business rules or delivery person capacity
  static const int maxOrdersPerDeliveryMan = 2;

  /// Check if delivery person has reached maximum order capacity
  /// Returns true if they cannot accept more orders
  static bool hasReachedMaxCapacity(List<OrderModel> currentOrders) {
    return currentOrders.length >= maxOrdersPerDeliveryMan;
  }

  /// Get remaining order capacity for delivery person
  /// Returns how many more orders they can accept
  static int getRemainingCapacity(List<OrderModel> currentOrders) {
    return maxOrdersPerDeliveryMan - currentOrders.length;
  }

  /// Check if delivery person can accept new orders
  /// Returns true if they have capacity for more orders
  static bool canAcceptNewOrders(List<OrderModel> currentOrders) {
    return !hasReachedMaxCapacity(currentOrders);
  }

  /// Get priority level for order (1 = highest, 3 = lowest)
  /// Priority 1: Orders that are accepted (first order delivery person accepted)
  /// Priority 2: Orders that are picked up or confirmed (in progress)
  /// Priority 3: Orders that are pending (just assigned)
  static int getOrderPriority(OrderModel order) {
    switch (order.orderStatus?.toLowerCase()) {
      case 'accepted':
        return 1; // HIGHEST - First order delivery person accepted
      case 'picked_up':
      case 'handover':
      case 'confirmed':
        return 2; // MEDIUM - In progress orders
      case 'pending':
        return 3; // LOW - Just assigned
      default:
        return 4; // Unknown status, lowest priority
    }
  }

  /// Sort orders by priority (accepted orders first)
  /// Returns a new sorted list with highest priority orders first
  static List<OrderModel> sortOrdersByPriority(List<OrderModel> orders) {
    final sortedOrders = List<OrderModel>.from(orders);
    sortedOrders
        .sort((a, b) => getOrderPriority(a).compareTo(getOrderPriority(b)));

    // Debug: Print sorting results
    debugPrint('🔍 ORDER SORTING DEBUG:');
    for (var order in sortedOrders) {
      debugPrint(
          'Order #${order.id}: Status=${order.orderStatus}, Priority=${getOrderPriority(order)}');
    }

    return sortedOrders;
  }

  /// Check if order is in delivery phase (has food)
  /// Returns true if delivery person already has the food and needs to deliver
  static bool isInDeliveryPhase(OrderModel order) {
    return order.orderStatus?.toLowerCase() == 'picked_up' ||
        order.orderStatus?.toLowerCase() == 'handover';
  }

  /// Check if order is in pickup phase (needs to get food)
  /// Returns true if order is confirmed and needs pickup from restaurant
  static bool isInPickupPhase(OrderModel order) {
    return order.orderStatus?.toLowerCase() == 'accepted' ||
        order.orderStatus?.toLowerCase() == 'confirmed';
  }

  /// Get contextual location for order based on its status
  /// Returns customer address if picked up, restaurant address if confirmed
  static String getContextualLocation(OrderModel order) {
    if (isInDeliveryPhase(order)) {
      // Order is picked up - show customer delivery address
      return order.deliveryAddress?.address ?? 'address_not_found'.tr;
    } else if (isInPickupPhase(order)) {
      // Order needs pickup - show restaurant address
      return order.storeAddress ?? 'address_not_found'.tr;
    } else {
      // Default to restaurant address
      return order.storeAddress ?? 'address_not_found'.tr;
    }
  }

  /// Get contextual icon for order based on its status
  /// Returns home icon if picked up, store icon if confirmed
  static String getContextualIconName(OrderModel order) {
    if (isInDeliveryPhase(order)) {
      return 'home'; // Customer location
    } else {
      return 'store'; // Restaurant location
    }
  }

  /// Get contextual label for order based on its status
  /// Returns "Deliver to" if picked up, "Pickup from" if confirmed
  static String getContextualLabel(OrderModel order) {
    if (isInDeliveryPhase(order)) {
      return 'deliver_to'.tr;
    } else {
      return 'pickup_from'.tr;
    }
  }

  /// Check if order should be marked as urgent
  /// Orders are urgent if they are accepted (first order) or picked up (has food)
  static bool isUrgentOrder(OrderModel order) {
    return order.orderStatus?.toLowerCase() == 'accepted' ||
        isInDeliveryPhase(order) ||
        order.orderStatus?.toLowerCase() == 'pending';
  }

  /// Get status color for order based on its status
  /// Returns appropriate color for status badges
  static String getStatusColor(OrderModel order) {
    switch (order.orderStatus?.toLowerCase()) {
      case 'accepted':
        return 'urgent'; // Red/orange for accepted (first order)
      case 'picked_up':
      case 'handover':
        return 'urgent'; // Red/orange for urgent
      case 'confirmed':
        return 'success'; // Green for confirmed
      case 'pending':
        return 'info'; // Blue for pending
      default:
        return 'neutral'; // Gray for unknown
    }
  }
}
