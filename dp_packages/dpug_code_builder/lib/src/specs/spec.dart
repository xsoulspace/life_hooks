import '../visitors/visitor.dart';

// ignore: one_member_abstracts
abstract class DpugSpec {
  DpugSpec();

  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]);

  /// Get the string representation of this spec
  String get code;
}
