import 'package:shellafood_delivery/features/language/domain/models/language_model.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/features/language/domain/services/language_service_interface.dart';

class LocalizationController extends GetxController implements GetxService {
  final LanguageServiceInterface languageServiceInterface;
  LocalizationController({required this.languageServiceInterface}) {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(AppConstants.languages[0].languageCode!,
      AppConstants.languages[0].countryCode);
  Locale get locale => _locale;

  bool _isLtr = true;
  bool get isLtr => _isLtr;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  List<LanguageModel> _languages = [];
  List<LanguageModel> get languages => _languages;

  void setLanguage(Locale locale) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = languageServiceInterface.setLTR(_locale);
    languageServiceInterface.updateHeader(_locale);
    saveLanguage(_locale);
    update();
  }

  void loadCurrentLanguage() async {
    _locale = languageServiceInterface.getLocaleFromSharedPref();
    _isLtr = _locale.languageCode != 'ar';
    _selectedIndex = languageServiceInterface.setSelectedLanguageIndex(
        AppConstants.languages, _locale);
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  void saveLanguage(Locale locale) async {
    languageServiceInterface.saveLanguage(locale);
  }

  void setSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  /// True when the user has already completed the first-launch language
  /// selection screen at least once. Used by the splash flow to decide
  /// whether the language picker should be shown before normal routing.
  bool hasSeenLanguageIntro() {
    return languageServiceInterface.hasSeenLanguageIntro();
  }

  /// Persists that the first-launch language selection is done so the
  /// language picker will not block app startup again.
  Future<void> markLanguageIntroSeen() async {
    await languageServiceInterface.markLanguageIntroSeen();
  }
}
