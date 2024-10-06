import 'package:flutter/material.dart';

import 'localization.dart';

/// A class to configure the localization package.
class LocalizationConfig {
  LocalizationConfig({
    required this.supportedLanguages,
    required this.fallbackLanguage,
  }) : supportedLocales =
            supportedLanguages.map((final lang) => lang.locale).toList();

  final List<UiLanguage> supportedLanguages;
  final List<Locale> supportedLocales;
  final UiLanguage fallbackLanguage;

  static LocalizationConfig? _instance;

  // ignore: use_setters_to_change_properties
  static void initialize(final LocalizationConfig config) {
    _instance = config;
  }

  static LocalizationConfig get instance {
    if (_instance == null) {
      throw StateError('LocalizationConfig has not been initialized');
    }
    return _instance!;
  }

  /// Checks if the given locale is supported.
  bool isLocaleSupported(final Locale locale) =>
      supportedLocales.contains(locale) ||
      supportedLocales.any(
        (final supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode,
      );

  /// Checks if the given language is supported.
  bool isLanguageSupported(final UiLanguage language) =>
      supportedLanguages.contains(language) ||
      supportedLanguages.any(
        (final supportedLanguage) => supportedLanguage.code == language.code,
      );
}
