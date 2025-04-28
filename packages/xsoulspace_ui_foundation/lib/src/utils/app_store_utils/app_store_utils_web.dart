import 'package:web/web.dart' as web;

import 'app_store_utils.dart';

class AppStoreUtils implements AppStoreUtilsI {
  const AppStoreUtils();

  /// Retrieves the installation source.
  ///
  /// Returns an [InstallSource] indicating where the app was installed from.
  @override
  Future<InstallSource> getInstallationSource() async =>
      switch (web.window.location.hostname) {
        'itch.io' => InstallSource.webItchIo,
        _ => InstallSource.webSelfhost,
      };
}
