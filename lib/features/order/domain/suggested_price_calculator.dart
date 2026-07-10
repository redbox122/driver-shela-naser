// حاسبة السعر المقترح للشراء — ملف جديد.
// الكابتن يشتري الطلب من المتجر بسعر أقل من سعر التطبيق ليحقق ربحاً.
// الهامش: 5% (حد أدنى للربح) إلى 20% (ربح مثالي).

class SuggestedPrice {
  final double orderPrice;
  final double minBuyPrice; // أفضل سعر شراء (هامش 20%)
  final double maxBuyPrice; // أعلى سعر شراء مقبول (هامش 5%)
  final double minProfit;
  final double maxProfit;

  const SuggestedPrice({
    required this.orderPrice,
    required this.minBuyPrice,
    required this.maxBuyPrice,
    required this.minProfit,
    required this.maxProfit,
  });
}

class SuggestedPriceCalculator {
  static const double minMargin = 0.05; // 5%
  static const double maxMargin = 0.20; // 20%

  static SuggestedPrice calculate(double orderPrice) {
    final double safePrice = orderPrice < 0 ? 0 : orderPrice;
    final double maxBuyPrice = safePrice * (1 - minMargin);
    final double idealBuyPrice = safePrice * (1 - maxMargin);
    return SuggestedPrice(
      orderPrice: safePrice,
      minBuyPrice: idealBuyPrice,
      maxBuyPrice: maxBuyPrice,
      minProfit: safePrice - maxBuyPrice,
      maxProfit: safePrice - idealBuyPrice,
    );
  }
}
