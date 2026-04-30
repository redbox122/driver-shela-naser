import 'package:flutter/material.dart';
import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class LanguageRepositoryInterface extends RepositoryInterface {
  void updateHeader(Locale locale);
  Locale getLocaleFromSharedPref();
  void saveLanguage(Locale locale);

  /// Returns true once the user has explicitly chosen a language at least
  /// once (i.e. has seen and dismissed the first-launch language screen).
  bool hasSeenLanguageIntro();

  /// Persists that the first-launch language screen has been completed so
  /// it is not shown again on subsequent app starts.
  Future<void> markLanguageIntroSeen();
}
