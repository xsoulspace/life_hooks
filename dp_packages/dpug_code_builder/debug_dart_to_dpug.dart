import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/dpug_code_builder.dart';

void main() {
  final dartMethod = cb.Method(
    (final b) => b
      ..name = 'build'
      ..returns = cb.refer('Widget')
      ..body = const cb.Code('''
      return Container(
        padding: EdgeInsets.all(16),
        child: Text('Hello'),
      );
    '''),
  );

  print('Original Dart method:');
  print(dartMethod);
  print('\n--- Converting to DPug ---');

  final dpugSpec = Dpug.fromDart(dartMethod);
  print('DPug spec: $dpugSpec');

  if (dpugSpec != null) {
    final dpugString = Dpug.emitDpug(dpugSpec);
    print('DPug string:');
    print(dpugString);
  } else {
    print('DPug spec is null');
  }
}
