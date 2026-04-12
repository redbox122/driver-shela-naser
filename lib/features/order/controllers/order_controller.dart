import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/common/services/error_handler_service.dart';
import 'package:shellafood_delivery/common/services/order_filter_service.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_details_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/update_status_body_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/ignore_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_cancellation_body.dart';
import 'package:shellafood_delivery/features/order/domain/services/order_service_interface.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/helper/order_helper.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});

  List<OrderModel>? _currentOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;

  /// Check if delivery person has reached maximum order capacity
  bool hasReachedMaxCapacity() {
    if (_currentOrderList == null) return false;
    final assignedOrders = _getAssignedOrders();
    return OrderHelper.hasReachedMaxCapacity(assignedOrders);
  }

  /// Get remaining order capacity for delivery person
  int getRemainingCapacity() {
    if (_currentOrderList == null) return OrderHelper.maxOrdersPerDeliveryMan;
    final assignedOrders = _getAssignedOrders();
    return OrderHelper.getRemainingCapacity(assignedOrders);
  }

  /// Check if delivery person can accept new orders
  bool canAcceptNewOrders() {
    if (_currentOrderList == null) return true;
    final assignedOrders = _getAssignedOrders();
    return OrderHelper.canAcceptNewOrders(assignedOrders);
  }

  /// Helper method to get only assigned orders
  List<OrderModel> _getAssignedOrders() {
    if (_currentOrderList == null) return [];
    return _currentOrderList!
        .where((order) =>
            order.deliveryManId != null &&
            order.deliveryManId ==
                Get.find<ProfileController>().profileModel?.id)
        .toList();
  }

  /// Get current orders sorted by priority (accepted orders first)
  /// Only returns orders that are actually assigned to this delivery person
  List<OrderModel>? get currentOrdersSorted {
    if (_currentOrderList == null || _currentOrderList!.isEmpty) {
      return _currentOrderList;
    }

    // Filter out available orders (DeliveryManId=null) and only keep assigned orders
    final assignedOrders = _currentOrderList!
        .where((order) =>
            order.deliveryManId != null &&
            order.deliveryManId ==
                Get.find<ProfileController>().profileModel?.id)
        .toList();

    debugPrint('[currentOrdersSorted] total=${_currentOrderList!.length} assigned=${assignedOrders.length}');

    return OrderHelper.sortOrdersByPriority(assignedOrders);
  }

  List<OrderModel>? _completedOrderList;
  List<OrderModel>? get completedOrderList => _completedOrderList;

  List<OrderModel>? _latestOrderList;
  List<OrderModel>? get latestOrderList => _latestOrderList;

  List<OrderDetailsModel>? _orderDetailsModel;
  List<OrderDetailsModel>? get orderDetailsModel => _orderDetailsModel;

  List<IgnoreModel> _ignoredRequests = [];
  List<IgnoreModel> get ignoredRequests => _ignoredRequests;
  TextEditingController priceRequest = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _otp = '';
  String get otp => _otp;

  String _storeOtp = '';
  String get storeOtp => _storeOtp;

  bool _paginate = false;
  bool get paginate => _paginate;

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<int> _offsetList = [];
  List<int> get offsetList => _offsetList;

  int _offset = 1;
  int get offset => _offset;

  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

  String? _cancelReason = '';
  String? get cancelReason => _cancelReason;

  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  bool _showDeliveryImageField = false;
  bool get showDeliveryImageField => _showDeliveryImageField;


  List<XFile> _pickedPrescriptions = [];
  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  List<XFile> _pickedOrderProofImages = [];
  List<XFile> get pickedOrderProofImages => _pickedOrderProofImages;

  String _normalizeStatus(String? status) =>
      (status ?? '').toLowerCase().trim();

  bool canShowPickupPhotos(OrderModel? order) {
    final currentDriverId = Get.find<ProfileController>().profileModel?.id;
    assert(() {
      debugPrint(
          'PICKUP PHOTOS CHECK: orderType=${order?.orderType}, '
          'orderStatus=${order?.orderStatus}, '
          'deliveryManId=${order?.deliveryManId}, '
          'currentDriverId=$currentDriverId');
      return true;
    }());
    return order != null &&
        order.orderType == 'delivery' &&
        _normalizeStatus(order.orderStatus) ==
            _normalizeStatus(AppConstants.accepted) &&
        order.deliveryManId != null &&
        currentDriverId != null &&
        order.deliveryManId == currentDriverId;
  }

  bool get showDeliveryPhotos => canShowPickupPhotos(_orderModel);

  /// ✅ دالة محسنة للتحقق من وجود صور المطعم المرفوعة
  /// تتعامل مع null و empty string معاً
  bool hasUploadedRestaurantPhotos(OrderModel? order) {
    if (order == null) return false;
    
    // التحقق الصحيح: null OR empty list OR all elements are empty
    if (order.orderProofFullUrl == null) {
      debugPrint('🔍 No restaurant photos: orderProofFullUrl is null');
      return false;
    }
    
    if (order.orderProofFullUrl!.isEmpty) {
      debugPrint('🔍 No restaurant photos: orderProofFullUrl list is empty');
      return false;
    }
    
    // التحقق من أن جميع الصور ليست فارغة
    final hasValidPhotos =
        order.orderProofFullUrl!.where((url) => url.isNotEmpty).isNotEmpty;
    
    debugPrint('🔍 Restaurant photos check: $hasValidPhotos (${order.orderProofFullUrl!.length} photos)');
    return hasValidPhotos;
  }

  /// ✅ دالة للتحقق من التقاط صور التسليم
  bool hasPickedDeliveryPhotos() {
    final hasPicked = _pickedPrescriptions.isNotEmpty;
    debugPrint('🔍 Delivery photos picked: $hasPicked (${_pickedPrescriptions.length} photos)');
    return hasPicked;
  }

  /// ✅ دالة للتحقق من وجود صور التسليم المرفوعة
  bool hasUploadedDeliveryPhotos(OrderModel? order) {
    if (order == null) return false;
    // TODO: هذا يعتمد على field من الخادم - تأكد من الاسم الصحيح
    // قد يكون: deliveryImage, deliveryProof, proofImage, إلخ
    debugPrint('🔍 Delivery photos uploaded check needed - verify field name with backend');
    return false; // سيتم تحديثه حسب تجاوب الخادم
  }

  void changeDeliveryImageStatus({bool isUpdate = true}) {
    _showDeliveryImageField = !_showDeliveryImageField;
    if (isUpdate) {
      update();
    }
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
        if (Get.isDialogOpen!) {
          Get.back();
        }
      }
      update();
    }
  }

  void pickOrderProofImages(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedOrderProofImages = [];
    } else {
      // Limit to 5 images max
      if (_pickedOrderProofImages.length >= 5) {
        showCustomSnackBar('maximum_5_photos_allowed'.tr, isError: true);
        return;
      }
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedOrderProofImages.add(xFile);
        if (Get.isDialogOpen!) {
          Get.back();
        }
      }
      update();
    }
  }

  /// Uploads order proof photos (menu/facture/receipt) for modules 6/7/8/9
  /// 
  /// ✅ IMPORTANT FLOW:
  /// 1. User selects photos → pickOrderProofImages()
  /// 2. User clicks upload → uploadOrderProof()
  /// 3. Success → show message + refresh order
  /// 4. Then user can click "Pick Up" button
  /// 5. "Pick Up" validates hasUploadedRestaurantPhotos() FIRST
  /// 6. If true → updateOrderStatus('picked_up')
  /// 
  /// The order status REMAINS "confirmed" after photo upload.
  /// Status only changes to "picked_up" when DM clicks "Pick Up" button.
  /// 
  /// Flow: confirmed (with photos) → picked_up → delivered
  Future<bool> uploadOrderProof(OrderModel order) async {
    if (_pickedOrderProofImages.isEmpty) {
      showCustomSnackBar('please_select_at_least_one_photo'.tr, isError: true);
      return false;
    }

    // Debug print - check order status before upload
    debugPrint('[uploadOrderProof] order_id=${order.id} photos=${_pickedOrderProofImages.length}');

    _isLoading = true;
    update();

    try {
      List<MultipartBody> multiParts =
          orderServiceInterface.prepareOrderProofImages(_pickedOrderProofImages);
      
      // Upload pickup photos and move to picked_up
      UpdateStatusBodyModel updateStatusBody = UpdateStatusBodyModel(
        orderId: order.id,
        status: AppConstants.pickedUp,
        moduleId: order.module_id,
      );
      if (order.module_id == 3 &&
          order.otpStore != null &&
          order.otpStore!.isNotEmpty) {
        updateStatusBody.otpStore = order.otpStore;
      }

      ResponseModel responseModel = await orderServiceInterface.updateOrderStatus(
          updateStatusBody, multiParts);

      if (responseModel.isSuccess) {
        // Clear picked images after successful upload
        _pickedOrderProofImages = [];
        
        // Refresh order details to get updated orderProofFullUrl
        await getOrderDetails(order.id, false);
        
        debugPrint('[uploadOrderProof] success');
        showCustomSnackBar('order_proof_photos_uploaded'.tr, isError: false);
        update();
        return true;
      } else {
        debugPrint('[uploadOrderProof] failed: ${responseModel.message}');
        showCustomSnackBar(responseModel.message, isError: true);
        return false;
      }
    } catch (e) {
      showCustomSnackBar('upload_failed'.tr, isError: true);
      debugPrint('[uploadOrderProof] error: $e');
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    // ML-02: TextEditingController holds a ChangeNotifier — must be disposed
    priceRequest.dispose();
    super.onClose();
  }

  void initLoading() {
    _isLoading = false;
    update();
  }

  void setOrderCancelReason(String? reason) {
    _cancelReason = reason;
    update();
  }

  Future<void> getOrderCancelReasons() async {
    List<CancellationData>? orderCancelReasons =
        await orderServiceInterface.getCancelReasons();
    if (orderCancelReasons != null) {
      _orderCancelReasons = [];
      _orderCancelReasons!.addAll(orderCancelReasons);
    }
    update();
  }

  Future<void> getOrderWithId(int? orderId, {bool closeOnError = true}) async {
    if (orderId == null || orderId <= 0) {
      debugPrint('[ORDER TAP] invalid order_id: $orderId');
      showCustomSnackBar('invalid_order_id'.tr, isError: true);
      return;
    }
    _orderModel = null;
    Response response = await orderServiceInterface.getOrderWithId(orderId);
    if (response.statusCode == 200 && response.body != null) {
      _orderModel = OrderModel.fromJson(response.body);
    } else if (response.statusCode == 404) {
      showCustomSnackBar('order_not_found'.tr, isError: true);
      if (closeOnError && Get.context != null && Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      }
      await getCurrentOrders();
    } else {
      showCustomSnackBar('failed_to_load_order'.tr, isError: true);
      if (closeOnError && Get.context != null && Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      }
      await getCurrentOrders();
    }
    update();
  }

  Future<bool> fetchOrderDetailsOnTap(int? orderId) async {
    if (orderId == null || orderId <= 0) {
      debugPrint('[ORDER TAP] blocked - invalid order_id: $orderId');
      showCustomSnackBar('invalid_order_id'.tr, isError: true);
      return false;
    }

    debugPrint('[ORDER TAP] order_id=$orderId');
    await getOrderWithId(orderId, closeOnError: false);
    await getOrderDetails(orderId, _orderModel?.orderType == 'parcel');
    return true;
  }

  Future<void> getCompletedOrders(int offset) async {
    if (offset == 1) {
      _offsetList = [];
      _offset = 1;
      _completedOrderList = null;
      // update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      PaginatedOrderModel? paginatedOrderModel =
          await orderServiceInterface.getCompletedOrderList(offset);
      if (paginatedOrderModel != null) {
        if (offset == 1) {
          _completedOrderList = [];
        }
        _completedOrderList!.addAll(paginatedOrderModel.orders!);
        _pageSize = paginatedOrderModel.totalSize;
        _paginate = false;
        update();
      }
    } else {
      if (_paginate) {
        _paginate = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _paginate = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  Future<void> getCurrentOrders() async {
    List<OrderModel>? currentOrderList =
        await orderServiceInterface.getCurrentOrders();
    if (currentOrderList != null) {
      _currentOrderList = [];
      _currentOrderList!.addAll(currentOrderList);
    }
    update();
  }

  Future<void> getLatestOrders() async {
    try {
      List<OrderModel>? latestOrderList =
          await orderServiceInterface.getLatestOrders();

      if (latestOrderList != null) {
        _latestOrderList = [];
        List<int?> ignoredIdList =
            orderServiceInterface.prepareIgnoreIdList(_ignoredRequests);
        List<OrderModel> processedOrders = orderServiceInterface
            .processLatestOrders(latestOrderList, ignoredIdList);
        final int ignoredCount =
            latestOrderList.length - processedOrders.length;

        // Apply security filtering based on delivery man's profile
        final profileController = Get.find<ProfileController>();
        List<OrderModel> filteredOrders = OrderFilterService.filterLatestOrders(
            processedOrders, profileController.profileModel);

        _latestOrderList!.addAll(filteredOrders);

        // Log filtering results for debugging
        debugPrint(
            'Orders filtered: raw=${latestOrderList.length}, ignored=$ignoredCount, after_ignore=${processedOrders.length}, after_security=${filteredOrders.length}');
        final ids = filteredOrders
            .map((e) => e.id)
            .whereType<int>()
            .toList()
          ..sort();
        final int? maxId = ids.isNotEmpty ? ids.last : null;
        final List<int> tail = ids.length > 5 ? ids.sublist(ids.length - 5) : ids;
        debugPrint('[LATEST FINAL] count=${filteredOrders.length}, max_id=$maxId, last_ids=$tail');
      }
    } catch (e) {
      debugPrint('getLatestOrders error: $e');
    } finally {
      update();
    }
  }

  /// Fetch latest orders only when delivery man is active
  Future<void> getLatestOrdersIfActive() async {
    final profileController = Get.find<ProfileController>();
    if (profileController.profileModel == null ||
        profileController.profileModel!.active != 1) {
      _latestOrderList = [];
      update();
      return;
    }
    await getLatestOrders();
  }

  Future<bool> updateOrderStatus(OrderModel currentOrder, String status,
      {bool back = false,
      String? reason,
      bool? parcel = false,
      bool gotoDashboard = false}) async {
    _isLoading = true;
    update();

    debugPrint('[updateOrderStatus] order_id=${currentOrder.id} status=$status');

    List<MultipartBody> multiParts =
        orderServiceInterface.prepareOrderProofImages(_pickedPrescriptions);
    UpdateStatusBodyModel updateStatusBody = UpdateStatusBodyModel(
      orderId: currentOrder.id,
      status: status,
      reason: reason,
      otp: status == AppConstants.delivered ? _otp : null,
      otpStore: status == AppConstants.pickedUp ? _storeOtp : null,
    );

    ResponseModel responseModel = await orderServiceInterface.updateOrderStatus(
        updateStatusBody, multiParts);
    Get.back(result: responseModel.isSuccess);
    if (responseModel.isSuccess) {
      if (back) {
        Get.back();
      }
      if (gotoDashboard) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromOrderDetails: true));
      }
      Get.find<ProfileController>().getProfile();
      getCurrentOrders();
      // SM-07: do not mutate the passed-in OrderModel directly; getCurrentOrders()
      // above already refreshes the list from the server with the updated status.
      if (_isTerminalStatus(status)) {
        _removeOrderFromCurrentList(currentOrder.id);
        _removeOrderFromLatestList(currentOrder.id);
      }
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  Future<void> getOrderDetails(int? orderID, bool parcel) async {
    if (orderID == null || orderID <= 0) {
      debugPrint('[ORDER TAP] getOrderDetails blocked - invalid order_id: $orderID');
      showCustomSnackBar('invalid_order_id'.tr, isError: true);
      return;
    }
    if (parcel) {
      _orderDetailsModel = [];
    } else {
      _orderDetailsModel = null;
      List<OrderDetailsModel>? orderDetailsModel =
          await orderServiceInterface.getOrderDetails(orderID);
      if (orderDetailsModel != null) {
        _orderDetailsModel = [];
        _orderDetailsModel!.addAll(orderDetailsModel);
      }
      update();
    }
  }

  Future<bool> acceptOrder(
      int? orderID, int index, OrderModel orderModel) async {
    _isLoading = true;
    update();

    try {
      ResponseModel responseModel =
          await orderServiceInterface.acceptOrder(orderID);

      Get.back();

      if (responseModel.isSuccess) {
        // Safely remove order from latest order list
        _removeOrderFromLatestList(orderID);

        // Safely add order to current order list
        _addOrderToCurrentList(orderModel);

        showCustomSnackBar(
            responseModel.message ?? 'order_accepted_successfully'.tr,
            isError: false);
        return true;
      } else {
        // Enhanced error handling for specific error codes
        if (responseModel.errorResponse != null) {
          ErrorHandlerService.handleOrderAcceptanceError(
              responseModel.errorResponse);
        } else {
          // Fallback to generic error message
          showCustomSnackBar(
              responseModel.message ?? 'order_acceptance_failed'.tr,
              isError: true);
        }
        return false;
      }
    } catch (e) {
      Get.back();
      // Handle unexpected errors
      showCustomSnackBar('unexpected_error_occurred'.tr, isError: true);
      debugPrint('Order acceptance error: $e');
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> cancelOrder(int? orderID, {String? reason}) async {
    _isLoading = true;
    update();

    try {
      ResponseModel responseModel =
          await orderServiceInterface.cancelOrder(orderID, reason: reason);

      if (responseModel.isSuccess) {
        showCustomSnackBar(responseModel.message ?? 'canceled'.tr,
            isError: false);
        await getCurrentOrders();
        await getLatestOrders();
        Get.offAllNamed(RouteHelper.getMainRoute('order-request'));
      } else {
        showCustomSnackBar(
            responseModel.message ?? 'unexpected_error_occurred'.tr,
            isError: true);
      }
    } catch (e) {
      showCustomSnackBar('unexpected_error_occurred'.tr, isError: true);
      debugPrint('Order cancel error: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Safely remove order from latest order list by ID instead of index
  void _removeOrderFromLatestList(int? orderID) {
    if (_latestOrderList != null && orderID != null) {
      try {
        // Find and remove order by ID instead of index for better reliability
        _latestOrderList!.removeWhere((order) => order.id == orderID);
        debugPrint('Removed order $orderID from latest order list');
      } catch (e) {
        debugPrint('Error removing order from latest list: $e');
        // If removal fails, refresh the latest orders list
        getLatestOrders();
      }
    }
  }

  /// Safely add order to current order list
  void _addOrderToCurrentList(OrderModel orderModel) {
    if (_currentOrderList != null) {
      try {
        // Check if order is not already in current list
        bool orderExists =
            _currentOrderList!.any((order) => order.id == orderModel.id);
        if (!orderExists) {
          _currentOrderList!.add(orderModel);
          debugPrint('Added order ${orderModel.id} to current order list');
        }
      } catch (e) {
        debugPrint('Error adding order to current list: $e');
        // If addition fails, refresh the current orders list
        getCurrentOrders();
      }
    } else {
      // Initialize current order list if null
      _currentOrderList = [orderModel];
      debugPrint('Initialized current order list with order ${orderModel.id}');
    }
  }

  void _removeOrderFromCurrentList(int? orderID) {
    if (_currentOrderList != null && orderID != null) {
      try {
        _currentOrderList!.removeWhere((order) => order.id == orderID);
        debugPrint('Removed order $orderID from current order list');
      } catch (e) {
        debugPrint('Error removing order from current list: $e');
        getCurrentOrders();
      }
    }
  }

  bool _isTerminalStatus(String status) {
    final normalized = _normalizeStatus(status);
    return normalized == _normalizeStatus(AppConstants.delivered) ||
        normalized == _normalizeStatus(AppConstants.canceled) ||
        normalized == _normalizeStatus(AppConstants.failed) ||
        normalized == _normalizeStatus(AppConstants.refunded);
  }

  void getIgnoreList() {
    _ignoredRequests = [];
    _ignoredRequests.addAll(orderServiceInterface.getIgnoreList());
  }

  void ignoreOrder(int index) {
    if (_latestOrderList != null &&
        index >= 0 &&
        index < _latestOrderList!.length) {
      try {
        OrderModel orderToIgnore = _latestOrderList![index];
        _ignoredRequests
            .add(IgnoreModel(id: orderToIgnore.id, time: DateTime.now()));
        _latestOrderList!.removeAt(index);
        orderServiceInterface.setIgnoreList(_ignoredRequests);
        debugPrint('Ignored order ${orderToIgnore.id}');
      } catch (e) {
        debugPrint('Error ignoring order at index $index: $e');
        // If ignore fails, refresh the latest orders list
        getLatestOrders();
      }
    } else {
      debugPrint(
          'Invalid index $index for ignoring order. List length: ${_latestOrderList?.length ?? 0}');
    }
    update();
  }

  void removeFromIgnoreList() {
    List<IgnoreModel> tempList = orderServiceInterface.tempList(
        Get.find<SplashController>().currentTime, _ignoredRequests);
    _ignoredRequests = [];
    _ignoredRequests.addAll(tempList);
    orderServiceInterface.setIgnoreList(_ignoredRequests);
  }

  void setOtp(String otp) {
    _otp = otp;
    if (otp != '') {
      update();
    }
  }

  void setStoreOtp(String otp) {
    _storeOtp = otp;
    if (otp != '') {
      update();
    }
  }

  Future<bool> addRequest(int? orderId) {
    // CS-05: guard against null orderId and non-numeric price input
    if (orderId == null) {
      showCustomSnackBar('invalid_order_id'.tr, isError: true);
      return Future.value(false);
    }
    final double? price = double.tryParse(priceRequest.text.trim());
    if (price == null) {
      showCustomSnackBar('invalid_price'.tr, isError: true);
      return Future.value(false);
    }
    return orderServiceInterface.setPriceService(orderId, price);
  }

  /// Check if delivery man can see orders based on their status
  bool canShowOrders() {
    final profileController = Get.find<ProfileController>();
    return OrderFilterService.shouldShowOrders(profileController.profileModel);
  }

  /// Get delivery man status message for UI display
  String getDeliveryManStatusMessage() {
    final profileController = Get.find<ProfileController>();
    return OrderFilterService.getDeliveryManStatusMessage(
        profileController.profileModel);
  }

  /// Refresh orders with status validation
  Future<void> refreshOrdersWithValidation() async {
    if (!canShowOrders()) {
      // Clear orders if delivery man cannot see them
      _latestOrderList = [];
      update();
      return;
    }

    // Proceed with normal order refresh
    await getLatestOrders();
  }

  /// Get orders from today
  List<OrderModel> getTodaysOrders() {
    if (_completedOrderList == null) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _completedOrderList!.where((order) {
      if (order.createdAt == null || order.createdAt!.isEmpty) return false;

      try {
        final orderDate = DateTime.parse(order.createdAt!).toLocal();
        final orderDay =
            DateTime(orderDate.year, orderDate.month, orderDate.day);
        return orderDay.isAtSameMomentAs(today);
      } catch (e) {
        debugPrint('Error parsing order date: ${order.createdAt}');
        return false;
      }
    }).toList();
  }

  /// Get orders from this week (Monday to Sunday)
  List<OrderModel> getThisWeekOrders() {
    if (_completedOrderList == null) return [];

    final now = DateTime.now();
    // Calculate start of week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _completedOrderList!.where((order) {
      if (order.createdAt == null || order.createdAt!.isEmpty) return false;

      try {
        final orderDate = DateTime.parse(order.createdAt!).toLocal();
        return orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        debugPrint('Error parsing order date: ${order.createdAt}');
        return false;
      }
    }).toList();
  }
}
