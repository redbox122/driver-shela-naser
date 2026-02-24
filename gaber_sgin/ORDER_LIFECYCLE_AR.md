# 🔄 دورة حياة الطلب - Order Lifecycle

## 📋 نظرة عامة

هذا المستند يشرح بالتفصيل دورة حياة الطلب الكاملة من لحظة إنشائه حتى التسليم، وكيف يتفاعل السائق مع كل مرحلة.

---

## 🎯 مراحل الطلب الكاملة

### المخطط التفصيلي
```
┌─────────────────────────────────────────────────────────────────┐
│                      دورة حياة الطلب الكاملة                   │
└─────────────────────────────────────────────────────────────────┘

1. العميل يطلب     →  [PENDING]
                      ↓
2. المطعم يؤكد      →  [CONFIRMED]
                      ↓
3. توفر للسائقين    →  [AVAILABLE FOR DRIVERS]
                      ↓
4. سائق يقبل        →  [ACCEPTED]
                      ↓
5. المطعم يحضر      →  [PROCESSING]
                      ↓
6. الطلب جاهز       →  [HANDOVER]
                      ↓
7. السائق يلتقط     →  [PICKED_UP]
                      ↓
8. في الطريق        →  [ON_THE_WAY]
                      ↓
9. وصل للعميل       →  [ARRIVED]
                      ↓
10. تم التسليم       →  [DELIVERED] ✅
```

---

## 📱 تجربة السائق خطوة بخطوة

### المرحلة 1️⃣: إشعار بطلب جديد

#### ماذا يحدث؟
```
العميل يطلب → المطعم يؤكد → الطلب يُرسل لجميع السائقين في المنطقة
```

#### واجهة السائق
```
┌──────────────────────────┐
│   🔔 طلب جديد متاح!     │
├──────────────────────────┤
│ رقم الطلب: #12345       │
│ المطعم: مطعم الوليمة     │
│ المسافة: 2.5 كم         │
│ القيمة: 45 ريال          │
│                          │
│ [عرض التفاصيل] [تجاهل]  │
└──────────────────────────┘
```

#### البيانات المستلمة في الإشعار
```json
{
  "type": "new_order",
  "order_id": "12345",
  "order_type": "delivery_order",
  "restaurant_name": "مطعم الوليمة",
  "distance": "2.5",
  "amount": "45.00"
}
```

#### الكود المسؤول
```dart
// dashboard_screen.dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['type'] == 'new_order') {
    // عرض نافذة منبثقة
    Get.dialog(NewRequestDialogWidget(
      isRequest: true,
      orderId: int.parse(message.data['order_id']),
      isParcel: message.data['order_type'] == 'parcel_order',
      onTap: () => navigateToOrderRequest()
    ));
    
    // تشغيل صوت التنبيه
    AudioPlayer().play(AssetSource('notification.mp3'));
    
    // اهتزاز
    Vibration.vibrate(duration: 1000);
  }
});
```

---

### المرحلة 2️⃣: عرض الطلبات المتاحة

#### الشاشة الرئيسية
```
┌──────────────────────────────────────┐
│  📋 الطلبات المتاحة (3)             │
├──────────────────────────────────────┤
│                                      │
│  ⭐ طلب #12345                      │
│  🏪 مطعم الوليمة                    │
│  📍 2.5 كم منك                      │
│  💰 45 ريال                         │
│  ⏱️ منذ 2 دقيقة                    │
│  [قبول] [تفاصيل]                    │
│  ────────────────────────────────    │
│                                      │
│  طلب #12346                         │
│  🏪 مطعم النخيل                     │
│  📍 3.1 كم منك                      │
│  💰 67 ريال                         │
│  ⏱️ منذ 5 دقائق                    │
│  [قبول] [تفاصيل]                    │
│  ────────────────────────────────    │
│                                      │
└──────────────────────────────────────┘
```

#### شروط ظهور الطلب للسائق
```dart
// order_filter_service.dart
bool isOrderVisibleForDriver(OrderModel order) {
  // 1. الطلب في المنطقة الصحيحة
  if (order.zoneId != driver.zoneId) return false;
  
  // 2. السائق نشط (Online)
  if (!driver.active) return false;
  
  // 3. السائق لم يتجاهل هذا الطلب
  if (ignoredOrders.contains(order.id)) return false;
  
  // 4. السائق لديه سعة (أقل من طلبين حالياً)
  if (currentOrders.length >= 2) return false;
  
  // 5. الطلب لم يُقبل من سائق آخر بعد
  if (order.deliveryManId != null) return false;
  
  return true;
}
```

---

### المرحلة 3️⃣: قبول الطلب

#### السائق يضغط "قبول"
```dart
// order_controller.dart
Future<void> acceptOrder(int orderId) async {
  // التحقق من السعة
  if (hasReachedMaxCapacity()) {
    showCustomSnackBar('لديك الحد الأقصى من الطلبات (2)');
    return;
  }
  
  _isLoading = true;
  update();
  
  // إرسال طلب القبول للسيرفر
  Response response = await orderServiceInterface.acceptOrder(orderId);
  
  if (response.statusCode == 200) {
    // نجح القبول
    showCustomSnackBar('تم قبول الطلب بنجاح', isError: false);
    
    // تحديث قائمة الطلبات
    getCurrentOrders();
    
    // الانتقال لتفاصيل الطلب
    Get.toNamed(RouteHelper.getOrderDetailsRoute(orderId));
  } else {
    // فشل القبول (ربما سائق آخر قبله أولاً)
    showCustomSnackBar('عذراً، تم قبول الطلب من سائق آخر');
  }
  
  _isLoading = false;
  update();
}
```

#### API Request
```
POST /api/v1/delivery-man/accept-order
Headers: {
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
Body: {
  "order_id": 12345,
  "_method": "put"
}
```

#### ماذا يحدث في Backend؟
1. يتحقق أن الطلب لم يُقبل من سائق آخر
2. يربط الطلب بالسائق (delivery_man_id = driver.id)
3. يغير حالة الطلب إلى `accepted`
4. يرسل إشعار للعميل: "سائق قَبِلَ طلبك"
5. يحذف الطلب من قائمة السائقين الآخرين

---

### المرحلة 4️⃣: المطعم يحضر الطلب

#### الشاشة
```
┌────────────────────────────────────────┐
│  📦 طلب #12345                        │
│  🔄 المطعم يحضر طلبك...              │
├────────────────────────────────────────┤
│                                        │
│  🏪 مطعم الوليمة                      │
│  📍 شارع الملك فهد، الرياض             │
│  📞 +966 50 123 4567                   │
│  ⏱️ الوقت المتوقع: 15 دقيقة           │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │                                  │ │
│  │        🗺️ خريطة الموقع           │ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
│  📋 محتويات الطلب:                    │
│  • برجر كلاسيك × 2                    │
│  • بطاطس كبير × 1                     │
│  • بيبسي × 2                          │
│                                        │
│  [💬 محادثة المطعم]                   │
│  [🗺️ الاتجاهات للمطعم]               │
│                                        │
└────────────────────────────────────────┘
```

#### حالة الطلب في الكود
```dart
order.orderStatus = "processing"
```

#### لا يوجد إجراء مطلوب من السائق
- السائق ينتظر فقط
- يمكنه التواصل مع المطعم إذا لزم الأمر
- يمكنه الاستعداد بالذهاب للمطعم

---

### المرحلة 5️⃣: الطلب جاهز للالتقاط

#### إشعار للسائق
```
┌──────────────────────────┐
│   🎉 الطلب جاهز!        │
├──────────────────────────┤
│ طلب #12345 جاهز         │
│ للالتقاط من مطعم الوليمة │
│                          │
│ [الاتجاهات للمطعم]       │
└──────────────────────────┘
```

#### الشاشة الرئيسية
```
┌────────────────────────────────────────┐
│  📦 طلب #12345                        │
│  ✅ جاهز للالتقاط                     │
├────────────────────────────────────────┤
│                                        │
│  🏪 مطعم الوليمة                      │
│  📍 2.3 كم منك                        │
│  📞 +966 50 123 4567                   │
│                                        │
│  ⚠️ يرجى التقاط الطلب في أقرب وقت     │
│                                        │
│  [🚗 الاتجاهات] [☑️ لقد التقطته]    │
│                                        │
└────────────────────────────────────────┘
```

#### حالة الطلب
```dart
order.orderStatus = "handover" // جاهز للتسليم
```

---

### المرحلة 6️⃣: السائق يلتقط الطلب

#### السائق يضغط "لقد التقطته"
```dart
// order_controller.dart
Future<void> updateOrderStatus(int orderId, String status) async {
  _isLoading = true;
  update();
  
  // إنشاء نموذج التحديث
  UpdateStatusBodyModel body = UpdateStatusBodyModel(
    orderId: orderId,
    status: status, // "picked_up"
    method: 'put'
  );
  
  // إرسال للسيرفر
  Response response = await orderServiceInterface.updateOrderStatus(body);
  
  if (response.statusCode == 200) {
    showCustomSnackBar('تم تحديث حالة الطلب بنجاح', isError: false);
    
    // تحديث البيانات المحلية
    getOrderDetails(orderId);
    getCurrentOrders();
  }
  
  _isLoading = false;
  update();
}
```

#### API Request
```
POST /api/v1/delivery-man/update-order-status
Body: {
  "order_id": 12345,
  "status": "picked_up",
  "_method": "put"
}
```

#### ماذا يحدث؟
1. حالة الطلب → `picked_up`
2. إشعار للعميل: "السائق التقط طلبك، في الطريق إليك"
3. تفعيل تتبع الموقع المباشر
4. بدء حساب الوقت المتوقع للوصول

---

### المرحلة 7️⃣: في الطريق للعميل

#### الشاشة
```
┌────────────────────────────────────────┐
│  🚗 في الطريق للعميل                 │
│  طلب #12345                           │
├────────────────────────────────────────┤
│                                        │
│  👤 العميل: أحمد محمد                 │
│  📍 حي النرجس، الرياض                 │
│  📞 +966 55 987 6543                   │
│  🏠 شقة 15، بناية 3                   │
│  📝 ملاحظة: اتصل عند الوصول           │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │                                  │ │
│  │    🗺️ خريطة مباشرة للموقع       │ │
│  │    الوقت المتوقع: 8 دقائق        │ │
│  │    المسافة: 3.2 كم               │ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
│  💰 المبلغ المطلوب: 45 ريال           │
│  💵 طريقة الدفع: نقداً                │
│                                        │
│  [💬 محادثة العميل]                   │
│  [📞 اتصال بالعميل]                   │
│  [🗺️ الاتجاهات]                      │
│  [✅ لقد وصلت]                        │
│                                        │
└────────────────────────────────────────┘
```

#### تتبع الموقع التلقائي
```dart
// profile_controller.dart
Timer? _locationTimer;

void startLocationRecording() {
  // تسجيل الموقع كل 30 ثانية
  _locationTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
    Position position = await Geolocator.getCurrentPosition();
    
    // إرسال للسيرفر
    await recordLocation(
      latitude: position.latitude,
      longitude: position.longitude
    );
  });
}

Future<void> recordLocation({
  required double latitude,
  required double longitude
}) async {
  await apiClient.postData(
    AppConstants.recordLocationUri,
    {
      'token': getUserToken(),
      'location': [
        {'latitude': latitude, 'longitude': longitude}
      ]
    }
  );
}
```

#### التواصل مع العميل

##### الاتصال الهاتفي
```dart
void callCustomer(String phone) {
  launchUrl(Uri.parse('tel:$phone'));
}
```

##### المحادثة النصية
```dart
// الانتقال لشاشة المحادثة
Get.toNamed(RouteHelper.getChatRoute(
  notificationBody: NotificationBodyModel(
    orderId: order.id,
    type: 'message'
  ),
  user: User(
    id: order.customerId,
    fName: order.customerName,
    phone: order.customerPhone,
    image: order.customerImage
  )
));
```

---

### المرحلة 8️⃣: الوصول للعميل

#### السائق يضغط "لقد وصلت"
```dart
// تحديث الحالة
await updateOrderStatus(orderId, 'arrived');
```

#### إشعار للعميل
```
"سائقك وصل! يرجى استلام طلبك"
```

---

### المرحلة 9️⃣: تسليم الطلب

#### شاشة التأكيد
```
┌────────────────────────────────────────┐
│  ✅ تأكيد التسليم                     │
│  طلب #12345                           │
├────────────────────────────────────────┤
│                                        │
│  هل تم تسليم الطلب للعميل؟            │
│                                        │
│  💰 المبلغ: 45 ريال                   │
│  💵 طريقة الدفع: نقداً                │
│                                        │
│  ☑️ تم استلام المبلغ نقداً            │
│                                        │
│  📸 التقط صورة (اختياري)              │
│  ┌──────────────────┐                 │
│  │                  │                 │
│  │   📷 إضافة صورة  │                 │
│  │                  │                 │
│  └──────────────────┘                 │
│                                        │
│  [⬅️ إلغاء]    [✅ تأكيد التسليم]    │
│                                        │
└────────────────────────────────────────┘
```

#### الكود
```dart
// order_controller.dart
Future<void> updatePaymentStatus({
  required int orderId,
  required String status,
  XFile? proof // صورة إثبات التسليم
}) async {
  _isLoading = true;
  update();
  
  List<MultipartBody> multipartBody = [];
  
  // إضافة الصورة إذا موجودة
  if (proof != null) {
    multipartBody.add(MultipartBody('order_proof', proof));
  }
  
  // البيانات
  Map<String, String> body = {
    'order_id': orderId.toString(),
    'status': status, // 'paid'
    '_method': 'put'
  };
  
  // إرسال
  Response response = await orderServiceInterface.updatePaymentStatus(
    body,
    multipartBody
  );
  
  if (response.statusCode == 200) {
    // نجح التسليم
    showCustomSnackBar('تم تسليم الطلب بنجاح! 🎉', isError: false);
    
    // تحديث الطلب
    await updateOrderStatus(orderId, 'delivered');
    
    // إرسال إشعار للعميل بالتسليم
    await sendDeliveredNotification(orderId);
    
    // تحديث القوائم
    getCurrentOrders();
    getCompletedOrders();
    
    // الرجوع للصفحة الرئيسية
    Get.offAllNamed(RouteHelper.getMainRoute('home'));
  }
  
  _isLoading = false;
  update();
}
```

#### API Request
```
POST /api/v1/delivery-man/update-payment-status
Headers: {
  "Authorization": "Bearer {token}"
}
Body (multipart/form-data): {
  "order_id": 12345,
  "status": "paid",
  "_method": "put",
  "order_proof": <image_file> (optional)
}
```

---

### المرحلة 🔟: الطلب مكتمل

#### رسالة نجاح
```
┌────────────────────────────┐
│       ✅ تم التسليم!       │
├────────────────────────────┤
│                            │
│    🎉 أحسنت!              │
│                            │
│  تم تسليم الطلب بنجاح      │
│  طلب #12345               │
│                            │
│  💰 الأرباح: 5 ريال        │
│  💵 تم إضافتها للمحفظة     │
│                            │
│  [عودة للرئيسية]           │
│                            │
└────────────────────────────┘
```

#### تحديث سجل السائق
```dart
// ماذا يحدث:
1. زيادة عدد الطلبات المكتملة
2. إضافة الأرباح للمحفظة
3. إضافة المبلغ النقدي المحصل لـ "النقد في اليد"
4. إرسال إشعار للعميل بالتسليم
5. حذف الطلب من القائمة الحالية
6. إضافته لقائمة الطلبات المكتملة
```

---

## 🚨 حالات خاصة

### 1. إلغاء الطلب من العميل

#### إشعار للسائق
```json
{
  "type": "order_cancelled",
  "order_id": "12345",
  "reason": "العميل غيّر رأيه"
}
```

#### ماذا يحدث؟
```dart
// حذف الطلب من القائمة
_currentOrderList.removeWhere((order) => order.id == 12345);

// إشعار السائق
showCustomSnackBar('تم إلغاء الطلب #12345 من قبل العميل');

// تحديث عدد الطلبات
update();
```

---

### 2. مشكلة في الطلب

#### السائق يبلغ عن مشكلة
```
┌──────────────────────────────────┐
│  ⚠️ الإبلاغ عن مشكلة           │
├──────────────────────────────────┤
│                                  │
│  اختر نوع المشكلة:               │
│                                  │
│  ⭕ العميل لا يرد                │
│  ⭕ العنوان غير صحيح             │
│  ⭕ العميل رفض الاستلام           │
│  ⭕ الطلب ناقص من المطعم          │
│  ⭕ حادث/طارئ                    │
│  ⭕ أخرى                         │
│                                  │
│  📝 تفاصيل إضافية (اختياري):     │
│  ┌────────────────────────────┐ │
│  │                            │ │
│  └────────────────────────────┘ │
│                                  │
│  [إلغاء]         [إرسال]        │
│                                  │
└──────────────────────────────────┘
```

#### الكود
```dart
Future<void> reportOrderIssue({
  required int orderId,
  required String reason,
  String? details
}) async {
  Response response = await apiClient.postData(
    '/api/v1/delivery-man/report-issue',
    {
      'order_id': orderId,
      'reason': reason,
      'details': details ?? ''
    }
  );
  
  if (response.statusCode == 200) {
    showCustomSnackBar('تم إرسال البلاغ، سيتم التواصل معك');
    
    // إرسال للإدارة
    // تعليق الطلب مؤقتاً
  }
}
```

---

### 3. طلبان متزامنان

#### الشاشة الرئيسية
```
┌────────────────────────────────────────┐
│  📋 طلباتي الحالية (2/2) 🔴           │
├────────────────────────────────────────┤
│                                        │
│  ⭐ طلب #12345 (أولوية)               │
│  🏪 مطعم الوليمة                      │
│  📍 في الطريق للعميل                  │
│  ⏱️ متبقي: 8 دقائق                    │
│  [تفاصيل]                              │
│  ────────────────────────────────      │
│                                        │
│  طلب #12346                           │
│  🏪 مطعم النخيل                       │
│  📍 جاهز للالتقاط                     │
│  ⏱️ انتظار                            │
│  [تفاصيل]                              │
│                                        │
│  ⚠️ لن تستلم طلبات جديدة حتى تسلم أحد │
│     الطلبين الحاليين                  │
│                                        │
└────────────────────────────────────────┘
```

#### ترتيب الأولويات
```dart
// order_helper.dart
static List<OrderModel> sortOrdersByPriority(List<OrderModel> orders) {
  return orders..sort((a, b) {
    int priorityA = getOrderPriority(a);
    int priorityB = getOrderPriority(b);
    return priorityA.compareTo(priorityB);
  });
}

static int getOrderPriority(OrderModel order) {
  // أولوية 1 = أعلى (يجب التركيز عليه)
  // أولوية 3 = أقل
  
  switch(order.orderStatus?.toLowerCase()) {
    case 'picked_up':  // لديك الطلب، يجب التوصيل أولاً
      return 1;
      
    case 'handover':   // جاهز للالتقاط، اذهب الآن
      return 2;
      
    case 'accepted':   // مقبول، انتظر المطعم
    case 'confirmed':
    case 'processing':
      return 3;
      
    default:
      return 4;
  }
}
```

---

## 📊 إحصائيات وتقارير

### سجل الطلبات المكتملة
```
┌────────────────────────────────────────┐
│  📈 طلباتي المكتملة                   │
├────────────────────────────────────────┤
│                                        │
│  اليوم: 12 طلب - 60 ريال              │
│  ────────────────────────────────      │
│                                        │
│  ✅ طلب #12345 - 5 ريال               │
│     15:30 - مطعم الوليمة               │
│                                        │
│  ✅ طلب #12344 - 4 ريال               │
│     14:45 - مطعم النخيل                │
│                                        │
│  ✅ طلب #12343 - 6 ريال               │
│     13:20 - مقهى الروشن                │
│                                        │
│  [عرض المزيد]                          │
│                                        │
└────────────────────────────────────────┘
```

---

## 🎯 نصائح للسائقين

### ⚡ لزيادة الكفاءة

1. **قبول الطلبات بسرعة**: الطلب يُعرض على عدة سائقين، أول من يقبل يحصل عليه

2. **إدارة طلبين في نفس الوقت**:
   - اقبل طلبًا ثانيًا إذا كان:
     - في نفس المنطقة
     - بعد الانتهاء من التقاط الطلب الأول
   - رتب الأولويات بذكاء

3. **التواصل الفعال**:
   - اتصل بالعميل عند التأخير
   - تواصل مع المطعم إذا كان الطلب يتأخر

4. **استخدم الخرائط**:
   - دائماً افتح الاتجاهات من التطبيق
   - تابع موقعك المباشر

5. **كن نشطاً في الأوقات المزدحمة**:
   - وقت الغداء (12-2 ظهراً)
   - وقت العشاء (7-10 مساءً)
   - عطل نهاية الأسبوع

---

## 🔐 الأمان والخصوصية

### بيانات العميل المحمية
- رقم الهاتف **لا يُعرض** إلا بعد قبول الطلب
- العنوان الدقيق **لا يظهر** إلا بعد التقاط الطلب
- بيانات العميل **تُحذف** بعد 7 أيام من التسليم

### تتبع الموقع
- يُفعّل **فقط** عند وجود طلب نشط
- يتوقف تلقائياً عند تسليم جميع الطلبات
- لا يُسجّل **أبداً** خارج أوقات العمل

---

**آخر تحديث**: فبراير 2026
**الإصدار**: 1.1.4+18
