import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:test/test.dart';

const _dartCode = '''
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
  late String _newTodo = widget.newTodo;

  List<Todo> get todos => _todos;
  set todos(List<Todo> value) => setState(() => _todos = value);

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
          )
        ],
      );
    }
  }
''';

const _dpugCode = '''
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
      final todoList =
          (Dpug.classBuilder()
                ..name('TodoList')
                ..annotation(DpugAnnotationSpec.stateful())
                ..listenField(
                  name: 'todos',
                  type: 'List<Todo>',
                  initializer: DpugExpressionSpec.list([]),
                )
                ..listenField(
                  name: 'newTodo',
                  type: 'String',
                  initializer: DpugExpressionSpec.string(''),
                )
                ..buildMethod(
                  body: WidgetHelpers.column(
                    properties: {
                      'mainAxisAlignment': DpugExpressionSpec.reference(
                        'MainAxisAlignment.center',
                      ),
                    },
                    children: [
                      DpugWidgetBuilder()
                        ..name('TextFormField')
                        ..property(
                          'initialValue',
                          DpugExpressionSpec.reference('newTodo'),
                        )
                        ..property(
                          'onChanged',
                          DpugExpressionSpec.closure(
                            ['value'],
                            DpugExpressionSpec.assignment(
                              'newTodo',
                              DpugExpressionSpec.reference('value'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ))
              .build();

      final dartCode = todoList.accept(DpugToDartSpecVisitor()).toString();
      final dpugCode = todoList.accept(DpugEmitter());

      expect(dartCode, equals(_dartCode));
      expect(dpugCode, equals(_dpugCode));
    });

    test('Widget formatting rules', () {
      final widget =
          (Dpug.widgetBuilder()
                ..name('Scaffold')
                ..property(
                  'appBar',
                  DpugExpressionSpec.widget(
                    DpugWidgetBuilder()
                      ..name('AppBar')
                      ..property(
                        'title',
                        DpugExpressionSpec.widget(
                          DpugWidgetBuilder()
                            ..name('Text')
                            ..positionalCascadeArgument(
                              DpugExpressionSpec.string('Title'),
                            ),
                        ),
                      ),
                  ),
                )
                ..property(
                  'body',
                  DpugExpressionSpec.widget(
                    WidgetHelpers.container(
                      properties: {
                        'padding': DpugExpressionSpec.reference(
                          'EdgeInsets.all(16)',
                        ),
                      },
                      child: WidgetHelpers.column(
                        children: [
                          DpugWidgetBuilder()
                            ..name('Text')
                            ..positionalArgument(
                              DpugExpressionSpec.string('First'),
                            ),
                          DpugWidgetBuilder()
                            ..name('Text')
                            ..positionalCascadeArgument(
                              DpugExpressionSpec.string('Second'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ))
              .build();

      final dpugCode = widget.accept(DpugEmitter());

      const expectedDpugCode = '''
Scaffold
  ..appBar: AppBar
    ..title: Text
      ..'Title'
  ..body: Container
    ..padding: EdgeInsets.all(16)
    Column
      Text('First')
      Text
        ..'Second'
''';

      expect(dpugCode, equals(expectedDpugCode));
    });

    group('Critical Widget Cases', () {
      test('Single child widget with properties', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('Container')
                  ..property(
                    'color',
                    DpugExpressionSpec.reference('Colors.red'),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalCascadeArgument(
                        DpugExpressionSpec.string('Child'),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
Container
  ..color: Colors.red
  Text
    ..'Child\''''),
        );
      });

      test('Nested properties with cascade notation', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('Container')
                  ..property(
                    'decoration',
                    DpugExpressionSpec.widget(
                      DpugWidgetBuilder()
                        ..name('BoxDecoration')
                        ..property(
                          'color',
                          DpugExpressionSpec.reference('Colors.blue'),
                        )
                        ..property(
                          'borderRadius',
                          DpugExpressionSpec.reference(
                            'BorderRadius.circular(8)',
                          ),
                        ),
                    ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
Container
  ..decoration: BoxDecoration
    ..color: Colors.blue
    ..borderRadius: BorderRadius.circular(8)
'''),
        );
      });

      test('Complex callbacks with state management', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('ElevatedButton')
                  ..property(
                    'onPressed',
                    DpugExpressionSpec.closure(
                      [],
                      DpugExpressionSpec.reference(
                        'setState(() { count++; update(); })',
                      ),
                    ),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalCascadeArgument(
                        DpugExpressionSpec.string('Increment'),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
ElevatedButton
  ..onPressed: () => setState(() { count++; update(); })
  Text
    ..'Increment\''''),
        );
      });

      test('Mixed positional and named arguments', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('Padding')
                  ..property(
                    'padding',
                    DpugExpressionSpec.reference('EdgeInsets.all(16)'),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalArgument(DpugExpressionSpec.string('Hello'))
                      ..property(
                        'style',
                        DpugExpressionSpec.reference('boldStyle'),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
Padding
  ..padding: EdgeInsets.all(16)
  Text('Hello')
    ..style: boldStyle'''),
        );
      });
    });

    group('Critical State Management Cases', () {
      test('Complex state field with initializer', () {
        final widget =
            (Dpug.classBuilder()
                  ..name('ComplexWidget')
                  ..annotation(DpugAnnotationSpec.stateful())
                  ..listenField(
                    name: 'items',
                    type: 'List<CustomItem>',
                    initializer: DpugExpressionSpec.reference(
                      '[CustomItem(), CustomItem()]',
                    ),
                  ))
                .build();

        final dartCode = widget.accept(DpugToDartSpecVisitor()).toString();
        expect(dartCode, contains('late List<CustomItem> _items'));
        expect(dartCode, contains('List<CustomItem> get items => _items'));
        expect(
          dartCode,
          contains(
            'set items(List<CustomItem> value) => setState(() => _items = value)',
          ),
        );
      });

      test('Multiple interdependent state fields', () {
        final widget =
            (Dpug.classBuilder()
                  ..name('InterconnectedWidget')
                  ..annotation(DpugAnnotationSpec.stateful())
                  ..listenField(
                    name: 'isLoading',
                    type: 'bool',
                    initializer: DpugExpressionSpec.reference('false'),
                  )
                  ..listenField(
                    name: 'error',
                    type: 'String?',
                    initializer: DpugExpressionSpec.reference('null'),
                  )
                  ..listenField(
                    name: 'data',
                    type: 'List<dynamic>',
                    initializer: DpugExpressionSpec.list([]),
                  ))
                .build();

        final dartCode = widget.accept(DpugToDartSpecVisitor()).toString();
        expect(dartCode, contains('late bool _isLoading = false'));
        expect(dartCode, contains('late String? _error = null'));
        expect(dartCode, contains('late List<dynamic> _data = []'));
      });
    });

    group('Error Cases', () {
      test('Widget without name should throw', () {
        expect(() => DpugWidgetBuilder().build(), throwsStateError);
      });

      test('Class without name should throw', () {
        expect(() => Dpug.classBuilder().build(), throwsStateError);
      });
    });

    group('Complex Callback Cases', () {
      test('Multi-line callback with state', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('ElevatedButton')
                  ..property(
                    'onPressed',
                    DpugExpressionSpec.reference('''
() {
                  setState(() {
                    count++;
                    updateUI();
                  });
                }'''),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalCascadeArgument(
                        DpugExpressionSpec.string('Click me'),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
ElevatedButton
  ..onPressed: () {
    setState(() {
      count++;
      updateUI();
    });
  }
  Text
    ..'Click me\''''),
        );
      });

      test('Nested callbacks with multiple state updates', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('GestureDetector')
                  ..property(
                    'onTap',
                    DpugExpressionSpec.reference('''
() {
                  if (isEnabled) {
                    setState(() {
                      count++;
                    });
                    doSomething();
                  }
                }'''),
                  )
                  ..property(
                    'onLongPress',
                    DpugExpressionSpec.reference('''
() {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Reset?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              count = 0;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );
                }'''),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Container')
                      ..property(
                        'color',
                        DpugExpressionSpec.reference('Colors.blue'),
                      )
                      ..child(
                        DpugWidgetBuilder()
                          ..name('Text')
                          ..positionalCascadeArgument(
                            DpugExpressionSpec.string('Tap or Long Press'),
                          ),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
GestureDetector
  ..onTap: () {
    if (isEnabled) {
      setState(() {
        count++;
      });
      doSomething();
    }
  }
  ..onLongPress: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                count = 0;
              });
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
  Container
    ..color: Colors.blue
    Text
      ..'Tap or Long Press\''''),
        );
      });

      test('Async callbacks with error handling', () {
        final widget =
            (DpugWidgetBuilder()
                  ..name('FloatingActionButton')
                  ..property(
                    'onPressed',
                    DpugExpressionSpec.reference('''
() async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await fetchData();
                    setState(() {
                      isLoading = false;
                      hasData = true;
                    });
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                      error = e.toString();
                    });
                    showError(context);
                  }
                }'''),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Icon')
                      ..positionalArgument(
                        DpugExpressionSpec.reference('Icons.refresh'),
                      ),
                  ))
                .build();

        final dpugCode = widget.accept(DpugEmitter());
        expect(
          dpugCode,
          equals('''
FloatingActionButton
  ..onPressed: () async {
    try {
      setState(() {
        isLoading = true;
      });
      await fetchData();
      setState(() {
        isLoading = false;
        hasData = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      showError(context);
    }
  }
  Icon(Icons.refresh)'''),
        );
      });
    });

    group('Multiple Classes', () {
      test('Two stateful widgets in one file', () {
        final counterWidget =
            (Dpug.classBuilder()
                  ..name('Counter')
                  ..annotation(DpugAnnotationSpec.stateful())
                  ..listenField(
                    name: 'count',
                    type: 'int',
                    initializer: DpugExpressionSpec.reference('0'),
                  )
                  ..buildMethod(
                    body: WidgetHelpers.withChildren(
                      'Column',
                      children: [
                        DpugWidgetBuilder()
                          ..name('Text')
                          ..positionalCascadeArgument(
                            DpugExpressionSpec.reference('count.toString()'),
                          ),
                        DpugWidgetBuilder()
                          ..name('ElevatedButton')
                          ..property(
                            'onPressed',
                            DpugExpressionSpec.closure(
                              [],
                              DpugExpressionSpec.assignment(
                                'count',
                                DpugExpressionSpec.reference('count + 1'),
                              ),
                            ),
                          )
                          ..child(
                            DpugWidgetBuilder()
                              ..name('Text')
                              ..positionalCascadeArgument(
                                DpugExpressionSpec.string('Increment'),
                              ),
                          ),
                      ],
                    ),
                  ))
                .build();

        final displayWidget =
            (Dpug.classBuilder()
                  ..name('Display')
                  ..annotation(DpugAnnotationSpec.stateful())
                  ..listenField(
                    name: 'text',
                    type: 'String',
                    initializer: DpugExpressionSpec.string(''),
                  )
                  ..buildMethod(
                    body: WidgetHelpers.container(
                      properties: {
                        'padding': DpugExpressionSpec.reference(
                          'EdgeInsets.all(16)',
                        ),
                      },
                      child: DpugWidgetBuilder()
                        ..name('Text')
                        ..positionalCascadeArgument(
                          DpugExpressionSpec.reference('text'),
                        ),
                    ),
                  ))
                .build();

        const dpugCode = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..count.toString()
      ElevatedButton
        ..onPressed: () => count = count + 1
        Text
          ..'Increment'

@stateful
class Display
  @listen String text = ''

  Widget get build =>
    Container
      ..padding: EdgeInsets.all(16)
      Text
        ..text''';

        const dartCode = '''
class Counter extends StatefulWidget {
  Counter({
    required this.count,
    super.key,
  });

  final int count;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count = widget.count;

  int get count => _count;
  set count(int value) => setState(() => _count = value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString()),
        ElevatedButton(
          onPressed: () => count = count + 1,
          child: Text('Increment'),
        ),
      ],
    );
  }
}

class Display extends StatefulWidget {
  Display({
    required this.text,
    super.key,
  });

  final String text;

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late String _text = widget.text;

  String get text => _text;
  set text(String value) => setState(() => _text = value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(text),
    );
  }
}''';
        final emitter = DpugEmitter();
        final resultDpugCode = emitter.visitClasses([
          counterWidget,
          displayWidget,
        ]);
        final resultDartCode = Dpug.toIterableDartString([
          counterWidget,
          displayWidget,
        ]);

        expect(resultDpugCode, equals(dpugCode));
        expect(resultDartCode, equals(dartCode));
      });
    });
  });
}
