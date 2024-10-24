import 'package:flutter/widgets.dart';

import '../store_reviewer.dart';

final class SnapStoreReviewer extends StoreReviewer {
  SnapStoreReviewer({
    required super.packageName,
    super.consentBuilder,
    super.defaultLocale,
  });

  @override
  Future<bool> onLoad() async => true;

  @override
  Future<void> requestReview(
    final BuildContext context, {
    final Locale? locale,
    final bool force = false,
  }) async {
    final isConsent = await consentBuilder(context, locale ?? defaultLocale);
    if (!isConsent) return;

    await launchScheme('snap://review/$packageName');
  }
}
