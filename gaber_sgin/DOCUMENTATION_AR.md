# 📱 توثيق تطبيق منفذي الخدمات - Shella Food Delivery

## 📋 نظرة عامة على المشروع

### ما هو التطبيق؟
**تطبيق منفذي الخدمات (Delivery Men App)** هو تطبيق مخصص لسائقي التوصيل لإدارة طلبات التوصيل من المطاعم والمتاجر للعملاء. التطبيق جزء من منظومة متكاملة لتوصيل الطعام تتضمن:
- تطبيق العملاء (Customer App)
- تطبيق المطاعم/المتاجر (Vendor App)
- **تطبيق السائقين (Delivery Men App)** ← هذا التطبيق

### المعلومات الأساسية
- **اسم التطبيق**: منفذي الخدمات (Shella Food Delivery)
- **الإصدار**: 1.1.4+18
- **الإصدار البرمجي**: 2.8
- **النظام الأساسي**: Flutter
- **الخلفية (Backend)**: https://dev.shelafood.com
- **مشروع Firebase**: shella1

---

## 🎯 الوظائف الرئيسية للتطبيق

### 1. إدارة الطلبات 📦
- **استلام طلبات جديدة**: السائق يستلم إشعارات بطلبات جديدة متاحة في منطقته
- **قبول/رفض الطلبات**: يمكن للسائق قبول أو رفض الطلبات المعروضة
- **إدارة متعددة**: يمكن للسائق إدارة طلبين كحد أقصى في نفس الوقت
- **ترتيب حسب الأولوية**: الطلبات تُرتب تلقائياً حسب الأولوية (الطلبات المؤكدة أولاً)

### 2. تتبع حالة الطلب 🔄
الطلب يمر بعدة مراحل:
```
طلب جديد → مقبول → معالجة → جاهز → التقاط → في الطريق → تسليم
```

**الحالات بالتفصيل:**
- `pending`: طلب جديد معلق
- `confirmed`: طلب مؤكد من المطعم
- `accepted`: السائق قبل الطلب
- `processing`: المطعم يحضر الطلب
- `handover`: الطلب جاهز للتسليم
- `picked_up`: السائق التقط الطلب من المطعم
- `delivered`: تم التسليم للعميل
- `canceled`: الطلب ملغي

### 3. الملاحة والخرائط 🗺️
- **تتبع الموقع الحي**: تسجيل موقع السائق كل فترة وإرساله للسيرفر
- **خريطة جوجل**: عرض موقع المطعم والعميل على الخريطة
- **مسارات التوصيل**: إظهار الاتجاهات من المطعم للعميل
- **Geocoding**: تحويل العناوين إلى إحداثيات والعكس

### 4. الإشعارات الفورية 🔔
- **Firebase Cloud Messaging**: إشعارات فورية للطلبات الجديدة
- **إشعارات محلية**: تنبيهات صوتية عند وصول طلب جديد
- **أنواع الإشعارات**:
  - طلب جديد متاح (new_order)
  - طلب معين لك (assigned)
  - رسالة من العميل (message)
  - تحديث حالة طلب (order_status)
  - إشعارات عامة (general)

### 5. المحادثات 💬
- **محادثة مع العميل**: تواصل مباشر مع العميل لكل طلب
- **محادثة مع المطعم**: تواصل مع المطعم إذا لزم الأمر
- **WebSocket**: نظام محادثات فورية real-time

### 6. المحفظة والأرباح 💰
- **النقد في اليد (Cash in Hand)**: متابعة المبالغ النقدية المحصلة
- **سجل المعاملات**: عرض سجل الأرباح والتحويلات
- **طرق السحب (Disbursement)**: إدارة طرق سحب الأرباح
- **الدفعات**: نظام الدفع الإلكتروني

### 7. الملف الشخصي 👤
- **معلومات السائق**: الاسم، الصورة، رقم الهاتف
- **حالة النشاط**: تفعيل/إيقاف استقبال الطلبات
- **تحديث البيانات**: تعديل المعلومات الشخصية
- **السجل**: متابعة الطلبات المكتملة

---

## 🏗️ البنية المعمارية

### هيكل المشروع (Clean Architecture)

```
lib/
├── api/                      # طبقة الاتصال بالـ API
│   ├── api_client.dart       # عميل HTTP للطلبات
│   └── api_checker.dart      # فحص الأخطاء والاستجابات
│
├── common/                   # مكونات مشتركة
│   ├── controllers/          # Controllers مشتركة (Theme)
│   ├── models/              # نماذج مشتركة
│   ├── services/            # خدمات مشتركة
│   └── widgets/             # واجهات مشتركة
│
├── features/                # الميزات الرئيسية (Feature-First)
│   ├── auth/               # المصادقة والتسجيل
│   │   ├── controllers/    # منطق العمل
│   │   ├── domain/         # النماذج والخدمات
│   │   └── screens/        # واجهات المستخدم
│   │
│   ├── order/              # إدارة الطلبات
│   │   ├── controllers/    
│   │   ├── domain/
│   │   │   ├── models/     # Order, OrderDetails
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   └── screens/
│   │
│   ├── dashboard/          # الصفحة الرئيسية
│   ├── home/               # شاشة البداية
│   ├── profile/            # الملف الشخصي
│   ├── notification/       # الإشعارات
│   ├── chat/               # المحادثات
│   ├── address/            # العناوين
│   ├── cash_in_hand/       # النقد والأرباح
│   ├── disbursement/       # السحب
│   ├── language/           # اللغات
│   ├── splash/             # شاشة البداية
│   ├── forgot_password/    # استعادة كلمة المرور
│   ├── html/               # صفحات HTML (شروط، خصوصية)
│   └── update/             # تحديث التطبيق
│
├── helper/                  # مساعدات
│   ├── get_di.dart         # Dependency Injection
│   ├── route_helper.dart   # إدارة المسارات
│   ├── notification_helper.dart  # معالجة الإشعارات
│   └── order_helper.dart   # مساعدات الطلبات
│
├── theme/                   # السمات
│   ├── dark_theme.dart
│   └── light_theme.dart
│
├── util/                    # أدوات مساعدة
│   ├── app_constants.dart  # الثوابت والـ API endpoints
│   ├── dimensions.dart     # الأبعاد والمقاسات
│   ├── images.dart         # مسارات الصور
│   ├── messages.dart       # الترجمات
│   └── styles.dart         # التنسيقات
│
├── firebase_options.dart   # إعدادات Firebase
└── main.dart               # نقطة البداية

```

### أنماط البرمجة المستخدمة

#### 1. **GetX State Management**
```dart
class OrderController extends GetxController {
  // State management باستخدام GetX
  List<OrderModel>? _currentOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;
  
  void updateOrders() {
    _currentOrderList = newOrders;
    update(); // تحديث واجهة المستخدم
  }
}
```

#### 2. **Repository Pattern**
```dart
// Repository Interface
abstract class OrderRepositoryInterface {
  Future<List<OrderModel>?> getList();
}

// Repository Implementation
class OrderRepository implements OrderRepositoryInterface {
  @override
  Future<List<OrderModel>?> getList() async {
    // استدعاء API وإرجاع البيانات
  }
}
```

#### 3. **Service Layer**
```dart
// Service Interface
abstract class OrderServiceInterface {
  Future<List<OrderModel>?> getOrderList();
}

// Service Implementation
class OrderService implements OrderServiceInterface {
  final OrderRepositoryInterface repository;
  
  @override
  Future<List<OrderModel>?> getOrderList() {
    return repository.getList();
  }
}
```

---

## 🔐 نظام المصادقة والأمان

### 1. تسجيل الدخول
```dart
// المسار: lib/features/auth/controllers/auth_controller.dart

Future<ResponseModel> login(String phone, String password) async {
  Response response = await authServiceInterface.login(phone, password);
  if (response.statusCode == 200) {
    // حفظ التوكن
    authServiceInterface.saveUserToken(
      response.body['token'], 
      response.body['topic']
    );
    // تحديث FCM Token
    await authServiceInterface.updateToken();
  }
}
```

### 2. التوكن (Token)
- **نوع التوكن**: Bearer Token
- **التخزين**: SharedPreferences
- **الاستخدام**: يُرسل في header كل طلب API
```dart
Authorization: Bearer {token}
```

### 3. FCM Token للإشعارات
```dart
// الحصول على FCM Token
String? fcmToken = await FirebaseMessaging.instance.getToken();

// إرسال التوكن للسيرفر
await apiClient.postData(
  AppConstants.tokenUri,
  {"_method": "put", "fcm_token": fcmToken}
);
```

---

## 📡 التواصل مع الخلفية (Backend API)

### Base URL
```
https://dev.shelafood.com
```

### أهم الـ API Endpoints

#### 1. المصادقة
- `POST /api/v1/auth/delivery-man/login` - تسجيل الدخول
- `POST /api/v1/auth/delivery-man/store` - تسجيل حساب جديد
- `POST /api/v1/auth/delivery-man/forgot-password` - نسيت كلمة المرور
- `POST /api/v1/auth/delivery-man/reset-password` - إعادة تعيين كلمة المرور

#### 2. الطلبات
- `GET /api/v1/delivery-man/current-orders?token={token}` - الطلبات الحالية
- `GET /api/v1/delivery-man/latest-orders?token={token}` - آخر الطلبات
- `GET /api/v1/delivery-man/all-orders` - جميع الطلبات
- `GET /api/v1/delivery-man/order-details?token={token}&order_id={id}` - تفاصيل طلب
- `POST /api/v1/delivery-man/accept-order` - قبول طلب
- `POST /api/v1/delivery-man/update-order-status` - تحديث حالة طلب
- `POST /api/v1/delivery-man/update-payment-status` - تحديث حالة الدفع

#### 3. الملف الشخصي
- `GET /api/v1/delivery-man/profile?token={token}` - بيانات السائق
- `POST /api/v1/delivery-man/update-profile` - تحديث البيانات
- `PUT /api/v1/delivery-man/update-active-status` - تغيير حالة النشاط

#### 4. الموقع
- `POST /api/v1/delivery-man/record-location-data` - تسجيل الموقع

#### 5. الإشعارات
- `GET /api/v1/delivery-man/notifications?token={token}` - قائمة الإشعارات
- `POST /api/v1/delivery-man/update-fcm-token` - تحديث FCM Token

#### 6. المحفظة
- `GET /api/v1/delivery-man/wallet` - بيانات المحفظة
- `GET /api/v1/delivery-man/transactions` - سجل المعاملات

### مثال: طلب API
```dart
// في api_client.dart
Future<Response> getData(String uri) async {
  try {
    Response response = await http.get(
      Uri.parse(appBaseUrl + uri),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );
    return handleResponse(response);
  } catch (e) {
    return Response(statusCode: 1, statusText: e.toString());
  }
}
```

---

## 🔔 نظام الإشعارات (Firebase Cloud Messaging)

### البنية الأساسية

#### 1. تهيئة Firebase
```dart
// في main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// تهيئة الإشعارات المحلية
await NotificationHelper.initialize(flutterLocalNotificationsPlugin);

// تسجيل معالج الخلفية
FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
```

#### 2. أنواع الإشعارات

##### أ. إشعارات الطلبات الجديدة
```json
{
  "type": "new_order" | "order_request",
  "order_id": "123",
  "order_type": "delivery_order" | "parcel_order"
}
```

##### ب. طلب معين للسائق
```json
{
  "type": "assign",
  "order_id": "123",
  "order_type": "delivery_order"
}
```

##### ج. تحديث حالة طلب
```json
{
  "type": "order_status",
  "order_id": "123",
  "status": "confirmed" | "processing" | "delivered"
}
```

##### د. رسالة محادثة
```json
{
  "type": "message",
  "conversation_id": "456",
  "order_id": "123"
}
```

#### 3. معالجة الإشعارات

##### في المقدمة (Foreground)
```dart
// notification_helper.dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  String? type = message.data['type'];
  
  switch(type) {
    case 'message':
      // تحديث شاشة المحادثة إذا كانت مفتوحة
      break;
    case 'order_status':
      // عرض إشعار محلي
      showNotification(message);
      // تحديث قائمة الطلبات
      Get.find<OrderController>().getCurrentOrders();
      break;
    case 'new_order':
      // عرض نافذة منبثقة
      // تشغيل صوت التنبيه
      break;
  }
});
```

##### في الخلفية (Background)
```dart
@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // معالجة الإشعار في الخلفية
}
```

##### عند النقر على الإشعار
```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  String? type = message.data['type'];
  int? orderId = int.parse(message.data['order_id']);
  
  if (type == 'order_status') {
    // الانتقال لصفحة تفاصيل الطلب
    Get.toNamed(RouteHelper.getOrderDetailsRoute(orderId));
  } else if (type == 'message') {
    // الانتقال لصفحة المحادثة
    Get.toNamed(RouteHelper.getChatRoute(...));
  }
});
```

#### 4. موضوعات الإشعارات (Topics)
```dart
// الاشتراك في موضوع عام لجميع السائقين
await FirebaseMessaging.instance.subscribeToTopic('all_zone_delivery_man');

// الاشتراك في موضوع خاص بالمنطقة
await FirebaseMessaging.instance.subscribeToTopic('zone_${zoneId}_delivery_man');
```

---

## 🗺️ نظام التتبع والخرائط

### 1. تتبع موقع السائق
```dart
// في profile_controller.dart
void recordLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high
  );
  
  // إرسال الموقع للسيرفر كل فترة
  await profileServiceInterface.recordLocation(
    latitude: position.latitude,
    longitude: position.longitude
  );
}
```

### 2. عرض الخريطة
```dart
// استخدام Google Maps
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(latitude, longitude),
    zoom: 15
  ),
  markers: {
    // موقع المطعم
    Marker(
      markerId: MarkerId('restaurant'),
      position: LatLng(restaurantLat, restaurantLng)
    ),
    // موقع العميل
    Marker(
      markerId: MarkerId('customer'),
      position: LatLng(customerLat, customerLng)
    )
  }
)
```

### 3. الملاحة
```dart
// فتح تطبيق الخرائط للملاحة
String url = 'https://www.google.com/maps/dir/?api=1'
    '&origin=$currentLat,$currentLng'
    '&destination=$destLat,$destLng';
    
await launchUrl(Uri.parse(url));
```

---

## 💾 التخزين المحلي

### SharedPreferences
يستخدم لتخزين:
- توكن المستخدم
- معلومات تسجيل الدخول (إذا تم اختيار "تذكرني")
- إعدادات اللغة
- إعدادات الثيم (فاتح/داكن)
- حالة الإشعارات

```dart
// حفظ التوكن
await sharedPreferences.setString(AppConstants.token, token);

// قراءة التوكن
String? token = sharedPreferences.getString(AppConstants.token);

// حذف التوكن (تسجيل خروج)
await sharedPreferences.remove(AppConstants.token);
```

---

## 🌐 نظام اللغات (Localization)

### اللغات المدعومة
1. **العربية** (ar) - assets/language/ar.json
2. **الإنجليزية** (en) - assets/language/en.json
3. **البنغالية** (bn) - assets/language/bn.json
4. **الإسبانية** (es) - assets/language/es.json

### استخدام الترجمة
```dart
// في الكود
Text('key'.tr)

// مثال
Text('welcome'.tr)
Text('new_order'.tr)
```

### إضافة لغة جديدة
1. إنشاء ملف JSON جديد في `assets/language/`
2. إضافة اللغة في `app_constants.dart`:
```dart
static List<LanguageModel> languages = [
  LanguageModel(languageCode: 'ar', countryCode: 'SA'),
  LanguageModel(languageCode: 'en', countryCode: 'US'),
  // لغة جديدة
];
```

---

## 🎨 نظام الثيمات (Themes)

### الثيم الفاتح (Light Theme)
```dart
// theme/light_theme.dart
ThemeData lightTheme = ThemeData(
  primaryColor: Color(0xFF1455AC),
  brightness: Brightness.light,
  // ...
);
```

### الثيم الداكن (Dark Theme)
```dart
// theme/dark_theme.dart
ThemeData darkTheme = ThemeData(
  primaryColor: Color(0xFF1455AC),
  brightness: Brightness.dark,
  // ...
);
```

### التبديل بين الثيمات
```dart
Get.find<ThemeController>().toggleTheme();
```

---

## 📱 التشغيل والبناء

### المتطلبات
- Flutter SDK 3.4.0 أو أحدث
- Dart SDK متوافق
- Android Studio / Xcode
- حساب Firebase

### تشغيل التطبيق

#### على المحاكي/جهاز
```bash
# تحميل التبعيات
flutter pub get

# التشغيل
flutter run

# التشغيل بوضع الإصدار
flutter run --release
```

#### على الويب
```bash
flutter run -d chrome
```

### بناء التطبيق

#### Android (APK)
```bash
flutter build apk --release
```

#### Android (App Bundle)
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

---

## 🔧 الإعدادات والتكوين

### 1. إعدادات Firebase
```dart
// firebase_options.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '...',
  appId: '...',
  messagingSenderId: '...',
  projectId: 'shella1',
);
```

### 2. إعدادات Android
```groovy
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.shellafood.deliveryman_app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 3. الأذونات

#### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

#### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج موقعك لتتبع عملية التوصيل</string>
<key>NSCameraUsageDescription</key>
<string>نحتاج الكاميرا لالتقاط صور الطلبات</string>
```

---

## 🐛 استكشاف الأخطاء

### المشاكل الشائعة

#### 1. الإشعارات لا تعمل
- تحقق من إعداد Firebase
- تحقق من FCM Token
- تحقق من الأذونات

#### 2. الخريطة لا تظهر
- تحقق من Google Maps API Key
- تحقق من أذونات الموقع

#### 3. مشاكل تسجيل الدخول
- تحقق من الاتصال بالإنترنت
- تحقق من بيانات الدخول
- تحقق من Backend URL

---

## 📊 إحصائيات المشروع

### حجم الكود
- **إجمالي الملفات**: 200+ ملف
- **أسطر الكود**: 15,000+ سطر
- **Features**: 14 ميزة رئيسية

### التبعيات الرئيسية
- **GetX**: 4.6.6 - إدارة الحالة والتوجيه
- **Firebase**: Core + Messaging للإشعارات
- **Google Maps**: 2.0.6 للخرائط
- **HTTP**: 1.2.1 للاتصال بالـ API
- **Shared Preferences**: 2.0.6 للتخزين
- **Image Picker**: 1.0.7 لالتقاط الصور

---

## 🔐 الأمان وأفضل الممارسات

### 1. حماية التوكن
- التوكن يُخزن بشكل آمن في SharedPreferences
- يُرسل فقط عبر HTTPS
- يُحدث عند كل تسجيل دخول

### 2. التحقق من الصلاحيات
- كل API request يتطلب توكن صالح
- السيرفر يتحقق من صلاحية التوكن

### 3. حماية البيانات الحساسة
- كلمات المرور لا تُخزن محلياً
- بيانات المحفظة مشفرة في النقل

---

## 📞 الدعم والمساعدة

### روابط مهمة
- **Backend URL**: https://dev.shelafood.com
- **Firebase Console**: https://console.firebase.google.com/project/shella1

### للمطورين
- راجع ملفات التوثيق الإضافية:
  - `API_DOCUMENTATION_REPORT.md` - توثيق الـ API
  - `FIREBASE_NOTIFICATION_VERIFICATION_REPORT.md` - الإشعارات
  - `notifications.md` - قائمة الإشعارات

---

## 🚀 خارطة الطريق المستقبلية

### التحسينات المخططة
1. إضافة دعم لتوصيل متعدد (Multi-Drop)
2. تحسين خوارزمية المسارات
3. إضافة نظام التقييمات والمراجعات
4. تحسين واجهة المحادثات
5. إضافة وضع Offline
6. تحسين استهلاك البطارية

---

**آخر تحديث**: فبراير 2026
**الإصدار**: 1.1.4+18
