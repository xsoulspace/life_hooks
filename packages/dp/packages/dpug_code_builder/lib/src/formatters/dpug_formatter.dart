import 'dpug_config.dart';

class DpugFormatter {
  final DpugConfig config;

  DpugFormatter([this.config = const DpugConfig()]);

  String format(String code) {
    final lines = code.split('\n');
    final formattedLines = <String>[];
    var currentIndent = 0;
    var parentIndent = 0;
    var isInWidget = false;
    var isInMethod = false;
    var isInCallback = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // Handle indentation based on node type
      if (_isClassDeclaration(line)) {
        currentIndent = 0;
        parentIndent = 0;
        isInWidget = false;
        isInMethod = false;
      } else if (_isAnnotation(line)) {
        currentIndent = parentIndent;
      } else if (_isMethodDeclaration(line)) {
        currentIndent = 1;
        parentIndent = currentIndent;
        isInMethod = true;
      } else if (_isArrowFunction(line)) {
        currentIndent = parentIndent + 1;
        parentIndent = currentIndent;
      } else if (_isWidgetName(line)) {
        currentIndent = parentIndent + 1;
        parentIndent = currentIndent;
        isInWidget = true;
      } else if (_isCascadeNotation(line)) {
        currentIndent = parentIndent + 1;
      } else if (_isCallbackStart(line)) {
        currentIndent = parentIndent + 1;
        isInCallback = true;
      } else if (_isPositionalArgument(line)) {
        // Function-style arguments stay at parent level
        currentIndent = parentIndent;
      } else if (_isPropertyAssignment(line)) {
        currentIndent = parentIndent + 1;
      }

      final formattedLine = _formatLine(line, currentIndent);
      formattedLines.add(formattedLine);

      // Update parent indent for next line
      if (_isBlockEnd(line)) {
        if (isInCallback) {
          isInCallback = false;
        } else {
          parentIndent = isInWidget ? parentIndent - 1 : parentIndent;
          isInWidget = false;
        }
      } else if (_isMethodEnd(line)) {
        parentIndent = isInMethod ? parentIndent - 1 : parentIndent;
        isInMethod = false;
      }
    }

    return formattedLines.join('\n');
  }

  bool _isClassDeclaration(String line) {
    return line.startsWith('class') || line.startsWith('@stateful');
  }

  bool _isAnnotation(String line) {
    return line.startsWith('@');
  }

  bool _isMethodDeclaration(String line) {
    return line.contains(' get ') ||
        line.contains(' set ') ||
        line.contains('(');
  }

  bool _isArrowFunction(String line) {
    return line.contains('=>');
  }

  bool _isWidgetName(String line) {
    return RegExp(r'^[A-Z][a-zA-Z]*$').hasMatch(line);
  }

  bool _isCascadeNotation(String line) {
    return line.startsWith('..');
  }

  bool _isPositionalArgument(String line) {
    return line.contains('(') && !line.startsWith('..');
  }

  bool _isPropertyAssignment(String line) {
    return line.contains(':') && !line.contains('=>');
  }

  bool _isBlockEnd(String line) {
    return line.endsWith('}') || line.endsWith(')');
  }

  bool _isMethodEnd(String line) {
    return line.endsWith(';');
  }

  bool _isCallbackStart(String line) {
    return line.contains('{') &&
        (line.contains('=>') || line.contains('onPressed'));
  }

  String _formatLine(String line, int indent) {
    // Don't indent annotations at root level
    if (_isAnnotation(line) && indent == 0) {
      return line;
    }

    // Handle positional arguments without extra space
    if (_isPositionalArgument(line)) {
      final parts = line.split('(');
      if (parts.length == 2) {
        return '${config.indent * indent}${parts[0].trim()}(${parts[1].trim()}';
      }
    }

    return '${config.indent * indent}$line';
  }
}
