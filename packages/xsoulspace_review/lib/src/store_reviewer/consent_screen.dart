// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:xsoulspace_locale/xsoulspace_locale.dart';

const _languages = (
  en: UiLanguage('en', 'English'),
  ru: UiLanguage('ru', 'Russian'),
  it: UiLanguage('it', 'Italian'),
  zh: UiLanguage('zh', 'Chinese'),
  es: UiLanguage('es', 'Spanish'),
  pt: UiLanguage('pt', 'Portuguese'),
  ja: UiLanguage('ja', 'Japanese'),
);

/// A screen that prompts the user for consent to leave a review.
///
/// This widget displays a dialog asking the user if they would like to leave
/// a review for the application. It supports multiple languages for the
/// dialog content.
///
/// @ai Use this screen to gather user feedback effectively and ensure
/// localization is handled properly.
class _ConsentScreen extends StatelessWidget {
  /// Creates a consent screen.
  ///
  /// The [locale] argument is required to determine the language of the
  /// dialog content.
  ///
  /// @ai Ensure the [locale] is set correctly to provide the user with
  /// localized content.
  const _ConsentScreen({required this.locale});
  final Locale locale;

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(
      LocalizedMap(
        value: {
          _languages.en: 'Leave a Review?',
          _languages.ru: 'Оставить отзыв?',
          _languages.it: 'Lasciare una recensione?',
          _languages.zh: '留下评论？',
          _languages.es: 'Dejar una reseña?',
          _languages.pt: 'Deixar uma avaliação?',
          _languages.ja: 'レビューを書きますか？',
        },
      ).getValue(locale),
    ),
    content: Text(
      LocalizedMap(
        value: {
          _languages.en: 'Would you like to leave a review for our app?',
          _languages.ru: 'Хотите оставить отзыв о нашем приложении?',
          _languages.it: 'Vorresti lasciare una recensione per la nostra app?',
          _languages.ja: 'アプリのレビューを書いていただけますか？',
          _languages.zh: '您想为我们的应用程序留下评论吗？',
          _languages.es:
              '¿Te gustaría dejar una reseña para nuestra aplicación?',
          _languages.pt:
              'Você gostaria de deixar uma avaliação para a nossa aplicação?',
        },
      ).getValue(locale),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          LocalizedMap(
            value: {
              _languages.en: 'No',
              _languages.ru: 'Нет',
              _languages.it: 'No',
              _languages.ja: 'いいえ',
              _languages.zh: '不',
              _languages.es: 'No',
              _languages.pt: 'Não',
            },
          ).getValue(locale),
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ),
      TextButton(
        child: Text(
          LocalizedMap(
            value: {
              _languages.en: 'Yes',
              _languages.ru: 'Да',
              _languages.it: 'Sì',
              _languages.ja: 'はい',
              _languages.zh: '是',
              _languages.es: 'Sí',
              _languages.pt: 'Sim',
            },
          ).getValue(locale),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}

/// Displays a consent dialog and returns the user's response.
///
/// This function shows the [_ConsentScreen] dialog and waits for the user's
/// response. It returns true if the user consents to leave a review, and
/// false otherwise.
///
/// @param context The [BuildContext] used to display the dialog.
/// @param locale The [Locale] used to determine the language of the dialog.
///
/// @return A [Future<bool>] indicating the user's consent response.
///
/// @ai Use this function to handle user consent for feedback requests
/// effectively.
Future<bool> defaultFallbackConsentBuilder(
  final BuildContext context,
  final Locale locale,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (final context) => _ConsentScreen(locale: locale),
  );
  return result ?? false;
}
