import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  test('Debug Column conversion', () {
    final converter = DpugConverter();
    final simpleDart = '''
class TestWidget extends StatefulWidget {
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hello')
      ]
    );
  }
}
''';

    final result = converter.dartToDpug(simpleDart);
    print('Result: $result');
  });
}
