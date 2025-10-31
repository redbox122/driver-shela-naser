import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';

/// Helper service for smart navigation functionality
/// Handles opening external navigation apps with appropriate destinations
class NavigationHelper {
  /// Opens Google Maps with navigation to the appropriate destination
  /// based on current active order status and type
  static Future<void> navigateToActiveOrderDestination() async {
    try {
      final orderController = Get.find<OrderController>();

      // Check if there are any active orders
      if (orderController.currentOrderList == null ||
          orderController.currentOrderList!.isEmpty) {
        showCustomSnackBar('no_active_orders'.tr);
        return;
      }

      // Refresh current orders to ensure we have the latest status
      await orderController.getCurrentOrders();

      // Small delay to ensure server-side processing is complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check again after refresh
      if (orderController.currentOrderList == null ||
          orderController.currentOrderList!.isEmpty) {
        showCustomSnackBar('no_active_orders'.tr);
        return;
      }

      // Get the first active order
      final activeOrder = orderController.currentOrderList!.first;
      String url;

      // Debug logging
      debugPrint('🧭 Navigation Debug:');
      debugPrint('   Order ID: ${activeOrder.id}');
      debugPrint('   Order Type: ${activeOrder.orderType}');
      debugPrint('   Order Status: ${activeOrder.orderStatus}');
      debugPrint('   Store Lat: ${activeOrder.storeLat}');
      debugPrint('   Store Lng: ${activeOrder.storeLng}');
      debugPrint('   Customer Lat: ${activeOrder.deliveryAddress?.latitude}');
      debugPrint('   Customer Lng: ${activeOrder.deliveryAddress?.longitude}');

      // Check if order is in delivery phase (has food in hand)
      final isInDeliveryPhase =
          activeOrder.orderStatus?.toLowerCase() == 'picked_up' ||
              activeOrder.orderStatus?.toLowerCase() == 'handover';

      // Determine destination based on order status and type
      if (activeOrder.orderType == 'parcel') {
        // For parcel orders
        if (isInDeliveryPhase) {
          // Navigate to receiver location after pickup
          debugPrint(
              '   🎯 Navigating to RECEIVER location (parcel picked up)');
          url = _buildGoogleMapsUrl(
            activeOrder.receiverDetails?.latitude ?? '0',
            activeOrder.receiverDetails?.longitude ?? '0',
          );
        } else {
          // Navigate to pickup location (delivery address for parcel) before pickup
          debugPrint(
              '   🎯 Navigating to PICKUP location (parcel not picked up)');
          url = _buildGoogleMapsUrl(
            activeOrder.deliveryAddress?.latitude ?? '0',
            activeOrder.deliveryAddress?.longitude ?? '0',
          );
        }
      } else {
        // For food orders
        if (isInDeliveryPhase) {
          // Navigate to customer location after pickup
          debugPrint('   🎯 Navigating to CUSTOMER location (food picked up)');
          url = _buildGoogleMapsUrl(
            activeOrder.deliveryAddress?.latitude ?? '0',
            activeOrder.deliveryAddress?.longitude ?? '0',
          );
        } else {
          // Navigate to restaurant location before pickup
          // This includes: pending, confirmed, accepted, processing
          debugPrint(
              '   🎯 Navigating to RESTAURANT location (food not picked up)');
          url = _buildGoogleMapsUrl(
            activeOrder.storeLat ?? '0',
            activeOrder.storeLng ?? '0',
          );
        }
      }

      // Additional validation: If coordinates are invalid, show error
      if (url.contains('destination=0,0')) {
        debugPrint('   ❌ Invalid coordinates detected!');
        showCustomSnackBar('invalid_coordinates'.tr);
        return;
      }

      debugPrint('   🗺️ Final URL: $url');

      // Launch Google Maps
      await _launchNavigationUrl(url);
    } catch (e) {
      debugPrint('Navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Opens Google Maps with navigation to a specific location
  static Future<void> navigateToLocation({
    required String latitude,
    required String longitude,
    String? label,
  }) async {
    try {
      final url = _buildGoogleMapsUrl(latitude, longitude, label: label);
      await _launchNavigationUrl(url);
    } catch (e) {
      debugPrint('Navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Builds Google Maps URL for navigation
  static String _buildGoogleMapsUrl(
    String latitude,
    String longitude, {
    String? label,
  }) {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&mode=d';

    if (label != null && label.isNotEmpty) {
      url += '&destination_place_id=$label';
    }

    return url;
  }

  /// Launches navigation URL in external app
  static Future<void> _launchNavigationUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'could_not_launch'.tr} $url');
    }
  }

  /// Gets destination description for current active order
  static String getActiveOrderDestinationDescription() {
    try {
      final orderController = Get.find<OrderController>();

      if (orderController.currentOrderList == null ||
          orderController.currentOrderList!.isEmpty) {
        return 'no_active_orders'.tr;
      }

      final activeOrder = orderController.currentOrderList!.first;

      // Check if order is in delivery phase (has food in hand)
      final isInDeliveryPhase =
          activeOrder.orderStatus?.toLowerCase() == 'picked_up' ||
              activeOrder.orderStatus?.toLowerCase() == 'handover';

      if (activeOrder.orderType == 'parcel') {
        if (isInDeliveryPhase) {
          return 'navigate_to_receiver'.tr;
        } else {
          return 'navigate_to_pickup_location'.tr;
        }
      } else {
        if (isInDeliveryPhase) {
          return 'navigate_to_customer'.tr;
        } else {
          return 'navigate_to_restaurant'.tr;
        }
      }
    } catch (e) {
      return 'navigation_error'.tr;
    }
  }
}
