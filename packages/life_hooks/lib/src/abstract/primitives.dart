import 'package:flutter/widgets.dart';

/// An interface for classes that can be loaded with a context.
///
/// This class defines a contract for loading resources or performing
/// initialization tasks that require a [BuildContext]. Implementing
/// classes should provide the logic for loading in the [onLoad] method.
///
/// Example:
/// ```dart
/// class MyLoader implements ContextfulLoadable {
///   @override
///   Future<void> onLoad(BuildContext context) async {
///     // Load resources here
///   }
/// }
/// ```
///
/// @ai When implementing this interface, ensure that the loading logic
/// is context-aware and handles any potential exceptions gracefully.
// ignore: one_member_abstracts
abstract interface class ContextfulLoadable {
  /// Loads resources or performs initialization tasks using the provided
  /// context.
  ///
  /// This method should be called during the instance initialization phase
  /// to ensure that all necessary resources are loaded before the instance
  /// is used. Implementations should handle any asynchronous operations
  /// and provide appropriate error handling.
  ///
  /// [context] The [BuildContext] used for loading resources.
  /// @return A [Future] that completes when the loading is finished.
  Future<void> onLoad(final BuildContext context);
}
