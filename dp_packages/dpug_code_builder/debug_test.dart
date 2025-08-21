import 'package:dpug_code_builder/dpug_code_builder.dart';

void main() {
  final classSpec = DpugClassSpec(
    name: 'Counter',
    stateFields: [
      DpugStateFieldSpec(
        name: 'count',
        type: 'int',
        annotation: const DpugAnnotationSpec(name: 'listen'),
        initializer: DpugExpressionSpec.reference('0'),
      ),
    ],
    methods: [
      DpugMethodSpec.getter(
        name: 'build',
        returnType: 'Widget',
        body: DpugCodeSpec(r'return Text("Count: $count");'),
      ),
    ],
  );

  final generator = DartWidgetCodeGenerator();
  final code = generator.generateStatefulWidget(classSpec);

  print('Generated code:');
  print(code);
  print('\n--- Checking for late keyword ---');
  print('Contains "late int _count": ${code.contains('late int _count')}');
  print('Contains "late": ${code.contains('late')}');
}
