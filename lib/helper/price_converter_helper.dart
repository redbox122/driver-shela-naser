import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';

class PriceConverterHelper {
  /// Returns the currency symbol that should be displayed to the user.
  ///
  /// We first look up the localization key `currency_symbol`. If that key
  /// resolves to a non-empty translated string (i.e. it is not the literal
  /// key returned by GetX when missing) it is used. This is purely a
  /// display-side concern so the same backend currency value can render
  /// as "ر.س" in Arabic and "SAR" in English/Spanish/Bengali without
  /// touching API contracts. When the key is not present we fall back to
  /// the backend-supplied symbol so legacy behaviour is preserved.
  static String _currencySymbol() {
    const String key = 'currency_symbol';
    final String translated = key.tr;
    if (translated.isNotEmpty && translated != key) {
      return translated;
    }
    final backend =
        Get.find<SplashController>().configModel?.currencySymbol ?? '';
    return backend;
  }

  static String convertPrice(double? price,
      {double? discount, String? discountType, int? asFixed}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    final int decimals = asFixed ??
        Get.find<SplashController>().configModel?.digitAfterDecimalPoint ??
        2;
    final String formatted = (price ?? 0)
        .toStringAsFixed(decimals)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return '${_currencySymbol()} $formatted';
  }

  static double convertWithDiscount(
      double price, double discount, String discountType) {
    if (discountType == 'amount') {
      price = price - discount;
    } else if (discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : _currencySymbol()} ${'off'.tr}';
  }
}
