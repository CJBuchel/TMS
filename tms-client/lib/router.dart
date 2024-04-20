import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/connection/connection.dart';
import 'package:tms/views/deep_linking/deep_linking.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/login/logout.dart';
import 'package:tms/views/view_selector/view_selector.dart';
import 'package:tms/widgets/base_responsive.dart';
import 'package:tms/widgets/base_scaffold.dart';

final _protectedRoutes = <GoRoute>[
  GoRoute(
    path: '/setup',
    name: 'setup',
    builder: (context, state) => const SizedBox.shrink(),
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
    GoRoute(
      path: '/deep_linking',
      builder: (context, state) => BaseResponsive(child: DeepLinking()),
    ),
    ..._protectedRoutes,
  ],
);
