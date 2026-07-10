import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_details_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/common/widgets/custom_image_widget.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final bool showPrice;
  const OrderItemWidget(
      {super.key,
      required this.order,
      required this.orderDetails,
      this.showPrice = true});

  Widget _buildQuantityBadge(BuildContext context, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        '${'quantity'.tr}: $quantity',
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildVariationChips(BuildContext context) {
    List<Widget> chips = [];
    
    if (orderDetails.variation != null && orderDetails.variation!.isNotEmpty) {
      List<String> variationTypes = orderDetails.variation![0].type!.split('-');
      if (variationTypes.length ==
          orderDetails.itemDetails!.choiceOptions!.length) {
        int index = 0;
        for (var choice in orderDetails.itemDetails!.choiceOptions!) {
          if (index < variationTypes.length) {
            chips.add(
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${choice.title}: ${variationTypes[index]}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          }
          index = index + 1;
        }
      } else if (orderDetails.itemDetails!.variations != null &&
          orderDetails.itemDetails!.variations!.isNotEmpty) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              orderDetails.itemDetails!.variations![0].type ?? '',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      }
    } else if (orderDetails.foodVariation != null &&
        orderDetails.foodVariation!.isNotEmpty) {
      for (FoodVariation variation in orderDetails.foodVariation!) {
        if (variation.variationValues != null &&
            variation.variationValues!.isNotEmpty) {
          for (VariationValue value in variation.variationValues!) {
            chips.add(
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${variation.name ?? ''}: ${value.level ?? ''}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          }
        }
      }
    }
    
    return chips;
  }

  List<Widget> _buildAddOnChips(BuildContext context) {
    List<Widget> chips = [];
    
    if (orderDetails.addOns != null && orderDetails.addOns!.isNotEmpty) {
      for (var addOn in orderDetails.addOns!) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${addOn.name} (x${addOn.quantity})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.green.shade700,
              ),
            ),
          ),
        );
      }
    }
    
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final itemDetails = orderDetails.itemDetails;
    if (itemDetails == null) {
      return const SizedBox();
    }
    List<Widget> variationChips = _buildVariationChips(context);
    List<Widget> addOnChips = _buildAddOnChips(context);
    bool hasVariations = variationChips.isNotEmpty;
    // إظهار الإضافات دائماً إذا كانت موجودة في الطلب — لا نخفيها بحسب إعداد الموديول،
    // ليرى الكابتن ما طلبه العميل فعلاً (مثل «زيادة كاتشب»).
    bool hasAddOns = addOnChips.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: Dimensions.elevationLow,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                itemDetails.imageFullUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImageWidget(
                          height: 84,
                          width: 84,
                          fit: BoxFit.cover,
                          image: '${itemDetails.imageFullUrl}',
                        ),
                      )
                    : Container(
                        height: 84,
                        width: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.6)),
                      ),
                SizedBox(
                  width: itemDetails.imageFullUrl != null
                      ? Dimensions.paddingSizeSmall
                      : 0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemDetails.name ?? '',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildQuantityBadge(
                              context, orderDetails.quantity ?? 0),
                        ],
                      ),
                      const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        children: [
                          if (showPrice) ...[
                            Text(
                              PriceConverterHelper.convertPrice(
                                  (orderDetails.price ?? 0) -
                                      (orderDetails.discountOnItem ?? 0)),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            (orderDetails.discountOnItem ?? 0) > 0
                                ? Text(
                                    PriceConverterHelper.convertPrice(
                                        orderDetails.price),
                                    style: robotoMedium.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: Dimensions.fontSizeSmall,
                                      color:
                                          Theme.of(context).disabledColor,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                          if (showPrice &&
                              ((Get.find<SplashController>()
                                          .getModule(order.moduleType)
                                          .unit ==
                                      true &&
                                  itemDetails.unitType != null) ||
                                  (Get.find<SplashController>()
                                          .configModel
                                          ?.toggleVegNonVeg ==
                                      true &&
                                      Get.find<SplashController>()
                                              .getModule(order.moduleType)
                                              .vegNonVeg ==
                                          true)))
                            const Spacer(),
                          ((Get.find<SplashController>()
                                      .getModule(order.moduleType)
                                      .unit ==
                                  true &&
                                  itemDetails.unitType != null) ||
                              (Get.find<SplashController>()
                                      .configModel
                                      ?.toggleVegNonVeg ==
                                  true &&
                                  Get.find<SplashController>()
                                          .getModule(order.moduleType)
                                          .vegNonVeg ==
                                      true))
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical:
                                        Dimensions.paddingSizeExtraSmall,
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: Text(
                                    Get.find<SplashController>()
                                            .getModule(order.moduleType)
                                            .unit ==
                                        true
                                        ? itemDetails.unitType ?? ''
                                        : itemDetails.veg == 0
                                            ? 'non_veg'.tr
                                            : 'veg'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize:
                                          Dimensions.fontSizeExtraSmall,
                                      color:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasVariations) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'variations'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: variationChips,
              ),
            ],
            if (hasAddOns) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'addons'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: addOnChips,
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Divider(
              height: Dimensions.paddingSizeLarge,
              color: Theme.of(context)
                  .disabledColor
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}
