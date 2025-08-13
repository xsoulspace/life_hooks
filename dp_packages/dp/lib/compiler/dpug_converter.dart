import 'package:source_span/source_span.dart';

import 'ast_builder.dart';
import 'ast_to_dart.dart';
import 'dart_to_dpug.dart';
import 'lexer.dart';

/// Provides conversion between DPug text and Dart code using DPug IR.
class DpugConverter {
  /// Convert DPug source string to formatted Dart code.
  String dpugToDart(String dpugCode) {
    final SourceFile file = SourceFile.fromString(dpugCode);
    try {
      final List<Token> tokens = Lexer(dpugCode).tokenize();
      final ASTNode ast = ASTBuilder(tokens).build();
      final String out = AstToDart(file).generate(ast);
      return out;
    } on Object catch (e) {
      throw _ConversionException('DpugToDartError', e.toString(), file, 0, 0);
    }
  }

  /// Convert Dart source string to DPug string using analyzer -> IR -> emitter.
  String dartToDpug(String dartCode) {
    final SourceFile file = SourceFile.fromString(dartCode);
    try {
      final String dpug = DartToDpug(file).convert(dartCode);
      return dpug;
    } on Object catch (e) {
      throw _ConversionException('DartToDpugError', e.toString(), file, 0, 0);
    }
  }
}

/// Internal typed exception that carries a span description.
class _ConversionException implements Exception {
  final String type;
  final String message;
  final String span;
  _ConversionException(
      this.type, this.message, SourceFile file, int start, int end)
      : span =
            '${file.getLine(start) + 1}:${file.getColumn(start) + 1}..${file.getLine(end) + 1}:${file.getColumn(end) + 1}';

  @override
  String toString() => '$type: $message ($span)';
}
