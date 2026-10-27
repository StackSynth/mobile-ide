import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../projects/projects_screen.dart';
import '../files/files_screen.dart';
import '../editor/editor_screen.dart';
import '../terminal/terminal_screen.dart';
import '../preview/preview_screen.dart';
import '../ai/ai_screen.dart';
import '../ai/diff_review_screen.dart';
import '../settings/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/projects',
  routes: [
    // Standalone Projects / Workspaces screen
    GoRoute(
      path: '/projects',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProjectsScreen(),
    ),

    // Diff Review screen
    GoRoute(
      path: '/ai/diff-review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DiffReviewScreen(),
    ),

    // Settings screen
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),

    // Stateful Navigation Shell for 5 Tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Files
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesScreen(),
            ),
          ],
        ),

        // Tab 1: Editor
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/editor',
              builder: (context, state) => const EditorScreen(),
            ),
          ],
        ),

        // Tab 2: Terminal
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/terminal',
              builder: (context, state) => const TerminalScreen(),
            ),
          ],
        ),

        // Tab 3: Preview
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/preview',
              builder: (context, state) => const PreviewScreen(),
            ),
          ],
        ),

        // Tab 4: AI
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai',
              builder: (context, state) => const AiScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
