import '../visitors/visitor.dart';
import 'spec.dart';

/// For type references (extends, implements, etc.)
class DpugReferenceSpec implements DpugSpec {
  const DpugReferenceSpec(this.symbol, [this.url]);
  final String symbol;
  final String? url;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitReference(this, context);

  @override
  String get code => symbol;
}
