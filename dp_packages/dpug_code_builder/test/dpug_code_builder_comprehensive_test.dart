import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Code Builder Comprehensive Tests', () {
    group('Dpug Main API', () {
      test('classBuilder creates new instance', () {
        final builder = Dpug.classBuilder();
        expect(builder, isA<DpugClassBuilder>());
      });

      test('widgetBuilder creates new instance', () {
        final builder = Dpug.widgetBuilder();
        expect(builder, isA<DpugWidgetBuilder>());
      });

      test('round-trip conversion with simple class', () {
        const dpugCode = r'''
class Person
  String name
  int age

  Person(this.name, this.age)

  void greet() => print 'Hello, $name!'
''';

        final dartSpec = DpugSpec.fromDpug(dpugCode);
        expect(dartSpec, isNotNull);

        final emittedDpug = Dpug.emitDpug(dartSpec!);
        expect(emittedDpug, contains('class Person'));
        expect(emittedDpug, contains('String name;'));
        expect(emittedDpug, contains('int age;'));
        expect(emittedDpug, contains('Person(this.name, this.age);'));
        expect(
          emittedDpug,
          contains(r"void greet() => print('Hello, $name!');"),
        );

        final backToDart = Dpug.toDart(dartSpec);
        final dartString = Dpug.toDartString(dartSpec);
        expect(dartString, contains('class Person'));
        expect(dartString, contains('String name;'));
        expect(dartString, contains('int age;'));
      });
    });

    group('Class Specifications', () {
      test('DpugClassSpec basic functionality', () {
        final classSpec = DpugClassSpec(
          name: 'TestClass',
          fields: [
            DpugFieldSpec(name: 'id', type: 'int'),
            DpugFieldSpec(name: 'name', type: 'String'),
          ],
          methods: [
            DpugMethodSpec(
              name: 'test',
              body: "print('test');",
              returnType: 'void',
            ),
          ],
        );

        final emitted = Dpug.emitDpug(classSpec);
        expect(emitted, contains('class TestClass'));
        expect(emitted, contains('int id;'));
        expect(emitted, contains('String name;'));
        expect(emitted, contains("void test() => print('test');"));
      });

      test('DpugClassSpec with constructors', () {
        final classSpec = DpugClassSpec(
          name: 'User',
          fields: [
            DpugFieldSpec(name: 'id', type: 'String'),
            DpugFieldSpec(name: 'email', type: 'String'),
          ],
          constructors: [
            DpugConstructorSpec(
              parameters: [
                DpugParameterSpec(name: 'id', type: 'String'),
                DpugParameterSpec(name: 'email', type: 'String'),
              ],
              body: 'this.id = id;\nthis.email = email;',
            ),
          ],
        );

        final emitted = Dpug.emitDpug(classSpec);
        expect(emitted, contains('class User'));
        expect(emitted, contains('String id;'));
        expect(emitted, contains('String email;'));
        expect(emitted, contains('User(String id, String email)'));
      });

      test('DpugClassSpec with annotations', () {
        final classSpec = DpugClassSpec(
          name: 'Product',
          annotations: [
            const DpugAnnotationSpec(name: 'JsonSerializable'),
            const DpugAnnotationSpec(name: 'Entity'),
          ],
          fields: [
            DpugFieldSpec(
              name: 'id',
              type: 'int',
              annotations: [const DpugAnnotationSpec(name: 'Id')],
            ),
          ],
        );

        final emitted = Dpug.emitDpug(classSpec);
        expect(emitted, contains('@JsonSerializable()'));
        expect(emitted, contains('@Entity()'));
        expect(emitted, contains('class Product'));
        expect(emitted, contains('@Id()'));
        expect(emitted, contains('int id;'));
      });
    });

    group('Widget Specifications', () {
      test('DpugWidgetSpec with stateless widget', () {
        final widgetSpec = DpugWidgetSpec(
          name: 'GreetingWidget',
          type: WidgetType.stateless,
          fields: [
            DpugFieldSpec(name: 'name', type: 'String'),
            DpugFieldSpec(name: 'textColor', type: 'Color'),
          ],
          buildMethod: DpugMethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: r'''
return Container(
  padding: EdgeInsets.all(16.0),
  child: Text(
    'Hello, $name!',
    style: TextStyle(color: textColor)
  )
);
''',
          ),
        );

        final emitted = Dpug.emitDpug(widgetSpec);
        expect(emitted, contains('@stateless'));
        expect(emitted, contains('class GreetingWidget'));
        expect(emitted, contains('String name;'));
        expect(emitted, contains('Color textColor;'));
        expect(emitted, contains('Widget get build =>'));
        expect(emitted, contains('Container'));
        expect(emitted, contains('Text'));
      });

      test('DpugWidgetSpec with stateful widget and state fields', () {
        final widgetSpec = DpugWidgetSpec(
          name: 'CounterWidget',
          type: WidgetType.stateful,
          fields: [DpugFieldSpec(name: 'title', type: 'String')],
          stateFields: [
            DpugStateFieldSpec(
              name: 'count',
              type: 'int',
              annotation: StateFieldAnnotation.listen,
            ),
            DpugStateFieldSpec(
              name: 'isLoading',
              type: 'bool',
              annotation: StateFieldAnnotation.setState,
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'increment',
              body: 'count++;',
              returnType: 'void',
            ),
          ],
          buildMethod: DpugMethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: r'''
return Column(
  children: [
    Text('$count'),
    ElevatedButton(
      onPressed: increment,
      child: Text('Increment')
    )
  ]
);
''',
          ),
        );

        final emitted = Dpug.emitDpug(widgetSpec);
        expect(emitted, contains('@stateful'));
        expect(emitted, contains('class CounterWidget'));
        expect(emitted, contains('String title;'));
        expect(emitted, contains('@listen int count'));
        expect(emitted, contains('@setState bool isLoading'));
        expect(emitted, contains('void increment() => count++;'));
        expect(emitted, contains('Widget get build =>'));
        expect(emitted, contains('Column'));
        expect(emitted, contains('ElevatedButton'));
      });

      test('DpugWidgetSpec with changeNotifier fields', () {
        final widgetSpec = DpugWidgetSpec(
          name: 'UserWidget',
          type: WidgetType.stateful,
          stateFields: [
            DpugStateFieldSpec(
              name: 'userModel',
              type: 'UserModel',
              annotation: StateFieldAnnotation.changeNotifier,
            ),
          ],
          buildMethod: DpugMethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: '''
return ChangeNotifierProvider.value(
  value: userModel,
  child: UserProfile()
);
''',
          ),
        );

        final emitted = Dpug.emitDpug(widgetSpec);
        expect(emitted, contains('@stateful'));
        expect(emitted, contains('class UserWidget'));
        expect(emitted, contains('@changeNotifier UserModel userModel'));
        expect(emitted, contains('Widget get build =>'));
        expect(emitted, contains('ChangeNotifierProvider.value'));
      });
    });

    group('Expression Specifications', () {
      test('DpugLiteralSpec for different types', () {
        const stringLiteral = DpugStringLiteralSpec('Hello World');
        const intLiteral = DpugNumLiteralSpec(42);
        const boolLiteral = DpugBoolLiteralSpec(true);
        const listLiteral = DpugListLiteralSpec([
          DpugStringLiteralSpec('a'),
          DpugStringLiteralSpec('b'),
        ]);

        expect(Dpug.emitDpug(stringLiteral), equals("'Hello World'"));
        expect(Dpug.emitDpug(intLiteral), equals('42'));
        expect(Dpug.emitDpug(boolLiteral), equals('true'));
        expect(Dpug.emitDpug(listLiteral), equals("['a', 'b']"));
      });

      test('DpugBinarySpec for operations', () {
        const binarySpec = DpugBinarySpec(
          left: DpugReferenceSpec('a'),
          operator: '+',
          right: DpugReferenceSpec('b'),
        );

        expect(Dpug.emitDpug(binarySpec), equals('a + b'));
      });

      test('DpugAssignmentSpec', () {
        const assignment = DpugAssignmentSpec(
          target: DpugReferenceSpec('count'),
          value: DpugBinarySpec(
            left: DpugReferenceSpec('count'),
            operator: '+',
            right: DpugNumLiteralSpec(1),
          ),
        );

        expect(Dpug.emitDpug(assignment), equals('count = count + 1'));
      });
    });

    group('Method and Parameter Specifications', () {
      test('DpugMethodSpec with parameters', () {
        final method = DpugMethodSpec(
          name: 'calculate',
          returnType: 'int',
          parameters: [
            DpugParameterSpec(name: 'a', type: 'int'),
            DpugParameterSpec(name: 'b', type: 'int'),
          ],
          body: 'return a + b;',
        );

        final emitted = Dpug.emitDpug(method);
        expect(emitted, contains('int calculate(int a, int b)'));
        expect(emitted, contains('return a + b;'));
      });

      test('DpugMethodSpec with async/await', () {
        final method = DpugMethodSpec(
          name: 'fetchData',
          returnType: 'Future<String>',
          isAsync: true,
          body: '''
final response = await http.get(url);
return response.body;
''',
        );

        final emitted = Dpug.emitDpug(method);
        expect(emitted, contains('Future<String> fetchData() async'));
        expect(emitted, contains('await http.get(url);'));
        expect(emitted, contains('return response.body;'));
      });
    });

    group('Visitor Pattern Tests', () {
      test('DartToDpugSpecVisitor converts basic class', () {
        final dartClass = cb.Class(
          (final b) => b
            ..name = 'Person'
            ..fields.add(
              cb.Field(
                (final b) => b
                  ..name = 'name'
                  ..type = cb.refer('String'),
              ),
            )
            ..constructors.add(
              cb.Constructor(
                (final b) => b
                  ..requiredParameters.add(
                    cb.Parameter(
                      (final b) => b
                        ..name = 'name'
                        ..toThis = true,
                    ),
                  ),
              ),
            ),
        );

        final dpugSpec = Dpug.fromDart(dartClass);
        expect(dpugSpec, isA<DpugClassSpec>());

        final classSpec = dpugSpec! as DpugClassSpec;
        expect(classSpec.name, equals('Person'));
        expect(classSpec.fields.length, equals(1));
        expect(classSpec.fields[0].name, equals('name'));
        expect(classSpec.fields[0].type, equals('String'));
      });

      test('DpugToDartSpecVisitor converts widget spec', () {
        final widgetSpec = DpugWidgetSpec(
          name: 'TestWidget',
          type: WidgetType.stateless,
          buildMethod: DpugMethodSpec(
            name: 'build',
            returnType: 'Widget',
            body: 'return Container();',
          ),
        );

        final dartSpec = Dpug.toDart(widgetSpec);
        expect(dartSpec, isA<cb.Class>());

        final dartClass = dartSpec as cb.Class;
        expect(dartClass.name, equals('TestWidget'));
        expect(dartClass.annotations.length, equals(1));
        expect(dartClass.annotations[0].name.name, equals('stateless'));
      });
    });

    group('Builder Pattern Tests', () {
      test('DpugClassBuilder builds class with fields and methods', () {
        final classSpec = Dpug.classBuilder()
            .name('Calculator')
            .field('value', 'double', isPrivate: true)
            .field('precision', 'int')
            .method('add', 'void', [
              DpugParameterSpec(name: 'n', type: 'double'),
            ], 'value += n;')
            .method('getValue', 'double', [], 'return value;')
            .build();

        final emitted = Dpug.emitDpug(classSpec);
        expect(emitted, contains('class Calculator'));
        expect(emitted, contains('double _value;'));
        expect(emitted, contains('int precision;'));
        expect(emitted, contains('void add(double n) => value += n;'));
        expect(emitted, contains('double getValue() => return value;'));
      });

      test('DpugWidgetBuilder builds widget with state fields', () {
        final widgetSpec = Dpug.widgetBuilder()
            .name('CounterWidget')
            .type(WidgetType.stateful)
            .field('initialValue', 'int')
            .stateField('count', 'int', StateFieldAnnotation.listen)
            .method('increment', 'void', [], 'count++;')
            .buildMethod(r'''
return Scaffold(
  body: Center(
    child: Text('$count')
  )
);
''')
            .build();

        final emitted = Dpug.emitDpug(widgetSpec);
        expect(emitted, contains('@stateful'));
        expect(emitted, contains('class CounterWidget'));
        expect(emitted, contains('int initialValue;'));
        expect(emitted, contains('@listen int count'));
        expect(emitted, contains('void increment() => count++;'));
        expect(emitted, contains('Widget get build =>'));
        expect(emitted, contains('Scaffold'));
        expect(emitted, contains('Center'));
        expect(emitted, contains(r"Text('$count')"));
      });
    });

    group('Integration Tests', () {
      test('complete round-trip with complex widget', () {
        const originalDpug = '''
@stateful
class ComplexWidget
  @listen String title = 'App'
  @changeNotifier UserModel userModel = UserModel()
  @setState bool isLoading = false

  void toggleLoading() => isLoading = !isLoading

  Widget get build =>
    Scaffold
      appBar: AppBar title: Text title
      body:
        if isLoading
          CircularProgressIndicator()
        else
          ChangeNotifierProvider.value(
            value: userModel,
            child: UserProfile()
          )
''';

        final spec = DpugSpec.fromDpug(originalDpug);
        expect(spec, isNotNull);

        final emitted = Dpug.emitDpug(spec!);
        expect(emitted, contains('@stateful'));
        expect(emitted, contains('class ComplexWidget'));
        expect(emitted, contains('@listen String title'));
        expect(emitted, contains('@changeNotifier UserModel userModel'));
        expect(emitted, contains('@setState bool isLoading'));
        expect(emitted, contains('void toggleLoading()'));
        expect(emitted, contains('Widget get build =>'));
        expect(emitted, contains('Scaffold'));
        expect(emitted, contains('if isLoading'));
        expect(emitted, contains('ChangeNotifierProvider.value'));
      });

      test('multiple specs conversion', () {
        final specs = [
          DpugClassSpec(
            name: 'User',
            fields: [DpugFieldSpec(name: 'name', type: 'String')],
          ),
          DpugWidgetSpec(
            name: 'UserWidget',
            type: WidgetType.stateless,
            buildMethod: DpugMethodSpec(
              name: 'build',
              returnType: 'Widget',
              body: "return Text('Hello');",
            ),
          ),
        ];

        final result = Dpug.toIterableDartString(specs);
        expect(result, contains('class User'));
        expect(result, contains('String name;'));
        expect(result, contains('class UserWidget'));
        expect(result, contains('@stateless'));
        expect(result, contains('Widget get build =>'));
      });
    });

    group('Error Handling', () {
      test('handles invalid DPug syntax gracefully', () {
        const invalidDpug = '''
class Invalid
  // Missing semicolon
  int field
  // Invalid syntax
  method() => invalid syntax here
''';

        expect(() => DpugSpec.fromDpug(invalidDpug), throwsException);
      });

      test('handles null values in conversion', () {
        final nullSpec = DpugSpec.fromDpug('');
        expect(nullSpec, isNull);

        final emptyString = Dpug.dartToDpugString(
          cb.Class((final b) => b..name = ''),
        );
        expect(emptyString, isEmpty);
      });

      test('handles malformed builder patterns', () {
        expect(() => Dpug.classBuilder().name(''), throwsException);
        expect(
          () => Dpug.classBuilder().field('', 'InvalidType'),
          throwsException,
        );
        expect(
          () => Dpug.widgetBuilder().buildMethod('invalid body'),
          throwsException,
        );
      });

      test('handles circular dependencies in specs', () {
        final spec1 = DpugClassSpec(name: 'Class1');
        final spec2 = DpugClassSpec(
          name: 'Class2',
          fields: [DpugFieldSpec(name: 'ref', type: 'Class1')],
        );

        // Should handle circular references gracefully
        expect(() => Dpug.emitDpug(spec1), returnsNormally);
        expect(() => Dpug.emitDpug(spec2), returnsNormally);
      });

      test('handles invalid type parameters', () {
        expect(
          () => Dpug.classBuilder().name('Test<T extends Unknown>'),
          throwsException,
        );
        expect(
          () => Dpug.classBuilder().name('Test<T, U, V extends List<Unknown>>'),
          throwsException,
        );
      });

      test('handles memory exhaustion with large specs', () {
        final largeSpec = DpugClassSpec(
          name: 'LargeClass',
          fields: List.generate(
            1000,
            (final i) => DpugFieldSpec(name: 'field$i', type: 'String'),
          ),
          methods: List.generate(
            500,
            (final i) => DpugMethodSpec(
              name: 'method$i',
              returnType: 'void',
              body: "print('method$i');",
            ),
          ),
        );

        // Should handle large specs without memory issues
        expect(() => Dpug.emitDpug(largeSpec), returnsNormally);
      });

      test('handles concurrent builder usage', () {
        // Test that builders can be used concurrently
        final builder1 = Dpug.classBuilder().name('Class1');
        final builder2 = Dpug.classBuilder().name('Class2');
        final builder3 = Dpug.widgetBuilder()
            .name('Widget1')
            .type(WidgetType.stateless);

        expect(builder1, isNotNull);
        expect(builder2, isNotNull);
        expect(builder3, isNotNull);
      });

      test('handles invalid widget configurations', () {
        expect(
          () => Dpug.widgetBuilder().name('').type(WidgetType.stateless),
          throwsException,
        );
        expect(
          () => Dpug.widgetBuilder()
              .name('Test')
              .type(WidgetType.stateful)
              .stateField('', 'String', StateFieldAnnotation.listen),
          throwsException,
        );
        expect(
          () => Dpug.widgetBuilder().name('Test').buildMethod(''),
          throwsException,
        );
      });

      test('handles malformed expressions in specs', () {
        final malformedSpec = DpugClassSpec(
          name: 'Malformed',
          methods: [
            DpugMethodSpec(
              name: 'test',
              returnType: 'void',
              body: 'invalid syntax here +++ === &&&',
            ),
          ],
        );

        // Should handle gracefully or throw appropriate error
        expect(() => Dpug.emitDpug(malformedSpec), returnsNormally);
      });

      test('handles edge cases in type inference', () {
        final dynamicSpec = DpugClassSpec(
          name: 'DynamicClass',
          fields: [
            DpugFieldSpec(name: 'dynamicField', type: 'dynamic'),
            DpugFieldSpec(name: 'varField', type: 'var'),
            DpugFieldSpec(name: 'objectField', type: 'Object'),
            DpugFieldSpec(name: 'nullField', type: 'Null'),
          ],
        );

        expect(() => Dpug.emitDpug(dynamicSpec), returnsNormally);
      });

      test('handles deeply nested method calls', () {
        final nestedSpec = DpugClassSpec(
          name: 'NestedMethods',
          methods: [
            DpugMethodSpec(
              name: 'deepMethod',
              returnType: 'String',
              body: '''
final result = obj.method1()
  .method2()
  .method3()
  .method4()
  .method5();
return result.toString();
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(nestedSpec), returnsNormally);
      });

      test('handles complex cascade operations', () {
        final cascadeSpec = DpugClassSpec(
          name: 'CascadeClass',
          methods: [
            DpugMethodSpec(
              name: 'cascadeMethod',
              returnType: 'void',
              body: '''
StringBuffer buffer = StringBuffer()
  ..write('Hello')
  ..write(' ')
  ..write('World')
  ..write('!')
  ..clear()
  ..write('Done');

List<int> numbers = [1, 2, 3, 4, 5]
  ..add(6)
  ..add(7)
  ..sort()
  ..clear()
  ..addAll([10, 20, 30]);

Map<String, int> map = {'a': 1}
  ..['b'] = 2
  ..['c'] = 3
  ..remove('a')
  ..clear()
  ..addAll({'x': 10, 'y': 20});
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(cascadeSpec), returnsNormally);
      });

      test('handles async/await patterns in methods', () {
        final asyncSpec = DpugClassSpec(
          name: 'AsyncClass',
          methods: [
            DpugMethodSpec(
              name: 'asyncMethod',
              returnType: 'Future<void>',
              isAsync: true,
              body: '''
await Future.delayed(Duration(seconds: 1));
final data = await fetchData();
await processData(data);
print('Async method completed');
''',
            ),
            DpugMethodSpec(
              name: 'generatorMethod',
              returnType: 'Stream<int>',
              isGenerator: true,
              body: '''
for (int i = 0; i < 10; i++) {
  yield i;
  await Future.delayed(Duration(milliseconds: 100));
}
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(asyncSpec), returnsNormally);
      });

      test('handles complex conditional expressions', () {
        final conditionalSpec = DpugClassSpec(
          name: 'ConditionalClass',
          methods: [
            DpugMethodSpec(
              name: 'complexCondition',
              returnType: 'String',
              body: '''
bool condition1 = true;
bool condition2 = false;
int value = 42;

String result = condition1 && !condition2 && value > 40
  ? 'Complex condition met'
  : condition1 || condition2
    ? 'Partial condition met'
    : 'No condition met';

return result + (value >= 0 ? ' (positive)' : ' (negative)');
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(conditionalSpec), returnsNormally);
      });

      test('handles operator overloading in classes', () {
        final operatorSpec = DpugClassSpec(
          name: 'Vector',
          fields: [
            DpugFieldSpec(name: 'x', type: 'double'),
            DpugFieldSpec(name: 'y', type: 'double'),
          ],
          constructors: [
            DpugConstructorSpec(
              parameters: [
                DpugParameterSpec(name: 'x', type: 'double'),
                DpugParameterSpec(name: 'y', type: 'double'),
              ],
              body: 'this.x = x;\nthis.y = y;',
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'operator +',
              returnType: 'Vector',
              parameters: [DpugParameterSpec(name: 'other', type: 'Vector')],
              body: 'return Vector(x + other.x, y + other.y);',
            ),
            DpugMethodSpec(
              name: 'operator -',
              returnType: 'Vector',
              parameters: [DpugParameterSpec(name: 'other', type: 'Vector')],
              body: 'return Vector(x - other.x, y - other.y);',
            ),
            DpugMethodSpec(
              name: 'operator *',
              returnType: 'Vector',
              parameters: [DpugParameterSpec(name: 'scalar', type: 'double')],
              body: 'return Vector(x * scalar, y * scalar);',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(operatorSpec), returnsNormally);
      });

      test('handles complex generic constraints', () {
        final genericSpec = DpugClassSpec(
          name: 'ComplexGeneric<T extends num, U, V extends List<U>>',
          typeParameters: ['T extends num', 'U', 'V extends List<U>'],
          methods: [
            DpugMethodSpec(
              name: 'process',
              returnType: 'List<T>',
              parameters: [
                DpugParameterSpec(name: 'items', type: 'V'),
                DpugParameterSpec(name: 'transformer', type: 'T Function(U)'),
              ],
              body: '''
return items.map((item) => transformer(item)).toList();
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(genericSpec), returnsNormally);
      });

      test('handles builder pattern edge cases', () {
        // Test builder with empty configurations
        final emptyBuilder = Dpug.classBuilder().name('EmptyClass').build();

        expect(emptyBuilder, isNotNull);

        // Test builder with only fields
        final fieldOnlyBuilder = Dpug.classBuilder()
            .name('FieldOnly')
            .field('test', 'String')
            .build();

        expect(fieldOnlyBuilder, isNotNull);

        // Test builder with only methods
        final methodOnlyBuilder = Dpug.classBuilder()
            .name('MethodOnly')
            .method('test', 'void', [], "print('test');")
            .build();

        expect(methodOnlyBuilder, isNotNull);

        // Test widget builder with minimal configuration
        final minimalWidget = Dpug.widgetBuilder()
            .name('MinimalWidget')
            .type(WidgetType.stateless)
            .buildMethod('return Container();')
            .build();

        expect(minimalWidget, isNotNull);
      });

      test('handles complex widget builder scenarios', () {
        final complexWidget = Dpug.widgetBuilder()
            .name('ComplexWidget')
            .type(WidgetType.stateful)
            .field('title', 'String')
            .field('initialCount', 'int')
            .stateField('count', 'int', StateFieldAnnotation.listen)
            .stateField('isLoading', 'bool', StateFieldAnnotation.setState)
            .stateField(
              'data',
              'List<String>',
              StateFieldAnnotation.changeNotifier,
            )
            .method('increment', 'void', [], 'count++;')
            .method(
              'loadData',
              'Future<void>',
              [],
              'async { /* implementation */ }',
              isAsync: true,
            )
            .buildMethod(r'''
return Scaffold(
  appBar: AppBar(title: Text(title)),
  body: isLoading
    ? CircularProgressIndicator()
    : Column(
        children: [
          Text('Count: $count'),
          for (String item in data)
            ListTile(title: Text(item)),
        ],
      ),
  floatingActionButton: FloatingActionButton(
    onPressed: increment,
    child: Icon(Icons.add),
  ),
);
''')
            .build();

        expect(complexWidget, isNotNull);
        expect(Dpug.emitDpug(complexWidget), contains('class ComplexWidget'));
        expect(Dpug.emitDpug(complexWidget), contains('@stateful'));
        expect(Dpug.emitDpug(complexWidget), contains('@listen int count'));
        expect(
          Dpug.emitDpug(complexWidget),
          contains('@setState bool isLoading'),
        );
        expect(
          Dpug.emitDpug(complexWidget),
          contains('@changeNotifier List<String> data'),
        );
      });

      test('handles error conditions in visitor patterns', () {
        final malformedDartClass = cb.Class(
          (final b) => b
            ..name = ''
            ..fields.add(
              cb.Field(
                (final b) => b
                  ..name = ''
                  ..type = cb.refer(''),
              ),
            ),
        );

        // Should handle gracefully
        expect(() => Dpug.fromDart(malformedDartClass), returnsNormally);
      });

      test('handles large-scale code generation', () {
        // Generate a large number of classes to test scalability
        final largeScaleSpecs = List.generate(
          100,
          (final i) => DpugClassSpec(
            name: 'GeneratedClass$i',
            fields: List.generate(
              10,
              (final j) => DpugFieldSpec(name: 'field$j', type: 'String'),
            ),
            methods: List.generate(
              5,
              (final j) => DpugMethodSpec(
                name: 'method$j',
                returnType: 'void',
                body: "print('method$j');",
              ),
            ),
          ),
        );

        // Should handle large-scale generation without issues
        for (final spec in largeScaleSpecs) {
          expect(() => Dpug.emitDpug(spec), returnsNormally);
        }
      });

      test('handles mixed content types in specs', () {
        final mixedSpec = DpugClassSpec(
          name: 'MixedContent',
          annotations: [
            const DpugAnnotationSpec(name: 'JsonSerializable'),
            const DpugAnnotationSpec(name: 'Entity'),
          ],
          fields: [
            DpugFieldSpec(name: 'stringField', type: 'String'),
            DpugFieldSpec(name: 'intField', type: 'int'),
            DpugFieldSpec(name: 'boolField', type: 'bool'),
            DpugFieldSpec(name: 'listField', type: 'List<String>'),
            DpugFieldSpec(name: 'mapField', type: 'Map<String, dynamic>'),
          ],
          methods: [
            DpugMethodSpec(
              name: 'syncMethod',
              returnType: 'void',
              body: "print('sync');",
            ),
            DpugMethodSpec(
              name: 'asyncMethod',
              returnType: 'Future<void>',
              body: 'await Future.delayed(Duration(seconds: 1));',
              isAsync: true,
            ),
            DpugMethodSpec(
              name: 'generatorMethod',
              returnType: 'Stream<int>',
              body: 'for (int i = 0; i < 5; i++) yield i;',
              isGenerator: true,
            ),
          ],
        );

        expect(() => Dpug.emitDpug(mixedSpec), returnsNormally);
      });

      test('handles recursive data structures', () {
        final recursiveSpec = DpugClassSpec(
          name: 'TreeNode',
          fields: [
            DpugFieldSpec(name: 'value', type: 'String'),
            DpugFieldSpec(name: 'children', type: 'List<TreeNode>'),
            DpugFieldSpec(name: 'parent', type: 'TreeNode?'),
          ],
          constructors: [
            DpugConstructorSpec(
              parameters: [DpugParameterSpec(name: 'value', type: 'String')],
              body: '''
this.value = value;
this.children = [];
this.parent = null;
''',
            ),
          ],
          methods: [
            DpugMethodSpec(
              name: 'addChild',
              returnType: 'void',
              parameters: [DpugParameterSpec(name: 'child', type: 'TreeNode')],
              body: '''
children.add(child);
child.parent = this;
''',
            ),
          ],
        );

        // Should handle self-referential types
        expect(() => Dpug.emitDpug(recursiveSpec), returnsNormally);
      });

      test('handles complex import and export scenarios', () {
        final importSpec = DpugClassSpec(
          name: 'ImportedClass',
          imports: [
            'package:flutter/material.dart',
            'package:provider/provider.dart',
            'dart:async',
            'dart:io',
          ],
          methods: [
            DpugMethodSpec(
              name: 'useImports',
              returnType: 'Widget',
              body: '''
return StreamBuilder<FileSystemEntity>(
  stream: Directory('.').list(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(
        children: snapshot.data!.map((entity) => ListTile(
          title: Text(entity.path),
        )).toList(),
      );
    }
    return CircularProgressIndicator();
  },
);
''',
            ),
          ],
        );

        expect(() => Dpug.emitDpug(importSpec), returnsNormally);
      });

      test('handles performance-critical operations', () {
        final performanceSpec = DpugClassSpec(
          name: 'PerformanceTest',
          methods: [
            DpugMethodSpec(
              name: 'heavyComputation',
              returnType: 'List<int>',
              body: '''
List<int> result = [];
for (int i = 0; i < 1000000; i++) {
  result.add(i * i);
}
return result;
''',
            ),
            DpugMethodSpec(
              name: 'memoryIntensive',
              returnType: 'Map<String, List<int>>',
              body: r'''
Map<String, List<int>> result = {};
for (int i = 0; i < 1000; i++) {
  result['key$i'] = List.generate(1000, (j) => i * j);
}
return result;
''',
            ),
          ],
        );

        // Should handle performance-critical code generation
        expect(() => Dpug.emitDpug(performanceSpec), returnsNormally);
      });
    });
  });
}
