import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CountCardWidget extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String? value;
  final double height;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const CountCardWidget({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.height,
    this.icon,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CardShimmerWidget(
        height: height,
        borderRadius: BorderRadius.circular(Dimensions.radiusModern),
      );
    }

    return Semantics(
      label: '$title: $value',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHero,
            vertical: Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: Dimensions.iconSizeLarge,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
              value != null
                  ? Text(
                      value!,
                      style: robotoBold.copyWith(
                        fontSize: height > 150
                            ? Dimensions.fontSizeHero
                            : Dimensions.fontSizeOverLarge,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: value == null,
                      color: Colors.grey[500]!,
                      child: Container(
                        height: height > 150 ? 60 : 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                      ),
                    ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer widget for count cards
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
