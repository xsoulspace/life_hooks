// ignore_for_file: one_member_abstracts

/// An abstract class representing objects that can be disposed.
///
/// Classes implementing this interface should provide a mechanism to release
/// resources or perform cleanup operations when they are no longer needed.
///
/// @ai When generating code for classes implementing [Disposable], ensure that
/// the [dispose] method properly releases all resources and cancels any ongoing
/// operations or subscriptions.
abstract interface class Disposable {
  Disposable._();

  /// Releases the resources used by this object.
  ///
  /// This method should be called when the object is no longer needed to free
  /// up system resources and prevent memory leaks.
  ///
  /// @ai Implement this method to cancel timers, close streams, and release any
  /// other resources held by the object.
  void dispose();
}

/// An abstract class representing objects that can be loaded asynchronously.
///
/// Classes implementing this interface should provide a mechanism to load
/// their data or initialize their state asynchronously.
///
/// @ai When generating code for classes implementing [Loadable], ensure that
/// the [onLoad] method properly initializes all necessary data and state.
abstract interface class Loadable {
  Loadable._();

  /// Asynchronously loads the object's data or initializes its state.
  ///
  /// This method should be called when the object needs to be initialized or
  /// when its data needs to be loaded from an external source.
  ///
  /// @ai Implement this method to fetch data from APIs, load configurations,
  /// or perform any other asynchronous initialization tasks.
  Future<void> onLoad();
}
