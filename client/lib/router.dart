import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/base/base_scaffold.dart';
import 'package:tms_client/deferred_widget.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/views/home/home_view.dart' deferred as home;
import 'package:tms_client/views/login/login_view.dart' deferred as login;
import 'package:tms_client/views/setup/setup_view.dart' deferred as setup;

part 'router.g.dart';

final _homeRoute = '/';
final _loginRoute = '/login';
final _adminRoute = '/admin';
final _setupRoute = '/setup';

/// Creates a page with a standard fade + slide up transition
CustomTransitionPage<void> buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
      );
    },
  );
}

@riverpod
GoRouter router(Ref ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: _homeRoute,
    routes: <RouteBase>[
      // Shell Routes (for standard displays)
      ShellRoute(
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: BaseScaffold(state: state, child: child),
          );
        },
        routes: [
          GoRoute(
            name: 'home',
            path: _homeRoute,
            pageBuilder: (context, state) => buildTransitionPage(
              key: state.pageKey,
              child: DeferredWidget(
                libraryKey: _homeRoute,
                libraryLoader: home.loadLibrary,
                builder: (context) => home.HomeView(),
              ),
            ),
          ),

          // Protected Admin routes
          GoRoute(
            name: 'admin',
            path: _adminRoute,
            redirect: (context, state) {
              if (!isLoggedIn) {
                return _loginRoute;
              }
              return null;
            },
            routes: [
              GoRoute(
                name: 'setup',
                path: _setupRoute,
                pageBuilder: (context, state) => buildTransitionPage(
                  key: state.pageKey,
                  child: DeferredWidget(
                    libraryKey: _setupRoute,
                    libraryLoader: setup.loadLibrary,
                    builder: (context) => setup.SetupView(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        name: 'login',
        path: _loginRoute,
        builder: (context, state) => BaseScaffold(
          showActions: false,
          state: state,
          child: DeferredWidget(
            libraryKey: _loginRoute,
            libraryLoader: login.loadLibrary,
            builder: (context) => login.LoginView(),
          ),
        ),
      ),
    ],
  );
}
