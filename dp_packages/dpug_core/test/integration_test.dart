import 'dart:io';

import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Core End-to-End Integration Tests', () {
    late DpugConverter converter;
    late DpugFormatter formatter;

    setUp(() {
      converter = DpugConverter();
      formatter = DpugFormatter();
    });

    group('Complete Conversion Workflows', () {
      test('Round-trip conversion: DPug → Dart → DPug', () {
        const originalDpug = r'''
@stateful
class CounterWidget
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

        // DPug to Dart
        final dartCode = converter.dpugToDart(originalDpug);
        expect(dartCode, contains('class CounterWidget'));
        expect(dartCode, contains('extends StatefulWidget'));
        expect(dartCode, contains('int count = 0'));
        expect(dartCode, contains(r'Count: $count'));
        expect(dartCode, contains('onPressed: () => count++'));

        // Dart back to DPug
        final roundTripDpug = converter.dartToDpug(dartCode);
        expect(roundTripDpug, contains('class CounterWidget'));
        expect(roundTripDpug, contains('@listen int count = 0'));
        expect(roundTripDpug, contains('Text'));
        expect(roundTripDpug, contains('ElevatedButton'));
      });

      test('Convert → Format → Convert workflow', () {
        const messyDpug = '''
@stateful    class    CounterWidget
      @listen    int    count=0

 Widget   get   build   =>
     Column
       children:    Text
           ..text:"Hello"
         ElevatedButton
             ..onPressed:    ()   =>   count++
''';

        // Convert to Dart
        final dartCode = converter.dpugToDart(messyDpug);

        // Format the DPug
        final formattedDpug = formatter.format(messyDpug);

        // Convert formatted DPug to Dart
        final formattedDartCode = converter.dpugToDart(formattedDpug);

        // Both should produce equivalent Dart code (ignoring whitespace)
        final normalizedOriginal = dartCode
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        final normalizedFormatted = formattedDartCode
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        expect(normalizedOriginal, equals(normalizedFormatted));
      });

      test('Complex Flutter widget conversion', () {
        const complexDpug = '''
@stateless
class ProfileCard
  String name
  String email
  String avatarUrl

  Widget get build =>
    Card
      ..elevation: 4.0
      ..child:
        Padding
          ..padding: EdgeInsets.all(16.0)
          ..child:
            Row
              children:
                CircleAvatar
                  ..backgroundImage: NetworkImage(avatarUrl)
                  ..radius: 30.0
                SizedBox
                  ..width: 16.0
                Expanded
                  ..child:
                    Column
                      crossAxisAlignment: CrossAxisAlignment.start
                      children:
                        Text
                          ..text: name
                          ..style:
                            TextStyle
                              ..fontSize: 18.0
                              ..fontWeight: FontWeight.bold
                        Text
                          ..text: email
                          ..style:
                            TextStyle
                              ..fontSize: 14.0
                              ..color: Colors.grey
''';

        final dartCode = converter.dpugToDart(complexDpug);

        expect(dartCode, contains('class ProfileCard'));
        expect(dartCode, contains('extends StatelessWidget'));
        expect(dartCode, contains('CircleAvatar'));
        expect(dartCode, contains('NetworkImage(avatarUrl)'));
        expect(dartCode, contains('EdgeInsets.all(16.0)'));
        expect(dartCode, contains('CrossAxisAlignment.start'));
        expect(dartCode, contains('FontWeight.bold'));
        expect(dartCode, contains('Colors.grey'));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('Invalid DPug syntax throws meaningful errors', () {
        const invalidDpug = '''
@invalid_annotation
class BrokenWidget
  @unknown_property int value = "not_a_number"

  Widget get build =>
    UnknownWidget
      ..invalid_prop: "value"
''';

        expect(
          () => converter.dpugToDart(invalidDpug),
          throwsA(isA<Exception>()),
        );
      });

      test('Empty and minimal valid inputs', () {
        const emptyDpug = '';

        expect(() => converter.dpugToDart(emptyDpug), returnsNormally);

        const minimalDpug = '''
Text
  ..text: "Hello"
''';

        final result = converter.dpugToDart(minimalDpug);
        expect(result, contains('Text'));
        expect(result, contains('text: "Hello"'));
      });

      test('Large DPug files processing', () {
        // Generate a large DPug structure
        final largeDpug = StringBuffer();
        largeDpug.writeln('@stateful');
        largeDpug.writeln('class LargeWidget');
        largeDpug.writeln('  @listen int counter = 0');
        largeDpug.writeln();
        largeDpug.writeln('  Widget get build =>');
        largeDpug.writeln('    Column');
        largeDpug.writeln('      children:');

        // Add many child widgets
        for (int i = 0; i < 100; i++) {
          largeDpug.writeln('        Text');
          largeDpug.writeln('          ..text: "Item $i"');
        }

        final result = converter.dpugToDart(largeDpug.toString());
        expect(result, contains('class LargeWidget'));
        expect(result, contains('Column'));
        expect(result, contains('children:'));
        expect(result, contains('Item 99')); // Last item should be present
      });

      test('Special characters and Unicode handling', () {
        const unicodeDpug = '''
Text
  ..text: "Hello 🌍 世界!"
  ..style:
    TextStyle
      ..fontSize: 16.0
      ..color: Color(0xFF42A5F5)
''';

        final result = converter.dpugToDart(unicodeDpug);
        expect(result, contains('Hello 🌍 世界!'));
        expect(result, contains('Color(0xFF42A5F5)'));
      });
    });

    group('Integration with File System', () {
      test('Process DPug files from disk', () async {
        const testDpug = '''
Text
  ..text: "File Test"
  ..style:
    TextStyle
      ..fontSize: 18.0
''';

        // Create temporary file
        final tempDir = await Directory.systemTemp.createTemp('dpug_test_');
        final dpugFile = File('${tempDir.path}/test.dpug');

        await dpugFile.writeAsString(testDpug);

        try {
          final fileContent = await dpugFile.readAsString();
          final dartCode = converter.dpugToDart(fileContent);

          expect(dartCode, contains('Text'));
          expect(dartCode, contains('File Test'));
          expect(dartCode, contains('fontSize: 18.0'));
        } finally {
          await tempDir.delete(recursive: true);
        }
      });

      test('Directory traversal and batch processing', () async {
        const testDpug1 = '''
Text
  ..text: "First File"
''';

        const testDpug2 = '''
Text
  ..text: "Second File"
''';

        // Create temporary directory structure
        final tempDir = await Directory.systemTemp.createTemp(
          'dpug_batch_test_',
        );
        final subDir = Directory('${tempDir.path}/widgets');
        await subDir.create();

        final file1 = File('${subDir.path}/widget1.dpug');
        final file2 = File('${subDir.path}/widget2.dpug');

        await file1.writeAsString(testDpug1);
        await file2.writeAsString(testDpug2);

        try {
          final dpugFiles = await subDir
              .list()
              .where((final entity) => entity.path.endsWith('.dpug'))
              .cast<File>()
              .toList();

          expect(dpugFiles.length, equals(2));

          for (final file in dpugFiles) {
            final content = await file.readAsString();
            final dartCode = converter.dpugToDart(content);
            expect(dartCode, contains('Text'));
            expect(dartCode, contains('extends StatelessWidget'));
          }
        } finally {
          await tempDir.delete(recursive: true);
        }
      });
    });

    group('Performance and Memory', () {
      test('Memory usage with large files', () {
        // Create a very large DPug structure
        final largeDpug = StringBuffer();
        largeDpug.writeln('@stateful');
        largeDpug.writeln('class PerformanceTest');
        largeDpug.writeln('  @listen int value = 0');
        largeDpug.writeln('  Widget get build =>');
        largeDpug.writeln('    Column');
        largeDpug.writeln('      children:');

        for (int i = 0; i < 1000; i++) {
          largeDpug.writeln('      Text');
          largeDpug.writeln('        ..text: "Item $i"');
          largeDpug.writeln('        ..key: ValueKey("$i")');
        }

        final startTime = DateTime.now();
        final result = converter.dpugToDart(largeDpug.toString());
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(
          duration.inSeconds,
          lessThan(10),
        ); // Should complete within 10 seconds

        expect(result, contains('class PerformanceTest'));
        expect(result, contains('Item 999')); // Last item should be present
      });

      test('Concurrent processing', () async {
        const dpugTemplate = '''
Text
  ..text: "Test %d"
  ..key: Key("test_%d")
''';

        final futures = List.generate(50, (final i) async {
          final dpug = dpugTemplate.replaceAll('%d', i.toString());
          return converter.dpugToDart(dpug);
        });

        final results = await Future.wait(futures);

        expect(results.length, equals(50));
        for (int i = 0; i < 50; i++) {
          expect(results[i], contains('Test $i'));
          expect(results[i], contains('Key("test_$i")'));
        }
      });
    });

    group('Real-world Scenarios', () {
      test('Complete app structure conversion', () {
        const appDpug = '''
@stateless
class MyApp
  Widget get build =>
    MaterialApp
      ..title: "DPug Demo"
      ..theme: ThemeData.light()
      ..home:
        Scaffold
          ..appBar:
            AppBar
              ..title: "DPug Demo"
          ..body:
            Center
              ..child:
                Column
                  mainAxisAlignment: MainAxisAlignment.center
                  children:
                    Text
                      ..text: "Welcome to DPug!"
                      ..style:
                        TextStyle
                          ..fontSize: 24.0
                          ..fontWeight: FontWeight.bold
                    ElevatedButton
                      ..onPressed: () => print("Button pressed")
                      ..child:
                        Text
                          ..text: "Press Me"
''';

        final dartCode = converter.dpugToDart(appDpug);

        expect(dartCode, contains('class MyApp'));
        expect(dartCode, contains('extends StatelessWidget'));
        expect(dartCode, contains('MaterialApp'));
        expect(dartCode, contains('Scaffold'));
        expect(dartCode, contains('AppBar'));
        expect(dartCode, contains('Center'));
        expect(dartCode, contains('Column'));
        expect(dartCode, contains('TextStyle'));
        expect(dartCode, contains('FontWeight.bold'));
      });

      test('Form with validation', () {
        const formDpug = '''
@stateful
class LoginForm
  @listen String email = ""
  @listen String password = ""
  @listen String? emailError
  @listen String? passwordError

  Widget get build =>
    Form
      ..key: _formKey
      ..child:
        Column
          children:
            TextFormField
              ..decoration:
                InputDecoration
                  ..labelText: "Email"
                  ..errorText: emailError
              ..onChanged: (value) => email = value
              ..validator: (value) =>
                value?.isEmpty ?? true ? "Email is required" : null
            TextFormField
              ..decoration:
                InputDecoration
                  ..labelText: "Password"
                  ..errorText: passwordError
              ..obscureText: true
              ..onChanged: (value) => password = value
              ..validator: (value) =>
                value?.length < 6 ? "Password too short" : null
            ElevatedButton
              ..onPressed: _submit
              ..child:
                Text
                  ..text: "Login"
''';

        final dartCode = converter.dpugToDart(formDpug);

        expect(dartCode, contains('class LoginForm'));
        expect(dartCode, contains('extends StatefulWidget'));
        expect(dartCode, contains('TextFormField'));
        expect(dartCode, contains('InputDecoration'));
        expect(dartCode, contains('validator:'));
        expect(dartCode, contains('Email is required'));
        expect(dartCode, contains('Password too short'));
      });
    });
  });
}
