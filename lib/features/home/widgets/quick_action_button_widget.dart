import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:get/get.dart';

/// Reusable quick action button widget
/// Provides consistent styling and interaction for common actions
class QuickActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;
  final bool isEnabled;
  final String? tooltip;

  const QuickActionButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: tooltip ?? label,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip ?? label,
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          child: Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark ? AppColors.surfaceDark : AppColors.surface),
              borderRadius: BorderRadius.circular(Dimensions.radiusModern),
              border: Border.all(
                color: AppColors.glassFrostBorder,
                width: 1.0,
              ),
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
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: Dimensions.iconSizeDefault,
                  color: iconColor ??
                      (isEnabled
                          ? (isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurface)
                          : (isDark
                              ? AppColors.onSurfaceDark.withOpacity(0.4)
                              : AppColors.onSurface.withOpacity(0.4))),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  label,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: labelColor ??
                        (isEnabled
                            ? (isDark
                                ? AppColors.onSurfaceDark.withOpacity(0.7)
                                : AppColors.onSurface.withOpacity(0.7))
                            : (isDark
                                ? AppColors.onSurfaceDark.withOpacity(0.4)
                                : AppColors.onSurface.withOpacity(0.4))),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of quick action buttons
class QuickActionsRowWidget extends StatelessWidget {
  final List<QuickActionButtonWidget> actions;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;

  const QuickActionsRowWidget({
    super.key,
    required this.actions,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.spacing = Dimensions.paddingSizeHero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHero,
        vertical: Dimensions.cardSpacingVertical,
      ),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: index == 0 || index == actions.length - 1
                    ? 0
                    : Dimensions.paddingSizeExtraSmall,
              ),
              child: action,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Predefined quick action buttons for common delivery tasks
class DeliveryQuickActionsWidget extends StatelessWidget {
  final VoidCallback? onCallSupport;
  final VoidCallback? onEarningsHistory;
  final VoidCallback? onNavigate;
  final VoidCallback? onHelpCenter;
  final bool showCallSupport;
  final bool showEarningsHistory;
  final bool showNavigate;
  final bool showHelpCenter;

  const DeliveryQuickActionsWidget({
    super.key,
    this.onCallSupport,
    this.onEarningsHistory,
    this.onNavigate,
    this.onHelpCenter,
    this.showCallSupport = true,
    this.showEarningsHistory = true,
    this.showNavigate = true,
    this.showHelpCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <QuickActionButtonWidget>[];

    if (showCallSupport) {
      actions.add(
        QuickActionButtonWidget(
          icon: Icons.phone,
          label: 'call'.tr,
          onTap: onCallSupport ?? () {},
          backgroundColor: AppColors.error.withOpacity(0.08),
          iconColor: AppColors.error,
          tooltip: 'call_support'.tr,
        ),
      );
    }

    if (showEarningsHistory) {
      actions.add(
        QuickActionButtonWidget(
          icon: Icons.account_balance_wallet,
          label: 'earnings'.tr,
          onTap: onEarningsHistory ?? () {},
          backgroundColor: AppColors.primary.withOpacity(0.08),
          iconColor: AppColors.primary,
          tooltip: 'earnings_history'.tr,
        ),
      );
    }

    if (showNavigate) {
      actions.add(
        QuickActionButtonWidget(
          icon: Icons.navigation,
          label: 'navigate'.tr,
          onTap: onNavigate ?? () {},
          backgroundColor: AppColors.accent.withOpacity(0.08),
          iconColor: AppColors.accent,
          tooltip: 'open_navigation'.tr,
        ),
      );
    }

    if (showHelpCenter) {
      actions.add(
        QuickActionButtonWidget(
          icon: Icons.help_center,
          label: 'help'.tr,
          onTap: onHelpCenter ?? () {},
          backgroundColor: AppColors.warning.withOpacity(0.08),
          iconColor: AppColors.warning,
          tooltip: 'help_center'.tr,
        ),
      );
    }

    return QuickActionsRowWidget(actions: actions);
  }
}

/// Floating action button for primary actions
class PrimaryActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isEnabled;
  final bool showLabel;
  final double? size;

  const PrimaryActionButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.isEnabled = true,
    this.showLabel = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                onTap();
              }
            : null,
        child: Container(
          width: size ?? Dimensions.touchTargetHero,
          height: size ?? Dimensions.touchTargetHero,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(Dimensions.radiusModern),
            boxShadow: [
              BoxShadow(
                color: AppColors.elevationHigh,
                blurRadius: Dimensions.elevationHigh,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: showLabel
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: Dimensions.iconSizeDefault,
                        color: iconColor ?? AppColors.surface,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        label,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: iconColor ?? AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                )
              : Icon(
                  icon,
                  size: Dimensions.iconSizeDefault,
                  color: iconColor ?? AppColors.surface,
                ),
        ),
      ),
    );
  }
}
