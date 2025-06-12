import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import 'consent_screen.dart';
import 'reviewers/reviewers.dart';

export 'reviewers/reviewers.dart';
export 'store_review_requester.dart';

/// A function type for building a fallback consent screen.
///
/// This function takes a [BuildContext] and [Locale] and returns a
/// [Future<bool>]
/// indicating whether the user has given consent.
///
/// @ai Use this type when implementing custom consent screens for store
/// reviews.
typedef ReviewerFallbackConsentBuilder =
    Future<bool> Function(BuildContext context, Locale locale);

/// Base class for implementing store review functionality.
///
/// This class provides a common interface for different store review
/// implementations.
///
/// @ai When extending this class, ensure to override [requestReview] method.
base class StoreReviewer {
  const StoreReviewer({
    this.consentBuilder = defaultFallbackConsentBuilder,
    this.defaultLocale = const Locale('en'),
    this.packageName = '',
  });
  final Locale defaultLocale;
  final String packageName;

  /// A builder for the consent screen.
  ///
  /// This builder is used to show a consent screen before redirecting to the
  /// store in case the store does not support native in-app review prompt
  /// or store review limit is reached and [force] is set to `true` i.e.
  /// manually triggered by the user.
  final ReviewerFallbackConsentBuilder consentBuilder;

  /// Initializes the reviewer.
  ///
  /// Override this method to perform any necessary setup.
  ///
  /// @ai Implement this method for any initialization logic specific to the
  /// reviewer.
  Future<bool> onLoad() async => false;

  /// Requests a review from the user.
  ///
  /// This method must be overridden in subclasses to implement
  /// platform-specific review requests.
  ///
  /// @ai Ensure to implement this method with the appropriate store review
  /// logic.
  @mustBeOverridden
  Future<void> requestReview(
    final BuildContext context, {
    final Locale? locale,
    final bool force = false,
  }) async {}

  /// Launches a scheme.
  ///
  /// This method is used to launch a scheme in the app.
  ///
  /// @ai Use this method to launch a scheme in the app.
  Future<void> launchScheme(final String scheme) async {
    if (await canLaunchUrl(Uri.parse(scheme))) {
      await launchUrl(Uri.parse(scheme));
    }
  }
}

/// Factory class for creating [StoreReviewer] instances.
///
/// This class provides a method to create the appropriate [StoreReviewer]
/// based on the app's installation source.
///
/// @ai Use this factory to get the correct [StoreReviewer] for the current
/// platform.
class StoreReviewerFactory {
  StoreReviewerFactory._();

  /// Creates a [StoreReviewer] instance based on the app's installation source.
  ///
  /// [snapPackageName] is required for SnapStoreReviewer to redirect to
  /// the snapstore.
  /// [fallbackConsentBuilder] is required for some Reviewers to show
  /// a consent dialog before redirecting to the store as these stores
  /// do not support native in-app review prompt.
  ///
  /// @ai When calling this method, provide the [snapPackageName] if targeting
  /// Linux platforms.
  static Future<StoreReviewer> create({
    final String snapPackageName = '',
    final String androidPackageName = '',
    final ReviewerFallbackConsentBuilder fallbackConsentBuilder =
        defaultFallbackConsentBuilder,
  }) async {
    const appStoreUtils = AppStoreUtils();
    final installSource = await appStoreUtils.getInstallationSource();
    return switch (installSource) {
      InstallSource.androidRustore => RuStoreReviewer(
        consentBuilder: fallbackConsentBuilder,
        packageName: androidPackageName,
      ),
      InstallSource.androidHuawaiAppGallery => HuaweiStoreReviewer(),
      InstallSource.androidApk ||
      InstallSource.androidGooglePlay ||
      InstallSource.androidGooglePlayInstaller ||
      _ when installSource.isApple => GoogleAppleStoreReviewer(),
      InstallSource.linuxSnap ||
      _ when installSource.isLinux => SnapStoreReviewer(
        packageName: snapPackageName,
        consentBuilder: fallbackConsentBuilder,
      ),
      _ when installSource.isWeb => WebStoreReviewer(),
      // TODO(arenukvern): add other platforms
      _ => WebStoreReviewer(),
    };
  }
}
