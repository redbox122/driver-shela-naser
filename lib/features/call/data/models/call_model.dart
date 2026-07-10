// نماذج نظام الاتصال الداخلي (Agora RTC) — ملف جديد.
// CallTokenModel: رد نقطة POST /call/token
// IncomingCallModel: بيانات المكالمة الواردة القادمة عبر FCM data payload

class CallTokenModel {
  final String token;
  final String channel;
  final String? appId;
  final int uid;

  CallTokenModel({
    required this.token,
    required this.channel,
    this.appId,
    this.uid = 0,
  });

  factory CallTokenModel.fromJson(Map<String, dynamic> json) {
    return CallTokenModel(
      token: json['token']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      appId: json['app_id']?.toString(),
      uid: json['uid'] is int
          ? json['uid'] as int
          : int.tryParse('${json['uid'] ?? 0}') ?? 0,
    );
  }

  // في وضع App ID only (بدون شهادة) يصل token فارغاً — يكفي وجود القناة.
  // عند تفعيل الشهادة لاحقاً سيصل token غير فارغ ويعمل نفس المنطق.
  bool get isValid => channel.isNotEmpty;
}

class IncomingCallModel {
  final int? orderId;
  final String channel;
  final String? token;
  final int uid;
  final String? callerName;
  final String? callerImage;
  final int? callerId;

  IncomingCallModel({
    this.orderId,
    required this.channel,
    this.token,
    this.uid = 0,
    this.callerName,
    this.callerImage,
    this.callerId,
  });

  /// يُبنى من حمولة FCM (كل القيم تصل كنصوص).
  /// القناة اشتقاقية: إن لم تصل صراحةً نبنيها من order_id → call_order_{id}.
  /// اسم/صورة المتصل قد يصلان عبر title/image (حسب مُرسِل الإشعار في الباك-إند).
  factory IncomingCallModel.fromData(Map<String, dynamic> data) {
    final int? orderId = int.tryParse('${data['order_id'] ?? ''}');
    String channel = data['channel']?.toString() ?? '';
    if (channel.isEmpty && orderId != null) {
      channel = 'call_order_$orderId';
    }
    return IncomingCallModel(
      orderId: orderId,
      channel: channel,
      token: data['token']?.toString(),
      uid: int.tryParse('${data['uid'] ?? 0}') ?? 0,
      callerName: data['caller_name']?.toString() ?? data['title']?.toString(),
      callerImage:
          data['caller_image']?.toString() ?? data['image']?.toString(),
      callerId: int.tryParse('${data['caller_id'] ?? ''}'),
    );
  }

  bool get isCallPayload => channel.isNotEmpty;
}
