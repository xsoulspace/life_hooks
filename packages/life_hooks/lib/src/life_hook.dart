import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

abstract class LifeState {
  @mustCallSuper
  void initState() {
    mounted = true;
  }

  @mustCallSuper
  void dispose() {
    mounted = false;
  }

  /// Called everytime the [HookState] is requested.
  /// Equals to [HookState.build].
  ///
  /// This method is where a [HookState] may use other hooks.
  /// This restriction is made to ensure that hooks are always
  /// unconditionally requested.
  ///
  /// Copied from [HookState].
  void registerHooks(final BuildContext context);

  late VoidCallback setState;

  /// Equals to [HookState.context]
  /// Equivalent of [State.context] for [HookState]
  ///
  /// Copied from [HookState].
  late BuildContext context;
  bool mounted = false;
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
      ..context = context
      ..setState = () {
        setState(() {});
      }
      ..initState();
    super.initHook();
  }

  @override
  T build(final BuildContext context) {
    _innerState.registerHooks(context);
    return _innerState;
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
