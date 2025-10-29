import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_colors.dart';

/// Reusable animated shimmer widget for loading states
/// Provides consistent loading animations across the app
class AnimatedShimmerWidget extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AnimatedShimmerWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(seconds: 2),
    this.baseColor,
    this.highlightColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer(
      duration: duration,
      enabled: enabled,
      color: baseColor ?? AppColors.surfaceVariant,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: highlightColor ?? AppColors.surface,
          borderRadius:
              borderRadius ?? BorderRadius.circular(Dimensions.radiusModern),
        ),
        child: child,
      ),
    );
  }
}

/// Shimmer skeleton for text content
class TextShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const TextShimmerWidget({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: width,
      height: height,
      borderRadius:
          borderRadius ?? BorderRadius.circular(Dimensions.radiusSmall),
      child: const SizedBox(),
    );
  }
}

/// Shimmer skeleton for circular content (avatars, icons)
class CircularShimmerWidget extends StatelessWidget {
  final double size;
  final Color? baseColor;
  final Color? highlightColor;

  const CircularShimmerWidget({
    super.key,
    this.size = 40.0,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: size,
      height: size,
      baseColor: baseColor,
      highlightColor: highlightColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: const SizedBox(),
    );
  }
}

/// Shimmer skeleton for card content
class CardShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CardShimmerWidget({
    super.key,
    this.width,
    this.height = 120.0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: width,
      height: height,
      borderRadius:
          borderRadius ?? BorderRadius.circular(Dimensions.radiusModern),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeHero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextShimmerWidget(
              width: width != null ? width! * 0.6 : 120.0,
              height: 20.0,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TextShimmerWidget(
              width: width != null ? width! * 0.4 : 80.0,
              height: 16.0,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              children: [
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.3 : 60.0,
                    height: 14.0,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.3 : 60.0,
                    height: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for list items
class ListItemShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;
  final bool showAvatar;
  final bool showActions;

  const ListItemShimmerWidget({
    super.key,
    this.width,
    this.height = 80.0,
    this.showAvatar = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(Dimensions.radiusModern),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
        child: Row(
          children: [
            if (showAvatar) ...[
              const CircularShimmerWidget(size: 40.0),
              const SizedBox(width: Dimensions.paddingSizeHero),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextShimmerWidget(
                    width: width != null ? width! * 0.5 : 100.0,
                    height: 16.0,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextShimmerWidget(
                    width: width != null ? width! * 0.3 : 60.0,
                    height: 14.0,
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              const CircularShimmerWidget(size: 32.0),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for hero cards
class HeroCardShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;

  const HeroCardShimmerWidget({
    super.key,
    this.width,
    this.height = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(Dimensions.radiusHero),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircularShimmerWidget(size: 60.0),
                const SizedBox(width: Dimensions.paddingSizeHero),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextShimmerWidget(
                        width: width != null ? width! * 0.4 : 80.0,
                        height: 18.0,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextShimmerWidget(
                        width: width != null ? width! * 0.6 : 120.0,
                        height: 16.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextShimmerWidget(
              width: width != null ? width! * 0.8 : 160.0,
              height: 14.0,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TextShimmerWidget(
              width: width != null ? width! * 0.6 : 120.0,
              height: 14.0,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              children: [
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.25 : 50.0,
                    height: 40.0,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusModern),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.25 : 50.0,
                    height: 40.0,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusModern),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.25 : 50.0,
                    height: 40.0,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusModern),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for financial overview
class FinancialOverviewShimmerWidget extends StatelessWidget {
  final double? width;
  final double height;

  const FinancialOverviewShimmerWidget({
    super.key,
    this.width,
    this.height = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmerWidget(
      enabled: true,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(Dimensions.radiusModern),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeHero),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextShimmerWidget(
                        width: width != null ? width! * 0.3 : 60.0,
                        height: 14.0,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextShimmerWidget(
                        width: width != null ? width! * 0.5 : 100.0,
                        height: 24.0,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 40.0,
                  color: AppColors.surface,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextShimmerWidget(
                        width: width != null ? width! * 0.3 : 60.0,
                        height: 14.0,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextShimmerWidget(
                        width: width != null ? width! * 0.4 : 80.0,
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              children: [
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.2 : 40.0,
                    height: 12.0,
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 20.0,
                  color: AppColors.surface,
                ),
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.2 : 40.0,
                    height: 12.0,
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 20.0,
                  color: AppColors.surface,
                ),
                Expanded(
                  child: TextShimmerWidget(
                    width: width != null ? width! * 0.2 : 40.0,
                    height: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
