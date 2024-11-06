import '../visitors/visitors.dart';
import 'parameter_spec.dart';
import 'spec.dart';

class DpugMethodSpec extends DpugSpec {
  final String name;
  final String returnType;
  final List<DpugParameterSpec> parameters;
  final DpugSpec body;
  final bool isGetter;

  const DpugMethodSpec({
    required this.name,
    required this.returnType,
    this.parameters = const [],
    required this.body,
    this.isGetter = false,
  });

  factory DpugMethodSpec.getter({
    required String name,
    required String returnType,
    required DpugSpec body,
  }) =>
      DpugMethodSpec(
          name: name, returnType: returnType, body: body, isGetter: true);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitMethod(this, context);
}
