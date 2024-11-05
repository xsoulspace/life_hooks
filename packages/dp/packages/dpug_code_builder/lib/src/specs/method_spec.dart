import 'package:dpug/dpug.dart';

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

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitMethod(this);
}
