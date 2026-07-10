import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/call/data/models/call_model.dart';
import 'package:shellafood_delivery/features/call/presentation/screens/incoming_call_screen.dart';

/// مستقبِل إشعارات المكالمات الواردة (Agora) — ملف جديد.
/// يوجّه حمولة FCM من نوع «مكالمة» إلى شاشة المكالمة الواردة.
/// لا يمسّ معالِج الإشعارات/الخلفية الموجود (onBackgroundMessage يبقى كما هو).
class CallNotificationHandler {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    // مكالمة تصل والتطبيق في المقدمة
    FirebaseMessaging.onMessage.listen(_route);
    // المستخدم فتح التطبيق بالضغط على إشعار المكالمة (التطبيق كان في الخلفية)
    FirebaseMessaging.onMessageOpenedApp.listen(_route);
  }

  /// حمولة مكالمة؟ (type=incoming_call/call أو channel يبدأ بـ call_order_)
  static bool isCallPayload(Map<String, dynamic> data) {
    final String type =
        data['type']?.toString() ?? data['call_type']?.toString() ?? '';
    final String channel = data['channel']?.toString() ?? '';
    return type == 'incoming_call' ||
        type == 'call' ||
        channel.startsWith('call_order_');
  }

  static void _route(RemoteMessage message) {
    try {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(message.data);
      if (!isCallPayload(data)) return;
      final IncomingCallModel call = IncomingCallModel.fromData(data);
      if (!call.isCallPayload) return;
      Get.to(() => IncomingCallScreen(call: call));
    } catch (_) {}
  }
}
