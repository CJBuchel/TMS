import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/backups/backups.dart';
import 'package:tms/views/connection/connection.dart';
import 'package:tms/views/dashboard/dashboard.dart';
import 'package:tms/views/game_match_timer/game_match_timer.dart';
import 'package:tms/views/game_matches/game_matches.dart';
import 'package:tms/views/game_tables/game_tables.dart';
import 'package:tms/views/judging_pods/judging_pods.dart';
import 'package:tms/views/judging_sessions/judging_sessions.dart';
import 'package:tms/views/login/login.dart';
import 'package:tms/views/login/logout.dart';
import 'package:tms/views/match_controller/match_controller.dart';
import 'package:tms/views/referee_scoring/referee_scoring.dart';
import 'package:tms/views/scoreboard/scoreboard.dart';
import 'package:tms/views/setup/setup.dart';
import 'package:tms/views/team_data/team_data.dart';
import 'package:tms/views/teams/teams.dart';
import 'package:tms/views/users/users.dart';
import 'package:tms/views/view_selector/view_selector.dart';
import 'package:tms/widgets/scaffolds/base_scaffold.dart';
import 'package:tms/widgets/scaffolds/base_scaffold_drawer_router.dart';
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
  // admin routes
  GoRoute(
    path: '/admin',
    name: 'admin',
    routes: [
      GoRoute(
        path: 'setup',
        name: 'setup',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: Setup())),
        ),
      ),
      GoRoute(
        path: 'dashboard',
        name: 'dashboard',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: Dashboard())),
        ),
      ),
      GoRoute(
        path: 'users',
        name: 'users',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: Users())),
        ),
      ),
      GoRoute(
        path: 'backups',
        name: 'backups',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: Backups())),
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

  GoRoute(
    path: '/teams',
    name: 'teams',
    routes: [
      GoRoute(
        path: 'team_data',
        name: 'team_data',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: TeamData())),
        ),
      ),
    ],
    builder: (context, state) => BaseScaffoldDrawerRouter(
      state: state,
      child: _DelayedViewWrapper(
        child: NoMobileViewWrapper(child: Teams()),
      ),
    ),
    redirect: (context, state) {
      if (!Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
        return '/login';
      }

      return null;
    },
  ),

  // robot games routes
  GoRoute(
    path: '/robot_games',
    name: 'robot_games',
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
      GoRoute(
        path: 'game_matches',
        name: 'game_matches',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: GameMatches())),
        ),
      ),
      GoRoute(
        path: 'game_tables',
        name: 'game_tables',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: GameTables())),
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

  // Judging routes
  GoRoute(
    path: '/judging',
    name: 'judging',
    routes: [
      GoRoute(
        path: 'judging_pods',
        name: 'judging_pods',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: JudgingPods())),
        ),
      ),
      GoRoute(
        path: 'judging_sessions',
        name: 'judging_sessions',
        builder: (context, state) => BaseScaffoldDrawerRouter(
          state: state,
          child: _DelayedViewWrapper(child: NoMobileViewWrapper(child: JudgingSessions())),
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
      builder: (context, state) => Connection(state: state),
    ),
    GoRoute(
      path: '/game_match_timer',
      name: 'game_match_timer',
      builder: (context, state) => BaseScaffold(state: state, child: _DelayedViewWrapper(child: GameMatchTimer())),
    ),
    GoRoute(
      path: '/scoreboard',
      name: 'scoreboard',
      builder: (context, state) => BaseScaffold(state: state, child: const _DelayedViewWrapper(child: Scoreboard())),
    ),
    ..._protectedRoutes,
  ],
);
