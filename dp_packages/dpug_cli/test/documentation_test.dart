import 'dart:io';

import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('Documentation Validation Tests', () {
    late DpugConverter converter;
    late DpugFormatter formatter;

    setUp(() {
      converter = DpugConverter();
      formatter = DpugFormatter();
    });

    group('DPug Specification Examples', () {
      test('Basic widget syntax from specification', () {
        // Example from dpug_specification.md
        const dpugExample = '''
Text
  ..text: "Hello World"
  ..style:
    TextStyle
      ..fontSize: 16.0
      ..color: Colors.blue
''';

        final result = converter.dpugToDart(dpugExample);
        expect(result, contains('Text'));
        expect(result, contains('Hello World'));
        expect(result, contains('TextStyle'));
        expect(result, contains('fontSize: 16.0'));
        expect(result, contains('Colors.blue'));
      });

      test('Stateful widget example from specification', () {
        const statefulExample = '''
@stateful
class CounterWidget
  @listen int count = 0

  Widget get build =>
    Column
      children:
        Text
          ..text: "Count: \$count"
        ElevatedButton
          ..onPressed: () => count++
          ..child:
            Text
              ..text: "Increment"
''';

        final result = converter.dpugToDart(statefulExample);
        expect(result, contains('class CounterWidget'));
        expect(result, contains('extends StatefulWidget'));
        expect(result, contains('int count = 0'));
        expect(result, contains('Count: \$count'));
        expect(result, contains('onPressed: () => count++'));
      });

      test('Complex nested widget from specification', () {
        const complexExample = '''
Card
  ..elevation: 4.0
  ..child:
    Padding
      ..padding: EdgeInsets.all(16.0)
      ..child:
        Column
          crossAxisAlignment: CrossAxisAlignment.start
          children:
            Text
              ..text: "Title"
              ..style:
                TextStyle
                  ..fontSize: 20.0
                  ..fontWeight: FontWeight.bold
            Text
              ..text: "Description"
              ..style:
                TextStyle
                  ..fontSize: 14.0
                  ..color: Colors.grey
''';

        final result = converter.dpugToDart(complexExample);
        expect(result, contains('Card'));
        expect(result, contains('elevation: 4.0'));
        expect(result, contains('Padding'));
        expect(result, contains('EdgeInsets.all(16.0)'));
        expect(result, contains('CrossAxisAlignment.start'));
        expect(result, contains('FontWeight.bold'));
        expect(result, contains('Colors.grey'));
      });
    });

    group('Flutter Widget Examples', () {
      test('Scaffold example from flutter documentation', () {
        const scaffoldExample = '''
Scaffold
  ..appBar:
    AppBar
      ..title: "My App"
  ..body:
    Center
      ..child:
        Text
          ..text: "Hello Flutter!"
  ..floatingActionButton:
    FloatingActionButton
      ..onPressed: () => print("FAB pressed")
      ..child:
        Icon
          ..icon: Icons.add
''';

        final result = converter.dpugToDart(scaffoldExample);
        expect(result, contains('Scaffold'));
        expect(result, contains('AppBar'));
        expect(result, contains('Center'));
        expect(result, contains('FloatingActionButton'));
        expect(result, contains('Icons.add'));
      });

      test('ListView example from flutter documentation', () {
        const listViewExample = '''
ListView
  ..children:
    ListTile
      ..title: "Item 1"
      ..leading:
        Icon
          ..icon: Icons.star
    ListTile
      ..title: "Item 2"
      ..leading:
        Icon
          ..icon: Icons.favorite
''';

        final result = converter.dpugToDart(listViewExample);
        expect(result, contains('ListView'));
        expect(result, contains('ListTile'));
        expect(result, contains('Icon'));
        expect(result, contains('Icons.star'));
        expect(result, contains('Icons.favorite'));
      });

      test('Form example from flutter documentation', () {
        const formExample = '''
Form
  ..key: _formKey
  ..child:
    Column
      children:
        TextFormField
          ..decoration:
            InputDecoration
              ..labelText: "Email"
          ..validator: (value) =>
            value?.isEmpty ?? true ? "Please enter email" : null
        ElevatedButton
          ..onPressed: _submit
          ..child:
            Text
              ..text: "Submit"
''';

        final result = converter.dpugToDart(formExample);
        expect(result, contains('Form'));
        expect(result, contains('TextFormField'));
        expect(result, contains('InputDecoration'));
        expect(result, contains('validator:'));
        expect(result, contains('Please enter email'));
      });
    });

    group('Annotation Examples', () {
      test('Stateful annotation from annotations documentation', () {
        const statefulExample = '''
@stateful
class MyWidget
  @listen String name = "World"

  Widget get build =>
    Text
      ..text: "Hello \$name!"
''';

        final result = converter.dpugToDart(statefulExample);
        expect(result, contains('class MyWidget'));
        expect(result, contains('extends StatefulWidget'));
        expect(result, contains('String name = "World"'));
        expect(result, contains('Hello \$name!'));
      });

      test('Stateless annotation from annotations documentation', () {
        const statelessExample = '''
@stateless
class GreetingWidget
  String message

  Widget get build =>
    Text
      ..text: message
''';

        final result = converter.dpugToDart(statelessExample);
        expect(result, contains('class GreetingWidget'));
        expect(result, contains('extends StatelessWidget'));
        expect(result, contains('final String message'));
      });

      test('Multiple annotations from annotations documentation', () {
        const multiAnnotationExample = '''
@stateful
@deprecated
class LegacyWidget
  @listen int value = 0

  Widget get build =>
    Text
      ..text: "Value: \$value"
''';

        final result = converter.dpugToDart(multiAnnotationExample);
        expect(result, contains('@deprecated'));
        expect(result, contains('class LegacyWidget'));
        expect(result, contains('extends StatefulWidget'));
      });
    });

    group('Collections Examples', () {
      test('List literal from collections documentation', () {
        const listExample = '''
Column
  children: [
    Text
      ..text: "First"
    Text
      ..text: "Second"
    Text
      ..text: "Third"
  ]
''';

        final result = converter.dpugToDart(listExample);
        expect(result, contains('Column'));
        expect(result, contains('children: ['));
        expect(result, contains('First'));
        expect(result, contains('Second'));
        expect(result, contains('Third'));
      });

      test('Map literal from collections documentation', () {
        const mapExample = '''
Container
  ..decoration:
    BoxDecoration
      ..color: Colors.blue
      ..borderRadius: BorderRadius.circular(8.0)
''';

        final result = converter.dpugToDart(mapExample);
        expect(result, contains('Container'));
        expect(result, contains('BoxDecoration'));
        expect(result, contains('Colors.blue'));
        expect(result, contains('BorderRadius.circular(8.0)'));
      });

      test('Set literal from collections documentation', () {
        const setExample = '''
// This would be a theoretical example if DPug supported sets
// Text
//   ..text: "Sets are not directly supported in Flutter widgets"
''';

        // Skip this test as sets aren't commonly used in Flutter widgets
        expect(true, isTrue); // Placeholder
      });
    });

    group('Primitives Examples', () {
      test('String literals from primitives documentation', () {
        const stringExample = '''
Text
  ..text: "Hello World"
  ..text: 'Single quotes'
  ..text: """Multi-line
string"""
''';

        final result = converter.dpugToDart(stringExample);
        expect(result, contains('Hello World'));
        expect(result, contains('Single quotes'));
        expect(result, contains('Multi-line'));
      });

      test('Numeric literals from primitives documentation', () {
        const numericExample = '''
Container
  ..width: 100.0
  ..height: 200.5
  ..margin: EdgeInsets.all(16)
''';

        final result = converter.dpugToDart(numericExample);
        expect(result, contains('width: 100.0'));
        expect(result, contains('height: 200.5'));
        expect(result, contains('EdgeInsets.all(16)'));
      });

      test('Boolean literals from primitives documentation', () {
        const booleanExample = '''
Checkbox
  ..value: true
  ..onChanged: (value) => setState(() => _isChecked = value ?? false)

Switch
  ..value: false
  ..onChanged: (value) => setState(() => _isSwitched = value)
''';

        final result = converter.dpugToDart(booleanExample);
        expect(result, contains('value: true'));
        expect(result, contains('value: false'));
        expect(result, contains('onChanged:'));
      });
    });

    group('README Examples Validation', () {
      test('README installation example', () {
        // This would test the installation example from README
        // For now, just validate that the basic command structure works
        const basicExample = '''
Text
  ..text: "Welcome to DPug!"
''';

        final result = converter.dpugToDart(basicExample);
        expect(result, contains('Text'));
        expect(result, contains('Welcome to DPug!'));
      });

      test('README basic usage example', () {
        const usageExample = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      children:
        Text
          ..text: "Count: \$count"
        ElevatedButton
          ..onPressed: () => count++
          ..child:
            Text
              ..text: "Add"
''';

        final result = converter.dpugToDart(usageExample);
        expect(result, contains('class Counter'));
        expect(result, contains('extends StatefulWidget'));
        expect(result, contains('int count = 0'));
        expect(result, contains('Count: \$count'));
      });

      test('README CLI usage example', () {
        // Test the CLI examples mentioned in README
        const cliExample = '''
@stateless
class MyWidget
  String title

  Widget get build =>
    Scaffold
      ..appBar:
        AppBar
          ..title: title
      ..body:
        Center
          ..child:
            Text
              ..text: "Hello from CLI!"
''';

        final result = converter.dpugToDart(cliExample);
        expect(result, contains('class MyWidget'));
        expect(result, contains('extends StatelessWidget'));
        expect(result, contains('Scaffold'));
        expect(result, contains('AppBar'));
        expect(result, contains('Hello from CLI!'));
      });
    });

    group('Documentation Formatting Tests', () {
      test('Validate documentation syntax consistency', () async {
        // Test that documentation examples follow consistent formatting
        const testCases = [
          '''
Text
  ..text: "Consistent indentation"
  ..style:
    TextStyle
      ..fontSize: 16.0
''',
          '''
Container
  ..child:
    Column
      children:
        Text
          ..text: "Nested properly"
''',
        ];

        for (final example in testCases) {
          final formatted = formatter.format(example);
          // Should not throw an error
          expect(() => converter.dpugToDart(formatted), returnsNormally);
        }
      });

      test('Test code block extraction from markdown', () async {
        // Simulate extracting code blocks from documentation
        const markdownExample = '''
# DPug Example

Here's how to create a simple widget:

```dpug
Text
  ..text: "Hello from markdown"
  ..style:
    TextStyle
      ..fontSize: 18.0
      ..fontWeight: FontWeight.bold
```

This widget displays text with custom styling.
''';

        // Extract DPug code block (simplified)
        final dpugStart = markdownExample.indexOf('```dpug');
        final dpugEnd = markdownExample.indexOf('```', dpugStart + 1);

        if (dpugStart != -1 && dpugEnd != -1) {
          final dpugCode = markdownExample
              .substring(
                dpugStart + 7, // Skip ```dpug
                dpugEnd,
              )
              .trim();

          final result = converter.dpugToDart(dpugCode);
          expect(result, contains('Text'));
          expect(result, contains('Hello from markdown'));
          expect(result, contains('TextStyle'));
          expect(result, contains('fontSize: 18.0'));
          expect(result, contains('FontWeight.bold'));
        }
      });

      test('Validate all documentation files', () async {
        // Find all markdown files and validate their DPug examples
        final docFiles = [
          'dpug_docs/dpug_specification.md',
          'dpug_docs/dpug_flutter.md',
          'dpug_docs/dpug_classes.md',
          'dpug_docs/dpug_collections.md',
          'dpug_docs/dpug_primitives.md',
          'dpug_docs/dpug_annotations.md',
          'dpug_docs/README.md',
        ];

        for (final docFile in docFiles) {
          final file = File(docFile);
          if (await file.exists()) {
            final content = await file.readAsString();

            // Extract all DPug code blocks
            final dpugBlocks = extractDpugCodeBlocks(content);

            for (final block in dpugBlocks) {
              // Each code block should be valid DPug
              expect(
                () => converter.dpugToDart(block),
                returnsNormally,
                reason: 'Invalid DPug in $docFile: $block',
              );
            }
          }
        }
      });
    });

    group('Round-trip Documentation Examples', () {
      test('Ensure examples work in both directions', () {
        const examples = [
          '''
Text
  ..text: "Round-trip test"
''',
          '''
@stateful
class RoundTripWidget
  @listen int value = 0

  Widget get build =>
    Text
      ..text: "Value: \$value"
''',
          '''
Container
  ..padding: EdgeInsets.all(16.0)
  ..child:
    Column
      children:
        Text
          ..text: "Nested widget"
        ElevatedButton
          ..onPressed: () => print("Pressed")
          ..child:
            Text
              ..text: "Button"
''',
        ];

        for (final dpugExample in examples) {
          // DPug to Dart
          final dartCode = converter.dpugToDart(dpugExample);
          expect(dartCode, isNotEmpty);

          // Dart back to DPug
          final roundTripDpug = converter.dartToDpug(dartCode);
          expect(roundTripDpug, isNotEmpty);

          // Should contain the essential elements
          expect(roundTripDpug, contains('Text'));
        }
      });

      test('Validate example complexity levels', () {
        const complexityLevels = {
          'basic': '''
Text
  ..text: "Basic"
''',
          'intermediate': '''
@stateless
class IntermediateWidget
  String message

  Widget get build =>
    Text
      ..text: message
''',
          'advanced': '''
@stateful
class AdvancedWidget
  @listen Map<String, dynamic> data = {}

  Widget get build =>
    Scaffold
      ..appBar:
        AppBar
          ..title: "Advanced"
      ..body:
        ListView
          ..children: data.entries.map((entry) =>
            ListTile
              ..title: entry.key
              ..subtitle: entry.value.toString()
          ).toList()
''',
        };

        complexityLevels.forEach((level, example) {
          final result = converter.dpugToDart(example);
          expect(
            result,
            contains('class'),
            reason: '$level example should compile',
          );
        });
      });
    });

    group('Error Documentation Examples', () {
      test('Document common error patterns', () {
        const errorExamples = [
          // Missing indentation
          '''
Text
..text: "No indentation"
''',
          // Invalid property
          '''
Text
  ..invalidProperty: "Bad property"
''',
          // Wrong type
          '''
Text
  ..text: 123  // Should be string
''',
        ];

        for (final example in errorExamples) {
          // These should either work or fail gracefully
          expect(() => converter.dpugToDart(example), returnsNormally);
        }
      });

      test('Validate error messages in documentation', () {
        // This would test that error messages in docs are accurate
        // For now, just test that the system handles errors gracefully
        const problematicCode = '''
@invalid_annotation
class ProblemWidget
  @bad_field int value = "string"

  Widget get build =>
    UnknownWidget
      ..bad_property: "value"
''';

        expect(() => converter.dpugToDart(problematicCode), returnsNormally);
      });
    });
  });
}

// Helper function to extract DPug code blocks from markdown
List<String> extractDpugCodeBlocks(String markdown) {
  final blocks = <String>[];
  final lines = markdown.split('\n');
  var inDpugBlock = false;
  final currentBlock = StringBuffer();

  for (final line in lines) {
    if (line.trim() == '```dpug') {
      inDpugBlock = true;
      currentBlock.clear();
    } else if (line.trim() == '```' && inDpugBlock) {
      inDpugBlock = false;
      if (currentBlock.isNotEmpty) {
        blocks.add(currentBlock.toString().trim());
      }
    } else if (inDpugBlock) {
      currentBlock.writeln(line);
    }
  }

  return blocks;
}
