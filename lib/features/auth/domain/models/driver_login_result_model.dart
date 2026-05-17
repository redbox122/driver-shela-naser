/// Result of delivery-man login step 1 (credentials) before OTP verification.
class DriverLoginResult {
  final bool isSuccess;
  final bool isOtpRequired;
  final String? message;
  final String? otpPhone;
  final bool otpSent;
  final int? retryAfterSeconds;

  const DriverLoginResult({
    required this.isSuccess,
    this.isOtpRequired = false,
    this.message,
    this.otpPhone,
    this.otpSent = true,
    this.retryAfterSeconds,
  });

  factory DriverLoginResult.completed() {
    return const DriverLoginResult(isSuccess: true);
  }

  factory DriverLoginResult.otpRequired({
    required String otpPhone,
    required bool otpSent,
    int? retryAfterSeconds,
  }) {
    return DriverLoginResult(
      isSuccess: false,
      isOtpRequired: true,
      otpPhone: otpPhone,
      otpSent: otpSent,
      retryAfterSeconds: retryAfterSeconds,
    );
  }

  factory DriverLoginResult.failure(String? message) {
    return DriverLoginResult(isSuccess: false, message: message);
  }
}
