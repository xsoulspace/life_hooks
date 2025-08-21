import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart' as ds;

import '../dart_imports.dart';
import '../specs/specs.dart';
import 'visitor.dart';

/// converts Dpug to Dart
class DpugToDartSpecVisitor implements DpugSpecVisitor<cb.Spec> {
  final _emitter = cb.DartEmitter();
  final _formatter = ds.DartFormatter(
    languageVersion: ds.DartFormatter.latestLanguageVersion,
  );

  @override
  cb.Spec visitCode(final DpugCodeSpec spec, [final cb.Spec? context]) =>
      cb.Code(spec.value);

  @override
  cb.Spec visitExpression(
    final DpugExpressionSpec spec, [
    final cb.Spec? context,
  ]) {
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
    return const cb.Code('');
  }

  @override
  cb.Spec visitClass(final DpugClassSpec spec, [final cb.Spec? context]) {
    if (spec.annotations.any((final a) => a.name == 'stateful')) {
      final library = cb.Library(
        (final b) =>
            b..body.addAll([_buildWidgetClass(spec), _buildStateClass(spec)]),
      );

      // Convert library to formatted string
      return cb.Code(_formatter.format(library.accept(_emitter).toString()));
    }

    final classSpec = cb.Class(
      (final b) => b
        ..name = spec.name
        ..extend = cb.refer('StatefulWidget')
        ..fields.addAll(
          spec.stateFields.map((final f) => f.accept(this) as cb.Field),
        )
        ..methods.addAll(
          spec.methods.map((final m) => m.accept(this) as cb.Method),
        ),
    );
    return cb.Code(_formatter.format(classSpec.accept(_emitter).toString()));
  }

  @override
  cb.Spec visitStateField(
    final DpugStateFieldSpec spec, [
    final cb.Spec? context,
  ]) => cb.Field(
    (final b) => b
      ..name = spec.name
      ..type = cb.refer(spec.type)
      ..modifier = cb.FieldModifier.final$
      ..annotations.add(spec.annotation.accept(this) as cb.Expression)
      ..assignment = spec.initializer?.accept(this) as cb.Code?,
  );

  @override
  cb.Spec visitMethod(final DpugMethodSpec spec, [final cb.Spec? context]) =>
      cb.Method((final b) {
        b.name = spec.name;

        if (spec.name == 'build') {
          b
            ..annotations.add(cb.refer('override'))
            ..returns = cb.refer('Widget')
            ..requiredParameters.add(
              cb.Parameter(
                (final pb) => pb
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
                (final p) => cb.Parameter(
                  (final pb) => pb
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
          b.body = cb.Code('return ${bodySpec.accept(_emitter)};');
        } else if (spec.isGetter) {
          b
            ..lambda = true
            ..body = bodySpec is cb.Expression
                ? bodySpec.code
                : bodySpec as cb.Code;
        } else {
          b.body = cb.Code('return ${bodySpec.accept(_emitter)};');
        }
      });

  @override
  cb.Spec visitWidget(final DpugWidgetSpec spec, [final cb.Spec? context]) {
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

    // Build widget expression. Some widgets always use `children` even for a single child.
    final multiChildWidgets = <String>{
      'Column',
      'Row',
      'Stack',
      'ListView',
      'GridView',
      'GridView.builder',
    };

    final Map<String, cb.Expression> namedArgs = {...properties};

    if (spec.children.isNotEmpty) {
      if (multiChildWidgets.contains(spec.name)) {
        namedArgs['children'] = cb.literalList(
          spec.children.map(_processChild).toList(),
        );
      } else if (spec.isSingleChild) {
        namedArgs['child'] = _processChild(spec.children.first);
      } else {
        namedArgs['children'] = cb.literalList(
          spec.children.map(_processChild).toList(),
        );
      }
    }

    final expression = cb.refer(spec.name).call(positionalArgs, namedArgs);

    return cb.Code(expression.accept(_emitter).toString());
  }

  @override
  cb.Spec visitStringLiteral(
    final DpugStringLiteralSpec spec, [
    final cb.Spec? context,
  ]) => cb.literalString(spec.value, raw: spec.raw);

  @override
  cb.Spec visitReference(
    final DpugReferenceSpec spec, [
    final cb.Spec? context,
  ]) => cb.refer(spec.symbol, spec.url);

  cb.Expression _processChild(final DpugWidgetSpec child) {
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
    final DpugClosureExpressionSpec spec, [
    final cb.Spec? context,
  ]) {
    // Build a lambda-style method for closures to produce arrow functions
    final bodySpec = spec.method.body.accept(this);
    final method = cb.Method(
      (final b) => b
        ..lambda = true
        ..returns = cb.refer('dynamic')
        ..requiredParameters.addAll(
          spec.method.parameters.map(
            (final p) => cb.Parameter(
              (final pb) => pb
                ..name = p.name
                ..type = p.type != null
                    ? cb.refer(p.type!.symbol, p.type!.url)
                    : null
                ..named = p.isNamed
                ..required = p.isRequired
                ..toThis = p.isNamed,
            ),
          ),
        )
        ..body = bodySpec is cb.Expression
            ? bodySpec.code
            : bodySpec as cb.Code,
    );
    return toClosure(method);
  }

  @override
  cb.Spec visitAssignment(
    final DpugAssignmentSpec spec, [
    final cb.Spec? context,
  ]) {
    final value = spec.value.accept(this);
    return cb.CodeExpression(
      cb.Code('${spec.target} = ${value.accept(_emitter)}'),
    );
  }

  @override
  cb.Spec visitAnnotation(
    final DpugAnnotationSpec spec, [
    final cb.Spec? context,
  ]) => cb
      .refer('@${spec.name}')
      .call(
        spec.arguments
            .map((final a) => a.accept(this) as cb.Expression)
            .toList(),
      );

  @override
  cb.Spec visitListLiteral(
    final DpugListLiteralSpec spec, [
    final cb.Spec? context,
  ]) => cb.literalList(
    spec.values.map((final v) => v.accept(this) as cb.Expression),
  );

  cb.Class _buildWidgetClass(final DpugClassSpec spec) => cb.Class(
    (final b) => b
      ..name = spec.name
      ..extend = cb.refer('StatefulWidget')
      ..constructors.add(
        cb.Constructor(
          (final b) => b
            ..optionalParameters.addAll([
              // Align to heuristic: if there are multiple fields, super.key first; else fields first
              if (spec.stateFields.length > 1)
                cb.Parameter(
                  (final b) => b
                    ..name = 'key'
                    ..named = true
                    ..toSuper = true,
                ),
              ...spec.stateFields.map(
                (final f) => cb.Parameter(
                  (final b) => b
                    ..name = f.name
                    ..named = true
                    ..required = true
                    ..toThis = true,
                ),
              ),
              if (spec.stateFields.length <= 1)
                cb.Parameter(
                  (final b) => b
                    ..name = 'key'
                    ..named = true
                    ..toSuper = true,
                ),
            ]),
        ),
      )
      ..fields.addAll(
        spec.stateFields.map(
          (final f) => cb.Field(
            (final b) => b
              ..name = f.name
              ..modifier = cb.FieldModifier.final$
              ..type = cb.refer(f.type),
          ),
        ),
      )
      ..methods.add(
        cb.Method(
          (final b) => b
            ..name = 'createState'
            ..returns = cb.refer('State<${spec.name}>')
            ..annotations.add(cb.refer('override'))
            ..lambda = true
            ..body = cb.Code('_${spec.name}State()'),
        ),
      ),
  );

  cb.Class _buildStateClass(final DpugClassSpec spec) => cb.Class(
    (final b) => b
      ..name = '_${spec.name}State'
      ..extend = cb.refer('State<${spec.name}>')
      ..fields.addAll(spec.stateFields.map(_buildStateField))
      ..methods.addAll([
        ...spec.stateFields.expand(_buildStateAccessors),
        ...spec.methods.map((final m) => m.accept(this) as cb.Method),
      ]),
  );

  cb.Field _buildStateField(final DpugStateFieldSpec field) => cb.Field(
    (final b) => b
      ..name = '_${field.name}'
      ..late = true
      ..type = cb.refer(field.type)
      ..assignment = cb.Code('widget.${field.name}'),
  );

  Iterable<cb.Method> _buildStateAccessors(final DpugStateFieldSpec field) => [
    cb.Method(
      (final b) => b
        ..name = field.name
        ..type = cb.MethodType.getter
        ..returns = cb.refer(field.type)
        ..lambda = true
        ..body = cb.Code('_${field.name}'),
    ),
    cb.Method(
      (final b) => b
        ..name = field.name
        ..type = cb.MethodType.setter
        ..lambda = true
        ..requiredParameters.add(
          cb.Parameter(
            (final b) => b
              ..name = 'value'
              ..type = cb.refer(field.type),
          ),
        )
        ..body = cb.Code('setState(() => _${field.name} = value)'),
    ),
  ];

  @override
  cb.Spec visitParameter(
    final DpugParameterSpec spec, [
    final cb.Spec? context,
  ]) {
    // Return a Method wrapper carrying a single parameter, to avoid changing call sites
    return cb.Method(
      (final b) => b
        ..requiredParameters.add(
          cb.Parameter(
            (final pb) => pb
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
  cb.Spec visitBinary(final DpugBinarySpec spec, [final cb.Spec? context]) {
    final left = spec.left.accept(this);
    final right = spec.right.accept(this);
    final leftStr = left.accept(_emitter).toString();
    final rightStr = right.accept(_emitter).toString();
    return cb.CodeExpression(cb.Code('$leftStr ${spec.operator} $rightStr'));
  }

  @override
  cb.Spec visitConstructor(
    final DpugConstructorSpec spec, [
    final cb.Spec? context,
  ]) =>
      cb.Constructor(
            (final b) => b
              ..name = spec.name
              ..body = spec.body?.accept(this) as cb.Code?
              ..constant = spec.isConst
              ..docs.addAll(spec.docs)
              ..external = spec.external
              ..factory = spec.factory
              ..lambda = spec.lambda
              ..redirect = spec.redirect?.accept(this) as cb.Reference?
              ..initializers.addAll(
                spec.initializers.map((final i) => i.accept(this) as cb.Code),
              )
              ..annotations.addAll(
                spec.annotations.map(
                  (final a) => a.accept(this) as cb.Expression,
                ),
              )
              ..optionalParameters.addAll(
                spec.optionalParameters.map(
                  (final p) => p.accept(this) as cb.Parameter,
                ),
              )
              ..requiredParameters.addAll(
                spec.requiredParameters.map(
                  (final p) => p.accept(this) as cb.Parameter,
                ),
              ),
          )
          as cb.Spec;

  @override
  cb.Spec visitInvoke(final DpugInvokeSpec spec, [final cb.Spec? context]) {
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
    spec.namedArguments.forEach((final k, final v) {
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
  cb.Spec visitLiteral(final DpugLiteralSpec spec, [final cb.Spec? context]) {
    final value = spec.value;
    if (value is String) return cb.literalString(value);
    if (value is num) return cb.literalNum(value);
    if (value is bool) return cb.literalBool(value);
    return cb.Code("'$value'");
  }

  @override
  cb.Spec visitReferenceExpression(
    final DpugReferenceExpressionSpec spec, [
    final cb.Spec? context,
  ]) => cb.CodeExpression(cb.Code(spec.name));

  @override
  cb.Spec visitBoolLiteral(
    final DpugBoolLiteralSpec spec, [
    final cb.Spec? context,
  ]) => cb.literalBool(spec.value);

  @override
  cb.Spec visitNumLiteral(
    final DpugNumLiteralSpec spec, [
    final cb.Spec? context,
  ]) => cb.literalNum(spec.value);
}
