import 'package:flutter/widgets.dart';

import '../store_reviewer.dart';

final class WebStoreReviewer extends StoreReviewer {
  @override
  Future<void> requestReview(
    final BuildContext context, {
    final Locale? locale,
    final bool force = false,
  }) async {
    // TODO(arenukvern): add review request for web
  }
}
