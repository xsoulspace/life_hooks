import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<bool> useIsBool({final bool initial = false}) =>
    useState(initial);
