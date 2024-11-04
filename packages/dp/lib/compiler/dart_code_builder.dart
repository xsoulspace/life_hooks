import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class DpugCodeBuilder {
  final _formatter = DartFormatter();
  final _emitter = DartEmitter();

  String buildStatefulWidget({
    required String className,
    required List<StateField> stateFields,
    required Code buildMethod,
  }) {
    final stateClassName = '_${className}State';

    // Build main widget class
    final widgetClass = Class((b) => b
      ..name = className
      ..extend = refer('StatefulWidget')
      ..fields.addAll(_buildWidgetFields(stateFields))
      ..constructors.add(_buildConstructor(className, stateFields))
      ..methods.add(_buildCreateState(stateClassName)));

    // Build state class
    final stateClass = Class((b) => b
      ..name = stateClassName
      ..extend = refer('State<$className>')
      ..fields.addAll(_buildStateFields(stateFields))
      ..methods.addAll([
        ..._buildStateGettersSetters(stateFields),
        Method((b) => b
          ..name = 'build'
          ..returns = refer('Widget')
          ..requiredParameters.add(Parameter((b) => b
            ..name = 'context'
            ..type = refer('BuildContext')))
          ..body = buildMethod),
      ]));

    final library = Library((b) => b..body.addAll([widgetClass, stateClass]));

    return _formatter.format('${library.accept(_emitter)}');
  }

  List<Field> _buildWidgetFields(List<StateField> stateFields) {
    return stateFields
        .map((f) => Field((b) => b
          ..name = f.name
          ..modifier = FieldModifier.final$
          ..type = refer(f.type)))
        .toList();
  }

  Constructor _buildConstructor(
      String className, List<StateField> stateFields) {
    return Constructor((b) => b
      ..name = className
      ..constant = true
      ..optionalParameters.addAll([
        ...stateFields.map((f) => Parameter((b) => b
          ..name = f.name
          ..named = true
          ..required = true
          ..toThis = true)),
        Parameter((b) => b
          ..name = 'key'
          ..named = true
          ..toSuper = true),
      ]));
  }

  Method _buildCreateState(String stateClassName) {
    return Method((b) => b
      ..name = 'createState'
      ..annotations.add(refer('override'))
      ..returns = refer('State<StatefulWidget>')
      ..lambda = true
      ..body = Code('$stateClassName()'));
  }

  List<Field> _buildStateFields(List<StateField> stateFields) {
    return stateFields
        .map((f) => Field((b) => b
          ..name = '_${f.name}'
          ..late = true
          ..type = refer(f.type)
          ..assignment = Code('widget.${f.name}')))
        .toList();
  }

  List<Method> _buildStateGettersSetters(List<StateField> stateFields) {
    final methods = <Method>[];

    for (final field in stateFields) {
      // Getter
      methods.add(Method((b) => b
        ..name = field.name
        ..type = MethodType.getter
        ..returns = refer(field.type)
        ..lambda = true
        ..body = Code('_${field.name}')));

      // Setter
      methods.add(Method((b) => b
        ..name = field.name
        ..type = MethodType.setter
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'value'
          ..type = refer(field.type)))
        ..lambda = true
        ..body = Code('setState(() => _${field.name} = value)')));
    }

    return methods;
  }
}

class StateField {
  final String name;
  final String type;
  final String annotation;
  final Expression? initialValue;

  StateField({
    required this.name,
    required this.type,
    required this.annotation,
    this.initialValue,
  });
}
