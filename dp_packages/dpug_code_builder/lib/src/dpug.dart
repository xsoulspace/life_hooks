import 'package:code_builder/code_builder.dart' as cb;

import 'builders/builders.dart';
import 'specs/specs.dart';
import 'visitors/visitors.dart';

// ignore: avoid_classes_with_only_static_members
class Dpug {
  static DpugClassBuilder classBuilder() => DpugClassBuilder();
  static DpugWidgetBuilder widgetBuilder() => DpugWidgetBuilder();

  static String emitDpug(final DpugSpec spec) {
    final emitter = DpugEmitter();
    return spec.accept(emitter);
  }

  static DpugSpec? fromDart(final cb.Spec dartSpec) {
    final visitor = DartToDpugSpecVisitor();
    return dartSpec.accept(visitor);
  }

  static cb.Spec toDart(final DpugSpec dpugSpec) {
    final visitor = DpugToDartSpecVisitor();
    return dpugSpec.accept(visitor);
  }

  static String dartToDpugString(final cb.Spec dartSpec) {
    final dpugSpec = fromDart(dartSpec);
    return dpugSpec != null ? emitDpug(dpugSpec) : '';
  }

  static String toIterableDartString(final Iterable<DpugSpec> dpugSpecs) =>
      dpugSpecs.map(toDartString).join('\n\n');

  static String toDartString(final DpugSpec dpugSpec) {
    final dartSpec = toDart(dpugSpec);
    final emitter = cb.DartEmitter();
    return dartSpec.accept(emitter).toString();
  }
}
