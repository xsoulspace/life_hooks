import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'contextful_life_hook.dart';

abstract class LifeState {
  /// Equivalent of [State.initState] for [HookState].
  ///
  /// Copied from [HookState].
  @mustCallSuper
  void initState() {
    mounted = true;
  }

  /// Equivalent of [State.dispose] for [HookState].
  ///
  /// Copied from [HookState].
  @mustCallSuper
  void dispose() {
    mounted = false;
  }

  /// Equivalent of [State.setState] for [HookState].
  ///
  /// Copied from [HookState].
  late VoidCallback setState;

  bool mounted = false;

  /// Called everytime the [HookState] is requested.
  /// [build] is where a [HookState] may use other hooks.
  /// This restriction is made to ensure that hooks are always
  /// unconditionally requested.
  ///
  /// Copied from [HookState]
  @mustCallSuper
  void build() {}

  @mustCallSuper

  /// Equivalent of [State.didUpdateWidget] for [HookState].
  ///
  /// Copied from [HookState]
  ///
  /// For generic states use
  ///
  /// if([oldState] is T){
  ///   do something with the [oldState]
  /// }
  ///
  /// T will be the same class as the state
  void didUpdateState(final LifeState oldState) {}

  /// Equivalent of [State.widget] for [HookState].
  ///
  /// Copied from [HookState]
  /// For generic states use
  ///
  /// if([oldState] is T){
  ///   do something with the [oldState]
  /// }
  ///
  /// T will be the same class as the state
  late ValueGetter<LifeState> getHookState;
}

class LifeHook<T extends LifeState> extends Hook<T> {
  const LifeHook({
    required this.debugLabel,
    required this.state,
  });

  final String debugLabel;
  final T state;

  @override
  _LifeHookState<T> createState() => _LifeHookState<T>(state: state);
}

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
