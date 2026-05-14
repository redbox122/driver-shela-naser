import 'dart:async';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/language/controllers/language_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/common/controllers/theme_controller.dart';
import 'package:shellafood_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:shellafood_delivery/helper/notification_helper.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/theme/dark_theme.dart';
import 'package:shellafood_delivery/theme/light_theme.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/util/messages.dart';
import 'package:shellafood_delivery/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // SS-06: ensureInitialized must come before any platform-channel calls
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[APP_BASE_URL] ${AppConstants.baseUrl}');
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      // Initialize notification helper FIRST to create channels
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);

      // Register background handler BEFORE any other Firebase operations
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

      // Check for notification that opened app
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  runApp(MyApp(languages: languages, body: body));
}

// WR-04: Converted to StatefulWidget so web init side-effects run once in
// initState() instead of on every build() call, which caused repeated API calls.
class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      _route();
    }
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null)
              ? const SizedBox()
              : GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  theme: themeController.darkTheme ? dark : light,
                  locale: localizeController.locale,
                  translations: Messages(languages: widget.languages),
                  fallbackLocale: Locale(
                      AppConstants.languages[0].languageCode!,
                      AppConstants.languages[0].countryCode),
                  initialRoute: RouteHelper.getSplashRoute(widget.body),
                  getPages: RouteHelper.routes,
                  navigatorObservers: [AppRouteLogger()],
                  defaultTransition: Transition.topLevel,
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (BuildContext context, widget) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1)),
                        child: widget!);
                  });
        });
      });
    });
  }
}

class AppRouteLogger extends GetObserver {
  void _logRoute(String action, Route<dynamic>? route) {
    assert(() {
      final String name = route?.settings.name ?? 'unknown';
      debugPrint('\x1B[34m[ROUTE] $action: $name\x1B[0m');
      return true;
    }());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute('ENTER', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRoute('EXIT', route);
    if (previousRoute != null) {
      _logRoute('BACK_TO', previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRoute('REPLACE', newRoute);
  }
}

// SR-01: MyHttpOverrides (global TLS bypass) has been removed.
// All HTTPS connections now use proper certificate validation.
