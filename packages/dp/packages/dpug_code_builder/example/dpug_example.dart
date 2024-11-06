import '../lib/dpug.dart';

void main() {
  final todoList = (
    Dpug.classBuilder()
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
        body: Dpug.widgetBuilder()
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
                        DpugExpressionSpec.stringLiteral('Todo List'),
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
                  'padding': DpugExpressionSpec.reference('EdgeInsets.all(16)'),
                },
                child: WidgetHelpers.column(
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
              ),
            ),
          ),
      ),
  ).$1.build();

  print('// Dart output:');
  print(todoList.accept(DpugToDartVisitor()));
  print('\n// Dpug output:');
  print(todoList.accept(DpugGeneratingVisitor()));
}
