import 'package:flutter/material.dart';
import 'package:shellafood_delivery/features/order/domain/suggested_price_calculator.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// بطاقة «السعر المقترح للشراء» — ملف جديد.
/// تُرشد الكابتن لسعر شراء الطلب من المتجر ليحقق ربحاً (هامش 5%–20%).
class SuggestedPriceCard extends StatelessWidget {
  final double orderPrice;
  const SuggestedPriceCard({super.key, required this.orderPrice});

  @override
  Widget build(BuildContext context) {
    final SuggestedPrice price =
        SuggestedPriceCalculator.calculate(orderPrice);
    final Color green = Theme.of(context).primaryColor;
    final Color divider =
        Theme.of(context).dividerColor.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // سعر الطلب في التطبيق
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سعر الطلب في التطبيق',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault)),
                Text(PriceConverterHelper.convertPrice(price.orderPrice),
                    style: robotoBold.copyWith(fontSize: 18)),
              ],
            ),
          ),
          Divider(height: 1, color: divider),

          // السعر المقترح
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            color: green.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb, color: green, size: 18),
                        const SizedBox(width: 4),
                        Text('السعر المقترح للشراء',
                            style: robotoMedium.copyWith(color: green)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${price.minBuyPrice.toStringAsFixed(0)} — '
                        '${price.maxBuyPrice.toStringAsFixed(0)} ر.س',
                        style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ربحك المتوقع: ${price.minProfit.toStringAsFixed(0)} — '
                    '${price.maxProfit.toStringAsFixed(0)} ر.س',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: divider),

          // تحذير
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            color: Colors.red.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'لا تشتري إذا تجاوز السعر '
                    '${PriceConverterHelper.convertPrice(price.maxBuyPrice)}',
                    style: robotoRegular.copyWith(
                        color: Colors.red.shade700,
                        fontSize: Dimensions.fontSizeSmall),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade600, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
