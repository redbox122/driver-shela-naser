import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class EarningWidget extends StatelessWidget {
  final String title;
  final double? amount;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? textColor;

  const EarningWidget({
    super.key,
    required this.title,
    required this.amount,
    this.onTap,
    this.isLoading = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Expanded(
        child: Column(
          children: [
            Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              color: AppColors.surfaceVariant,
              child: Container(
                height: 12,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              color: AppColors.surfaceVariant,
              child: Container(
                height: 16,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveTextColor =
        textColor ?? (isDark ? AppColors.onSurfaceDark : AppColors.onSurface);

    return Semantics(
      label:
          '$title: ${amount != null ? PriceConverterHelper.convertPrice(amount!) : '0.00'}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: effectiveTextColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              amount != null
                  ? Text(
                      PriceConverterHelper.convertPrice(amount!),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: effectiveTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: amount == null,
                      color: AppColors.surfaceVariant,
                      child: Container(
                        height: 16,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced earning widget with icon and trend indicator
class EnhancedEarningWidget extends StatelessWidget {
  final String title;
  final double? amount;
  final IconData icon;
  final double? percentageChange;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const EnhancedEarningWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.percentageChange,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CardShimmerWidget(
        height: Dimensions.cardHeightSmall,
        borderRadius: BorderRadius.circular(Dimensions.radiusModern),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBackgroundColor =
        backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);
    final effectiveTextColor =
        textColor ?? (isDark ? AppColors.onSurfaceDark : AppColors.onSurface);

    return Semantics(
      label:
          '$title: ${amount != null ? PriceConverterHelper.convertPrice(amount!) : '0.00'}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: Dimensions.cardHeightSmall,
          padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusModern),
            boxShadow: [
              BoxShadow(
                color: AppColors.elevationLow,
                blurRadius: Dimensions.elevationLow,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: Dimensions.iconSizeDefault,
                    color: effectiveTextColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: effectiveTextColor.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount != null
                        ? PriceConverterHelper.convertPrice(amount!)
                        : '0.00',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: effectiveTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (percentageChange != null) ...[
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      children: [
                        Icon(
                          percentageChange! >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: Dimensions.iconSizeSmall,
                          color: percentageChange! >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '${percentageChange!.abs().toStringAsFixed(1)}%',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: percentageChange! >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer widget for earning cards
class CardShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const CardShimmerWidget({
    super.key,
    this.width,
    this.height = 120.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      color: AppColors.surfaceVariant,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              borderRadius ?? BorderRadius.circular(Dimensions.radiusModern),
        ),
      ),
    );
  }
}
