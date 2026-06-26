import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';

/// شله كابتن — حالة «غير متاح»: تظهر في الرئيسية عندما يكون الكابتن offline.
/// لا تظهر أي طلبات وهو غير متاح؛ زر التفعيل يحوّل الحالة إلى متاح ويبدأ بثّ الموقع.
class CaptainOfflineView extends StatelessWidget {
  final VoidCallback onActivate;
  const CaptainOfflineView({super.key, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeExtraLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          // رسمة الحالة (أيقونة دائرية هادئة بلون الخمول)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.offline.withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.offline.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.bedtime_outlined,
                  size: 56, color: AppColors.offline),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            'not_available_to_receive_orders'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'turn_status_active_to_receive_captain_orders'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          CustomButtonWidget(
            buttonText: 'activate_order_reception'.tr,
            icon: Icons.power_settings_new,
            onPressed: onActivate,
          ),
        ],
      ),
    );
  }
}
