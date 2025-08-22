import 'dart:io';

import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('CLI End-to-End Integration Tests', () {
    late Directory tempDir;
    late DpugConverter converter;
    late DpugFormatter formatter;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dpug_cli_integration_');
      converter = DpugConverter();
      formatter = DpugFormatter();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('Convert Command Integration', () {
      test('Convert single DPug file to Dart', () async {
        const dpugContent = r'''
@stateful
class ConvertTestWidget
  @listen int count = 0

  Widget get build =>
    Column
      children:
        Text
          ..text: "Count: $count"
        ElevatedButton
          ..onPressed: () => count++
          ..child:
            Text
              ..text: "Increment"
''';

        final dpugFile = File('${tempDir.path}/test.dpug');
        final dartFile = File('${tempDir.path}/test.dart');

        await dpugFile.writeAsString(dpugContent);

        final convertCommand = ConvertCommand();
        await convertCommand.runCommand(from: dpugFile.path, to: dartFile.path);

        expect(await dartFile.exists(), isTrue);
        final dartContent = await dartFile.readAsString();

        expect(dartContent, contains('class ConvertTestWidget'));
        expect(dartContent, contains('extends StatefulWidget'));
        expect(dartContent, contains('int count = 0'));
        expect(dartContent, contains(r'Count: $count'));
      });

      test('Convert multiple files in directory', () async {
        const files = [
          ('widget1.dpug', 'Text\n  ..text: "First"'),
          ('widget2.dpug', 'Text\n  ..text: "Second"'),
          ('widget3.dpug', 'Text\n  ..text: "Third"'),
        ];

        // Create DPug files
        for (final file in files) {
          await File('${tempDir.path}/${file.$1}').writeAsString(file.$2);
        }

        // Convert all files
        final convertCommand = ConvertCommand();
        await convertCommand.runCommand(from: tempDir.path, to: tempDir.path);

        // Check all Dart files were created
        for (final file in files) {
          final dartFileName = file.$1.replaceAll('.dpug', '.dart');
          final dartFile = File('${tempDir.path}/$dartFileName');
          expect(await dartFile.exists(), isTrue);

          final content = await dartFile.readAsString();
          expect(content, contains('Text'));
          expect(content, contains('extends StatelessWidget'));
        }
      });
    });

    group('Format Command Integration', () {
      test('Format single DPug file', () async {
        const messyDpug = '''
@stateful    class    FormatTestWidget
      @listen    int    count=0

 Widget   get   build   =>
     Column
       children:    Text
           ..text:"Messy"
         ElevatedButton
             ..onPressed:    ()   =>   count++
''';

        final dpugFile = File('${tempDir.path}/messy.dpug');
        await dpugFile.writeAsString(messyDpug);

        final formatCommand = FormatCommand();
        await formatCommand.runCommand(file: dpugFile.path);

        final formattedContent = await dpugFile.readAsString();

        expect(formattedContent, contains('class FormatTestWidget'));
        expect(formattedContent, contains('@listen int count = 0'));
        expect(formattedContent, contains('Widget get build =>'));
      });
    });

    group('Complete CLI Workflows', () {
      test('Convert → Format → Convert round-trip', () async {
        const originalDpug = '''
@stateful
class WorkflowTest
  @listen String message = "Hello"

  Widget get build =>
    Text
      ..text: message
''';

        final dpugFile = File('${tempDir.path}/workflow.dpug');
        await dpugFile.writeAsString(originalDpug);

        // Convert to Dart
        final convertCommand = ConvertCommand();
        await convertCommand.runCommand(
          from: dpugFile.path,
          to: '${tempDir.path}/workflow.dart',
        );

        final dartFile = File('${tempDir.path}/workflow.dart');
        expect(await dartFile.exists(), isTrue);

        // Convert back to DPug
        await convertCommand.runCommand(
          from: '${tempDir.path}/workflow.dart',
          to: '${tempDir.path}/workflow_roundtrip.dpug',
        );

        final roundTripFile = File('${tempDir.path}/workflow_roundtrip.dpug');
        expect(await roundTripFile.exists(), isTrue);

        // Format the round-trip file
        final formatCommand = FormatCommand();
        await formatCommand.runCommand(file: roundTripFile.path);

        final formattedContent = await roundTripFile.readAsString();
        expect(formattedContent, contains('class WorkflowTest'));
        expect(formattedContent, contains('@listen String message = "Hello"'));
      });
    });
  });
}
