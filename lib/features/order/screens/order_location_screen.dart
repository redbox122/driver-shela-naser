import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/address/controllers/address_controller.dart';
import 'package:shellafood_delivery/features/address/domain/models/zone_model.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/order/widgets/delivery_proof_sheet_widget.dart';
// نظام الاتصال الداخلي (Agora) — استيراد جديد
import 'package:shellafood_delivery/features/call/presentation/widgets/call_button.dart';
import 'package:shellafood_delivery/helper/navigation_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/location_card_widget.dart';

class OrderLocationScreen extends StatefulWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int index;
  final Function onTap;
  final bool isDeliveryPhase;
  const OrderLocationScreen({
    super.key,
    required this.orderModel,
    required this.orderController,
    required this.index,
    required this.onTap,
    this.isDeliveryPhase = false,
  });

  @override
  State<OrderLocationScreen> createState() => _OrderLocationScreenState();
}

class _OrderLocationScreenState extends State<OrderLocationScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Polygon> _polygons = HashSet<Polygon>();

  @override
  void initState() {
    super.initState();
    _loadZonePolygon();
  }

  @override
  Widget build(BuildContext context) {
    bool parcel = widget.orderModel.orderType == 'parcel';
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: widget.isDeliveryPhase ? 'موقع العميل' : 'order_location'.tr,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(
                  widget.orderModel.deliveryAddress?.latitude ?? '0',
                ),
                double.parse(
                  widget.orderModel.deliveryAddress?.longitude ?? '0',
                ),
              ),
              zoom: 16,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: false,
            markers: _markers,
            polygons: _polygons,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              setMarker(widget.orderModel, parcel);
            },
          ),
          Positioned(
            bottom: Dimensions.paddingSizeSmall,
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            child: widget.isDeliveryPhase
                ? _DeliveryPhaseCard(orderModel: widget.orderModel)
                : LocationCardWidget(
                    orderModel: widget.orderModel,
                    orderController: widget.orderController,
                    onTap: widget.onTap,
                    index: widget.index,
                  ),
          ),
        ],
      ),
    );
  }

  void setMarker(OrderModel orderModel, bool parcel) async {
    try {
      Uint8List destinationImageData = await convertAssetToUnit8List(
        Images.customerMarker,
        width: 100,
      );
      Uint8List restaurantImageData = await convertAssetToUnit8List(
        parcel ? Images.userMarker : Images.restaurantMarker,
        width: parcel ? 70 : 100,
      );
      Uint8List deliveryBoyImageData = await convertAssetToUnit8List(
        Images.yourMarker,
        width: 100,
      );

      LatLngBounds? bounds;
      if (_controller != null) {
        double deliveryLat = double.parse(
          orderModel.deliveryAddress?.latitude ?? '0',
        );
        double deliveryLng = double.parse(
          orderModel.deliveryAddress?.longitude ?? '0',
        );
        double storeLat = double.parse(orderModel.storeLat ?? '0');
        double storeLng = double.parse(orderModel.storeLng ?? '0');
        double receiverLat = double.parse(
          orderModel.receiverDetails?.latitude ?? '0',
        );
        double receiverLng = double.parse(
          orderModel.receiverDetails?.longitude ?? '0',
        );
        double deliveryManLat =
            Get.find<ProfileController>().recordLocationBody?.latitude ?? 0;
        double deliveryManLng =
            Get.find<ProfileController>().recordLocationBody?.longitude ?? 0;

        if (parcel) {
          bounds = LatLngBounds(
            southwest: LatLng(
              min(deliveryLat, min(receiverLat, deliveryManLat)),
              min(deliveryLng, min(receiverLng, deliveryManLng)),
            ),
            northeast: LatLng(
              max(deliveryLat, max(receiverLat, deliveryManLat)),
              max(deliveryLng, max(receiverLng, deliveryManLng)),
            ),
          );
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(
              min(deliveryLat, min(storeLat, deliveryManLat)),
              min(deliveryLng, min(storeLng, deliveryManLng)),
            ),
            northeast: LatLng(
              max(deliveryLat, max(storeLat, deliveryManLat)),
              max(deliveryLng, max(storeLng, deliveryManLng)),
            ),
          );
        }

        LatLng centerBounds = LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );

        if (kDebugMode) {
          debugPrint('center bound $centerBounds');
        }

        _controller!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        _markers.clear();

        if (orderModel.deliveryAddress != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(deliveryLat, deliveryLng),
              infoWindow: InfoWindow(
                title: parcel ? 'Sender' : 'Destination',
                snippet: orderModel.deliveryAddress?.address,
              ),
              icon: BitmapDescriptor.bytes(destinationImageData),
            ),
          );
        }

        if (parcel && orderModel.receiverDetails != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('receiver'),
              position: LatLng(receiverLat, receiverLng),
              infoWindow: InfoWindow(
                title: 'Receiver',
                snippet: orderModel.receiverDetails?.address,
              ),
              icon: BitmapDescriptor.bytes(restaurantImageData),
            ),
          );
        }

        if (!parcel &&
            orderModel.storeLat != null &&
            orderModel.storeLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('store'),
              position: LatLng(storeLat, storeLng),
              infoWindow: InfoWindow(
                title: orderModel.storeName,
                snippet: orderModel.storeAddress,
              ),
              icon: BitmapDescriptor.bytes(restaurantImageData),
            ),
          );
        }

        if (Get.find<ProfileController>().recordLocationBody != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('delivery_boy'),
              position: LatLng(deliveryManLat, deliveryManLng),
              infoWindow: InfoWindow(
                title: 'delivery_man'.tr,
                snippet:
                    Get.find<ProfileController>().recordLocationBody?.location,
              ),
              icon: BitmapDescriptor.bytes(deliveryBoyImageData),
            ),
          );
        }
        if (orderModel.collectionOrder == true) {
          for (
            int i = 0;
            i < (orderModel.groupOrderLocation?.length ?? 0);
            i++
          ) {
            if (orderModel.groupOrderLocation![i] !=
                LatLng(storeLat, storeLng)) {
              _markers.add(
                Marker(
                  markerId: MarkerId(orderModel.groupOrder![i].toString()),
                  position: orderModel.groupOrderLocation![i],
                  icon: BitmapDescriptor.bytes(restaurantImageData),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting markers: $e');
      }
    }
    setState(() {});
  }

  Future<void> _loadZonePolygon() async {
    try {
      final addressController = Get.find<AddressController>();
      if (addressController.zoneList == null) {
        await addressController.getZoneList();
      }

      final int? zoneId = widget.orderModel.deliveryAddress?.zoneId;

      if (zoneId == null || addressController.zoneList == null) {
        return;
      }

      ZoneModel? zone;
      for (final zoneItem in addressController.zoneList!) {
        if (zoneItem.id == zoneId) {
          zone = zoneItem;
          break;
        }
      }

      final List<LatLng>? points = zone?.coordinates?.coordinates;
      if (points == null || points.isEmpty) {
        return;
      }

      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: PolygonId('zone_$zoneId'),
          points: points,
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withValues(alpha: 0.2),
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading zone polygon: $e');
      }
    }
  }

  Future<Uint8List> convertAssetToUnit8List(
    String imagePath, {
    int width = 50,
  }) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  Future<void> zoomToFit(
    GoogleMapController? controller,
    LatLngBounds? bounds,
    LatLng centerBounds, {
    double padding = 0.5,
  }) async {
    bool keepZoomingOut = true;

    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
        break;
      } else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck =
        screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck =
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck =
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck =
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
  }
}

/// كارت يُعرض في شاشة الخريطة بعد استلام الطلب من المتجر
class _DeliveryPhaseCard extends StatelessWidget {
  final OrderModel orderModel;
  const _DeliveryPhaseCard({required this.orderModel});


  @override
  Widget build(BuildContext context) {
    final customerName = orderModel.deliveryAddress?.contactPersonName ?? '';
    final customerAddress = orderModel.deliveryAddress?.address ?? '';
    final lat = orderModel.deliveryAddress?.latitude ?? '0';
    final lng = orderModel.deliveryAddress?.longitude ?? '0';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بانر النجاح
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'تم استلام الطلب من المتجر',
                  style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          // اسم العميل
          if (customerName.isNotEmpty) ...[
            Row(children: [
              Icon(Icons.person_outline,
                  size: 16, color: Theme.of(context).hintColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customerName,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // زر الاتصال الداخلي (Agora) — إضافة احترافية بجانب اسم العميل
              if (orderModel.customer?.id != null)
                CallButton(
                  orderId: orderModel.id,
                  customerId: orderModel.customer?.id,
                  customerName: customerName,
                  customerImage: orderModel.customer?.imageFullUrl,
                  size: 42,
                ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],
          // عنوان العميل
          if (customerAddress.isNotEmpty) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Theme.of(context).hintColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customerAddress,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
          // زر التنقل
          CustomButtonWidget(
            buttonText: 'التنقل إلى العميل',
            icon: Icons.navigation_outlined,
            height: 48,
            onPressed: () => NavigationHelper.navigateToLocation(
              latitude: lat,
              longitude: lng,
              label: customerName,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          // زر الوصول → يفتح شيت التصوير + OTP مباشرة
          OutlinedButton.icon(
            onPressed: () {
              Get.find<OrderController>()
                  .pickPrescriptionImage(isRemove: true, isCamera: false);
              Get.bottomSheet(
                DeliveryProofSheetWidget(orderModel: orderModel),
                isScrollControlled: true,
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('تم الوصول للعميل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
