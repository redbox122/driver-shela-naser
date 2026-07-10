import 'package:shellafood_delivery/features/call/data/models/call_model.dart';
import 'package:shellafood_delivery/features/call/data/repositories/call_repository.dart';

/// حالة استخدام: بدء مكالمة صادرة — ملف جديد.
/// تطلب التوكن ثم تُشعر الطرف الآخر، وتعيد بيانات القناة/التوكن.
class InitiateCall {
  final CallRepository repository;
  InitiateCall(this.repository);

  Future<CallTokenModel?> call({
    required int orderId,
    required int callerId,
    required int receiverId,
    String callerType = 'driver',
  }) async {
    final CallTokenModel? tokenModel = await repository.requestToken(
      orderId: orderId,
      callerId: callerId,
      receiverId: receiverId,
      callerType: callerType,
    );
    if (tokenModel != null && tokenModel.isValid) {
      await repository.notifyReceiver(
        orderId: orderId,
        channel: tokenModel.channel,
        receiverId: receiverId,
      );
    }
    return tokenModel;
  }
}
