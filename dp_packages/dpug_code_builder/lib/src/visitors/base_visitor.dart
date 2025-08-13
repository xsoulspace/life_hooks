import '../specs/specs.dart';
import 'visitor.dart';

abstract class BaseVisitor<T> implements DpugSpecVisitor<T> {
  final List<String> _errors = [];
  final bool throwOnError;

  BaseVisitor({this.throwOnError = false});

  List<String> get errors => List.unmodifiable(_errors);

  T visitSafely<S extends DpugSpec>(S spec, T Function(S) visit) {
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
