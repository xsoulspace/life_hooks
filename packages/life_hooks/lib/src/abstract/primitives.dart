import 'package:flutter/widgets.dart';

abstract class Loadable {
  Loadable();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad({required final BuildContext context});
}

typedef FutureVoidCallback = Future<void> Function();
