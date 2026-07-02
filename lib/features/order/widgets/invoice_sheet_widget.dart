import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';

/// كابتن شله — نافذة «اصدار فاتورة»
/// لما يُدخل الكابتن المبلغ ويختار الصورة تُرسل الفاتورة تلقائياً.
class InvoiceSheetWidget extends StatefulWidget {
  final int orderId;
  final double? initialAmount;
  final bool hasExistingImage;
  const InvoiceSheetWidget(
      {super.key,
      required this.orderId,
      this.initialAmount,
      this.hasExistingImage = false});

  @override
  State<InvoiceSheetWidget> createState() => _InvoiceSheetWidgetState();
}

class _InvoiceSheetWidgetState extends State<InvoiceSheetWidget> {
  final TextEditingController _amountCtrl = TextEditingController();
  bool _issued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().clearInvoiceImage();
    });
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountCtrl.text = widget.initialAmount!.toStringAsFixed(2);
    }
    _amountCtrl.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountCtrl.removeListener(_onAmountChanged);
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusExtraLarge)),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('اصدار فاتورة',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('تفاصيل الفاتورة',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text('عزيزنا الكابتن، نرجو إدخال نفس قيمة فاتورة المتجر',
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('إجمالي قيمة الفاتورة',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: robotoMedium,
                decoration: InputDecoration(
                  hintText: 'قيمة الفاتورة',
                  suffixText: 'ريال',
                  filled: true,
                  fillColor: Theme.of(context).disabledColor.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSmall),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              GetBuilder<OrderController>(builder: (orderController) {
                final picked = orderController.pickedInvoiceImage;
                return InkWell(
                  onTap: _issued ? null : () => _pickPhoto(orderController),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          width: 1),
                    ),
                    child: picked == null
                        ? Column(
                            children: [
                              Icon(
                                  widget.hasExistingImage
                                      ? Icons.check_circle_outline
                                      : Icons.photo_camera_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 30),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Text(
                                  widget.hasExistingImage
                                      ? 'صورة الفاتورة مرفقة مسبقاً — اضغط لتغييرها'
                                      : 'ارفق صورة لفاتورة المتجر (إلزامي)',
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                      color: widget.hasExistingImage
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).hintColor)),
                            ],
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                child: Image.file(File(picked.path),
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Text(
                                  _issued
                                      ? 'تم رفع الصورة بنجاح ✓'
                                      : 'اضغط لتغيير الصورة',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: _issued
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).primaryColor)),
                            ],
                          ),
                  ),
                );
              }),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              GetBuilder<OrderController>(builder: (orderController) {
                if (orderController.invoiceLoading) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (_issued) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: Theme.of(context).primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text('تم حفظ الفاتورة بنجاح',
                          style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeDefault)),
                    ],
                  );
                }
                final canSubmit = (double.tryParse(_amountCtrl.text.trim()) ?? 0) > 0 &&
                    (orderController.pickedInvoiceImage != null || widget.hasExistingImage);
                return CustomButtonWidget(
                  buttonText: 'حفظ الفاتورة',
                  icon: Icons.save_outlined,
                  onPressed: canSubmit
                      ? () async {
                          final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
                          final ok = await orderController.submitInvoice(
                              widget.orderId, amount,
                              allowNoImage: widget.hasExistingImage);
                          if (!mounted) return;
                          if (ok) {
                            setState(() => _issued = true);
                            // إغلاق تلقائي بعد ١.٥ ثانية — result: true يُخبر شاشة الطلب بالانتقال لموقع العميل
                            Future.delayed(const Duration(milliseconds: 1500),
                                () { if (mounted) Get.back(result: true); });
                          }
                        }
                      : null,
                );
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ),
        ),
      ),
    );
  }

  void _pickPhoto(OrderController orderController) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text('الكاميرا', style: robotoMedium),
                onTap: () {
                  Get.back();
                  orderController.pickInvoiceImage(isCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('المعرض', style: robotoMedium),
                onTap: () {
                  Get.back();
                  orderController.pickInvoiceImage(isCamera: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
