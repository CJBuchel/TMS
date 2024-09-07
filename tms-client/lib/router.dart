import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/connection/connection.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/login/logout.dart';
import 'package:tms/views/match_controller/match_controller.dart';
import 'package:tms/views/referee_scoring/referee_scoring.dart';
import 'package:tms/views/setup/setup.dart';
import 'package:tms/views/view_selector/view_selector.dart';
import 'package:tms/widgets/base_responsive.dart';
import 'package:tms/widgets/base_scaffold.dart';
import 'package:tms/widgets/base_scaffold_drawer_router.dart';
import 'package:tms/widgets/no_mobile_view_wrapper.dart';

class _DelayedViewWrapper extends StatelessWidget {
  final Widget child;

  const _DelayedViewWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

final _protectedRoutes = <GoRoute>[
  GoRoute(
    path: '/setup',
    name: 'setup',
    builder: (context, state) => BaseScaffold(
      state: state,
      child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: Setup())),
    ),
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
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: const _DelayedViewWrapper(child: NoMobileViewWrapper(child: MatchController())),
        ),
      ),
      GoRoute(
        path: 'scoring',
        name: 'scoring',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: RefereeScoring())),
        ),
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
      builder: (context, state) => BaseResponsive(child: Connection(state: state)),
    ),
    ..._protectedRoutes,
  ],
);
