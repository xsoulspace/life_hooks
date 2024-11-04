class SourceLocation {
  final int offset;
  final int line;
  final int column;
  final int length;

  const SourceLocation({
    required this.offset,
    required this.line,
    required this.column,
    required this.length,
  });
}

class SourceMapper {
  final Map<int, SourceLocation> _sourceMap = {};
  final Map<int, int> _lengthMap = {};

  void addMapping(int generatedOffset, SourceLocation original, {int? length}) {
    _sourceMap[generatedOffset] = original;
    if (length != null) {
      _lengthMap[generatedOffset] = length;
    }
  }

  SourceLocation? getOriginalLocation(int generatedOffset) {
    return _sourceMap[generatedOffset];
  }

  int? getLength(int generatedOffset) {
    return _lengthMap[generatedOffset];
  }

  // Helper to map a range of positions
  List<SourceLocation> getMappingsInRange(int start, int end) {
    return _sourceMap.entries
        .where((entry) => entry.key >= start && entry.key <= end)
        .map((e) => e.value)
        .toList();
  }
}
