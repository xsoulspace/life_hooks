import '../lib/dpug.dart';

void main() {
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
              ..name('TextField')
              ..property('value', DpugExpressionSpec.reference('newTodo'))
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

  print(todoList.accept(DartGeneratingVisitor()));
  print('\n---\n');
  print(todoList.accept(DpugGeneratingVisitor()));
}
