import '../specs/specs.dart';
import 'visitor.dart';

abstract class BaseVisitor<T> implements DpugSpecVisitor<T> {
  BaseVisitor({this.throwOnError = false});
  final List<String> _errors = [];
  final bool throwOnError;

  List<String> get errors => List.unmodifiable(_errors);

  T visitSafely<S extends DpugSpec>(final S spec, final T Function(S) visit) {
    try {
      return visit(spec);
    } catch (e, stack) {
      final error = 'Error visiting ${spec.runtimeType}: $e\n$stack';
      _errors.add(error);
      if (throwOnError) rethrow;
      return _defaultValue;
    }
  }

  T get _defaultValue;
}
