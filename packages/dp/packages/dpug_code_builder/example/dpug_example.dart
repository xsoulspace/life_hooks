import '../lib/dpug.dart';

void main() {
  final todoList = Dpug.classBuilder()
    ..name('TodoList')
    ..annotation(DpugAnnotationSpec.stateful())
    ..stateField(DpugStateFieldSpec(
      name: 'todos',
      type: 'List<Todo>',
      annotation: DpugAnnotationSpec.listen(),
      initializer: DpugExpressionSpec.listLiteral([]),
    ))
    ..stateField(DpugStateFieldSpec(
      name: 'newTodo',
      type: 'String',
      annotation: DpugAnnotationSpec.listen(),
      initializer: DpugExpressionSpec.stringLiteral(''),
    ))
    ..buildGetter(
      name: 'build',
      returnType: 'Widget',
      body: DpugWidgetSpec(
        name: 'Column',
        properties: {},
        children: [
          DpugWidgetSpec(
            name: 'TextField',
            properties: {
              'value': DpugReferenceSpec('newTodo'),
              'onChanged': DpugReferenceSpec('(value) => newTodo = value'),
            },
            children: [],
          ),
        ],
      ),
    );

  print(todoList.accept(DartGeneratingVisitor()));
  print('\n---\n');
  print(todoList.accept(DpugGeneratingVisitor()));
}
