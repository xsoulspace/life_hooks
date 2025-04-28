/// {@template xsoulspace_foundation.stateless}
/// Flags a class which should not contain any state.
///
/// This class can be used to annotate functional classes that encapsulate
/// business logic without exposing any internal state. It may contain minimal
/// internal state (e.g., `_isInitialized`), but this should not be accessible
/// to other classes.
///
/// @ai Ensure that the annotated class adheres to the principles of
/// statelessness and does not expose any mutable state.
/// {@endtemplate}
const stateless = Stateless();

/// A marker class indicating that a class should not contain any state.
///
/// This class is used to annotate functional classes that encapsulate
/// business logic without exposing any internal state. It may contain minimal
/// internal state (e.g., `_isInitialized`), but this should not be accessible
/// to other classes.
///
/// @ai Ensure that the annotated class adheres to the principles of
/// statelessness and does not expose any mutable state.
final class Stateless {
  /// {@macro xsoulspace_foundation.stateless}
  const Stateless();
}

/// {@template xsoulspace_foundation.state_distributor}
/// A marker class indicating that a class contains state but should not
/// contain any business logic.
///
/// This class is used to annotate classes that manage state without
/// implementing any business logic. It serves as a clear separation of
/// concerns in the architecture.
///
/// @ai Use this annotation to ensure that the annotated class focuses solely
/// on state management without mixing in business logic.
/// {@endtemplate}
const stateDistributor = StateDistributor();

/// A marker class indicating that a class contains state but should not
/// contain any business logic.
///
/// This class is used to annotate classes that manage state without
/// implementing any business logic. It serves as a clear separation of
/// concerns in the architecture.
///
/// @ai Use this annotation to ensure that the annotated class focuses solely
/// on state management without mixing in business logic.
final class StateDistributor {
  /// {@macro xsoulspace_foundation.state_distributor}
  const StateDistributor();
}

/// {@template xsoulspace_foundation.heavy_computation}
/// A marker class indicating that a function contains heavy computation.
///
/// This class is used to annotate functions that perform intensive operations,
/// such as loading large datasets or performing complex calculations.
///
/// @ai When annotating a function with this class, ensure that the heavy
/// computation is well-optimized and consider offloading it to a separate
/// isolate if necessary.
/// {@endtemplate}
const heavyComputation = HeavyComputation();

/// A marker class indicating that a function contains heavy computation.
///
/// This class is used to annotate functions that perform intensive operations,
/// such as loading large datasets or performing complex calculations.
///
/// @ai When annotating a function with this class, ensure that the heavy
/// computation is well-optimized and consider offloading it to a separate
/// isolate if necessary.
final class HeavyComputation {
  /// {@macro xsoulspace_foundation.heavy_computation}
  const HeavyComputation();
}
