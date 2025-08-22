import 'package:dpug_cli/dpug_cli.dart';
import 'package:test/test.dart';

void main() {
  group('DpugCliUtils', () {
    test('printSuccess should not throw', () {
      expect(() => DpugCliUtils.printSuccess('Test message'), returnsNormally);
    });

    test('printError should not throw', () {
      expect(() => DpugCliUtils.printError('Test error'), returnsNormally);
    });

    test('printInfo should not throw', () {
      expect(() => DpugCliUtils.printInfo('Test info'), returnsNormally);
    });
  });
}
