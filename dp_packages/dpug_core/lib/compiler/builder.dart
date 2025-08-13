import 'dart:async';

import 'package:build/build.dart';

import 'dpug_converter.dart';

/// Build runner builder that compiles `.dpug` files into `.dpug.dart`.
class DpugBuilder implements Builder {
  final DpugConverter _converter = DpugConverter();

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.dpug': ['.dpug.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final String input = await buildStep.readAsString(buildStep.inputId);
    final String out;
    try {
      out = _converter.dpugToDart(input);
    } on Object catch (e) {
      log.severe('DPug build error in ${buildStep.inputId.path}: $e');
      rethrow;
    }
    final AssetId outputId = buildStep.inputId.changeExtension('.dpug.dart');
    await buildStep.writeAsString(outputId, out);
  }
}

/// Factory for build.yaml wiring.
Builder dpugBuilder(BuilderOptions options) => DpugBuilder();
