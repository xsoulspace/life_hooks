<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Unofficial Supabase life cycle adaptation for flutter_hooks.
See more in the original package:
https://github.com/supabase/supabase-flutter

Note: This library is completely experimental and not recommended for production usage.

The idea is the same as in LifeHook, except that you can override more methods,
specific to Supabase Auth life cycle

```dart
AuthRequiredState useAuthRequiredState({
  required final NavigatorState navigator,
}) => use(
      LifeHook(
        debugLabel: 'AuthRequiredState',
        state: AuthRequiredState(
          navigator: navigator,
        ),
      ),
    );

class AuthRequiredState extends SupabaseAuthRequiredLifeState {
  AuthRequiredState({
    required this.navigator,
  });
  final NavigatorState navigator;
  @override
  void onUnauthenticated() {
    /// Users will be sent back to the LoginPage if they sign out.
    if (mounted) {
      /// Users will be sent back to the LoginPage if they sign out.
      navigator
          .pushNamedAndRemoveUntil('/login', (final route) => false);
    }
  }
}
```

or use

```dart
AuthState useAuthState({
  required NavigatorState navigator,
}) => use(
      LifeHook(
        debugLabel: 'AuthState',
        state: AuthState(
          navigator: navigator,
        ),
      ),
    );

class AuthState extends SupabaseAuthLifeState {
  AuthRequiredState({
    required this.navigator,
  });
  final NavigatorState navigator;
  @override
  void onUnauthenticated() {
    if (mounted) {
      navigator
          .pushNamedAndRemoveUntil('/', (final route) => false);
    }
  }

  @override
  void onAuthenticated(final Session session) {
    if (mounted) {
      navigator
          .pushNamedAndRemoveUntil('/', (final route) => false);
    }
  }

  @override
  void onPasswordRecovery(final Session session) {}

  @override
  void onErrorAuthenticating(final String message) {
    navigator.context.showErrorSnackBar(message: message);
  }
}
```

<!-- ## Features -->

<!-- TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more. -->
