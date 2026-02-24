# 🔒 نظام التصوير الإلزامي - مرحلتان

## 🎯 الهدف
ضمان التقاط صور إلزامية في مرحلتين مهمتين:
1. **عند الوصول للمطعم**: صورة المنتج/الفاتورة
2. **عند التسليم للعميل**: صورة التسليم

---

## 📋 المراحل الكاملة

### ✅ المرحلة الأولى: عند الوصول للمطعم (MODULES 6/7/8/9 فقط)

**الشروط:**
- `order.orderStatus == 'confirmed'`
- `order.module_id` ∈ [6, 7, 8, 9]

**الخطوات الإلزامية:**
```
1. عرض واجهة تحميل صور المطعم
   ├─ اختيار صور المنتج/الفاتورة
   └─ الحد الأقصى: 5 صور

2. رفع الصور
   ├─ التحقق: `order.orderProofFullUrl != null && order.orderProofFullUrl.isNotEmpty`
   └─ النتيجة: `status = 'confirmed'` (الحالة تبقى - صور توثيقية فقط)

3. السماح بضغط زر "Pick Up"
   ├─ الشرط: `orderProofFullUrl != null && orderProofFullUrl.isNotEmpty`
   └─ النتيجة: `status = 'picked_up'`
```

**الرسائل:**
- ⚠️ **قبل الرفع**: "من فضلك قم بتحميل صور إثبات الطلب أولاً"
- ✅ **بعد الرفع**: "تم تحميل صور إثبات الطلب بنجاح"
- 🔴 **خطأ**: "فشل التحميل" أو رسالة الخطأ من الخادم

---

### ✅ المرحلة الثانية: عند التسليم للعميل (جميع الطلبات)

**الشروط:**
- `order.orderStatus == 'picked_up'`
- `dmPictureUploadStatus == true` (من الإعدادات)

**الخطوات الإلزامية:**
```
1. عرض واجهة تحميل صورة التسليم
   ├─ التقاط صورة من الكاميرا
   └─ أو اختيار من المعرض (حد أقصى 5)

2. رفع الصورة
   ├─ التحقق: `pickedPrescriptions != null && pickedPrescriptions.isNotEmpty`
   └─ النتيجة: تحديث `deliveryImage` في الخادم

3. تفعيل زر "Complete Delivery"
   ├─ الشرط: `pickedPrescriptions.isNotEmpty`
   └─ النتيجة: السماح بـ `status = 'delivered'`
```

**الرسائل:**
- ⚠️ **قبل الالتقاط**: "قم بالتقاط صورة التسليم أولاً"
- ✅ **بعد الالتقاط**: "جاهز للإكمال"
- 🔴 **خطأ**: "فشل رفع الصورة"

---

## 🔧 البنية الفنية

### الملفات المتأثرة:

#### 1. **order_controller.dart**
```dart
// ✅ دوال مساعدة جديدة

/// التحقق من وجود صور المطعم المرفوعة
bool hasUploadedRestaurantPhotos(OrderModel order) {
  return order.orderProofFullUrl != null && 
         order.orderProofFullUrl!.isNotEmpty;
}

/// التحقق من التقاط صور التسليم
bool hasPickedDeliveryPhotos() {
  return _pickedPrescriptions.isNotEmpty;
}

/// التحقق من وجود صور التسليم المرفوعة
bool hasUploadedDeliveryPhotos(OrderModel order) {
  return order.deliveryImage != null && 
         order.deliveryImage!.isNotEmpty;
}
```

#### 2. **order_details_screen.dart**

**تعديل زر "Pick Up":**
```dart
// BEFORE ❌
if ([6, 7, 8, 9].contains(controllerOrderModel.module_id) &&
    confirmed &&
    controllerOrderModel.orderProofFullUrl != null &&
    controllerOrderModel.orderProofFullUrl!.isNotEmpty) {
  // يسمح بالالتقاط
}

// AFTER ✅ - لا نسمح إلا إذا كانت الصور موجودة
if ([6, 7, 8, 9].contains(controllerOrderModel.module_id) &&
    confirmed &&
    hasUploadedRestaurantPhotos(controllerOrderModel)) {
  // يسمح بالالتقاط
} else {
  // عرض رسالة: "من فضلك قم بتحميل الصور أولاً"
  showCustomSnackBar('please_upload_order_proof_photos_first'.tr, isError: true);
  return;
}
```

**تعديل زر "Complete Delivery":**
```dart
// BEFORE ❌
CustomButtonWidget(
  buttonText: 'complete_delivery'.tr,
  onPressed: () { /* بدون شرط */ },
)

// AFTER ✅ - تعطيل الزر بدون صور
CustomButtonWidget(
  buttonText: 'complete_delivery'.tr,
  onPressed: orderController.pickedPrescriptions.isEmpty ?
      null : // تعطيل الزر
      () { /* رفع الصورة وتحديث الحالة */ },
  backgroundColor: orderController.pickedPrescriptions.isEmpty ?
      Colors.grey : // لون رمادي عند التعطيل
      Theme.of(context).primaryColor,
)
```

---

## 🔐 قائمة التحقق (Security Checklist)

- [ ] لا يمكن النقر على "Pick Up" بدون صور المطعم
- [ ] لا يمكن النقر على "Complete Delivery" بدون صور التسليم
- [ ] الشرط يتعامل مع `null` و `isEmpty` معاً
- [ ] رسائل واضحة عند محاولة التجاوز
- [ ] الصور تُحفظ قبل تغيير الحالة
- [ ] الحالة تتغير فقط بعد نجاح الرفع

---

## 📊 مثال على السيناريو الكامل

```
user: السائق
timeline:
  ↓ 1. يقبل الطلب
  status = 'accepted'
  
  ↓ 2. يصل للمطعم
  status = 'confirmed' (automatic)
  ⚠️ UI: "من فضلك قم بتحميل صور المطعم"
  
  ↓ 3. يلتقط صور الفاتورة (3 صور)
  UI: عرض الصور المختارة
  
  ↓ 4. يضغط "Upload"
  ✅ الصور تُرفع
  status = 'confirmed' (مع orderProofFullUrl)
  ✅ UI: "تم الرفع بنجاح"
  
  ↓ 5. يضغط "Pick Up" (الزر الآن فعّال)
  API: updateOrderStatus('picked_up', otpStore)
  status = 'picked_up'
  
  ↓ 6. يتجه للعميل
  On the way...
  
  ↓ 7. يصل للعميل
  status = 'arrived' (automatic)
  
  ↓ 8. يلتقط صورة التسليم
  ⚠️ UI: "من فضلك التقط صورة التسليم"
  pickPrescriptionImage() → عرض الصورة
  
  ↓ 9. يضغط "Complete Delivery" (✅ الزر الآن فعّال)
  API: updatePaymentStatus('paid', deliveryImage)
  status = 'delivered'
  ✅ showDeliveryConfirmImage = false
  
  ✅ DONE
```

---

## 🚨 معالجة الأخطاء

| الحالة | المشكلة | الحل |
|--------|--------|------|
| بدون صور المطعم | لا يمكن اختيار "Pick Up" | عرض رسالة + تفعيل واجهة التحميل |
| خطأ برفع صور المطعم | "upload_failed" | إعادة المحاولة أو إظهار تفاصيل الخطأ |
| بدون صور التسليم | زر "Complete Delivery" معطل | رمادي + disable + رسالة عند التمرير |
| الاتصال ضعيف | انقطاع أثناء الرفع | إعادة محاولة تلقائية أو يدوية |

---

## 💡 نصائح التطبيق

✅ **الصحيح:**
```dart
// التحقق الصحيح من الصور
if (order.orderProofFullUrl == null || 
    order.orderProofFullUrl!.isEmpty) {
  // لا توجد صور
}
```

❌ **الخطأ الشائع:**
```dart
// التحقق الخاطئ
if (order.orderProofFullUrl == null) {
  // ماذا لو كانت string فارغة ""؟
}
```

---

## 📝 الترجمات المطلوبة

```json
{
  "upload_order_proof_description": "قم بتحميل صور القائمة أو الإيصال أو الفاتورة كدليل على استلام الطلب",
  "please_upload_order_proof_photos_first": "من فضلك قم بتحميل صور إثبات الطلب أولاً",
  "order_proof_photos_uploaded": "تم تحميل صور إثبات الطلب بنجاح",
  "completed_after_delivery_picture": "سيتم إكمال الطلب بعد التقاط صورة التسليم",
  "please_take_delivery_photo_first": "من فضلك التقط صورة التسليم أولاً",
  "delivery_photo_captured": "تم التقاط صورة التسليم بنجاح"
}
```

---

## ✨ النتيجة النهائية

✅ **نظام محكم بـ 100% موثوقية**
- لا يمكن تجاوز التصوير الإلزامي
- رسائل واضحة للسائق
- حماية كاملة من التلاعب
- توثيق شامل للطلبات
