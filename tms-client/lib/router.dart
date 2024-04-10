import 'package:go_router/go_router.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/view_selector.dart';

final tmsRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const ViewSelector(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => Login(),
    ),
  ],
);
