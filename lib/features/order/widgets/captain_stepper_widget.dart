import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// كابتن شله — مؤشر الخطوات الأربع لتوضيح تسلسل الطلب للكابتن:
/// (١) التوجه للاستلام → (٢) إصدار فاتورة → (٣) استلام من المتجر → (٤) التوصيل والتسليم
class CaptainStepperWidget extends StatelessWidget {
  final String? orderStatus;
  final bool invoiceIssued;
  const CaptainStepperWidget(
      {super.key, required this.orderStatus, this.invoiceIssued = false});

  static const List<String> _labels = [
    'الاستلام',
    'الفاتورة',
    'استلام المتجر',
    'التسليم',
  ];

  int _currentStep() {
    final s = (orderStatus ?? '').toLowerCase();
    if (s == 'picked_up' || s == 'delivered') return 3; // التسليم
    if (s == 'handover') return 2; // استلام المتجر
    if (invoiceIssued) return 2; // الفاتورة صدرت → جاهز للاستلام
    return 1; // confirmed/accepted → إصدار الفاتورة
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final current = _currentStep();
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: primary.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: primary.withValues(alpha:0.15)),
      ),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // connector line between circles
            final stepBefore = i ~/ 2;
            final done = stepBefore < current;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? primary : Theme.of(context).disabledColor.withValues(alpha:0.3),
              ),
            );
          }
          final step = i ~/ 2;
          final done = step < current;
          final active = step == current;
          final Color circleColor = (done || active)
              ? primary
              : Theme.of(context).disabledColor.withValues(alpha:0.25);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 15)
                    : Text('${step + 1}',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: active ? primary : circleColor)),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 62,
                child: Text(
                  _labels[step],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: (done || active)
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
