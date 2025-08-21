import 'package:dpug_core/compiler/dpug_parser.dart';

void main() {
  final parser = DPugParser();

  const validInput = '''
class Test
  @listen String name = 'test' ''';

  print('Testing input:');
  print(validInput);
  print('\n--- Parsing ---');

  final result = parser.parse(validInput);
  print('Parse result: $result');
  print('Result type: ${result.runtimeType}');
  print('Result toString: $result');

  print('\n--- Validation ---');
  final isValid = parser.isValid(validInput);
  print('Is valid: $isValid');
}
