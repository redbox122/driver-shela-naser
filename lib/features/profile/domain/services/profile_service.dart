import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:shellafood_delivery/features/address/domain/models/record_location_body_model.dart';
import 'package:shellafood_delivery/features/profile/domain/models/profile_model.dart';
import 'package:shellafood_delivery/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;
import 'package:shellafood_delivery/features/profile/domain/services/profile_service_interface.dart';

class ProfileService implements ProfileServiceInterface {
  final ProfileRepositoryInterface profileRepositoryInterface;
  ProfileService({required this.profileRepositoryInterface});

  @override
  Future<ProfileModel?> getProfileInfo() async {
    return await profileRepositoryInterface.getProfileInfo();
  }

  @override
  Future<ResponseModel> updateProfile(
      ProfileModel userInfoModel, XFile? data, String token) async {
    return await profileRepositoryInterface.updateProfile(
        userInfoModel, data, token);
  }

  @override
  Future<ResponseModel> updateActiveStatus({int? active}) async {
    return await profileRepositoryInterface.updateActiveStatus(active: active);
  }

  @override
  Future<void> recordWebSocketLocation(
      RecordLocationBodyModel recordLocationBody) async {
    await profileRepositoryInterface
        .recordWebSocketLocation(recordLocationBody);
  }

  @override
  Future<Response> recordLocation(
      RecordLocationBodyModel recordLocationBody) async {
    return await profileRepositoryInterface.recordLocation(recordLocationBody);
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    return await profileRepositoryInterface.deleteDriver();
  }

  @override
  Future<String> addressPlaceMark(Position locationResult) async {
    String address;
    try {
      List<geo_coding.Placemark> addresses =
          await geo_coding.placemarkFromCoordinates(
              locationResult.latitude, locationResult.longitude);
      geo_coding.Placemark placeMark = addresses.first;
      address =
          '${placeMark.name}, ${placeMark.subAdministrativeArea}, ${placeMark.isoCountryCode}';
    } catch (e) {
      address = 'Unknown Location Found';
    }
    return address;
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      debugPrint('Requesting location permission...');

      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();

      // Check current permission status
      permission = await Geolocator.checkPermission();

      debugPrint('Permission status: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('Permission denied, showing dialog');
        Get.dialog(
            CustomAlertDialogWidget(
                description: 'you_denied'.tr,
                onOkPressed: () async {
                  Get.back();
                  // Try one more time
                  final retryPermission = await Geolocator.requestPermission();
                  if (retryPermission == LocationPermission.denied) {
                    debugPrint('Permission still denied after retry');
                    return;
                  }
                }),
            barrierDismissible: false);
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Permission denied forever, opening settings');
        Get.dialog(
            CustomAlertDialogWidget(
                description: 'you_denied_forever'.tr,
                onOkPressed: () async {
                  Get.back();
                  await Geolocator.openAppSettings();
                }),
            barrierDismissible: false);
        return false;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        debugPrint('Permission granted: $permission');
        return true;
      }

      debugPrint('Unexpected permission status: $permission');
      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  @override
  void checkPermission(Function callback) async {
    debugPrint('checkPermission called - using new linear flow');
    final hasPermission = await requestLocationPermission();
    if (hasPermission) {
      debugPrint('Permission granted, executing callback');
      callback();
    } else {
      debugPrint('Permission not granted, callback not executed');
    }
  }
}
