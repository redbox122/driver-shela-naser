# 🏗️ الدليل التقني للمطورين - Technical Guide

## 📋 نظرة عامة

هذا الدليل مخصص للمطورين الذين يريدون فهم البنية التقنية للتطبيق بعمق وكيفية التعديل عليه والإضافة إليه.

---

## 🎯 البنية المعمارية (Architecture)

### النمط المستخدم: Clean Architecture + Feature-First

```
┌──────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Screens (UI) + Widgets                              │   │
│  │  - order_details_screen.dart                         │   │
│  │  - order_screen.dart                                 │   │
│  └───────────────────┬──────────────────────────────────┘   │
│                      │ GetX Controllers                      │
│                      ↓                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Controllers (State Management)                      │   │
│  │  - OrderController extends GetxController            │   │
│  │  - update() → rebuilds UI                            │   │
│  └───────────────────┬──────────────────────────────────┘   │
└──────────────────────┼──────────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────────┐
│                      ↓   Domain Layer                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Services (Business Logic)                           │   │
│  │  - OrderService implements OrderServiceInterface     │   │
│  └───────────────────┬──────────────────────────────────┘   │
│                      │                                        │
│                      ↓                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Models (Data Structures)                            │   │
│  │  - OrderModel                                        │   │
│  │  - OrderDetailsModel                                 │   │
│  └───────────────────┬──────────────────────────────────┘   │
└──────────────────────┼──────────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────────┐
│                      ↓   Data Layer                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Repositories (Data Access)                          │   │
│  │  - OrderRepository implements Interface              │   │
│  └───────────────────┬──────────────────────────────────┘   │
│                      │                                        │
│                      ↓                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  API Client (HTTP Communication)                     │   │
│  │  - ApiClient (GET, POST, PUT, DELETE)                │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

## 📦 Feature: Order (مثال عملي)

### هيكل الملفات الكامل

```
lib/features/order/
├── controllers/
│   └── order_controller.dart          # State Management
│
├── domain/
│   ├── models/
│   │   ├── order_model.dart           # نموذج الطلب
│   │   ├── order_details_model.dart   # تفاصيل الطلب
│   │   ├── update_status_body_model.dart
│   │   ├── ignore_model.dart
│   │   └── order_cancellation_body.dart
│   │
│   ├── repositories/
│   │   ├── order_repository_interface.dart
│   │   └── order_repository.dart      # تطبيق الـ Repository
│   │
│   └── services/
│       ├── order_service_interface.dart
│       └── order_service.dart         # منطق الأعمال
│
├── screens/
│   ├── order_screen.dart              # قائمة الطلبات
│   ├── order_details_screen.dart      # تفاصيل طلب
│   ├── order_request_screen.dart      # الطلبات المتاحة
│   ├── running_order_screen.dart      # الطلبات الجارية
│   └── filtered_orders_screen.dart    # طلبات مفلترة
│
└── widgets/
    ├── order_item_widget.dart         # عنصر في القائمة
    ├── order_info_widget.dart
    └── order_status_widget.dart
```

---

## 🔄 Flow: كيف تعمل الطلبات؟

### 1. عرض الطلبات

#### الخطوة 1: الواجهة (Screen)
```dart
// order_screen.dart
class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // طلب البيانات عند فتح الشاشة
    Get.find<OrderController>().getCurrentOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلباتي')),
      body: GetBuilder<OrderController>(
        builder: (orderController) {
          // إذا جاري التحميل
          if (orderController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // إذا لا توجد طلبات
          if (orderController.currentOrderList == null ||
              orderController.currentOrderList!.isEmpty) {
            return Center(child: Text('لا توجد طلبات'));
          }
          
          // عرض قائمة الطلبات
          return ListView.builder(
            itemCount: orderController.currentOrderList!.length,
            itemBuilder: (context, index) {
              OrderModel order = orderController.currentOrderList![index];
              return OrderItemWidget(order: order);
            }
          );
        }
      )
    );
  }
}
```

#### الخطوة 2: الـ Controller
```dart
// order_controller.dart
class OrderController extends GetxController {
  final OrderServiceInterface orderServiceInterface;
  
  List<OrderModel>? _currentOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getCurrentOrders() async {
    _isLoading = true;
    update(); // تحديث UI (يُظهر loader)
    
    // استدعاء الـ Service
    List<OrderModel>? orders = 
        await orderServiceInterface.getCurrentOrderList();
    
    if (orders != null) {
      _currentOrderList = orders;
    }
    
    _isLoading = false;
    update(); // تحديث UI (يُظهر البيانات)
  }
}
```

#### الخطوة 3: الـ Service
```dart
// order_service.dart
class OrderService implements OrderServiceInterface {
  final OrderRepositoryInterface orderRepositoryInterface;
  
  OrderService({required this.orderRepositoryInterface});

  @override
  Future<List<OrderModel>?> getCurrentOrderList() async {
    // ببساطة يستدعي Repository
    return await orderRepositoryInterface.getCurrentOrderList();
  }
}
```

#### الخطوة 4: الـ Repository
```dart
// order_repository.dart
class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  
  @override
  Future<List<OrderModel>?> getCurrentOrderList() async {
    // الحصول على التوكن
    String token = _getUserToken();
    
    // استدعاء API
    Response response = await apiClient.getData(
      '${AppConstants.currentOrdersUri}$token'
    );
    
    // معالجة الرد
    if (response.statusCode == 200) {
      List<OrderModel> orders = [];
      
      // تحويل JSON إلى Objects
      response.body.forEach((orderJson) {
        orders.add(OrderModel.fromJson(orderJson));
      });
      
      return orders;
    }
    
    return null;
  }
  
  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? '';
  }
}
```

#### الخطوة 5: API Client
```dart
// api_client.dart
class ApiClient {
  final String appBaseUrl = AppConstants.baseUrl;
  
  Future<Response> getData(String uri) async {
    try {
      // بناء الـ URL الكامل
      String url = appBaseUrl + uri;
      
      // الحصول على التوكن
      String? token = _getToken();
      
      // إرسال الطلب
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token'
        }
      );
      
      return handleResponse(response);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
  
  Response handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      body = response.body;
    }
    
    Response finalResponse = Response(
      body: body,
      bodyString: response.body,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase
    );
    
    // معالجة الأخطاء
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return finalResponse;
    } else {
      return finalResponse;
    }
  }
}
```

---

## 🎯 GetX Dependency Injection

### التسجيل (Registration)

```dart
// helper/get_di.dart
Future<Map<String, Map<String, String>>> init() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  
  // API Client
  Get.lazyPut(() => ApiClient(
    appBaseUrl: AppConstants.baseUrl,
    sharedPreferences: Get.find()
  ));
  
  // Repositories
  Get.lazyPut<OrderRepositoryInterface>(() => OrderRepository(
    apiClient: Get.find(),
    sharedPreferences: Get.find()
  ));
  
  // Services
  Get.lazyPut<OrderServiceInterface>(() => OrderService(
    orderRepositoryInterface: Get.find()
  ));
  
  // Controllers
  Get.lazyPut(() => OrderController(
    orderServiceInterface: Get.find()
  ));
  
  return {};
}
```

### الاستخدام (Usage)

```dart
// في أي مكان في التطبيق
OrderController orderController = Get.find<OrderController>();

// أو مباشرة
Get.find<OrderController>().getCurrentOrders();
```

---

## 🔔 نظام الإشعارات بالتفصيل

### 1. تهيئة Firebase

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // تهيئة الإشعارات المحلية
  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  
  // تسجيل معالج الخلفية (MUST be top-level function)
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  
  runApp(MyApp());
}

// معالج الخلفية (Top-Level Function)
@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  print("Background Message: ${message.messageId}");
  
  // يمكنك معالجة البيانات هنا
  // لكن لا يمكنك تحديث UI
}
```

### 2. تهيئة الإشعارات المحلية

```dart
// notification_helper.dart
class NotificationHelper {
  static Future<void> initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
  ) async {
    // إعدادات Android
    var androidInitialize = AndroidInitializationSettings('notification_icon');
    
    // إعدادات iOS
    var iOSInitialize = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    var initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize
    );
    
    // تهيئة
    await flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // عند النقر على الإشعار
        try {
          if (response.payload != null && response.payload!.isNotEmpty) {
            // تحويل payload من JSON
            NotificationBodyModel payload = 
                NotificationBodyModel.fromJson(jsonDecode(response.payload!));
            
            // التنقل حسب النوع
            if (payload.type == 'order_request') {
              Get.toNamed(RouteHelper.getRunningOrderRoute());
            } else if (payload.orderId != null) {
              Get.toNamed(
                RouteHelper.getOrderDetailsRoute(payload.orderId)
              );
            }
          }
        } catch (e) {
          print('Error handling notification tap: $e');
        }
      }
    );
    
    // إنشاء قناة الإشعارات (Android)
    await _createNotificationChannel(flutterLocalNotificationsPlugin);
  }
  
  static Future<void> _createNotificationChannel(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
  ) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'shellafood', // id
      'Shella Food', // name
      description: 'Shella Food Notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
```

### 3. الاستماع للإشعارات في المقدمة

```dart
// notification_helper.dart
static void setupFirebaseMessaging() {
  // المقدمة (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("📱 Foreground Notification Received");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
    
    // استخراج البيانات
    String? type = message.data['type'];
    String? orderId = message.data['order_id'];
    
    // معالجة حسب النوع
    if (type == 'message') {
      // إذا المستخدم في نفس المحادثة، لا تعرض إشعار
      if (_isInSameChat(orderId)) {
        // فقط حدّث الرسائل
        Get.find<ChatController>().getMessages(conversationId);
        return;
      }
    } else if (type == 'order_status') {
      // حدّث قائمة الطلبات
      Get.find<OrderController>().getCurrentOrders();
    }
    
    // عرض الإشعار المحلي
    await showNotification(message, flutterLocalNotificationsPlugin);
    
    // تشغيل صوت
    AudioPlayer().play(AssetSource('notification.mp3'));
  });
  
  // عند فتح التطبيق من إشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📱 Notification Opened App");
    _handleNotificationNavigation(message);
  });
}

static Future<void> showNotification(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin fln
) async {
  // البيانات
  String title = message.notification?.title ?? 'إشعار جديد';
  String body = message.notification?.body ?? '';
  
  // Payload (للتنقل عند النقر)
  NotificationBodyModel notificationBody = NotificationBodyModel(
    orderId: int.tryParse(message.data['order_id'] ?? '0'),
    type: message.data['type']
  );
  String payload = jsonEncode(notificationBody.toJson());
  
  // إعدادات Android
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'shellafood',
    'Shella Food',
    channelDescription: 'Shella Food Notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: 'notification_icon',
  );
  
  // إعدادات iOS
  DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails
  );
  
  // عرض الإشعار
  await fln.show(
    0, // notification id
    title,
    body,
    platformDetails,
    payload: payload
  );
}
```

### 4. التعامل مع الإشعارات في الـ Dashboard

```dart
// dashboard_screen.dart
class _DashboardScreenState extends State<DashboardScreen> {
  late StreamSubscription _stream;
  
  @override
  void initState() {
    super.initState();
    
    // الاستماع للإشعارات
    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? type = message.data['type'];
      String? orderId = message.data['order_id'];
      
      if (type == 'new_order' || type == 'order_request') {
        // تحديث قائمة الطلبات
        Get.find<OrderController>().getCurrentOrders();
        
        // عرض Dialog
        Get.dialog(NewRequestDialogWidget(
          isRequest: true,
          orderId: int.parse(orderId),
          onTap: () => _navigateRequestPage()
        ));
      } else if (type == 'assign') {
        // طلب تم تعيينه لك
        Get.dialog(NewRequestDialogWidget(
          isRequest: false,
          orderId: int.parse(orderId),
          onTap: () {
            Get.offAllNamed(
              RouteHelper.getOrderDetailsRoute(int.parse(orderId))
            );
          }
        ));
      } else if (type == 'block') {
        // حسابك تم حظره
        Get.find<AuthController>().clearSharedData();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }
  
  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }
}
```

---

## 🗺️ نظام الخرائط والموقع

### 1. طلب الأذونات

```dart
// في أول تشغيل
Future<bool> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  
  if (permission == LocationPermission.deniedForever) {
    // لا يمكن طلب الإذن، المستخدم رفضه للأبد
    return false;
  }
  
  return permission == LocationPermission.whileInUse ||
         permission == LocationPermission.always;
}
```

### 2. الحصول على الموقع الحالي

```dart
Future<Position?> getCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10)
    );
    return position;
  } catch (e) {
    print('Error getting location: $e');
    return null;
  }
}
```

### 3. تسجيل الموقع دورياً

```dart
// profile_controller.dart
Timer? _locationTimer;

void startLocationRecording() {
  // تسجيل الموقع كل 30 ثانية
  _locationTimer = Timer.periodic(
    Duration(seconds: 30),
    (timer) async {
      Position? position = await getCurrentLocation();
      if (position != null) {
        await recordLocation(
          latitude: position.latitude,
          longitude: position.longitude
        );
      }
    }
  );
}

void stopLocationRecording() {
  _locationTimer?.cancel();
  _locationTimer = null;
}

Future<void> recordLocation({
  required double latitude,
  required double longitude
}) async {
  Response response = await apiClient.postData(
    AppConstants.recordLocationUri,
    {
      'token': _getUserToken(),
      'location': [
        {
          'latitude': latitude.toString(),
          'longitude': longitude.toString()
        }
      ]
    }
  );
}
```

### 4. عرض الخريطة

```dart
// في صفحة تفاصيل الطلب
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(restaurantLat, restaurantLng),
    zoom: 14
  ),
  markers: {
    // موقع المطعم
    Marker(
      markerId: MarkerId('restaurant'),
      position: LatLng(restaurantLat, restaurantLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange
      ),
      infoWindow: InfoWindow(
        title: restaurantName,
        snippet: 'موقع الالتقاط'
      )
    ),
    // موقع العميل
    Marker(
      markerId: MarkerId('customer'),
      position: LatLng(customerLat, customerLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue
      ),
      infoWindow: InfoWindow(
        title: customerName,
        snippet: 'موقع التسليم'
      )
    ),
    // موقعي الحالي
    if (myLat != null && myLng != null)
      Marker(
        markerId: MarkerId('me'),
        position: LatLng(myLat!, myLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen
        ),
        infoWindow: InfoWindow(title: 'موقعك')
      ),
  },
  polylines: {
    // خط المسار
    if (routePoints.isNotEmpty)
      Polyline(
        polylineId: PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5
      )
  },
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
    
    // تحريك الكاميرا لتشمل جميع النقاط
    _fitBounds();
  }
)
```

---

## 💬 نظام المحادثات (WebSocket)

### 1. الاتصال

```dart
// chat_controller.dart
WebSocketChannel? _channel;

void connectToChat(int conversationId) {
  String wsUrl = '${AppConstants.baseUrl}/ws/chat/$conversationId'
      '?token=${Get.find<AuthController>().getUserToken()}';
  
  _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  
  // الاستماع للرسائل
  _channel!.stream.listen(
    (message) {
      // رسالة جديدة
      _handleNewMessage(jsonDecode(message));
    },
    onError: (error) {
      print('WebSocket Error: $error');
    },
    onDone: () {
      print('WebSocket Closed');
    }
  );
}

void _handleNewMessage(Map<String, dynamic> data) {
  Message message = Message.fromJson(data);
  
  // إضافة للقائمة
  _messageList.add(message);
  update();
  
  // تشغيل صوت إذا الرسالة من الطرف الآخر
  if (message.senderId != myId) {
    AudioPlayer().play(AssetSource('message.mp3'));
  }
}

void sendMessage(String text) {
  if (_channel == null) return;
  
  var message = {
    'conversation_id': conversationId,
    'message': text,
    'sender_id': myId,
    'timestamp': DateTime.now().toIso8601String()
  };
  
  _channel!.sink.add(jsonEncode(message));
}

void disconnect() {
  _channel?.sink.close();
  _channel = null;
}

@override
void onClose() {
  disconnect();
  super.onClose();
}
```

---

## 🎨 الثيمات والتخصيص

### إضافة لون جديد

```dart
// util/app_constants.dart
class AppConstants {
  static const Color primaryColor = Color(0xFF1455AC);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color accentColor = Color(0xFF4ECDC4);
  
  // اللون الجديد
  static const Color customColor = Color(0xFF95E1D3);
}
```

### إضافة ستايل نصي جديد

```dart
// util/styles.dart
final customTextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: AppConstants.customColor
);
```

### استخدامه

```dart
Text(
  'نص مخصص',
  style: customTextStyle
)
```

---

## 📱 إضافة ميزة جديدة (Feature)

### مثال: إضافة ميزة التقييمات (Ratings)

#### 1. إنشاء الهيكل

```
lib/features/rating/
├── controllers/
│   └── rating_controller.dart
├── domain/
│   ├── models/
│   │   └── rating_model.dart
│   ├── repositories/
│   │   ├── rating_repository_interface.dart
│   │   └── rating_repository.dart
│   └── services/
│       ├── rating_service_interface.dart
│       └── rating_service.dart
├── screens/
│   └── rating_screen.dart
└── widgets/
    └── rating_widget.dart
```

#### 2. النموذج (Model)

```dart
// rating_model.dart
class RatingModel {
  final int? id;
  final int? orderId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  RatingModel({
    this.id,
    this.orderId,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      orderId: json['order_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}
```

#### 3. Repository Interface

```dart
// rating_repository_interface.dart
abstract class RatingRepositoryInterface {
  Future<Response> submitRating(Map<String, dynamic> body);
  Future<List<RatingModel>?> getMyRatings();
}
```

#### 4. Repository Implementation

```dart
// rating_repository.dart
class RatingRepository implements RatingRepositoryInterface {
  final ApiClient apiClient;
  
  RatingRepository({required this.apiClient});

  @override
  Future<Response> submitRating(Map<String, dynamic> body) async {
    return await apiClient.postData(
      '/api/v1/delivery-man/submit-rating',
      body
    );
  }

  @override
  Future<List<RatingModel>?> getMyRatings() async {
    Response response = await apiClient.getData(
      '/api/v1/delivery-man/ratings'
    );
    
    if (response.statusCode == 200) {
      List<RatingModel> ratings = [];
      response.body.forEach((json) {
        ratings.add(RatingModel.fromJson(json));
      });
      return ratings;
    }
    return null;
  }
}
```

#### 5. Service

```dart
// rating_service.dart
class RatingService implements RatingServiceInterface {
  final RatingRepositoryInterface repository;
  
  RatingService({required this.repository});

  @override
  Future<Response> submitRating(int orderId, int rating, String comment) {
    return repository.submitRating({
      'order_id': orderId,
      'rating': rating,
      'comment': comment
    });
  }

  @override
  Future<List<RatingModel>?> getMyRatings() {
    return repository.getMyRatings();
  }
}
```

#### 6. Controller

```dart
// rating_controller.dart
class RatingController extends GetxController {
  final RatingServiceInterface ratingServiceInterface;
  
  RatingController({required this.ratingServiceInterface});

  List<RatingModel>? _ratings;
  List<RatingModel>? get ratings => _ratings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> submitRating(int orderId, int rating, String comment) async {
    _isLoading = true;
    update();

    Response response = await ratingServiceInterface.submitRating(
      orderId,
      rating,
      comment
    );

    if (response.statusCode == 200) {
      showCustomSnackBar('تم إرسال التقييم بنجاح', isError: false);
      await getMyRatings();
    } else {
      showCustomSnackBar('حدث خطأ، حاول مرة أخرى');
    }

    _isLoading = false;
    update();
  }

  Future<void> getMyRatings() async {
    _ratings = await ratingServiceInterface.getMyRatings();
    update();
  }
}
```

#### 7. التسجيل في Dependency Injection

```dart
// helper/get_di.dart
Future<void> init() async {
  // ... الكود الموجود
  
  // Rating
  Get.lazyPut<RatingRepositoryInterface>(
    () => RatingRepository(apiClient: Get.find())
  );
  
  Get.lazyPut<RatingServiceInterface>(
    () => RatingService(repository: Get.find())
  );
  
  Get.lazyPut(
    () => RatingController(ratingServiceInterface: Get.find())
  );
}
```

#### 8. الواجهة (Screen)

```dart
// rating_screen.dart
class RatingScreen extends StatelessWidget {
  final int orderId;
  
  const RatingScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تقييم الطلب')),
      body: GetBuilder<RatingController>(
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // نجوم التقييم
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    // حفظ التقييم
                  },
                ),
                
                SizedBox(height: 20),
                
                // حقل التعليق
                TextField(
                  decoration: InputDecoration(
                    labelText: 'أضف تعليق (اختياري)',
                    border: OutlineInputBorder()
                  ),
                  maxLines: 4,
                ),
                
                SizedBox(height: 20),
                
                // زر الإرسال
                ElevatedButton(
                  onPressed: controller.isLoading ? null : () {
                    controller.submitRating(orderId, 5, 'تعليق');
                  },
                  child: controller.isLoading
                    ? CircularProgressIndicator()
                    : Text('إرسال التقييم')
                )
              ],
            ),
          );
        }
      )
    );
  }
}
```

---

## 🧪 الاختبارات (Testing)

### Unit Test مثال

```dart
// test/order_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

class MockOrderService extends Mock implements OrderServiceInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late OrderController orderController;
  late MockOrderService mockOrderService;

  setUp(() {
    mockOrderService = MockOrderService();
    orderController = OrderController(
      orderServiceInterface: mockOrderService
    );
  });

  group('Order Controller Tests', () {
    test('getCurrentOrders should update order list', () async {
      // Arrange
      List<OrderModel> mockOrders = [
        OrderModel(id: 1, orderStatus: 'accepted'),
        OrderModel(id: 2, orderStatus: 'picked_up'),
      ];
      
      when(mockOrderService.getCurrentOrderList())
          .thenAnswer((_) async => mockOrders);

      // Act
      await orderController.getCurrentOrders();

      // Assert
      expect(orderController.currentOrderList, mockOrders);
      expect(orderController.currentOrderList!.length, 2);
      expect(orderController.isLoading, false);
    });

    test('hasReachedMaxCapacity should return true when 2 orders', () {
      // Arrange
      orderController.setOrdersForTesting([
        OrderModel(id: 1, deliveryManId: 1),
        OrderModel(id: 2, deliveryManId: 1),
      ]);

      // Act & Assert
      expect(orderController.hasReachedMaxCapacity(), true);
    });
  });
}
```

---

## 🚀 نشر التطبيق (Deployment)

### Android

#### 1. إنشاء Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

#### 2. تكوين Gradle

```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] 
                ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 3. البناء

```bash
# APK
flutter build apk --release

# App Bundle (للـ Play Store)
flutter build appbundle --release
```

### iOS

#### 1. في Xcode

```
1. فتح ios/Runner.xcworkspace
2. اختيار Target: Runner
3. General → Signing
4. اختيار Team الصحيح
5. Bundle Identifier صحيح
```

#### 2. البناء

```bash
flutter build ios --release
```

#### 3. Archive & Upload

```
1. في Xcode: Product → Archive
2. انتظر اكتمال الـ Archive
3. اختر Archive → Distribute App
4. اختر App Store Connect
5. Upload
```

---

## 📊 مراقبة الأداء (Performance Monitoring)

### استخدام Firebase Performance

```dart
// pubspec.yaml
dependencies:
  firebase_performance: ^0.9.0

// main.dart
import 'package:firebase_performance/firebase_performance.dart';

// قياس وقت تحميل البيانات
Future<void> loadData() async {
  Trace trace = FirebasePerformance.instance.newTrace('load_orders');
  await trace.start();
  
  try {
    await Get.find<OrderController>().getCurrentOrders();
  } finally {
    await trace.stop();
  }
}

// قياس HTTP requests تلقائياً
final http.Client client = http.Client();
final HttpMetric metric = FirebasePerformance.instance
    .newHttpMetric(url, HttpMethod.Get);

await metric.start();
final http.Response response = await client.get(Uri.parse(url));
metric.responseCode = response.statusCode;
await metric.stop();
```

---

## 🔒 أفضل الممارسات الأمنية

### 1. لا تخزن البيانات الحساسة في الكود

```dart
// ❌ خطأ
const String apiKey = "AIzaSyD...";

// ✅ صحيح
// استخدم .env file
final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
```

### 2. تشفير البيانات الحساسة

```dart
import 'package:encrypt/encrypt.dart';

String encryptData(String plainText) {
  final key = Key.fromUtf8('32_character_key_for_encryption');
  final iv = IV.fromLength(16);
  
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  
  return encrypted.base64;
}
```

### 3. التحقق من SSL Pinning

```dart
// api_client.dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
        (X509Certificate cert, String host, int port) {
          // تحقق من الـ Certificate
          return host == 'dev.shelafood.com';
        };
  }
}
```

---

## 📚 موارد إضافية

### روابط مفيدة
- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

### أدوات مفيدة
- **Flutter DevTools**: لتصحيح الأخطاء ومراقبة الأداء
- **Postman**: لاختبار الـ API
- **Firebase Console**: لإدارة الـ Backend
- **Android Studio Profiler**: لمراقبة الذاكرة والـ CPU

---

**آخر تحديث**: فبراير 2026
**الإصدار**: 1.1.4+18
**للمطورين**: إذا كان لديك أي أسئلة، راجع الملفات الأخرى في المشروع أو تواصل مع الفريق.
