import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

const int _driverLoginOtpLength = 6;

class DriverLoginOtpScreen extends StatefulWidget {
  const DriverLoginOtpScreen({super.key});

  @override
  State<DriverLoginOtpScreen> createState() => _DriverLoginOtpScreenState();
}

class _DriverLoginOtpScreenState extends State<DriverLoginOtpScreen> {
  String? _phone;
  bool _otpSent = true;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? arguments =
        Get.arguments is Map<String, dynamic>
            ? Get.arguments as Map<String, dynamic>
            : null;
    final AuthController authController = Get.find<AuthController>();
    _phone = arguments?['phone']?.toString() ??
        authController.loginOtpDisplayPhone;
    _otpSent = arguments?['otp_sent'] as bool? ?? authController.loginOtpSent;
    final int? retryAfterSeconds = arguments?['retry_after_seconds'] as int? ??
        authController.loginOtpRetryAfterSeconds;
    if (_phone != null && !_phone!.startsWith('+')) {
      _phone = '+$_phone';
    }
    debugPrint(
        '[DRIVER_LOGIN_OTP_NAVIGATE] phone=$_phone otp_sent=$_otpSent retry_after_seconds=$retryAfterSeconds');
    if (!_otpSent && retryAfterSeconds != null && retryAfterSeconds > 0) {
      _startCooldownTimer(retryAfterSeconds);
    } else if (_otpSent) {
      _startCooldownTimer(60);
    }
  }

  void _startCooldownTimer(int seconds) {
    _cooldownTimer?.cancel();
    if (seconds <= 0) {
      setState(() {
        _cooldownSeconds = 0;
      });
      return;
    }
    _cooldownSeconds = seconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      } else {
        setState(() {
          _cooldownSeconds = _cooldownSeconds - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'otp_verification'.tr),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Center(
              child: SizedBox(
                width: 1170,
                child: GetBuilder<AuthController>(builder: (authController) {
                  return Column(
                    children: [
                      if (Get.find<SplashController>().configModel!.demo!)
                        Text('for_demo_purpose'.tr, style: robotoRegular)
                      else if (_otpSent)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'enter_the_verification_sent_to'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              TextSpan(
                                text: ' $_phone',
                                style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          _cooldownSeconds > 0
                              ? '${'login_otp_cooldown'.tr} ($_cooldownSeconds)'
                              : 'login_otp_not_sent'.tr,
                          style: robotoRegular,
                          textAlign: TextAlign.center,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth =
                                constraints.maxWidth.isFinite
                                    ? constraints.maxWidth
                                    : MediaQuery.of(context).size.width;
                            final double fieldWidth =
                                ((availableWidth - 48) / _driverLoginOtpLength)
                                    .clamp(34.0, 45.0);
                            return Directionality(
                              textDirection: TextDirection.ltr,
                              child: PinCodeTextField(
                                length: _driverLoginOtpLength,
                                appContext: context,
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.slide,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  fieldHeight: 60,
                                  fieldWidth: fieldWidth,
                                  borderWidth: 1,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  selectedColor: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.2),
                                  selectedFillColor: Colors.white,
                                  inactiveFillColor: Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2),
                                  inactiveColor: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.2),
                                  activeColor: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.4),
                                  activeFillColor: Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2),
                                ),
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                backgroundColor: Colors.transparent,
                                enableActiveFill: true,
                                onChanged: authController.updateLoginOtpCode,
                                beforeTextPaste: (text) => true,
                              ),
                            );
                          },
                        ),
                      ),
                      if (authController.canResendLoginOtp)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'did_not_receive_the_code'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            TextButton(
                              onPressed: _cooldownSeconds < 1 &&
                                      !authController.isLoading
                                  ? () => _resendOtp(authController)
                                  : null,
                              child: Text(
                                '${'resend'.tr}${_cooldownSeconds > 0 ? ' ($_cooldownSeconds)' : ''}',
                              ),
                            ),
                          ],
                        ),
                      !authController.isLoading
                          ? CustomButtonWidget(
                              buttonText: 'verify'.tr,
                              onPressed: () => _verifyOtp(authController),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp(AuthController authController) async {
    final String otp = authController.loginOtpVerificationCode.trim();
    if (_phone == null || _phone!.isEmpty) {
      showCustomSnackBar('invalid_phone_number'.tr);
      return;
    }
    if (otp.length < _driverLoginOtpLength) {
      showCustomSnackBar('login_otp_enter_6_digits'.tr);
      return;
    }
    final ResponseModel result =
        await authController.verifyLoginOtp(_phone!, otp);
    if (result.isSuccess) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      showCustomSnackBar(result.message);
    }
  }

  Future<void> _resendOtp(AuthController authController) async {
    final result = await authController.resendLoginOtp();
    if (result.isOtpRequired) {
      setState(() {
        _phone = result.otpPhone ?? _phone;
        _otpSent = result.otpSent;
      });
      if (result.otpSent) {
        showCustomSnackBar('resend_code_successful'.tr, isError: false);
        _startCooldownTimer(60);
      } else {
        final int cooldown = result.retryAfterSeconds ?? 0;
        if (cooldown > 0) {
          _startCooldownTimer(cooldown);
        }
        showCustomSnackBar(
          cooldown > 0
              ? '${'login_otp_cooldown'.tr} ($cooldown)'
              : 'login_otp_not_sent'.tr,
        );
      }
    } else if (result.isSuccess) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      showCustomSnackBar(result.message);
    }
  }
}
