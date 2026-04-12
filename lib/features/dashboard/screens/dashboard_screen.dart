import 'dart:async';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/disbursement/helper/disbursement_helper.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:shellafood_delivery/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:shellafood_delivery/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:shellafood_delivery/features/home/screens/home_screen.dart';
import 'package:shellafood_delivery/features/profile/screens/profile_screen.dart';
import 'package:shellafood_delivery/features/order/screens/order_request_screen.dart';
import 'package:shellafood_delivery/features/order/screens/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromOrderDetails;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromOrderDetails = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.shellafood/app_retain');
  late StreamSubscription _stream;
  DisbursementHelper disbursementHelper = DisbursementHelper();

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      OrderRequestScreen(onTap: () => _setPage(0)),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();

    // NA-02: NotificationHelper already has an onMessage listener that calls
    // getCurrentOrders() and getLatestOrdersIfActive(). This listener is kept
    // only for UI-exclusive actions (showing dialogs, handling 'block').
    // The duplicate API calls have been removed to prevent 4× requests per
    // notification (2 listeners × 2 methods each).
    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String? type = message.data['body_loc_key'] ?? message.data['type'];
      final String? orderID =
          message.data['title_loc_key'] ?? message.data['order_id'];
      final bool isParcel = (message.data['order_type'] == 'parcel_order');

      if (type == 'new_order' || type == 'order_request') {
        // CS-03: guard int.parse — malformed order_id would crash the listener
        final int? parsedId =
            int.tryParse(message.data['order_id']?.toString() ?? '');
        if (parsedId == null) return;
        // Order list refresh is handled by NotificationHelper's listener.
        Get.dialog(NewRequestDialogWidget(
            isRequest: true,
            onTap: () => _navigateRequestPage(),
            orderId: parsedId,
            isParcel: isParcel));
      } else if (type == 'assign' && orderID != null && orderID.isNotEmpty) {
        final int? parsedOrderId =
            int.tryParse(message.data['order_id']?.toString() ?? '');
        final int? parsedAssignId = int.tryParse(orderID);
        if (parsedOrderId == null || parsedAssignId == null) return;
        // Order list refresh is handled by NotificationHelper's listener.
        Get.dialog(NewRequestDialogWidget(
            isRequest: false,
            orderId: parsedOrderId,
            isParcel: isParcel,
            onTap: () {
              Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                  parsedAssignId,
                  fromNotification: true));
            }));
      } else if (type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<ProfileController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  showDisbursementWarningMessage() async {
    if (!widget.fromOrderDetails) {
      disbursementHelper.enableDisbursementWarningMessage(true);
    }
  }

  void _navigateRequestPage() {
    if (Get.find<ProfileController>().profileModel != null &&
        Get.find<ProfileController>().profileModel!.active == 1 &&
        Get.find<OrderController>().currentOrderList != null &&
        Get.find<OrderController>().currentOrderList!.isEmpty) {
      _setPage(1);
    } else {
      if (Get.find<ProfileController>().profileModel == null ||
          Get.find<ProfileController>().profileModel!.active == 0) {
        Get.dialog(CustomAlertDialogWidget(
            description: 'you_are_offline_now'.tr,
            onOkPressed: () => _safePopDialog()));
      } else {
        _setPage(1);
      }
    }
  }

  @override
  void dispose() {
    _stream.cancel();
    _pageController?.dispose(); // ML-01: dispose to release scroll resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          // CS-01: profileModel can be null before the first API response
          final bool isActive =
              Get.find<ProfileController>().profileModel?.active == 1;
          if (GetPlatform.isAndroid && isActive) {
            _channel.invokeMethod('sendToBackground');
          } else {
            return;
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : BottomAppBar(
                elevation: 5,
                notchMargin: 5,
                shadowColor: Colors.grey[300],
                shape: const CircularNotchedRectangle(),
                child: Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    BottomNavItemWidget(
                        iconData: Icons.home,
                        isSelected: _pageIndex == 0,
                        onTap: () => _setPage(0)),
                    BottomNavItemWidget(
                        iconData: Icons.list_alt_rounded,
                        isSelected: _pageIndex == 1,
                        onTap: () {
                          _navigateRequestPage();
                        }),
                    BottomNavItemWidget(
                        iconData: Icons.shopping_bag,
                        isSelected: _pageIndex == 2,
                        onTap: () => _setPage(2)),
                    BottomNavItemWidget(
                        iconData: Icons.person,
                        isSelected: _pageIndex == 3,
                        onTap: () => _setPage(3)),
                  ]),
                ),
              ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  void _safePopDialog() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).maybePop();
  }
}
