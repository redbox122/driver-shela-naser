import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkInfoHelper {
  final Connectivity connectivity;
  NetworkInfoHelper(this.connectivity);

  Future<bool> get isConnected async {
    List<ConnectivityResult> results = await connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        final result = results.first;
        if (Get.find<SplashController>().firstTimeConnectionCheck) {
          Get.find<SplashController>().setFirstTimeConnectionCheck(false);
        } else {
          bool isNotConnected = result == ConnectivityResult.none;
          isNotConnected
              ? const SizedBox()
              : ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: isNotConnected ? Colors.red : Colors.green,
            duration: Duration(seconds: isNotConnected ? 6000 : 3),
            content: Text(
              isNotConnected ? 'no_connection' : 'connected',
              textAlign: TextAlign.center,
            ),
          ));
        }
      }
    });
  }
}
