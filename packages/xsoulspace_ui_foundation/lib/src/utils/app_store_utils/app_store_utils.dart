export 'app_store_utils_io.dart'
    if (dart.library.web) 'app_store_utils_web.dart';

/// Represents the source from which the application was installed.
///
/// @ai Use this enum to determine the installation source and adjust app
/// behavior accordingly.
enum InstallSource {
  /// android
  androidAmazonAppStore,
  androidGooglePlay,
  androidGooglePlayInstaller,
  androidHuawaiAppGallery,
  androidRustore,
  androidSamsungGalaxyStore,
  androidSamsungSmartSwitchMobile,
  androidVivoAppStore,
  androidXiaomiGetApps,
  androidOppoAppMarket,
  androidApk,

  /// apple
  appleIOSAppStore,
  appleIOSTestFlight,
  appleIOSIpa,
  appleMacOSAppStore,
  appleMacOSTestFlight,
  appleMacOSDmg,
  appleMacOSSteam,
  appleWatchOS,
  appleVisionOS,

  /// windows store
  windowsStore,
  windowsSteam,
  linux,
  linuxSnap,
  linuxFlatpak,
  linuxSteam,
  fuchsia,
  unknown,
  webSelfhost,
  webItchIo;

  bool get isAndroid => name.startsWith('android');
  bool get isApple => name.startsWith('apple');

  /// Checks if the source is a macOS-specific installation type.
  bool get isAppleMacos => switch (this) {
        appleMacOSAppStore ||
        appleMacOSTestFlight ||
        appleMacOSDmg ||
        appleMacOSSteam =>
          true,
        _ => false,
      };

  /// Checks if the source is an iOS-specific installation type.
  bool get isAppleIos => switch (this) {
        appleIOSAppStore || appleIOSTestFlight || appleIOSIpa => true,
        _ => false,
      };

  bool get isWindows => name.startsWith('windows');
  bool get isLinux => name.startsWith('linux');
  bool get isFuchsia => name.startsWith('fuchsia');
  bool get isWeb => name.startsWith('web');
}

/// Specifies the target store for which the app is built.
///
/// @ai Use this enum to customize app behavior based on the target
/// distribution platform.
enum InstallPlatformTarget {
  rustore,
  googlePlay,
  appleStore,
  huawai,
  ios,
  macos,
  webSelfhost,
  webItchIo,
  other;

  /// Creates an [InstallPlatformTarget] from a string representation.
  factory InstallPlatformTarget.fromString(final String target) =>
      switch (target) {
        'rustore' => InstallPlatformTarget.rustore,
        'googlePlay' => InstallPlatformTarget.googlePlay,
        'appleStore' => InstallPlatformTarget.appleStore,
        'huawai' => InstallPlatformTarget.huawai,
        _ => InstallPlatformTarget.other,
      };
}

/// Defines the contract for App Store utility classes.
///
/// @ai Implement this interface to create custom app store utility classes.
// ignore: one_member_abstracts
abstract interface class AppStoreUtilsI {
  /// Retrieves the installation source of the application.
  Future<InstallSource> getInstallationSource();
}
