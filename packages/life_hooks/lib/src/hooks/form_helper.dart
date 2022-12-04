import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../life_hooks.dart';

FormHelperState useFormHelper() => use(
      LifeHook(
        debugLabel: 'FormHelperState',
        state: FormHelperState(),
      ),
    );

class FormHelperState extends LifeState {
  FormHelperState();
  final formHelper = FormHelper();
  @override
  void dispose() {
    super.dispose();
    formHelper.dispose();
  }

  late final validate = formHelper.validate;
  late final submit = formHelper.submit;
}

class FormHelper implements Disposable {
  FormHelper();
  final formKey = GlobalKey<FormState>();
  final loading = ValueNotifier(false);

  @override
  void dispose() {
    loading.dispose();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Future<void> submit({
    required final FutureVoidCallback onValide,
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
