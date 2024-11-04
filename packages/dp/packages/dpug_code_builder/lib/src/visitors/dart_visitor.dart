import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart' as ds;

import '../specs/specs.dart';
import 'visitor.dart';

class DartGeneratingVisitor implements DpugSpecVisitor<cb.Spec> {
  final _emitter = cb.DartEmitter();
  final _formatter = ds.DartFormatter();

  @override
  cb.Spec visitClass(DpugClassSpec spec) {
    if (spec.annotations.any((a) => a.name == 'stateful')) {
      final library = cb.Library((b) => b
        ..body.addAll([
          _buildWidgetClass(spec),
          _buildStateClass(spec),
        ]));

      // Convert library to formatted string
      return cb.Code(_formatter.format(library.accept(_emitter).toString()));
    }

    final classSpec = cb.Class((b) => b
      ..name = spec.name
      ..extend = cb.refer('StatefulWidget')
      ..fields.addAll(spec.stateFields.map((f) => f.accept(this) as cb.Field))
      ..methods.addAll(spec.methods.map((m) => m.accept(this) as cb.Method)));

    return cb.Code(_formatter.format(classSpec.accept(_emitter).toString()));
  }

  @override
  cb.Spec visitStateField(DpugStateFieldSpec spec) {
    return cb.Field((b) => b
      ..name = spec.name
      ..type = cb.refer(spec.type)
      ..modifier = cb.FieldModifier.final$
      ..annotations.add(spec.annotation.accept(this) as cb.Expression)
      ..assignment = spec.initializer?.accept(this) as cb.Code?);
  }

  @override
  cb.Spec visitMethod(DpugMethodSpec spec) {
    return cb.Method((b) {
      b
        ..name = spec.name
        ..returns = cb.refer(spec.returnType)
        ..type = spec.isGetter ? cb.MethodType.getter : null;

      // Handle parameters by creating them directly here
      if (!spec.isGetter) {
        b.requiredParameters.addAll(
          spec.parameters.map((p) => cb.Parameter((pb) => pb
            ..name = p.name
            ..type = cb.refer(p.type)
            ..named = p.isNamed
            ..required = p.isRequired
            ..toThis = p.isNamed)),
        );
      }

      // Handle body
      final bodySpec = spec.body.accept(this);
      if (spec.isGetter) {
        b
          ..lambda = true
          ..body =
              bodySpec is cb.Expression ? bodySpec.code : bodySpec as cb.Code;
      } else {
        b..body = cb.Code('return ${bodySpec.accept(_emitter)};');
      }
    });
  }

  @override
  cb.Spec visitWidget(DpugWidgetSpec spec) {
    final properties = <String, cb.Expression>{};
    final positionalArgs = <cb.Expression>[];

    // Convert all positional arguments
    for (final arg in [...spec.positionalArgs, ...spec.positionalCascadeArgs]) {
      final value = arg.accept(this);
      if (value is cb.Expression) {
        positionalArgs.add(value);
      } else if (value is cb.Code) {
        positionalArgs.add(cb.CodeExpression(value));
      }
    }

    // Convert properties
    for (final entry in spec.properties.entries) {
      final value = entry.value.accept(this);
      if (value is cb.Expression) {
        properties[entry.key] = value;
      } else if (value is cb.Code) {
        properties[entry.key] = cb.CodeExpression(value);
      }
    }

    // Build widget expression
    final expression = cb.refer(spec.name).newInstance(
      positionalArgs,
      {
        ...properties,
        if (spec.children.isNotEmpty)
          'children': cb.literalList(
            spec.children.map((c) {
              final childSpec = c.accept(this);
              return childSpec is cb.Expression
                  ? childSpec
                  : cb.CodeExpression(childSpec as cb.Code);
            }).toList(),
          ),
      },
    );

    return expression;
  }

  @override
  cb.Spec visitLambda(DpugLambdaSpec spec) {
    final params = spec.parameters.map((p) => cb.Parameter((b) => b..name = p));
    final bodySpec = spec.body.accept(this);
    final bodyCode = bodySpec is cb.Expression
        ? bodySpec.accept(_emitter).toString()
        : (bodySpec as cb.Code).toString();

    return cb.Method((b) => b
      ..lambda = true
      ..requiredParameters.addAll(params)
      ..body = cb.Code(bodyCode)).closure;
  }

  @override
  cb.Spec visitAssignment(DpugAssignmentSpec spec) {
    final value = spec.value.accept(this);
    return cb.CodeExpression(cb.Code(
      '${spec.target} = ${value.accept(_emitter)}',
    ));
  }

  @override
  cb.Spec visitAnnotation(DpugAnnotationSpec spec) {
    return cb.refer('@${spec.name}').call(
        spec.arguments.map((a) => a.accept(this) as cb.Expression).toList());
  }

  @override
  cb.Spec visitReference(DpugReferenceSpec spec) {
    return cb.refer(spec.name);
  }

  @override
  cb.Spec visitListLiteral(DpugListLiteralSpec spec) {
    return cb
        .literalList(spec.values.map((v) => v.accept(this) as cb.Expression));
  }

  @override
  cb.Spec visitStringLiteral(DpugStringLiteralSpec spec) {
    return cb.literalString(spec.value);
  }

  cb.Class _buildWidgetClass(DpugClassSpec spec) {
    return cb.Class((b) => b
      ..name = spec.name
      ..extend = cb.refer('StatefulWidget')
      ..constructors.add(cb.Constructor((b) => b
        ..optionalParameters.addAll([
          cb.Parameter((b) => b
            ..name = 'key'
            ..named = true
            ..toSuper = true),
          ...spec.stateFields.map((f) => cb.Parameter((b) => b
            ..name = f.name
            ..named = true
            ..required = true))
        ])))
      ..fields.addAll(spec.stateFields.map((f) => cb.Field((b) => b
        ..name = f.name
        ..modifier = cb.FieldModifier.final$
        ..type = cb.refer(f.type))))
      ..methods.add(cb.Method((b) => b
        ..name = 'createState'
        ..returns = cb.refer('State<${spec.name}>')
        ..annotations.add(cb.refer('override'))
        ..lambda = true
        ..body = cb.Code('_${spec.name}State()'))));
  }

  cb.Class _buildStateClass(DpugClassSpec spec) {
    return cb.Class((b) => b
      ..name = '_${spec.name}State'
      ..extend = cb.refer('State<${spec.name}>')
      ..fields.addAll(spec.stateFields.map(_buildStateField))
      ..methods.addAll([
        ...spec.stateFields.expand(_buildStateAccessors),
        ...spec.methods.map((m) => m.accept(this) as cb.Method),
      ]));
  }

  cb.Field _buildStateField(DpugStateFieldSpec field) {
    return cb.Field((b) => b
      ..name = '_${field.name}'
      ..late = true
      ..type = cb.refer(field.type)
      ..assignment = cb.Code('widget.${field.name}'));
  }

  Iterable<cb.Method> _buildStateAccessors(DpugStateFieldSpec field) {
    return [
      cb.Method((b) => b
        ..name = field.name
        ..type = cb.MethodType.getter
        ..returns = cb.refer(field.type)
        ..lambda = true
        ..body = cb.Code('_${field.name}')),
      cb.Method((b) => b
        ..name = field.name
        ..type = cb.MethodType.setter
        ..lambda = true
        ..requiredParameters.add(cb.Parameter((b) => b
          ..name = 'value'
          ..type = cb.refer(field.type)))
        ..body = cb.Code('setState(() => _${field.name} = value)')),
    ];
  }

  @override
  cb.Spec visitParameter(DpugParameterSpec spec) {
    // Instead of returning Parameter directly, return a Method that would use this parameter
    return cb.Method((b) => b
      ..requiredParameters.add(cb.Parameter((pb) => pb
        ..name = spec.name
        ..type = cb.refer(spec.type)
        ..named = spec.isNamed
        ..required = spec.isRequired
        ..toThis = spec.isNamed)));
  }
}
