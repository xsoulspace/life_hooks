import '../lib/dpug.dart';

void main() {
  final todoList = (
    Dpug.classBuilder()
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
                        DpugExpressionSpec.string('Todo List'),
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
              ),
            ),
          ),
      ),
  ).$1.build();

  print('// Dart output:');
  print(Dpug.toDartString(todoList));
  print('\n// Dpug output:');
  print(Dpug.emitDpug(todoList));
}
