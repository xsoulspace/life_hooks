import 'ast_builder.dart';
import 'dart_generator.dart';
import 'lexer.dart';

class DpugConverter {
  final _lexer = Lexer('');
  final _generator = DartGenerator();

  String dpugToDart(String dpugCode) {
    final tokens = _lexer.tokenize();
    final ast = ASTBuilder(tokens).build();
    return _generator.generate(ast);
  }

  String dartToDpug(String dartCode) {
    // This will be implemented later when we add dart->dpug conversion
    throw UnimplementedError('Dart to DartPug conversion not yet implemented');
  }
}
