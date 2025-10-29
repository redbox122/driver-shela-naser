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
import 'package:shellafood_delivery/features/home/widgets/hero_order_card_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/quick_action_button_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/financial_overview_widget.dart';
import 'package:shellafood_delivery/features/home/widgets/performance_card_widget.dart';
import 'package:shellafood_delivery/common/services/quick_action_service.dart';
import 'package:shellafood_delivery/features/order/screens/order_details_screen.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundGradientDark
              : AppColors.meshGradientSoft,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Modern Header
              _buildModernHeader(context),

              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    return await _loadData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: GetBuilder<ProfileController>(
                        builder: (profileController) {
                      return Column(children: [
                        // Hero Section: Active Order with overlapping effect
                        GetBuilder<OrderController>(builder: (orderController) {
                          bool hasActiveOrder =
                              orderController.currentOrderList != null &&
                                  orderController.currentOrderList!.isNotEmpty;

                          // Debug information
                          print('=== ORDER DEBUG ===');
                          print('Has Active Order: $hasActiveOrder');
                          if (hasActiveOrder) {
                            print(
                                'Order Count: ${orderController.currentOrderList!.length}');
                            print(
                                'First Order ID: ${orderController.currentOrderList![0].id}');
                          }
                          print('==================');

                          if (hasActiveOrder) {
                            return HeroOrderCardWidget(
                              orderModel: orderController.currentOrderList![0],
                              isRunningOrder: true,
                              orderIndex: 0,
                              onCallCustomer: () {
                                // Call customer logic - implement when order details are available
                                showCustomSnackBar(
                                    'call_customer_feature_coming_soon'.tr);
                              },
                              onNavigate: () async {
                                QuickActionService.navigateToActiveOrder();
                              },
                              onViewDetails: () {
                                Get.toNamed(
                                  RouteHelper.getOrderDetailsRoute(
                                      orderController.currentOrderList![0].id),
                                  arguments: OrderDetailsScreen(
                                    orderId:
                                        orderController.currentOrderList![0].id,
                                    isRunningOrder: true,
                                    orderIndex: 0,
                                  ),
                                );
                              },
                            );
                          } else {
                            // Show empty state with professional card
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeHero,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: Card(
                                elevation: Dimensions.elevationMedium,
                                color: Colors
                                    .black87, // Dark background for visibility
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusLarge),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeLarge),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.delivery_dining_rounded,
                                          size: Dimensions.iconSizeHero + 8,
                                          color: Colors
                                              .white, // White icon for contrast
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      Text(
                                        'no_active_orders'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Colors
                                              .white, // White text for visibility
                                        ),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      Text(
                                        'You will be notified when new orders arrive',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Colors.white.withOpacity(
                                              0.8), // Light white for subtitle
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      height: Dimensions.headerHeightCompact,
      decoration: BoxDecoration(
        gradient: AppColors.meshGradientPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radiusHero),
          bottomRight: Radius.circular(Dimensions.radiusHero),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHero,
          vertical: Dimensions.paddingSizeCompact,
        ),
        child: Row(
          children: [
            // Left: Logo
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeCompact),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusModern),
              ),
              child: Image.asset(
                Images.logo,
                height: 24,
                width: 24,
                color: AppColors.surface,
              ),
            ),

            // Center: Earnings
            Expanded(
              child: GetBuilder<ProfileController>(
                builder: (profileController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'todays_earning'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: AppColors.surface.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        profileController.profileModel?.todaysEarning != null
                            ? PriceConverterHelper.convertPrice(
                                profileController.profileModel!.todaysEarning!)
                            : '\$0.00',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeEarningsCompact,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Right: Notifications + Toggle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Notifications
                GetBuilder<NotificationController>(
                  builder: (notificationController) {
                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeCompact),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusModern),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: AppColors.surface,
                          ),
                        ),
                        if (notificationController.hasNotification)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1,
                                  color: AppColors.surface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                // Online/Offline toggle
                GetBuilder<ProfileController>(
                  builder: (profileController) {
                    return GetBuilder<OrderController>(
                      builder: (orderController) {
                        return (profileController.profileModel != null &&
                                orderController.currentOrderList != null)
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeCompact,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                child: FlutterSwitch(
                                  width: 60,
                                  height: 25,
                                  valueFontSize: Dimensions.fontSizeExtraSmall,
                                  showOnOff: true,
                                  activeText: 'on',
                                  inactiveText: 'off',
                                  activeColor: AppColors.success,
                                  inactiveColor: AppColors.onSurfaceDisabled,
                                  value:
                                      profileController.profileModel!.active ==
                                          1,
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
                                          description:
                                              'are_you_sure_to_offline'.tr,
                                          onYesPressed: () {
                                            Get.back();
                                            profileController
                                                .updateActiveStatus();
                                          },
                                        ));
                                      } else {
                                        LocationPermission permission =
                                            await Geolocator.checkPermission();
                                        if (permission ==
                                                LocationPermission.denied ||
                                            permission ==
                                                LocationPermission
                                                    .deniedForever ||
                                            (GetPlatform.isIOS
                                                ? false
                                                : true)) {
                                          if (GetPlatform.isAndroid) {
                                            Get.dialog(
                                                ConfirmationDialogWidget(
                                                  icon:
                                                      Images.locationPermission,
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
                                            _checkPermission(() =>
                                                profileController
                                                    .updateActiveStatus());
                                          }
                                        } else {
                                          profileController
                                              .updateActiveStatus();
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
          ],
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
