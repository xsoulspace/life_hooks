import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source.dart';
import 'package:analyzer/src/generated/timestamped_data.dart';
import 'package:dpug_analyzer/compiler/parser.dart';

import 'compiler/source_mapper.dart';

class DPugAnalyzer {
  final AnalysisSession session;
  final String path;

  DPugAnalyzer(this.session, this.path);

  Future<List<AnalysisError>> analyze(String source) async {
    // Convert DPug to temporary Dart file
    final parser = DPugParser();
    final dartSource = await parser.processDPugFile(source, null);

    // Analyze generated Dart code
    final result = await session.getResolvedUnit(path);

    if (result is ResolvedUnitResult) {
      // Map errors back to DPug source
      return _mapErrorsToDPug(result.errors, source, parser.sourceMapper);
    }

    return [];
  }

  List<AnalysisError> _mapErrorsToDPug(
    List<AnalysisError> dartErrors,
    String dpugSource,
    SourceMapper sourceMapper,
  ) {
    final source = _DPugSource(path, dpugSource);
    final lineInfo = LineInfo.fromContent(dpugSource);

    return dartErrors.map((error) {
      final dpugLocation = sourceMapper.getOriginalLocation(error.offset);
      if (dpugLocation == null) return error;

      final length = sourceMapper.getLength(error.offset) ?? error.length;

      return AnalysisError.tmp(
        source: source,
        offset: dpugLocation.offset,
        length: length,
        errorCode: error.errorCode,
        contextMessages: error.contextMessages,
        data: error.data,
      );
    }).toList();
  }
}

class _DPugSource implements Source {
  @override
  final String fullName;
  final String content;

  _DPugSource(this.fullName, this.content);

  @override
  TimestampedData<String> get contents =>
      TimestampedData<String>(DateTime.now().millisecondsSinceEpoch, content);

  @override
  String get encoding => Uri.encodeFull(fullName);

  @override
  int get modificationStamp => DateTime.now().millisecondsSinceEpoch;

  @override
  String get shortName => Uri.parse(fullName).pathSegments.last;

  @override
  Uri get uri => Uri.file(fullName);

  @override
  bool exists() => true;
}

class DPugErrorCode implements ErrorCode {
  @override
  final String name;
  @override
  final String uniqueName;
  @override
  final String message;
  @override
  final String? correction;
  @override
  final ErrorSeverity errorSeverity;
  @override
  final ErrorType type;

  const DPugErrorCode({
    required this.name,
    required this.uniqueName,
    required this.message,
    this.correction,
    required this.errorSeverity,
    required this.type,
  });

  @override
  String get correctionMessage => correction ?? '';

  @override
  bool get hasPublishedDocs => false;

  @override
  bool get isIgnorable => false;

  @override
  bool get isUnresolvedIdentifier => false;

  @override
  int get numParameters => 0;

  @override
  String get problemMessage => message;

  @override
  String? get url => null;
}

class DPugErrorListener implements AnalysisErrorListener {
  final List<AnalysisError> errors = [];

  @override
  void onError(AnalysisError error) {
    errors.add(error);
  }
}
