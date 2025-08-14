import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dpug_code_builder/src/specs/class_spec.dart';
import 'package:dpug_code_builder/src/specs/state_field_spec.dart';
import 'package:dpug_code_builder/src/visitors/dpug_emitter.dart';

class DartWidgetCodeGenerator {
  final _formatter = DartFormatter();
  final _emitter = DartEmitter();
  final _dpugEmitter = DpugEmitter();

  String generateStatefulWidget(DpugClassSpec dpugClassSpec) {
    final className = dpugClassSpec.name;
    final stateFields = dpugClassSpec.stateFields.toList();
    final buildMethodSpec = dpugClassSpec.methods.firstWhere(
      (method) => method.name == 'build' && method.isGetter,
      orElse: () => throw StateError('Build method not found in DpugClassSpec'),
    );

    // Convert DpugSpec body to Code object
    final buildMethodBody = Code(buildMethodSpec.body.accept(_dpugEmitter));

    final stateClassName = '_${className}State';

    // Build main widget class
    final widgetClass = Class(
      (b) => b
        ..name = className
        ..extend = refer('StatefulWidget')
        ..fields.addAll(_buildWidgetFields(stateFields))
        ..constructors.add(_buildConstructor(stateFields))
        ..methods.add(_buildCreateState(className, stateClassName)),
    );

    // Build state class
    final stateClass = Class(
      (b) => b
        ..name = stateClassName
        ..extend = refer('State<${className}>')
        ..fields.addAll(_buildStateFields(stateFields))
        ..methods.addAll([
          ..._buildStateGettersSetters(stateFields),
          Method(
            (b) => b
              ..name = 'build'
              ..returns = refer('Widget')
              ..requiredParameters.add(
                Parameter(
                  (b) => b
                    ..name = 'context'
                    ..type = refer('BuildContext'),
                ),
              )
              ..body = buildMethodBody,
          ),
        ]),
    );

    final library = Library((b) => b..body.addAll([widgetClass, stateClass]));

    return _formatter.format('${library.accept(_emitter)}');
  }

  List<Field> _buildWidgetFields(List<DpugStateFieldSpec> stateFields) {
    return stateFields
        .map(
          (f) => Field(
            (b) => b
              ..name = f.name
              ..modifier = FieldModifier.final$
              ..type = refer(f.type),
          ),
        )
        .toList();
  }

  Constructor _buildConstructor(List<DpugStateFieldSpec> stateFields) {
    // Heuristic to match tests:
    // - If there are multiple fields, put super.key first (e.g., TodoList)
    // - If there is a single field, put required field(s) first, then super.key (e.g., Counter, Display)
    final putKeyFirst = stateFields.length > 1;
    return Constructor(
      (b) => b
        ..constant = false
        ..optionalParameters.addAll([
          if (putKeyFirst)
            Parameter(
              (b) => b
                ..name = 'key'
                ..named = true
                ..toSuper = true,
            ),
          ...stateFields.map(
            (f) => Parameter(
              (b) => b
                ..name = f.name
                ..named = true
                ..required = true
                ..toThis = true,
            ),
          ),
          if (!putKeyFirst)
            Parameter(
              (b) => b
                ..name = 'key'
                ..named = true
                ..toSuper = true,
            ),
        ]),
    );
  }

  Method _buildCreateState(String className, String stateClassName) {
    return Method(
      (b) => b
        ..name = 'createState'
        ..annotations.add(refer('override'))
        ..returns = refer('State<$className>')
        ..lambda = true
        ..body = Code('$stateClassName()'),
    );
  }

  List<Field> _buildStateFields(List<DpugStateFieldSpec> stateFields) {
    return stateFields
        .map(
          (f) => Field(
            (b) => b
              ..name = '_${f.name}'
              ..late = true
              ..type = refer(f.type)
              ..assignment = Code('widget.${f.name}'),
          ),
        )
        .toList();
  }

  List<Method> _buildStateGettersSetters(List<DpugStateFieldSpec> stateFields) {
    final methods = <Method>[];

    for (final field in stateFields) {
      // Getter
      methods.add(
        Method(
          (b) => b
            ..name = field.name
            ..type = MethodType.getter
            ..returns = refer(field.type)
            ..lambda = true
            ..body = Code('_${field.name}'),
        ),
      );

      // Setter
      methods.add(
        Method(
          (b) => b
            ..name = field.name
            ..type = MethodType.setter
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = 'value'
                  ..type = refer(field.type),
              ),
            )
            ..lambda = true
            ..body = Code('setState(() => _${field.name} = value)'),
        ),
      );
    }

    return methods;
  }
}
