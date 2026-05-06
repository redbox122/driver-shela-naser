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
  bool _hasRecordedFallbackLocation = false;

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
      assert(() {
        debugPrint('Error fetching profile: $e');
        return true;
      }());
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

  @override
  void onClose() {
    _timer?.cancel(); // ML-03: cancel location timer to prevent memory leak
    super.onClose();
  }

  /// Handles location permission checking with state tracking to prevent repeated dialogs
  Future<void> _handleLocationPermissionCheck() async {
    // Prevent multiple simultaneous permission checks
    if (_isCheckingLocationPermission) {
      assert(() {
        debugPrint('Location permission check already in progress, skipping');
        return true;
      }());
      return;
    }

    _isCheckingLocationPermission = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      _lastKnownPermission = permission;

      assert(() {
        debugPrint('Current location permission: $permission');
        debugPrint('Has shown dialog before: $_hasShownLocationDialog');
        return true;
      }());

      // Check if we need to show the dialog
      bool shouldShowDialog = _shouldShowLocationDialog(permission);

      final bool isGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (shouldShowDialog) {
        assert(() {
          debugPrint('Showing location permission dialog');
          return true;
        }());
        _hasShownLocationDialog = true;
        await _showLocationPermissionDialog();
        await _recordFallbackLocationIfNeeded(permission);
      } else if (isGranted) {
        assert(() {
          debugPrint('Permission granted, starting location recording');
          return true;
        }());
        startLocationRecord();
      } else {
        assert(() {
          debugPrint('Permission not granted, stopping location recording');
          return true;
        }());
        stopLocationRecord();
        await _recordFallbackLocationIfNeeded(permission);
      }
    } catch (e) {
      assert(() {
        debugPrint('Error in location permission check: $e');
        return true;
      }());
    } finally {
      _isCheckingLocationPermission = false;
    }
  }

  /// Determines if the location permission dialog should be shown
  bool _shouldShowLocationDialog(LocationPermission permission) {
    // Don't show if already shown
    if (_hasShownLocationDialog) {
      assert(() {
        debugPrint('Dialog already shown, skipping');
        return true;
      }());
      return false;
    }

    // Check if permission status has changed since last check
    if (_lastKnownPermission != null && _lastKnownPermission == permission) {
      assert(() {
        debugPrint('Permission status unchanged, skipping dialog');
        return true;
      }());
      return false;
    }

    // Show if permission is denied or denied forever
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      assert(() {
        debugPrint('Permission denied, showing dialog');
        return true;
      }());
      return true;
    }

    // For Android, show if permission is not granted
    if (GetPlatform.isAndroid &&
        permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      assert(() {
        debugPrint('Android permission not granted, showing dialog');
        return true;
      }());
      return true;
    }

    assert(() {
      debugPrint('Permission granted, no dialog needed');
      return true;
    }());
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
            assert(() {
              debugPrint('Location permission dialog confirmed');
              return true;
            }());

            // Add safety timer to reset loading state
            Timer(const Duration(seconds: 10), () {
              try {
                final orderController = Get.find<OrderController>();
                if (orderController.isLoading) {
                  assert(() {
                    debugPrint(
                        'Safety: Resetting OrderController loading state');
                    return true;
                  }());
                  orderController.initLoading();
                }
              } catch (e) {
                assert(() {
                  debugPrint('Error in safety timer: $e');
                  return true;
                }());
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
    assert(() {
      debugPrint('Location permission state reset');
      return true;
    }());
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
      assert(() {
        debugPrint('Starting location recording...');
        return true;
      }());

      // Add timeout for location request
      final Position locationResult = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          assert(() {
            debugPrint('Location request timed out');
            return true;
          }());
          throw TimeoutException(
              'Location request timed out', const Duration(seconds: 15));
        },
      );

      assert(() {
        debugPrint(
            'Location obtained: ${locationResult.latitude}, ${locationResult.longitude}');
        return true;
      }());

      String address =
          await profileServiceInterface.addressPlaceMark(locationResult);
      assert(() {
        debugPrint('Address resolved: $address');
        return true;
      }());

      _recordLocation = RecordLocationBodyModel(
        location: address,
        latitude: locationResult.latitude,
        longitude: locationResult.longitude,
      );

      if (Get.find<SplashController>().configModel!.webSocketStatus!) {
        assert(() {
          debugPrint('Recording location via WebSocket');
          return true;
        }());
        await profileServiceInterface.recordWebSocketLocation(_recordLocation!);
      } else {
        assert(() {
          debugPrint('Recording location via HTTP');
          return true;
        }());
        await profileServiceInterface.recordLocation(_recordLocation!);
      }

      assert(() {
        debugPrint('Location recorded successfully');
        return true;
      }());
    } catch (e) {
      assert(() {
        debugPrint('Error recording location: $e');
        return true;
      }());

      // Use fallback location if GPS fails
      await _recordFallbackLocationIfNeeded(null);
    }
  }

  Future<void> _recordFallbackLocationIfNeeded(
      LocationPermission? permission) async {
    if (_hasRecordedFallbackLocation) {
      return;
    }

    if (permission != null &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      return;
    }

    final defaultLocation =
        Get.find<SplashController>().configModel?.defaultLocation;
    final double fallbackLat =
        double.tryParse(defaultLocation?.lat ?? '') ?? 24.700531572620886;
    final double fallbackLng =
        double.tryParse(defaultLocation?.lng ?? '') ?? 46.7287762170735;

    _recordLocation = RecordLocationBodyModel(
      location: 'Location unavailable',
      latitude: fallbackLat,
      longitude: fallbackLng,
    );

    try {
      if (Get.find<SplashController>().configModel!.webSocketStatus!) {
        await profileServiceInterface.recordWebSocketLocation(_recordLocation!);
      } else {
        await profileServiceInterface.recordLocation(_recordLocation!);
      }
      _hasRecordedFallbackLocation = true;
      assert(() {
        debugPrint('Fallback location recorded');
        return true;
      }());
    } catch (fallbackError) {
      assert(() {
        debugPrint('Error recording fallback location: $fallbackError');
        return true;
      }());
    }
  }
}
