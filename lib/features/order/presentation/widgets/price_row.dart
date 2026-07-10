import 'package:flutter/material.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// صف مبلغ (عنوان يمين + قيمة يسار) — ملف جديد.
class PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style = (isBold ? robotoBold : robotoRegular).copyWith(
      fontSize: isBold ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
      color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(PriceConverterHelper.convertPrice(value), style: style),
        ],
      ),
    );
  }
}
