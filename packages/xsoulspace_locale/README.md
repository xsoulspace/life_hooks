# Xsoulspace Locale

I've developed this package as I've tried to simplify work with localizations.
The most complicated problem with all packages - it is easy to create strings and translations, but quite hard to manage them.

To fix this problem this package uses LocalizedMap which utilizes current locale to get the string.

Also added boilerplate for keyboard languages and languages changes.

## Overview

Boilerplate for localization, keyboard languages, locale changes to use side by side with Intl or other localization solutions.

## Features

- **Support for multiple languages**: Manage multiple languages for your application.
- **Dynamic locale switching**: Dynamically switch between locales at runtime.
- **Keyboard language management**: Manage keyboard languages for different locales.
- **Localized string management**: Manage localized strings for different languages.

## Setup

### Step 1: Add the package to your `pubspec.yaml`

```yaml
dependencies:
  xsoulspace_locale: ^0.0.2
```

### Step 2: Import the package in your Dart code

```dart
import 'package:xsoulspace_locale/xsoulspace_locale.dart';
```

### Step 3: Initialize the `LocalizationConfig`

You can initialize the `LocalizationConfig` at the start of your application
or in any widgets before using `MaterialApp` or `CupertinoApp`.

```dart
void main() {
  final languages = (
    en: UiLanguage('en', 'English'),
    es: UiLanguage('es', 'Español'),
    fr: UiLanguage('fr', 'Français'),
  );

  LocalizationConfig.initialize(
    LocalizationConfig(
      supportedLanguages: [
        languages.en,
        languages.es,
        languages.fr,
      ],
      fallbackLanguage: languages.en,
    ),
  );


  // Now you can use KeyboardLanguage like this:
  final englishKeyboard = KeyboardLanguage.fromLanguage(languages.en);
  final spanishKeyboard = KeyboardLanguage.fromLanguage(languages.es);
  final allKeyboardLanguages = KeyboardLanguage.values;
  final defaultKeyboard = KeyboardLanguage.defaultKeyboardLanguage;

  runApp(MyApp());
}
```

## Usage

### Locale Management

Use `LocaleLogic` to manage locale changes:

```dart
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => _MyAppState();
}

class MyAppState extends State<MyApp> {
  final LocaleLogic localeLogic = LocaleLogic();
  Locale currentLocale = Locales.fallback;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: currentLocale,
      localizationsDelegates: [
        // Your localization delegates
      ],
      supportedLocales: LocalizationConfig.instance.supportedLocales,
      home: MyHomePage(),
    );
  }

  Future<void> changeLocale(Locale newLocale) async {
    final result = await localeLogic.updateLocale(
      newLocale: newLocale,
      oldLocale: currentLocale,
      uiLocale: currentLocale,
      onLocaleChanged: S.delegate.load, // S is your generated localization class
    );
    if (result != null) {
      setState(() {
        currentLocale = result.uiLocale;
      });
    }
  }
}
```

### Localized Strings

To manage localized strings, use the `LocalizedMap` class. Here's an example of how to create a `LocalizedMap` and retrieve a localized string based on the current locale:

```dart
final localizedMap = LocalizedMap(
  value: {
    languages.en: 'Hello',
    languages.es: 'Hola',
    languages.fr: 'Bonjour',
  },
);

// Retrieve the greeting based on the current locale
String greeting = localizedMap.getValue(context.locale);
```

### Keyboard Language

For managing keyboard languages, use the `KeyboardLanguage` class. Here's an example of how to get the current keyboard language based on the current locale:

```dart
// Get the current keyboard language based on the current locale
final currentKeyboardLanguage = KeyboardLanguage.defaultKeyboardLanguage;
// or
final currentKeyboardLanguage = KeyboardLanguage.fromLanguage(
  UiLanguage.byLocale(context.locale),
);
```

## Best Practices

1. **Initialize `LocalizationConfig`**: Always initialize `LocalizationConfig` before using any other classes from this package.
2. **Use `LocaleLogic` for locale changes**: Use `LocaleLogic` to handle locale changes and ensure proper updates across your app.
3. **Manage localized strings with `LocalizedMap`**: Utilize `LocalizedMap` for managing strings that need to be localized.
4. **Consider `KeyboardLanguage` for input methods**: Consider using `KeyboardLanguage` when dealing with input methods that may vary by language.
5. **Update supported languages and locales**: Regularly update your supported languages and locales in the `LocalizationConfig` as your app expands to new regions.

## Note

This package is designed to work alongside Flutter's built-in localization system. It provides additional functionality for managing locales and localized content but does not replace Flutter's `Localizations` widget or localization delegates.

## Contributing

Contributions to improve this package are welcome. Please feel free to submit issues, feature requests, or pull requests on our GitHub repository.

## License

This package is released under the MIT License. See the LICENSE file for details.
