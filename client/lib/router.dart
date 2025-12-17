import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/base/base_scaffold.dart';
import 'package:tms_client/views/home/home_view.dart' deferred as home;
import 'package:tms_client/views/login/login_view.dart' deferred as login;

class DeferredWidget extends HookConsumerWidget {
  final Future<void> Function() libraryLoader;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.libraryLoader,
    required this.builder,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryFuture = useMemoized(() => libraryLoader());
    final snapshot = useFuture(libraryFuture);

    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(child: Text('Failed to load: ${snapshot.error}'));
      }
      return builder(context);
    }

    return placeholder ?? const Center(child: CircularProgressIndicator());
  }
}

final _homeRoute = '/';
final _loginRoute = '/login';
// final _adminRoute = '/admin';

final router = GoRouter(
  initialLocation: _homeRoute,
  routes: <RouteBase>[
    // Shell Routes (for standard displays)
    ShellRoute(
      builder: (context, state, child) {
        return BaseScaffold(state: state, child: child);
      },

      routes: [
        GoRoute(
          name: 'home',
          path: _homeRoute,
          builder: (context, state) => DeferredWidget(
            libraryLoader: home.loadLibrary,
            builder: (context) => home.HomeView(),
          ),
        ),
        GoRoute(
          name: 'login',
          path: _loginRoute,
          builder: (context, state) => DeferredWidget(
            libraryLoader: login.loadLibrary,
            builder: (context) => login.LoginView(),
          ),
        ),
      ],
    ),

    // Standalone Routes
  ],
);
