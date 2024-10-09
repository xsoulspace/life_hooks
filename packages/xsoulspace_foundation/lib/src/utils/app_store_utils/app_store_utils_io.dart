import 'dart:io';

import 'package:store_checker/store_checker.dart';

import 'app_store_utils.dart';

class AppStoreUtils implements AppStoreUtilsI {
  const AppStoreUtils();
  @override
  Future<InstallSource> getInstallationSource() async {
    final installationSource = await StoreChecker.getSource;

    final result = switch (installationSource) {
      /// ********************************************
      /// *      ANDROID
      /// ********************************************
      Source.IS_INSTALLED_FROM_PLAY_STORE => InstallSource.androidGooglePlay,
      Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER =>
        InstallSource.androidGooglePlayInstaller,
      Source.IS_INSTALLED_FROM_AMAZON_APP_STORE =>
        InstallSource.androidAmazonAppStore,
      Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY =>
        InstallSource.androidHuawaiAppGallery,
      Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE =>
        InstallSource.androidSamsungGalaxyStore,
      Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE =>
        InstallSource.androidSamsungSmartSwitchMobile,
      Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS =>
        InstallSource.androidXiaomiGetApps,
      Source.IS_INSTALLED_FROM_OPPO_APP_MARKET =>
        InstallSource.androidOppoAppMarket,
      Source.IS_INSTALLED_FROM_VIVO_APP_STORE =>
        InstallSource.androidVivoAppStore,
      Source.IS_INSTALLED_FROM_OTHER_SOURCE => InstallSource.androidApk,
      Source.IS_INSTALLED_FROM_RU_STORE => InstallSource.androidRustore,

      /// ********************************************
      /// *      APPLE
      /// ********************************************
      /// * IOS
      Source.IS_INSTALLED_FROM_APP_STORE when Platform.isIOS =>
        InstallSource.appleIOSAppStore,
      Source.IS_INSTALLED_FROM_TEST_FLIGHT when Platform.isIOS =>
        InstallSource.appleIOSTestFlight,

      /// * MACOS
      Source.IS_INSTALLED_FROM_APP_STORE => InstallSource.appleMacOSAppStore,
      Source.IS_INSTALLED_FROM_TEST_FLIGHT =>
        InstallSource.appleMacOSTestFlight,
      Source.IS_INSTALLED_FROM_LOCAL_SOURCE || Source.UNKNOWN => null,
    };
    if (result != null) return result;
    if (Platform.isAndroid) {
      return InstallSource.androidApk;
    } else if (Platform.isIOS) {
      /// maybe other stores, like EpicStore
      return InstallSource.appleIOSIpa;
    } else if (Platform.isMacOS) {
      return InstallSource.appleMacOSDmg;
    } else if (Platform.isWindows) {
      return InstallSource.windowsStore;
    } else if (Platform.isLinux) {
      return InstallSource.linux;
    } else if (Platform.isFuchsia) {
      return InstallSource.fuchsia;
    } else {
      return InstallSource.unknown;
    }
  }
}
