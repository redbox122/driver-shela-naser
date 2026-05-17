import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shellafood_delivery/util/app_constants.dart';

/// Store QR driver referral token from Google Play Install Referrer.
/// Token is persisted until driver registration succeeds (HTTP 200).
class DriverQrReferralHelper {
  DriverQrReferralHelper._();

  static const String _referralTypeDriver = 'driver';

  /// Reads Play Install Referrer on Android and stores a valid driver token.
  static Future<void> initFromInstallReferrer(
      SharedPreferences sharedPreferences) async {
    debugPrint('[QR_REFERRAL_INSTALL_REFERRER_INIT]');
    if (!GetPlatform.isAndroid) {
      debugPrint(
          '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=not_android');
      return;
    }
    if (_hasStoredToken(sharedPreferences)) {
      debugPrint(
          '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=token_already_stored');
      return;
    }
    try {
      final ReferrerDetails referrerDetails =
          await PlayInstallReferrer.installReferrer;
      final String? rawReferrer = referrerDetails.installReferrer;
      if (rawReferrer == null || rawReferrer.trim().isEmpty) {
        debugPrint(
            '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=empty_referrer');
        return;
      }
      debugPrint('[QR_REFERRAL_INSTALL_REFERRER_RAW] referrer=$rawReferrer');
      final Map<String, String> params = _parseReferrerQuery(rawReferrer);
      final String? referralType = params['referral_type']?.trim();
      final String? referralToken = params['referral_token']?.trim();
      debugPrint(
          '[QR_REFERRAL_INSTALL_REFERRER_PARSED] referral_type=$referralType '
          'referral_token_present=${referralToken != null && referralToken.isNotEmpty}');
      if (referralType != _referralTypeDriver) {
        debugPrint(
            '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=referral_type_not_driver '
            'referral_type=$referralType');
        return;
      }
      if (referralToken == null || referralToken.isEmpty) {
        debugPrint(
            '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=empty_referral_token');
        return;
      }
      if (_hasStoredToken(sharedPreferences)) {
        debugPrint(
            '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=token_already_stored');
        return;
      }
      await sharedPreferences.setString(
          AppConstants.driverQrReferralToken, referralToken);
      debugPrint(
          '[QR_REFERRAL_INSTALL_REFERRER_STORED] token=$referralToken');
    } catch (error) {
      debugPrint(
          '[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=retrieval_failed '
          'error=${error.runtimeType}');
    }
  }

  static String? getStoredToken(SharedPreferences sharedPreferences) {
    final String? token =
        sharedPreferences.getString(AppConstants.driverQrReferralToken);
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return token.trim();
  }

  static Future<void> clearStoredToken(
      SharedPreferences sharedPreferences) async {
    await sharedPreferences.remove(AppConstants.driverQrReferralToken);
    debugPrint('[QR_REFERRAL_DRIVER_REGISTER_TOKEN_CLEARED]');
  }

  static bool _hasStoredToken(SharedPreferences sharedPreferences) {
    return getStoredToken(sharedPreferences) != null;
  }

  static Map<String, String> _parseReferrerQuery(String rawReferrer) {
    final String normalized = rawReferrer.trim();
    if (normalized.isEmpty) {
      return <String, String>{};
    }
    final int queryStart = normalized.indexOf('?');
    final String queryPart = queryStart >= 0
        ? normalized.substring(queryStart + 1)
        : normalized;
    return Map<String, String>.from(Uri.splitQueryString(queryPart));
  }
}
