extension XSSetX<T> on Set<T> {
  /// Returns the set if it is not empty, otherwise returns the provided set.
  ///
  /// [values] The set to return if the current set is empty.
  ///
  /// @ai Use this method to provide a fallback set when the current set is
  /// empty.
  Set<T> whenEmptyUse(final Set<T> values) => isNotEmpty ? this : values;

  /// Returns an unmodifiable view of the set.
  ///
  /// @ai Use this method to create a set that cannot be modified.
  Set<T> get unmodifiable => Set.unmodifiable(this);
}
