import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// بطاقة ملخّص الأرباح — ودجت جديد (إضافة فوق شاشة الحساب، بلا حذف أي موجود).
/// تعرض إجمالي الأرباح بتصميم أخضر شلة + صفوف اليوم/الأسبوع/الشهر + زر «سحب الأرباح».
class EarningsSummaryCardWidget extends StatelessWidget {
  const EarningsSummaryCardWidget({super.key});

  static const Color shellaGreen = Color(0xFF159B53);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      final profile = profileController.profileModel;
      final double balance = profile?.balance ?? 0;
      final Color greenDark =
          Color.lerp(shellaGreen, Colors.black, 0.18) ?? shellaGreen;

      return Column(
        children: [
          // بطاقة الإجمالي الخضراء
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topEnd,
                end: AlignmentDirectional.bottomStart,
                colors: [shellaGreen, greenDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: shellaGreen.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'total_earnings'.tr,
                      style: robotoRegular.copyWith(
                          color: Colors.white70,
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  PriceConverterHelper.convertPrice(balance),
                  style: robotoBold.copyWith(
                      color: Colors.white, fontSize: 30),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // التحويل عبر ماي فاتورة → شاشة طرق السحب لاختيار/إعداد الطريقة
                    onPressed: () =>
                        Get.toNamed(RouteHelper.getWithdrawMethodRoute()),
                    icon: const Icon(Icons.south_west_rounded,
                        color: shellaGreen, size: 20),
                    label: Text(
                      'withdraw_earnings'.tr,
                      style: robotoBold.copyWith(
                          color: shellaGreen,
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          // صفوف الفترات (اليوم / الأسبوع / الشهر)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _periodRow(context, 'today'.tr, profile?.todaysEarning ?? 0),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                _periodRow(
                    context, 'this_week'.tr, profile?.thisWeekEarning ?? 0),
                Divider(
                    height: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                _periodRow(
                    context, 'this_month'.tr, profile?.thisMonthEarning ?? 0),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );
    });
  }

  Widget _periodRow(BuildContext context, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
          Text(
            PriceConverterHelper.convertPrice(amount),
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: shellaGreen),
          ),
        ],
      ),
    );
  }
}
