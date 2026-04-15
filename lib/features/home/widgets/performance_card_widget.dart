import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/animated_shimmer_widget.dart';
import 'package:shellafood_delivery/common/widgets/glassmorphic_container.dart';
import 'package:get/get.dart';

/// Performance metrics card widget
/// Displays order statistics with trend indicators
class PerformanceCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? percentageChange;
  final Color backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const PerformanceCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.percentageChange,
    required this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CardShimmerWidget(
        height: Dimensions.cardHeightMedium,
        borderRadius:
            BorderRadius.all(Radius.circular(Dimensions.radiusModern)),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveTextColor =
        textColor ?? (isDark ? AppColors.onSurfaceDark : AppColors.onSurface);

    return Semantics(
      label: '$title: $value',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicContainer(
          height: Dimensions.cardHeightMedium,
          padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
          borderRadius: BorderRadius.circular(Dimensions.radiusModern),
          backgroundColor: backgroundColor.withValues(alpha: 0.05),
          borderColor: backgroundColor.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLayer1,
              blurRadius: Dimensions.elevationLow,
              offset: const Offset(
                  Dimensions.shadowOffsetX, Dimensions.shadowOffsetY / 4),
            ),
            BoxShadow(
              color: AppColors.shadowLayer2,
              blurRadius: Dimensions.elevationMedium,
              offset: const Offset(
                  Dimensions.shadowOffsetX, Dimensions.shadowOffsetY / 2),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: backgroundColor.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusModern),
                      ),
                      child: Icon(
                        icon,
                        size: Dimensions.iconSizeDefault,
                        color: effectiveTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
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
                    value,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: effectiveTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      subtitle!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: effectiveTextColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              if (percentageChange != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: (percentageChange! >= 0
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Icon(
                        percentageChange! >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: Dimensions.iconSizeSmall,
                        color: percentageChange! >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
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
        ),
      ),
    );
  }
}

/// Horizontal scrollable performance metrics
class PerformanceMetricsWidget extends StatelessWidget {
  final List<PerformanceCardWidget> cards;
  final String? title;
  final VoidCallback? onViewAll;

  const PerformanceMetricsWidget({
    super.key,
    required this.cards,
    this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHero,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'view_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
        SizedBox(
          height: Dimensions.cardHeightMedium + Dimensions.paddingSizeDefault,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHero,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < cards.length - 1
                      ? Dimensions.paddingSizeSmall
                      : Dimensions.paddingSizeHero, // Show peek of next card
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: cards[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Predefined performance cards for delivery metrics
class DeliveryPerformanceWidget extends StatelessWidget {
  final int? todaysOrders;
  final int? weeklyOrders;
  final int? totalOrders;
  final double? todaysPercentageChange;
  final double? weeklyPercentageChange;
  final VoidCallback? onTodaysOrdersTap;
  final VoidCallback? onWeeklyOrdersTap;
  final VoidCallback? onTotalOrdersTap;
  final bool isLoading;

  const DeliveryPerformanceWidget({
    super.key,
    this.todaysOrders,
    this.weeklyOrders,
    this.totalOrders,
    this.todaysPercentageChange,
    this.weeklyPercentageChange,
    this.onTodaysOrdersTap,
    this.onWeeklyOrdersTap,
    this.onTotalOrdersTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cards = [
      PerformanceCardWidget(
        title: 'todays_orders'.tr,
        value: todaysOrders?.toString() ?? '0',
        subtitle: 'today'.tr,
        percentageChange: todaysPercentageChange,
        backgroundColor: isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.1),
        textColor: isDark ? AppColors.primaryLight : AppColors.primary,
        icon: Icons.today,
        onTap: onTodaysOrdersTap,
        isLoading: isLoading,
      ),
      PerformanceCardWidget(
        title: 'this_week_orders'.tr,
        value: weeklyOrders?.toString() ?? '0',
        subtitle: 'this_week'.tr,
        percentageChange: weeklyPercentageChange,
        backgroundColor: isDark
            ? AppColors.accent.withValues(alpha: 0.2)
            : AppColors.accent.withValues(alpha: 0.1),
        textColor: isDark ? AppColors.accentLight : AppColors.accent,
        icon: Icons.date_range,
        onTap: onWeeklyOrdersTap,
        isLoading: isLoading,
      ),
      PerformanceCardWidget(
        title: 'total_orders'.tr,
        value: totalOrders?.toString() ?? '0',
        subtitle: 'all_time'.tr,
        backgroundColor: isDark
            ? AppColors.warning.withValues(alpha: 0.2)
            : AppColors.warning.withValues(alpha: 0.1),
        textColor: isDark ? AppColors.warningLight : AppColors.warning,
        icon: Icons.analytics,
        onTap: onTotalOrdersTap,
        isLoading: isLoading,
      ),
    ];

    return PerformanceMetricsWidget(
      title: 'orders'.tr,
      cards: cards,
    );
  }
}

/// Shimmer widget for performance cards
class PerformanceCardShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;

  const PerformanceCardShimmerWidget({
    super.key,
    this.width,
    this.height = Dimensions.cardHeightMedium,
  });

  @override
  Widget build(BuildContext context) {
    return CardShimmerWidget(
      width: width,
      height: height,
      borderRadius:
          const BorderRadius.all(Radius.circular(Dimensions.radiusModern)),
    );
  }
}
