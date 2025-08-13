class DpugConfig {
  /// The indentation string (default: two spaces)
  final String indent;

  /// Whether to add newlines between class members
  final bool spaceBetweenMembers;

  /// Whether to add newlines between widget properties
  final bool spaceBetweenProperties;

  /// Whether to add newlines after annotations
  final bool spaceAfterAnnotations;

  /// Whether to add newlines between cascade operations
  final bool spaceBetweenCascades;

  const DpugConfig({
    this.indent = '  ',
    this.spaceBetweenMembers = true,
    this.spaceBetweenProperties = false,
    this.spaceAfterAnnotations = false,
    this.spaceBetweenCascades = false,
  });

  /// Creates a compact configuration with minimal whitespace
  factory DpugConfig.compact() => const DpugConfig(
    spaceBetweenMembers: false,
    spaceBetweenProperties: false,
    spaceAfterAnnotations: false,
    spaceBetweenCascades: false,
  );

  /// Creates a readable configuration with maximal whitespace
  factory DpugConfig.readable() => const DpugConfig(
    spaceBetweenMembers: true,
    spaceBetweenProperties: true,
    spaceAfterAnnotations: true,
    spaceBetweenCascades: true,
  );
}
