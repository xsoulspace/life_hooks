import 'package:code_builder/code_builder.dart' as cb;

import 'builders/builders.dart';
import 'specs/specs.dart';
import 'visitors/visitors.dart';

class Dpug {
  static DpugClassBuilder classBuilder() => DpugClassBuilder();
  static DpugWidgetBuilder widgetBuilder() => DpugWidgetBuilder();

  static String emitDpug(DpugSpec spec) {
    final emitter = DpugEmitter();
    return spec.accept(emitter);
  }

  static DpugSpec? fromDart(cb.Spec dartSpec) {
    final visitor = const DartToDpugVisitor();
    return dartSpec.accept(visitor);
  }

  static cb.Spec toDart(DpugSpec dpugSpec) {
    final visitor = DpugToDartVisitor();
    return dpugSpec.accept(visitor);
  }

  static String dartToDpugString(cb.Spec dartSpec) {
    final dpugSpec = fromDart(dartSpec);
    return dpugSpec != null ? emitDpug(dpugSpec) : '';
  }

  static String dpugToDartString(DpugSpec dpugSpec) {
    final dartSpec = toDart(dpugSpec);
    final emitter = cb.DartEmitter();
    return dartSpec.accept(emitter).toString();
  }
}
