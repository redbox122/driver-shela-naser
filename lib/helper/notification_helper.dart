import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/chat/controllers/chat_controller.dart';
import 'package:shellafood_delivery/features/notification/controllers/notification_controller.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {
  static const String _defaultChannelId = 'shellafood';
  static const String _ordersChannelId = 'shellafood_orders';
  static final Map<int, Timer> _orderReminderTimers = {};

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    // Request notification permissions for Android 13+ (API 33+)
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        // Create notification channel for Android 8.0+ (API 26+)
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            _defaultChannelId,
            'shellafood',
            description: 'Delivery notifications',
            importance: Importance.max, // KEY: Enables heads-up banners
            playSound: true,
            enableVibration: true,
            showBadge: true, // Enable badge on app icon
          ),
        );
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            _ordersChannelId,
            'Delivery Orders',
            description: 'New and assigned order notifications',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            enableVibration: true,
            showBadge: true,
          ),
        );

        if (kDebugMode) {
          print(
              "🔔 Android notification channel 'shellafood' created with max importance");
        }
      }
    }

    await flutterLocalNotificationsPlugin.initialize(
        settings: initializationsSettings,
        onDidReceiveNotificationResponse: (load) async {
      try {
        if (load.payload != null && load.payload!.isNotEmpty) {
          NotificationBodyModel payload =
              NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          if (payload.notificationType == NotificationType.order) {
            Get.offAllNamed(RouteHelper.getOrderDetailsRoute(payload.orderId,
                fromNotification: true));
          } else if (payload.notificationType ==
              NotificationType.order_request) {
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          } else if (payload.notificationType == NotificationType.general) {
            Get.offAllNamed(
                RouteHelper.getNotificationRoute(fromNotification: true));
          } else {
            Get.offAllNamed(RouteHelper.getChatRoute(
                notificationBody: payload,
                conversationId: payload.conversationId,
                fromNotification: true));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error handling notification tap: $e");
        }
      }
      return;
    });

    if (kDebugMode) {
      print("🔔 Setting up onMessage listener...");
    }

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("🔔 onMessage FIRED - message received in foreground");
        print("🔔 onMessage message type:${message.data['type']}");
        print("🔔 onMessage message data:${message.data}");
        print("🔔 onMessage notification title:${message.notification?.title}");
        print("🔔 onMessage notification body:${message.notification?.body}");
      }

      try {
        String? type = message.data['type'];
        final bool isOrderType = _isOrderType(type);
        final int? orderId = _parseOrderId(message.data);
        final DateTime? orderTime = _parseOrderTime(message);
        final Duration? orderAge =
            orderTime != null ? DateTime.now().difference(orderTime) : null;
        final bool canNotifyOrder =
            !isOrderType || orderAge == null || orderAge.inMinutes <= 2;
        final bool isOrderForDriver =
            !isOrderType || _isOrderVisibleForDriver(message.data);

        if (kDebugMode && isOrderType) {
          final Duration offset =
              Get.find<SplashController>().currentTime.difference(DateTime.now());
          debugPrint(
              'Order notification: serverTimeOffsetMs=${offset.inMilliseconds}');
        }

        if (canNotifyOrder && isOrderForDriver) {
          await NotificationHelper.showNotification(
              message, flutterLocalNotificationsPlugin);
        }

        if (kDebugMode) {
          print(
              "Notification display called for type: $type (notify=$canNotifyOrder)");
        }

        // Handle special cases based on notification type
        try {
          if (message.data['type'] == 'message' &&
              Get.currentRoute.startsWith(RouteHelper.chatScreen)) {
            if (Get.find<AuthController>().isLoggedIn()) {
              Get.find<ChatController>().getConversationList(1);
              if (Get.find<ChatController>()
                      .messageModel!
                      .conversation!
                      .id
                      .toString() ==
                  message.data['conversation_id'].toString()) {
                Get.find<ChatController>().getMessages(
                  1,
                  NotificationBodyModel(
                    notificationType: NotificationType.message,
                    customerId: message.data['sender_type'] == AppConstants.user
                        ? 0
                        : null,
                    vendorId: message.data['sender_type'] == AppConstants.vendor
                        ? 0
                        : null,
                  ),
                  null,
                  int.parse(message.data['conversation_id'].toString()),
                );
              }
            }
          } else if (message.data['type'] == 'message' &&
              Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
            if (Get.find<AuthController>().isLoggedIn()) {
              Get.find<ChatController>().getConversationList(1);
            }
          } else {
            // Update order lists for order-related notifications
            if (type != 'message') {
              Get.find<OrderController>().getCurrentOrders();
              Get.find<OrderController>().getLatestOrdersIfActive();
              Get.find<NotificationController>().getNotificationList();
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error in notification handler logic: $e");
          }
        }

        // Schedule a one-time reminder at 5 minutes for order notifications
        if (isOrderType && orderId != null && orderTime != null) {
          _scheduleOrderReminder(
              orderId, orderTime, flutterLocalNotificationsPlugin);
        }
      } catch (e) {
        if (kDebugMode) {
          print("ERROR in onMessage listener: $e");
          print("Error stack: ${e.toString()}");
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("onOpenApp message type:${message.data['type']}");
      }
      try {
        if (message.data.isNotEmpty) {
          NotificationBodyModel notificationBody =
              convertNotification(message.data)!;

          if (notificationBody.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(
                int.parse(message.data['order_id'])));
          } else if (notificationBody.notificationType ==
              NotificationType.order_request) {
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          } else if (notificationBody.notificationType ==
              NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute());
          } else {
            Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: notificationBody,
                conversationId: notificationBody.conversationId));
          }
        }
      } catch (_) {}
    });
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if (kDebugMode) {
      print("🔔 showNotification called - type: ${message.data['type']}");
    }

    String? title;
    String? body;
    String? image;
    NotificationBodyModel? notificationBody = convertNotification(message.data);

    // Get title and body from notification or data
    title = message.notification?.title ?? message.data['title'];
    body = message.notification?.body ?? message.data['body'];

    // If still null, try alternative keys
    title ??= message.data['title_loc_key'];
    body ??= message.data['body_loc_key'];

    // Translate keys if they match known translation keys (before setting defaults)
    // This handles cases where backend sends translation keys instead of translated text
    try {
      if (title != null && Get.keys.containsKey(title)) {
        title = title.tr;
      }
      if (body != null && Get.keys.containsKey(body)) {
        body = body.tr;
      }
    } catch (_) {
      // If translation fails, use original text
    }

    // Fallback to default if still null (after translation attempt)
    final String finalTitle = title ?? 'New Notification';
    final String finalBody = body ?? 'You have a new notification';

    if (kDebugMode) {
      print("🔔 Notification title: $finalTitle, body: $finalBody");

    }

    final bool isOrderType = _isOrderType(message.data['type']);
    final String channelId = isOrderType ? _ordersChannelId : _defaultChannelId;
    final String channelName = isOrderType ? 'Delivery Orders' : 'shellafood';
    final String channelDesc = isOrderType
        ? 'New and assigned order notifications'
        : 'Delivery notifications';

    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http')
            ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
        : null;

    if (GetPlatform.isIOS) {
      // iOS: Show notification using local notifications plugin
      // Firebase handles system notifications, but we show local for better control
      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification.wav',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(iOS: iosPlatformChannelSpecifics);

      await fln.show(
        id: message.hashCode,
        title: finalTitle,
        body: finalBody,
        notificationDetails: platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : jsonEncode(message.data),
      );

      if (kDebugMode) {
        print("🔔 iOS notification displayed");
      }
    } else {
      // Android: Show notification with image support
      if (image != null && image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
              finalTitle,
              finalBody,
              notificationBody,
              image,
              fln,
              channelId,
              channelName,
              channelDesc);
          if (kDebugMode) {
            print("🔔 Android notification with image displayed");
          }
        } catch (e) {
          if (kDebugMode) {
            print("🔔 Error showing image notification, fallback to text: $e");
          }
          await showBigTextNotification(
              finalTitle, finalBody, notificationBody, fln, channelId, channelName, channelDesc);
        }
      } else {
        await showBigTextNotification(
            finalTitle, finalBody, notificationBody, fln, channelId, channelName, channelDesc);
        if (kDebugMode) {
          print("🔔 Android text notification displayed");
        }
      }
    }
  }

  static Future<void> showTextNotification(
      String title,
      String body,
      NotificationBodyModel notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'shellafood',
      'shellafood',
      channelDescription: 'Delivery notifications',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      channelShowBadge: true,
      showWhen: true,
      color: const Color(0xFF2A9849), // App primary green
      colorized: true,
      icon: 'notification_icon',
      ticker: 'New delivery notification',
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      enableLights: true,
      ledColor: const Color(0xFF2A9849),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(notificationBody.toJson()),
    );
  }

  static Future<void> showBigTextNotification(
      String? title,
      String body,
      NotificationBodyModel? notificationBody,
      FlutterLocalNotificationsPlugin fln,
      [String channelId = _defaultChannelId,
      String channelName = 'shellafood',
      String channelDesc = 'Delivery notifications']) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: '📦 Delivery Notification • Tap to open',
      htmlFormatSummaryText: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      channelShowBadge: true,
      showWhen: true,
      color: const Color(0xFF2A9849), // App primary green
      colorized: true, // Colored notification bar
      icon: 'notification_icon',
      largeIcon: const DrawableResourceAndroidBitmap('notification_icon'),
      ticker: 'New delivery notification',
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      enableLights: true,
      ledColor: const Color(0xFF2A9849),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: notificationBody != null
          ? jsonEncode(notificationBody.toJson())
          : null,
    );
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String? title,
      String? body,
      NotificationBodyModel? notificationBody,
      String image,
      FlutterLocalNotificationsPlugin fln,
      [String channelId = _defaultChannelId,
      String channelName = 'shellafood',
      String channelDesc = 'Delivery notifications']) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: '📦 Delivery Notification • Tap to view details',
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      channelShowBadge: true,
      showWhen: true,
      color: const Color(0xFF2A9849), // App primary green
      colorized: true,
      icon: 'notification_icon',
      ticker: 'New delivery notification',
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      enableLights: true,
      ledColor: const Color(0xFF2A9849),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: notificationBody != null
          ? jsonEncode(notificationBody.toJson())
          : null,
    );
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel? convertNotification(Map<String, dynamic> data) {
    if (data['type'] == 'general') {
      return NotificationBodyModel(notificationType: NotificationType.general);
    } else if (data['type'] == 'order_status') {
      return NotificationBodyModel(
          orderId: int.parse(data['order_id']),
          notificationType: NotificationType.order);
    } else if (data['type'] == 'new_order' || data['type'] == 'assign') {
      return NotificationBodyModel(
          orderId: int.parse(data['order_id']),
          notificationType: NotificationType.order);
    } else if (data['type'] == 'order_request') {
      return NotificationBodyModel(
          orderId: int.parse(data['order_id']),
          notificationType: NotificationType.order_request);
    } else if (data['type'] == 'message') {
      return NotificationBodyModel(
        conversationId: (data['conversation_id'] != null &&
                data['conversation_id'].isNotEmpty)
            ? int.parse(data['conversation_id'])
            : null,
        notificationType: NotificationType.message,
        type: data['sender_type'] == AppConstants.user
            ? AppConstants.user
            : AppConstants.vendor,
      );
    } else {
      return null;
    }
  }

  static bool _isOrderType(String? type) {
    return type == 'new_order' || type == 'order_request' || type == 'assign';
  }

  static bool _isOrderVisibleForDriver(Map<String, dynamic> data) {
    if (!Get.isRegistered<ProfileController>()) {
      return true;
    }
    final profile = Get.find<ProfileController>().profileModel;
    if (profile == null || profile.active != 1) {
      return false;
    }

    final int? deliveryManId = _parseInt(data['delivery_man_id']);
    if (deliveryManId != null && profile.id != null) {
      if (deliveryManId != profile.id) {
        return false;
      }
    }

    if (profile.type == 'zone_wise' && profile.zoneId != null) {
      final int? zoneId = _parseInt(
          data['zone_id'] ?? data['zoneId'] ?? data['delivery_zone_id']);
      if (zoneId != null && zoneId != profile.zoneId) {
        return false;
      }
    }
    return true;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static int? _parseOrderId(Map<String, dynamic> data) {
    final dynamic raw =
        data['order_id'] ?? data['orderId'] ?? data['id'] ?? data['order'];
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  static DateTime? _parseOrderTime(RemoteMessage message) {
    final data = message.data;
    final dynamic raw = data['created_at'] ??
        data['createdAt'] ??
        data['order_time'] ??
        data['time'];
    if (raw != null) {
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {}
    }
    return message.sentTime;
  }

  static void _scheduleOrderReminder(int orderId, DateTime orderTime,
      FlutterLocalNotificationsPlugin fln) {
    if (_orderReminderTimers.containsKey(orderId)) {
      return;
    }

    final Duration age = DateTime.now().difference(orderTime);
    if (age.inMinutes >= 5) {
      return;
    }

    final Duration delay = Duration(minutes: 5) - age;
    _orderReminderTimers[orderId] = Timer(delay, () async {
      _orderReminderTimers.remove(orderId);

      final String title = 'order_reminder_title'.tr;
      final String body =
          '${'order_reminder_body'.tr} #$orderId';
      final NotificationBodyModel notificationBody = NotificationBodyModel(
          orderId: orderId, notificationType: NotificationType.order_request);

      await showBigTextNotification(title, body, notificationBody, fln);
    });
  }
}

/// Background message handler - must be top-level function
/// Called when app is terminated or in background
/// Required annotation for AOT compilation (release builds)
@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("📱🔔 BACKGROUND NOTIFICATION RECEIVED!");
    print("📱 Background data: ${message.data}");
    print("📱 Background title: ${message.notification?.title}");
    print("📱 Background body: ${message.notification?.body}");
  }

  try {
    // Initialize local notifications plugin
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    // Initialize Android notification settings
    const AndroidInitializationSettings androidInitialize =
        AndroidInitializationSettings('notification_icon');

    // Initialize iOS notification settings
    const DarwinInitializationSettings iosInitialize =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    // Initialize the plugin (safe to call multiple times)
    await localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap when app opens from terminated state
        if (kDebugMode) {
          print("Notification tapped from background: ${details.payload}");
        }
        // Navigation will be handled when app fully initializes
      },
    );

    // CRITICAL: Create notification channel for Android BEFORE showing notification
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        // Create notification channel with max importance for heads-up display
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificationHelper._defaultChannelId,
            'shellafood',
            description: 'Delivery notifications',
            importance: Importance.max, // KEY: Enables heads-up banners
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificationHelper._ordersChannelId,
            'Delivery Orders',
            description: 'New and assigned order notifications',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            enableVibration: true,
            showBadge: true,
          ),
        );
        if (kDebugMode) {
          print("🔔 Background: Notification channel created");
        }
      }
    }

    // Get notification data
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];

    // Note: Cannot use Get.tr in background isolate, use original text
    // Translations will be handled by app when it opens

    if (title != null && body != null) {
      // Convert notification data for payload
      NotificationBodyModel? notificationBody =
          NotificationHelper.convertNotification(message.data);

      String? payload;
      if (notificationBody != null) {
        payload = jsonEncode(notificationBody.toJson());
      } else {
        payload = jsonEncode(message.data);
      }

      // Show notification for Android with enhanced styling
      final bool isOrderType =
          NotificationHelper._isOrderType(message.data['type']);
      final String channelId = isOrderType
          ? NotificationHelper._ordersChannelId
          : NotificationHelper._defaultChannelId;
      final String channelName =
          isOrderType ? 'Delivery Orders' : 'shellafood';
      final String channelDesc = isOrderType
          ? 'New and assigned order notifications'
          : 'Delivery notifications';

      if (Platform.isAndroid) {
        // Enhanced notification with rich styling and brand colors
        final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: '📦 Delivery Notification • Tap to open',
          htmlFormatSummaryText: true,
        );

        final AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max, // ⭐ KEY: Enables heads-up banners
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
          showWhen: true,
          sound: RawResourceAndroidNotificationSound('notification'),
          largeIcon: DrawableResourceAndroidBitmap('notification_icon'),
          styleInformation: bigTextStyle,
          autoCancel: true,
          ongoing: false,
          color: const Color(0xFF2A9849), // App primary green color
          colorized: true, // Enable colored notification bar
          icon: 'notification_icon', // Small icon in status bar
          ticker:
              'New delivery notification', // Text that shows briefly in status bar
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          enableLights: true, // Enable LED light for notification
          ledColor: const Color(0xFF2A9849), // LED color matches app primary
          ledOnMs: 1000, // LED on for 1 second
          ledOffMs: 500, // LED off for 0.5 seconds
        );

        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await localNotifications.show(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: title,
          body: body,
          notificationDetails: platformChannelSpecifics,
          payload: payload,
        );

        if (kDebugMode) {
          print("✅📱 Background notification DISPLAYED successfully!");
          print("✅📱 Title: $title");
          print("✅📱 Body: $body");
        }
      } else if (Platform.isIOS) {
        // Show notification for iOS
        const DarwinNotificationDetails iosPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification.wav',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(iOS: iosPlatformChannelSpecifics);

        await localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          notificationDetails: platformChannelSpecifics,
          payload: payload,
        );

        if (kDebugMode) {
          print("✅📱 iOS Background notification DISPLAYED successfully!");
        }
      }
    } else {
      if (kDebugMode) {
        print("❌📱 Background notification SKIPPED - title or body is null");
        print("❌📱 Title: $title, Body: $body");
      }
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print("❌📱 ERROR in background notification handler: $e");
      print("❌📱 Stack trace: $stackTrace");
    }
  }
}

