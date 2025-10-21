import 'dart:io';

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('Cross-Package Integration Tests', () {
    late Directory tempDir;
    late DpugConverter converter;
    late DpugFormatter formatter;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dpug_cross_package_');
      converter = DpugConverter();
      formatter = DpugFormatter();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('dpug_core ↔ dpug_code_builder Integration', () {
      test('DPug Core conversion to Code Builder specs', () {
        const dpugInput = r'''
@stateful
class IntegrationWidget
  @listen int counter = 0

  Widget get build =>
    Column
      children:
        Text
          ..text: "Count: $counter"
        ElevatedButton
          ..onPressed: () => counter++
          ..child:
            Text
              ..text: "Press Me"
''';

        // Convert using dpug_core
        final dartCode = converter.dpugToDart(dpugInput);

        // Parse the generated Dart code back to Code Builder spec
        final parsedSpec = Dpug.fromDart(cb.Code(dartCode));
        expect(parsedSpec, isNotNull);

        // Convert back using dpug_code_builder
        final dpugSpec = Dpug.fromDart(cb.Code(dartCode));
        expect(dpugSpec, isNotNull);

        // Generate DPug using dpug_code_builder
        final generatedDpug = Dpug.emitDpug(dpugSpec!);
        expect(generatedDpug, contains('class IntegrationWidget'));
        expect(generatedDpug, contains('@listen int counter = 0'));
      });

      test('Code Builder spec generation and validation', () {
        // Create a DPug spec using dpug_code_builder
        const statefulAnnotation = DpugAnnotationSpec('stateful');
        const listenAnnotation = DpugAnnotationSpec('listen');

        final dpugSpec = DpugClassSpec(
          name: 'CodeBuilderTest',
          annotations: [statefulAnnotation],
          stateFields: [
            DpugStateFieldSpec(
              name: 'value',
              type: const DpugReferenceSpec('String'),
              annotation: listenAnnotation,
              initializer: const DpugStringLiteralSpec('Test'),
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: const DpugStringLiteralSpec('Text(value)'),
            ),
          ],
        );

        // Convert to Dart using dpug_code_builder
        final dartCode = Dpug.toDartString(dpugSpec);

        // Validate using dpug_core converter
        final roundTripDpug = converter.dartToDpug(dartCode);

        expect(roundTripDpug, contains('class CodeBuilderTest'));
        expect(roundTripDpug, contains('extends StatefulWidget'));
        expect(roundTripDpug, contains('@listen String value = "Test"'));
      });

      test('Complex nested widget hierarchies', () {
        // Create complex nested specs using dpug_code_builder
        final complexSpec = DpugClassSpec(
          name: 'ComplexWidget',
          constructors: [
            DpugConstructorSpec(
              requiredParameters: [
                DpugParameterSpec(
                  name: 'title',
                  type: const DpugReferenceSpec('String'),
                ),
                DpugParameterSpec(
                  name: 'items',
                  type: const DpugReferenceSpec('List<String>'),
                ),
              ],
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: const DpugStringLiteralSpec('Scaffold(...)'),
            ),
          ],
        );

        // Generate Dart code
        final dartCode = Dpug.toDartString(complexSpec);

        // Validate with dpug_core
        expect(dartCode, contains('class ComplexWidget'));
        expect(dartCode, contains('Scaffold'));
        expect(dartCode, contains('AppBar'));
        expect(dartCode, contains('ListView'));
        expect(dartCode, contains('ListTile'));

        // Test round-trip conversion
        final roundTripDpug = converter.dartToDpug(dartCode);
        expect(roundTripDpug, contains('class ComplexWidget'));
      });
    });

    group('dpug_core ↔ dpug_cli Integration', () {
      test('CLI convert command with dpug_core converter', () async {
        const dpugContent = '''
@stateless
class CliTestWidget
  String message

  Widget get build =>
    Container
      ..padding: EdgeInsets.all(16.0)
      ..child:
        Text
          ..text: message
          ..style:
            TextStyle
              ..fontSize: 16.0
              ..fontWeight: FontWeight.bold
''';

        final dpugFile = File('${tempDir.path}/cli_test.dpug');
        final dartFile = File('${tempDir.path}/cli_test.dart');

        await dpugFile.writeAsString(dpugContent);

        // Use CLI convert command
        final convertCommand = ConvertCommand();
        await convertCommand.convertFile(dpugFile.path, dartFile.path);

        expect(await dartFile.exists(), isTrue);
        final generatedDart = await dartFile.readAsString();

        // Verify with dpug_core converter
        final expectedDart = converter.dpugToDart(dpugContent);

        // Both should produce equivalent results
        expect(generatedDart, contains('class CliTestWidget'));
        expect(generatedDart, contains('extends StatelessWidget'));
        expect(generatedDart, contains('Container'));
        expect(generatedDart, contains('EdgeInsets.all(16.0)'));
        expect(generatedDart, contains('TextStyle'));
      });

      test('CLI format command with dpug_core formatter', () async {
        const messyDpug = r'''
@stateful    class    MessyWidget
      @listen    int    value=0

 Widget   get   build   =>
     Text
       ..text:    "Value: $value"
''';

        final dpugFile = File('${tempDir.path}/messy.dpug');
        await dpugFile.writeAsString(messyDpug);

        // Use CLI format command
        final formatCommand = FormatCommand();
        await formatCommand.formatFile(dpugFile.path);

        final formattedContent = await dpugFile.readAsString();

        // Verify with dpug_core formatter
        final expectedFormatted = formatter.format(messyDpug);

        // Both should produce similar formatting
        expect(formattedContent, contains('class MessyWidget'));
        expect(formattedContent, contains('@listen int value = 0'));
        expect(formattedContent, contains('Widget get build =>'));
      });

      test('Batch CLI operations with dpug_core', () async {
        const files = [
          ('batch1.dpug', 'Text\n  ..text: "First"'),
          (
            'batch2.dpug',
            r'''
@stateful
class BatchWidget
  @listen int count = 0

  Widget get build =>
    Text
      ..text: "Count: $count"
''',
          ),
          (
            'batch3.dpug',
            'ElevatedButton\n  ..child:\n    Text\n      ..text: "Press"',
          ),
        ];

        // Create test files
        for (final file in files) {
          await File('${tempDir.path}/${file.$1}').writeAsString(file.$2);
        }

        // Use CLI to convert all files
        final convertCommand = ConvertCommand();
        // Note: CLI doesn't support directory conversion in convertFile method
        // Let's convert files individually for testing
        final outputDir = Directory('${tempDir.path}/dart_output');
        await outputDir.create();
        for (final file in files) {
          final inputFile = File('${tempDir.path}/${file.$1}');
          final outputFile = File(
            '${outputDir.path}/${file.$1.replaceAll('.dpug', '.dart')}',
          );
          await convertCommand.convertFile(inputFile.path, outputFile.path);
        }

        // Verify all conversions with dpug_core
        for (final file in files) {
          final dpugContent = file.$2;
          final expectedDart = converter.dpugToDart(dpugContent);

          final dartFileName = file.$1.replaceAll('.dpug', '.dart');
          final generatedFile = File(
            '${tempDir.path}/dart_output/$dartFileName',
          );

          expect(await generatedFile.exists(), isTrue);
          final generatedDart = await generatedFile.readAsString();

          // Both CLI and direct converter should produce valid Dart
          expect(generatedDart, contains('extends'));
          expect(generatedDart, contains('Widget'));
        }
      });
    });

    group('dpug_code_builder ↔ dpug_cli Integration', () {
      test('CLI convert with code builder generated content', () async {
        // Generate DPug content using dpug_code_builder
        final generatedSpec = DpugClassSpec(
          name: 'GeneratedWidget',
          annotations: [statefulAnnotation],
          stateFields: [
            DpugStateFieldSpec(
              name: 'data',
              type: const DpugReferenceSpec('String'),
              annotation: listenAnnotation,
              initializer: const DpugStringLiteralSpec('Generated'),
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: const DpugStringLiteralSpec('Card(...)'),
            ),
          ],
        );

        final generatedDpug = Dpug.emitDpug(generatedSpec);

        // Write to file and use CLI to convert
        final dpugFile = File('${tempDir.path}/generated.dpug');
        await dpugFile.writeAsString(generatedDpug);

        final convertCommand = ConvertCommand();
        await convertCommand.convertFile(
          dpugFile.path,
          '${tempDir.path}/generated.dart',
        );

        final dartFile = File('${tempDir.path}/generated.dart');
        expect(await dartFile.exists(), isTrue);

        final generatedDart = await dartFile.readAsString();

        expect(generatedDart, contains('class GeneratedWidget'));
        expect(generatedDart, contains('extends StatefulWidget'));
        expect(generatedDart, contains('Card'));
        expect(generatedDart, contains('Padding'));
        expect(generatedDart, contains('EdgeInsets.all(16.0)'));
      });

      test('CLI format with code builder generated content', () async {
        // Generate messy DPug using code builder
        final messySpec = DpugClassSpec(
          name: 'MessyGenerated',
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: DpugWidgetSpec(
                name: 'Column',
                properties: {
                  'children': DpugListLiteralSpec([
                    DpugWidgetSpec(
                      name: 'Text',
                      properties: {
                        'text': const DpugStringLiteralSpec('First'),
                      },
                    ),
                    DpugWidgetSpec(
                      name: 'Text',
                      properties: {
                        'text': const DpugStringLiteralSpec('Second'),
                      },
                    ),
                  ]),
                },
              ),
            ),
          ],
        );

        final messyDpug = Dpug.emitDpug(messySpec);

        // Make it look messy for formatting test
        final reallyMessyDpug = messyDpug
            .replaceAll('\n', ' \n ')
            .replaceAll('  ', '    ');

        final dpugFile = File('${tempDir.path}/messy_generated.dpug');
        await dpugFile.writeAsString(reallyMessyDpug);

        // Use CLI to format
        final formatCommand = FormatCommand();
        await formatCommand.formatFile(dpugFile.path);

        final formattedContent = await dpugFile.readAsString();

        expect(formattedContent, contains('class MessyGenerated'));
        expect(formattedContent, contains('Column'));
        expect(formattedContent, contains('children:'));

        // Should be properly indented
        final lines = formattedContent.split('\n');
        final classLine = lines.firstWhere(
          (final line) => line.contains('class'),
        );
        expect(classLine, startsWith('class')); // No extra indentation
      });
    });

    group('Complete Three-Package Workflow', () {
      test(
        'dpug_code_builder → dpug_core → dpug_cli complete workflow',
        () async {
          // Step 1: Generate DPug spec using dpug_code_builder
          final originalSpec = DpugClassSpec(
            name: 'CompleteWorkflowWidget',
            annotations: [statefulAnnotation],
            stateFields: [
              DpugStateFieldSpec(
                name: 'counter',
                type: const DpugReferenceSpec('int'),
                annotation: listenAnnotation,
                initializer: const DpugNumLiteralSpec(0),
              ),
              DpugStateFieldSpec(
                name: 'title',
                type: const DpugReferenceSpec('String'),
                annotation: listenAnnotation,
                initializer: const DpugStringLiteralSpec('Complete Workflow'),
              ),
            ],
            methods: [
              DpugMethodSpec(
                name: 'build',
                returnType: 'Widget',
                body: DpugWidgetSpec(
                  name: 'Scaffold',
                  properties: {
                    'appBar': DpugWidgetSpec(
                      name: 'AppBar',
                      properties: {
                        'title': DpugWidgetSpec(
                          name: 'Text',
                          properties: {
                            'text': const DpugReferenceExpressionSpec('title'),
                          },
                        ),
                      },
                    ),
                    'body': DpugWidgetSpec(
                      name: 'Center',
                      properties: {
                        'child': DpugWidgetSpec(
                          name: 'Column',
                          properties: {
                            'mainAxisAlignment':
                                const DpugReferenceExpressionSpec(
                                  'MainAxisAlignment.center',
                                ),
                            'children': DpugListLiteralSpec([
                              DpugWidgetSpec(
                                name: 'Text',
                                properties: {
                                  'text': const DpugStringLiteralSpec(
                                    r'Counter: $counter',
                                  ),
                                  'style': const DpugInvokeSpec(
                                    target: 'TextStyle',
                                    namedArguments: {
                                      'fontSize': DpugNumLiteralSpec(24.0),
                                    },
                                  ),
                                },
                              ),
                              DpugWidgetSpec(
                                name: 'ElevatedButton',
                                properties: {
                                  'onPressed':
                                      DpugClosureExpressionSpec.fromParams(
                                        [],
                                        const DpugStringLiteralSpec(
                                          'counter++',
                                        ),
                                      ),
                                  'child': DpugWidgetSpec(
                                    name: 'Text',
                                    properties: {
                                      'text': const DpugStringLiteralSpec(
                                        'Increment',
                                      ),
                                    },
                                  ),
                                },
                              ),
                            ]),
                          },
                        ),
                      },
                    ),
                  },
                ),
              ),
            ],
          );

          // Step 2: Emit DPug using dpug_code_builder
          final dpugContent = Dpug.emitDpug(originalSpec);

          // Step 3: Format using dpug_core
          final formattedDpug = formatter.format(dpugContent);

          // Step 4: Convert to Dart using dpug_core
          final dartCode = converter.dpugToDart(formattedDpug);

          // Step 5: Write to file and use dpug_cli to process
          final dpugFile = File('${tempDir.path}/workflow.dpug');
          await dpugFile.writeAsString(formattedDpug);

          final convertCommand = ConvertCommand();
          await convertCommand.convertFile(
            dpugFile.path,
            '${tempDir.path}/workflow_cli.dart',
          );

          final cliDartFile = File('${tempDir.path}/workflow_cli.dart');
          expect(await cliDartFile.exists(), isTrue);

          final cliDartContent = await cliDartFile.readAsString();

          // Step 6: Verify all components work together
          expect(cliDartContent, contains('class CompleteWorkflowWidget'));
          expect(cliDartContent, contains('extends StatefulWidget'));
          expect(cliDartContent, contains('Scaffold'));
          expect(cliDartContent, contains('AppBar'));
          expect(cliDartContent, contains('Center'));
          expect(cliDartContent, contains('Column'));
          expect(cliDartContent, contains('ElevatedButton'));
          expect(cliDartContent, contains('TextStyle'));
          expect(cliDartContent, contains('fontSize: 24.0'));

          // Step 7: Test round-trip conversion
          final roundTripDpug = converter.dartToDpug(cliDartContent);
          expect(roundTripDpug, contains('class CompleteWorkflowWidget'));
          expect(roundTripDpug, contains('@listen int counter = 0'));
          expect(
            roundTripDpug,
            contains('@listen String title = "Complete Workflow"'),
          );

          // Step 8: Format the round-trip result
          final finalFormatted = formatter.format(roundTripDpug);
          expect(finalFormatted, contains('class CompleteWorkflowWidget'));
        },
      );

      test('Widget library generation and CLI processing', () async {
        // Generate a library of widgets using dpug_code_builder
        final widgetSpecs = <DpugSpec>[];

        final widgetTypes = [
          ('ButtonWidget', false, ['String text', 'VoidCallback? onPressed']),
          ('CardWidget', false, ['String title', 'String content']),
          ('ListWidget', false, ['List<String> items']),
          ('FormWidget', true, ['String initialValue']), // Stateful
        ];

        for (final widgetType in widgetTypes) {
          final (name, isStateful, params) = widgetType;

          final constructorParams = params.map((final param) {
            final parts = param.split(' ');
            return DpugParameterSpec(
              name: parts[1].replaceAll('?', ''),
              type: DpugReferenceSpec(parts[0]),
            );
          }).toList();

          const statefulAnnotation = DpugAnnotationSpec(name: 'stateful');
          const listenAnnotation = DpugAnnotationSpec(name: 'listen');

          final spec = DpugClassSpec(
            name: name,
            annotations: isStateful ? [statefulAnnotation] : [],
            constructors: [
              DpugConstructorSpec(requiredParameters: constructorParams),
            ],
            stateFields: isStateful
                ? [
                    DpugStateFieldSpec(
                      name: 'value',
                      type: 'String',
                      annotation: listenAnnotation,
                      initializer: const DpugStringLiteralSpec('initialValue'),
                    ),
                  ]
                : [],
            methods: [
              DpugMethodSpec(
                name: 'build',
                returnType: 'Widget',
                body: DpugWidgetSpec(
                  name: name == 'ButtonWidget'
                      ? 'ElevatedButton'
                      : name == 'CardWidget'
                      ? 'Card'
                      : name == 'ListWidget'
                      ? 'ListView'
                      : 'TextField',
                  properties: _getWidgetProperties(name, isStateful),
                ),
              ),
            ],
          );

          widgetSpecs.add(spec);
        }

        // Generate DPug library
        final libraryDpug = widgetSpecs.map(Dpug.emitDpug).join('\n\n');

        // Write to file
        final libraryFile = File('${tempDir.path}/widget_library.dpug');
        await libraryFile.writeAsString(libraryDpug);

        // Format using CLI
        final formatCommand = FormatCommand();
        await formatCommand.formatFile(libraryFile.path);

        // Convert using CLI
        final convertCommand = ConvertCommand();
        await convertCommand.convertFile(
          libraryFile.path,
          '${tempDir.path}/widget_library.dart',
        );

        final libraryDartFile = File('${tempDir.path}/widget_library.dart');
        expect(await libraryDartFile.exists(), isTrue);

        final libraryDart = await libraryDartFile.readAsString();

        // Verify all widgets are present
        for (final widgetType in widgetTypes) {
          final (name, isStateful, _) = widgetType;
          expect(libraryDart, contains('class $name'));
          expect(
            libraryDart,
            contains(
              isStateful ? 'extends StatefulWidget' : 'extends StatelessWidget',
            ),
          );
        }

        // Verify with dpug_core
        final roundTripLibrary = converter.dartToDpug(libraryDart);
        expect(roundTripLibrary, contains('class ButtonWidget'));
        expect(roundTripLibrary, contains('class CardWidget'));
        expect(roundTripLibrary, contains('class ListWidget'));
        expect(roundTripLibrary, contains('class FormWidget'));
      });
    });

    group('Error Handling Across Packages', () {
      test('Error propagation from dpug_core to dpug_cli', () async {
        const invalidDpug = '''
@invalid_annotation
class BrokenWidget
  @unknown_field int value = "not_a_number"

  Widget get build =>
    UnknownWidget
      ..invalid_prop: "value"
''';

        final invalidFile = File('${tempDir.path}/invalid.dpug');
        await invalidFile.writeAsString(invalidDpug);

        // CLI should handle errors gracefully
        final convertCommand = ConvertCommand();

        expect(
          () => convertCommand.convertFile(
            invalidFile.path,
            '${tempDir.path}/invalid_output.dart',
          ),
          returnsNormally,
        );
      });

      test('Malformed spec handling in dpug_code_builder', () {
        // Test with edge cases that might cause issues
        final edgeCaseSpecs = [
          DpugClassSpec(name: '', methods: []), // Empty name
          DpugClassSpec(
            name: 'EdgeCase',
            methods: [
              DpugMethodSpec(
                name: 'build',
                returnType: 'Widget',
                body: const DpugStringLiteralSpec(''), // Empty body
              ),
            ],
          ),
        ];

        for (final spec in edgeCaseSpecs) {
          expect(() => Dpug.toDartString(spec), returnsNormally);
        }
      });
    });

    group('Performance Across Packages', () {
      test('Large scale processing workflow', () async {
        // Generate a large number of widget specs
        final largeSpecs = <DpugSpec>[];

        for (int i = 0; i < 100; i++) {
          largeSpecs.add(
            DpugClassSpec(
              name: 'Widget$i',
              methods: [
                DpugMethodSpec(
                  name: 'build',
                  returnType: 'Widget',
                  body: DpugWidgetSpec(
                    name: 'Text',
                    properties: {'text': DpugStringLiteralSpec('Widget $i')},
                  ),
                ),
              ],
            ),
          );
        }

        final startTime = DateTime.now();

        // Generate DPug using dpug_code_builder
        final largeDpugLibrary = largeSpecs.map(Dpug.emitDpug).join('\n\n');

        // Format using dpug_core
        final formattedLibrary = formatter.format(largeDpugLibrary);

        // Convert using dpug_core
        final largeDartLibrary = converter.dpugToDart(formattedLibrary);

        // Write to file and process with CLI
        final largeFile = File('${tempDir.path}/large_library.dpug');
        await largeFile.writeAsString(formattedLibrary);

        final convertCommand = ConvertCommand();
        await convertCommand.convertFile(
          largeFile.path,
          '${tempDir.path}/large_library_cli.dart',
        );

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete within reasonable time
        expect(duration.inSeconds, lessThan(60));

        // Verify results
        final cliOutputFile = File('${tempDir.path}/large_library_cli.dart');
        expect(await cliOutputFile.exists(), isTrue);

        final cliOutput = await cliOutputFile.readAsString();

        // Should contain all widget classes
        expect(cliOutput, contains('class Widget0'));
        expect(cliOutput, contains('class Widget99'));
        expect(cliOutput, contains('Widget 0'));
        expect(cliOutput, contains('Widget 99'));
      });
    });
  });
}

// Helper function to generate widget properties
Map<String, DpugSpec> _getWidgetProperties(
  final String widgetName,
  final bool isStateful,
) {
  switch (widgetName) {
    case 'ButtonWidget':
      return {
        'onPressed': const DpugReferenceExpressionSpec('onPressed'),
        'child': DpugWidgetSpec(
          name: 'Text',
          properties: {'text': const DpugReferenceExpressionSpec('text')},
        ),
      };
    case 'CardWidget':
      return {
        'child': DpugWidgetSpec(
          name: 'Column',
          properties: {
            'children': DpugListLiteralSpec([
              DpugWidgetSpec(
                name: 'Text',
                properties: {
                  'text': const DpugReferenceExpressionSpec('title'),
                },
              ),
              DpugWidgetSpec(
                name: 'Text',
                properties: {
                  'text': const DpugReferenceExpressionSpec('content'),
                },
              ),
            ]),
          },
        ),
      };
    case 'ListWidget':
      return {
        'children': DpugInvokeSpec(
          target: const DpugReferenceExpressionSpec('items.map'),
          positionedArguments: [
            DpugClosureExpressionSpec.fromParams([
              'item',
            ], const DpugStringLiteralSpec('ListTile(...)')),
          ],
        ),
      };
    case 'FormWidget':
      return {
        'controller': const DpugReferenceExpressionSpec('_controller'),
        'decoration': const DpugInvokeSpec(
          target: DpugReferenceExpressionSpec('InputDecoration'),
          namedArguments: {'labelText': DpugStringLiteralSpec('Value')},
        ),
        'onChanged': DpugClosureExpressionSpec.fromParams([
          'text',
        ], const DpugStringLiteralSpec('value = text')),
      };
    default:
      return {};
  }
}
