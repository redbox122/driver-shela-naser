import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_constants.dart';

/// 🔍 Debug Widget - لتتبع حالة الطلب والصور
class OrderDebugWidget extends StatelessWidget {
  final OrderModel order;
  
  const OrderDebugWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔍 DEBUG INFO', 
                  style: robotoBold.copyWith(
                      color: Colors.blue, 
                      fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              
              // Order Status
              _buildDebugRow('Order ID:', order.id.toString()),
              _buildDebugRow('Status:', order.orderStatus ?? 'null'),
              _buildDebugRow('Module ID:', order.module_id.toString()),
              _buildDebugRow('Is Restaurant (6/7/8/9)?', 
                  '[6, 7, 8,9].contains(${order.module_id}) = ${[6, 7, 8, 9].contains(order.module_id)}'),
              
              const SizedBox(height: Dimensions.paddingSizeSmall),
              const Divider(),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              
              // Photos Status
              _buildDebugRow('Restaurant Photos Uploaded?', 
                  controller.hasUploadedRestaurantPhotos(order) ? '✅ YES' : '❌ NO'),
              _buildDebugRow('Photos URL:', 
                  order.orderProofFullUrl?.length.toString() ?? 'null'),
              _buildDebugRow('Selected Photos:', 
                  controller.pickedOrderProofImages.length.toString()),
              _buildDebugRow('Picked Delivery Photos:', 
                  controller.hasPickedDeliveryPhotos() ? '✅ YES' : '❌ NO'),
              
              const SizedBox(height: Dimensions.paddingSizeSmall),
              const Divider(),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              
              // UI Visibility
              Text('📱 UI VISIBILITY:', 
                  style: robotoBold.copyWith(color: Colors.green)),
              _buildDebugRow('Show Restaurant Photos UI?',
                  (controller.showDeliveryPhotos ? '✅ SHOW' : '❌ HIDE')),
              _buildDebugRow('Show Delivery Photo Section?',
                  (_isStatus(order.orderStatus, AppConstants.pickedUp) ||
                          _isStatus(order.orderStatus, AppConstants.handover)
                      ? '✅ SHOW'
                      : '❌ HIDE')),
              _buildDebugRow('Complete Delivery Button Active?', 
                  (controller.hasPickedDeliveryPhotos() ? '✅ ACTIVE' : '🔴 DISABLED')),
              
              const SizedBox(height: Dimensions.paddingSizeSmall),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('📋 === FULL ORDER DEBUG ===');
                        debugPrint('Order: ${order.toJson()}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Print Order JSON'),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.update();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Refresh UI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: robotoRegular.copyWith(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(value, 
                style: robotoMedium.copyWith(
                    fontSize: 12,
                    color: Colors.blue[700]),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  bool _isStatus(String? status, String target) =>
      (status ?? '').toLowerCase().trim() ==
      target.toLowerCase().trim();
}
