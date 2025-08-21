import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A hook that creates and manages a state notifier.
///
/// This hook allows for the creation and management of complex state objects
/// in a hook-based widget, providing a clean and efficient way to handle state.
///
/// [builder] A function that creates the state notifier.
/// @returns The created state notifier.
///
/// @ai Use this hook to create and manage complex state objects in a hook-based
/// widget.
TNotifier useStateBuilder<TState, TNotifier extends ValueNotifier<TState>>(
  final _StateHookBuilder<TState, TNotifier> builder,
) => use(_StateHook<TState, TNotifier>(builder: builder));

/// A typedef for the state notifier builder function.
typedef _StateHookBuilder<TState, TNotifier extends ValueNotifier<TState>> =
    TNotifier Function();

/// A custom hook for creating and managing state notifiers.
///
/// @ai This internal class should not be used directly. Use
/// [useStateBuilder] instead.
class _StateHook<TState, TNotifier extends ValueNotifier<TState>>
    extends Hook<TNotifier> {
  const _StateHook({required this.builder});
  final _StateHookBuilder<TState, TNotifier> builder;

  @override
  _StateHookState<TState, TNotifier> createState() => _StateHookState();
}

/// The state for the [_StateHook].
///
/// This class manages the lifecycle and state of the state builder hook.
///
/// @ai Ensure that the state is properly managed to reflect the current state.
class _StateHookState<TState, TNotifier extends ValueNotifier<TState>>
    extends HookState<TNotifier, _StateHook<TState, TNotifier>> {
  late final _state = hook.builder()..addListener(_listener);

  @override
  void dispose() {
    _state.dispose();
  }

  @override
  TNotifier build(final BuildContext context) => _state;

  void _listener() => setState(() {});

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useState<$TState>';
}
