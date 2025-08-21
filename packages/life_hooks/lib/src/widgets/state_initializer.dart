import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../abstract/abstract.dart';
import '../hooks/hooks.dart';

/// An abstract interface for state initializers that can load contextually.
///
/// This interface extends [ContextfulLoadable] to ensure that any
/// implementing class can perform loading operations that require
/// a [BuildContext].
///
/// @ai When implementing this interface, ensure that the loading logic
/// is context-aware and handles any potential exceptions gracefully.
abstract interface class StateInitializer implements ContextfulLoadable {}

/// A widget that manages the loading state of its child based on the
/// provided [StateInitializer].
///
/// This widget displays a loading indicator while the [initializer]
/// is performing its loading operations. Once loading is complete,
/// it transitions to display the [child] widget.
///
/// @ai Ensure that the [StateInitializer] is properly implemented
/// to handle loading logic and that the [loader] widget is visually
/// appropriate for your application.
class StateLoader extends HookWidget {
  /// Creates a [StateLoader] widget.
  ///
  /// The [child] is displayed once loading is complete, and the
  /// [initializer] is responsible for loading the necessary state.
  ///
  /// [loader] is displayed while loading is in progress.
  const StateLoader({
    required this.child,
    required this.initializer,
    required this.loader,
    this.background = Colors.black,
    this.backgroundIsTransparent = false,
    super.key,
  });

  /// The widget to display once loading is complete.
  final Widget child;

  /// The initializer responsible for loading state.
  final StateInitializer initializer;

  /// The widget to display while loading.
  final Widget loader;

  /// The background color of the loader.
  final Color background;

  /// Whether the background is transparent during loading.
  final bool backgroundIsTransparent;

  static const _transitionDuration = Duration(milliseconds: 450);
  static const _minScale = 0.98;
  static const double _maxScale = 1;
  static const double _scaleDiff = _maxScale - _minScale;

  @override
  Widget build(final BuildContext context) {
    final ValueNotifier<bool> loaded = useIsBool();
    final ValueNotifier<bool> renderAllowed = useIsBool();
    final ValueNotifier<bool> loading = useIsBool();
    final ValueNotifier<double> homeOpacity = useState(0);
    final ValueNotifier<double> loaderOpacity = useState(1);
    final ValueNotifier<double> loaderScale = useState(1);

    final AnimationController animationController = useAnimationController(
      duration: _transitionDuration,
      initialValue: _minScale,
      lowerBound: _minScale,
    );
    final double animation = useAnimation(animationController);

    useEffect(() {
      final double progressPercent = (animation - _minScale) / _scaleDiff;
      homeOpacity.value = progressPercent;
      loaderOpacity.value = 1 - progressPercent;
      loaderScale.value = animation + 0.1;

      return null;
    }, [animation]);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (!backgroundIsTransparent) Container(color: background),
          if (backgroundIsTransparent && loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Container(color: background),
            ),
          if (renderAllowed.value)
            Transform.scale(scale: animationController.value, child: child),
          if (loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Transform.scale(
                scale: loaderScale.value,
                child: FutureBuilder<bool>(
                  // ignore: discarded_futures
                  future: () async {
                    if (loading.value) return false;
                    loading.value = true;
                    loaded.value = true;
                    await initializer.onLoad(context);
                    renderAllowed.value = true;
                    await animationController.forward();
                    loading.value = false;

                    return true;
                  }(),
                  builder: (final context, final snapshot) {
                    if (snapshot.connectionState != ConnectionState.done ||
                        snapshot.data == false) {
                      return loader;
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
