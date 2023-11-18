import 'package:flutter/widgets.dart';

abstract interface class Disposable {
  void dispose();
}

abstract interface class Loadable {
  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad();
}

abstract interface class ContextfulLoadable {
  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad(final BuildContext context);
}

@Deprecated('Use AsyncCallback from flutter')
typedef FutureVoidCallback = Future<void> Function();
