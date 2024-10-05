import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../utils/device_runtime_type.dart';

/// A hook that provides a [ValueNotifier] for keyboard visibility.
///
/// This hook allows widgets to react to changes in keyboard visibility,
/// enabling dynamic UI adjustments based on whether the keyboard is shown or
/// hidden.
///
/// @returns A [ValueNotifier<bool>] that updates when the keyboard visibility
/// changes.
///
/// @ai Use this hook in widgets that need to react to keyboard visibility
/// changes.
ValueNotifier<bool> useKeyboardVisibility() =>
    use(const _KeyboardVisiblityHook());

/// A custom hook for keyboard visibility.
///
/// @ai This internal class should not be used directly. Use
/// [useKeyboardVisibility] instead.
class _KeyboardVisiblityHook extends Hook<ValueNotifier<bool>> {
  const _KeyboardVisiblityHook();

  @override
  _KeyboardVisiblityHookState createState() => _KeyboardVisiblityHookState();
}

/// The state for the [_KeyboardVisiblityHook].
///
/// This class manages the lifecycle and state of the keyboard visibility hook.
///
/// @ai Ensure that the state is properly managed to reflect the current
/// keyboard visibility.
class _KeyboardVisiblityHookState
    extends HookState<ValueNotifier<bool>, _KeyboardVisiblityHook> {
  late final _state = ValueNotifier<bool>(false)..addListener(_listener);
  StreamSubscription<bool>? keyboardSubscription;

  @override
  void initHook() {
    if (DeviceRuntimeType.isNativeDesktop) return;

    final keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen(onKeyboardVisibiltyChange);

    super.initHook();
  }

  @override
  void dispose() {
    unawaited(keyboardSubscription?.cancel());
    _state.dispose();
  }

  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void onKeyboardVisibiltyChange(final bool visible) {
    _state.value = visible;
  }

  @override
  ValueNotifier<bool> build(final BuildContext context) => _state;

  void _listener() {
    setState(() {});
  }

  @override
  bool? get debugValue => _state.value;

  @override
  String get debugLabel => 'useState<$bool>';
}
