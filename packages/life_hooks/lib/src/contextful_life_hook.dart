part of 'life_hook.dart';

abstract class ContextfulLifeState extends LifeState {
  late ValueGetter<BuildContext> getContext;
}

class ContextfulLifeHook<T extends ContextfulLifeState> extends LifeHook<T> {
  const ContextfulLifeHook({
    required super.debugLabel,
    required super.state,
  });

  @override
  _ContextfulLifeHookState<T> createState() =>
      _ContextfulLifeHookState<T>(state: state);
}

class _ContextfulLifeHookState<T extends ContextfulLifeState>
    extends _LifeHookState<T> {
  _ContextfulLifeHookState({
    required super.state,
  });

  @override
  void initHook() {
    _innerState.getContext = () => context;
    super.initHook();
  }
}
