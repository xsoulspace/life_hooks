// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/assets/l10n/wiredash_localizations.g.dart';
import 'package:wiredash/assets/l10n/wiredash_localizations_en.g.dart';
import 'package:wiredash/assets/l10n/wiredash_localizations_it.g.dart';

// TODO(arenukvern): create PR for wiredash
class CustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const CustomWiredashTranslationsDelegate();

  /// You have to define all languages that should be overridden
  @override
  bool isSupported(final Locale locale) =>
      ['en', 'ru', 'it'].contains(locale.languageCode);

  @override
  Future<WiredashLocalizations> load(final Locale locale) =>
      switch (locale.languageCode) {
        'ru' => SynchronousFuture(_RuOverrides()),
        'it' => SynchronousFuture(WiredashLocalizationsIt()),
        'en' || _ => SynchronousFuture(WiredashLocalizationsEn()),
      };

  @override
  bool shouldReload(final CustomWiredashTranslationsDelegate old) => false;
}

class _RuOverrides extends _RuDefaultOverrides {
  _RuOverrides();

  @override
  String get feedbackStep2LabelsTitle => 'С чем связан ваш отзыв?';

  @override
  String get feedbackStep2LabelsDescription =>
      'Выбор правильной категории поможет нам решить вопрос быстрее';
  @override
  String get feedbackStep4EmailTitle =>
      'Получите обновления на email о вашей проблеме';
}

class _RuDefaultOverrides extends WiredashLocalizationsEn {
  _RuDefaultOverrides() : super('ru');
  @override
  String get feedbackStep1MessageTitle => 'Отправьте свой отзыв';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Составить сообщение';

  @override
  String get feedbackStep1MessageDescription =>
      'Кратко опишите проблему, с которой вы столкнулись';

  @override
  String get feedbackStep1MessageHint =>
      'Например, возникает неизвестная ошибка, когда я пытаюсь изменить...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Пожалуйста, добавьте сообщение';

  @override
  String get feedbackStep2LabelsTitle =>
      'Какие категории лучше всего соответствуют вашему отзыву?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Категории';

  @override
  String get feedbackStep2LabelsDescription =>
      'Выбор правильной категории помогает нам определить проблему и направить ваш отзыв соответствующему специалисту';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Добавить скриншоты для лучшего понимания проблемы?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Скриншоты';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Вы сможете перемещаться по приложению и выбирать, когда сделать скриншот';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Пропустить';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Заскриншотить';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Сделать скриншот';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Добавьте скриншот для лучшего понимания проблемы';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Рисуйте на экране, чтобы показать проблему';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Отменить';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Заскриншотить';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Сохранить';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ок';

  @override
  String get feedbackStep3GalleryTitle => 'Прикрепленные скриншоты';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Скриншоты';

  @override
  String get feedbackStep3GalleryDescription =>
      'Добавьте больше скриншотов, чтобы мы могли лучше понять вашу проблему.';

  @override
  String get feedbackStep4EmailTitle =>
      'Получите обновления на email о вашей проблеме';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Контакт';

  @override
  String get feedbackStep4EmailDescription =>
      'Добавьте свой email адрес ниже или оставьте поле пустым';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Это не похоже на действительный email адрес. Вы можете оставить его пустым.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Отправить отзыв';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Отправить';

  @override
  String get feedbackStep6SubmitDescription =>
      'Пожалуйста, проверьте всю информацию перед отправкой.\nВы можете вернуться назад, чтобы изменить свой отзыв в любое время.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Отправить';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Показать детали';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Скрыть детали';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Детали отзыва';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Отправка вашего отзыва';

  @override
  String get feedbackStep7SubmissionSuccessMessage => 'Спасибо за ваш отзыв!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Не удалось отправить отзыв';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Нажмите, чтобы увидеть детали ошибки';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Повторить';

  @override
  String feedbackStepXOfY(final int current, final int total) =>
      'Шаг $current из $total';

  @override
  String get feedbackDiscardButton => 'Отменить отзыв';

  @override
  String get feedbackDiscardConfirmButton => 'Точно? Отменить!';

  @override
  String get feedbackNextButton => 'Далее';

  @override
  String get feedbackBackButton => 'Назад';

  @override
  String get feedbackCloseButton => 'Закрыть';

  @override
  String get promoterScoreStep1Question =>
      'Насколько вероятно, что вы порекомендуете нас?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Маловероятно, 10 = Очень вероятно';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Насколько вероятно, что вы порекомендуете нас своим друзьям и семье?';

  @override
  String promoterScoreStep2MessageDescription(final int rating) =>
      'Не могли бы вы рассказать немного подробнее, почему вы выбрали $rating? Этот шаг необязателен.';

  @override
  String get promoterScoreStep2MessageHint =>
      'Было бы здорово, если бы вы могли улучшить...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Спасибо за вашу оценку!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Спасибо за вашу оценку!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Спасибо за вашу оценку!';

  @override
  String get promoterScoreNextButton => 'Далее';

  @override
  String get promoterScoreBackButton => 'Назад';

  @override
  String get promoterScoreSubmitButton => 'Отправить';

  @override
  String get backdropReturnToApp => 'Вернуться в приложение';
}
