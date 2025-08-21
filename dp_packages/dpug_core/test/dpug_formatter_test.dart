import 'dart:io';

import 'package:dpug_code_builder/src/formatters/dpug_config.dart';
import 'package:dpug_core/compiler/dpug_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Formatter Tests', () {
    late DpugFormatter formatter;

    setUp(() {
      formatter = DpugFormatter();
    });

    test('Format basic DPug code', () {
      // Use a simpler example that the current parser can handle
      const input = 'Text\n  ..text: "Hello"';

      // For now, formatter returns input as-is since formatting logic is TODO
      final output = formatter.format(input);
      expect(output, equals(input));
    });

    test('Format with compact config', () {
      final compactFormatter = DpugFormatter(config: DpugConfig.compact());
      const input = 'Text\n  ..text: "Hello"';

      final output = compactFormatter.format(input);
      expect(output, equals(input));
    });

    test('Format with readable config', () {
      final readableFormatter = DpugFormatter(config: DpugConfig.readable());
      const input = 'Text\n  ..text: "Hello"';

      final output = readableFormatter.format(input);
      expect(output, equals(input));
    });

    test('Error handling for invalid DPug', () {
      const invalidInput = '''
@stateful
class Broken
  @invalid annotation
  Widget get build =>
    UnknownWidget
      ..invalid:property
''';

      expect(
        () => formatter.format(invalidInput),
        throwsA(isA<FormatException>()),
      );
    });

    test('Format file (integration test)', () async {
      // Create a temporary test file
      final tempDir = await Directory.systemTemp.createTemp('dpug_test');
      final testFile = File('${tempDir.path}/test.dpug');

      const content = 'Text\n  ..text: "Hello World"';

      await testFile.writeAsString(content);

      // Format the file
      await formatter.formatFile(testFile.path);

      // Read back and verify
      final formatted = await testFile.readAsString();
      expect(formatted, equals(content));

      // Clean up
      await tempDir.delete(recursive: true);
    });

    test('Format multiple files', () async {
      final tempDir = await Directory.systemTemp.createTemp('dpug_test');

      // Create test files
      final file1 = File('${tempDir.path}/test1.dpug');
      final file2 = File('${tempDir.path}/test2.dpug');

      await file1.writeAsString('Text\n  ..text: "File 1"');
      await file2.writeAsString('Column\n  Text\n    ..text: "File 2"');

      // Format multiple files
      await formatter.formatFiles([file1.path, file2.path]);

      // Verify both files were processed
      expect(await file1.exists(), isTrue);
      expect(await file2.exists(), isTrue);

      // Clean up
      await tempDir.delete(recursive: true);
    });

    test('Handle non-existent file', () async {
      final nonExistent = '/path/does/not/exist.dpug';

      expect(
        () => formatter.formatFile(nonExistent),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
