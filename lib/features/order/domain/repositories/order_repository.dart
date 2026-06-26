import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/common/models/response_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/ignore_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_cancellation_body.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_details_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/order/domain/models/update_status_body_model.dart';
import 'package:shellafood_delivery/features/order/domain/repositories/order_repository_interface.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';
import 'package:shellafood_delivery/util/app_constants.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData(
        '${AppConstants.orderCancellationUri}?offset=1&limit=30&type=deliveryman');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody =
          OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  @override
  Future<Response> get(int? id) async {
    if (id == null || id <= 0) {
      debugPrint('[REQUEST] skipped /delivery-man/order: invalid order_id: $id');
      return Response(
        statusCode: 400,
        statusText: 'invalid_order_id',
        body: {'message': 'Invalid order_id: $id'},
      );
    }

    final String token = _getUserToken();
    final Map<String, String> queryParams = {
      'token': token,
      'order_id': id.toString(),
    };
    final String primaryUri =
        '${AppConstants.currentOrderUri}$token&order_id=$id';
    final Map<String, String> noCacheHeaders = _orderNoCacheHeaders();

    _logOrderRequest(
      endpoint: '/api/v1/delivery-man/order',
      uri: primaryUri,
      method: 'GET',
      headers: noCacheHeaders,
      queryParams: queryParams,
    );

    final Response response = await apiClient.getData(
      primaryUri,
      headers: noCacheHeaders,
      handleError: false,
    );
    _logOrderResponse(
      endpoint: '/api/v1/delivery-man/order',
      response: response,
    );

    if (response.statusCode == 404) {
      final String fallbackUri =
          '${AppConstants.orderDetailsUri}$token&order_id=$id';
      _logOrderRequest(
        endpoint: '/api/v1/delivery-man/order-details',
        uri: fallbackUri,
        method: 'GET',
        headers: noCacheHeaders,
        queryParams: queryParams,
      );

      final Response fallbackResponse = await apiClient.getData(
        fallbackUri,
        headers: noCacheHeaders,
        handleError: false,
      );
      _logOrderResponse(
        endpoint: '/api/v1/delivery-man/order-details',
        response: fallbackResponse,
      );
    }

    return response;
  }

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData(
        '${AppConstants.allOrdersUri}?token=${_getUserToken()}&offset=$offset&limit=10');
    if (response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return paginatedOrderModel;
  }

  @override
  Future<List<OrderModel>?> getList() async {
    List<OrderModel>? currentOrderList;
    final String uri = AppConstants.currentOrdersUri + _getUserToken();
    Response response = await apiClient.getData(
      uri,
      headers: _orderNoCacheHeaders(),
    );
    if (response.statusCode == 200) {
      currentOrderList = [];
      response.body.forEach(
          (order) => currentOrderList!.add(OrderModel.fromJson(order)));
    }
    return currentOrderList;
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    List<OrderModel>? latestOrderList;
    final String uri = AppConstants.latestOrdersUri + _getUserToken();
    Response response =
        await apiClient.getData(uri, headers: _orderNoCacheHeaders());
    if (response.statusCode == 200) {
      latestOrderList = [];
      final List<dynamic> orders = _extractOrderList(response.body);
      for (final order in orders) {
        latestOrderList.add(OrderModel.fromJson(order));
      }
      final ids = latestOrderList
          .map((o) => o.id)
          .whereType<int>()
          .toList()
        ..sort();
      final int? maxId = ids.isNotEmpty ? ids.last : null;
      final List<int> tail = ids.length > 5 ? ids.sublist(ids.length - 5) : ids;
      if (kDebugMode) {
        debugPrint('[LATEST RAW] count=${latestOrderList.length}, max_id=$maxId, last_ids=$tail');
      }
    }
    return latestOrderList;
  }

  @override
  Future<ResponseModel> updateOrderStatus(
      UpdateStatusBodyModel updateStatusBody,
      List<MultipartBody> proofAttachment) async {
    updateStatusBody.token = _getUserToken();
    ResponseModel responseModel;
    Response response = await apiClient.postMultipartData(
        AppConstants.updateOrderStatusUri,
        updateStatusBody.toJson(),
        proofAttachment,
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int? orderID) async {
    if (orderID == null || orderID <= 0) {
      debugPrint('[REQUEST] skipped /delivery-man/order-details: invalid order_id: $orderID');
      return null;
    }

    List<OrderDetailsModel>? orderDetailsModel;
    final String token = _getUserToken();
    final String uri = '${AppConstants.orderDetailsUri}$token&order_id=$orderID';
    final Map<String, String> queryParams = {
      'token': token,
      'order_id': orderID.toString(),
    };
    final Map<String, String> noCacheHeaders = _orderNoCacheHeaders();

    _logOrderRequest(
      endpoint: '/api/v1/delivery-man/order-details',
      uri: uri,
      method: 'GET',
      headers: noCacheHeaders,
      queryParams: queryParams,
    );

    Response response = await apiClient.getData(
      uri,
      headers: noCacheHeaders,
      handleError: false,
    );
    _logOrderResponse(
      endpoint: '/api/v1/delivery-man/order-details',
      response: response,
    );

    if (response.statusCode == 200) {
      orderDetailsModel = [];
      response.body.forEach((orderDetails) =>
          orderDetailsModel!.add(OrderDetailsModel.fromJson(orderDetails)));
    }
    return orderDetailsModel;
  }

  @override
  Future<ResponseModel> acceptOrder(int? orderID) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.acceptOrderUri,
        {"_method": "put", 'token': _getUserToken(), 'order_id': orderID},
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      // Enhanced error handling for structured error responses
      String errorMessage = _extractErrorMessage(response);
      responseModel = ResponseModel(false, errorMessage);

      // Store the full error response for detailed error handling
      responseModel.errorResponse = response.body;
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> cancelOrder(int? orderID, {String? reason}) async {
    ResponseModel responseModel;
    final Map<String, dynamic> payload = {
      "_method": "put",
      'token': _getUserToken(),
      'order_id': orderID,
    };
    if (reason != null && reason.isNotEmpty) {
      payload['reason'] = reason;
    }

    Response response = await apiClient.postData(
        AppConstants.cancelOrderUri, payload,
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      String errorMessage = _extractErrorMessage(response);
      responseModel = ResponseModel(false, errorMessage);
      responseModel.errorResponse = response.body;
    }
    return responseModel;
  }

  /// Extract meaningful error message from API response
  String _extractErrorMessage(Response response) {
    try {
      if (response.body is Map<String, dynamic>) {
        final body = response.body as Map<String, dynamic>;

        // Check for structured error response
        if (body.containsKey('errors') && body['errors'] is List) {
          final errors = body['errors'] as List;
          if (errors.isNotEmpty && errors.first is Map<String, dynamic>) {
            final firstError = errors.first as Map<String, dynamic>;
            return firstError['message'] ??
                response.statusText ??
                'order_acceptance_failed';
          }
        }

        // Check for direct message field
        if (body.containsKey('message')) {
          return body['message'] ??
              response.statusText ??
              'order_acceptance_failed';
        }
      }
    } catch (e) {
      // Fallback to status text if parsing fails
    }

    return response.statusText ?? 'order_acceptance_failed';
  }

  @override
  List<IgnoreModel> getIgnoreList() {
    List<IgnoreModel> ignoreList = [];
    List<String> stringList =
        sharedPreferences.getStringList(AppConstants.ignoreList) ?? [];
    for (var ignore in stringList) {
      ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
    }
    return ignoreList;
  }

  @override
  void setIgnoreList(List<IgnoreModel> ignoreList) {
    List<String> stringList = [];
    for (var ignore in ignoreList) {
      stringList.add(jsonEncode(ignore.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.ignoreList, stringList);
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  Map<String, String> _orderNoCacheHeaders() {
    final headers = apiClient.mainHeaders;
    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
    headers['Pragma'] = 'no-cache';
    headers['Expires'] = '0';
    return headers;
  }

  void _logOrderRequest({
    required String endpoint,
    required String uri,
    required String method,
    required Map<String, String> headers,
    required Map<String, String> queryParams,
  }) {
    if (!kDebugMode) return;
    // SR-02: strip token from logged URL to avoid leaking credentials
    final String safeUri = uri.replaceAll(RegExp(r'token=[^&]*'), 'token=***');
    debugPrint('[REQUEST] ${AppConstants.baseUrl}$safeUri');
    debugPrint('method: $method, endpoint: $endpoint');
  }

  void _logOrderResponse({
    required String endpoint,
    required Response response,
  }) {
    if (!kDebugMode) return;
    debugPrint('[RESPONSE] endpoint=$endpoint status=${response.statusCode}');
  }

  List<dynamic> _extractOrderList(dynamic body) {
    if (body == null) return [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      if (body['orders'] is List) return body['orders'] as List;
      if (body['data'] is List) return body['data'] as List;
    }
    return [];
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<ResponseModel> submitInvoice(
      int orderId, double amount, XFile? image) async {
    List<MultipartBody> attachments = [];
    if (image != null) {
      attachments.add(MultipartBody('image', image));
    }
    Response response = await apiClient.postMultipartData(
        AppConstants.submitInvoiceUri,
        {
          'token': _getUserToken(),
          'order_id': orderId.toString(),
          'amount': amount.toString(),
        },
        attachments,
        handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message'] ?? 'success');
    }
    return ResponseModel(false, response.statusText ?? 'failed');
  }

  @override
  Future<bool> setPriceService(int orderId, double price) {
    return apiClient.postData("/api/v1/delivery-man/request", {
      "token": _getUserToken(),
      "price": price,
      "order_id": orderId,
      "delivery_man_id": Get.find<ProfileController>().profileModel?.id
    }).then((onValue) {
      if (kDebugMode) {
        debugPrint('[setPriceService] order_id=$orderId status=${onValue.statusCode}');
      }
      if (onValue.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
  }
}
