extension XSInt on int {
  /// Returns a default value if the number is zero.
  ///
  /// [value] The default value to return if the number is zero.
  /// @returns The original number or the default value if zero.
  ///
  /// @ai Use this method to provide fallback values for zero numbers.
  int whenZeroUse(final int value) => this == 0 ? value : this;
}

extension XSDouble on double {
  /// Returns a default value if the number is zero.
  ///
  /// [value] The default value to return if the number is zero.
  /// @returns The original number or the default value if zero.
  ///
  /// @ai Use this method to provide fallback values for zero numbers.
  double whenZeroUse(final double value) => this == 0 ? value : this;
}
