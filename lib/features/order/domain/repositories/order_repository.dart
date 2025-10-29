import 'dart:convert';
import 'package:get/get.dart';
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
    Response response = await apiClient.getData(
        '${AppConstants.currentOrderUri}${_getUserToken()}&order_id=$id');
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
    Response response = await apiClient
        .getData(AppConstants.currentOrdersUri + _getUserToken());
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
    Response response =
        await apiClient.getData(AppConstants.latestOrdersUri + _getUserToken());
    if (response.statusCode == 200) {
      latestOrderList = [];
      response.body
          .forEach((order) => latestOrderList!.add(OrderModel.fromJson(order)));
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
    List<OrderDetailsModel>? orderDetailsModel;
    Response response = await apiClient.getData(
        '${AppConstants.orderDetailsUri}${_getUserToken()}&order_id=$orderID');
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
  Future<bool> setPriceService(int orderId, double price) {
    return apiClient.postData("/api/v1/delivery-man/request", {
      "token": _getUserToken(),
      "price": price,
      "order_id": orderId,
      "delivery_man_id": Get.find<ProfileController>().profileModel?.id
    }).then((onValue) {
      print({
        "token": _getUserToken(),
        "price": price,
        "order_id": orderId,
        "delivery_man_id": Get.find<ProfileController>().profileModel?.id
      });
      print("onValue.body${onValue.body}");
      if (onValue.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
  }
}
