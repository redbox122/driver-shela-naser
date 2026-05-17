import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class AuthRepositoryInterface implements RepositoryInterface {
  Future<dynamic> login(String phone, String password);
  Future<dynamic> verifyLoginOtp(String phone, String otp);
  Future<dynamic> updateToken();
  Future<bool> saveUserToken(String token, String zoneTopic);
  String getUserToken();
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<void> saveUserNumberAndPassword(
      String number, String password, String countryCode);
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  bool isNotificationActive();
  void setNotificationActive(bool isActive);
  Future<bool> clearUserNumberAndPassword();
  Future<ResponseModel> registerDeliveryMan(
      DeliveryManBodyModel deliveryManBody, List<MultipartBody> multiParts);
}
