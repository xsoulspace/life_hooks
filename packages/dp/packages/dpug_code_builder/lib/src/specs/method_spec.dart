import '../visitors/visitors.dart';
import 'specs.dart';

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

  factory DpugMethodSpec.build(DpugWidgetSpec widget) => DpugMethodSpec(
        name: 'build',
        returnType: 'Widget',
        parameters: [
          DpugParameterSpec(
            name: 'context',
            type: 'BuildContext',
          ),
        ],
        body: widget,
      );

  factory DpugMethodSpec.getter({
    required String name,
    required String returnType,
    required DpugSpec body,
  }) =>
      DpugMethodSpec(
        name: name,
        returnType: returnType,
        parameters: const [],
        body: body,
        isGetter: true,
      );

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitMethod(this);
}

class DpugParameterSpec extends DpugSpec {
  final String name;
  final String type;
  final bool isRequired;
  final bool isNamed;
  final DpugExpressionSpec? defaultValue;

  const DpugParameterSpec({
    required this.name,
    required this.type,
    this.isRequired = false,
    this.isNamed = false,
    this.defaultValue,
  });

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitParameter(this);
}
