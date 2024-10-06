import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A utility function that provides a [ValueNotifier<bool>] for managing
/// boolean state in hooks.
///
/// This function simplifies the creation of a boolean state that can be
/// used within a hook context. It initializes the state with the provided
/// [initial] value.
///
/// Example:
/// ```dart
/// final isVisible = useIsBool(initial: true);
/// ```
///
/// @ai When using this function, ensure that the [initial] value is set
/// appropriately to reflect the desired initial state.
ValueNotifier<bool> useIsBool({final bool initial = false}) =>
    useState(initial);
