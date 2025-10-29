import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';

/// Glassmorphic container widget with backdrop blur and gradient border support
/// Creates modern frosted glass effect with configurable blur intensity
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurIntensity;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool enableBlur;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurIntensity = Dimensions.blurRadiusMedium,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradient,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor = backgroundColor ??
        (isDark
            ? AppColors.glassmorphismDarkMode
            : AppColors.glassmorphismLight);

    final effectiveBorderColor = borderColor ??
        (isDark
            ? AppColors.onSurfaceDark.withOpacity(0.2)
            : AppColors.onSurface.withOpacity(0.1));

    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(Dimensions.radiusGlassmorphism);

    final effectiveBoxShadow = boxShadow ??
        [
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
        ];

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? effectiveBackgroundColor : null,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: effectiveBoxShadow,
      ),
      child: child,
    );

    if (enableBlur) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Predefined glassmorphic containers for common use cases
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        height: height,
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
        margin: margin,
        child: child,
      ),
    );
  }
}

/// Glassmorphic container with gradient background
class GlassmorphicGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassmorphicGradientCard({
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

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        height: height,
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
        margin: margin,
        gradient: effectiveGradient,
        enableBlur: true,
        child: child,
      ),
    );
  }
}

/// Floating glassmorphic container with enhanced shadows
class FloatingGlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const FloatingGlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        height: height,
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
        margin: margin,
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
          BoxShadow(
            color: AppColors.shadowLayer3,
            blurRadius: Dimensions.elevationHigh,
            offset: const Offset(
                Dimensions.shadowOffsetX, Dimensions.shadowOffsetY),
          ),
        ],
        child: child,
      ),
    );
  }
}

/// Hero glassmorphic container with premium styling
class HeroGlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const HeroGlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        height: height,
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
        margin: margin,
        borderRadius: BorderRadius.circular(Dimensions.radiusHero),
        gradient: AppColors.meshGradientPrimary,
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
          BoxShadow(
            color: AppColors.shadowLayer3,
            blurRadius: Dimensions.elevationHigh,
            offset: const Offset(
                Dimensions.shadowOffsetX, Dimensions.shadowOffsetY),
          ),
          BoxShadow(
            color: AppColors.shadowLayer4,
            blurRadius: Dimensions.elevationHero,
            offset: const Offset(
                Dimensions.shadowOffsetX, Dimensions.shadowOffsetY * 1.5),
          ),
        ],
        child: child,
      ),
    );
  }
}
