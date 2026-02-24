import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:shellafood_delivery/features/notification/controllers/notification_controller.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/quick_action_button_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/financial_overview_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/performance_card_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/current_orders_list_widget.dart';
import 'package:shellafood_delivery/common/services/quick_action_service.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _loadData() async {
    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
    bool isBatteryOptimizationDisabled = GetPlatform.isAndroid
        ? (await DisableBatteryOptimization.isBatteryOptimizationDisabled)!
        : true;
    if (!isBatteryOptimizationDisabled && GetPlatform.isAndroid) {
      DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadData();

    return Scaffold(
      appBar: AppBar(
        leading: GetBuilder<ProfileController>(
          builder: (profileController) {
            return Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Image.asset(
                Images.logo,
                height: 30,
                width: 30,
              ),
            );
          },
        ),
        title: GetBuilder<ProfileController>(
          builder: (profileController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'todays_earning'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Text(
                  profileController.profileModel?.todaysEarning != null
                      ? PriceConverterHelper.convertPrice(
                          profileController.profileModel!.todaysEarning!)
                      : '\$0.00',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        actions: [
          GetBuilder<NotificationController>(
            builder: (notificationController) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Get.toNamed(RouteHelper.getNotificationRoute());
                    },
                  ),
                  if (notificationController.hasNotification)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          GetBuilder<ProfileController>(
            builder: (profileController) {
              return GetBuilder<OrderController>(
                builder: (orderController) {
                  return (profileController.profileModel != null &&
                          orderController.currentOrderList != null)
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeDefault),
                          child: FlutterSwitch(
                            width: 60,
                            height: 25,
                            valueFontSize: Dimensions.fontSizeExtraSmall,
                            showOnOff: true,
                            activeText: 'on',
                            inactiveText: 'off',
                            activeColor: AppColors.success,
                            inactiveColor: AppColors.onSurfaceDisabled,
                            value: profileController.profileModel!.active == 1,
                            onToggle: (bool isActive) async {
                              if (!isActive &&
                                  orderController
                                      .currentOrderList!.isNotEmpty) {
                                showCustomSnackBar(
                                    'you_can_not_go_offline_now'.tr);
                              } else {
                                if (!isActive) {
                                  Get.dialog(ConfirmationDialogWidget(
                                    icon: Images.warning,
                                    description: 'are_you_sure_to_offline'.tr,
                                    onYesPressed: () {
                                      Get.back();
                                      profileController.updateActiveStatus();
                                    },
                                  ));
                                } else {
                                  LocationPermission permission =
                                      await Geolocator.checkPermission();
                                  if (permission == LocationPermission.denied ||
                                      permission ==
                                          LocationPermission.deniedForever ||
                                      (GetPlatform.isIOS ? false : true)) {
                                    if (GetPlatform.isAndroid) {
                                      Get.dialog(
                                          ConfirmationDialogWidget(
                                            icon: Images.locationPermission,
                                            iconSize: 200,
                                            hasCancel: false,
                                            description:
                                                'this_app_collects_location_data'
                                                    .tr,
                                            onYesPressed: () {
                                              Get.back();
                                              _checkPermission(() =>
                                                  profileController
                                                      .updateActiveStatus());
                                            },
                                          ),
                                          barrierDismissible: false);
                                    } else {
                                      _checkPermission(() => profileController
                                          .updateActiveStatus());
                                    }
                                  } else {
                                    profileController.updateActiveStatus();
                                  }
                                }
                              }
                            },
                          ),
                        )
                      : const SizedBox();
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundGradientDark
              : AppColors.meshGradientSoft,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    return await _loadData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      child: GetBuilder<ProfileController>(
                          builder: (profileController) {
                        return Column(children: [
                        // Active Orders Section: Hero card + expandable list
                        GetBuilder<OrderController>(builder: (orderController) {
                          return CurrentOrdersListWidget(
                            orders: orderController.currentOrdersSorted ?? [],
                            onRefresh: () => _loadData(),
                          );
                        }),

                        // Quick Actions Row (10% screen space)
                        DeliveryQuickActionsWidget(
                          onCallSupport: () {
                            QuickActionService.callSupport();
                          },
                          onEarningsHistory: () {
                            QuickActionService.showEarningsOptions();
                          },
                          onNavigate: () {
                            QuickActionService.navigateToActiveOrder();
                          },
                          onHelpCenter: () {
                            QuickActionService.showHelpOptions();
                          },
                        ),

                        const SizedBox(height: Dimensions.cardSpacingVertical),

                        // Financial Overview Card (20% screen space)
                        if (profileController.profileModel != null &&
                            profileController.profileModel!.earnings == 1)
                          FinancialOverviewWidget(
                            balance: profileController.profileModel!.balance,
                            cashInHand:
                                profileController.profileModel!.cashInHands,
                            todaysEarning:
                                profileController.profileModel!.todaysEarning,
                            thisWeekEarning:
                                profileController.profileModel!.thisWeekEarning,
                            thisMonthEarning: profileController
                                .profileModel!.thisMonthEarning,
                            showWarning:
                                profileController.profileModel!.cashInHands! >
                                    1000,
                            onBalanceTap: () {
                              QuickActionService.navigateToEarningsHistory();
                            },
                            onCashInHandTap: () {
                              Get.toNamed(RouteHelper.getCashInHandRoute());
                            },
                            onEarningsTap: () {
                              QuickActionService.showEarningsOptions();
                            },
                          ),

                        const SizedBox(height: Dimensions.cardSpacingVertical),

                        // Performance Metrics (20% screen space)
                        DeliveryPerformanceWidget(
                          todaysOrders:
                              profileController.profileModel?.todaysOrderCount,
                          weeklyOrders: profileController
                              .profileModel?.thisWeekOrderCount,
                          totalOrders:
                              profileController.profileModel?.orderCount,
                          onTodaysOrdersTap: () {
                            Get.toNamed(RouteHelper.getFilteredOrdersRoute(
                                'today', 'todays_orders'.tr));
                          },
                          onWeeklyOrdersTap: () {
                            Get.toNamed(RouteHelper.getFilteredOrdersRoute(
                                'week', 'this_week_orders'.tr));
                          },
                          onTotalOrdersTap: () {
                            // Navigate to all orders screen
                            Get.toNamed(RouteHelper.getMainRoute('order'));
                          },
                        ),

                        // Remove redundant order stats - already shown in performance metrics above

                        const SizedBox(height: Dimensions.paddingSizeSection),
                      ]);
                    }),
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkPermission(Function callback) async {
    try {
      debugPrint('Home screen: Checking location permission');

      LocationPermission permission = await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();

      debugPrint('Home screen: Permission status: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('Home screen: Permission denied, showing dialog');
        Get.dialog(
            CustomAlertDialogWidget(
                description: 'you_denied'.tr,
                onOkPressed: () async {
                  Get.back();
                  // Try one more time
                  final retryPermission = await Geolocator.requestPermission();
                  if (retryPermission == LocationPermission.denied) {
                    debugPrint(
                        'Home screen: Permission still denied after retry');
                    return;
                  }
                  // If retry succeeded, execute callback
                  callback();
                }),
            barrierDismissible: false);
      } else if (permission == LocationPermission.deniedForever) {
        debugPrint('Home screen: Permission denied forever, opening settings');
        Get.dialog(
            CustomAlertDialogWidget(
                description: 'you_denied_forever'.tr,
                onOkPressed: () async {
                  Get.back();
                  await Geolocator.openAppSettings();
                }),
            barrierDismissible: false);
      } else {
        debugPrint('Home screen: Permission granted, executing callback');
        callback();
      }
    } catch (e) {
      debugPrint('Home screen: Error checking permission: $e');
    }
  }
}
