import '../visitors/visitors.dart';
import 'spec.dart';

class DpugCodeSpec extends DpugSpec {
  DpugCodeSpec(this.value);
  final String value;

  @override
  R accept<R>(covariant final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitCode(this, context);

  @override
  String get code => value;
}
