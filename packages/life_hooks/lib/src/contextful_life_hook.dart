part of 'life_hook.dart';

abstract class ContextfulLifeState extends LifeState {
  late BuildContext context;
}

class ContextfulLifeHook<T extends ContextfulLifeState> extends LifeHook<T> {
  const ContextfulLifeHook({
    required final String debugLabel,
    required final T state,
  }) : super(debugLabel: debugLabel, state: state);

  @override
  _ContextfulLifeHookState<T> createState() =>
      _ContextfulLifeHookState<T>(state: state);
}

class _ContextfulLifeHookState<T extends ContextfulLifeState>
    extends _LifeHookState<T> {
  _ContextfulLifeHookState({
    required final T state,
  }) : super(
          state: state,
        );

  @override
  void initHook() {
    _innerState.context = context;
    super.initHook();
  }
}
