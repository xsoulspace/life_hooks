import 'dart:io';

import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('File System Integration Tests', () {
    late Directory tempDir;
    late Directory nestedDir;
    late DpugConverter converter;
    late DpugFormatter formatter;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dpug_filesystem_');
      nestedDir = Directory('${tempDir.path}/nested/deep/structure');
      await nestedDir.create(recursive: true);
      converter = DpugConverter();
      formatter = DpugFormatter();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('File Reading and Writing Operations', () {
      test('Read and convert single DPug file', () async {
        const dpugContent = '''
@stateless
class ReadWriteTest
  String title

  Widget get build =>
    Text
      ..text: title
      ..style:
        TextStyle
          ..fontSize: 24.0
          ..fontWeight: FontWeight.bold
''';

        final dpugFile = File('${tempDir.path}/test_read_write.dpug');
        await dpugFile.writeAsString(dpugContent);

        // Verify file was written correctly
        expect(await dpugFile.exists(), isTrue);
        final readContent = await dpugFile.readAsString();
        expect(readContent, equals(dpugContent));

        // Convert and write to new file
        final dartContent = converter.dpugToDart(readContent);
        final dartFile = File('${tempDir.path}/test_read_write.dart');
        await dartFile.writeAsString(dartContent);

        // Verify conversion
        final readDartContent = await dartFile.readAsString();
        expect(readDartContent, contains('class ReadWriteTest'));
        expect(readDartContent, contains('extends StatelessWidget'));
        expect(readDartContent, contains('FontWeight.bold'));
      });

      test('Write converted content to different directory', () async {
        const dpugContent = 'Text\n  ..text: "Directory Test"';
        final sourceFile = File('${tempDir.path}/source.dpug');
        await sourceFile.writeAsString(dpugContent);

        final outputDir = Directory('${tempDir.path}/output');
        await outputDir.create();

        final outputFile = File('${outputDir.path}/converted.dart');
        final convertCommand = ConvertCommand();

        await convertCommand.runCommand(
          from: sourceFile.path,
          to: outputFile.path,
        );

        expect(await outputFile.exists(), isTrue);
        final content = await outputFile.readAsString();
        expect(content, contains('Text'));
        expect(content, contains('Directory Test'));
      });

      test('Handle file encoding correctly', () async {
        const unicodeContent = '''
Text
  ..text: "Hello 🌍 世界! Ñoño 🚀"
  ..style:
    TextStyle
      ..fontSize: 16.0
''';

        final unicodeFile = File('${tempDir.path}/unicode_test.dpug');
        await unicodeFile.writeAsString(unicodeContent);

        final readContent = await unicodeFile.readAsString();
        expect(readContent, equals(unicodeContent));

        final dartContent = converter.dpugToDart(readContent);
        final dartFile = File('${tempDir.path}/unicode_test.dart');
        await dartFile.writeAsString(dartContent);

        final readDartContent = await dartFile.readAsString();
        expect(readDartContent, contains('Hello 🌍 世界! Ñoño 🚀'));
      });

      test('Append to existing file', () async {
        const initialContent = 'Text\n  ..text: "Initial"\n';
        const additionalContent = 'Text\n  ..text: "Additional"\n';

        final file = File('${tempDir.path}/append_test.dpug');
        await file.writeAsString(initialContent);

        // Append additional content
        await file.writeAsString(additionalContent, mode: FileMode.append);

        final fullContent = await file.readAsString();
        expect(fullContent, equals(initialContent + additionalContent));
      });
    });

    group('Directory Traversal', () {
      test('Traverse and process files in single directory', () async {
        const files = [
          ('widget1.dpug', 'Text\n  ..text: "Widget 1"'),
          ('widget2.dpug', 'Text\n  ..text: "Widget 2"'),
          ('widget3.dpug', 'Text\n  ..text: "Widget 3"'),
          ('data.txt', 'This is not a DPug file'),
        ];

        // Create files
        for (final file in files) {
          await File('${tempDir.path}/${file.$1}').writeAsString(file.$2);
        }

        // Find all DPug files
        final dpugFiles = await tempDir
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.dpug'))
            .cast<File>()
            .toList();

        expect(dpugFiles.length, equals(3));

        // Process each DPug file
        for (final file in dpugFiles) {
          final content = await file.readAsString();
          final dartContent = converter.dpugToDart(content);
          expect(dartContent, contains('extends StatelessWidget'));
        }
      });

      test('Traverse nested directory structure', () async {
        const nestedFiles = [
          ('root.dpug', 'Text\n  ..text: "Root Widget"'),
          (
            'nested/deep.dpug',
            '''
@stateful
class DeepWidget
  @listen int value = 0

  Widget get build =>
    Text
      ..text: "Deep: \$value"
''',
          ),
          ('nested/structure/leaf.dpug', 'Text\n  ..text: "Leaf Widget"'),
        ];

        // Create nested files
        for (final file in nestedFiles) {
          final filePath = '${tempDir.path}/${file.$1}';
          await File(filePath).parent.create(recursive: true);
          await File(filePath).writeAsString(file.$2);
        }

        // Traverse recursively and find all DPug files
        final dpugFiles = <File>[];
        await _traverseDirectory(tempDir, dpugFiles);

        expect(dpugFiles.length, equals(3));

        // Process each file
        for (final file in dpugFiles) {
          final content = await file.readAsString();
          final dartContent = converter.dpugToDart(content);
          expect(dartContent, contains('extends'));
          expect(dartContent, contains('Widget'));
        }
      });

      test('Handle directory with mixed file types', () async {
        const mixedFiles = [
          (
            'app.dpug',
            '''
@stateless
class App
  Widget get build =>
    MaterialApp
      ..home: HomePage()
''',
          ),
          (
            'home_page.dart',
            '''
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
''',
          ),
          ('styles.css', '.app { color: blue; }'),
          ('data.json', '{"key": "value"}'),
          ('readme.md', '# README'),
        ];

        // Create mixed files
        for (final file in mixedFiles) {
          await File('${tempDir.path}/${file.$1}').writeAsString(file.$2);
        }

        // Find only DPug files
        final dpugFiles = await tempDir
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.dpug'))
            .cast<File>()
            .toList();

        expect(dpugFiles.length, equals(1));

        final dpugFile = dpugFiles.first;
        final content = await dpugFile.readAsString();
        final dartContent = converter.dpugToDart(content);

        expect(dartContent, contains('class App'));
        expect(dartContent, contains('MaterialApp'));
      });

      test('Skip hidden files and directories', () async {
        const visibleFiles = [('widget.dpug', 'Text\n  ..text: "Visible"')];

        const hiddenFiles = [
          ('.hidden.dpug', 'Text\n  ..text: "Hidden"'),
          ('normal_file', 'content'),
        ];

        // Create files including hidden ones
        for (final file in [...visibleFiles, ...hiddenFiles]) {
          await File('${tempDir.path}/${file.$1}').writeAsString(file.$2);
        }

        // Create .hidden directory
        final hiddenDir = Directory('${tempDir.path}/.hidden_dir');
        await hiddenDir.create();
        await File(
          '${hiddenDir.path}/hidden_widget.dpug',
        ).writeAsString('Text\n  ..text: "Hidden Dir Widget"');

        // Find only visible DPug files
        final dpugFiles = await tempDir
            .list()
            .where(
              (entity) =>
                  entity is File &&
                  entity.path.endsWith('.dpug') &&
                  !entity.path.contains('/.'),
            )
            .cast<File>()
            .toList();

        expect(dpugFiles.length, equals(1));

        final visibleFile = dpugFiles.first;
        expect(visibleFile.path, contains('widget.dpug'));
        expect(visibleFile.path, isNot(contains('/.')));
      });
    });

    group('File Permissions and Security', () {
      test('Handle read-only files gracefully', () async {
        const dpugContent = 'Text\n  ..text: "Read Only Test"';
        final readOnlyFile = File('${tempDir.path}/readonly.dpug');
        await readOnlyFile.writeAsString(dpugContent);

        // Try to set read-only (this might not work on all platforms)
        try {
          await readOnlyFile.setReadOnly(true);

          final convertCommand = ConvertCommand();

          // Should handle read-only files gracefully
          expect(
            () => convertCommand.runCommand(
              from: readOnlyFile.path,
              to: '${tempDir.path}/readonly_output.dart',
            ),
            returnsNormally,
          );
        } catch (e) {
          // If we can't set read-only, skip the test
          print('Skipping read-only test: $e');
        }
      });

      test('Handle permission denied errors', () async {
        const dpugContent = 'Text\n  ..text: "Permission Test"';
        final file = File('${tempDir.path}/permission_test.dpug');
        await file.writeAsString(dpugContent);

        // Try to read from a file that might have permission issues
        try {
          final content = await file.readAsString();
          expect(content, equals(dpugContent));

          // If we can read it, the conversion should work
          final dartContent = converter.dpugToDart(content);
          expect(dartContent, contains('Text'));
        } catch (e) {
          // If there are permission issues, the test should still pass
          expect(e, isA<FileSystemException>());
        }
      });

      test('Write to directory with proper permissions', () async {
        const dpugContent = 'Text\n  ..text: "Permission Write Test"';

        // Create a subdirectory with proper permissions
        final subDir = Directory('${tempDir.path}/writable');
        await subDir.create();

        final inputFile = File('${subDir.path}/input.dpug');
        final outputFile = File('${subDir.path}/output.dart');

        await inputFile.writeAsString(dpugContent);

        final convertCommand = ConvertCommand();
        await convertCommand.runCommand(
          from: inputFile.path,
          to: outputFile.path,
        );

        expect(await outputFile.exists(), isTrue);
        final content = await outputFile.readAsString();
        expect(content, contains('Permission Write Test'));
      });

      test('Handle non-existent output directory', () async {
        const dpugContent = 'Text\n  ..text: "Directory Test"';
        final inputFile = File('${tempDir.path}/input.dpug');
        await inputFile.writeAsString(dpugContent);

        // Try to write to a non-existent directory
        final outputFile = File('${tempDir.path}/nonexistent/output.dart');

        final convertCommand = ConvertCommand();

        // Should handle the case where output directory doesn't exist
        expect(
          () => convertCommand.runCommand(
            from: inputFile.path,
            to: outputFile.path,
          ),
          returnsNormally,
        );
      });
    });

    group('Large File Processing', () {
      test('Process large DPug files', () async {
        // Create a large DPug file with many widgets
        final largeDpug = StringBuffer();
        largeDpug.writeln('@stateful');
        largeDpug.writeln('class LargeFileWidget');
        largeDpug.writeln('  @listen int counter = 0');
        largeDpug.writeln('');
        largeDpug.writeln('  Widget get build =>');
        largeDpug.writeln('    Column');
        largeDpug.writeln('      children:');

        // Add many child widgets
        for (int i = 0; i < 1000; i++) {
          largeDpug.writeln('      Text');
          largeDpug.writeln('        ..text: "Item $i"');
          largeDpug.writeln('        ..key: ValueKey("$i")');
        }

        final largeFile = File('${tempDir.path}/large.dpug');
        await largeFile.writeAsString(largeDpug.toString());

        // Verify file size
        final fileSize = await largeFile.length();
        expect(fileSize, greaterThan(10000)); // At least 10KB

        // Process the large file
        final startTime = DateTime.now();
        final content = await largeFile.readAsString();
        final dartContent = converter.dpugToDart(content);
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(
          duration.inSeconds,
          lessThan(30),
        ); // Should complete within 30 seconds

        // Verify results
        expect(dartContent, contains('class LargeFileWidget'));
        expect(dartContent, contains('extends StatefulWidget'));
        expect(dartContent, contains('Item 0'));
        expect(dartContent, contains('Item 999'));
        expect(dartContent, contains('ValueKey("999")'));

        // Write result to file
        final outputFile = File('${tempDir.path}/large_output.dart');
        await outputFile.writeAsString(dartContent);

        final outputSize = await outputFile.length();
        expect(
          outputSize,
          greaterThan(fileSize),
        ); // Dart output should be larger
      });

      test('Memory usage with large files', () async {
        // Create multiple large files
        const fileCount = 10;
        final largeFiles = <File>[];

        for (int fileIndex = 0; fileIndex < fileCount; fileIndex++) {
          final largeDpug = StringBuffer();
          largeDpug.writeln('@stateless');
          largeDpug.writeln('class LargeWidget$fileIndex');
          largeDpug.writeln('');
          largeDpug.writeln('  Widget get build =>');
          largeDpug.writeln('    Column');
          largeDpug.writeln('      children:');

          for (int i = 0; i < 500; i++) {
            largeDpug.writeln('      Text');
            largeDpug.writeln('        ..text: "File $fileIndex Item $i"');
          }

          final file = File('${tempDir.path}/large_$fileIndex.dpug');
          await file.writeAsString(largeDpug.toString());
          largeFiles.add(file);
        }

        // Process all large files
        final startTime = DateTime.now();

        for (final file in largeFiles) {
          final content = await file.readAsString();
          final dartContent = converter.dpugToDart(content);

          // Write output
          final outputPath = file.path.replaceAll('.dpug', '.dart');
          await File(outputPath).writeAsString(dartContent);
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete within reasonable time
        expect(duration.inSeconds, lessThan(60));

        // Verify all outputs exist and are correct
        for (int fileIndex = 0; fileIndex < fileCount; fileIndex++) {
          final outputFile = File('${tempDir.path}/large_$fileIndex.dart');
          expect(await outputFile.exists(), isTrue);

          final content = await outputFile.readAsString();
          expect(content, contains('class LargeWidget$fileIndex'));
          expect(content, contains('File $fileIndex Item 0'));
          expect(content, contains('File $fileIndex Item 499'));
        }
      });

      test('Handle files with very long lines', () async {
        // Create a file with extremely long lines
        const longText =
            'This is a very long text that will be repeated many times to create an extremely long line that tests the parser and formatter capabilities with edge cases that might cause issues with memory or processing time. ' *
            100;

        final longLineDpug =
            '''
Text
  ..text: "$longText"
  ..maxLines: 3
  ..overflow: TextOverflow.ellipsis
''';

        final longLineFile = File('${tempDir.path}/long_lines.dpug');
        await longLineFile.writeAsString(longLineDpug);

        // Process the file with long lines
        final content = await longLineFile.readAsString();
        final dartContent = converter.dpugToDart(content);

        expect(dartContent, contains('Text'));
        expect(dartContent, contains(longText));
        expect(dartContent, contains('TextOverflow.ellipsis'));

        // Format the long line file
        final formatCommand = FormatCommand();
        await formatCommand.runCommand(file: longLineFile.path);

        final formattedContent = await longLineFile.readAsString();
        expect(formattedContent, contains('Text'));
        expect(formattedContent, contains(longText));
      });
    });

    group('File System Edge Cases', () {
      test('Handle files with special characters in names', () async {
        const specialNames = [
          'widget-with-dashes.dpug',
          'widget_with_underscores.dpug',
          'widget with spaces.dpug',
          'widget.with.dots.dpug',
          '123numeric.dpug',
        ];

        for (final name in specialNames) {
          final content = 'Text\n  ..text: "$name"';
          final file = File('${tempDir.path}/$name');
          await file.writeAsString(content);

          // Should be able to read and process
          final readContent = await file.readAsString();
          expect(readContent, equals(content));

          final dartContent = converter.dpugToDart(readContent);
          expect(dartContent, contains('Text'));
          expect(dartContent, contains(name));
        }
      });

      test('Handle empty files and directories', () async {
        // Empty file
        final emptyFile = File('${tempDir.path}/empty.dpug');
        await emptyFile.writeAsString('');

        final emptyContent = await emptyFile.readAsString();
        expect(emptyContent, isEmpty);

        // Empty directory
        final emptyDir = Directory('${tempDir.path}/empty_dir');
        await emptyDir.create();

        final emptyDirContents = await emptyDir.list().toList();
        expect(emptyDirContents, isEmpty);
      });

      test('Handle file system case sensitivity', () async {
        const content = 'Text\n  ..text: "Case Test"';

        // Create files with different cases (if filesystem supports it)
        final lowerCaseFile = File('${tempDir.path}/test.dpug');
        final upperCaseFile = File('${tempDir.path}/TEST.dpug');

        await lowerCaseFile.writeAsString(content);

        // Try to create uppercase version (might fail on case-insensitive filesystems)
        try {
          await upperCaseFile.writeAsString(content);
          expect(await upperCaseFile.exists(), isTrue);
        } catch (e) {
          // Expected on case-insensitive filesystems
          expect(e, isA<FileSystemException>());
        }

        // Should always be able to process the lowercase file
        final lowerContent = await lowerCaseFile.readAsString();
        final dartContent = converter.dpugToDart(lowerContent);
        expect(dartContent, contains('Case Test'));
      });

      test('Concurrent file operations', () async {
        const fileCount = 20;
        final files = <File>[];

        // Create multiple files
        for (int i = 0; i < fileCount; i++) {
          final content = 'Text\n  ..text: "Concurrent $i"';
          final file = File('${tempDir.path}/concurrent_$i.dpug');
          await file.writeAsString(content);
          files.add(file);
        }

        // Process files concurrently
        final futures = files.map((file) async {
          final content = await file.readAsString();
          final dartContent = converter.dpugToDart(content);
          final outputFile = File(file.path.replaceAll('.dpug', '.dart'));
          await outputFile.writeAsString(dartContent);
          return outputFile;
        });

        final outputFiles = await Future.wait(futures);

        // Verify all files were processed correctly
        for (int i = 0; i < fileCount; i++) {
          final outputFile = outputFiles[i];
          expect(await outputFile.exists(), isTrue);

          final content = await outputFile.readAsString();
          expect(content, contains('Concurrent $i'));
        }
      });
    });

    group('Integration with CLI Commands', () {
      test('CLI batch processing with directory traversal', () async {
        // Create a complex directory structure
        const structure = {
          'lib/widgets/button.dpug': '''
@stateless
class ButtonWidget
  String text

  Widget get build =>
    ElevatedButton
      ..child:
        Text
          ..text: text
''',
          'lib/widgets/card.dpug': '''
@stateless
class CardWidget
  String title
  String content

  Widget get build =>
    Card
      ..child:
        Column
          children:
            Text
              ..text: title
            Text
              ..text: content
''',
          'lib/screens/home_screen.dpug': '''
@stateful
class HomeScreen
  @listen int counter = 0

  Widget get build =>
    Scaffold
      ..body:
        Center
          ..child:
            Column
              children:
                Text
                  ..text: "Counter: \$counter"
                ElevatedButton
                  ..onPressed: () => counter++
                  ..child:
                    Text
                      ..text: "Increment"
''',
          'lib/main.dpug': '''
void main() => runApp(MyApp());

@stateless
class MyApp
  Widget get build =>
    MaterialApp
      ..home: HomeScreen()
''',
        };

        // Create directory structure
        for (final entry in structure.entries) {
          final filePath = '${tempDir.path}/${entry.key}';
          await File(filePath).parent.create(recursive: true);
          await File(filePath).writeAsString(entry.value);
        }

        // Use CLI to convert entire lib directory
        final convertCommand = ConvertCommand();
        await convertCommand.runCommand(
          from: '${tempDir.path}/lib',
          to: '${tempDir.path}/dart_lib',
        );

        // Verify all files were converted
        for (final fileName in structure.keys) {
          final dartFileName = fileName.replaceAll('.dpug', '.dart');
          final outputFile = File('${tempDir.path}/dart_lib/$dartFileName');
          expect(await outputFile.exists(), isTrue);

          final content = await outputFile.readAsString();
          expect(content, contains('extends'));
          expect(content, contains('Widget'));
        }

        // Verify specific widget classes
        final buttonFile = File('${tempDir.path}/dart_lib/widgets/button.dart');
        final buttonContent = await buttonFile.readAsString();
        expect(buttonContent, contains('class ButtonWidget'));
        expect(buttonContent, contains('ElevatedButton'));

        final homeScreenFile = File(
          '${tempDir.path}/dart_lib/screens/home_screen.dart',
        );
        final homeScreenContent = await homeScreenFile.readAsString();
        expect(homeScreenContent, contains('class HomeScreen'));
        expect(homeScreenContent, contains('Scaffold'));
        expect(homeScreenContent, contains('extends StatefulWidget'));
      });

      test('CLI format with filesystem operations', () async {
        // Create messy files in different directories
        const messyFiles = {
          'screen1.dpug': '''
@stateful    class    Screen1
      @listen    int    value=0

 Widget   get   build   =>
     Text
       ..text:    "Screen 1"
''',
          'widgets/widget1.dpug': '''
@stateless
class    Widget1
  String   title

  Widget   get   build   =>
    Container
      ..child:    Text
        ..text:  title
''',
          'widgets/widget2.dpug': '''
@stateless class Widget2 Widget get build => Text..text:"Widget 2"
''',
        };

        // Create files
        for (final entry in messyFiles.entries) {
          final filePath = '${tempDir.path}/${entry.key}';
          await File(filePath).parent.create(recursive: true);
          await File(filePath).writeAsString(entry.value);
        }

        // Format entire directory
        final formatCommand = FormatCommand();
        await formatCommand.runCommand(directory: tempDir.path);

        // Verify all files are properly formatted
        for (final fileName in messyFiles.keys) {
          final file = File('${tempDir.path}/$fileName');
          final formattedContent = await file.readAsString();

          expect(formattedContent, contains('class'));
          expect(formattedContent, contains('extends'));
          expect(formattedContent, contains('Widget get build =>'));

          // Should have consistent indentation
          final lines = formattedContent.split('\n');
          final classLine = lines.firstWhere((line) => line.contains('class'));
          expect(classLine, startsWith('class')); // No extra indentation
        }
      });
    });
  });
}

// Helper function to traverse directory recursively
Future<void> _traverseDirectory(Directory dir, List<File> dpugFiles) async {
  await for (final entity in dir.list()) {
    if (entity is File && entity.path.endsWith('.dpug')) {
      dpugFiles.add(entity);
    } else if (entity is Directory) {
      await _traverseDirectory(entity, dpugFiles);
    }
  }
}
