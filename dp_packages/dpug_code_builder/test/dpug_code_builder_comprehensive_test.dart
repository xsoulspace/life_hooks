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
    });
  });
}
