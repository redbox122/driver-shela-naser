import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shellafood_delivery/api/api_checker.dart';
import 'package:shellafood_delivery/common/models/error_response.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    // SR-02: Do not log the auth token.
    updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
  }

  void updateHeader(String? token, String? languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      'Authorization': 'Bearer $token'
    };
  }

  Map<String, String> get mainHeaders => Map<String, String>.from(_mainHeaders);

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    try {
      assert(() {
        debugPrint('====> API Call: $uri');
        return true;
      }());
      http.Response response = await http
          .get(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      assert(() {
        debugPrint('====> API Call: $uri');
        return true;
      }());
      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      assert(() {
        debugPrint('====> API Error (postData): $e');
        return true;
      }());
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      assert(() {
        debugPrint('====> API Call: $uri (multipart, ${multipartBody.length} files)');
        return true;
      }());
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (foundation.kIsWeb) {
            // P-03: read bytes once, reuse the same Uint8List for both
            // length and stream — previously the file was read twice.
            final Uint8List bytes = await multipart.file!.readAsBytes();
            http.MultipartFile part = http.MultipartFile(
              multipart.key,
              Stream.value(bytes),
              bytes.length,
              filename: basename(multipart.file!.path),
              contentType: MediaType('image', 'jpg'),
            );
            request.files.add(part);
          } else {
            File file = File(multipart.file!.path);
            request.files.add(http.MultipartFile(
              multipart.key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: file.path.split('/').last,
            ));
          }
        }
      }
      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      assert(() {
        debugPrint('====> API Call: $uri');
        return true;
      }());
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      assert(() {
        debugPrint('====> API Call: $uri');
        return true;
      }());
      http.Response response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(
      http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.errors![0].message);
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    _updateServerTimeFromBody(body);
    assert(() {
      debugPrint(
          '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
      return true;
    }());
    if (handleError) {
      if (response0.statusCode == 200) {
        return response0;
      } else {
        _logApiError(response0, uri);
        ApiChecker.checkApi(response0);
        return const Response();
      }
    } else {
      return response0;
    }
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

void _logApiError(Response response, String uri) {
  assert(() {
    final String url = response.request?.url.toString() ?? '';
    final int? status = response.statusCode;
    final Map<String, String>? headers = response.headers;
    final String body = response.bodyString ?? response.body?.toString() ?? '';

    final String prettyBody = _tryPrettyJson(body);
    final String headerDump = headers == null
        ? ''
        : headers.entries
            .map((e) => '${e.key}: ${_maskSensitiveHeaderValue(e.key, e.value)}')
            .join('\n');

    debugPrint('\x1B[32m====> API Error\x1B[0m');
    debugPrint('\x1B[32mStatus: $status\x1B[0m');
    if (url.isNotEmpty) {
      debugPrint('\x1B[32mURL: $url\x1B[0m');
    } else {
      debugPrint('\x1B[32mURL: ${AppConstants.baseUrl + uri}\x1B[0m');
    }
    if (headerDump.isNotEmpty) {
      debugPrint('\x1B[32mHeaders:\n$headerDump\x1B[0m');
    }
    if (prettyBody.isNotEmpty) {
      debugPrint('\x1B[32mBody:\n$prettyBody\x1B[0m');
    }

    final String? requestId = _findRequestId(headers);
    if (requestId != null) {
      debugPrint('\x1B[32mRequest-ID: $requestId\x1B[0m');
    }
    return true;
  }());
}

String _maskSensitiveHeaderValue(String key, String value) {
  final String lowerKey = key.toLowerCase();
  if (lowerKey == 'authorization' ||
      lowerKey == 'cookie' ||
      lowerKey == 'set-cookie' ||
      lowerKey == 'x-api-key') {
    return '***masked***';
  }
  return value;
}

// DC-03: _updateServerTimeFromHeaders was never called; removed.

bool _updateServerTimeFromBody(dynamic body) {
  final dynamic rawValue = _extractServerTimeRaw(body);
  if (rawValue == null) {
    return false;
  }
  final DateTime? serverTime = _parseServerTimeValue(rawValue);
  if (serverTime == null) {
    return false;
  }
  assert(() {
    debugPrint('Server time raw: $rawValue');
    debugPrint('Server time parsed: $serverTime');
    return true;
  }());
  if (Get.isRegistered<SplashController>()) {
    final splash = Get.find<SplashController>();
    splash.updateServerTime(serverTime);
    assert(() {
      final int offsetMs =
          splash.currentTime.difference(DateTime.now()).inMilliseconds;
      debugPrint('Server time offset ms: $offsetMs');
      return true;
    }());
  }
  return true;
}

dynamic _extractServerTimeRaw(dynamic body) {
  if (body is Map<String, dynamic>) {
    final dynamic direct = body['server_time'];
    if (direct != null) return direct;

    final dynamic data = body['data'];
    if (data is Map<String, dynamic>) {
      final dynamic nested = data['server_time'];
      if (nested != null) return nested;
    }
  }
  return null;
}

DateTime? _parseServerTimeValue(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return _dateTimeFromEpoch(value);
  }
  if (value is num) {
    return _dateTimeFromEpoch(value.toInt());
  }
  if (value is String) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    try {
      final String normalized = _ensureTimezoneOffset(trimmed);
      return DateTime.parse(normalized);
    } catch (_) {
      return null;
    }
  }
  return null;
}

DateTime _dateTimeFromEpoch(int epoch) {
  final int ms = epoch > 1000000000000 ? epoch : epoch * 1000;
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

String _ensureTimezoneOffset(String value) {
  final String trimmed = value.trim();
  final bool hasZulu = trimmed.endsWith('Z');
  final bool hasOffset =
      RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(trimmed) ||
          RegExp(r'[+-]\d{4}$').hasMatch(trimmed);
  if (hasZulu || hasOffset) {
    return trimmed;
  }

  final Duration offset = DateTime.now().timeZoneOffset;
  final String sign = offset.isNegative ? '-' : '+';
  final int hours = offset.inHours.abs();
  final int minutes = (offset.inMinutes.abs()) % 60;
  final String hh = hours.toString().padLeft(2, '0');
  final String mm = minutes.toString().padLeft(2, '0');
  return '$trimmed$sign$hh:$mm';
}

String _tryPrettyJson(String input) {
  try {
    final dynamic decoded = jsonDecode(input);
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(decoded);
  } catch (_) {
    return input;
  }
}

String? _findRequestId(Map<String, String>? headers) {
  if (headers == null) return null;
  for (final entry in headers.entries) {
    final key = entry.key.toLowerCase();
    if (key == 'x-request-id' || key == 'x-correlation-id' || key == 'request-id') {
      return entry.value;
    }
  }
  return null;
}
