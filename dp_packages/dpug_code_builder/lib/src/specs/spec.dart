import '../visitors/visitor.dart';

// ignore: one_member_abstracts
abstract class DpugSpec {
  DpugSpec();
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]);
}
