import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/address/controllers/address_controller.dart';
import 'package:shellafood_delivery/features/language/controllers/language_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:shellafood_delivery/helper/custom_validator_helper.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_dropdown_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:shellafood_delivery/features/auth/widgets/condition_check_box_widget.dart';
import 'package:shellafood_delivery/features/auth/widgets/pass_view_widget.dart';

class DeliveryManRegistrationScreen extends StatefulWidget {
  const DeliveryManRegistrationScreen({super.key});

  @override
  State<DeliveryManRegistrationScreen> createState() =>
      _DeliveryManRegistrationScreenState();
}

class _DeliveryManRegistrationScreenState
    extends State<DeliveryManRegistrationScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _nationalityNumberController =
      TextEditingController();
  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _identityNumberNode = FocusNode();
  String? _countryDialCode;
  bool _hasRequestedRegistrationLookups = false;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass(isUpdate: false);
    }
    Get.find<AuthController>().pickDmImageForRegistration(false, true);
    Get.find<AuthController>().dmStatusChange(0.4, isUpdate: false);
    Get.find<AuthController>().validPassCheck('', isUpdate: false);
    Get.find<AuthController>().setIdentityTypeIndex(
        Get.find<AuthController>().identityTypeList[0], false);
    Get.find<AuthController>().setDMTypeIndex(0, false);
    _loadRegistrationLookups();
  }

  void _loadRegistrationLookups() {
    if (_hasRequestedRegistrationLookups) {
      return;
    }
    _hasRequestedRegistrationLookups = true;
    Get.find<AddressController>().getZoneList();
    Get.find<AuthController>().getVehicleList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (Get.find<AuthController>().dmStatus != 0.4 && !didPop) {
          Get.find<AuthController>().dmStatusChange(0.4);
        } else {
          Future.delayed(const Duration(milliseconds: 0), () {
            Get.offAllNamed(RouteHelper.getSignInRoute());
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'delivery_man_registration'.tr,
            onBackPressed: () {
              if (Get.find<AuthController>().dmStatus != 0.4) {
                Get.find<AuthController>().dmStatusChange(0.4);
              } else {
                Future.delayed(const Duration(milliseconds: 0), () {
                  Get.back();
                });
              }
            }),
        body: GetBuilder<AuthController>(builder: (authController) {
          return GetBuilder<AddressController>(builder: (addressController) {
            List<int> zoneIndexList = [];
            List<DropdownItem<int>> zoneList = [];
            List<DropdownItem<int>> vehicleList = [];
            List<DropdownItem<int>> dmTypeList = [];
            List<DropdownItem<int>> identityTypeList = [];

            for (int index = 0;
                index < authController.dmTypeList.length;
                index++) {
              dmTypeList.add(DropdownItem<int>(
                  value: index,
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${authController.dmTypeList[index]?.tr}'),
                    ),
                  )));
            }
            for (int index = 0;
                index < authController.identityTypeList.length;
                index++) {
              identityTypeList.add(DropdownItem<int>(
                  value: index,
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(authController.identityTypeList[index].tr),
                    ),
                  )));
            }
            if (addressController.zoneList != null) {
              for (int index = 0;
                  index < addressController.zoneList!.length;
                  index++) {
                zoneIndexList.add(index);
                zoneList.add(DropdownItem<int>(
                    value: index,
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('${addressController.zoneList![index].name}'),
                      ),
                    )));
              }
            }
            if (authController.vehicles != null) {
              for (int index = 0;
                  index < authController.vehicles!.length;
                  index++) {
                vehicleList.add(DropdownItem<int>(
                    value: index + 1,
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${authController.vehicles![index].type}'),
                      ),
                    )));
              }
            }

            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                child: Column(children: [
                  Text(
                    'complete_registration_process_to_serve_as_delivery_man_in_this_platform'
                        .tr,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).disabledColor,
                    minHeight: 2,
                    value: authController.dmStatus,
                  ),
                ]),
              ),
              Expanded(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                physics: const BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: authController.dmStatus == 0.4,
                        child: Column(children: [
                          Align(
                              alignment: Alignment.center,
                              child: Stack(clipBehavior: Clip.none, children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  child: authController.pickedImage != null
                                      ? GetPlatform.isWeb
                                          ? Image.network(
                                              authController.pickedImage!.path,
                                              width: 140,
                                              height: 140,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(authController
                                                  .pickedImage!.path),
                                              width: 140,
                                              height: 140,
                                              fit: BoxFit.cover,
                                            )
                                      : SizedBox(
                                          width: 140,
                                          height: 140,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.photo_camera,
                                                    size: 26,
                                                    color: Theme.of(context)
                                                        .disabledColor),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                Text(
                                                  'upload_profile_picture'.tr,
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ]),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () => authController
                                        .pickDmImageForRegistration(
                                            true, false),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        radius: const Radius.circular(
                                            Dimensions.radiusDefault),
                                        color: Theme.of(context).primaryColor,
                                        strokeWidth: 1,
                                        strokeCap: StrokeCap.butt,
                                        dashPattern: const [5, 5],
                                        padding: const EdgeInsets.all(0),
                                      ),
                                      child: Visibility(
                                        visible:
                                            authController.pickedImage != null,
                                        child: Center(
                                          child: Container(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                authController.pickedImage != null
                                    ? Positioned(
                                        bottom: -10,
                                        right: -10,
                                        child: InkWell(
                                          onTap: () =>
                                              authController.removeDmImage(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  width: 2),
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            padding: const EdgeInsets.all(
                                                Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ])),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          Row(children: [
                            Expanded(
                                child: CustomTextFieldWidget(
                              hintText: 'first_name'.tr,
                              controller: _fNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _fNameNode,
                              nextFocus: _lNameNode,
                              prefixIcon: Icons.person,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeLarge),
                            Expanded(
                                child: CustomTextFieldWidget(
                              hintText: 'last_name'.tr,
                              controller: _lNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _lNameNode,
                              nextFocus: _phoneNode,
                              prefixIcon: Icons.person,
                            )),
                          ]),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          CustomTextFieldWidget(
                            hintText: 'phone'.tr,
                            controller: _phoneController,
                            focusNode: _phoneNode,
                            nextFocus: _emailNode,
                            inputType: TextInputType.phone,
                            isPhone: true,
                            onCountryChanged: (CountryCode countryCode) {
                              _countryDialCode = countryCode.dialCode;
                            },
                            countryDialCode: _countryDialCode ??
                                Get.find<LocalizationController>()
                                    .locale
                                    .countryCode,
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          CustomTextFieldWidget(
                            hintText: 'email'.tr,
                            controller: _emailController,
                            focusNode: _emailNode,
                            nextFocus: _passwordNode,
                            inputType: TextInputType.emailAddress,
                            prefixIcon: Icons.email,
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          CustomTextFieldWidget(
                            hintText: 'password'.tr,
                            controller: _passwordController,
                            focusNode: _passwordNode,
                            nextFocus: _identityNumberNode,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            prefixIcon: Icons.lock,
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!authController.showPassView) {
                                  authController.showHidePass();
                                }
                                authController.validPassCheck(value);
                              } else {
                                if (authController.showPassView) {
                                  authController.showHidePass();
                                }
                              }
                            },
                          ),
                          authController.showPassView
                              ? const PassViewWidget()
                              : const SizedBox(),
                        ]),
                      ),
                      Visibility(
                        visible: authController.dmStatus != 0.4,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 0.3)),
                                  child: CustomDropdown<int>(
                                    onChange: (int? value, int index) {
                                      authController.setDMTypeIndex(
                                          index, true);
                                    },
                                    dropdownButtonStyle: DropdownButtonStyle(
                                      height: 45,
                                      padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                        horizontal:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      primaryColor: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                    dropdownStyle: DropdownStyle(
                                      elevation: 10,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall),
                                    ),
                                    items: dmTypeList,
                                    child: Text(
                                        '${authController.dmTypeList[0]?.tr}'),
                                  ),
                                )),
                                const SizedBox(
                                    width: Dimensions.paddingSizeLarge),
                                Expanded(
                                    child: addressController.zoneList != null
                                        ? addressController.zoneList!.isNotEmpty
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      width: 0.3),
                                                ),
                                                child: CustomDropdown<int>(
                                                  onChange:
                                                      (int? value, int index) {
                                                    addressController
                                                        .setZoneIndex(value);
                                                  },
                                                  dropdownButtonStyle:
                                                      DropdownButtonStyle(
                                                    height: 45,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeExtraSmall,
                                                      horizontal: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                                  ),
                                                  dropdownStyle: DropdownStyle(
                                                    elevation: 10,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeExtraSmall),
                                                  ),
                                                  items: zoneList,
                                                  child: Text(
                                                      '${addressController.zoneList![0].name}'),
                                                ),
                                              )
                                            : _buildUnavailableDropdown(
                                                'لا توجد مناطق متاحة')
                                        : const Center(
                                            child:
                                                CircularProgressIndicator())),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              authController.vehicleIds != null
                                  ? authController.vehicles != null &&
                                          authController.vehicles!.isNotEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            color: Theme.of(context).cardColor,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 0.3),
                                          ),
                                          child: CustomDropdown<int>(
                                            onChange: (int? value, int index) {
                                              authController.setVehicleIndex(
                                                  value, true);
                                            },
                                            dropdownButtonStyle:
                                                DropdownButtonStyle(
                                              height: 45,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall,
                                                horizontal: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              primaryColor: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                            ),
                                            dropdownStyle: DropdownStyle(
                                              elevation: 10,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusDefault),
                                              padding: const EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeExtraSmall),
                                            ),
                                            items: vehicleList,
                                            child:
                                                Text('select_vehicle_type'.tr),
                                          ),
                                        )
                                      : _buildUnavailableDropdown(
                                          'لا توجد مركبات متاحة')
                                  : const CircularProgressIndicator(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 0.3),
                                ),
                                child: CustomDropdown<int>(
                                  onChange: (int? value, int index) {
                                    authController.setIdentityTypeIndex(
                                        authController.identityTypeList[index],
                                        true);
                                  },
                                  dropdownButtonStyle: DropdownButtonStyle(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall,
                                      horizontal:
                                          Dimensions.paddingSizeExtraSmall,
                                    ),
                                    primaryColor: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  dropdownStyle: DropdownStyle(
                                    elevation: 10,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                  ),
                                  items: identityTypeList,
                                  child: Text(
                                      authController.identityTypeList[0].tr),
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              CustomTextFieldWidget(
                                hintText: authController.identityTypeIndex == 0
                                    ? 'Ex: XXXXX-XXXXXXX-X'
                                    : authController.identityTypeIndex == 1
                                        ? 'L-XXX-XXX-XXX-XXX.'
                                        : 'XXX-XXXXX',
                                controller: _identityNumberController,
                                focusNode: _identityNumberNode,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.text,
                                enableSuggestions: false,
                                autocorrect: false,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              CustomTextFieldWidget(
                                hintText: "nationality".tr,
                                controller: _nationalityNumberController,
                                inputAction: TextInputAction.done,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    authController.pickedIdentities.length + 1,
                                itemBuilder: (context, index) {
                                  XFile? file = index ==
                                          authController.pickedIdentities.length
                                      ? null
                                      : authController.pickedIdentities[index];
                                  if (index ==
                                      authController.pickedIdentities.length) {
                                    return InkWell(
                                      onTap: () {
                                        if (authController
                                                .pickedIdentities.length <
                                            6) {
                                          authController
                                              .pickDmImageForRegistration(
                                                  false, false);
                                        } else {
                                          showCustomSnackBar(
                                              'maximum_image_limit_is_6'.tr);
                                        }
                                      },
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          radius: const Radius.circular(
                                              Dimensions.radiusDefault),
                                          color: Theme.of(context).primaryColor,
                                          strokeWidth: 1,
                                          strokeCap: StrokeCap.butt,
                                          dashPattern: const [5, 5],
                                          padding: const EdgeInsets.all(5),
                                        ),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.camera_alt,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                    size: 38),
                                                Text(
                                                    _getDocumentUploadLabel(
                                                        authController),
                                                    style: robotoMedium.copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor)),
                                              ]),
                                        ),
                                      ),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeSmall),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        radius: const Radius.circular(
                                            Dimensions.radiusDefault),
                                        color: Theme.of(context).primaryColor,
                                        strokeWidth: 1,
                                        strokeCap: StrokeCap.butt,
                                        dashPattern: const [5, 5],
                                        padding: const EdgeInsets.all(5),
                                      ),
                                      child: Stack(children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          child: GetPlatform.isWeb
                                              ? Image.network(
                                                  file!.path,
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(file!.path),
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: InkWell(
                                            onTap: () => authController
                                                .removeIdentityImage(index),
                                            child: const Padding(
                                              padding: EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              child: Icon(Icons.delete_forever,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              ConditionCheckBoxWidget(
                                  authController: authController,
                                  fromSignUp: true),
                            ]),
                      ),
                    ]),
              )),
              !authController.isLoading
                  ? CustomButtonWidget(
                      buttonText: authController.dmStatus == 0.4
                          ? 'next'.tr
                          : 'submit'.tr,
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      height: 50,
                      onPressed: () => _handleRegisterButtonTap(
                          authController, addressController),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ]);
          });
        }),
      ),
    );
  }

  Widget _buildUnavailableDropdown(String message) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 0.3,
        ),
      ),
      child: Text(
        message,
        style: robotoRegular.copyWith(
          color: Theme.of(context).disabledColor,
          fontSize: Dimensions.fontSizeSmall,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _handleRegisterButtonTap(AuthController authController,
      AddressController addressController) async {
    debugPrint(
        '[DM_REGISTER_TAP] step=${authController.dmStatus == 0.4 ? 'basic_info' : 'documents'}');
    if (authController.dmStatus == 0.4) {
      if (_validateBasicRegistrationStep(authController)) {
        debugPrint('[DM_REGISTER_VALIDATION_PASS] basic_info');
        authController.dmStatusChange(0.8);
      }
      return;
    }
    await _addDeliveryMan(authController, addressController);
  }

  bool _validateBasicRegistrationStep(AuthController authController) {
    debugPrint('[DM_REGISTER_VALIDATION_START] basic_info');
    final String fName = _fNameController.text.trim();
    final String lName = _lNameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    if (!authController.acceptTerms) {
      return _failRegistrationValidation('يرجى الموافقة على الشروط والأحكام');
    }
    if (fName.isEmpty) {
      return _failRegistrationValidation('يرجى إدخال الاسم الأول');
    }
    if (lName.isEmpty) {
      return _failRegistrationValidation('يرجى إدخال الاسم الأخير');
    }
    if (phone.isEmpty) {
      return _failRegistrationValidation('يرجى إدخال رقم الجوال');
    }
    if (!_isPhoneValid(phone)) {
      return _failRegistrationValidation('يرجى إدخال رقم جوال صحيح');
    }
    if (email.isEmpty) {
      return _failRegistrationValidation('يرجى إدخال البريد الإلكتروني');
    }
    if (!GetUtils.isEmail(email)) {
      return _failRegistrationValidation('يرجى إدخال بريد إلكتروني صحيح');
    }
    if (password.isEmpty) {
      return _failRegistrationValidation('يرجى إدخال كلمة المرور');
    }
    if (!authController.spatialCheck ||
        !authController.lowercaseCheck ||
        !authController.uppercaseCheck ||
        !authController.numberCheck ||
        !authController.lengthCheck) {
      return _failRegistrationValidation('يرجى إدخال كلمة مرور صالحة');
    }
    if (authController.pickedImage == null) {
      return _failRegistrationValidation('يرجى تحميل الصورة الشخصية');
    }
    return true;
  }

  bool _isPhoneValid(String phone) {
    final String numberWithCountryCode = (_countryDialCode ?? '') + phone;
    try {
      final PhoneNumber phoneNumber = PhoneNumber.parse(numberWithCountryCode);
      return phoneNumber.isValid();
    } catch (error) {
      debugPrint('[DM_REGISTER_VALIDATION_FAIL] invalid_phone');
      return false;
    }
  }

  bool _failRegistrationValidation(String message) {
    debugPrint('[DM_REGISTER_VALIDATION_FAIL] $message');
    showCustomSnackBar(message);
    return false;
  }

  Future<void> _addDeliveryMan(AuthController authController,
      AddressController addressController) async {
    debugPrint('[DM_REGISTER_VALIDATION_START] documents');
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String identityNumber = _identityNumberController.text.trim();

    String numberWithCountryCode = _countryDialCode! + phone;
    PhoneValid phoneValid =
        await CustomValidatorHelper.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (!authController.acceptTerms) {
      _failRegistrationValidation('يرجى الموافقة على الشروط والأحكام');
    } else if (fName.isEmpty) {
      _failRegistrationValidation('يرجى إدخال الاسم الأول');
    } else if (lName.isEmpty) {
      _failRegistrationValidation('يرجى إدخال الاسم الأخير');
    } else if (phone.isEmpty) {
      _failRegistrationValidation('يرجى إدخال رقم الجوال');
    } else if (!phoneValid.isValid) {
      _failRegistrationValidation('يرجى إدخال رقم جوال صحيح');
    } else if (email.isEmpty) {
      _failRegistrationValidation('يرجى إدخال البريد الإلكتروني');
    } else if (!GetUtils.isEmail(email)) {
      _failRegistrationValidation('يرجى إدخال بريد إلكتروني صحيح');
    } else if (password.isEmpty) {
      _failRegistrationValidation('يرجى إدخال كلمة المرور');
    } else if (authController.pickedImage == null) {
      _failRegistrationValidation('يرجى تحميل الصورة الشخصية');
    } else if (identityNumber.isEmpty) {
      _failRegistrationValidation('يرجى إدخال رقم الهوية');
    } else if (addressController.zoneList == null ||
        addressController.zoneList!.isEmpty) {
      _failRegistrationValidation('يرجى اختيار المنطقة');
    } else if (authController.vehicleIndex == null ||
        authController.vehicleIndex! - 1 == -1 ||
        authController.vehicles == null ||
        authController.vehicles!.isEmpty) {
      _failRegistrationValidation('يرجى اختيار نوع المركبة');
    } else if (authController.pickedIdentities.isEmpty) {
      _failRegistrationValidation(_getMissingDocumentMessage(authController));
    } else {
      debugPrint('[DM_REGISTER_VALIDATION_PASS] documents');
      await authController.registerDeliveryMan(DeliveryManBodyModel(
        fName: fName,
        lName: lName,
        password: password,
        phone: numberWithCountryCode,
        email: email,
        identityNumber: identityNumber,
        identityType:
            authController.identityTypeList[authController.identityTypeIndex],
        earning: authController.dmTypeIndex == 0 ? '1' : '0',
        zoneId: addressController
            .zoneList![addressController.selectedZoneIndex!].id
            .toString(),
        vehicleId: authController.vehicles![authController.vehicleIndex! - 1].id
            .toString(),
      ));
    }
  }

  String _getDocumentUploadLabel(AuthController authController) {
    return authController.identityTypeList[authController.identityTypeIndex] ==
            'driving_license'
        ? 'تحميل صورة الرخصة'
        : 'تحميل صورة الهوية';
  }

  String _getMissingDocumentMessage(AuthController authController) {
    return authController.identityTypeList[authController.identityTypeIndex] ==
            'driving_license'
        ? 'يرجى تحميل صورة الرخصة'
        : 'يرجى تحميل صورة الهوية';
  }
}
