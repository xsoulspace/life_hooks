import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.web) 'package:intl/intl_browser.dart';

import 'localization.dart';

class LocaleLogic {
  LocaleLogic();

  Future<Locale> get _defaultLocale async {
    final systemLocaleStr = await findSystemLocale();

    final systemLocale = Locale.fromSubtags(
      languageCode: systemLocaleStr.substring(0, 2),
    );
    final isSupported =
        LocalizationConfig.instance.supportedLocales.contains(systemLocale);
    if (isSupported) return systemLocale;
    return Locales.fallback;
  }

  /// Ui locale will not be saved, and will always be in runtime
  /// updatedLocale is the one that will be saved.
  ///
  /// Use [onLocaleChanged] to update the Intl localization,
  /// for example, S.delegate.load(locale)
  Future<({Locale? updatedLocale, Locale uiLocale})?> updateLocale({
    required final Locale? newLocale,
    required final Locale? oldLocale,
    required final Locale uiLocale,
    final ValueChanged<Locale>? onLocaleChanged,
  }) async {
    final didChanged = oldLocale?.languageCode != newLocale?.languageCode ||
        uiLocale != newLocale;
    if (!didChanged) return null;

    Locale? updatedLocale = oldLocale;
    Locale updatedUiLocale = uiLocale;
    final defaultLocale = await _defaultLocale;

    if (newLocale == null) {
      onLocaleChanged?.call(defaultLocale);
      updatedLocale = null;
      updatedUiLocale = defaultLocale;
    } else {
      if (!LocalizationConfig.instance.isLocaleSupported(newLocale)) {
        throw UnsupportedError(
          'The requested locale $newLocale is not supported.',
        );
      }

      final localeCandidate = UiLanguage.byLocale(newLocale).locale;

      onLocaleChanged?.call(localeCandidate);
      updatedLocale = localeCandidate;
      updatedUiLocale = localeCandidate;
    }

    return (
      updatedLocale: updatedLocale,
      uiLocale: updatedUiLocale,
    );
  }
}
