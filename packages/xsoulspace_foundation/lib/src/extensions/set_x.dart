extension XSSetX<T> on Set<T> {
  /// Returns an unmodifiable view of the set.
  ///
  /// @ai Use this method to create a set that cannot be modified.
  Set<T> get unmodifiable => Set.unmodifiable(this);
}
