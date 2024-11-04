import 'builders/builders.dart';
import 'specs/specs.dart';
import 'visitors/visitors.dart';

class Dpug {
  static DpugClassBuilder classBuilder() => DpugClassBuilder();
  static DpugWidgetBuilder widgetBuilder() => DpugWidgetBuilder();

  static String generateDart(DpugSpec spec) {
    final visitor = DartGeneratingVisitor();
    return spec.accept(visitor).toString();
  }

  static String generateDpug(DpugSpec spec) {
    final visitor = DpugGeneratingVisitor();
    return spec.accept(visitor);
  }
}
