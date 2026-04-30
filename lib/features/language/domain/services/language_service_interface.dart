import 'package:flutter/material.dart';
import 'package:shellafood_delivery/features/language/domain/models/language_model.dart';

abstract class LanguageServiceInterface {
  bool setLTR(Locale locale);
  void updateHeader(Locale locale);
  Locale getLocaleFromSharedPref();
  int setSelectedLanguageIndex(List<LanguageModel> languages, Locale locale);
  void saveLanguage(Locale locale);

  /// Whether the user has already completed the first-launch language picker.
  bool hasSeenLanguageIntro();

  /// Marks the first-launch language picker as completed.
  Future<void> markLanguageIntroSeen();
}
