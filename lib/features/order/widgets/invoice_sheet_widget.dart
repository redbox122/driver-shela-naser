import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/common/widgets/custom_button_widget.dart';

/// كابتن شله — نافذة «اصدار فاتورة»: الكابتن يُدخل قيمة فاتورة المتجر ويُرفق صورتها.
/// تُحفظ على الطلب وتظهر بالداش بورد فقط (لا يراها العميل).
class InvoiceSheetWidget extends StatefulWidget {
  final int orderId;
  final double? initialAmount;
  final bool hasExistingImage; // صورة فاتورة محفوظة مسبقاً (وضع التعديل)
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
  // بعد إصدار/تعديل الفاتورة يظهر زر «تابع الطلب» داخل النافذة
  bool _issued = false;

  @override
  void initState() {
    super.initState();
    // تأجيل المسح لما بعد أول إطار لتفادي «setState/markNeedsBuild during build»
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().clearInvoiceImage();
    });
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountCtrl.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  // يسمح بالأرقام والفاصلة العشرية فقط (فئة أحرف بسيطة وموثوقة)
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
                  onTap: () => _pickPhoto(orderController),
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
                              Text('اضغط لتغيير الصورة',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).primaryColor)),
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
                // بعد الحفظ: رسالة نجاح + زر «تابع الطلب» (داخل النافذة)
                if (_issued) {
                  return Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Text('تم حفظ الفاتورة بنجاح',
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomButtonWidget(
                      buttonText: 'تابع الطلب',
                      icon: Icons.arrow_forward,
                      onPressed: () => Get.back(),
                    ),
                  ]);
                }
                return CustomButtonWidget(
                  buttonText: 'اصدار فاتورة',
                  onPressed: () async {
                    final amount =
                        double.tryParse(_amountCtrl.text.trim()) ?? 0;
                    final ok = await orderController.submitInvoice(
                        widget.orderId, amount,
                        allowNoImage: widget.hasExistingImage);
                    // بدل إغلاق النافذة: نُظهر «تابع الطلب» داخلها
                    if (ok && mounted) setState(() => _issued = true);
                  },
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
    Get.bottomSheet(
      SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text('الكاميرا', style: robotoMedium),
                onTap: () => orderController.pickInvoiceImage(isCamera: true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('المعرض', style: robotoMedium),
                onTap: () => orderController.pickInvoiceImage(isCamera: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
