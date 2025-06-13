import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rustore_review/flutter_rustore_review.dart';

import '../store_reviewer.dart';

final class RuStoreReviewer extends StoreReviewer {
  RuStoreReviewer({
    super.consentBuilder,
    super.defaultLocale,
    super.packageName,
  });
  @override
  Future<bool> onLoad() async {
    await RustoreReviewClient.initialize();
    return true;
  }

  @override
  Future<void> requestReview(
    final BuildContext context, {
    final Locale? locale,
    final bool force = false,
  }) async {
    try {
      await RustoreReviewClient.request();
      await RustoreReviewClient.review();
    } on PlatformException catch (e) {
      switch (e.message) {
        case 'RuStoreRequestLimitReached':
          if (force && context.mounted) {
            final isConsent = await consentBuilder(
              context,
              locale ?? defaultLocale,
            );
            if (!isConsent) return;
            await launchScheme(
              'https://www.rustore.ru/catalog/app/$packageName',
            );
          }
          return;
        case 'RuStoreReviewExists':
          // TODO(arenukvern): handle this case
          return;
      }
      rethrow;
    }
  }
}
