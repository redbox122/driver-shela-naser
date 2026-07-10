import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/features/call/data/models/call_model.dart';

/// مستودع نظام الاتصال — ملف جديد.
/// يستخدم ApiClient الحالي (نفس الـbaseURL والترويسات) لنقطتَي الاتصال.
/// ملاحظة: يجب توفير هاتين النقطتين في الباك-إند (توليد توكن Agora).
class CallRepository {
  final ApiClient apiClient;
  CallRepository({required this.apiClient});

  static const String tokenUri = '/api/v1/call/token';
  static const String notifyUri = '/api/v1/call/notify';

  /// POST /call/token → { token, channel, app_id?, uid? }
  Future<CallTokenModel?> requestToken({
    required int orderId,
    required int callerId,
    required int receiverId,
    String callerType = 'driver',
  }) async {
    final Response response = await apiClient.postData(
      tokenUri,
      {
        'order_id': orderId,
        'caller_type': callerType,
        'caller_id': callerId,
        'receiver_id': receiverId,
      },
      handleError: false,
    );
    if (response.statusCode == 200 && response.body != null) {
      return CallTokenModel.fromJson(Map<String, dynamic>.from(response.body));
    }
    return null;
  }

  /// POST /call/notify → يرسل إشعار للطرف الآخر ليظهر عنده مكالمة واردة
  Future<bool> notifyReceiver({
    required int orderId,
    required String channel,
    required int receiverId,
  }) async {
    final Response response = await apiClient.postData(
      notifyUri,
      {
        'order_id': orderId,
        'channel': channel,
        'receiver_id': receiverId,
      },
      handleError: false,
    );
    return response.statusCode == 200;
  }
}
