import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_life_state.dart';

/// Interface for screen that requires an authenticated user
abstract class SupabaseAuthRequiredLifeState extends SupabaseLifeState
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  late final StreamSubscription<AuthChangeEvent> _authStateListener;
  final _log = Supabase.instance.client.realtime.log;
  @override
  void initState() {
    super.initState();

    _authStateListener = Supabase.instance.client.auth.listen((final event) {
      if (event == AuthChangeEvent.signedOut) {
        onUnauthenticated();
      }
    });

    if (Supabase.instance.client.auth.currentSession == null) {
      _recoverSupabaseSession();
    } else {
      onAuthenticated(Supabase.instance.client.auth.currentSession!);
    }
  }

  @override
  void dispose() {
    unawaited(_authStateListener.cancel());
    super.dispose();
  }

  @override
  void startAuthObserver() {
    _log('***** SupabaseAuthRequiredState startAuthObserver');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void stopAuthObserver() {
    _log('***** SupabaseAuthRequiredState stopAuthObserver');
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<bool> onResumed() {
    _log('***** SupabaseAuthRequiredState onResumed');
    return _recoverSupabaseSession();
  }

  Future<bool> _recoverSupabaseSession() async {
    final bool exist =
        await Supabase.instance.client.auth.localStorage.hasAccessToken();
    if (!exist) {
      onUnauthenticated();
      return false;
    }

    final String? jsonStr =
        await SupabaseAuth.instance.localStorage.accessToken();
    if (jsonStr == null) {
      onUnauthenticated();
      return false;
    }

    final response = await Supabase.instance.client.auth.recoverSession(
      jsonStr,
    );
    if (response.error != null) {
      await SupabaseAuth.instance.localStorage.removePersistedSession();
      onUnauthenticated();
      return false;
    } else {
      onAuthenticated(response.data!);
      return true;
    }
  }

  /// Callback when user session is ready
  void onAuthenticated(final Session session) {}

  /// Callback when user is unauthenticated
  void onUnauthenticated();
}
