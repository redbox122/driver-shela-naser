import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/call/data/models/call_model.dart';
import 'package:shellafood_delivery/features/call/presentation/controllers/call_controller.dart';
import 'package:shellafood_delivery/features/call/presentation/screens/outgoing_call_screen.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// شاشة المكالمة الواردة — ملف جديد.
/// تظهر حين يتصل العميل: صورة/اسم + زر رد (أخضر) وزر رفض (أحمر).
class IncomingCallScreen extends StatelessWidget {
  final IncomingCallModel call;
  const IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.find<CallController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0E2A24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              _IncomingAvatar(image: call.callerImage),
              const SizedBox(height: 20),
              Text(
                (call.callerName ?? '').trim().isEmpty
                    ? 'call'.tr
                    : call.callerName!,
                style: robotoBold.copyWith(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('incoming_call'.tr,
                  style: robotoRegular.copyWith(
                      color: Colors.white70, fontSize: 16)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    label: 'reject'.tr,
                    onTap: () async {
                      await controller.endCurrentCall();
                      await controller.disposeEngine();
                      Get.back();
                    },
                  ),
                  _ActionButton(
                    icon: Icons.call,
                    color: AppColors.success,
                    label: 'accept'.tr,
                    onTap: () async {
                      final bool ok = await controller.answerIncoming(call);
                      if (ok) {
                        Get.off(() => OutgoingCallScreen(
                              name: call.callerName,
                              image: call.callerImage,
                            ));
                      } else {
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingAvatar extends StatelessWidget {
  final String? image;
  const _IncomingAvatar({this.image});
  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        (image ?? '').isNotEmpty && image!.startsWith('http');
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(72),
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: robotoRegular.copyWith(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
