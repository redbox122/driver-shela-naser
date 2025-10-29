import 'package:get/get.dart';
import 'package:shellafood_delivery/common/models/error_response.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/common/widgets/custom_alert_dialog_widget.dart';

/// Service to handle API error responses with specific error codes
/// Provides user-friendly error messages and appropriate actions
class ErrorHandlerService {
  /// Handle order acceptance errors with specific error codes
  static void handleOrderAcceptanceError(dynamic response) {
    try {
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        final errorResponse = ErrorResponse.fromJson(response);
        final errors = errorResponse.errors ?? [];

        for (final error in errors) {
          _handleSpecificError(error.code, error.message);
        }
      } else {
        // Fallback for generic errors
        showCustomSnackBar('order_acceptance_failed'.tr, isError: true);
      }
    } catch (e) {
      // Ultimate fallback
      showCustomSnackBar('something_went_wrong'.tr, isError: true);
    }
  }

  /// Handle specific error codes from the backend
  static void _handleSpecificError(String? code, String? message) {
    switch (code) {
      case 'zone_mismatch':
        _showZoneMismatchError();
        break;
      case 'store_zone_mismatch':
        _showStoreZoneMismatchError();
        break;
      case 'store_mismatch':
        _showStoreMismatchError();
        break;
      case 'invalid_order_type':
        _showInvalidOrderTypeError();
        break;
      case 'application_status':
        _showApplicationStatusError();
        break;
      case 'account_status':
        _showAccountStatusError();
        break;
      case 'order_already_taken':
        _showOrderAlreadyTakenError();
        break;
      case 'insufficient_permissions':
        _showInsufficientPermissionsError();
        break;
      default:
        // Show the specific message from backend or generic message
        showCustomSnackBar(message ?? 'order_acceptance_failed'.tr,
            isError: true);
    }
  }

  /// Zone mismatch error - order not in delivery man's zone
  static void _showZoneMismatchError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'this_order_is_not_in_your_delivery_zone'.tr,
        onOkPressed: () {
          Get.back();
          // Refresh order list to show only valid orders
          Get.find<OrderController>().getLatestOrders();
        },
      ),
    );
  }

  /// Store zone mismatch error - store doesn't serve delivery man's zone
  static void _showStoreZoneMismatchError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'store_does_not_serve_your_zone'.tr,
        onOkPressed: () {
          Get.back();
          Get.find<OrderController>().getLatestOrders();
        },
      ),
    );
  }

  /// Store mismatch error - order not from delivery man's assigned store
  static void _showStoreMismatchError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'order_not_from_your_assigned_store'.tr,
        onOkPressed: () {
          Get.back();
          Get.find<OrderController>().getLatestOrders();
        },
      ),
    );
  }

  /// Invalid order type error - take-away orders shouldn't be assigned to delivery men
  static void _showInvalidOrderTypeError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'take_away_orders_do_not_require_delivery'.tr,
        onOkPressed: () {
          Get.back();
          Get.find<OrderController>().getLatestOrders();
        },
      ),
    );
  }

  /// Application status error - delivery man account not approved
  static void _showApplicationStatusError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'your_account_is_pending_approval'.tr,
        onOkPressed: () {
          Get.back();
          // Navigate to profile screen
          Get.toNamed('/profile');
        },
      ),
    );
  }

  /// Account status error - delivery man account suspended
  static void _showAccountStatusError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'your_account_has_been_suspended'.tr,
        onOkPressed: () {
          Get.back();
          // Navigate to support screen
          Get.toNamed('/support');
        },
      ),
    );
  }

  /// Order already taken error - race condition
  static void _showOrderAlreadyTakenError() {
    showCustomSnackBar('order_has_already_been_accepted_by_another_driver'.tr,
        isError: true);
    // Refresh order list immediately
    Get.find<OrderController>().getLatestOrders();
  }

  /// Insufficient permissions error
  static void _showInsufficientPermissionsError() {
    Get.dialog(
      CustomAlertDialogWidget(
        description: 'you_do_not_have_permission_to_accept_this_order'.tr,
        onOkPressed: () {
          Get.back();
          Get.find<OrderController>().getLatestOrders();
        },
      ),
    );
  }

  /// Handle generic API errors
  static void handleGenericError(dynamic response, {String? fallbackMessage}) {
    try {
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        final errorResponse = ErrorResponse.fromJson(response);
        final errors = errorResponse.errors ?? [];

        if (errors.isNotEmpty) {
          showCustomSnackBar(
              errors.first.message ??
                  fallbackMessage ??
                  'something_went_wrong'.tr,
              isError: true);
        } else {
          showCustomSnackBar(fallbackMessage ?? 'something_went_wrong'.tr,
              isError: true);
        }
      } else {
        showCustomSnackBar(fallbackMessage ?? 'something_went_wrong'.tr,
            isError: true);
      }
    } catch (e) {
      showCustomSnackBar(fallbackMessage ?? 'something_went_wrong'.tr,
          isError: true);
    }
  }
}
