import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';

import 'dpug_grammar.dart';

/// PetitParser-based DPug parser with enhanced error handling
class DPugParser {
  late final DPugGrammar _grammar;
  late final Parser _parser;

  DPugParser() {
    _grammar = DPugGrammar();
    _parser = _grammar.build();
  }

  /// Parse DPug source code and return the AST
  Result parse(String source) {
    final result = _parser.parse(source);
    return result;
  }

  /// Check if the source is valid DPug syntax
  bool isValid(String source) => _parser.accept(source);

  /// Get parser diagnostics and linting information
  List<String> lint() =>
      linter(_parser).map((issue) => issue.toString()).toList();

  /// Get a human-readable grammar description
  String getGrammarInfo() {
    final buffer = StringBuffer();
    buffer.writeln('DPug Grammar:');
    buffer.writeln('- Supports indentation-based widget trees');
    buffer.writeln('- Class definitions with @stateful/@listen annotations');
    buffer.writeln('- Properties via cascade syntax (..prop: value)');
    buffer.writeln('- Positional arguments in parentheses');
    buffer.writeln('- Simple expressions (literals, identifiers, closures)');
    return buffer.toString();
  }

  /// Example usage patterns
  Map<String, String> getExamples() {
    return {
      'Simple Widget': '''
Text
  ..text: 'Hello World'
''',
      'Class Definition': '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: \$count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
''',
      'Widget with Children': '''
Column
  Text
    ..text: 'Header'
  Row
    Text
      ..text: 'Item 1'
    Text
      ..text: 'Item 2'
''',
    };
  }
}
