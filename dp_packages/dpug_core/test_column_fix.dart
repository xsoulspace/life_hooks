import 'package:dpug_core/dpug_core.dart';

void main() {
  const dpugCode = r'''
Column
  Text
    ..text: 'Hello'
''';

  final converter = DpugConverter();
  final dartCode = converter.dpugToDart(dpugCode);

  print('Generated Dart Code:');
  print('=' * 50);
  print(dartCode);
  print('=' * 50);

  // Check if it contains the expected pattern
  if (dartCode.contains("Column(\n      children: [\n        Text(text: 'Hello')\n      ],\n    )")) {
    print('✅ SUCCESS: Column uses children array correctly!');
  } else if (dartCode.contains("Column(\n        child:\n            Text(text: 'Hello'))")) {
    print('❌ ISSUE: Column uses child instead of children');
  } else {
    print('❓ UNKNOWN: Different Column pattern found');
  }
}
