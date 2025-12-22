import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Type-safe navigation routes for the entire app.
///
/// Usage:
/// - Named navigation: `AppRoute.setup.go(context)`
/// - With parameters: `AppRoute.setup.go(context, queryParams: {'tab': 'database'})`
/// - Index-based navigation: `AppRoute.fromRailIndex(0).go(context)`
/// - Get current index: `AppRoute.currentRailIndex(context)`
///
/// Route definitions:
/// - path: The actual path used in go_router (for route definitions)
/// - name: The route name used for named navigation
/// - railIndex: The index in NavigationRail (null if not in rail)
enum AppRoute {
  // Public routes
  home(path: '/', name: 'home', railIndex: null),
  login(path: '/login', name: 'login', railIndex: null),
  settings(path: '/settings', name: 'settings', railIndex: null),

  // Protected routes (nested under /protected)
  setup(
    path: '/setup', // Relative to /protected parent
    name: 'setup',
    railIndex: 0,
  ),
  matchController(
    path: '/match_controller', // Relative to /protected parent
    name: 'match_controller',
    railIndex: 1,
  ),

  // Future routes (placeholders for cards that don't navigate yet)
  scoreboard(path: '/scoreboard', name: 'scoreboard', railIndex: null),
  timer(path: '/timer', name: 'timer', railIndex: null),
  dashboard(path: '/dashboard', name: 'dashboard', railIndex: null),
  referee(path: '/referee', name: 'referee', railIndex: null);

  const AppRoute({
    required this.path,
    required this.name,
    required this.railIndex,
  });

  /// The path used in go_router route definitions
  final String path;

  /// The route name used by go_router for named navigation
  final String name;

  /// The index in the NavigationRail (null if not in rail)
  final int? railIndex;

  /// Navigate to this route using go_router's goNamed method
  void go(
    BuildContext context, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    context.goNamed(
      name,
      pathParameters: pathParams ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }

  /// Navigate to this route using go_router's pushNamed method
  Future<T?> push<T>(
    BuildContext context, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    return context.pushNamed<T>(
      name,
      pathParameters: pathParams ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }

  /// Get the route by navigation rail index
  static AppRoute? fromRailIndex(int index) {
    try {
      return values.firstWhere((route) => route.railIndex == index);
    } catch (e) {
      return null;
    }
  }

  /// Get all routes that appear in the navigation rail, in order
  static List<AppRoute> get railRoutes {
    final routes = values.where((route) => route.railIndex != null).toList();
    routes.sort((a, b) => a.railIndex!.compareTo(b.railIndex!));
    return routes;
  }

  /// Get the current rail index based on the current route name
  static int? currentRailIndex(BuildContext context) {
    final routeName = GoRouterState.of(context).topRoute?.name;

    if (routeName == null) return null;

    // Find the route that matches the current name
    for (final route in values) {
      if (routeName == route.name) {
        return route.railIndex;
      }
    }

    return null;
  }

  /// Get the current route based on the current route name
  static AppRoute? current(BuildContext context) {
    final routeName = GoRouterState.of(context).topRoute?.name;

    if (routeName == null) return null;

    for (final route in values) {
      if (routeName == route.name) {
        return route;
      }
    }

    return null;
  }
}
