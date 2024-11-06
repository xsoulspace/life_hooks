import 'package:meta/meta.dart';

import '../visitors/visitor.dart';

@immutable
abstract class DpugSpec {
  const DpugSpec();
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]);
}
