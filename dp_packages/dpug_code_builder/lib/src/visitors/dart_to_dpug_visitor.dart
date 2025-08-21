// !DO NOT REMOVE IMPORT!
import '../dart_imports.dart';
import '../specs/specs.dart';

class DartToDpugSpecVisitor
    implements
        SpecVisitor<DpugSpec?>,
        ExpressionVisitor<DpugSpec?>,
        CodeVisitor<DpugSpec?> {
  const DartToDpugSpecVisitor();

  @override
  DpugSpec? visitClass(final Class spec, [final DpugSpec? context]) {
    // Convert class with all its members
    final annotations = spec.annotations
        .map((final a) => DpugAnnotationSpec(name: a.toString()))
        .toList();

    final fields = spec.fields
        .map((final f) => f.accept(this, context))
        .whereType<DpugStateFieldSpec>()
        .toList();

    final methods = spec.methods
        .map((final m) => m.accept(this, context))
        .whereType<DpugMethodSpec>()
        .toList();

    // Heuristic: treat any class with a 'build' method returning Widget as stateful
    final hasBuild = spec.methods.any((final m) => (m.name ?? '') == 'build');
    if (hasBuild) {
      annotations.insert(0, DpugAnnotationSpec.stateful());
    }

    return DpugClassSpec(
      name: spec.name,
      annotations: annotations,
      stateFields: fields,
      methods: methods,
    );
  }

  @override
  DpugSpec? visitField(final Field spec, [final DpugSpec? context]) {
    if (spec.type != null) {
      final initializer = spec.assignment?.accept(this);
      return DpugStateFieldSpec(
        name: spec.name,
        type: spec.type.toString(),
        annotation: DpugAnnotationSpec.state(),
        initializer: initializer is DpugExpressionSpec ? initializer : null,
      );
    }
    return null;
  }

  @override
  DpugSpec? visitMethod(final Method spec, [final DpugSpec? context]) {
    // Detect build method to match tests: 'Widget get build =>' style
    final isBuild = (spec.name ?? '') == 'build';
    final returnType = spec.returns?.toString() ?? 'dynamic';
    final body = spec.body?.accept(this) ?? DpugCodeSpec('');

    if (isBuild && body is DpugExpressionSpec) {
      return DpugMethodSpec.getter(
        name: 'build',
        returnType: 'Widget',
        body: body,
      );
    }

    return DpugMethodSpec(
      name: spec.name ?? '',
      returnType: returnType,
      parameters: spec.requiredParameters
          .map(
            (final p) => DpugParameterSpec(
              name: p.name,
              type: p.type != null
                  ? DpugReferenceSpec(p.type!.toString())
                  : null,
              isRequired: true,
            ),
          )
          .toList(),
      body: body,
      isGetter: spec.type == MethodType.getter,
    );
  }

  // Implement other required SpecVisitor methods
  @override
  DpugSpec? visitDirective(final Directive spec, [final DpugSpec? context]) =>
      null;

  @override
  DpugSpec? visitEnum(final Enum spec, [final DpugSpec? context]) => null;

  @override
  DpugSpec? visitConstructor(
    final Constructor spec,
    final String clazz, [
    final DpugSpec? context,
  ]) => null;

  @override
  DpugSpec? visitExtension(final Extension spec, [final DpugSpec? context]) =>
      null;

  @override
  DpugSpec? visitExtensionType(
    final ExtensionType spec, [
    final DpugSpec? context,
  ]) => null;

  @override
  DpugSpec? visitFunctionType(
    final FunctionType spec, [
    final DpugSpec? context,
  ]) => null;

  @override
  DpugSpec? visitLibrary(final Library spec, [final DpugSpec? context]) => null;

  @override
  DpugSpec? visitMixin(final Mixin spec, [final DpugSpec? context]) => null;

  @override
  DpugSpec? visitRecordType(final RecordType spec, [final DpugSpec? context]) =>
      null;

  @override
  DpugSpec? visitReference(final Reference spec, [final DpugSpec? context]) {
    final sym = spec.symbol ?? '';
    if (sym == 'Widget') {
      // In DPUG strings we want 'Widget' unwrapped, not a Reference dump
      return const DpugReferenceExpressionSpec('Widget');
    }
    return DpugReferenceSpec(sym);
  }

  @override
  DpugSpec? visitSpec(final Spec spec, [final DpugSpec? context]) =>
      spec.accept(this, context);

  @override
  DpugSpec? visitType(final TypeReference spec, [final DpugSpec? context]) =>
      DpugReferenceSpec(spec.toString());

  @override
  DpugSpec? visitTypeParameters(
    final Iterable<Reference> specs, [
    final DpugSpec? context,
  ]) => DpugReferenceSpec(specs.map((final s) => s.toString()).join(', '));

  @override
  DpugSpec? visitTypeDef(final TypeDef spec, [final DpugSpec? context]) => null;

  // CodeVisitor methods
  @override
  DpugSpec? visitBlock(final Block code, [final DpugSpec? context]) {
    final text = code.toString();
    final trimmed = text.trim();
    final withoutReturn = trimmed.startsWith('return ')
        ? trimmed.substring('return '.length)
        : trimmed;
    final withoutSemicolon = withoutReturn.endsWith(';')
        ? withoutReturn.substring(0, withoutReturn.length - 1)
        : withoutReturn;
    return _parseCodeExpression(withoutSemicolon.trim());
  }

  @override
  DpugSpec? visitScopedCode(final ScopedCode code, [final DpugSpec? context]) {
    final text = code.toString().trim();
    final withoutReturn = text.startsWith('return ')
        ? text.substring('return '.length)
        : text;
    final withoutSemicolon = withoutReturn.endsWith(';')
        ? withoutReturn.substring(0, withoutReturn.length - 1)
        : withoutReturn;
    return _parseCodeExpression(withoutSemicolon.trim());
  }

  @override
  DpugSpec? visitStaticCode(final StaticCode code, [final DpugSpec? context]) {
    final text = code.toString().trim();
    final withoutReturn = text.startsWith('return ')
        ? text.substring('return '.length)
        : text;
    final withoutSemicolon = withoutReturn.endsWith(';')
        ? withoutReturn.substring(0, withoutReturn.length - 1)
        : withoutReturn;
    return _parseCodeExpression(withoutSemicolon.trim());
  }

  /// Helper method to parse code expressions into appropriate specs
  DpugSpec? _parseCodeExpression(final String code) {
    // Handle widget constructors and complex expressions
    if (code.contains('(') && !code.contains('=>')) {
      // This might be a widget constructor or method call
      final trimmed = code.trim();

      // Check for common widget patterns
      if (trimmed.startsWith('Container(') ||
          trimmed.startsWith('Column(') ||
          trimmed.startsWith('Row(') ||
          trimmed.startsWith('Text(') ||
          trimmed.startsWith('ElevatedButton(') ||
          trimmed.startsWith('TextFormField(')) {
        // Try to manually create a DpugWidgetSpec for known patterns
        return _createWidgetFromString(trimmed);
      }
    }
    return DpugReferenceExpressionSpec(code);
  }

  /// Helper method to create a widget spec from a string representation
  DpugSpec? _createWidgetFromString(final String code) {
    // For now, return as reference - we'll enhance this later
    // The real fix needs proper parsing of the constructor arguments
    return DpugReferenceExpressionSpec(code);
  }

  // ExpressionVisitor methods
  @override
  DpugSpec? visitBinaryExpression(
    final BinaryExpression expression, [
    final DpugSpec? context,
  ]) {
    final left = expression.left.accept(this);
    final right = expression.right.accept(this);

    if (left is! DpugExpressionSpec || right is! DpugExpressionSpec) {
      return DpugReferenceSpec(expression.toString());
    }

    return DpugBinarySpec(expression.operator, left, right);
  }

  @override
  DpugSpec? visitInvokeExpression(
    final InvokeExpression expression, [
    final DpugSpec? context,
  ]) {
    final args = <DpugExpressionSpec>[];
    final namedArgs = <String, DpugExpressionSpec>{};

    // Handle positional arguments
    for (final arg in expression.positionalArguments) {
      final converted = arg.accept(this);
      if (converted is DpugExpressionSpec) {
        args.add(converted);
      } else {
        args.add(DpugReferenceExpressionSpec(arg.toString()));
      }
    }

    // Handle named arguments
    for (final entry in expression.namedArguments.entries) {
      final converted = entry.value.accept(this);
      if (converted is DpugExpressionSpec) {
        namedArgs[entry.key] = converted;
      } else {
        namedArgs[entry.key] = DpugReferenceExpressionSpec(
          entry.value.toString(),
        );
      }
    }

    // Check if this is a widget constructor
    final target = expression.target.accept(this);
    if (target is DpugReferenceExpressionSpec) {
      final widgetName = target.name;
      // Widget names typically start with capital letters
      if (widgetName.isNotEmpty &&
          widgetName[0].toUpperCase() == widgetName[0]) {
        // Convert to DpugWidgetSpec for proper DPug formatting
        final children = <DpugWidgetSpec>[];

        // Handle special cases like 'child' and 'children'
        if (namedArgs.containsKey('child')) {
          final childExpr = namedArgs['child'];
          if (childExpr != null) {
            final childWidget = _expressionToWidget(childExpr);
            if (childWidget != null) {
              children.add(childWidget);
            }
          }
          namedArgs.remove('child');
        }

        if (namedArgs.containsKey('children')) {
          final childrenExpr = namedArgs['children'];
          if (childrenExpr != null) {
            final childList = _expressionToChildrenList(childrenExpr);
            children.addAll(childList);
          }
          namedArgs.remove('children');
        }

        return DpugWidgetSpec(
          name: widgetName,
          children: children,
          properties: namedArgs,
          positionalArgs: args,
        );
      }
    }

    return DpugInvokeSpec(
      target: expression.target.accept(this)! as DpugExpressionSpec,
      positionedArguments: args,
      isConst: expression.isConst,
      name: expression.name,
      typeArguments: expression.typeArguments
          .map((final t) => t.accept(this)! as DpugReferenceSpec)
          .toList(),
      namedArguments: namedArgs,
    );
  }

  @override
  DpugSpec? visitLiteralExpression(
    final LiteralExpression expression, [
    final DpugSpec? context,
  ]) => DpugStringLiteralSpec(expression.literal);

  @override
  DpugSpec? visitLiteralListExpression(
    final LiteralListExpression expression, [
    final DpugSpec? context,
  ]) {
    final values = <DpugExpressionSpec>[];

    for (final value in expression.values) {
      if (value == null) {
        values.add(const DpugStringLiteralSpec('null'));
        continue;
      }

      // Handle different literal types
      if (value is bool) {
        values.add(DpugBoolLiteralSpec(value));
      } else if (value is num) {
        values.add(DpugNumLiteralSpec(value));
      } else if (value is String) {
        values.add(DpugStringLiteralSpec(value));
      } else if (value is Expression) {
        final converted = value.accept(this);
        if (converted is DpugExpressionSpec) {
          values.add(converted);
        } else {
          values.add(value.accept(this)! as DpugExpressionSpec);
        }
      } else {
        // For unsupported types, convert to string reference
        values.add(DpugStringLiteralSpec(value.toString()));
      }
    }

    return DpugListLiteralSpec(values);
  }

  @override
  DpugSpec? visitClosureExpression(
    final ClosureExpression expression, [
    final DpugSpec? context,
  ]) => DpugClosureExpressionSpec(
    expression.method.accept(this)! as DpugMethodSpec,
  );

  @override
  DpugSpec? visitCodeExpression(
    final CodeExpression expression, [
    final DpugSpec? context,
  ]) => DpugReferenceExpressionSpec(expression.code.toString().trim());

  @override
  DpugSpec? visitLiteralMapExpression(
    final LiteralMapExpression expression, [
    final DpugSpec? context,
  ]) => DpugReferenceSpec(expression.toString());

  @override
  DpugSpec? visitLiteralRecordExpression(
    final LiteralRecordExpression expression, [
    final DpugSpec? context,
  ]) => DpugReferenceSpec(expression.toString());

  @override
  DpugSpec? visitParenthesizedExpression(
    final ParenthesizedExpression expression, [
    final DpugSpec? context,
  ]) {
    return expression.expression.accept(
      this,
    ); // ignore: invalid_use_of_visible_for_overriding_member
  }

  @override
  DpugSpec? visitToCodeExpression(
    final ToCodeExpression expression, [
    final DpugSpec? context,
  ]) => DpugReferenceSpec(expression.toString());

  @override
  DpugSpec? visitLiteralSetExpression(
    final LiteralSetExpression expression, [
    final DpugSpec? context,
  ]) => DpugReferenceSpec(expression.toString());

  @override
  DpugSpec? visitAnnotation(final Expression spec, [final DpugSpec? context]) {
    if (spec is CodeExpression) {
      return DpugAnnotationSpec(name: spec.code.toString());
    }
    return DpugAnnotationSpec(name: spec.toString());
  }

  /// Helper method to convert an expression to a widget spec
  DpugWidgetSpec? _expressionToWidget(final DpugExpressionSpec expr) {
    if (expr is DpugWidgetExpressionSpec) {
      return expr.builder.build();
    }
    return null;
  }

  /// Helper method to convert a children list expression to widget specs
  List<DpugWidgetSpec> _expressionToChildrenList(
    final DpugExpressionSpec expr,
  ) {
    if (expr is DpugListLiteralSpec) {
      return expr.values
          .map(_expressionToWidget)
          .whereType<DpugWidgetSpec>()
          .toList();
    }
    return [];
  }
}
