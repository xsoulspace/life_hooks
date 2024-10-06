part of 'life_hook.dart';

/// An abstract class representing a life state that has access to a
/// [BuildContext].
///
/// This class extends [LifeState] and provides a mechanism to retrieve
/// the current [BuildContext] for use in loading or other operations.
///
/// @ai When implementing this class, ensure that the context is
/// properly set and used within the lifecycle of the state.
abstract class ContextfulLifeState extends LifeState {
  /// A getter that retrieves the current [BuildContext].
  late ValueGetter<BuildContext> getContext;
}

/// A hook that provides a context-aware life state.
///
/// This class extends [LifeHook] and allows the associated state to
/// access the current [BuildContext] during its lifecycle.
///
/// @ai Ensure that the context is used appropriately within the
/// lifecycle methods of the state.
class ContextfulLifeHook<T extends ContextfulLifeState> extends LifeHook<T> {
  /// Creates a [ContextfulLifeHook].
  const ContextfulLifeHook({
    required super.debugLabel,
    required super.state,
  });

  @override
  _ContextfulLifeHookState<T> createState() =>
      _ContextfulLifeHookState<T>(state: state);
}

/// The state class for [ContextfulLifeHook].
///
/// This class initializes the context for the associated state and
/// manages its lifecycle.
///
/// @ai Ensure that the context is set correctly before using it
/// in the state methods.
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
