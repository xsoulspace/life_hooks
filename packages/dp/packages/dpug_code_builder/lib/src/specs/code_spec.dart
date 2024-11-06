import '../visitors/visitors.dart';
import 'spec.dart';

class DpugCodeSpec extends DpugSpec {
  final String value;

  DpugCodeSpec(this.value);

  @override
  R accept<R>(covariant DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitCode(this, context);
}
