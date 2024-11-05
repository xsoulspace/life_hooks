import '../specs/specs.dart';
import 'visitor.dart';

class DpugEmitter implements DpugSpecVisitor<String> {
  final StringBuffer _buffer = StringBuffer();
  int _indent = 0;

  String get _indentation => '  ' * _indent;

  @override
  String visitClass(DpugClassSpec spec) {
    // Similar to current DpugGeneratingVisitor but cleaner
    spec.annotations.forEach((a) => _buffer.writeln(a.accept(this)));
    _buffer.writeln('class ${spec.name}');
    _indent++;
    // ... rest of implementation
    return _buffer.toString();
  }

  // ... other visitor methods
}
