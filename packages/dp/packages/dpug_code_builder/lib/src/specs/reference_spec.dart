import '../visitors/visitor.dart';
import 'spec.dart';

/// For type references (extends, implements, etc.)
class DpugReferenceSpec implements DpugSpec {
  final String symbol;
  final String? url;

  const DpugReferenceSpec(this.symbol, [this.url]);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitReference(this, context);
}
