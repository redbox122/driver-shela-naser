import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';

/// Enhanced card widget with multi-layer shadow system
/// Provides configurable elevation and gradient support
class ElevatedCardWidget extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final double elevation;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool enableRipple;

  const ElevatedCardWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.customShadows,
    this.elevation = Dimensions.elevationMedium,
    this.borderColor,
    this.borderWidth = 0.0,
    this.onTap,
    this.enableRipple = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor =
        backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(Dimensions.radiusModern);

    final effectiveShadows =
        customShadows ?? _getShadowsForElevation(elevation);

    final effectiveBorderColor = borderColor ??
        (isDark
            ? AppColors.onSurfaceDark.withOpacity(0.1)
            : AppColors.onSurface.withOpacity(0.1));

    Widget card = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBackgroundColor : null,
        gradient: gradient,
        borderRadius: effectiveBorderRadius,
        border: borderWidth > 0
            ? Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: effectiveShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enableRipple ? onTap : null,
          borderRadius: effectiveBorderRadius,
          child: card,
        ),
      );
    }

    return card;
  }

  List<BoxShadow> _getShadowsForElevation(double elevation) {
    if (elevation <= Dimensions.elevationLow) {
      return [
        BoxShadow(
          color: AppColors.shadowLayer1,
          blurRadius: Dimensions.elevationLow,
          offset: const Offset(0, 1),
        ),
      ];
    } else if (elevation <= Dimensions.elevationMedium) {
      return [
        BoxShadow(
          color: AppColors.shadowLayer1,
          blurRadius: Dimensions.elevationLow,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.shadowLayer2,
          blurRadius: Dimensions.elevationMedium,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (elevation <= Dimensions.elevationHigh) {
      return [
        BoxShadow(
          color: AppColors.shadowLayer1,
          blurRadius: Dimensions.elevationLow,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.shadowLayer2,
          blurRadius: Dimensions.elevationMedium,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.shadowLayer3,
          blurRadius: Dimensions.elevationHigh,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (elevation <= Dimensions.elevationHero) {
      return [
        BoxShadow(
          color: AppColors.shadowLayer1,
          blurRadius: Dimensions.elevationLow,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.shadowLayer2,
          blurRadius: Dimensions.elevationMedium,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.shadowLayer3,
          blurRadius: Dimensions.elevationHigh,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.shadowLayer4,
          blurRadius: Dimensions.elevationHero,
          offset: const Offset(0, 8),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: AppColors.shadowLayer1,
          blurRadius: Dimensions.elevationLow,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.shadowLayer2,
          blurRadius: Dimensions.elevationMedium,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.shadowLayer3,
          blurRadius: Dimensions.elevationHigh,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.shadowLayer4,
          blurRadius: Dimensions.elevationHero,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.shadowLayer4,
          blurRadius: Dimensions.elevationUltra,
          offset: const Offset(0, 12),
        ),
      ];
    }
  }
}

/// Predefined elevated cards for common use cases
class FloatingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const FloatingCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedCardWidget(
      height: height,
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
      margin: margin,
      elevation: Dimensions.elevationHigh,
      onTap: onTap,
      child: child,
    );
  }
}

/// Premium card with maximum elevation and gradient
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveGradient = gradient ??
        (isDark
            ? AppColors.cardGradientDarkGlass
            : AppColors.cardGradientGlass);

    return ElevatedCardWidget(
      height: height,
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
      margin: margin,
      elevation: Dimensions.elevationPremium,
      gradient: effectiveGradient,
      borderRadius: BorderRadius.circular(Dimensions.radiusPremium),
      onTap: onTap,
      child: child,
    );
  }
}

/// Hero card with dramatic elevation and styling
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedCardWidget(
      height: height,
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
      margin: margin,
      elevation: Dimensions.elevationHero,
      gradient: AppColors.meshGradientPrimary,
      borderRadius: BorderRadius.circular(Dimensions.radiusHero),
      onTap: onTap,
      child: child,
    );
  }
}

/// Compact card for metrics and small content
class CompactCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedCardWidget(
      height: height,
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: margin,
      elevation: Dimensions.elevationLow,
      borderRadius: BorderRadius.circular(Dimensions.radiusModern),
      onTap: onTap,
      child: child,
    );
  }
}

/// Overlapping card that extends beyond its container
class OverlappingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double overlapAmount;
  final VoidCallback? onTap;

  const OverlappingCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.overlapAmount = Dimensions.cardOverlapMedium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedCardWidget(
      height: height,
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
      margin: margin ?? EdgeInsets.only(top: overlapAmount),
      elevation: Dimensions.elevationHigh,
      borderRadius: BorderRadius.circular(Dimensions.radiusUltraModern),
      onTap: onTap,
      child: child,
    );
  }
}

