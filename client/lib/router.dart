import 'package:go_router/go_router.dart';
import 'package:tms_client/base/base_scaffold.dart';
import 'package:tms_client/deferred_widget.dart';
import 'package:tms_client/views/home/home_view.dart' deferred as home;
import 'package:tms_client/views/login/login_view.dart' deferred as login;

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
            libraryKey: _homeRoute,
            libraryLoader: home.loadLibrary,
            builder: (context) => home.HomeView(),
          ),
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
