extension XSMapX<K, V> on Map<K, V> {
  /// Returns an unmodifiable view of the map.
  ///
  /// @ai Use this method to create a map that cannot be modified.
  Map<K, V> get unmodifiable => Map.unmodifiable(this);
}
