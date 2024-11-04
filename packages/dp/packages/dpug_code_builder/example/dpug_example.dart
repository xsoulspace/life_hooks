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
        ..buildMethod(
          body: WidgetHelpers.column(
            properties: {
              'mainAxisAlignment':
                  DpugExpressionSpec.reference('MainAxisAlignment.center'),
            },
            children: [
              DpugWidgetBuilder()
                ..name('TextFormField')
                ..property(
                    'initialValue', DpugExpressionSpec.reference('newTodo'))
                ..property(
                  'onChanged',
                  DpugExpressionSpec.lambda(
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

  print(todoList.accept(DartGeneratingVisitor()));
  print('\n---\n');
  print(todoList.accept(DpugGeneratingVisitor()));
}
