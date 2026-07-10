import 'package:flutter/material.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_details_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/order/presentation/widgets/order_item_row.dart';
import 'package:shellafood_delivery/features/order/presentation/widgets/price_row.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// بطاقة «تفاصيل الطلب» الكاملة — ملف جديد (إضافة تحت بطاقة تفاصيل الاتصال بالعميل).
/// تعرض عناصر الطلب (بتنويعاتها وإضافاتها) + ملخّص المبالغ + طريقة الدفع.
class OrderItemsDetailsCard extends StatelessWidget {
  final OrderModel order;
  final List<OrderDetailsModel> items;

  const OrderItemsDetailsCard({
    super.key,
    required this.order,
    required this.items,
  });

  String _paymentMethod(String? method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'نقداً';
      case 'digital_payment':
        return 'دفع إلكتروني';
      case 'wallet':
        return 'المحفظة';
      case 'partial_payment':
        return 'دفع جزئي';
      case 'offline_payment':
        return 'دفع بنكي';
      default:
        return method ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double total = order.orderAmount ?? 0;
    final double delivery = order.deliveryCharge ?? 0;
    final double subTotal = (total - delivery) < 0 ? 0 : (total - delivery);
    final Color divider =
        Theme.of(context).dividerColor.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Icon(Icons.receipt_long,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text('تفاصيل الطلب',
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
              ],
            ),
          ),
          Divider(height: 1, color: divider),

          // العناصر
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: Dimensions.paddingSizeDefault,
                endIndent: Dimensions.paddingSizeDefault,
                color: divider),
            itemBuilder: (_, i) => OrderItemRow(item: items[i]),
          ),
          Divider(height: 1, color: divider),

          // ملخّص المبالغ
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                PriceRow(label: 'المجموع', value: subTotal),
                PriceRow(label: 'رسوم التوصيل', value: delivery),
                Divider(color: divider),
                PriceRow(
                  label: 'الإجمالي',
                  value: total,
                  isBold: true,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طريقة الدفع',
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                    Text(_paymentMethod(order.paymentMethod),
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).hintColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
