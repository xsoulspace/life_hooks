// ignore_for_file: invalid_annotation_target, avoid_annotating_with_dynamic
part of 'localization.dart';

/// A class representing a named locale for user selection.
///
/// This class is used to display a list of supported [UiLanguage]s
/// and allows the user to choose one of them.
///
/// Use [NamedLocale] to create instances that pair a user-friendly
/// name with a corresponding [Locale].
///
/// ```dart
/// final namedLocale = NamedLocale(name: 'English',
/// locale: Locale('en', 'US'));
/// ```
///
/// @ai When using this class, ensure to provide meaningful names
/// for better user experience.
@immutable
class NamedLocale extends Equatable {
  /// Creates a [NamedLocale] instance.
  ///
  /// The [name] is the display name for the locale, and [locale]
  /// is the actual locale used for localization.
  const NamedLocale({required this.name, required this.locale});

  /// The display name of the locale shown to the user.
  final String name;

  /// The locale used as the value to change the application's locale.
  final Locale locale;

  /// The language code of the locale.
  ///
  /// This is equivalent to [Locale.languageCode] and can be used
  /// to retrieve the language code for the current locale.
  String get code => locale.languageCode;

  @override
  List<Object?> get props => [name, locale];

  @override
  String toString() => 'NamedLocale(name: $name, locale: $locale)';
}

/// Converts a language code string to a corresponding [Locale].
///
/// Returns null if the provided [languageCode] is null or empty.
///
/// [languageCode] The language code to convert to a [Locale].
Locale? localeFromString(final String? languageCode) {
  if (languageCode == null || languageCode.isEmpty) return null;
  return UiLanguage.byCode(languageCode)?.locale;
}

/// Converts a [Locale] to its corresponding language code string.
///
/// Returns null if the provided [locale] is null.
///
/// [locale] The locale to convert to a language code.
String? localeToString(final Locale? locale) => locale?.languageCode;

/// Converts a dynamic map to a map of [UiLanguage]s and their corresponding
/// values.
///
/// Throws an [UnimplementedError] if the input is neither a [String] nor
/// a [Map].
///
/// [map] The dynamic input to convert.
LocalizedMap localeValueFromMap(final dynamic map) {
  if (map case String _) {
    return LocalizedMap.fromLanguages();
  } else if (map case final Map map) {
    if (map.isEmpty) {
      return LocalizedMap.fromLanguages();
    }
    final localeMap = <UiLanguage, String>{};
    for (final key in map.keys) {
      final language = UiLanguage.byCode(key);
      if (language == null) continue;
      localeMap[language] = map[key];
    }
    return LocalizedMap(localeMap);
  } else {
    throw UnimplementedError('localeValueFromMap $map');
  }
}

/// Converts a map of [UiLanguage]s and their corresponding values to a
/// string map.
///
/// [locales] The map of languages to convert.
Map<String, String> localeValueToMap(final Map<UiLanguage, String> locales) =>
    locales.map((final key, final value) => MapEntry(key.code, value));

/// Extension type that represents a localized map of values for
/// different languages.
///
/// Use it to manage localized strings associated with different [UiLanguage]s.
/// Provides type-safe JSON handling and zero runtime overhead.
extension type const LocalizedMap(Map<UiLanguage, String> value) {
  /// Creates a [LocalizedMap] from a JSON map.
  factory LocalizedMap.fromJson(final dynamic json) {
    if (json case {'value': final dynamic value}) {
      return LocalizedMap(jsonDecodeMapAs(value));
    } else {
      return LocalizedMap(jsonDecodeMapAs(json));
    }
  }

  /// Creates a [LocalizedMap] initialized with empty values for all languages.
  factory LocalizedMap.fromLanguages() => LocalizedMap({
    for (final lang in LocalizationConfig.instance.supportedLanguages) lang: '',
  });

  /// Converts the [LocalizedMap] to a JSON value map.
  static Map<String, dynamic> toJsonValueMap(final LocalizedMap map) => {
    'value': localeValueToMap(map.value),
  };

  Map<String, dynamic> toJson() => localeValueToMap(value);

  /// An empty [LocalizedMap].
  static const empty = LocalizedMap({});

  /// Retrieves the localized value for a given [Locale].
  String getValue(final Locale locale) =>
      getValueByLanguage(UiLanguage.byLocale(locale));

  /// Retrieves the localized value for a given [UiLanguage].
  /// If no language is provided, it defaults to the current language.
  String getValueByLanguage([final UiLanguage? language]) {
    final lang = language ?? getCurrentLanguage();
    return value[lang] ??
        value[LocalizationConfig.instance.fallbackLanguage] ??
        '';
  }

  /// Retrieves the current language based on the locale.
  static UiLanguage getCurrentLanguage() {
    final languageCode = getLanguageCodeByStr(Intl.getCurrentLocale());
    return UiLanguage.byCodeWithFallback(languageCode);
  }

  LocalizedMap copyWith({final Map<UiLanguage, String>? value}) =>
      LocalizedMap(value ?? this.value);
}
