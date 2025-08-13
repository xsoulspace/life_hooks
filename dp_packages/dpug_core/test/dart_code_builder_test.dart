import 'package:code_builder/code_builder.dart';
import 'package:dpug_code_builder/src/builders/dart_widget_code_generator.dart';
import 'package:dpug_code_builder/src/specs/annotation_spec.dart';
import 'package:dpug_code_builder/src/specs/class_spec.dart';
import 'package:dpug_code_builder/src/specs/code_spec.dart';
import 'package:dpug_code_builder/src/specs/expression_spec.dart';
import 'package:dpug_code_builder/src/specs/method_spec.dart';
import 'package:dpug_code_builder/src/specs/state_field_spec.dart';
import 'package:test/test.dart';

void main() {
  group('DartWidgetCodeGenerator', () {
    test('generates stateful widget with state management', () {
      final generator = DartWidgetCodeGenerator();

      final classSpec = DpugClassSpec(
        name: 'TodoList',
        stateFields: [
          DpugStateFieldSpec(
            name: 'todos',
            type: 'List<Todo>',
            annotation: DpugAnnotationSpec.listen(),
          ),
        ],
        methods: [
          DpugMethodSpec.getter(
            name: 'build',
            returnType: 'Widget',
            body: DpugCodeSpec('''
              return Column(
                children: [
                  TextField(
                    value: newTodo,
                    onChanged: (value) => newTodo = value,
                  ),
                ],
              );
            '''),
          ),
        ],
      );

      final code = generator.generateStatefulWidget(classSpec);

      expect(code, contains('class TodoList extends StatefulWidget'));
      expect(code, contains('class _TodoListState extends State<TodoList>'));
      expect(code, contains('List<Todo> get todos => _todos'));
      expect(code, contains('set todos(List<Todo> value)'));
    });
  });
}
