import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'contextful_life_hook.dart';

/// An abstract class representing the state of a life hook.
///
/// This class provides lifecycle methods similar to [State] for use
/// in hooks, including initialization, disposal, and state updates.
///
/// @ai When implementing this class, ensure that lifecycle methods
/// are properly overridden to manage state effectively.
abstract class LifeState {
  /// Equivalent of [State.initState] for [HookState].
  ///
  /// This method is called when the hook is initialized.
  /// Copied from [HookState].
  ///
  /// @ai Ensure that the state is properly initialized and that any
  /// necessary setup is performed in this method.
  @mustCallSuper
  void initState() {
    mounted = true;
  }

  /// Equivalent of [State.dispose] for [HookState].
  /// Copied from [HookState].
  ///
  /// This method is called when the hook is disposed.
  @mustCallSuper
  void dispose() {
    mounted = false;
  }

  /// Equivalent of [State.setState] for [HookState].
  /// Copied from [HookState].
  ///
  /// This method is used to trigger a rebuild of the hook.
  late VoidCallback setState;

  /// Whether the hook is currently mounted.
  bool mounted = false;

  /// Called everytime the [HookState] is requested.
  /// Copied from [HookState]
  /// This method is where hooks may use other hooks.
  @mustCallSuper
  void build() {}

  /// Equivalent of [State.didUpdateWidget] for [HookState].
  /// Copied from [HookState].
  ///
  /// This method is called when the hook's state is updated.
  @mustCallSuper
  void didUpdateState(final LifeState oldState) {}

  /// Equivalent of [State.widget] for [HookState].
  /// Copied from [HookState].
  ///
  /// This method provides access to the current hook state.
  late ValueGetter<LifeState> getHookState;
}

/// A hook that manages the lifecycle of a [LifeState].
///
/// This class provides a mechanism to create and manage the state
/// of a life hook, including initialization and disposal.
///
/// @ai Ensure that the state is properly managed and that lifecycle
/// methods are overridden as needed.
class LifeHook<T extends LifeState> extends Hook<T> {
  /// Creates a [LifeHook].
  const LifeHook({required this.debugLabel, required this.state});

  /// A label for debugging purposes.
  final String debugLabel;

  /// The state associated with this hook.
  final T state;

  @override
  _LifeHookState<T> createState() => _LifeHookState<T>(state: state);
}

/// The state class for [LifeHook].
///
/// This class manages the lifecycle of the associated state and
/// provides mechanisms for rebuilding and disposing of the state.
///
/// @ai Ensure that the state is properly managed and that lifecycle
/// methods are overridden as needed.
class _LifeHookState<T extends LifeState> extends HookState<T, LifeHook<T>> {
  _LifeHookState({required final T state}) : _innerState = state;
  final T _innerState;

  @override
  void initHook() {
    _innerState
      ..setState = () {
        setState(() {});
      }
      ..initState()
      ..getHookState = () => hook.state;
    super.initHook();
  }

  @override
  T build(final BuildContext context) {
    _innerState.build();
    return _innerState;
  }

  @override
  void didUpdateHook(final LifeHook<T> oldHook) {
    _innerState.didUpdateState(oldHook.state);
    super.didUpdateHook(oldHook);
  }

  @override
  void dispose() {
    _innerState
      ..setState = () {}
      ..dispose();
    super.dispose();
  }

  @override
  String get debugLabel => hook.debugLabel;
}
