class UpdateStatusBodyModel {
  String? token;
  int? orderId;
  String? status;
  String? otp;
  String? otpStore;
  String method = 'put';
  String? reason;

  UpdateStatusBodyModel(
      {this.token,
      this.orderId,
      this.status,
      this.otp,
      this.otpStore,
      this.reason});

  UpdateStatusBodyModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    method = json['_method'] ?? 'put';
    reason = json['reason'];
    otpStore = json['otp_store'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['token'] = token!;
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['_method'] = method;

    // Send only the appropriate OTP field based on status
    if (status == 'picked_up' && otpStore != null && otpStore!.isNotEmpty) {
      data['otp_store'] = otpStore!;
      print('🔧 PICKUP API: Sending otp_store = ${otpStore}');
    } else if (status == 'delivered' && otp != null && otp!.isNotEmpty) {
      data['otp'] = otp!;
      print('🔧 DELIVERY API: Sending otp = ${otp}');
    }

    if (reason != '' && reason != null) {
      data['reason'] = reason!;
    }

    print('🔧 API Request Body: $data');
    return data;
  }
}
