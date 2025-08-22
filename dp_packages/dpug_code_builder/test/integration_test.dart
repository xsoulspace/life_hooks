import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Code Builder End-to-End Integration Tests', () {
    group('Complete Code Generation Workflows', () {
      test('Round-trip conversion: DPugSpec → Dart → DPugSpec', () {
        // Create a DPug spec for a stateful widget
        final dpugSpec = DpugClassSpec(
          name: 'TestWidget',
          isStateful: true,
          stateFields: [
            DpugStateFieldSpec(name: 'count', type: 'int', initialValue: '0'),
          ],
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
                        'text': const DpugStringLiteralSpec(r'Count: $count'),
                      },
                    ),
                    DpugWidgetSpec(
                      name: 'ElevatedButton',
                      properties: {
                        'onPressed': DpugClosureSpec(
                          parameters: [],
                          body: 'count++',
                        ),
                        'child': DpugWidgetSpec(
                          name: 'Text',
                          properties: {
                            'text': const DpugStringLiteralSpec('Increment'),
                          },
                        ),
                      },
                    ),
                  ]),
                },
              ),
            ),
          ],
        );

        // Convert DPugSpec to Dart
        final dartSpec = Dpug.toDart(dpugSpec);
        final dartCode = Dpug.toDartString(dpugSpec);

        expect(dartCode, contains('class TestWidget'));
        expect(dartCode, contains('extends StatefulWidget'));
        expect(dartCode, contains('int count = 0'));
        expect(dartCode, contains(r'Count: $count'));

        // Convert back to DPugSpec
        final roundTripDpugSpec = Dpug.fromDart(dartSpec);
        expect(roundTripDpugSpec, isNotNull);
        expect(roundTripDpugSpec!.name, equals('TestWidget'));

        if (roundTripDpugSpec is DpugClassSpec) {
          expect(roundTripDpugSpec.isStateful, isTrue);
          expect(roundTripDpugSpec.stateFields.length, equals(1));
          expect(roundTripDpugSpec.stateFields[0].name, equals('count'));
        }
      });

      test('Complex widget hierarchy generation', () {
        final profileCardSpec = DpugClassSpec(
          name: 'ProfileCard',
          constructors: [
            DpugConstructorSpec(
              parameters: [
                DpugParameterSpec(name: 'name', type: 'String'),
                DpugParameterSpec(name: 'email', type: 'String'),
                DpugParameterSpec(name: 'avatarUrl', type: 'String'),
              ],
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: DpugWidgetSpec(
                name: 'Card',
                properties: {
                  'elevation': const DpugNumLiteralSpec(4.0),
                  'child': DpugWidgetSpec(
                    name: 'Padding',
                    properties: {
                      'padding': const DpugInvokeSpec(
                        target: 'EdgeInsets.all',
                        arguments: [DpugNumLiteralSpec(16.0)],
                      ),
                      'child': DpugWidgetSpec(
                        name: 'Row',
                        properties: {
                          'children': DpugListLiteralSpec([
                            DpugWidgetSpec(
                              name: 'CircleAvatar',
                              properties: {
                                'backgroundImage': const DpugInvokeSpec(
                                  target: 'NetworkImage',
                                  arguments: [
                                    DpugReferenceExpressionSpec('avatarUrl'),
                                  ],
                                ),
                                'radius': const DpugNumLiteralSpec(30.0),
                              },
                            ),
                            DpugWidgetSpec(
                              name: 'SizedBox',
                              properties: {
                                'width': const DpugNumLiteralSpec(16.0),
                              },
                            ),
                            DpugWidgetSpec(
                              name: 'Expanded',
                              properties: {
                                'child': DpugWidgetSpec(
                                  name: 'Column',
                                  properties: {
                                    'crossAxisAlignment':
                                        const DpugReferenceExpressionSpec(
                                          'CrossAxisAlignment.start',
                                        ),
                                    'children': DpugListLiteralSpec([
                                      DpugWidgetSpec(
                                        name: 'Text',
                                        properties: {
                                          'text':
                                              const DpugReferenceExpressionSpec(
                                                'name',
                                              ),
                                          'style': const DpugInvokeSpec(
                                            target: 'TextStyle',
                                            arguments: [],
                                            namedArguments: {
                                              'fontSize': DpugNumLiteralSpec(
                                                18.0,
                                              ),
                                              'fontWeight':
                                                  DpugReferenceExpressionSpec(
                                                    'FontWeight.bold',
                                                  ),
                                            },
                                          ),
                                        },
                                      ),
                                      DpugWidgetSpec(
                                        name: 'Text',
                                        properties: {
                                          'text':
                                              const DpugReferenceExpressionSpec(
                                                'email',
                                              ),
                                          'style': const DpugInvokeSpec(
                                            target: 'TextStyle',
                                            arguments: [],
                                            namedArguments: {
                                              'fontSize': DpugNumLiteralSpec(
                                                14.0,
                                              ),
                                              'color':
                                                  DpugReferenceExpressionSpec(
                                                    'Colors.grey',
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

        final dartCode = Dpug.toDartString(profileCardSpec);

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

    group('Builder Pattern Integration', () {
      test('Class builder workflow', () {
        final classBuilder = Dpug.classBuilder()
          ..name = 'BuilderTestWidget'
          ..isStateful = true;

        classBuilder.stateFields.add(
          DpugStateFieldSpec(
            name: 'value',
            type: 'String',
            initialValue: '"Hello"',
          ),
        );

        classBuilder.methods.add(
          DpugMethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: DpugWidgetSpec(
              name: 'Text',
              properties: {'text': const DpugReferenceExpressionSpec('value')},
            ),
          ),
        );

        final spec = classBuilder.build();
        final dartCode = Dpug.toDartString(spec);

        expect(dartCode, contains('class BuilderTestWidget'));
        expect(dartCode, contains('extends StatefulWidget'));
        expect(dartCode, contains('String value = "Hello"'));
        expect(dartCode, contains('Text(text: value)'));
      });

      test('Widget builder integration', () {
        final widgetBuilder = Dpug.widgetBuilder();

        final widgetSpec = widgetBuilder.buildWidget(
          name: 'Container',
          properties: {
            'padding': const DpugInvokeSpec(
              target: 'EdgeInsets.all',
              arguments: [DpugNumLiteralSpec(8.0)],
            ),
            'child': DpugWidgetSpec(
              name: 'Text',
              properties: {
                'text': const DpugStringLiteralSpec('Nested Widget'),
              },
            ),
          },
        );

        final dartCode = Dpug.toDartString(widgetSpec);

        expect(dartCode, contains('Container'));
        expect(dartCode, contains('EdgeInsets.all(8.0)'));
        expect(dartCode, contains('Text'));
        expect(dartCode, contains('Nested Widget'));
      });
    });

    group('Expression and Literal Handling', () {
      test('Complex expression evaluation', () {
        final expressions = [
          const DpugStringLiteralSpec('Hello World'),
          const DpugNumLiteralSpec(42),
          const DpugBoolLiteralSpec(true),
          const DpugListLiteralSpec([
            DpugStringLiteralSpec('item1'),
            DpugStringLiteralSpec('item2'),
          ]),
          const DpugInvokeSpec(target: 'Colors.blue', arguments: []),
          const DpugBinarySpec(
            left: DpugNumLiteralSpec(10),
            operator: '+',
            right: DpugNumLiteralSpec(5),
          ),
          DpugClosureSpec(
            parameters: [DpugParameterSpec(name: 'x', type: 'int')],
            body: 'x * 2',
          ),
        ];

        for (final expr in expressions) {
          final dartSpec = Dpug.toDart(expr);
          final dartCode = Dpug.toDartString(expr);
          expect(dartCode, isNotEmpty);

          // Should be able to convert back
          final roundTrip = Dpug.fromDart(dartSpec);
          expect(roundTrip, isNotNull);
        }
      });

      test('Reference resolution', () {
        final methodSpec = DpugMethodSpec(
          name: 'calculate',
          returnType: 'int',
          body: const DpugBinarySpec(
            left: DpugReferenceExpressionSpec('a'),
            operator: '+',
            right: DpugReferenceExpressionSpec('b'),
          ),
        );

        final dartCode = Dpug.toDartString(methodSpec);

        expect(dartCode, contains('a + b'));
      });
    });

    group('Annotation and Metadata Integration', () {
      test('Class annotations', () {
        final annotatedClass = DpugClassSpec(
          name: 'AnnotatedWidget',
          annotations: [
            const DpugAnnotationSpec(name: 'deprecated'),
            const DpugAnnotationSpec(
              name: 'pragma',
              arguments: [DpugStringLiteralSpec('vm:entry-point')],
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: DpugWidgetSpec(
                name: 'Text',
                properties: {'text': const DpugStringLiteralSpec('Annotated')},
              ),
            ),
          ],
        );

        final dartCode = Dpug.toDartString(annotatedClass);

        expect(dartCode, contains('@deprecated'));
        expect(dartCode, contains('@pragma'));
        expect(dartCode, contains('vm:entry-point'));
        expect(dartCode, contains('class AnnotatedWidget'));
      });

      test('Method annotations', () {
        final methodWithAnnotations = DpugMethodSpec(
          name: 'annotatedMethod',
          returnType: 'void',
          annotations: [
            const DpugAnnotationSpec(name: 'override'),
            const DpugAnnotationSpec(
              name: 'pragma',
              arguments: [DpugStringLiteralSpec('vm:prefer-inline')],
            ),
          ],
          body: const DpugStringLiteralSpec('print("Hello")'),
        );

        final dartCode = Dpug.toDartString(methodWithAnnotations);

        expect(dartCode, contains('@override'));
        expect(dartCode, contains('@pragma'));
        expect(dartCode, contains('vm:prefer-inline'));
        expect(dartCode, contains('void annotatedMethod()'));
      });
    });

    group('Large Scale Code Generation', () {
      test('Generate multiple related classes', () {
        final specs = <DpugSpec>[];

        // Generate 10 related widget classes
        for (int i = 0; i < 10; i++) {
          specs.add(
            DpugClassSpec(
              name: 'GeneratedWidget$i',
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

        final generatedCode = Dpug.toIterableDartString(specs);

        for (int i = 0; i < 10; i++) {
          expect(generatedCode, contains('class GeneratedWidget$i'));
          expect(generatedCode, contains('Widget $i'));
        }
      });

      test('Nested widget hierarchies', () {
        // Create deeply nested widget structure
        DpugSpec createNestedWidget(final int depth) {
          if (depth <= 0) {
            return DpugWidgetSpec(
              name: 'Text',
              properties: {'text': const DpugStringLiteralSpec('Leaf')},
            );
          }

          return DpugWidgetSpec(
            name: 'Container',
            properties: {'child': createNestedWidget(depth - 1)},
          );
        }

        final deepWidget = createNestedWidget(5);
        final dartCode = Dpug.toDartString(deepWidget);

        // Should contain 5 levels of nesting
        final containerCount = 'Container'.allMatches(dartCode).length;
        expect(containerCount, equals(5));
        expect(dartCode, contains('Text'));
        expect(dartCode, contains('Leaf'));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('Invalid spec handling', () {
        // Test with null values
        final invalidSpec = DpugClassSpec(name: '', methods: []);

        expect(() => Dpug.toDartString(invalidSpec), returnsNormally);
      });

      test('Empty and minimal specs', () {
        final emptyClass = DpugClassSpec(name: 'EmptyClass', methods: []);

        final dartCode = Dpug.toDartString(emptyClass);
        expect(dartCode, contains('class EmptyClass'));

        final minimalMethod = DpugMethodSpec(
          name: 'empty',
          returnType: 'void',
          body: const DpugStringLiteralSpec(''),
        );

        final methodCode = Dpug.toDartString(minimalMethod);
        expect(methodCode, contains('void empty()'));
      });

      test('Circular reference handling', () {
        final selfReferencingWidget = DpugWidgetSpec(
          name: 'Container',
          properties: {
            'child': DpugWidgetSpec(
              name: 'Container',
              properties: {
                'child': DpugWidgetSpec(
                  name: 'Container',
                  properties: {
                    'child': const DpugReferenceExpressionSpec('this'),
                  },
                ),
              },
            ),
          },
        );

        final dartCode = Dpug.toDartString(selfReferencingWidget);
        expect(dartCode, contains('Container'));
        expect(dartCode, contains('child: this'));
      });
    });

    group('Performance and Memory', () {
      test('Large code generation performance', () {
        // Generate a large number of specs
        final specs = <DpugSpec>[];

        for (int i = 0; i < 1000; i++) {
          specs.add(
            DpugClassSpec(
              name: 'PerformanceClass$i',
              methods: [
                DpugMethodSpec(
                  name: 'build',
                  returnType: 'Widget',
                  body: DpugWidgetSpec(
                    name: 'Text',
                    properties: {
                      'text': DpugStringLiteralSpec('Performance test $i'),
                    },
                  ),
                ),
              ],
            ),
          );
        }

        final startTime = DateTime.now();
        final generatedCode = Dpug.toIterableDartString(specs);
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(
          duration.inSeconds,
          lessThan(30),
        ); // Should complete within 30 seconds

        expect(generatedCode, contains('class PerformanceClass999'));
        expect(generatedCode, contains('Performance test 999'));
      });

      test('Memory efficiency with large specs', () {
        // Create a spec with many nested elements
        final largeNestedSpec = DpugClassSpec(
          name: 'LargeNestedClass',
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: createLargeNestedWidget(100),
            ),
          ],
        );

        final dartCode = Dpug.toDartString(largeNestedSpec);
        expect(
          dartCode.length,
          greaterThan(1000),
        ); // Should generate substantial code
        expect(dartCode, contains('class LargeNestedClass'));
      });
    });

    group('Real-world Code Generation Scenarios', () {
      test('Form widget generation', () {
        final formClass = DpugClassSpec(
          name: 'LoginForm',
          isStateful: true,
          stateFields: [
            DpugStateFieldSpec(
              name: 'email',
              type: 'String',
              initialValue: '""',
            ),
            DpugStateFieldSpec(
              name: 'password',
              type: 'String',
              initialValue: '""',
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: DpugWidgetSpec(
                name: 'Form',
                properties: {
                  'key': const DpugReferenceExpressionSpec('_formKey'),
                  'child': DpugWidgetSpec(
                    name: 'Column',
                    properties: {
                      'children': DpugListLiteralSpec([
                        DpugWidgetSpec(
                          name: 'TextFormField',
                          properties: {
                            'decoration': const DpugInvokeSpec(
                              target: 'InputDecoration',
                              arguments: [],
                              namedArguments: {
                                'labelText': DpugStringLiteralSpec('Email'),
                              },
                            ),
                            'onChanged': DpugClosureSpec(
                              parameters: [
                                DpugParameterSpec(
                                  name: 'value',
                                  type: 'String',
                                ),
                              ],
                              body: 'email = value',
                            ),
                          },
                        ),
                        DpugWidgetSpec(
                          name: 'TextFormField',
                          properties: {
                            'decoration': const DpugInvokeSpec(
                              target: 'InputDecoration',
                              arguments: [],
                              namedArguments: {
                                'labelText': DpugStringLiteralSpec('Password'),
                              },
                            ),
                            'obscureText': const DpugBoolLiteralSpec(true),
                            'onChanged': DpugClosureSpec(
                              parameters: [
                                DpugParameterSpec(
                                  name: 'value',
                                  type: 'String',
                                ),
                              ],
                              body: 'password = value',
                            ),
                          },
                        ),
                      ]),
                    },
                  ),
                },
              ),
            ),
          ],
        );

        final dartCode = Dpug.toDartString(formClass);

        expect(dartCode, contains('class LoginForm'));
        expect(dartCode, contains('extends StatefulWidget'));
        expect(dartCode, contains('TextFormField'));
        expect(dartCode, contains('InputDecoration'));
        expect(dartCode, contains('obscureText: true'));
        expect(dartCode, contains('onChanged: (value)'));
      });

      test('List view with dynamic content', () {
        final listViewClass = DpugClassSpec(
          name: 'ItemList',
          constructors: [
            DpugConstructorSpec(
              parameters: [
                DpugParameterSpec(name: 'items', type: 'List<String>'),
              ],
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: DpugWidgetSpec(
                name: 'ListView',
                properties: {
                  'children': DpugInvokeSpec(
                    target: 'items.map',
                    arguments: [
                      DpugClosureSpec(
                        parameters: [
                          DpugParameterSpec(name: 'item', type: 'String'),
                        ],
                        body: const DpugInvokeSpec(
                          target: 'ListTile',
                          arguments: [],
                          namedArguments: {
                            'title': DpugInvokeSpec(
                              target: 'Text',
                              arguments: [DpugReferenceExpressionSpec('item')],
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                },
              ),
            ),
          ],
        );

        final dartCode = Dpug.toDartString(listViewClass);

        expect(dartCode, contains('class ItemList'));
        expect(dartCode, contains('ListView'));
        expect(dartCode, contains('items.map'));
        expect(dartCode, contains('ListTile'));
        expect(dartCode, contains('(item)'));
      });
    });
  });
}

// Helper function for creating large nested widgets
DpugSpec createLargeNestedWidget(final int depth) {
  if (depth <= 0) {
    return DpugWidgetSpec(
      name: 'Text',
      properties: {'text': const DpugStringLiteralSpec('Deep Leaf')},
    );
  }

  return DpugWidgetSpec(
    name: 'Container',
    properties: {'child': createLargeNestedWidget(depth - 1)},
  );
}
