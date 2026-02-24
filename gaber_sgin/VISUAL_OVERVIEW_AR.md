# 🎨 المخطط المرئي الشامل - Visual Overview

## 📋 نظرة عامة

هذا المستند يحتوي على مخططات مرئية شاملة توضح كيفية عمل التطبيق بشكل بصري.

---

## 🌐 معمارية النظام الكامل

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         منظومة Shella Food                              │
└─────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │              │         │              │         │              │
    │   تطبيق      │         │   تطبيق     │         │   تطبيق     │
    │   العملاء     │         │  المطاعم     │         │  السائقين    │
    │  (Customer)  │         │  (Vendor)    │         │ (Delivery)   │
    │              │         │              │         │  ← أنت هنا   │
    └──────┬───────┘         └──────┬───────┘         └──────┬───────┘
           │                        │                        │
           │  📱 HTTP Requests      │  📱 HTTP Requests      │  📱 HTTP Requests
           │  🔔 Notifications      │  🔔 Notifications      │  🔔 Notifications
           │                        │                        │
           └────────────────────────┼────────────────────────┘
                                    │
                                    ↓
           ┌──────────────────────────────────────────────┐
           │     Backend Server (Laravel)                 │
           │     https://dev.shelafood.com                │
           │                                              │
           │  • REST API                                  │
           │  • Authentication                            │
           │  • Order Management                          │
           │  • Payment Processing                        │
           │  • Location Tracking                         │
           └──────────────┬───────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ↓               ↓               ↓
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │          │   │          │   │          │
    │ Firebase │   │ Database │   │  Google  │
    │   FCM    │   │  MySQL   │   │   Maps   │
    │ (Push)   │   │          │   │   API    │
    │          │   │          │   │          │
    └──────────┘   └──────────┘   └──────────┘
```

---

## 🔄 تدفق البيانات (Data Flow)

### 1. تسجيل الدخول

```
                      تسجيل الدخول
┌────────────────────────────────────────────────────────┐
│                                                        │
│  [السائق]                                             │
│     │                                                  │
│     │ 1. إدخال رقم الهاتف وكلمة المرور                 │
│     ↓                                                  │
│  ┌──────────────┐                                     │
│  │ SignInScreen │                                     │
│  └──────┬───────┘                                     │
│         │ 2. عند الضغط على "دخول"                     │
│         ↓                                              │
│  ┌──────────────────┐                                 │
│  │ AuthController   │                                 │
│  │ .login()         │                                 │
│  └──────┬───────────┘                                 │
│         │ 3. استدعاء AuthService                      │
│         ↓                                              │
│  ┌──────────────────┐                                 │
│  │ AuthService      │                                 │
│  └──────┬───────────┘                                 │
│         │ 4. استدعاء AuthRepository                   │
│         ↓                                              │
│  ┌──────────────────┐                                 │
│  │ AuthRepository   │                                 │
│  └──────┬───────────┘                                 │
│         │ 5. إرسال HTTP Request                       │
│         ↓                                              │
│  ┌────────────────────────────────┐                   │
│  │ POST /api/v1/auth/login        │                   │
│  │ Body: {phone, password}        │                   │
│  └────────────┬───────────────────┘                   │
│               │ 6. الرد من السيرفر                     │
│               ↓                                        │
│  ┌────────────────────────────────┐                   │
│  │ Response: {                    │                   │
│  │   "token": "abc123...",        │                   │
│  │   "topic": "zone_1_dm"         │                   │
│  │ }                              │                   │
│  └────────────┬───────────────────┘                   │
│               │ 7. حفظ التوكن                          │
│               ↓                                        │
│  ┌──────────────────────────┐                         │
│  │ SharedPreferences        │                         │
│  │ .setString("token", ...) │                         │
│  └──────────┬───────────────┘                         │
│             │ 8. الحصول على FCM Token                 │
│             ↓                                          │
│  ┌──────────────────────────────┐                     │
│  │ FirebaseMessaging            │                     │
│  │ .getToken()                  │                     │
│  └──────────┬───────────────────┘                     │
│             │ 9. إرسال FCM Token للسيرفر              │
│             ↓                                          │
│  ┌────────────────────────────────┐                   │
│  │ POST /api/v1/update-fcm-token  │                   │
│  │ Body: {fcm_token: "xyz..."}    │                   │
│  └────────────┬───────────────────┘                   │
│               │ 10. نجح ✅                             │
│               ↓                                        │
│  ┌──────────────────────┐                             │
│  │ الانتقال لـ Dashboard │                             │
│  └──────────────────────┘                             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 2. استلام طلب جديد

```
                    استلام طلب جديد
┌───────────────────────────────────────────────────────┐
│                                                       │
│  [العميل يطلب] → [المطعم يؤكد]                       │
│                        ↓                              │
│               ┌────────────────┐                      │
│               │ Backend        │                      │
│               │ يحدد السائقين  │                      │
│               │ في المنطقة     │                      │
│               └────────┬───────┘                      │
│                        │                              │
│         Firebase Cloud Messaging                      │
│                        ↓                              │
│      ╔═════════════════════════════════╗              │
│      ║  📱 Firebase sends push        ║              │
│      ║     to all matched drivers     ║              │
│      ╚═════════════════════════════════╝              │
│                        │                              │
│          ┌─────────────┼─────────────┐                │
│          │             │             │                │
│     [سائق 1]      [سائق 2]      [أنت]               │
│          │             │             │                │
│          │             │             ↓                │
│          │             │    ┌──────────────────┐      │
│          │             │    │ onMessage.listen │      │
│          │             │    └────────┬─────────┘      │
│          │             │             │                │
│          │             │             ↓                │
│          │             │    ┌──────────────────┐      │
│          │             │    │ NotificationBody│      │
│          │             │    │ {                │      │
│          │             │    │   type: new_order│      │
│          │             │    │   order_id: 123  │      │
│          │             │    │ }                │      │
│          │             │    └────────┬─────────┘      │
│          │             │             │                │
│          │             │             ↓                │
│          │             │    ┌──────────────────┐      │
│          │             │    │ 🔊 تشغيل صوت    │      │
│          │             │    │ 📳 اهتزاز        │      │
│          │             │    └────────┬─────────┘      │
│          │             │             │                │
│          │             │             ↓                │
│          │             │    ┌──────────────────┐      │
│          │             │    │ Show Dialog:     │      │
│          │             │    │ "طلب جديد #123"  │      │
│          │             │    │ [عرض] [تجاهل]    │      │
│          │             │    └──────────────────┘      │
│          │             │                              │
│          │             │  السائق يختار:               │
│          │             │                              │
│   [يتجاهل]      [يتجاهل]         [يقبل] ✅           │
│                                         │             │
│                                         ↓             │
│                              ┌──────────────────┐     │
│                              │ POST /accept     │     │
│                              │ {order_id: 123}  │     │
│                              └────────┬─────────┘     │
│                                       │               │
│                                       ↓               │
│                              ┌──────────────────┐     │
│                              │ Backend:         │     │
│                              │ • يربط الطلب بك  │     │
│                              │ • يحذفه من بقية │     │
│                              │   السائقين       │     │
│                              │ • يرسل إشعار     │     │
│                              │   للعميل         │     │
│                              └────────┬─────────┘     │
│                                       │               │
│                                       ↓               │
│                              ┌──────────────────┐     │
│                              │ تم قبول الطلب ✅  │     │
│                              └──────────────────┘     │
│                                                       │
└───────────────────────────────────────────────────────┘
```

### 3. دورة حياة الطلب الكاملة

```
┌────────────────────────────────────────────────────────────────────┐
│                    Order Lifecycle                                 │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  [PENDING] ────────→ العميل طلب                                   │
│      │                                                              │
│      ↓                                                              │
│  [CONFIRMED] ──────→ المطعم أكد                                    │
│      │                                                              │
│      │ 🔔 Push notification to drivers                            │
│      ↓                                                              │
│  ┌─────────────────────────────────────┐                          │
│  │  AVAILABLE FOR ALL DRIVERS          │                          │
│  │  (يظهر لجميع السائقين في المنطقة)   │                          │
│  └───────────┬─────────────────────────┘                          │
│              │                                                      │
│              │ السائق يقبل ✅                                       │
│              ↓                                                      │
│  [ACCEPTED] ───────→ تم القبول                                    │
│      │                                                              │
│      │ المطعم يبدأ التحضير                                         │
│      ↓                                                              │
│  [PROCESSING] ─────→ جاري التحضير                                 │
│      │                                                              │
│      │ الطلب جاهز                                                  │
│      ↓                                                              │
│  [HANDOVER] ───────→ جاهز للالتقاط                                │
│      │                🔔 إشعار للسائق: "الطلب جاهز"               │
│      │                                                              │
│      │ السائق يلتقط الطلب                                          │
│      ↓                                                              │
│  [PICKED_UP] ──────→ التقط الطلب                                  │
│      │                🔔 إشعار للعميل: "في الطريق إليك"           │
│      │                📍 تتبع مباشر للموقع                         │
│      │                                                              │
│      │ السائق يصل                                                  │
│      ↓                                                              │
│  [ARRIVED] ────────→ وصل السائق                                   │
│      │                🔔 إشعار للعميل: "سائقك وصل"                 │
│      │                                                              │
│      │ تسليم للعميل                                                │
│      ↓                                                              │
│  [DELIVERED] ──────→ تم التسليم ✅                                │
│                      🔔 إشعار للعميل: "شكراً، تم التسليم"          │
│                      💰 إضافة الأرباح للسائق                       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘

     حالات خاصة:
     
     [أي مرحلة] ──→ [CANCELLED] (الإلغاء)
                         ↓
                    تحديث جميع الأطراف
```

---

## 🏗️ Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                    التطبيق (App)                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Presentation Layer - طبقة العرض                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────┐      ┌───────────────────┐             │
│  │   📱 Screens      │      │   🎨 Widgets      │             │
│  │   - UI Layout     │      │   - Reusable      │             │
│  │   - StatefulW.    │      │   - Custom        │             │
│  └─────────┬─────────┘      └─────────┬─────────┘             │
│            │                           │                        │
│            └───────────┬───────────────┘                        │
│                        │                                        │
│            ┌───────────▼─────────────────┐                     │
│            │   🎮 Controllers (GetX)     │                     │
│            │   - State Management        │                     │
│            │   - Business Logic Calls    │                     │
│            │   - update() rebuilds UI    │                     │
│            └───────────┬─────────────────┘                     │
│                        │                                        │
└────────────────────────┼────────────────────────────────────────┘
                         │
                         │ GetX find()
                         │
┌────────────────────────▼────────────────────────────────────────┐
│  Domain Layer - طبقة المنطق                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │  📦 Models (Data Structures)                 │              │
│  │  - OrderModel                                │              │
│  │  - UserModel                                 │              │
│  │  - fromJson() / toJson()                     │              │
│  └──────────────────────────────────────────────┘              │
│                                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │  🔧 Services (Business Logic)                │              │
│  │  - Implements ServiceInterface               │              │
│  │  - Processes data                            │              │
│  │  - Calls Repository methods                  │              │
│  └──────────────┬───────────────────────────────┘              │
│                 │                                               │
│                 │ uses                                          │
│                 ↓                                               │
│  ┌──────────────────────────────────────────────┐              │
│  │  📝 Repository Interfaces                    │              │
│  │  - Pure abstract classes                     │              │
│  │  - Define contracts                          │              │
│  └──────────────────────────────────────────────┘              │
│                                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ implements
                         │
┌────────────────────────▼────────────────────────────────────────┐
│  Data Layer - طبقة البيانات                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │  🗄️ Repository Implementations               │              │
│  │  - Implements RepositoryInterface            │              │
│  │  - Data access logic                         │              │
│  │  - Calls ApiClient                           │              │
│  └──────────────┬───────────────────────────────┘              │
│                 │                                               │
│                 │ uses                                          │
│                 ↓                                               │
│  ┌──────────────────────────────────────────────┐              │
│  │  🌐 ApiClient (HTTP)                         │              │
│  │  - GET, POST, PUT, DELETE                    │              │
│  │  - Headers, Authentication                   │              │
│  │  - Error handling                            │              │
│  └──────────────┬───────────────────────────────┘              │
│                 │                                               │
│                 │ HTTP                                          │
│                 ↓                                               │
│  ┌──────────────────────────────────────────────┐              │
│  │  ☁️ Backend API                              │              │
│  │  https://dev.shelafood.com                   │              │
│  └──────────────────────────────────────────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 GetX State Management Flow

```
┌────────────────────────────────────────────────────────────────┐
│              كيف يعمل GetX State Management                     │
└────────────────────────────────────────────────────────────────┘

    المستخدم يتفاعل مع UI
             │
             ↓
    ┌─────────────────┐
    │  UI Event       │  مثال: onPressed()
    │  (Button Click) │
    └────────┬────────┘
             │
             ↓
    ┌──────────────────────────────────┐
    │  Controller Method Called        │
    │  orderController.getCurrentOrders()│
    └────────┬─────────────────────────┘
             │
             │  1. تغيير الحالة
             ↓
    ┌──────────────────────────────────┐
    │  _isLoading = true               │
    │  update()  ◄── يُعلم UI بالتغيير│
    └────────┬─────────────────────────┘
             │
             │  2. UI rebuilds
             ↓
    ┌──────────────────────────────────┐
    │  UI shows loader                 │
    │  (CircularProgressIndicator)     │
    └──────────────────────────────────┘
             │
             │  3. استدعاء Service
             ↓
    ┌──────────────────────────────────┐
    │  service.getOrders()             │
    │  └─→ repository.getOrders()      │
    │      └─→ apiClient.getData()     │
    └────────┬─────────────────────────┘
             │
             │  4. انتظار الرد
             ↓
    ┌──────────────────────────────────┐
    │  Backend Response                │
    │  {orders: [...]}                 │
    └────────┬─────────────────────────┘
             │
             │  5. تحديث البيانات
             ↓
    ┌──────────────────────────────────┐
    │  _currentOrderList = orders      │
    │  _isLoading = false              │
    │  update()  ◄── يُعلم UI بالتغيير│
    └────────┬─────────────────────────┘
             │
             │  6. UI rebuilds again
             ↓
    ┌──────────────────────────────────┐
    │  UI shows data                   │
    │  ListView with orders            │
    └──────────────────────────────────┘


    الكود:
    
    // في الـ Controller
    Future<void> getCurrentOrders() async {
      _isLoading = true;
      update(); // ← يُعيد بناء كل GetBuilder مرتبط
      
      _currentOrderList = await service.getOrders();
      
      _isLoading = false;
      update(); // ← يُعيد البناء مرة أخرى
    }
    
    // في الـ UI
    GetBuilder<OrderController>(
      builder: (controller) {
        // هذا الجزء يُعاد بناؤه عند كل update()
        if (controller.isLoading) {
          return CircularProgressIndicator();
        }
        return ListView(...);
      }
    )
```

---

## 🔔 Firebase Notifications Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│              Firebase Cloud Messaging Flow                        │
└──────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │  Backend Server  │
                    │  (Laravel)       │
                    └────────┬─────────┘
                             │
                             │ 1. يرسل notification
                             ↓
                    ┌──────────────────┐
                    │  Firebase FCM    │
                    │  Servers         │
                    └────────┬─────────┘
                             │
                             │ 2. يوجّه للجهاز
                             ↓
                ┌────────────────────────────┐
                │  Driver's Phone            │
                └────────────────────────────┘
                             │
               ┌─────────────┼──────────────┐
               │             │              │
               ↓             ↓              ↓
       [App Closed]   [Background]   [Foreground]
               │             │              │
               │             │              │
               ↓             ↓              ↓
    ┌──────────────┐ ┌─────────────┐ ┌──────────────────┐
    │ System تray  │ │ Background  │ │ onMessage.listen │
    │ notification │ │ Handler     │ │ (notification_   │
    │              │ │ (top-level) │ │  helper.dart)    │
    └──────┬───────┘ └──────┬──────┘ └────────┬─────────┘
           │                │                  │
           │ User taps      │ Process in      │ Show local
           │                │ background      │ notification
           ↓                ↓                  │ + update UI
    ┌─────────────┐  ┌──────────────┐        ↓
    │ App Opens   │  │ Save to DB   │  ┌───────────────┐
    │ with data   │  │ (optional)   │  │ Dialog shown  │
    └─────┬───────┘  └──────────────┘  │ Sound played  │
          │                             │ Vibration     │
          │                             └───────────────┘
          ↓
    ┌──────────────────────────────┐
    │ onMessageOpenedApp.listen    │
    │ Navigate to correct screen   │
    └──────────────────────────────┘


    الكود المقابل:

    // main.dart
    void main() async {
      await Firebase.initializeApp();
      
      // Background handler (MUST be top-level)
      FirebaseMessaging.onBackgroundMessage(
        myBackgroundMessageHandler
      );
      
      runApp(MyApp());
    }

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      // App is open, show custom notification
    });

    // User tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Navigate based on notification data
    });
```

---

## 🗺️ Location Tracking System

```
┌──────────────────────────────────────────────────────────────────┐
│                  تتبع الموقع (Location Tracking)                 │
└──────────────────────────────────────────────────────────────────┘

    السائق لديه طلب نشط
             │
             ↓
    ┌─────────────────────┐
    │ startLocationTracking│
    └────────┬────────────┘
             │
             ↓
    ┌──────────────────────────────┐
    │  Timer.periodic(30 seconds)  │ ◄─┐
    └────────┬─────────────────────┘   │
             │                         │
             │ every 30s               │
             ↓                         │
    ┌──────────────────────────────┐   │
    │  Geolocator.getCurrentPosition│  │
    └────────┬─────────────────────┘   │
             │                         │
             │ {lat, lng}              │
             ↓                         │
    ┌──────────────────────────────┐   │
    │  POST /record-location       │   │
    │  Body: {                     │   │
    │    latitude: 24.7136,        │   │
    │    longitude: 46.6753        │   │
    │  }                           │   │
    └────────┬─────────────────────┘   │
             │                         │
             │ Response: OK            │
             ↓                         │
    ┌──────────────────────────────┐   │
    │  Backend saves to DB         │   │
    │  customers_location table    │   │
    └──────────────────────────────┘   │
             │                         │
             └─────────────────────────┘
                    (repeats)


    ┌──────────────────────────────┐
    │  Customer App                │
    │  يرى الموقع المباشر للسائق    │
    └──────────────────────────────┘
             ↑
             │ polls every 5s
             │
    ┌──────────────────────────────┐
    │  GET /driver-location        │
    │  ?order_id=123               │
    └──────────────────────────────┘


    الـ Timer يتوقف عندما:
    • السائق يُسلّم جميع الطلبات
    • السائق يُصبح Offline
    • السائق يُسجّل خروج
```

---

## 🎨 UI Layer Structure

```
┌──────────────────────────────────────────────────────────────────┐
│                    UI Components Hierarchy                        │
└──────────────────────────────────────────────────────────────────┘

                    MyApp (main.dart)
                         │
                         ↓
                  GetMaterialApp
                         │
            ┌────────────┼────────────┐
            │            │            │
            ↓            ↓            ↓
      SplashScreen  DashboardScreen  ...
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ↓              ↓              ↓
      HomeScreen    OrderScreen    ProfileScreen
          │
          ├─ AppBarWidget
          │
          ├─ StatisticsWidget
          │  ├─ TodayEarnings
          │  ├─ TodayOrders
          │  └─ OnlineTime
          │
          ├─ ActiveOrdersWidget
          │  └─ ListView
          │     └─ OrderItemWidget ◄─┐
          │        ├─ OrderInfo        │
          │        ├─ RestaurantInfo   │ Reusable
          │        ├─ StatusBadge      │
          │        └─ ActionButtons    │
          │                           ─┘
          └─ QuickActionsWidget


    GetBuilder Pattern:
    
    Screen (Stateful/Stateless)
        │
        ↓
    GetBuilder<OrderController>(
      builder: (controller) {
        return Widget based on controller.state
      }
    )
    
    • عند controller.update()
    • GetBuilder يُعيد البناء تلقائياً
    • efficient (only rebuilds GetBuilder part)
```

---

## 📊 Database Schema (Backend Reference)

```
┌──────────────────────────────────────────────────────────────────┐
│                  الجداول الرئيسية في قاعدة البيانات              │
└──────────────────────────────────────────────────────────────────┘

orders                          delivery_men
├─ id (PK)                     ├─ id (PK)
├─ customer_id (FK)            ├─ f_name
├─ restaurant_id (FK)          ├─ l_name
├─ delivery_man_id (FK) ───────┼─→ phone
├─ order_amount                ├─ email
├─ order_status                ├─ password
│   • pending                  ├─ identity_type
│   • confirmed                ├─ identity_number
│   • accepted                 ├─ vehicle_id (FK)
│   • processing               ├─ zone_id (FK)
│   • handover                 ├─ active (0/1)
│   • picked_up                ├─ available (0/1)
│   • delivered                ├─ fcm_token
│   • cancelled                ├─ auth_token
├─ payment_method              ├─ earning
├─ delivery_charge             ├─ current_orders
├─ created_at                  └─ created_at
├─ updated_at
├─ delivery_address
└─ customer_contact_no


order_details                   zones
├─ id (PK)                     ├─ id (PK)
├─ order_id (FK)               ├─ name
├─ food_id (FK)                ├─ coordinates (JSON)
├─ quantity                    └─ status
├─ price
└─ add_ons (JSON)


customer_location               conversations
├─ id (PK)                     ├─ id (PK)
├─ user_id (FK)                ├─ sender_id
├─ latitude                    ├─ sender_type
├─ longitude                   │   • delivery_man
├─ type                        │   • customer
│   • customer                 │   • vendor
│   • delivery_man             ├─ receiver_id
└─ created_at                  ├─ receiver_type
                               ├─ last_message_id (FK)
                               └─ unread_message_count

notifications                   messages
├─ id (PK)                     ├─ id (PK)
├─ title                       ├─ conversation_id (FK)
├─ description                 ├─ sender_id
├─ order_id (FK)               ├─ message
├─ image                       ├─ file (attachment)
├─ status (read/unread)        ├─ is_seen (0/1)
└─ created_at                  └─ created_at
```

---

## 🔐 Security & Authentication Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    أمان التطبيق (Security)                        │
└──────────────────────────────────────────────────────────────────┘

    ┌────────────────────────┐
    │  Login Request         │
    │  POST /auth/login      │
    │  {phone, password}     │
    └───────────┬────────────┘
                │
                ↓
    ┌────────────────────────┐
    │  Backend validates     │
    │  • Phone exists?       │
    │  • Password correct?   │
    │  • Account active?     │
    └───────────┬────────────┘
                │
           ┌────┴────┐
           │         │
         Valid    Invalid
           │         │
           ↓         ↓
    ┌──────────┐  ┌────────────┐
    │ Generate │  │ Return 401 │
    │ JWT      │  │ Error      │
    │ Token    │  └────────────┘
    └────┬─────┘
         │
         ↓
    ┌────────────────────────────┐
    │ Return:                    │
    │ {                          │
    │   "token": "eyJ0...",      │
    │   "topic": "zone_1_dm"     │
    │ }                          │
    └───────────┬────────────────┘
                │
                ↓
    ┌────────────────────────────┐
    │ App saves to:              │
    │ SharedPreferences          │
    │ • token → للـ API           │
    │ • topic → للـ FCM           │
    └───────────┬────────────────┘
                │
                ↓
    ┌────────────────────────────┐
    │ All future requests:       │
    │ Headers: {                 │
    │   "Authorization":         │
    │   "Bearer eyJ0..."         │
    │ }                          │
    └────────────────────────────┘


    Token Validation على كل Request:
    
    Request → Backend
                │
                ↓
          ┌─────────────┐
          │ Check Token │
          └──────┬──────┘
                 │
        ┌────────┼────────┐
        │                 │
      Valid           Invalid
        │                 │
        ↓                 ↓
    ┌────────┐      ┌──────────┐
    │Process │      │Return 401│
    │Request │      │Redirect  │
    └────────┘      │to Login  │
                    └──────────┘
```

---

## ⚡ Performance Optimization

```
┌──────────────────────────────────────────────────────────────────┐
│              استراتيجيات تحسين الأداء                            │
└──────────────────────────────────────────────────────────────────┘

1. State Management Optimization
   
   GetBuilder (Efficient)            setState (Less Efficient)
   ├─ Only rebuilds its scope       ├─ Rebuilds entire widget
   ├─ Selective updates             ├─ No granular control
   └─ Memory efficient              └─ More memory usage


2. Image Caching
   
   ┌─────────────────┐
   │ CachedNetworkImage │
   └────────┬──────────┘
            │
      ┌─────┴─────┐
      │           │
   Network     Cache
      │           │
      ↓           ↓
   First      Subsequent
   Load       Loads (Fast!)


3. Lazy Loading Lists
   
   ListView.builder(
     itemCount: orders.length,
     itemBuilder: (context, index) {
       // بناء العناصر فقط عند الظهور
       return OrderItemWidget(orders[index]);
     }
   )
   
   ❌ Don't: ListView(children: orders.map(...).toList())
   ✅ Do: ListView.builder(...)


4. Pagination
   
   ┌────────────────────────────┐
   │ Load first 20 orders       │ Page 1
   └────────────────────────────┘
              │
              │ User scrolls to end
              ↓
   ┌────────────────────────────┐
   │ Load next 20 orders        │ Page 2
   └────────────────────────────┘
              │
              │ And so on...
              ↓


5. Debouncing API Calls
   
   User types in search: "pizza"
   
   ❌ Bad:
   'p' → API Call
   'pi' → API Call
   'piz' → API Call
   'pizz' → API Call
   'pizza' → API Call
   
   ✅ Good (Debounced):
   'p'
   'pi'
   'piz'
   'pizz'
   'pizza' → Wait 500ms → API Call
```

---

## 🎭 Error Handling Strategy

```
┌──────────────────────────────────────────────────────────────────┐
│                    معالجة الأخطاء                                │
└──────────────────────────────────────────────────────────────────┘

                API Request
                     │
                     ↓
            ┌────────────────┐
            │  try { }       │
            └────────┬───────┘
                     │
          ┌──────────┼──────────┐
          │                     │
      Success                 Error
          │                     │
          ↓                     ↓
┌───────────────────┐   ┌──────────────────┐
│ return data       │   │ catch (e) { }    │
└───────────────────┘   └────────┬─────────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
              Network Error  Timeout    Server Error
                    │            │            │
                    ↓            ↓            ↓
            ┌─────────────────────────────────────┐
            │ show error message to user          │
            │ - showCustomSnackBar(message)       │
            │ - log error for debugging           │
            │ - offer retry option                │
            └─────────────────────────────────────┘


مثال في الكود:

Future<void> loadOrders() async {
  try {
    _isLoading = true;
    update();
    
    Response response = await apiClient.getData('/orders');
    
    if (response.statusCode == 200) {
      _orders = parseOrders(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized - redirect to login
      Get.offAllNamed(Routes.LOGIN);
    } else {
      showError('خطأ في تحميل الطلبات');
    }
    
  } on SocketException {
    showError('لا يوجد اتصال بالإنترنت');
  } on TimeoutException {
    showError('انتهت مهلة الاتصال');
  } catch (e) {
    showError('حدث خطأ غير متوقع');
    print('Error: $e');
  } finally {
    _isLoading = false;
    update();
  }
}
```

---

## 📱 Cross-Platform Compilation

```
┌──────────────────────────────────────────────────────────────────┐
│                    Flutter Cross-Platform                         │
└──────────────────────────────────────────────────────────────────┘

        شفرة واحدة (Dart + Flutter)
                    │
                    ↓
            ┌───────────────┐
            │ Flutter Build │
            │   System      │
            └───────┬───────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
        ↓           ↓           ↓
   ┌────────┐  ┌────────┐  ┌────────┐
   │Android │  │   iOS  │  │  Web   │
   │  APK   │  │  .app  │  │  HTML  │
   └────────┘  └────────┘  └────────┘


Platform-Specific Code:

if (GetPlatform.isAndroid) {
  // Android-specific
} else if (GetPlatform.isIOS) {
  // iOS-specific
} else if (GetPlatform.isWeb) {
  // Web-specific
}


Conditional Imports:

import 'package:permission_handler/permission_handler.dart'
    if (dart.library.html) 'package:web_permission_handler/web.dart';
```

---

**النهاية**

هذا المستند يوفر نظرة مرئية شاملة لكيفية عمل التطبيق. استخدمه كمرجع سريع لفهم التدفقات والبنية المعمارية.

**آخر تحديث**: فبراير 2026
**الإصدار**: 1.1.4+18
