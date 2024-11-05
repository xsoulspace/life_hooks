import '../visitors/visitor.dart';
import 'spec.dart';

/// For type references (extends, implements, etc.)
class DpugReferenceSpec extends DpugSpec {
  final String symbol;
  final String? url;

  const DpugReferenceSpec(this.symbol, [this.url]);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitReference(this);
}
