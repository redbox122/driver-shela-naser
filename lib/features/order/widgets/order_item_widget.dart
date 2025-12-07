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
  const OrderItemWidget(
      {super.key, required this.order, required this.orderDetails});

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
        'Qty: $quantity',
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
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
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
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
    List<Widget> variationChips = _buildVariationChips(context);
    List<Widget> addOnChips = _buildAddOnChips(context);
    bool hasVariations = variationChips.isNotEmpty;
    bool hasAddOns = addOnChips.isNotEmpty &&
        Get.find<SplashController>().getModule(order.moduleType).addOn!;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                orderDetails.itemDetails!.imageFullUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImageWidget(
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          image: '${orderDetails.itemDetails!.imageFullUrl}',
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: orderDetails.itemDetails!.imageFullUrl != null
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
                              orderDetails.itemDetails!.name!,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildQuantityBadge(context, orderDetails.quantity!),
                        ],
                      ),
                      const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        children: [
                          Text(
                            PriceConverterHelper.convertPrice(
                                orderDetails.price! -
                                    orderDetails.discountOnItem!),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          orderDetails.discountOnItem! > 0
                              ? Expanded(
                                  child: Text(
                                    PriceConverterHelper.convertPrice(
                                        orderDetails.price),
                                    style: robotoMedium.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: Dimensions.fontSizeSmall,
                                      color:
                                          Theme.of(context).disabledColor,
                                    ),
                                  ),
                                )
                              : const Expanded(child: SizedBox()),
                          ((Get.find<SplashController>()
                                      .getModule(order.moduleType)
                                      .unit! &&
                                  orderDetails.itemDetails!.unitType !=
                                      null) ||
                              (Get.find<SplashController>()
                                      .configModel!
                                      .toggleVegNonVeg! &&
                                  Get.find<SplashController>()
                                      .getModule(order.moduleType)
                                      .vegNonVeg!))
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
                                        .withOpacity(0.1),
                                  ),
                                  child: Text(
                                    Get.find<SplashController>()
                                            .getModule(order.moduleType)
                                            .unit!
                                        ? orderDetails.itemDetails!.unitType ??
                                            ''
                                        : orderDetails.itemDetails!.veg == 0
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
              color: Theme.of(context).disabledColor.withOpacity(0.3),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}
