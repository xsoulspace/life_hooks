import 'dpug_parser.dart';

/// Example demonstrating PetitParser-based DPug parsing
void main() {
  final parser = DPugParser();

  // Example DPug code
  const dpugCode = r'''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: $count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
''';

  print('=== PetitParser DPug Demo ===\n');
  print('Input DPug code:');
  print(dpugCode);
  print('\n${'=' * 50}\n');

  // Parse the code
  final result = parser.parse(dpugCode);

  try {
    print('✅ Parsing successful!');
    final ast = result.value;
    print('AST Type: ${ast.runtimeType}');
    print('Parsed value: $ast');
  } catch (e) {
    print('❌ Parsing failed:');
    print('Error: $e');
  }

  print('\n${'=' * 50}\n');

  // Grammar validation
  print('Grammar Linting Results:');
  final lintingIssues = parser.lint();
  if (lintingIssues.isEmpty) {
    print('✅ No grammar issues found');
  } else {
    print('⚠️  Grammar issues:');
    for (final issue in lintingIssues) {
      print('  - $issue');
    }
  }

  print('\n${'=' * 50}\n');

  // Show examples
  print('Available Examples:');
  final examples = parser.getExamples();
  examples.forEach((final name, final code) {
    print('\n📝 $name:');
    print(code);
  });

  print('\n${'=' * 50}\n');
  print('Grammar Info:');
  print(parser.getGrammarInfo());
}
