// ignore_for_file: invalid_annotation_target
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
  const NamedLocale({
    required this.name,
    required this.locale,
  });

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

// ignore: avoid_annotating_with_dynamic
/// Converts a dynamic map to a map of [UiLanguage]s and their corresponding
/// values.
///
/// Throws an [UnimplementedError] if the input is neither a [String] nor
/// a [Map].
///
/// [map] The dynamic input to convert.
Map<UiLanguage, String> localeValueFromMap(final dynamic map) {
  if (map is String) {
    return {};
  } else if (map is Map) {
    if (map.isEmpty) {
      return {
        for (final lang in LocalizationConfig.instance.supportedLanguages)
          lang: '',
      };
    }
    final localeMap = <UiLanguage, String>{};
    for (final key in map.keys) {
      final language = UiLanguage.byCode(key);
      if (language == null) continue;
      localeMap[language] = map[key];
    }
    return localeMap;
  } else {
    throw UnimplementedError('localeValueFromMap $map');
  }
}

/// Converts a map of [UiLanguage]s and their corresponding values to a
/// string map.
///
/// [locales] The map of languages to convert.
Map<String, String> localeValueToMap(final Map<UiLanguage, String> locales) =>
    locales.map(
      (final key, final value) => MapEntry(key.code, value),
    );

/// A class representing a localized map of values for different languages.
///
/// This class is used to manage localized strings associated with
/// different [UiLanguage]s.
@immutable
class LocalizedMap extends Equatable {
  const LocalizedMap({
    required this.value,
  });

  /// Creates a [LocalizedMap] from a JSON map.
  ///
  /// [json] The JSON map to convert.
  factory LocalizedMap.fromJson(final Map<String, dynamic> json) =>
      LocalizedMap(value: localeValueFromMap(json['value']));

  /// Creates a [LocalizedMap] from a JSON value map.
  ///
  /// If the JSON does not contain a 'value' key, it wraps the entire
  /// JSON in a new map with 'value' as the key.
  ///
  /// [json] The JSON map to convert.
  factory LocalizedMap.fromJsonValueMap(final Map<String, dynamic> json) {
    if (json.containsKey('value')) {
      return LocalizedMap.fromJson(json);
    } else {
      return LocalizedMap.fromJson({'value': json});
    }
  }

  /// Creates a [LocalizedMap] initialized with empty values for all languages.
  factory LocalizedMap.fromLanguages() => LocalizedMap(
        value: {
          for (final lang in LocalizationConfig.instance.supportedLanguages)
            lang: '',
        },
      );

  final Map<UiLanguage, String> value;

  /// Converts the [LocalizedMap] to a JSON value map.
  ///
  /// [map] The [LocalizedMap] to convert.
  static Map<String, dynamic> toJsonValueMap(final LocalizedMap map) =>
      {'value': localeValueToMap(map.value)};

  /// An empty [LocalizedMap].
  static const empty = LocalizedMap(value: {});

  /// Retrieves the localized value for a given [Locale].
  ///
  /// [locale] The locale to get the value for.
  String getValue(final Locale locale) =>
      getValueByLanguage(UiLanguage.byLocale(locale));

  /// Retrieves the localized value for a given [UiLanguage].
  ///
  /// If no language is provided, it defaults to the current language.
  ///
  /// [language] The language to get the value for.
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

  Map<String, dynamic> toJson() => {
        'value': localeValueToMap(value),
      };

  LocalizedMap copyWith({
    final Map<UiLanguage, String>? value,
  }) =>
      LocalizedMap(
        value: value ?? this.value,
      );

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'LocalizedMap(value: $value)';
}
