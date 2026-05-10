import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:shellafood_delivery/features/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:shellafood_delivery/helper/price_converter_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';

class WalletProvidedHistoryScreen extends StatefulWidget {
  const WalletProvidedHistoryScreen({super.key});

  @override
  State<WalletProvidedHistoryScreen> createState() =>
      _WalletProvidedHistoryScreenState();
}

class _WalletProvidedHistoryScreenState
    extends State<WalletProvidedHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _refreshWalletHistory();
  }

  Future<void> _refreshWalletHistory() async {
    debugPrint('[DM_WALLET_REFRESH_ON_OPEN]');
    debugPrint('[DM_ACCOUNT_FETCH_START] wallet_history_refresh');
    await Get.find<CashInHandController>().getWalletProvidedEarningList();
    debugPrint('[DM_ACCOUNT_FETCH_SUCCESS] wallet_history_refresh');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'wallet_provided_earning_history'.tr),
      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        debugPrint('[DM_WALLET_UI_BUILD] wallet_provided_history_screen');
        return cashInHandController.walletProvidedTransactions != null
            ? cashInHandController.walletProvidedTransactions!.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: _refreshWalletHistory,
                    child: ListView.builder(
                      itemCount: cashInHandController
                          .walletProvidedTransactions!.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final transaction = cashInHandController
                            .walletProvidedTransactions![index];
                        return Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeLarge),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                            _logAndConvertAccountAmount(
                                              amount: transaction.amount,
                                              label: 'earning_history',
                                            ),
                                            style: robotoMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeDefault)),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall),
                                      Text(
                                          _getWalletProvidedMethodLabel(
                                              transaction),
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color:
                                                Theme.of(context).disabledColor,
                                          )),
                                    ]),
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      transaction.paymentTime.toString(),
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    Text(transaction.status!.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: transaction.status ==
                                                  'approved'
                                              ? Theme.of(context).primaryColor
                                              : transaction.status == 'denied'
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .error
                                                  : Colors.blue,
                                        )),
                                  ]),
                            ]),
                          ),
                          const Divider(height: 1),
                        ]);
                      },
                    ),
                  )
                : Center(child: Text('no_transaction_found'.tr))
            : const Center(child: CircularProgressIndicator());
      }),
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
