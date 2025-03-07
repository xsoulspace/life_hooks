<!-- PROMPT for doc
Add detailed documentation comments to the following classes, focusing on their purpose and usage. -->

This package is a collection of useful utilities, extensions, and helpers that I often use in my projects. It is intended for personal and commercial projects, providing reusable components that enhance productivity and maintainability.
Please note: this package is kinda stable, but some parts may be unstable (I've marked them with unstable tag) or lacks documentation.

# Usage

To use the `xsoulspace_foundation` package in your Flutter project, follow these steps:

1. **Add Dependency**: Include the package in your `pubspec.yaml` file:

   ```yaml
   dependencies:
     xsoulspace_foundation: ^0.0.1
   ```

2. **Import the Package**: Import the necessary files in your Dart code:

   ```dart
   import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
   ```

3. Create an instance of `AppStoreUtils`:

   ```dart
   final appStoreUtils = AppStoreUtils();
   ```

4. Get the installation source:

   ```dart
   final installSource = await appStoreUtils.getInstallationSource();
   ```

5. Use the `InstallSource` enum to check the store source:

   ```dart
   switch (installSource) {
      case InstallSource.androidGooglePlay:
         // Android Google Play specific code
         break;
      case InstallSource.androidAppGallery:
         // Android App Gallery specific code
         break;
      case InstallSource.androidSamsungGalaxyStore:
         // Android Samsung Galaxy Store specific code
         break;
      // etc...
   }
   ```

   or

   ```dart
   if (installSource.isAndroid) {
      // Android-specific code
   } else if (installSource.isAppleIos) {
      // Apple-specific code
   } else if (installSource.isWeb) {
      // Web-specific code
   }
   ```

# Overview

The xsoulspace_foundation package provides a set of utility classes and functions to enhance your Flutter and Dart applications.

## Extensions

TODO:

## Models

TODO:

## Utils

### Infinite Scroll Pagination Utils - compliments `infinite_scroll_pagination` package

The `infinite_scroll_pagination_utils` compliments `infinite_scroll_pagination` package and provides fast plug in and play solution.
See more in [infinite_scroll_pagination_utils/README.md](lib/src/utils/infinite_scroll_pagination_utils/README.md)

### App Store Utils (Unstable) - TODO

The `app_store_utils` module offers a convenient way to determine source from where your app was installed from.
Base on [store_checker](https://pub.dev/packages/store_checker) package.

> **Note**: This feature is still in development and may not be fully stable.

This information can be crucial for various reasons:

1. **Analytics**: Track which app stores or distribution methods are most popular among your users.
2. **Feature Customization**: Enable or disable certain features based on the installation source.
3. **Store-Specific Functionality**: Implement store-specific features or behaviors.
4. **Troubleshooting**: Identify potential issues related to specific distribution channels.

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
