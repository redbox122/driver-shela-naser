import 'package:shellafood_delivery/features/profile/domain/models/profile_model.dart';
import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class ForgotPasswordRepositoryInterface
    implements RepositoryInterface {
  Future<dynamic> changePassword(ProfileModel userInfoModel, String password);
  Future<dynamic> forgetPassword(String? phone);
  Future<dynamic> verifyToken(String? phone, String token);
  Future<dynamic> resetPassword(String? resetToken, String phone,
      String password, String confirmPassword);
}
