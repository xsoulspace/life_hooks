import 'package:flutter/widgets.dart';

abstract class Disposable {
  Disposable();
  void dispose();
}

abstract class Loadable {
  Loadable();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad();
}

abstract class ContextfulLoadable {
  ContextfulLoadable();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad(final BuildContext context);
}

typedef FutureVoidCallback = Future<void> Function();
