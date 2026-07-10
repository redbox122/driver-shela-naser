import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/helper/navigation_helper.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';

/// Service for handling quick action button functionalities
/// Provides callbacks for all home screen quick action buttons
class QuickActionService {
  static void _safePopDialog() {
    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.maybePop();
    }
  }
  /// Calls customer support using phone dialer
  static Future<void> callSupport() async {
    try {
      const phoneNumber = '+966501234567'; // Support phone number
      final uri = Uri.parse('tel:$phoneNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        showCustomSnackBar('invalid_phone_number_found'.tr);
      }
    } catch (e) {
      debugPrint('Call support error: $e');
      showCustomSnackBar('call_support_error'.tr);
    }
  }

  /// Navigates to earnings history screen
  static void navigateToEarningsHistory() {
    try {
      Get.toNamed(RouteHelper.getCashInHandRoute());
    } catch (e) {
      debugPrint('Earnings navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Navigates to wallet provided earnings screen
  static void navigateToWalletEarnings() {
    try {
      Get.toNamed(RouteHelper.getWalletProvidedEarningRoute());
    } catch (e) {
      debugPrint('Wallet earnings navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Opens navigation to active order destination
  static Future<void> navigateToActiveOrder() async {
    await NavigationHelper.navigateToActiveOrderDestination();
  }

  /// Navigates to help center (terms and conditions)
  static void navigateToHelpCenter() {
    try {
      Get.toNamed(RouteHelper.getTermsRoute());
    } catch (e) {
      debugPrint('Help center navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Navigates to privacy policy
  static void navigateToPrivacyPolicy() {
    try {
      Get.toNamed(RouteHelper.getPrivacyRoute());
    } catch (e) {
      debugPrint('Privacy policy navigation error: $e');
      showCustomSnackBar('navigation_error'.tr);
    }
  }

  /// Shows earnings options dialog
  static void showEarningsOptions() {
    Get.dialog(
      AlertDialog(
        title: Text('earnings'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text('withdraw_earnings'.tr),
              subtitle: Text('withdraw_earnings_hint'.tr),
              onTap: () {
                _safePopDialog();
                navigateToEarningsHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text('wallet_earnings'.tr),
              subtitle: Text('view_wallet_provided_earnings'.tr),
              onTap: () {
                _safePopDialog();
                navigateToWalletEarnings();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _safePopDialog(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  /// Shows help options dialog
  static void showHelpOptions() {
    Get.dialog(
      AlertDialog(
        title: Text('help_center'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: Text('terms_and_conditions'.tr),
              subtitle: Text('view_terms_and_conditions'.tr),
              onTap: () {
                _safePopDialog();
                navigateToHelpCenter();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text('privacy_policy'.tr),
              subtitle: Text('view_privacy_policy'.tr),
              onTap: () {
                _safePopDialog();
                navigateToPrivacyPolicy();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _safePopDialog(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }
}
