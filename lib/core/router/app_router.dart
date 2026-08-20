import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/weight_detail_screen.dart';
import '../../features/home/presentation/weight_period_picker.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/profile/presentation/goals_screen.dart';
import '../../features/profile/presentation/nutrition_targets_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/training/presentation/training_screen.dart';
import '../logging/app_logger.dart';

/// Each tab is its own branch so it keeps an independent navigation stack.
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        _branch(
          '/home',
          const HomeScreen(),
          // Inside the home branch, so the bottom navigation keeps its place
          // and the tab remembers it was here.
          routes: [
            GoRoute(
              path: 'weight',
              // The period rides along in the URL rather than in `extra`: it
              // is a plain enum name, and one that survives a restored route
              // instead of coming back as null.
              builder: (context, state) => WeightDetailScreen(
                initialPeriod: weightPeriodByName(
                  state.uri.queryParameters['period'],
                ),
              ),
            ),
          ],
        ),
        _branch('/nutrition', const NutritionScreen()),
        _branch('/training', const TrainingScreen()),
        _branch('/stats', const StatsScreen()),
        _branch(
          '/settings',
          const SettingsScreen(),
          // Stays inside the settings branch, so the bottom navigation keeps
          // its place and the tab remembers where it was.
          routes: [
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: 'goals',
              builder: (context, state) => const GoalsScreen(),
              routes: [
                GoRoute(
                  path: 'nutrition',
                  builder: (context, state) => const NutritionTargetsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
)..routerDelegate.addListener(_logRouteChange);

void _logRouteChange() {
  final uri = appRouter.routerDelegate.currentConfiguration.uri;
  AppLogger.routing.info('Route changed to $uri');
}

StatefulShellBranch _branch(
  String path,
  Widget child, {
  List<RouteBase> routes = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, builder: (context, state) => child, routes: routes),
    ],
  );
}
