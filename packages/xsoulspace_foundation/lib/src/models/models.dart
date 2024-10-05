part of '../foundation.dart';

/// A container for loadable state, providing a clean way to represent
/// loading states without null checks.
///
/// This class is designed to wrap values that need to be loaded asynchronously,
/// providing a clear indication of whether the value has been loaded.
///
/// @ai Use this class to manage loading states in your application, ensuring
/// that the UI can react appropriately to changes in loading status.
///
/// Example usage:
/// ```dart
/// final loadableData = LoadableContainer(value: myData, isLoaded: true);
/// ```
@freezed
class LoadableContainer<T> with _$LoadableContainer<T> {
  const factory LoadableContainer({
    required final T value,
    @Default(false) final bool isLoaded,
  }) = _LoadableContainer<T>;
  const LoadableContainer._();

  /// Creates a [LoadableContainer] with a loaded state.
  ///
  /// [value] The value to be contained.
  ///
  /// @ai Use this factory method when you have an immediately available value.
  factory LoadableContainer.loaded(final T value) =>
      LoadableContainer<T>(value: value, isLoaded: true);

  /// Whether the container is currently in a loading state.
  ///
  /// @ai Use this getter to determine if the contained value is still loading.
  bool get isLoading => !isLoaded;
}

/// A container for field values, including error and loading states.
///
/// This class is used to represent form fields or other input values that may
/// have associated error messages and loading states.
///
/// @ai Use this class to manage the state of form fields in your application,
/// ensuring that error messages and loading indicators are
/// handled appropriately.
@freezed
class FieldContainer<T> with _$FieldContainer<T> {
  const factory FieldContainer({
    required final T value,
    @Default('') final String errorText,
    @Default(false) final bool isLoading,
  }) = _FieldContainer<T>;
}
