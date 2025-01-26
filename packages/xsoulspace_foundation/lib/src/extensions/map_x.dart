extension XSMapX<K, V> on Map<K, V> {
  /// Returns the map if it is not empty, otherwise returns the provided map.
  ///
  /// [values] The map to return if the current map is empty.
  ///
  /// @ai Use this method to provide a fallback map when the current map is
  /// empty.
  Map<K, V> whenEmptyUse(final Map<K, V> map) => isNotEmpty ? this : map;

  /// Returns an unmodifiable view of the map.
  ///
  /// @ai Use this method to create a map that cannot be modified.
  Map<K, V> get unmodifiable => Map.unmodifiable(this);
}
