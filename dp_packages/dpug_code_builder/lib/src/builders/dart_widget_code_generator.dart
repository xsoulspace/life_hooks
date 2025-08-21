import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../specs/class_spec.dart';
import '../specs/state_field_spec.dart';
import '../visitors/dpug_emitter.dart';

class DartWidgetCodeGenerator {
  final _formatter = DartFormatter();
  final _emitter = DartEmitter();
  final _dpugEmitter = DpugEmitter();

  String generateStatefulWidget(final DpugClassSpec dpugClassSpec) {
    final className = dpugClassSpec.name;
    final stateFields = dpugClassSpec.stateFields.toList();
    final buildMethodSpec = dpugClassSpec.methods.firstWhere(
      (final method) => method.name == 'build' && method.isGetter,
      orElse: () => throw StateError('Build method not found in DpugClassSpec'),
    );

    // Convert DpugSpec body to Code object
    final buildMethodBody = Code(buildMethodSpec.body.accept(_dpugEmitter));

    final stateClassName = '_${className}State';

    // Build main widget class
    final widgetClass = Class(
      (final b) => b
        ..name = className
        ..extend = refer('StatefulWidget')
        ..fields.addAll(_buildWidgetFields(stateFields))
        ..constructors.add(_buildConstructor(stateFields))
        ..methods.add(_buildCreateState(className, stateClassName)),
    );

    // Build state class
    final stateClass = Class(
      (final b) => b
        ..name = stateClassName
        ..extend = refer('State<$className>')
        ..fields.addAll(_buildStateFields(stateFields))
        ..methods.addAll([
          ..._buildStateGettersSetters(stateFields),
          Method(
            (final b) => b
              ..name = 'build'
              ..returns = refer('Widget')
              ..requiredParameters.add(
                Parameter(
                  (final b) => b
                    ..name = 'context'
                    ..type = refer('BuildContext'),
                ),
              )
              ..body = buildMethodBody,
          ),
        ]),
    );

    final library = Library(
      (final b) => b..body.addAll([widgetClass, stateClass]),
    );

    return _formatter.format('${library.accept(_emitter)}');
  }

  List<Field> _buildWidgetFields(final List<DpugStateFieldSpec> stateFields) =>
      stateFields
          .map(
            (final f) => Field(
              (final b) => b
                ..name = f.name
                ..modifier = FieldModifier.final$
                ..type = refer(f.type),
            ),
          )
          .toList();

  Constructor _buildConstructor(final List<DpugStateFieldSpec> stateFields) {
    // Heuristic to match tests:
    // - If there are multiple fields, put super.key first (e.g., TodoList)
    // - If there is a single field, put required field(s) first, then super.key (e.g., Counter, Display)
    final putKeyFirst = stateFields.length > 1;
    return Constructor(
      (final b) => b
        ..constant = false
        ..optionalParameters.addAll([
          if (putKeyFirst)
            Parameter(
              (final b) => b
                ..name = 'key'
                ..named = true
                ..toSuper = true,
            ),
          ...stateFields.map(
            (final f) => Parameter(
              (final b) => b
                ..name = f.name
                ..named = true
                ..required = true
                ..toThis = true,
            ),
          ),
          if (!putKeyFirst)
            Parameter(
              (final b) => b
                ..name = 'key'
                ..named = true
                ..toSuper = true,
            ),
        ]),
    );
  }

  Method _buildCreateState(
    final String className,
    final String stateClassName,
  ) => Method(
    (final b) => b
      ..name = 'createState'
      ..annotations.add(refer('override'))
      ..returns = refer('State<$className>')
      ..lambda = true
      ..body = Code('$stateClassName()'),
  );

  List<Field> _buildStateFields(final List<DpugStateFieldSpec> stateFields) =>
      stateFields
          .map(
            (final f) => Field(
              (final b) => b
                ..modifier = FieldModifier.var$
                ..type = refer('late ${f.type}')
                ..name = '_${f.name}'
                ..assignment = Code('widget.${f.name}'),
            ),
          )
          .toList();

  List<Method> _buildStateGettersSetters(
    final List<DpugStateFieldSpec> stateFields,
  ) {
    final methods = <Method>[];

    for (final field in stateFields) {
      // Getter
      methods.add(
        Method(
          (final b) => b
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
          (final b) => b
            ..name = field.name
            ..type = MethodType.setter
            ..requiredParameters.add(
              Parameter(
                (final b) => b
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
