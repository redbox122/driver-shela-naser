// ChooseLanguageScreen
//
// Two responsibilities:
//   1. First-launch experience: when the user opens the app for the first
//      time and no language has been chosen, this screen is pushed by the
//      splash flow. The back button is hidden, the user must pick a
//      language, press Save and we then mark the language intro as seen
//      and resume the normal splash routing.
//   2. In-app language switching: reachable from Profile -> Language. The
//      user can change locale at any time; tapping Save persists the new
//      locale and pops back to the previous screen.
//
// The screen is intentionally minimal and consistent with the rest of
// the app's theme (cards, primary color, robotoMedium typography).
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/language/controllers/language_controller.dart';
import 'package:shellafood_delivery/features/language/widgets/language_widget.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';

class ChooseLanguageScreen extends StatelessWidget {
  /// True when this screen is shown as part of the very first app launch
  /// (no saved language yet). In that mode the back button is hidden and
  /// pressing Save will mark the intro as seen and resume routing through
  /// the normal splash flow instead of popping.
  final bool fromFirstLaunch;

  const ChooseLanguageScreen({super.key, this.fromFirstLaunch = false});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // On first-launch we want to prevent the user from leaving without
      // making a choice. Outside of first-launch the user can pop normally.
      canPop: !fromFirstLaunch,
      child: Scaffold(
        appBar: fromFirstLaunch
            ? null
            : CustomAppBarWidget(title: 'language'.tr),
        body: SafeArea(
          child: GetBuilder<LocalizationController>(
            builder: (localizationController) {
              return Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Center(
                              child: Image.asset(Images.logo, width: 140),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeLarge),
                            Text(
                              'choose_language_title'.tr,
                              textAlign: TextAlign.center,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeOverLarge,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            Text(
                              'choose_language_subtitle'.tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeLarge),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: localizationController.languages.length,
                              itemBuilder: (context, index) => LanguageWidget(
                                languageModel:
                                    localizationController.languages[index],
                                localizationController: localizationController,
                                index: index,
                              ),
                            ),
                            if (!fromFirstLaunch) ...[
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              Text(
                                'you_can_change_language'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                CustomButtonWidget(
                  buttonText: fromFirstLaunch
                      ? 'continue_text'.tr
                      : 'save'.tr,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  onPressed: () => _onSave(localizationController),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  /// Persists the selected locale and either resumes the splash routing
  /// (first launch) or pops back to the previous screen (settings flow).
  Future<void> _onSave(LocalizationController controller) async {
    if (controller.languages.isEmpty || controller.selectedIndex == -1) {
      showCustomSnackBar('select_a_language'.tr);
      return;
    }

    final selected = AppConstants.languages[controller.selectedIndex];
    controller.setLanguage(
      Locale(selected.languageCode!, selected.countryCode),
    );

    if (fromFirstLaunch) {
      await controller.markLanguageIntroSeen();
      await _resumeNormalRouting();
    } else {
      Get.back();
    }
  }

  /// Recreates the routing decision normally made by `SplashScreen._route`
  /// after a successful config fetch, so the first-launch picker does not
  /// re-run the entire splash UI again.
  Future<void> _resumeNormalRouting() async {
    final splashController = Get.find<SplashController>();
    final configModel = splashController.configModel;
    if (configModel == null) {
      // Config has not yet loaded (very first launch). Send the user back
      // through splash so it can fetch config and route accordingly.
      Get.offAllNamed(RouteHelper.getSplashRoute(null));
      return;
    }

    double minimumVersion = 0;
    if (GetPlatform.isAndroid) {
      minimumVersion = configModel.appMinimumVersionAndroid ?? 0;
    } else if (GetPlatform.isIOS) {
      minimumVersion = configModel.appMinimumVersionIos ?? 0;
    }
    final bool inMaintenance = configModel.maintenanceMode ?? false;

    if (AppConstants.appVersion < minimumVersion || inMaintenance) {
      Get.offAllNamed(RouteHelper.getUpdateRoute(
          AppConstants.appVersion < minimumVersion));
      return;
    }

    if (Get.find<AuthController>().isLoggedIn()) {
      await Future.wait([
        Get.find<AuthController>().updateToken(),
        Get.find<ProfileController>().getProfile(),
      ]);
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
  }
}
