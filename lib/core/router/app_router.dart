import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/training/presentation/training_screen.dart';

/// Each tab is its own branch so it keeps an independent navigation stack.
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        _branch('/home', const HomeScreen()),
        _branch('/nutrition', const NutritionScreen()),
        _branch('/training', const TrainingScreen()),
        _branch('/stats', const StatsScreen()),
      ],
    ),
  ],
);

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => child)],
  );
}
