import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shellafood_delivery/features/call/data/models/call_model.dart';
import 'package:shellafood_delivery/features/call/domain/usecases/end_call.dart';
import 'package:shellafood_delivery/features/call/domain/usecases/initiate_call.dart';

/// معرّف تطبيق Agora — كابتن شلة.
const String agoraAppId = 'd0b119f16af84daa93186f1b7fc7dd09';

enum CallStatus { idle, calling, ringing, connected, ended, failed }

/// متحكّم نظام الاتصال الداخلي — ملف جديد (لا يمسّ أي متحكّم موجود).
class CallController extends GetxController {
  final InitiateCall initiateCall;
  final EndCall endCall;
  CallController({required this.initiateCall, required this.endCall});

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  final Rx<CallStatus> status = CallStatus.idle.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOn = true.obs;
  final RxBool remoteJoined = false.obs;
  final RxInt seconds = 0.obs;

  Timer? _timer;
  String? channel;
  String? peerName;
  String? peerImage;

  String get durationText {
    final int m = seconds.value ~/ 60;
    final int s = seconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> _ensureMicPermission() async {
    final PermissionStatus st = await Permission.microphone.request();
    return st.isGranted;
  }

  Future<void> _initEngine(String appId) async {
    _engine ??= createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (status.value != CallStatus.connected) {
          status.value = CallStatus.calling;
        }
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteJoined.value = true;
        status.value = CallStatus.connected;
        _startTimer();
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        remoteJoined.value = false;
        endCurrentCall();
      },
      onError: (ErrorCodeType err, String msg) {
        debugPrint('[Agora] error: $err $msg');
      },
    ));
    await _engine!.enableAudio();
    await _engine!.setEnableSpeakerphone(speakerOn.value);
  }

  Future<void> _join({
    required String token,
    required String channelId,
    required int uid,
  }) async {
    await _engine!.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  /// مكالمة صادرة (الكابتن يتصل بالعميل)
  Future<bool> startOutgoingCall({
    required int orderId,
    required int callerId,
    required int receiverId,
    String? name,
    String? image,
  }) async {
    peerName = name;
    peerImage = image;
    if (!await _ensureMicPermission()) {
      status.value = CallStatus.failed;
      return false;
    }
    status.value = CallStatus.calling;
    final CallTokenModel? tokenModel = await initiateCall.call(
      orderId: orderId,
      callerId: callerId,
      receiverId: receiverId,
    );
    if (tokenModel == null || !tokenModel.isValid) {
      status.value = CallStatus.failed;
      return false;
    }
    channel = tokenModel.channel;
    await _initEngine(
        (tokenModel.appId?.isNotEmpty ?? false) ? tokenModel.appId! : agoraAppId);
    await _join(
      token: tokenModel.token,
      channelId: tokenModel.channel,
      uid: tokenModel.uid,
    );
    return true;
  }

  /// الرد على مكالمة واردة
  Future<bool> answerIncoming(IncomingCallModel data) async {
    peerName = data.callerName;
    peerImage = data.callerImage;
    if (!await _ensureMicPermission()) {
      status.value = CallStatus.failed;
      return false;
    }
    String token = data.token ?? '';
    int uid = data.uid;
    String appId = agoraAppId;
    // إن لم يصل التوكن ضمن الإشعار، نطلبه للقناة نفسها (في App-ID-only يرجع فارغاً وهذا مقبول)
    if (token.isEmpty && data.orderId != null) {
      final CallTokenModel? tm = await initiateCall.repository.requestToken(
        orderId: data.orderId!,
        callerId: data.callerId ?? 0,
        receiverId: data.callerId ?? 0,
        callerType: 'driver',
      );
      if (tm != null && tm.isValid) {
        token = tm.token;
        uid = tm.uid;
        if (tm.appId?.isNotEmpty ?? false) appId = tm.appId!;
      }
    }
    // يكفي وجود القناة؛ التوكن قد يكون فارغاً في وضع App ID only
    if (data.channel.isEmpty) {
      status.value = CallStatus.failed;
      return false;
    }
    channel = data.channel;
    await _initEngine(appId);
    await _join(token: token, channelId: data.channel, uid: uid);
    status.value = CallStatus.connected;
    _startTimer();
    return true;
  }

  void toggleMute() {
    muted.value = !muted.value;
    _engine?.muteLocalAudioStream(muted.value);
  }

  void toggleSpeaker() {
    speakerOn.value = !speakerOn.value;
    _engine?.setEnableSpeakerphone(speakerOn.value);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => seconds.value++);
  }

  Future<void> endCurrentCall() async {
    _timer?.cancel();
    if (status.value != CallStatus.ended) status.value = CallStatus.ended;
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    try {
      await endCall.call();
    } catch (_) {}
    remoteJoined.value = false;
  }

  /// تحرير المحرّك وإعادة ضبط الحالة (يُستدعى عند إغلاق شاشة المكالمة)
  Future<void> disposeEngine() async {
    _timer?.cancel();
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    try {
      await _engine?.release();
    } catch (_) {}
    _engine = null;
    status.value = CallStatus.idle;
    seconds.value = 0;
    muted.value = false;
    remoteJoined.value = false;
    channel = null;
  }

  @override
  void onClose() {
    disposeEngine();
    super.onClose();
  }
}
