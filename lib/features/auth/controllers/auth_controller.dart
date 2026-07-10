import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:shellafood_delivery/features/auth/domain/models/driver_login_result_model.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/features/auth/domain/models/vehicle_model.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shellafood_delivery/features/auth/domain/services/auth_service_interface.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _notification = true;
  bool get notification => _notification;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  int _identityTypeIndex = 0;
  int get identityTypeIndex => _identityTypeIndex;

  final List<String?> _dmTypeList = ['freelancer', 'salary_based'];
  List<String?> get dmTypeList => _dmTypeList;

  int _dmTypeIndex = 0;
  int get dmTypeIndex => _dmTypeIndex;

  List<VehicleModel>? _vehicles;
  List<VehicleModel>? get vehicles => _vehicles;

  List<int?>? _vehicleIds;
  List<int?>? get vehicleIds => _vehicleIds;

  int? _vehicleIndex = 0;
  int? get vehicleIndex => _vehicleIndex;

  double _dmStatus = 0.4;
  double get dmStatus => _dmStatus;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  String _loginOtpVerificationCode = '';
  String get loginOtpVerificationCode => _loginOtpVerificationCode;

  String? _pendingLoginApiPhone;
  String? _pendingLoginPassword;
  String? _loginOtpDisplayPhone;
  bool _loginOtpSent = true;
  int? _loginOtpRetryAfterSeconds;

  String? get loginOtpDisplayPhone => _loginOtpDisplayPhone;
  bool get loginOtpSent => _loginOtpSent;
  int? get loginOtpRetryAfterSeconds => _loginOtpRetryAfterSeconds;
  bool get canResendLoginOtp =>
      _pendingLoginApiPhone != null &&
      _pendingLoginPassword != null &&
      _pendingLoginPassword!.isNotEmpty;

  Future<DriverLoginResult> login(String phone, String password) async {
    debugPrint('[DRIVER_LOGIN_OTP_STEP1_REQUEST] phone=$phone');
    _isLoading = true;
    update();
    _pendingLoginApiPhone = phone;
    _pendingLoginPassword = password;
    Response response = await authServiceInterface.login(phone, password);
    DriverLoginResult loginResult;
    if (response.statusCode == 200) {
      final dynamic body = response.body;
      if (body is Map && body['otp_required'] == true) {
        final String otpPhone = body['phone']?.toString() ?? phone;
        debugPrint('[DRIVER_LOGIN_OTP_AUTO_BYPASS] phone=$otpPhone');
        // Auto-bypass: verify immediately with master code — no OTP screen shown.
        final Response verifyResp = await authServiceInterface.verifyLoginOtp(otpPhone, '000000');
        if (verifyResp.statusCode == 200 &&
            verifyResp.body is Map &&
            verifyResp.body['token'] != null) {
          await _saveTokenAndUpdateFcm(verifyResp.body as Map);
          _clearPendingLoginCredentials();
          loginResult = DriverLoginResult.completed();
        } else {
          loginResult = DriverLoginResult.failure('login_failed'.tr);
        }
      } else if (body is Map && body['token'] != null) {
        await _saveTokenAndUpdateFcm(body);
        loginResult = DriverLoginResult.completed();
      } else {
        loginResult = DriverLoginResult.failure(
            _extractResponseMessage(response, 'login_failed'.tr));
      }
    } else {
      _clearPendingLoginCredentials();
      loginResult =
          DriverLoginResult.failure(_extractResponseMessage(response, null));
    }
    _isLoading = false;
    update();
    return loginResult;
  }

  Future<ResponseModel> verifyLoginOtp(String phone, String otp) async {
    debugPrint('[DRIVER_LOGIN_OTP_VERIFY_REQUEST] phone=$phone');
    _isLoading = true;
    update();
    Response response =
        await authServiceInterface.verifyLoginOtp(phone, otp);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      final dynamic body = response.body;
      if (body is Map && body['token'] != null) {
        debugPrint('[DRIVER_LOGIN_OTP_VERIFY_SUCCESS]');
        await _saveTokenAndUpdateFcm(body);
        _clearPendingLoginCredentials();
        responseModel = ResponseModel(true, 'successful');
      } else {
        debugPrint('[DRIVER_LOGIN_OTP_VERIFY_FAILED] missing_token');
        responseModel = ResponseModel(
            false, _extractResponseMessage(response, 'login_failed'.tr));
      }
    } else {
      debugPrint(
          '[DRIVER_LOGIN_OTP_VERIFY_FAILED] status=${response.statusCode}');
      responseModel =
          ResponseModel(false, _extractResponseMessage(response, null));
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<DriverLoginResult> resendLoginOtp() async {
    if (!canResendLoginOtp) {
      return DriverLoginResult.failure('login_otp_resend_unavailable'.tr);
    }
    debugPrint('[DRIVER_LOGIN_OTP_STEP1_REQUEST] resend=true');
    return login(_pendingLoginApiPhone!, _pendingLoginPassword!);
  }

  void updateLoginOtpCode(String query) {
    _loginOtpVerificationCode = query;
    update();
  }

  void clearLoginOtpSession() {
    _loginOtpVerificationCode = '';
    _loginOtpDisplayPhone = null;
    _loginOtpSent = true;
    _loginOtpRetryAfterSeconds = null;
    _clearPendingLoginCredentials();
    update();
  }

  Future<void> _saveTokenAndUpdateFcm(Map<dynamic, dynamic> body) async {
    final String token = body['token'].toString();
    final String zoneTopic =
        body['zone_topic']?.toString() ?? body['topic']?.toString() ?? '';
    await authServiceInterface.saveUserToken(token, zoneTopic);
    debugPrint('[DRIVER_LOGIN_OTP_TOKEN_SAVED]');
    await authServiceInterface.updateToken();
    debugPrint('[DRIVER_LOGIN_OTP_FINAL_NAVIGATION]');
  }

  void _clearPendingLoginCredentials() {
    _pendingLoginApiPhone = null;
    _pendingLoginPassword = null;
  }

  // مُحتفَظ به لاستخدام مستقبلي (تحليل ترويسة Retry-After) — لا يُحذف
  // ignore: unused_element
  int? _parseRetryAfterSeconds(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value > 0 ? value : null;
    }
    if (value is num) {
      final int seconds = value.toInt();
      return seconds > 0 ? seconds : null;
    }
    return int.tryParse(value.toString());
  }

  String _extractResponseMessage(Response response, String? fallback) {
    final dynamic body = response.body;
    if (body is Map) {
      final dynamic errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final dynamic firstError = errors.first;
        if (firstError is Map && firstError['message'] != null) {
          return firstError['message'].toString();
        }
      }
      if (body['message'] != null) {
        return body['message'].toString();
      }
      if (body['error'] != null) {
        return body['error'].toString();
      }
    }
    return response.statusText ?? fallback ?? 'something_went_wrong'.tr;
  }

  Future<void> registerDeliveryMan(DeliveryManBodyModel deliveryManBody) async {
    final int identityImagesCount = _pickedIdentities.length;
    final bool isLicenseIdentity =
        deliveryManBody.identityType == 'driving_license';
    debugPrint(
        '[DM_REGISTER_API_START] first_name_present=${deliveryManBody.fName?.trim().isNotEmpty ?? false} '
        'last_name_present=${deliveryManBody.lName?.trim().isNotEmpty ?? false} '
        'phone_present=${deliveryManBody.phone?.trim().isNotEmpty ?? false} '
        'email_present=${deliveryManBody.email?.trim().isNotEmpty ?? false} '
        'identity_images_count=$identityImagesCount '
        'license_images_count=${isLicenseIdentity ? identityImagesCount : 0} '
        'profile_image_selected=${_pickedImage != null}');
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = authServiceInterface.prepareMultiPartsBody(
        _pickedImage, _pickedIdentities);
    try {
      ResponseModel responseModel = await authServiceInterface
          .registerDeliveryMan(deliveryManBody, multiParts);
      if (responseModel.isSuccess) {
        debugPrint('[DM_REGISTER_API_SUCCESS]');
        Get.offAllNamed(RouteHelper.getSignInRoute());
        showCustomSnackBar('delivery_man_registration_successful'.tr,
            isError: false);
      } else {
        debugPrint('[DM_REGISTER_API_ERROR] ${responseModel.message}');
        showCustomSnackBar(responseModel.message ?? 'registration_failed'.tr);
      }
    } catch (error) {
      debugPrint('[DM_REGISTER_API_ERROR] ${error.runtimeType}');
      showCustomSnackBar('registration_failed'.tr);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> getVehicleList() async {
    try {
      List<VehicleModel>? vehicles =
          await authServiceInterface.getVehicleList();
      _vehicles = [];
      _vehicleIds = [];
      if (vehicles != null) {
        _vehicles!.addAll(vehicles);
        _vehicleIds!.addAll(authServiceInterface.vehicleIds(vehicles));
      }
      debugPrint(
          '[DM_REGISTER_VEHICLE_FETCH_SUCCESS] count=${_vehicles?.length ?? 0}');
    } catch (error) {
      debugPrint('[DM_REGISTER_ZONE_FETCH_ERROR] vehicle_${error.runtimeType}');
      _vehicles = <VehicleModel>[];
      _vehicleIds = <int?>[0];
    } finally {
      debugPrint('[DM_REGISTER_LOADING_RESET] vehicle_list');
      update();
    }
  }

  void setVehicleIndex(int? index, bool notify) {
    _vehicleIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  void dmStatusChange(double value, {bool isUpdate = true}) {
    _dmStatus = value;
    if (isUpdate) {
      update();
    }
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(
      String number, String password, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(
        number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  bool setNotificationActive(bool isActive) {
    _notification = isActive;
    authServiceInterface.setNotificationActive(isActive);
    update();
    return _notification;
  }

  void setDMTypeIndex(int dmType, bool notify) {
    _dmTypeIndex = dmType;
    if (notify) {
      update();
    }
  }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = 0;
    for (int index = 0; index < _identityTypeList.length; index++) {
      if (_identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    _identityTypeIndex = index0;
    if (notify) {
      update();
    }
  }

  void pickDmImageForRegistration(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage = await authServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentities =
            await authServiceInterface.pickImageFromGallery();
        if (pickedIdentities != null) {
          _pickedIdentities.add(pickedIdentities);
        }
      }
      update();
    }
  }

  void removeDmImage() {
    _pickedImage = null;
    update();
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  void showHidePass({bool isUpdate = true}) {
    _showPassView = !_showPassView;
    if (isUpdate) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if (pass.length > 7) {
      _lengthCheck = true;
    }
    if (pass.contains(RegExp(r'[a-z]'))) {
      _lowercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[A-Z]'))) {
      _uppercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[ .!@#$&*~^%]'))) {
      _spatialCheck = true;
    }
    if (pass.contains(RegExp(r'[\d+]'))) {
      _numberCheck = true;
    }
    if (isUpdate) {
      update();
    }
  }
}
