import 'dart:async';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/address/domain/models/record_location_body_model.dart';
import 'package:shellafood_delivery/features/profile/domain/models/profile_model.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shellafood_delivery/features/profile/domain/services/profile_service_interface.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  RecordLocationBodyModel? _recordLocation;
  RecordLocationBodyModel? get recordLocationBody => _recordLocation;

  Timer? _timer;

  // Permission state tracking to prevent repeated dialogs
  bool _hasShownLocationDialog = false;
  bool _isCheckingLocationPermission = false;
  LocationPermission? _lastKnownPermission;

  Future<void> getProfile() async {
    try {
      ProfileModel? profileModel =
          await profileServiceInterface.getProfileInfo();
      if (profileModel != null) {
        _profileModel = profileModel;
        if (_profileModel!.active == 1) {
          await _handleLocationPermissionCheck();
        } else {
          stopLocationRecord();
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    update();
  }

  Future<bool> updateUserInfo(
      ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.updateProfile(
        updateUserModel, _pickedFile, token);
    _isLoading = false;
    if (responseModel.isSuccess) {
      _profileModel = updateUserModel;
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  void initData() {
    _pickedFile = null;
  }

  Future<bool> updateActiveStatus() async {
    ResponseModel responseModel =
        await profileServiceInterface.updateActiveStatus();
    if (responseModel.isSuccess) {
      _profileModel!.active = _profileModel!.active == 0 ? 1 : 0;
      showCustomSnackBar(responseModel.message, isError: false);
      if (_profileModel!.active == 1) {
        await _handleLocationPermissionCheck();
      } else {
        stopLocationRecord();
      }
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  Future deleteDriver() async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.deleteDriver();
    _isLoading = false;
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      Get.find<AuthController>().clearSharedData();
      stopLocationRecord();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    } else {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
  }

  void startLocationRecord() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      recordLocation();
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  /// Handles location permission checking with state tracking to prevent repeated dialogs
  Future<void> _handleLocationPermissionCheck() async {
    // Prevent multiple simultaneous permission checks
    if (_isCheckingLocationPermission) {
      debugPrint('Location permission check already in progress, skipping');
      return;
    }

    _isCheckingLocationPermission = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      _lastKnownPermission = permission;

      debugPrint('Current location permission: $permission');
      debugPrint('Has shown dialog before: $_hasShownLocationDialog');

      // Check if we need to show the dialog
      bool shouldShowDialog = _shouldShowLocationDialog(permission);

      if (shouldShowDialog) {
        debugPrint('Showing location permission dialog');
        _hasShownLocationDialog = true;
        await _showLocationPermissionDialog();
      } else {
        debugPrint(
            'Permission granted or dialog already shown, starting location recording');
        startLocationRecord();
      }
    } catch (e) {
      debugPrint('Error in location permission check: $e');
    } finally {
      _isCheckingLocationPermission = false;
    }
  }

  /// Determines if the location permission dialog should be shown
  bool _shouldShowLocationDialog(LocationPermission permission) {
    // Don't show if already shown
    if (_hasShownLocationDialog) {
      debugPrint('Dialog already shown, skipping');
      return false;
    }

    // Check if permission status has changed since last check
    if (_lastKnownPermission != null && _lastKnownPermission == permission) {
      debugPrint('Permission status unchanged, skipping dialog');
      return false;
    }

    // Show if permission is denied or denied forever
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Permission denied, showing dialog');
      return true;
    }

    // For Android, show if permission is not granted
    if (GetPlatform.isAndroid &&
        permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      debugPrint('Android permission not granted, showing dialog');
      return true;
    }

    debugPrint('Permission granted, no dialog needed');
    return false;
  }

  /// Shows the location permission dialog
  Future<void> _showLocationPermissionDialog() async {
    Get.dialog(
        ConfirmationDialogWidget(
          icon: Images.locationPermission,
          iconSize: 200,
          hasCancel: false,
          description: 'this_app_collects_location_data'.tr,
          onYesPressed: () async {
            Get.back();
            debugPrint('Location permission dialog confirmed');

            // Add safety timer to reset loading state
            Timer(const Duration(seconds: 10), () {
              try {
                final orderController = Get.find<OrderController>();
                if (orderController.isLoading) {
                  debugPrint('Safety: Resetting OrderController loading state');
                  orderController.initLoading();
                }
              } catch (e) {
                debugPrint('Error in safety timer: $e');
              }
            });

            profileServiceInterface
                .checkPermission(() => startLocationRecord());
          },
        ),
        barrierDismissible: false);
  }

  /// Resets the permission dialog state (useful for testing or when user changes settings)
  void resetLocationPermissionState() {
    _hasShownLocationDialog = false;
    _isCheckingLocationPermission = false;
    _lastKnownPermission = null;
    debugPrint('Location permission state reset');
  }

  /// Gets the current permission state for debugging
  Map<String, dynamic> getLocationPermissionState() {
    return {
      'hasShownDialog': _hasShownLocationDialog,
      'isChecking': _isCheckingLocationPermission,
      'lastKnownPermission': _lastKnownPermission?.toString(),
    };
  }

  Future<void> recordLocation() async {
    try {
      debugPrint('Starting location recording...');

      // Add timeout for location request
      final Position locationResult = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Location request timed out');
          throw TimeoutException(
              'Location request timed out', const Duration(seconds: 15));
        },
      );

      debugPrint(
          'Location obtained: ${locationResult.latitude}, ${locationResult.longitude}');

      String address =
          await profileServiceInterface.addressPlaceMark(locationResult);
      debugPrint('Address resolved: $address');

      _recordLocation = RecordLocationBodyModel(
        location: address,
        latitude: locationResult.latitude,
        longitude: locationResult.longitude,
      );

      if (Get.find<SplashController>().configModel!.webSocketStatus!) {
        debugPrint('Recording location via WebSocket');
        await profileServiceInterface.recordWebSocketLocation(_recordLocation!);
      } else {
        debugPrint('Recording location via HTTP');
        await profileServiceInterface.recordLocation(_recordLocation!);
      }

      debugPrint('Location recorded successfully');
    } catch (e) {
      debugPrint('Error recording location: $e');

      // Use fallback location if GPS fails
      _recordLocation = RecordLocationBodyModel(
        location: 'Location unavailable',
        latitude: 24.700531572620886,
        longitude: 46.7287762170735,
      );

      try {
        if (Get.find<SplashController>().configModel!.webSocketStatus!) {
          await profileServiceInterface
              .recordWebSocketLocation(_recordLocation!);
        } else {
          await profileServiceInterface.recordLocation(_recordLocation!);
        }
        debugPrint('Fallback location recorded');
      } catch (fallbackError) {
        debugPrint('Error recording fallback location: $fallbackError');
      }
    }
  }
}
