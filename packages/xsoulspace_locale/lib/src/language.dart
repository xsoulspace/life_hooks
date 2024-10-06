// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

part of 'localization.dart';

/// A class that holds the supported locales for the application.
class Locales {
  Locales._();

  static List<Locale> get values =>
      LocalizationConfig.instance.supportedLocales;
  static Locale get fallback =>
      LocalizationConfig.instance.fallbackLanguage.locale;

  /// Returns the corresponding [Locale] for a given [UiLanguage].
  static Locale byLanguage(final UiLanguage language) => Locale(language.code);
}

/// A class representing keyboard language options.
class KeyboardLanguage extends Equatable {
  const KeyboardLanguage._(this.code);

  factory KeyboardLanguage.fromLanguage(final UiLanguage? language) =>
      language != null
          ? KeyboardLanguage.of(language.code)
          : defaultKeyboardLanguage;

  factory KeyboardLanguage.of(final String code) =>
      _values.putIfAbsent(code, () => KeyboardLanguage._(code));

  // ignore: prefer_constructors_over_static_methods
  static KeyboardLanguage get defaultKeyboardLanguage =>
      KeyboardLanguage.fromLanguage(
        LocalizationConfig.instance.fallbackLanguage,
      );

  final String code;

  static final Map<String, KeyboardLanguage> _values = {};

  static List<KeyboardLanguage> get values =>
      LocalizationConfig.instance.supportedLanguages
          .map(KeyboardLanguage.fromLanguage)
          .toList();

  @override
  List<Object?> get props => [code];

  @override
  String toString() => 'KeyboardLanguage($code)';
}

/// Returns the language code from a given language name.
String getLanguageCodeByStr(final String language) => language.split('_').first;

/// A map that associates each language with its corresponding named locale.
Map<UiLanguage, NamedLocale> get namedLocalesMap => Map.fromEntries(
      LocalizationConfig.instance.supportedLanguages.map(
        (final lang) => MapEntry(
          lang,
          NamedLocale(
            name: lang.name,
            locale: Locales.byLanguage(lang),
          ),
        ),
      ),
    );

/// A class representing a language.
class UiLanguage extends Equatable {
  const UiLanguage(this.code, this.name);

  final String code;
  final String name;
  static List<UiLanguage> get all =>
      LocalizationConfig.instance.supportedLanguages;
  static UiLanguage? byCode(final String languageCode) =>
      LocalizationConfig.instance.supportedLanguages.firstWhereOrNull(
        (final lang) => lang.code == languageCode,
      );
  static UiLanguage byCodeWithFallback(final String languageCode) =>
      byCode(languageCode) ?? LocalizationConfig.instance.fallbackLanguage;
  static UiLanguage byLocale(final Locale locale) =>
      byCodeWithFallback(locale.languageCode);

  Locale get locale => Locales.byLanguage(this);

  @override
  List<Object?> get props => [code];
}

extension UiLanguageX on Locale {
  UiLanguage get language => UiLanguage.byLocale(this);
}
