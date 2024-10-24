import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import 'store_reviewer.dart';

/// {@template store_review_requester}
/// A class responsible for managing review requests for a store.
///
/// This class schedules and sends review requests based on specified
/// review periods and a maximum review count.
/// It interacts with the [StoreReviewer] to initiate review requests and uses
/// a local database to track the last review request time and review count.
///
/// Example usage:
/// ```dart
/// final reviewRequester = StoreReviewRequester(
///   firstReviewPeriod: Duration(days: 1),
///   reviewPeriod: Duration(days: 30),
///   maxReviewCount: 3,
///   storeReviewer: myStoreReviewer,
///   localDb: myLocalDb,
/// );
/// await reviewRequester.onLoad();
/// ```
///
/// [StoreReviewer.onLoad] will be called during [onLoad]
///
/// Ensure proper initialization of [firstReviewPeriod], [reviewPeriod],
/// [maxReviewCount], [_storeReviewer], and [localDb].
/// {@endtemplate}
class StoreReviewRequester extends ChangeNotifier {
  /// Creates an instance of [StoreReviewRequester].
  ///
  /// {@macro store_review_requester}
  StoreReviewRequester({
    required this.localDb,
    final StoreReviewer storeReviewer = const StoreReviewer(),
    this.firstReviewPeriod = const Duration(days: 1),
    this.reviewPeriod = const Duration(days: 15),
    this.maxReviewCount = 3,
    this.getLocale,
  }) : _storeReviewer = storeReviewer;
  final ValueGetter<Locale>? getLocale;

  /// The duration before the first review request.
  final Duration firstReviewPeriod;

  /// The duration between subsequent review requests.
  final Duration reviewPeriod;

  /// The maximum number of times a review can be requested.
  final int maxReviewCount;

  /// The [StoreReviewer] instance used to request reviews.
  StoreReviewer _storeReviewer;

  /// The local database interface for storing review request data.
  final LocalDbI localDb;

  Timer? _timer;
  static const String _lastReviewRequestKey = 'last_review_request';
  static const String _reviewCountKey = 'review_count';
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;
  set isAvailable(final bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  /// Initializes the review requester by checking the last review request time
  /// and review count.
  ///
  /// If no previous request exists, it schedules the first review request.
  /// Otherwise, it schedules based on the elapsed time and review count.
  Future<void> onLoad() async {
    _storeReviewer = await StoreReviewerFactory.create();
    isAvailable = await _storeReviewer.onLoad();
    if (!isAvailable) return;

    final lastReviewRequest = await localDb.getInt(key: _lastReviewRequestKey);
    final reviewCount = await localDb.getInt(key: _reviewCountKey);

    if (reviewCount >= maxReviewCount) return;

    if (lastReviewRequest == 0) {
      _scheduleReviewRequest(initialDelay: firstReviewPeriod);
    } else {
      final lastRequestTime =
          DateTime.fromMillisecondsSinceEpoch(lastReviewRequest);
      final timeSinceLastRequest = DateTime.now().difference(lastRequestTime);
      final currentPeriod = reviewCount == 0 ? firstReviewPeriod : reviewPeriod;

      if (timeSinceLastRequest >= currentPeriod) {
        _scheduleReviewRequest();
      } else {
        final remainingTime = currentPeriod - timeSinceLastRequest;
        _scheduleReviewRequest(initialDelay: remainingTime);
      }
    }
  }

  /// Schedules a review request after a specified delay.
  void _scheduleReviewRequest({final Duration? initialDelay}) {
    if (!isAvailable) return;
    _timer?.cancel();
    _timer = Timer(initialDelay ?? reviewPeriod, requestReview);
  }

  /// Requests a review from the store reviewer if the maximum count hasn't
  /// been reached.
  Future<void> requestReview({
    final BuildContext? context,
    final Locale? locale,
  }) async {
    if (!isAvailable) return;
    final isManual = context != null;
    final reviewCount = await localDb.getInt(key: _reviewCountKey);
    if (reviewCount >= maxReviewCount && !isManual) return;

    final effectiveContext = context ?? WidgetsBinding.instance.rootElement;
    if (effectiveContext != null) {
      await _storeReviewer.requestReview(
        effectiveContext,
        locale: locale ?? getLocale?.call(),
        force: isManual,
      );
      await _updateLastReviewRequestTime();
      await _incrementReviewCount();
    }
    _scheduleReviewRequest();
  }

  /// Updates the last review request timestamp in the local database.
  Future<void> _updateLastReviewRequestTime() async {
    await localDb.setInt(
      key: _lastReviewRequestKey,
      value: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Increments the review count in the local database.
  Future<void> _incrementReviewCount() async {
    final currentCount = await localDb.getInt(key: _reviewCountKey);
    await localDb.setInt(key: _reviewCountKey, value: currentCount + 1);
  }

  /// Disposes of the timer to prevent memory leaks.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
