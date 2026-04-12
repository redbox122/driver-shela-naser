import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription<List<ConnectivityResult>> _onConnectivityChanged;
  // SS-05: guard against concurrent _route() calls (e.g. offline→online restore)
  bool _routeStarted = false;

  @override
  void initState() {
    super.initState();
    // SS-03: removed early getProfile() call — _route() already calls it for
    // logged-in users, so the duplicate request here was wasteful.

    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!firstTime) {
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        final bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;

        // Use a mounted check before accessing BuildContext across async gap
        if (mounted) {
          if (!isNotConnected) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: isNotConnected ? Colors.red : Colors.green,
            duration: Duration(seconds: isNotConnected ? 6000 : 3),
            content: Text(
              isNotConnected ? 'no_connection' : 'connected',
              textAlign: TextAlign.center,
            ),
          ));
        }
        // SS-05: only start routing if not already in progress
        if (!isNotConnected && !_routeStarted) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  Future<void> _route() async {
    // SS-05: prevent duplicate concurrent routing
    if (_routeStarted) return;
    _routeStarted = true;

    final bool isSuccess =
        await Get.find<SplashController>().getConfigData();

    if (!isSuccess) {
      // Config fetch failed — allow retry on next connectivity restore
      _routeStarted = false;
      return;
    }

    // CS-04: all configModel fields accessed with null-safe fallbacks
    final splashController = Get.find<SplashController>();
    final configModel = splashController.configModel;
    if (configModel == null) {
      _routeStarted = false;
      return;
    }

    double minimumVersion = 0;
    if (GetPlatform.isAndroid) {
      minimumVersion = configModel.appMinimumVersionAndroid ?? 0;
    } else if (GetPlatform.isIOS) {
      minimumVersion = configModel.appMinimumVersionIos ?? 0;
    }

    final bool inMaintenance = configModel.maintenanceMode ?? false;

    // SS-01: removed the artificial 1-second Timer delay that was here before.
    // Navigation now proceeds as soon as the config response is processed.
    if (AppConstants.appVersion < minimumVersion || inMaintenance) {
      Get.offNamed(RouteHelper.getUpdateRoute(
          AppConstants.appVersion < minimumVersion));
      return;
    }

    if (widget.body != null) {
      if (widget.body!.notificationType == NotificationType.order) {
        Get.offNamed(RouteHelper.getOrderDetailsRoute(
            widget.body!.orderId,
            fromNotification: true));
      } else if (widget.body!.notificationType ==
          NotificationType.order_request) {
        Get.offNamed(RouteHelper.getMainRoute('order-request'));
      } else if (widget.body!.notificationType == NotificationType.general) {
        Get.offNamed(
            RouteHelper.getNotificationRoute(fromNotification: true));
      } else {
        Get.offNamed(RouteHelper.getChatRoute(
            notificationBody: widget.body,
            conversationId: widget.body!.conversationId,
            fromNotification: true));
      }
    } else {
      if (Get.find<AuthController>().isLoggedIn()) {
        // SS-02: updateToken and getProfile are run concurrently with Future.wait
        // instead of sequentially, saving one full round-trip before navigation.
        await Future.wait([
          Get.find<AuthController>().updateToken(),
          Get.find<ProfileController>().getProfile(),
        ]);
        Get.offNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.logo, width: 200),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('suffix_name'.tr,
                style: robotoMedium, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
