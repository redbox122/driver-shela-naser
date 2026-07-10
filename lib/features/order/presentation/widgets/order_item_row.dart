import 'package:flutter/material.dart';
import 'package:shellafood_delivery/common/widgets/custom_image_widget.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_details_model.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// صف عنصر واحد في «تفاصيل الطلب» — ملف جديد.
/// يعرض: الكمية + الاسم + الصورة + التنويعات (└ الاسم: الخيار) + الإضافات (└ إضافة: الاسم) + السعر.
/// يستخدم OrderDetailsModel الموجود (لا نموذج موازٍ).
class OrderItemRow extends StatelessWidget {
  final OrderDetailsModel item;
  const OrderItemRow({super.key, required this.item});

  /// أسطر التنويعات: من foodVariation (الاسم: الخيار) ومن variation (النوع).
  List<String> _variationLines() {
    final List<String> lines = [];
    if (item.foodVariation != null) {
      for (final fv in item.foodVariation!) {
        if (fv.variationValues != null) {
          for (final v in fv.variationValues!) {
            final String name = fv.name ?? '';
            final String level = v.level ?? '';
            if (level.isNotEmpty) {
              lines.add(name.isNotEmpty ? '$name: $level' : level);
            }
          }
        }
      }
    }
    if (item.variation != null) {
      for (final v in item.variation!) {
        if ((v.type ?? '').isNotEmpty) lines.add(v.type!);
      }
    }
    // احتياط: نص التنويعة المجمّع إن لم نجد تفاصيل
    if (lines.isEmpty && (item.variant ?? '').isNotEmpty) {
      lines.add(item.variant!);
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final String name = item.itemDetails?.name ?? '';
    final String image = item.itemDetails?.imageFullUrl ?? '';
    final List<String> variationLines = _variationLines();
    final List<AddOn> addOns = item.addOns ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // الكمية (يسار) + [الاسم + الخيارات + الإضافات] عمود (يمين) + الصورة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.quantity ?? 1}x',
                style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeDefault),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.end,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault),
                          ),
                          // التنويعات (└ الاسم: الخيار) — تحت الاسم مباشرة
                          for (final line in variationLines)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 3, right: 8),
                              child: Text(
                                '└ $line',
                                textAlign: TextAlign.end,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor),
                              ),
                            ),
                          // الإضافات (└ + إضافة: الاسم)
                          for (final addOn in addOns)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 3, right: 8),
                              child: Text(
                                '└ + إضافة: ${addOn.name ?? ''}'
                                '${(addOn.quantity ?? 1) > 1 ? ' (x${addOn.quantity})' : ''}',
                                textAlign: TextAlign.end,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.green.shade700),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      child: image.isNotEmpty
                          ? CustomImageWidget(
                              image: image,
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover)
                          : Container(
                              height: 48,
                              width: 48,
                              alignment: Alignment.center,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.08),
                              child: Icon(Icons.fastfood,
                                  size: 22,
                                  color: Theme.of(context).primaryColor),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // السعر (يسار)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                PriceConverterHelper.convertPrice(item.price ?? 0),
                style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeDefault),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
