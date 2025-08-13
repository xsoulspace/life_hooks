import '../visitors/visitor.dart';

abstract class DpugSpec {
  DpugSpec();
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]);
}
