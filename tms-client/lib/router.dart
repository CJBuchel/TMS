import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/connection/connection.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/login/logout.dart';
import 'package:tms/views/match_controller/match_controller.dart';
import 'package:tms/views/setup/setup.dart';
import 'package:tms/views/view_selector/view_selector.dart';
import 'package:tms/widgets/base_responsive.dart';
import 'package:tms/widgets/base_scaffold.dart';

final _protectedRoutes = <GoRoute>[
  GoRoute(
    path: '/setup',
    name: 'setup',
    builder: (context, state) => BaseScaffold(state: state, child: Setup()),
    redirect: (context, state) {
      if (!Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
        return '/login';
      }

      return null;
    },
  ),

  // referee routes
  GoRoute(
    path: '/referee',
    name: 'referee',
    // builder: (context, state) => BaseScaffold(state: state, child: const ViewSelector()),
    routes: [
      GoRoute(
        path: 'match_controller',
        name: 'match_controller',
        builder: (context, state) => BaseScaffold(state: state, child: const MatchController()),
      ),
    ],
    redirect: (context, state) {
      if (!Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
        return '/login';
      }

      return null;
    },
  ),
];

final tmsRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => BaseScaffold(state: state, child: const ViewSelector()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BaseScaffold(state: state, child: Login()),
    ),
    GoRoute(
      path: '/logout',
      name: 'logout',
      builder: (context, state) => BaseScaffold(state: state, child: Logout()),
    ),
    GoRoute(
      path: '/connection',
      name: 'connection',
      // we don't use base Scaffold because we need the scaffold for floating buttons
      builder: (context, state) => BaseResponsive(child: Connection(state: state)),
    ),
    ..._protectedRoutes,
  ],
);
