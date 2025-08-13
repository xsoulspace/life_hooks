import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart' as ds;
import 'package:dpug_code_builder/src/dart_imports.dart';

import '../specs/specs.dart';
import 'visitor.dart';

/// converts Dpug to Dart
class DpugToDartSpecVisitor implements DpugSpecVisitor<cb.Spec> {
  final _emitter = cb.DartEmitter();
  final _formatter = ds.DartFormatter(
    languageVersion: ds.DartFormatter.latestLanguageVersion,
  );

  @override
  cb.Spec visitCode(DpugCodeSpec spec, [cb.Spec? context]) {
    return cb.Code(spec.value);
  }

  @override
  cb.Spec visitExpression(DpugExpressionSpec spec, [cb.Spec? context]) {
    // Fallback: try specialized handlers via pattern checks
    if (spec is DpugReferenceExpressionSpec)
      return visitReferenceExpression(spec);
    if (spec is DpugStringLiteralSpec) return visitStringLiteral(spec);
    if (spec is DpugWidgetExpressionSpec) return spec.builder.accept(this);
    if (spec is DpugInvokeSpec) return visitInvoke(spec);
    if (spec is DpugAssignmentSpec) return visitAssignment(spec);
    if (spec is DpugBinarySpec) return visitBinary(spec);
    if (spec is DpugBoolLiteralSpec) return visitBoolLiteral(spec);
    if (spec is DpugNumLiteralSpec) return visitNumLiteral(spec);
    if (spec is DpugClosureExpressionSpec) return visitClosureExpression(spec);
    if (spec is DpugLiteralSpec) return visitLiteral(spec);
    if (spec is DpugListLiteralSpec) return visitListLiteral(spec);
    return cb.Code('');
  }

  @override
  cb.Spec visitClass(DpugClassSpec spec, [cb.Spec? context]) {
    if (spec.annotations.any((a) => a.name == 'stateful')) {
      final library = cb.Library(
        (b) =>
            b..body.addAll([_buildWidgetClass(spec), _buildStateClass(spec)]),
      );

      // Convert library to formatted string
      return cb.Code(_formatter.format(library.accept(_emitter).toString()));
    }

    final classSpec = cb.Class(
      (b) => b
        ..name = spec.name
        ..extend = cb.refer('StatefulWidget')
        ..fields.addAll(spec.stateFields.map((f) => f.accept(this) as cb.Field))
        ..methods.addAll(spec.methods.map((m) => m.accept(this) as cb.Method)),
    );

    return cb.Code(_formatter.format(classSpec.accept(_emitter).toString()));
  }

  @override
  cb.Spec visitStateField(DpugStateFieldSpec spec, [cb.Spec? context]) {
    return cb.Field(
      (b) => b
        ..name = spec.name
        ..type = cb.refer(spec.type)
        ..modifier = cb.FieldModifier.final$
        ..annotations.add(spec.annotation.accept(this) as cb.Expression)
        ..assignment = spec.initializer?.accept(this) as cb.Code?,
    );
  }

  @override
  cb.Spec visitMethod(DpugMethodSpec spec, [cb.Spec? context]) {
    return cb.Method((b) {
      b..name = spec.name;

      if (spec.name == 'build') {
        b
          ..annotations.add(cb.refer('override'))
          ..returns = cb.refer('Widget')
          ..requiredParameters.add(
            cb.Parameter(
              (pb) => pb
                ..name = 'context'
                ..type = cb.refer('BuildContext'),
            ),
          );
      } else {
        b
          ..returns = cb.refer(spec.returnType)
          ..type = spec.isGetter ? cb.MethodType.getter : null;

        if (!spec.isGetter) {
          b.requiredParameters.addAll(
            spec.parameters.map(
              (p) => cb.Parameter(
                (pb) => pb
                  ..name = p.name
                  ..type = p.type != null
                      ? cb.refer(p.type!.symbol, p.type!.url)
                      : null
                  ..named = p.isNamed
                  ..required = p.isRequired
                  ..toThis = p.isNamed,
              ),
            ),
          );
        }
      }

      // Handle body
      final bodySpec = spec.body.accept(this);
      if (spec.name == 'build') {
        b..body = cb.Code('return ${bodySpec.accept(_emitter)};');
      } else if (spec.isGetter) {
        b
          ..lambda = true
          ..body = bodySpec is cb.Expression
              ? bodySpec.code
              : bodySpec as cb.Code;
      } else {
        b..body = cb.Code('return ${bodySpec.accept(_emitter)};');
      }
    });
  }

  @override
  cb.Spec visitWidget(DpugWidgetSpec spec, [cb.Spec? context]) {
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
    final expression = cb.refer(spec.name).call(positionalArgs, {
      ...properties,
      if (spec.shouldUseChildSugar)
        if (spec.isSingleChild)
          'child': _processChild(spec.children.first)
        else
          'children': cb.literalList(spec.children.map(_processChild).toList()),
    });

    return cb.Code(expression.accept(_emitter).toString());
  }

  @override
  cb.Spec visitStringLiteral(DpugStringLiteralSpec spec, [cb.Spec? context]) {
    return cb.literalString(spec.value, raw: spec.raw);
  }

  @override
  cb.Spec visitReference(DpugReferenceSpec spec, [cb.Spec? context]) {
    return cb.refer(spec.symbol, spec.url);
  }

  cb.Expression _processChild(DpugWidgetSpec child) {
    final childSpec = child.accept(this);
    if (childSpec is cb.Expression) {
      return childSpec;
    } else if (childSpec is cb.Code) {
      return cb.CodeExpression(childSpec);
    }
    throw StateError('Unexpected child spec type: ${childSpec.runtimeType}');
  }

  @override
  cb.Spec visitClosureExpression(
    DpugClosureExpressionSpec spec, [
    cb.Spec? context,
  ]) {
    return toClosure(spec.method.accept(this) as cb.Method);
  }

  @override
  cb.Spec visitAssignment(DpugAssignmentSpec spec, [cb.Spec? context]) {
    final value = spec.value.accept(this);
    return cb.CodeExpression(
      cb.Code('${spec.target} = ${value.accept(_emitter)}'),
    );
  }

  @override
  cb.Spec visitAnnotation(DpugAnnotationSpec spec, [cb.Spec? context]) {
    return cb
        .refer('@${spec.name}')
        .call(
          spec.arguments.map((a) => a.accept(this) as cb.Expression).toList(),
        );
  }

  @override
  cb.Spec visitListLiteral(DpugListLiteralSpec spec, [cb.Spec? context]) {
    return cb.literalList(
      spec.values.map((v) => v.accept(this) as cb.Expression),
    );
  }

  cb.Class _buildWidgetClass(DpugClassSpec spec) {
    return cb.Class(
      (b) => b
        ..name = spec.name
        ..extend = cb.refer('StatefulWidget')
        ..constructors.add(
          cb.Constructor(
            (b) => b
              ..optionalParameters.addAll([
                cb.Parameter(
                  (b) => b
                    ..name = 'key'
                    ..named = true
                    ..toSuper = true,
                ),
                ...spec.stateFields.map(
                  (f) => cb.Parameter(
                    (b) => b
                      ..name = f.name
                      ..named = true
                      ..required = true
                      ..toThis = true,
                  ),
                ),
              ]),
          ),
        )
        ..fields.addAll(
          spec.stateFields.map(
            (f) => cb.Field(
              (b) => b
                ..name = f.name
                ..modifier = cb.FieldModifier.final$
                ..type = cb.refer(f.type),
            ),
          ),
        )
        ..methods.add(
          cb.Method(
            (b) => b
              ..name = 'createState'
              ..returns = cb.refer('State<${spec.name}>')
              ..annotations.add(cb.refer('override'))
              ..lambda = true
              ..body = cb.Code('_${spec.name}State()'),
          ),
        ),
    );
  }

  cb.Class _buildStateClass(DpugClassSpec spec) {
    return cb.Class(
      (b) => b
        ..name = '_${spec.name}State'
        ..extend = cb.refer('State<${spec.name}>')
        ..fields.addAll(spec.stateFields.map(_buildStateField))
        ..methods.addAll([
          ...spec.stateFields.expand(_buildStateAccessors),
          ...spec.methods.map((m) => m.accept(this) as cb.Method),
        ]),
    );
  }

  cb.Field _buildStateField(DpugStateFieldSpec field) {
    return cb.Field(
      (b) => b
        ..name = '_${field.name}'
        ..late = true
        ..type = cb.refer(field.type)
        ..assignment = cb.Code('widget.${field.name}'),
    );
  }

  Iterable<cb.Method> _buildStateAccessors(DpugStateFieldSpec field) {
    return [
      cb.Method(
        (b) => b
          ..name = field.name
          ..type = cb.MethodType.getter
          ..returns = cb.refer(field.type)
          ..lambda = true
          ..body = cb.Code('_${field.name}'),
      ),
      cb.Method(
        (b) => b
          ..name = field.name
          ..type = cb.MethodType.setter
          ..lambda = true
          ..requiredParameters.add(
            cb.Parameter(
              (b) => b
                ..name = 'value'
                ..type = cb.refer(field.type),
            ),
          )
          ..body = cb.Code('setState(() => _${field.name} = value)'),
      ),
    ];
  }

  @override
  cb.Spec visitParameter(DpugParameterSpec spec, [cb.Spec? context]) {
    // Instead of returning Parameter directly, return a Method that would use this parameter
    return cb.Method(
      (b) => b
        ..requiredParameters.add(
          cb.Parameter(
            (pb) => pb
              ..name = spec.name
              ..type = spec.type != null
                  ? cb.refer(spec.type!.symbol, spec.type!.url)
                  : null
              ..named = spec.isNamed
              ..required = spec.isRequired
              ..toThis = spec.isNamed,
          ),
        ),
    );
  }

  @override
  cb.Spec visitBinary(DpugBinarySpec spec, [cb.Spec? context]) {
    final left = spec.left.accept(this);
    final right = spec.right.accept(this);
    final leftStr = left.accept(_emitter).toString();
    final rightStr = right.accept(_emitter).toString();
    return cb.CodeExpression(cb.Code('$leftStr ${spec.operator} $rightStr'));
  }

  @override
  cb.Spec visitConstructor(DpugConstructorSpec spec, [cb.Spec? context]) {
    return cb.Constructor(
          (b) => b
            ..name = spec.name
            ..body = spec.body?.accept(this) as cb.Code?
            ..constant = spec.isConst
            ..docs.addAll(spec.docs)
            ..external = spec.external
            ..factory = spec.factory
            ..lambda = spec.lambda
            ..redirect = spec.redirect?.accept(this) as cb.Reference?
            ..initializers.addAll(
              spec.initializers.map((i) => i.accept(this) as cb.Code),
            )
            ..annotations.addAll(
              spec.annotations.map((a) => a.accept(this) as cb.Expression),
            )
            ..optionalParameters.addAll(
              spec.optionalParameters.map(
                (p) => p.accept(this) as cb.Parameter,
              ),
            )
            ..requiredParameters.addAll(
              spec.requiredParameters.map(
                (p) => p.accept(this) as cb.Parameter,
              ),
            ),
        )
        as cb.Spec;
  }

  @override
  cb.Spec visitInvoke(DpugInvokeSpec spec, [cb.Spec? context]) {
    final targetSpec = spec.target.accept(this);
    final targetExpr = targetSpec is cb.Expression
        ? targetSpec
        : cb.CodeExpression(targetSpec as cb.Code);
    final positional = <cb.Expression>[];
    for (final a in spec.positionedArguments) {
      final s = a.accept(this);
      if (s is cb.Expression) {
        positional.add(s);
      } else if (s is cb.Code) {
        positional.add(cb.CodeExpression(s));
      }
    }
    final named = <String, cb.Expression>{};
    spec.namedArguments.forEach((k, v) {
      final s = v.accept(this);
      if (s is cb.Expression) {
        named[k] = s;
      } else if (s is cb.Code) {
        named[k] = cb.CodeExpression(s);
      }
    });
    final invoke = targetExpr.call(positional, named);
    return cb.Code(invoke.accept(_emitter).toString());
  }

  @override
  cb.Spec visitLiteral(DpugLiteralSpec spec, [cb.Spec? context]) {
    final value = spec.value;
    if (value is String) return cb.literalString(value);
    if (value is num) return cb.literalNum(value);
    if (value is bool) return cb.literalBool(value);
    return cb.Code("'${value.toString()}'");
  }

  @override
  cb.Spec visitReferenceExpression(
    DpugReferenceExpressionSpec spec, [
    cb.Spec? context,
  ]) {
    return cb.CodeExpression(cb.Code(spec.name));
  }

  @override
  cb.Spec visitBoolLiteral(DpugBoolLiteralSpec spec, [cb.Spec? context]) {
    return cb.literalBool(spec.value);
  }

  @override
  cb.Spec visitNumLiteral(DpugNumLiteralSpec spec, [cb.Spec? context]) {
    return cb.literalNum(spec.value);
  }
}
