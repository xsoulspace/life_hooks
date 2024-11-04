import 'ast_builder.dart';
import 'source_mapper.dart';

class DartGenerator {
  final DPugNode ast;
  final SourceMapper sourceMapper;
  final StringBuffer _buffer = StringBuffer();
  int _currentOffset = 0;

  DartGenerator(this.ast, this.sourceMapper);

  String generate() {
    _generateImports();
    _generateClass();
    return _buffer.toString();
  }

  void _generateImports() {
    _write('''
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
''', ast.location);
  }

  void _generateClass() {
    final classNode = ast.children.firstWhere(
      (node) => node.nodeType == NodeType.classDeclaration,
      orElse: () => throw Exception('No class declaration found'),
    );

    final className = classNode.value!;
    final isStateful = _hasStateVariables(classNode);

    if (isStateful) {
      _generateStatefulWidget(className, classNode);
    } else {
      _generateStatelessWidget(className, classNode);
    }
  }

  bool _hasStateVariables(DPugNode classNode) {
    return classNode.children.any((node) =>
        node.nodeType == NodeType.stateDeclaration ||
        (node.nodeType == NodeType.methodDeclaration &&
            node.type == 'annotation' &&
            node.value == 'state'));
  }

  void _generateStatefulWidget(String className, DPugNode node) {
    _write('''
class $className extends StatefulWidget {
  const $className({super.key});
  
  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
''', node.location);

    _generateListenVariables(node);
    _generateStateVariables(node);
    _generateBuildMethod(node);

    _write('}\n', node.location);
  }

  void _generateListenVariables(DPugNode node) {
    for (final child in node.children) {
      if (child.nodeType == NodeType.listenVariable) {
        final type = child.properties['type'] as String;
        final name = child.value!;
        final initialValue = child.properties['initialValue'];

        _write('  $type _$name = $initialValue;\n', child.location);
      }
    }
  }

  void _generateStatelessWidget(String className, DPugNode node) {
    _write('''
class $className extends StatelessWidget {
  const $className({super.key});

''', node.location);

    _generateBuildMethod(node);
    _write('\n}\n', node.location);
  }

  void _generateStateVariables(DPugNode classNode) {
    for (final child in classNode.children) {
      if (child.nodeType == NodeType.stateDeclaration) {
        final type = child.properties['type'] as String;
        final name = child.value!;
        _write('  $type _$name;\n', child.location);
      } else if (child.nodeType == NodeType.methodDeclaration &&
          child.type == 'annotation' &&
          child.value == 'state') {
        final stateNode = child.children.first;
        final type = stateNode.properties['type'] as String;
        final name = stateNode.value!;
        _write('''
  late final ValueNotifier<$type> _$name = ValueNotifier<$type>(${stateNode.properties['initialValue']});

  @override
  void dispose() {
    _$name.dispose();
    super.dispose();
  }
''', child.location);
      }
    }
  }

  void _generateBuildMethod(DPugNode classNode) {
    _write('''
  @override
  Widget build(BuildContext context) {
''', classNode.location);

    final buildBody = classNode.children.firstWhere(
      (node) => node.nodeType == NodeType.widgetDeclaration,
      orElse: () =>
          throw Exception('No widget declaration found in build method'),
    );

    _generateWidget(buildBody);
    _write('  }\n', classNode.location);
  }

  void _generateWidget(DPugNode node) {
    final indent = '    ';
    _write('$indent${node.type}(\n', node.location);

    // Generate properties
    for (final entry in node.properties.entries) {
      _write('$indent  ${entry.key}: ${_generateExpression(entry.value)},\n',
          node.location);
    }

    // Generate children if any
    if (node.children.isNotEmpty) {
      if (node.children.length == 1) {
        _write('$indent  child: ', node.location);
        _generateWidget(node.children.first);
      } else {
        _write('$indent  children: [\n', node.location);
        for (final child in node.children) {
          _generateWidget(child);
          _write(',\n', node.location);
        }
        _write('$indent  ],\n', node.location);
      }
    }

    _write('$indent)', node.location);

    // Handle cascade operations
    for (final cascade in node.children
        .where((n) => n.nodeType == NodeType.cascadeOperation)) {
      _write('\n$indent  ', node.location);
      _generateCascadeOperation(cascade);
    }
  }

  void _generateCascadeOperation(DPugNode node) {
    final method = node.children.first;
    _write('..${method.value}(', node.location);
    _generateArguments(method.children);
    _write(')', node.location);
  }

  void _generateArguments(List<DPugNode> args) {
    for (var i = 0; i < args.length; i++) {
      if (i > 0) _write(', ', args[i].location);
      _write(_generateExpression(args[i]), args[i].location);
    }
  }

  String _generateExpression(DPugNode node) {
    switch (node.nodeType) {
      case NodeType.expression:
        if (node.type == 'String') {
          return '"${node.value}"';
        }
        return node.value!;

      case NodeType.arrowFunction:
        return _generateArrowFunction(node);

      case NodeType.blockStatement:
        return _generateBlockStatement(node);

      case NodeType.methodCall:
        return _generateMethodCall(node);

      default:
        return node.value ?? '';
    }
  }

  String _generateArrowFunction(DPugNode node) {
    final params = node.children.take(node.children.length - 1);
    final body = node.children.last;

    final paramList = params.map((p) => p.value).join(', ');
    final bodyCode = _generateExpression(body);

    return '($paramList) => $bodyCode';
  }

  String _generateBlockStatement(DPugNode node) {
    final buffer = StringBuffer('{');
    for (final statement in node.children) {
      buffer.write('\n      ');
      buffer.write(_generateStatement(statement));
      buffer.write(';');
    }
    buffer.write('\n    }');
    return buffer.toString();
  }

  String _generateStatement(DPugNode node) {
    switch (node.nodeType) {
      case NodeType.assignment:
        return '${node.value} = ${_generateExpression(node.children.first)}';
      case NodeType.methodCall:
        return _generateMethodCall(node);
      default:
        return _generateExpression(node);
    }
  }

  String _generateMethodCall(DPugNode node) {
    final buffer = StringBuffer(node.value ?? '');
    buffer.write('(');
    _generateArguments(node.children);
    buffer.write(')');
    return buffer.toString();
  }

  void _write(String content, SourceLocation original) {
    sourceMapper.addMapping(_currentOffset, original, length: content.length);
    _buffer.write(content);
    _currentOffset += content.length;
  }
}
