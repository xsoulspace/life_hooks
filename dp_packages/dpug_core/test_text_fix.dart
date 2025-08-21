import 'package:dpug_core/dpug_core.dart';

void main() {
  const dpugCode = r'''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Text
      ..text: 'Count: $count'
''';

  final converter = DpugConverter();
  final dartCode = converter.dpugToDart(dpugCode);

  print('Generated Dart Code:');
  print('=' * 50);
  print(dartCode);
  print('=' * 50);

  // Check if it contains the expected pattern
  if (dartCode.contains("Text('Count: \$count')")) {
    print('✅ SUCCESS: Text widget uses positional argument correctly!');
  } else if (dartCode.contains("Text(text: 'Count: \$count')")) {
    print('❌ ISSUE: Text widget still uses named parameter');
  } else {
    print('❓ UNKNOWN: Different Text widget pattern found');
  }
}
