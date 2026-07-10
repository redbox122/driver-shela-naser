import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/auth/controllers/auth_controller.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:shellafood_delivery/features/cash_in_hand/domain/models/wallet_payment_model.dart';
// بطاقة ملخّص الأرباح — استيراد جديد (إضافة)
import 'package:shellafood_delivery/features/cash_in_hand/widgets/earnings_summary_card_widget.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_image_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/cash_in_hand/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:shellafood_delivery/features/cash_in_hand/widgets/wallet_attention_alert_widget.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({super.key});

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {
  final ScrollController scrollController = ScrollController();

  void _logCashInHandAction(String action) {
    debugPrint('\x1B[34m[CASH_IN_HAND] $action\x1B[0m');
  }

  @override
  void initState() {
    super.initState();
    _refreshWalletData();
  }

  Future<void> _refreshWalletData() async {
    debugPrint('[DM_WALLET_REFRESH_ON_OPEN]');
    debugPrint('[DM_ACCOUNT_FETCH_START] account_screen_refresh');
    debugPrint('[DM_WALLET_FETCH_START] account_screen_refresh');
    await Get.find<ProfileController>().getProfile();
    await Get.find<CashInHandController>().getWalletPaymentList();
    await Get.find<CashInHandController>().getWalletProvidedEarningList();
    debugPrint('[DM_ACCOUNT_FETCH_SUCCESS] account_screen_refresh');
    debugPrint('[DM_WALLET_FETCH_SUCCESS] account_screen_refresh');
  }

  @override
  Widget build(BuildContext context) {
    // إخفاء قسم «النقد في اليد» — النموذج رقمي بالكامل والتحويل عبر ماي فاتورة.
    // الكود الأصلي محفوظ بالكامل ويُعاد تفعيله بجعل العلَم true.
    bool showCashInHandSection = false;
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'my_account'.tr,
        isBackButtonExist: true,
        actionWidget:
            GetBuilder<ProfileController>(builder: (profileController) {
          return Container(
            margin: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                    width: 1.5, color: Theme.of(context).primaryColor)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: CustomImageWidget(
                image: (profileController.profileModel != null &&
                        Get.find<AuthController>().isLoggedIn())
                    ? profileController.profileModel!.imageFullUrl ?? ''
                    : '',
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),
      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        debugPrint('[DM_WALLET_UI_BUILD] cash_in_hand_screen');
        return GetBuilder<ProfileController>(builder: (profileController) {
          return (profileController.profileModel != null &&
                  cashInHandController.transactions != null &&
                  cashInHandController.walletProvidedTransactions != null)
              ? RefreshIndicator(
                  onRefresh: () async {
                    await _refreshWalletData();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(children: [
                            // بطاقة ملخّص الأرباح — إضافة جديدة أعلى الشاشة (لا حذف لأي محتوى موجود)
                            const EarningsSummaryCardWidget(),
                            // قسم «النقد في اليد» — مخفيّ في النموذج الرقمي (بلا حذف، شرط إظهار فقط)
                            // ignore: dead_code
                            if (showCashInHandSection)
                              // ignore: dead_code
                              Container(
                              width: context.width,
                              height: 129,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                color: const Color(0xff334257),
                                image: const DecorationImage(
                                  image: AssetImage(Images.cashInHandBg),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(Images.walletIcon,
                                                      width: 40, height: 40),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  Flexible(
                                                    child: Text(
                                                      'المبلغ المطلوب سداده للإدارة',
                                                      style:
                                                          robotoMedium.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                              Directionality(
                                                textDirection:
                                                    TextDirection.ltr,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    _logAndConvertAccountAmount(
                                                      amount: profileController
                                                          .profileModel!
                                                          .payableBalance,
                                                      label: 'payable_to_admin',
                                                    ),
                                                    style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeOverLarge,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            profileController
                                                    .profileModel!.adjustable!
                                                ? InkWell(
                                                    onTap: () {
                                                      _logCashInHandAction(
                                                          'Tap: adjust_payments');
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GetBuilder<
                                                                    CashInHandController>(
                                                                builder:
                                                                    (cashInHandController) {
                                                              return AlertDialog(
                                                                title: Center(
                                                                    child: Text(
                                                                        'cash_adjustment'
                                                                            .tr)),
                                                                content: Text(
                                                                    'cash_adjustment_description'
                                                                        .tr,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                                actions: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                SizedBox(
                                                                              height: 45,
                                                                              child: CustomButtonWidget(
                                                                                onPressed: () => Get.back(),
                                                                                backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                                                                buttonText: 'cancel'.tr,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: Dimensions.paddingSizeExtraLarge),
                                                                          Expanded(
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                cashInHandController.makeWalletAdjustment();
                                                                              },
                                                                              child: Container(
                                                                                height: 45,
                                                                                alignment: Alignment.center,
                                                                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                  color: Theme.of(context).primaryColor,
                                                                                ),
                                                                                child: !cashInHandController.isLoading
                                                                                    ? Text(
                                                                                        'ok'.tr,
                                                                                        style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge),
                                                                                      )
                                                                                    : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                          });
                                                    },
                                                    child: Container(
                                                      width: 115,
                                                      padding: const EdgeInsets
                                                          .all(Dimensions
                                                              .paddingSizeSmall),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      child: Text(
                                                          'adjust_payments'.tr,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: robotoMedium.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor)),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                                height: profileController
                                                        .profileModel!
                                                        .adjustable!
                                                    ? Dimensions
                                                        .paddingSizeLarge
                                                    : 0),
                                            InkWell(
                                              onTap: () {
                                                _logCashInHandAction(
                                                    'Tap: pay_now');
                                                if (profileController
                                                    .profileModel!
                                                    .showPayNowButton!) {
                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    useRootNavigator: true,
                                                    context: context,
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(Dimensions
                                                                  .radiusExtraLarge),
                                                          topRight: Radius
                                                              .circular(Dimensions
                                                                  .radiusExtraLarge)),
                                                    ),
                                                    builder: (context) {
                                                      _logCashInHandAction(
                                                          'ENTER: payment_method_sheet');
                                                      return ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            maxHeight: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.8),
                                                        child:
                                                            const PaymentMethodBottomSheetWidget(),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  if (Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .activePaymentMethodList!
                                                          .isEmpty ||
                                                      !Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .digitalPayment!) {
                                                    showCustomSnackBar(
                                                        'currently_there_are_no_payment_options_available_please_contact_admin_regarding_any_payment_process_or_queries'
                                                            .tr);
                                                  } else if (Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .minAmountToPayDm! >
                                                      profileController
                                                          .profileModel!
                                                          .payableBalance!) {
                                                    showCustomSnackBar(
                                                        '${'you_do_not_have_sufficient_balance_to_pay_the_minimum_payable_balance_is'.tr} ${PriceConverterHelper.convertPrice(Get.find<SplashController>().configModel!.minAmountToPayDm)}');
                                                  }
                                                }
                                              },
                                              child: Container(
                                                width: profileController
                                                        .profileModel!
                                                        .adjustable!
                                                    ? 115
                                                    : null,
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeSmall,
                                                    horizontal: Dimensions
                                                        .paddingSizeDefault),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                  color: profileController
                                                          .profileModel!
                                                          .showPayNowButton!
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .disabledColor
                                                          .withValues(
                                                              alpha: 0.8),
                                                ),
                                                child: Center(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'pay_now'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),
                            Row(children: [
                              // إحصائية «النقد في اليد» — مخفيّة (نموذج رقمي)، بلا حذف
                              // ignore: dead_code
                              if (showCashInHandSection)
                                // ignore: dead_code
                                Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: Get.isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                                color: Colors.grey[200]!,
                                                spreadRadius: 0.5,
                                                blurRadius: 5)
                                          ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _renderAccountAmount(
                                          amount: profileController
                                              .profileModel!.cashInHands,
                                          label: 'cash_in_hand',
                                          context: context,
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text('النقد في اليد',
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ]),
                                ),
                              ),
                              // الفاصل بين النقد في اليد والرصيد — مخفيّ مع الإحصائية (بلا حذف)
                              // ignore: dead_code
                              if (showCashInHandSection)
                                // ignore: dead_code
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: Get.isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                                color: Colors.grey[200]!,
                                                spreadRadius: 0.5,
                                                blurRadius: 5)
                                          ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _renderAccountAmount(
                                          amount: profileController
                                              .profileModel!.balance,
                                          label: 'balance',
                                          context: context,
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text('الرصيد',
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ]),
                                ),
                              ),
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraLarge),
                              child: Row(children: [
                                InkWell(
                                  onTap: () {
                                    if (cashInHandController.selectedIndex !=
                                        0) {
                                      cashInHandController.setIndex(0);
                                    }
                                  },
                                  hoverColor: Colors.transparent,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('payment_history'.tr,
                                            style: robotoMedium.copyWith(
                                              color: cashInHandController
                                                          .selectedIndex ==
                                                      0
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .disabledColor,
                                            )),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Container(
                                          height: 3,
                                          width: 110,
                                          margin: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: cashInHandController
                                                        .selectedIndex ==
                                                    0
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                InkWell(
                                  onTap: () {
                                    if (cashInHandController.selectedIndex !=
                                        1) {
                                      cashInHandController.setIndex(1);
                                    }
                                  },
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('wallet_provided_earning'.tr,
                                            style: robotoMedium.copyWith(
                                              color: cashInHandController
                                                          .selectedIndex ==
                                                      1
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .disabledColor,
                                            )),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Container(
                                          height: 3,
                                          width: 150,
                                          margin: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: cashInHandController
                                                        .selectedIndex ==
                                                    1
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                      ]),
                                ),
                              ]),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("transaction_history".tr,
                                      style: robotoMedium),
                                  (cashInHandController.selectedIndex == 0 &&
                                              cashInHandController
                                                  .transactions!.isEmpty) ||
                                          (cashInHandController.selectedIndex ==
                                                  1 &&
                                              cashInHandController
                                                  .walletProvidedTransactions!
                                                  .isEmpty)
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {
                                            _logCashInHandAction(
                                                'Tap: view_all');
                                            if (cashInHandController
                                                    .selectedIndex ==
                                                0) {
                                              Get.toNamed(RouteHelper
                                                  .getTransactionHistoryRoute());
                                            }
                                            if (cashInHandController
                                                    .selectedIndex ==
                                                1) {
                                              Get.toNamed(RouteHelper
                                                  .getWalletProvidedEarningRoute());
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 10),
                                            child: Text('view_all'.tr,
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )),
                                          ),
                                        ),
                                ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            if (cashInHandController.selectedIndex == 0)
                              cashInHandController.transactions != null
                                  ? cashInHandController
                                          .transactions!.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: cashInHandController
                                                      .transactions!.length >
                                                  25
                                              ? 25
                                              : cashInHandController
                                                  .transactions!.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeLarge),
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Directionality(
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                            child: Text(
                                                              _logAndConvertAccountAmount(
                                                                amount: cashInHandController
                                                                    .transactions![
                                                                        index]
                                                                    .amount,
                                                                label:
                                                                    'payment_history',
                                                              ),
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              '${'paid_via'.tr} ${cashInHandController.transactions![index].method?.replaceAll('_', ' ').capitalize ?? ''}',
                                                              style:
                                                                  robotoRegular
                                                                      .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeExtraSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor,
                                                              )),
                                                        ]),
                                                  ),
                                                  Text(
                                                    cashInHandController
                                                        .transactions![index]
                                                        .paymentTime
                                                        .toString(),
                                                    style:
                                                        robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                  ),
                                                ]),
                                              ),
                                              const Divider(height: 1),
                                            ]);
                                          },
                                        )
                                      : Center(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 250),
                                              child: Text(
                                                  'no_transaction_found'.tr)))
                                  : const Center(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 250),
                                          child: CircularProgressIndicator())),
                            if (cashInHandController.selectedIndex == 1)
                              cashInHandController.walletProvidedTransactions !=
                                      null
                                  ? cashInHandController
                                          .walletProvidedTransactions!
                                          .isNotEmpty
                                      ? ListView.builder(
                                          itemCount: cashInHandController
                                              .walletProvidedTransactions!
                                              .length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeLarge),
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Directionality(
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                            child: Text(
                                                              _logAndConvertAccountAmount(
                                                                amount: cashInHandController
                                                                    .walletProvidedTransactions![
                                                                        index]
                                                                    .amount,
                                                                label:
                                                                    'earning_history',
                                                              ),
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              _getWalletProvidedMethodLabel(
                                                                cashInHandController
                                                                        .walletProvidedTransactions![
                                                                    index],
                                                              ),
                                                              style:
                                                                  robotoRegular
                                                                      .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeExtraSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor,
                                                              )),
                                                        ]),
                                                  ),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          cashInHandController
                                                              .walletProvidedTransactions![
                                                                  index]
                                                              .paymentTime
                                                              .toString(),
                                                          style: robotoRegular.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor),
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Text(
                                                            cashInHandController
                                                                .walletProvidedTransactions![
                                                                    index]
                                                                .status!
                                                                .tr,
                                                            style: robotoRegular
                                                                .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: cashInHandController.walletProvidedTransactions![index].status ==
                                                                      'approved'
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : cashInHandController
                                                                              .walletProvidedTransactions![
                                                                                  index]
                                                                              .status ==
                                                                          'denied'
                                                                      ? Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .error
                                                                      : Colors
                                                                          .blue,
                                                            )),
                                                      ]),
                                                ]),
                                              ),
                                              const Divider(height: 1),
                                            ]);
                                          },
                                        )
                                      : Center(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 250),
                                              child: Text(
                                                  'no_transaction_found'.tr)))
                                  : const Center(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 250),
                                          child: CircularProgressIndicator())),
                          ]),
                        ),
                      ),
                      (profileController.profileModel!.overFlowWarning! ||
                              profileController
                                  .profileModel!.overFlowBlockWarning!)
                          ? WalletAttentionAlertWidget(
                              isOverFlowBlockWarning: profileController
                                  .profileModel!.overFlowBlockWarning!)
                          : const SizedBox(),
                    ]),
                  ),
                )
              : const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }

  Widget _renderAccountAmount({
    required double? amount,
    required String label,
    required BuildContext context,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _logAndConvertAccountAmount(amount: amount, label: label),
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).primaryColor,
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  String _logAndConvertAccountAmount({
    required double? amount,
    required String label,
  }) {
    debugPrint('[DM_ACCOUNT_AMOUNT_RENDER] label=$label amount=$amount');
    return PriceConverterHelper.convertPrice(amount);
  }

  String _getWalletProvidedMethodLabel(Transactions transaction) {
    final String? method = transaction.method;
    final String label;
    if (method == 'order_delivery') {
      final String? orderId = _extractOrderId(transaction.ref);
      label = orderId == null ? 'أرباح توصيل طلب' : 'أرباح توصيل طلب #$orderId';
    } else if (method == 'adjustment') {
      label = 'تسوية محفظة';
    } else {
      label = '${'wallet'.tr} ${method?.replaceAll('_', ' ').capitalize ?? ''}';
    }
    debugPrint('[DM_EARNING_METHOD_MAPPED] method=$method label=$label');
    return label;
  }

  String? _extractOrderId(String? ref) {
    if (ref == null) {
      return null;
    }
    final RegExpMatch? match =
        RegExp(r'order_(\d+)_delivery_earning').firstMatch(ref);
    return match?.group(1);
  }
}
