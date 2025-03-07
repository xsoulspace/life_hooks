import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

export 'wiredash_custom_delegate.dart';

class UserFeedbackWiredashDto {
  const UserFeedbackWiredashDto({
    required this.projectId,
    required this.secret,
    this.collectMetaData,
    this.feedbackOptions,
    this.psOptions,
    this.theme,
    this.options,
    this.padding,
  });
  final String projectId;
  final String secret;
  final FutureOr<CustomizableWiredashMetaData> Function(
    CustomizableWiredashMetaData metaData,
  )?
  collectMetaData;
  final WiredashFeedbackOptions? feedbackOptions;
  final PsOptions? psOptions;
  final WiredashThemeData? theme;
  final WiredashOptionsData? options;
  final EdgeInsets? padding;
}

class UserFeedback extends StatelessWidget {
  const UserFeedback.wiredash({
    required this.child,
    required final UserFeedbackWiredashDto dto,
    super.key,
  }) : wiredashDto = dto;
  final Widget child;
  final UserFeedbackWiredashDto wiredashDto;
  static Future<void> show(final BuildContext context) =>
      Wiredash.of(context).show();

  @override
  Widget build(final BuildContext context) => Wiredash(
    projectId: wiredashDto.projectId,
    secret: wiredashDto.secret,
    collectMetaData: wiredashDto.collectMetaData,
    feedbackOptions: wiredashDto.feedbackOptions,
    psOptions: wiredashDto.psOptions,
    theme: wiredashDto.theme,
    options: wiredashDto.options,
    padding: wiredashDto.padding,
    child: child,
  );
}
