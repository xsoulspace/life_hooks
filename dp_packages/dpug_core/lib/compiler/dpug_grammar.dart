import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

/// PetitParser-based grammar for DPug syntax
class DPugGrammar extends GrammarDefinition {
  // Helper to create proper FileSpans from source
  FileSpan _createSpan(final String source, final int start, final int end) {
    final file = SourceFile.fromString(source);
    return file.span(start, end);
  }

  @override
  Parser start() => ref(document).end();

  // Document structure
  Parser document() => ref(classDefinition).or(ref(widgetTree));

  // Annotations
  Parser annotations() => ref(annotation).star().map((final values) => values);

  // Class definitions
  Parser classDefinition() =>
      (ref(annotations).optional() &
              ref(keyword, 'class') &
              ref(identifier) &
              ref(colon) &
              ref(classBody).optional())
          .map((final values) => values);

  Parser classBody() => (ref(indent) & ref(classMember).star() & ref(dedent))
      .map((final values) => values[1]);

  Parser classMember() => ref(stateField).or(ref(buildMethod));

  Parser stateField() =>
      (ref(annotation) &
              ref(identifier) &
              ref(typeAnnotation).optional() &
              ref(equals).optional() &
              ref(expression).optional())
          .map((final values) => values);

  Parser buildMethod() =>
      (ref(keyword, 'Widget') &
              ref(keyword, 'get') &
              ref(identifier) & // Should be 'build'
              ref(operator, '=>') &
              ref(widgetTree))
          .map((final values) => values);

  // Widget trees
  Parser widgetTree() =>
      (ref(widgetNode) &
              (ref(indent) & ref(widgetChildren).star() & ref(dedent))
                  .optional())
          .map((final values) => values);

  Parser widgetChildren() =>
      ref(widgetNode).or(ref(property)).or(ref(positionalArg));

  Parser widgetNode() =>
      (ref(identifier) & ref(positionalArgs).optional() & ref(newline)).map(
        (final values) => values,
      );

  // Properties and arguments
  Parser property() =>
      (ref(identifier) & ref(colon) & ref(expression) & ref(newline)).map(
        (final values) => MapEntry(values[0], values[2]),
      );

  Parser positionalArgs() =>
      (ref(lparen) & ref(expression).starSeparated(ref(comma)) & ref(rparen))
          .map((final values) => values[1]);

  Parser positionalArg() =>
      (ref(operator, '..') &
              ref(stringLiteral).or(ref(expression)) &
              ref(newline))
          .map((final values) => values[1]);

  // Expressions
  Parser expression() => ref(stringLiteral).or(
    ref(numberLiteral).or(
      ref(
        booleanLiteral,
      ).or(ref(identifier).or(ref(closure).or(ref(assignment)))),
    ),
  );

  Parser assignment() => (ref(identifier) & ref(equals) & ref(expression)).map(
    (final values) => values,
  );

  Parser closure() =>
      (ref(lparen) & ref(rparen) & ref(operator, '=>') & ref(expression)).map(
        (final values) => values,
      );

  // Literals
  Parser stringLiteral() =>
      (ref(quote) & any().starLazy(ref(quote)) & ref(quote)).flatten().map(
        (final value) => value,
      );

  Parser numberLiteral() =>
      (digit().plus() & (char('.') & digit().plus()).optional()).flatten().map(
        (final value) => value,
      );

  Parser booleanLiteral() =>
      (string('true') | string('false')).map((final value) => value);

  // Basic tokens
  Parser identifier() =>
      (letter() & (letter() | digit() | char('_') | char('.')).star())
          .flatten();

  Parser annotation() => (char('@') & ref(identifier)).flatten();

  Parser typeAnnotation() =>
      (ref(colon) & ref(identifier)).map((final values) => values[1]);

  // Keywords and operators
  Parser keyword(final String value) => string(value).trim();
  Parser operator(final String value) => string(value).trim();

  // Symbols
  Parser colon() => char(':').trim();
  Parser equals() => char('=').trim();
  Parser lparen() => char('(').trim();
  Parser rparen() => char(')').trim();
  Parser comma() => char(',').trim();
  Parser quote() => char('"') | char("'");

  // Indentation (simplified)
  Parser indent() => string('  ') | string('\t'); // 2 spaces or tab
  Parser dedent() => ref(newline);

  // Whitespace and newlines
  Parser newline() => char('\n') | string('\r\n') | char('\r');
  Parser whitespace() => char(' ') | char('\t');

  // Utility
  Parser<List<T>> separatedBy<T>(
    final Parser<T> element,
    final Parser separator,
  ) => (element & (separator & element).star()).map(
    (final values) => [values[0], ...values[1].map((final pair) => pair[1])],
  );
}
