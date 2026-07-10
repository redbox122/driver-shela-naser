import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/call/presentation/controllers/call_controller.dart';
import 'package:shellafood_delivery/features/call/presentation/screens/outgoing_call_screen.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/util/app_colors.dart';
import 'package:shellafood_delivery/util/styles.dart';

/// زر المكالمة الداخلية (Agora) — ودجت جديد يُضاف بجانب بيانات العميل.
/// لا يعرض الرقم الحقيقي؛ يبدأ مكالمة صوتية عبر قناة الطلب.
class CallButton extends StatefulWidget {
  final int? orderId;
  final int? customerId;
  final String? customerName;
  final String? customerImage;
  final double size;

  /// إن وُجد نصّ → يُعرض زرّاً بتدرّج ونصّ (pill)، وإلا زرّاً دائرياً بأيقونة فقط.
  final String? label;

  const CallButton({
    super.key,
    required this.orderId,
    required this.customerId,
    this.customerName,
    this.customerImage,
    this.size = 44,
    this.label,
  });

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  bool _busy = false;

  Future<void> _startCall() async {
    if (_busy) return;
    if (widget.orderId == null ||
        widget.customerId == null ||
        widget.customerId == 0) {
      showCustomSnackBar('call_not_available'.tr, isError: true);
      return;
    }
    final int driverId =
        Get.find<ProfileController>().profileModel?.id ?? 0;
    if (driverId == 0) {
      showCustomSnackBar('call_not_available'.tr, isError: true);
      return;
    }

    setState(() => _busy = true);
    final CallController controller = Get.find<CallController>();
    Get.to(() => OutgoingCallScreen(
          name: widget.customerName,
          image: widget.customerImage,
        ));
    final bool ok = await controller.startOutgoingCall(
      orderId: widget.orderId!,
      callerId: driverId,
      receiverId: widget.customerId!,
      name: widget.customerName,
      image: widget.customerImage,
    );
    if (mounted) setState(() => _busy = false);
    if (!ok) {
      showCustomSnackBar('call_failed'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color green = AppColors.success;
    final Color greenDark = Color.lerp(green, Colors.black, 0.22) ?? green;
    final Gradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [green, greenDark],
    );
    final List<BoxShadow> shadow = [
      BoxShadow(
        color: green.withValues(alpha: 0.35),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];

    // نسخة الزرّ بالنصّ (pill) — تصميم احترافي بتدرّج وظلّ
    if (widget.label != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _startCall,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.phone_in_talk_rounded,
                        color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: robotoBold.copyWith(
                      color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // النسخة الدائرية — أيقونة فقط بتصميم احترافي
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.size),
        onTap: _startCall,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: shadow,
          ),
          child: _busy
              ? Padding(
                  padding: EdgeInsets.all(widget.size * 0.30),
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(Icons.phone_in_talk_rounded,
                  color: Colors.white, size: widget.size * 0.48),
        ),
      ),
    );
  }
}
