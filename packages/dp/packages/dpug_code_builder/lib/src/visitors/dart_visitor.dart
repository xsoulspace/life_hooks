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
        ..type = spec.isGetter ? cb.MethodType.getter : null
        ..requiredParameters
            .addAll(spec.parameters.map((p) => p.accept(this) as cb.Parameter));

      // Handle the body based on its type
      final bodySpec = spec.body.accept(this);
      if (spec.isGetter) {
        b
          ..lambda = true
          ..body = bodySpec is cb.Code
              ? bodySpec
              : cb.Code(bodySpec.accept(_emitter).toString());
      } else {
        // For regular methods (like build)
        final bodyCode = bodySpec is cb.Code
            ? bodySpec.toString()
            : bodySpec.accept(_emitter).toString();
        b..body = cb.Code('''
          return ${bodyCode};
        ''');
      }
    });
  }

  @override
  cb.Spec visitWidget(DpugWidgetSpec spec) {
    final properties = <String, cb.Expression>{};
    final positionalArgs = <cb.Expression>[];

    // Convert all positional arguments (both regular and cascade)
    for (final arg in [...spec.positionalArgs, ...spec.positionalCascadeArgs]) {
      final value = arg.accept(this);
      if (value is cb.Expression) {
        positionalArgs.add(value);
      } else if (value is cb.Code) {
        positionalArgs.add(cb.CodeExpression(value));
      }
    }

    // Convert properties to expressions
    for (final entry in spec.properties.entries) {
      final value = entry.value.accept(this);
      if (value is cb.Expression) {
        properties[entry.key] = value;
      } else if (value is cb.Code) {
        properties[entry.key] = cb.CodeExpression(value);
      }
    }

    // Build the widget expression
    final expression = cb.refer(spec.name).call(
      positionalArgs,
      {
        ...properties,
        if (spec.children.isNotEmpty)
          'children': cb.literalList(
            spec.children.map((c) {
              final childSpec = c.accept(this);
              if (childSpec is cb.Expression) {
                return childSpec;
              } else if (childSpec is cb.Code) {
                return cb.CodeExpression(childSpec);
              }
              throw StateError(
                  'Unexpected spec type: ${childSpec.runtimeType}');
            }).toList(),
          ),
      },
    );

    // Convert to properly formatted code without additional formatting
    return cb.Code(expression.accept(_emitter).toString());
  }

  @override
  cb.Spec visitLambda(DpugLambdaSpec spec) {
    final params = spec.parameters.map((p) => cb.Parameter((b) => b..name = p));
    final body = spec.body.accept(this);

    return cb.Method((b) => b
      ..lambda = true
      ..requiredParameters.addAll(params)
      ..body = body is cb.Code
          ? body
          : cb.Code(body.accept(_emitter).toString())).closure;
  }

  @override
  cb.Spec visitAssignment(DpugAssignmentSpec spec) {
    final value = spec.value.accept(this);
    final valueCode = value is cb.Expression
        ? value.accept(_emitter).toString()
        : value.toString();
    return cb.Code('${spec.target} = $valueCode');
  }

  @override
  cb.Spec visitParameter(DpugParameterSpec spec) {
    final param = cb.Parameter((b) => b
      ..name = spec.name
      ..type = cb.refer(spec.type)
      ..named = spec.isNamed
      ..required = spec.isRequired
      ..defaultTo = spec.defaultValue?.accept(this) as cb.Code?);
    final result = ds.DartFormatter(
            languageVersion: ds.DartFormatter.latestLanguageVersion)
        .format(
            '${cb.CodeExpression(cb.Code(param.toString())).accept(cb.DartEmitter())}');
    return cb.CodeExpression(cb.Code(result));
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
}
