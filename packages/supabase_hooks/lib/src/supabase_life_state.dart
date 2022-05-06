import 'package:life_hooks/life_hooks.dart';

/// Interface for screen that requires an authenticated user
abstract class SupabaseLifeState extends LifeState {
  @override
  void initState() {
    super.initState();
    startAuthObserver();
  }

  @override
  void dispose() {
    stopAuthObserver();
    super.dispose();
  }

  /// enable auth observer
  /// e.g. on nested authentication flow, call this method on navigation push.then()
  ///
  /// ```dart
  /// Navigator.pushNamed(context, '/signUp').then((_) => startAuthObserver());
  /// ```
  void startAuthObserver();

  /// disable auth observer
  /// e.g. on nested authentication flow, call this method before navigation push
  ///
  /// ```dart
  /// stopAuthObserver();
  /// Navigator.pushNamed(context, '/signUp').then((_) =>{});
  /// ```
  void stopAuthObserver();
}
