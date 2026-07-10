import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/common/widgets/animated_shimmer_widget.dart';
import 'package:get/get.dart';

/// Financial overview widget combining earnings and cash in hand
/// Features glass morphism effect and modern card design
class FinancialOverviewWidget extends StatelessWidget {
  final double? balance;
  final double? cashInHand;
  final double? todaysEarning;
  final double? thisWeekEarning;
  final double? thisMonthEarning;
  final VoidCallback? onBalanceTap;
  final VoidCallback? onCashInHandTap;
  final VoidCallback? onEarningsTap;
  final bool isLoading;
  final bool showWarning;

  const FinancialOverviewWidget({
    super.key,
    this.balance,
    this.cashInHand,
    this.todaysEarning,
    this.thisWeekEarning,
    this.thisMonthEarning,
    this.onBalanceTap,
    this.onCashInHandTap,
    this.onEarningsTap,
    this.isLoading = false,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const FinancialOverviewShimmerWidget();
    }
    debugPrint('[DM_WALLET_UI_BUILD] financial_overview');

    return Semantics(
      label: 'financial_overview'.tr,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHero,
          vertical: Dimensions.cardSpacingVertical,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: Dimensions.blurRadiusMedium,
              sigmaY: Dimensions.blurRadiusMedium,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87, // Dark background for visibility
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                  color: Colors.white
                      .withValues(alpha: 0.2), // Light border for contrast
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLayer2,
                    blurRadius: Dimensions.elevationMedium,
                    offset: const Offset(
                        Dimensions.shadowOffsetX, Dimensions.shadowOffsetY / 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEarningsTap,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(
                      children: [
                        // Main balance and cash in hand row
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: onBalanceTap,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                                alpha:
                                                    0.1), // Light background for dark card
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusModern),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: Dimensions.iconSizeDefault,
                                            color: Colors
                                                .white, // White icon for visibility
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Text(
                                          'balance'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white.withValues(
                                                alpha:
                                                    0.8), // White text for visibility
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CurrencyAmountText(
                                      amount: balance,
                                      label: 'balance',
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDisplay,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(
                                        alpha:
                                            0.2), // White separator for dark card
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: onCashInHandTap,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                                alpha:
                                                    0.1), // Light background for dark card
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusModern),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.account_balance_outlined,
                                            size: Dimensions.iconSizeDefault,
                                            color: Colors
                                                .white, // White icon for visibility
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Text(
                                          'withdraw_earnings'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white.withValues(
                                                alpha:
                                                    0.8), // White text for visibility
                                          ),
                                        ),
                                        if (showWarning) ...[
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              border: Border.all(
                                                color: AppColors.warning
                                                    .withValues(alpha: 0.3),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.warning_outlined,
                                              size: Dimensions.iconSizeSmall,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    // بدل مبلغ «النقد في اليد»: إجراء «اسحب الآن»
                                    // (النموذج رقمي — التحويل عبر ماي فاتورة)
                                    Row(
                                      children: [
                                        Text(
                                          'withdraw_now'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeLarge,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_left,
                                            size: 18, color: Colors.white),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        // Earnings breakdown row
                        Row(
                          children: [
                            Expanded(
                              child: _EarningItemWidget(
                                title: 'today'.tr,
                                amount: todaysEarning,
                              ),
                            ),
                            Container(
                              width: 1.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(
                                        alpha:
                                            0.15), // White separator for dark card
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _EarningItemWidget(
                                title: 'this_week'.tr,
                                amount: thisWeekEarning,
                              ),
                            ),
                            Container(
                              width: 1.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(
                                        alpha:
                                            0.15), // White separator for dark card
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _EarningItemWidget(
                                title: 'this_month'.tr,
                                amount: thisMonthEarning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual earning item widget
class _EarningItemWidget extends StatelessWidget {
  final String title;
  final double? amount;

  const _EarningItemWidget({
    required this.title,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Colors.white
                .withValues(alpha: 0.8), // White text for visibility
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        _CurrencyAmountText(
          amount: amount,
          label: title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Compact financial overview for smaller spaces
class CompactFinancialOverviewWidget extends StatelessWidget {
  final double? balance;
  final double? cashInHand;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool showWarning;

  const CompactFinancialOverviewWidget({
    super.key,
    this.balance,
    this.cashInHand,
    this.onTap,
    this.isLoading = false,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CardShimmerWidget(
        height: Dimensions.cardHeightSmall,
        borderRadius:
            BorderRadius.all(Radius.circular(Dimensions.radiusModern)),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'financial_summary'.tr,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHero,
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusModern),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.elevationLow,
                blurRadius: Dimensions.elevationLow,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'balance'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    _CurrencyAmountText(
                      amount: balance,
                      label: 'balance',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.0,
                height: 40.0,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.2)
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'cash_in_hand'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isDark
                                ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        if (showWarning) ...[
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Icon(
                            Icons.warning,
                            size: Dimensions.iconSizeSmall,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    _CurrencyAmountText(
                      amount: cashInHand,
                      label: 'cash_in_hand',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyAmountText extends StatelessWidget {
  final double? amount;
  final String label;
  final TextStyle style;

  const _CurrencyAmountText({
    required this.amount,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final String renderedAmount = amount != null
        ? PriceConverterHelper.convertPrice(amount!)
        : PriceConverterHelper.convertPrice(0);
    debugPrint('[DM_WALLET_UI_AMOUNT_RENDER] label=$label amount=$amount');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            renderedAmount,
            style: style,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

/// Financial overview shimmer widget
class FinancialOverviewShimmerWidget extends StatelessWidget {
  const FinancialOverviewShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.paddingSizeSmall,
      ),
      height: Dimensions.cardHeightMedium,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusModern),
        color: AppColors.surfaceVariant,
      ),
      child: const AnimatedShimmerWidget(
        enabled: true,
        child: SizedBox(),
      ),
    );
  }
}
