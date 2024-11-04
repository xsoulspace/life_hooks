import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/analyzer_converter.dart';

import 'analyser_integration.dart';

class DPugAnalyzerPlugin extends ServerPlugin {
  final AnalyzerConverter _converter = AnalyzerConverter();

  DPugAnalyzerPlugin({required super.resourceProvider});

  @override
  String get name => 'DPug Analyzer';

  @override
  String get version => '1.0.0';

  @override
  List<String> get fileGlobsToAnalyze => const ['**/*.dpug'];

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    if (!path.endsWith('.dpug')) return;

    // Get file content
    final session = analysisContext.currentSession;
    final result = await session.getFile(path);
    if (result is! FileResult) return;

    final source = result.content;
    final analyzer = DPugAnalyzer(session, path);

    final errors = await analyzer.analyze(source);

    // Convert analyzer errors to protocol errors
    final protocolErrors = errors.map((error) {
      return _converter.convertAnalysisError(
        error,
        lineInfo: result.lineInfo,
        severity: (error.errorCode.errorSeverity),
      );
    }).toList();

    // Send error notifications
    channel.sendNotification(
      AnalysisErrorsParams(
        path,
        protocolErrors,
      ).toNotification(),
    );
  }
}
