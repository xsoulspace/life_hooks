import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../life_hooks.dart';

/// A hook that provides a stateful form helper for managing form state.
///
/// This hook simplifies form handling by encapsulating the logic for
/// validation, submission, and state management. It utilizes the
/// [FormHelperState] to maintain the form's state and provides
/// convenient methods for validation and submission.
///
/// @ai When using this hook, ensure that the form is properly
/// initialized and that the [onValide] callback is correctly defined
/// to handle form submission.
FormHelperState useFormHelper() => use(
      LifeHook(
        debugLabel: 'FormHelperState',
        state: FormHelperState(),
      ),
    );

/// A state class for managing form operations.
///
/// This class encapsulates the logic for form validation and submission.
/// It holds an instance of [FormHelper] to manage the form's state and
/// provides methods for validation and submission.
///
/// @ai Ensure that the [dispose] method is called to clean up resources
/// when the form is no longer needed.
class FormHelperState extends LifeState {
  /// A helper class for managing form state and operations.
  ///
  /// This class provides methods for validating, resetting, and submitting
  /// forms. It maintains a [GlobalKey<FormState>] to track the form's state
  /// and a [ValueNotifier<bool>] to indicate loading status during submission.
  final formHelper = FormHelper();

  @override
  void dispose() {
    super.dispose();
    formHelper.dispose();
  }

  /// Validates the current form state.
  ///
  /// This method delegates the validation to the [FormHelper] instance.
  /// It returns true if the form is valid, otherwise false.
  late final validate = formHelper.validate;

  /// Submits the form and executes the provided callback if valid.
  ///
  /// This method delegates the submission to the [FormHelper] instance.
  /// It takes an [AsyncCallback] that is executed if the form is valid.
  late final submit = formHelper.submit;
}

/// A helper class for managing form state and operations.
///
/// This class provides methods for validating, resetting, and submitting
/// forms. It maintains a [GlobalKey<FormState>] to track the form's state
/// and a [ValueNotifier<bool>] to indicate loading status during submission.
///
/// @ai When using this class, ensure that the [formKey] is properly
/// assigned to the form widget and that the loading state is handled
/// appropriately.
class FormHelper implements Disposable {
  /// A key that uniquely identifies the form.
  ///
  /// This key is used to access the form's state and perform operations
  /// such as validation and resetting.
  final formKey = GlobalKey<FormState>();

  /// A notifier that indicates whether the form is currently loading.
  ///
  /// Whether the form is in a loading state during submission.
  final loading = ValueNotifier(false);

  @override
  void dispose() {
    loading.dispose();
  }

  /// Validates the current form state.
  ///
  /// This method checks if the form is valid by calling the
  /// [validate] method on the form's state.
  ///
  /// @return true if the form is valid, otherwise false.
  bool validate() => formKey.currentState?.validate() ?? false;

  /// Resets the form to its initial state.
  ///
  /// This method calls the [reset] method on the form's state.
  void reset() => formKey.currentState?.reset();

  /// Submits the form and executes the provided callback if valid.
  ///
  /// This method checks the form's validity and, if valid, sets the
  /// loading state to true, executes the provided [onValide] callback,
  /// and finally resets the loading state.
  ///
  /// [onValide] A callback that is executed if the form is valid.
  Future<void> submit({
    required final AsyncCallback onValide,
  }) async {
    try {
      if (validate()) {
        loading.value = true;
        await onValide();
      }
    } finally {
      loading.value = false;
    }
  }
}
