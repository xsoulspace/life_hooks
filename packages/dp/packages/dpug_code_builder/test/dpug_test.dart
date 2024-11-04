import 'package:dpug/dpug.dart';
import 'package:test/test.dart';

void main() {
  group('Dpug Syntax Tests', () {
    test('Basic stateful widget', () {
      final todoList = Dpug.classBuilder()
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
            ..child(Dpug.widgetBuilder()
                  ..name('TextField')
                  ..property('value', DpugExpressionSpec.reference('newTodo'))
                  ..property(
                    'onChanged',
                    DpugExpressionSpec.lambda(
                      ['value'],
                      DpugExpressionSpec.assignment(
                          'newTodo', DpugExpressionSpec.reference('value')),
                    ),
                  ))
                .build(),
        ).build();

      final dartCode = Dpug.generateDart(todoList);
      final dpugCode = Dpug.generateDpug(todoList);

      expect(dartCode, contains('class TodoList extends StatefulWidget'));
      expect(
          dartCode, contains('class _TodoListState extends State<TodoList>'));
      expect(dartCode, contains('late List<Todo> _todos = widget.todos'));
      expect(dartCode, contains('late String _newTodo = widget.newTodo'));
      expect(dartCode, contains('Widget build(BuildContext context)'));
      expect(dartCode, contains('TextField('));
      expect(dartCode, contains('value: newTodo'));
      expect(dartCode, contains('onChanged: (value) => newTodo = value'));

      expect(dpugCode, contains('@stateful'));
      expect(dpugCode, contains('class TodoList'));
      expect(dpugCode, contains('@listen List<Todo> todos = []'));
      expect(dpugCode, contains('@listen String newTodo = \'\''));
      expect(dpugCode, contains('Widget get build =>'));
      expect(dpugCode, contains('Column'));
      expect(dpugCode, contains('TextField'));
      expect(dpugCode, contains('value: newTodo'));
      expect(dpugCode, contains('onChanged: (value) => newTodo = value'));
    });

    test('Widget with multiple children', () {
      final widget = Dpug.widgetBuilder()
        ..name('Column')
        ..child(Dpug.widgetBuilder()
          ..name('Text')
          ..property('data', DpugExpressionSpec.stringLiteral('Hello')))
        ..child(Dpug.widgetBuilder()
              ..name('Text')
              ..property('data', DpugExpressionSpec.stringLiteral('World')))
            .build();

      final dartCode = widget.accept(DartGeneratingVisitor());
      final dpugCode = widget.accept(DpugGeneratingVisitor());

      expect(dartCode.toString(), contains('Column('));
      expect(dartCode.toString(), contains('children: ['));
      expect(dartCode.toString(), contains('Text(data: \'Hello\')'));
      expect(dartCode.toString(), contains('Text(data: \'World\')'));

      expect(dpugCode, contains('Column'));
      expect(dpugCode, contains('Text'));
      expect(dpugCode, contains('data: \'Hello\''));
      expect(dpugCode, contains('data: \'World\''));
    });
  });
}
