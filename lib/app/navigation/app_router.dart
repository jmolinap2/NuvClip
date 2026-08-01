import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvclip/app/navigation/root_shell.dart';
import 'package:nuvclip/features/downloader/presentation/home_screen.dart';
import 'package:nuvclip/features/downloader/presentation/preview_screen.dart';
import 'package:nuvclip/features/history/presentation/history_screen.dart';
import 'package:nuvclip/features/settings/presentation/settings_screen.dart';

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/history', builder: (context, state) => const HistoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/preview',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PreviewScreen(),
      ),
    ],
  );
}
