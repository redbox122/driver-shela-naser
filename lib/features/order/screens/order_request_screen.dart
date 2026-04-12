import 'dart:async';
import 'dart:math' as math;
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/features/order/widgets/order_requset_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRequestScreen extends StatefulWidget {
  final Function onTap;
  const OrderRequestScreen({super.key, required this.onTap});

  @override
  OrderRequestScreenState createState() => OrderRequestScreenState();
}

class OrderRequestScreenState extends State<OrderRequestScreen> {
  Timer? _timer;
  _DateSort _dateSort = _DateSort.newest;
  _DistanceSort _distanceSort = _DistanceSort.none;

  @override
  initState() {
    super.initState();

    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }

    Get.find<OrderController>().getLatestOrdersIfActive();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getLatestOrdersIfActive();
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: 'order_request'.tr, isBackButtonExist: false),
      body: GetBuilder<OrderController>(builder: (orderController) {
        if (orderController.latestOrderList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // CS-08: empty list is a distinct state from loading (null) — show message, not spinner
        if (orderController.latestOrderList!.isEmpty) {
          return Center(child: Text('no_order_found'.tr));
        }

        final profileController = Get.find<ProfileController>();
        final hasLocation =
            profileController.recordLocationBody?.latitude != null &&
                profileController.recordLocationBody?.longitude != null;

        final List orders = _sortOrders(
            orderController.latestOrderList!,
            profileController,
            hasLocation);

        return Column(
          children: [
            _buildFilterBar(context, hasLocation),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Get.find<OrderController>().getLatestOrdersIfActive();
                },
                child: ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return OrderRequestWidget(
                        orderModel: orders[index],
                        index: index,
                        onTap: widget.onTap);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool hasLocation) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<_DateSort>(
              value: _dateSort,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: _DateSort.newest,
                  child: Text('sort_newest'.tr),
                ),
                DropdownMenuItem(
                  value: _DateSort.oldest,
                  child: Text('sort_oldest'.tr),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _dateSort = value;
                });
              },
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: DropdownButtonFormField<_DistanceSort>(
              value: _distanceSort,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: _DistanceSort.none,
                  child: Text('sort_distance_none'.tr),
                ),
                DropdownMenuItem(
                  value: _DistanceSort.nearest,
                  child: Text('sort_nearest'.tr),
                ),
                DropdownMenuItem(
                  value: _DistanceSort.farthest,
                  child: Text('sort_farthest'.tr),
                ),
              ],
              onChanged: hasLocation
                  ? (value) {
                      if (value == null) return;
                      setState(() {
                        _distanceSort = value;
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  List _sortOrders(List orders, ProfileController profile, bool hasLocation) {
    final List sorted = List.of(orders);
    final double? userLat = profile.recordLocationBody?.latitude;
    final double? userLng = profile.recordLocationBody?.longitude;

    int compareByDate(a, b) {
      final DateTime? aDate = _parseDate(a.createdAt);
      final DateTime? bDate = _parseDate(b.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return _dateSort == _DateSort.newest
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    }

    int compareByDistance(a, b) {
      if (!hasLocation || userLat == null || userLng == null) return 0;
      final double aDist = _distanceFromOrder(a, userLat, userLng);
      final double bDist = _distanceFromOrder(b, userLat, userLng);
      if (_distanceSort == _DistanceSort.nearest) {
        return aDist.compareTo(bDist);
      }
      if (_distanceSort == _DistanceSort.farthest) {
        return bDist.compareTo(aDist);
      }
      return 0;
    }

    sorted.sort((a, b) {
      int byDistance = compareByDistance(a, b);
      if (byDistance != 0) return byDistance;
      return compareByDate(a, b);
    });

    return sorted;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  double _distanceFromOrder(order, double userLat, double userLng) {
    final double? lat = _orderLat(order);
    final double? lng = _orderLng(order);
    if (lat == null || lng == null) {
      return double.infinity;
    }
    return _haversine(userLat, userLng, lat, lng);
  }

  double? _orderLat(order) {
    final String? latStr = order.deliveryAddress?.latitude ?? order.storeLat;
    return latStr != null ? double.tryParse(latStr) : null;
  }

  double? _orderLng(order) {
    final String? lngStr = order.deliveryAddress?.longitude ?? order.storeLng;
    return lngStr != null ? double.tryParse(lngStr) : null;
  }

  double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const double r = 6371; // km
    final double dLat = _degToRad(lat2 - lat1);
    final double dLng = _degToRad(lng2 - lng1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);
}

enum _DateSort { newest, oldest }

enum _DistanceSort { none, nearest, farthest }
