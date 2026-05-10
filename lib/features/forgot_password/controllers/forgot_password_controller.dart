import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shellafood_delivery/features/profile/domain/models/profile_model.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/forgot_password/domain/services/forgot_password_service_interface.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  final ForgotPasswordServiceInterface forgotPasswordServiceInterface;
  ForgotPasswordController({required this.forgotPasswordServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  Future<bool> changePassword(
      ProfileModel updatedUserModel, String password) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface
        .changePassword(updatedUserModel, password);
    _isLoading = false;
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  Future<ResponseModel> forgetPassword(String? email) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await forgotPasswordServiceInterface.forgetPassword(email);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyToken(String? number) async {
    debugPrint('[DM_FORGOT_OTP_API_START] length=${_verificationCode.length}');
    _isLoading = true;
    update();
    try {
      ResponseModel responseModel = await forgotPasswordServiceInterface
          .verifyToken(number, _verificationCode);
      if (responseModel.isSuccess) {
        debugPrint('[DM_FORGOT_OTP_API_SUCCESS]');
      } else {
        debugPrint('[DM_FORGOT_OTP_API_ERROR] ${responseModel.message}');
      }
      return responseModel;
    } catch (error) {
      debugPrint('[DM_FORGOT_OTP_API_ERROR] ${error.runtimeType}');
      return ResponseModel(false, 'verification_failed'.tr);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<ResponseModel> resetPassword(String? resetToken, String phone,
      String password, String confirmPassword) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface
        .resetPassword(resetToken, phone, password, confirmPassword);
    _isLoading = false;
    update();
    return responseModel;
  }

  void updateVerificationCode(String query) {
    _verificationCode = query;
    debugPrint('[DM_FORGOT_OTP_CHANGED] length=${query.length}');
    update();
  }
}
