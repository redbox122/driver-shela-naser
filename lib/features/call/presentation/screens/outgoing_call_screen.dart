import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/call/presentation/controllers/call_controller.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// شاشة المكالمة الصادرة/الجارية — ملف جديد.
/// تعرض صورة العميل واسمه، حالة الاتصال/المؤقّت، وأزرار الكتم والإنهاء.
class OutgoingCallScreen extends StatelessWidget {
  final String? name;
  final String? image;
  const OutgoingCallScreen({super.key, this.name, this.image});

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.find<CallController>();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        await controller.disposeEngine();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E2A24),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                _Avatar(image: image ?? controller.peerImage),
                const SizedBox(height: 20),
                Text(
                  (name ?? controller.peerName ?? '').trim().isEmpty
                      ? 'call'.tr
                      : (name ?? controller.peerName)!,
                  style: robotoBold.copyWith(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  String label;
                  switch (controller.status.value) {
                    case CallStatus.connected:
                      label = controller.durationText;
                      break;
                    case CallStatus.failed:
                      label = 'call_failed'.tr;
                      break;
                    case CallStatus.ended:
                      label = 'call_ended'.tr;
                      break;
                    default:
                      label = 'calling'.tr;
                  }
                  return Text(
                    label,
                    style: robotoRegular.copyWith(
                        color: Colors.white70, fontSize: 16),
                  );
                }),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => _RoundButton(
                          icon: controller.muted.value
                              ? Icons.mic_off
                              : Icons.mic,
                          background: controller.muted.value
                              ? Colors.white24
                              : Colors.white12,
                          onTap: controller.toggleMute,
                          label: 'mute'.tr,
                        )),
                    _RoundButton(
                      icon: Icons.call_end,
                      background: AppColors.error,
                      size: 68,
                      onTap: () async {
                        await controller.endCurrentCall();
                        await controller.disposeEngine();
                        if (Get.isOverlaysOpen) Get.back();
                        Get.back();
                      },
                      label: 'end_call'.tr,
                    ),
                    Obx(() => _RoundButton(
                          icon: controller.speakerOn.value
                              ? Icons.volume_up
                              : Icons.volume_off,
                          background: Colors.white12,
                          onTap: controller.toggleSpeaker,
                          label: 'speaker'.tr,
                        )),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? image;
  const _Avatar({this.image});
  @override
  Widget build(BuildContext context) {
    final bool hasImage = (image ?? '').isNotEmpty &&
        (image!.startsWith('http'));
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white10,
        image: hasImage
            ? DecorationImage(image: NetworkImage(image!), fit: BoxFit.cover)
            : null,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: hasImage
          ? null
          : const Icon(Icons.person, color: Colors.white54, size: 70),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final VoidCallback onTap;
  final String label;
  final double size;
  const _RoundButton({
    required this.icon,
    required this.background,
    required this.onTap,
    required this.label,
    this.size = 56,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: background),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: robotoRegular.copyWith(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
