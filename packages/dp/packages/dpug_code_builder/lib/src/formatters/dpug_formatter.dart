class DpugFormatter {
  static const _indent = '  ';

  String format(String code) {
    final lines = code.split('\n');
    final formattedLines = <String>[];
    var currentIndent = 0;
    var parentIndent = 0;
    var isInWidget = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip empty lines
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // Handle indentation
      if (line.startsWith('class') || line.startsWith('@stateful')) {
        currentIndent = 0;
        parentIndent = 0;
        isInWidget = false;
      } else if (line.startsWith('..')) {
        // Keep cascade notation at parent's level + 1
        currentIndent = parentIndent + 1;
      } else if (line.contains('=>')) {
        // Handle arrow functions
        currentIndent = parentIndent + 1;
        parentIndent = currentIndent;
      } else if (line.contains('(') && !line.startsWith('..')) {
        // Handle function calls - keep at parent level
        currentIndent = parentIndent;
      } else if (!line.startsWith('@')) {
        if (_isWidgetName(line)) {
          // New widget starts at parent level + 1
          currentIndent = parentIndent + 1;
          parentIndent = currentIndent;
          isInWidget = true;
        } else {
          // Regular lines get parent's level + 1
          currentIndent = parentIndent + 1;
        }
      }

      // Format the line
      final formattedLine = _formatLine(line, currentIndent);
      formattedLines.add(formattedLine);

      // Update parent indent for next line
      if (line.endsWith('=>')) {
        parentIndent = currentIndent;
      } else if (line.endsWith(')')) {
        parentIndent = isInWidget ? parentIndent - 1 : parentIndent;
        isInWidget = false;
      }
    }

    return formattedLines.join('\n');
  }

  bool _isWidgetName(String line) {
    // Add more widget patterns if needed
    return RegExp(r'^[A-Z][a-zA-Z]*$').hasMatch(line);
  }

  String _formatLine(String line, int indent) {
    // Don't indent annotations
    if (line.startsWith('@')) {
      return line;
    }

    // Handle positional arguments without extra space
    if (line.contains('(') && !line.startsWith('..')) {
      final parts = line.split('(');
      if (parts.length == 2) {
        return '${_indent * indent}${parts[0].trim()}(${parts[1].trim()}';
      }
    }

    // Handle cascade notation
    if (line.startsWith('..')) {
      return '${_indent * indent}$line';
    }

    return '${_indent * indent}$line';
  }

  String formatExpression(String expression) {
    return expression.trim();
  }
}
