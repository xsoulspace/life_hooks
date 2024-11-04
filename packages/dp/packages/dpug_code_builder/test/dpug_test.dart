import 'package:dpug/dpug.dart';
import 'package:test/test.dart';

final _dartCode = '''
class TodoList extends StatefulWidget {
  TodoList({
    super.key,
    required this.todos,
    required this.newTodo,
  });
  final List<Todo> todos;
  final String newTodo;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<Todo> _todos = widget.todos;
  List<Todo> get todos => _todos;
  set todos(List<Todo> value) => setState(() => _todos = value);
  late String _newTodo = widget.newTodo;
  String get newTodo => _newTodo;
  set newTodo(String value) => setState(() => _newTodo = value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          initialValue: newTodo,
          onChanged: (value) => newTodo = value,
        ),
      ],
    );
  }
}
''';

final _dpugCode = '''
@stateful
class TodoList
  @listen List<Todo> todos = []
  @listen String newTodo = ''

  Widget get build =>
    Column
      ..mainAxisAlignment: MainAxisAlignment.center
      TextFormField
        ..initialValue: newTodo
        ..onChanged: (value) => newTodo = value
''';

void main() {
  group('Dpug Syntax Tests', () {
    test('Basic stateful widget', () {
      final todoList = (Dpug.classBuilder()
            ..name('TodoList')
            ..annotation(DpugAnnotationSpec.stateful())
            ..listenField(
              name: 'todos',
              type: 'List<Todo>',
              initializer: DpugExpressionSpec.listLiteral([]),
            )
            ..listenField(
              name: 'newTodo',
              type: 'String',
              initializer: DpugExpressionSpec.stringLiteral(''),
            )
            ..buildGetter(
              name: 'build',
              returnType: 'Widget',
              body: Dpug.widgetBuilder()
                ..name('Column')
                ..property(
                  'mainAxisAlignment',
                  DpugExpressionSpec.reference('MainAxisAlignment.center'),
                )
                ..child(Dpug.widgetBuilder()
                  ..name('TextFormField')
                  ..property(
                    'initialValue',
                    DpugExpressionSpec.reference('newTodo'),
                  )
                  ..property(
                    'onChanged',
                    DpugExpressionSpec.lambda(
                      ['value'],
                      DpugExpressionSpec.assignment(
                        'newTodo',
                        DpugExpressionSpec.reference('value'),
                      ),
                    ),
                  )),
            ))
          .build();

      final dartCode = todoList.accept(DartGeneratingVisitor()).toString();
      final dpugCode = todoList.accept(DpugGeneratingVisitor());

      expect(_normalizeWhitespace(dartCode),
          equals(_normalizeWhitespace(_dartCode)));
      expect(_normalizeWhitespace(dpugCode),
          equals(_normalizeWhitespace(_dpugCode)));
    });

    test('Widget with multiple children', () {
      final widget = (Dpug.widgetBuilder()
            ..name('Column')
            ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..positionalCascadeArgument(
                  DpugExpressionSpec.stringLiteral('Hello')))
            ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..positionalArgument(DpugExpressionSpec.stringLiteral('World'))))
          .build();

      final dartCode = widget.accept(DartGeneratingVisitor()).toString();
      final dpugCode = widget.accept(DpugGeneratingVisitor());

      final expectedDartCode = '''
Column(
  children: [
    Text('Hello'),
    Text('World'),
  ]
)''';

      final expectedDpugCode = '''
Column
  Text
    ..'Hello'
  Text('World')
''';

      expect(_normalizeWhitespace(dartCode),
          equals(_normalizeWhitespace(expectedDartCode)));
      expect(_normalizeWhitespace(dpugCode),
          equals(_normalizeWhitespace(expectedDpugCode)));
    });

    test('Widget with multiple children and different argument styles', () {
      final widget = (Dpug.widgetBuilder()
            ..name('Column')
            ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..positionalCascadeArgument(
                  DpugExpressionSpec.stringLiteral('Hello')))
            ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..positionalArgument(DpugExpressionSpec.stringLiteral('World')))
            ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..positionalCascadeArgument(
                  DpugExpressionSpec.stringLiteral('!'))))
          .build();

      final dartCode = widget.accept(DartGeneratingVisitor()).toString();
      final dpugCode = widget.accept(DpugGeneratingVisitor());

      final expectedDartCode = '''
Column(
  children: [
    Text('Hello'),
    Text('World'),
    Text('!'),
  ]
)''';

      final expectedDpugCode = '''
Column
  Text
    ..'Hello'
  Text('World')
  Text
    ..'!'
''';

      expect(_normalizeWhitespace(dartCode),
          equals(_normalizeWhitespace(expectedDartCode)));
      expect(_normalizeWhitespace(dpugCode),
          equals(_normalizeWhitespace(expectedDpugCode)));
    });
  });
}

String _normalizeWhitespace(String code) {
  return code
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('{ ', '{')
      .replaceAll(' }', '}')
      .replaceAll('[ ', '[')
      .replaceAll(' ]', ']')
      .replaceAll('( ', '(')
      .replaceAll(' )', ')')
      .trim();
}
