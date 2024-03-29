import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../abstract/abstract.dart';
import '../hooks/hooks.dart';

abstract interface class StateInitializer implements ContextfulLoadable {}

class StateLoader extends HookWidget {
  const StateLoader({
    required this.child,
    required this.initializer,
    required this.loader,
    this.background = Colors.black,
    this.backgroundIsTransparent = false,
    super.key,
  });
  final Widget child;
  final StateInitializer initializer;
  final Widget loader;
  final Color background;
  final bool backgroundIsTransparent;

  static const Duration _transitionDuration = Duration(milliseconds: 450);
  static const double _minScale = 0.98;
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

    useEffect(
      () {
        final double progressPercent = (animation - _minScale) / _scaleDiff;
        homeOpacity.value = progressPercent;
        loaderOpacity.value = 1 - progressPercent;
        loaderScale.value = animation + 0.1;

        return null;
      },
      [animation],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (!backgroundIsTransparent) Container(color: background),
          if (backgroundIsTransparent && loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Container(
                color: background,
              ),
            ),
          if (renderAllowed.value)
            Transform.scale(
              scale: animationController.value,
              child: child,
            ),
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
