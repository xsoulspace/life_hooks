import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:dpug_analyzer/compiler/ast_builder.dart';
import 'package:dpug_analyzer/compiler/dart_generator.dart';
import 'package:dpug_analyzer/compiler/lexer.dart';
import 'package:dpug_analyzer/compiler/source_mapper.dart';

class DPugParser implements Builder {
  final Map<String, ClassDeclaration> _dartClasses = {};
  final Map<String, ImportDirective> _imports = {};
  final SourceMapper sourceMapper = SourceMapper();
  final ErrorCollector _errors = ErrorCollector();

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dpug': ['.dpug.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = await buildStep.readAsString(buildStep.inputId);
    final output = await processDPugFile(input, buildStep);

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension('.dpug.dart'),
      output,
    );
  }

  Future<String> processDPugFile(String input, BuildStep? buildStep) async {
    try {
      // 1. Tokenize
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      // 2. Build AST
      final astBuilder = DPugASTBuilder(tokens);
      final ast = astBuilder.buildAST();

      // 3. Generate Dart code
      final generator = DartGenerator(ast, sourceMapper);
      return generator.generate();
    } catch (e, stackTrace) {
      if (e is ParserError) {
        _errors.addError(e.message, e.location);
      }
      rethrow;
    }
  }

  void validateAST(DPugNode ast) {
    // Validate class declarations
    for (final node in ast.children) {
      if (node.nodeType == NodeType.classDeclaration) {
        _validateClassDeclaration(node);
      }
    }
  }

  void _validateClassDeclaration(DPugNode node) {
    // Ensure class has a build method
    final hasBuildMethod = node.children.any(
      (child) =>
          child.nodeType == NodeType.methodDeclaration &&
          child.value == 'build',
    );

    if (!hasBuildMethod) {
      _errors.addError(
        'Class must have a build method',
        node.location,
      );
    }

    // Validate state variables
    for (final child in node.children) {
      if (child.nodeType == NodeType.stateDeclaration ||
          child.nodeType == NodeType.listenVariable) {
        _validateStateVariable(child);
      }
    }
  }

  void _validateStateVariable(DPugNode node) {
    if (!node.properties.containsKey('type')) {
      _errors.addError(
        'State variable must have a type',
        node.location,
      );
    }

    if (!node.properties.containsKey('initialValue')) {
      _errors.addError(
        'State variable must have an initial value',
        node.location,
      );
    }
  }
}

class ParserError extends Error {
  final String message;
  final SourceLocation location;

  ParserError(this.message, this.location);

  @override
  String toString() =>
      'Error at line ${location.line}, column ${location.column}: $message';
}

class ErrorCollector {
  final List<ParserError> errors = [];

  void addError(String message, SourceLocation location) {
    errors.add(ParserError(message, location));
  }

  bool get hasErrors => errors.isNotEmpty;

  void throwIfErrors() {
    if (hasErrors) {
      throw errors.first;
    }
  }
}
