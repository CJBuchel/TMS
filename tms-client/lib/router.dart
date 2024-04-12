import 'package:go_router/go_router.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/view_selector.dart';
import 'package:tms/widgets/base_scaffold.dart';

final tmsRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'selector',
      builder: (context, state) => BaseScaffold(child: ViewSelector()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BaseScaffold(child: Login()),
    ),
  ],
);
