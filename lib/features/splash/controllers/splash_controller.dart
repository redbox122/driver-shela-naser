import 'package:shellafood_delivery/common/models/config_model.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/splash/domain/services/splash_service_interface.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  int? _storeCategoryID;
  int? get storeCategoryID => _storeCategoryID;

  String? _storeType;
  String? get storeType => _storeType;

  Map<String, dynamic>? _data = {};

  Duration _serverTimeOffset = Duration.zero;

  DateTime get currentTime => DateTime.now().add(_serverTimeOffset);

  void updateServerTime(DateTime serverTime) {
    _serverTimeOffset = serverTime.difference(DateTime.now());
  }

  Module getModuleConfig(String? moduleType) {
    final Map<String, dynamic>? moduleConfig = _data?['module_config'];
    dynamic rawModule;
    if (moduleType != null &&
        moduleConfig != null &&
        moduleConfig.containsKey(moduleType)) {
      rawModule = moduleConfig[moduleType];
    } else {
      rawModule = null;
    }

    if (rawModule is Map<String, dynamic>) {
      Module module = Module.fromJson(rawModule);
      module.newVariation = moduleType == 'food';
      return module;
    }

    // Fallback to empty module when config missing to avoid crashes.
    Module module = Module();
    module.newVariation = moduleType == 'food';
    return module;
  }

  Future<bool> getConfigData() async {
    Response response = await splashServiceInterface.getConfigData();
    bool isSuccess = false;
    if (response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      isSuccess = true;
    } else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Module getModule(String? moduleType) {
    final Map<String, dynamic>? moduleConfig = _data?['module_config'];
    dynamic rawModule;
    if (moduleType != null &&
        moduleConfig != null &&
        moduleConfig.containsKey(moduleType)) {
      rawModule = moduleConfig[moduleType];
    } else {
      rawModule = null;
    }
    if (rawModule is Map<String, dynamic>) {
      return Module.fromJson(rawModule);
    }
    return Module();
  }

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }
}
