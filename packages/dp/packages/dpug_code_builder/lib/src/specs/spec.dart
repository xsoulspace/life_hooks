import 'package:meta/meta.dart';

import '../visitors/visitor.dart';

@immutable
abstract class DpugSpec {
  const DpugSpec();
  T accept<T>(DpugSpecVisitor<T> visitor);
}
