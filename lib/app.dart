import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'data/models/comic_book.dart';
import 'data/models/server_config.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/reader/reader_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/webdav/browser_screen.dart';
import 'ui/screens/webdav/server_form_screen.dart';
import 'ui/screens/webdav/server_list_screen.dart';
import 'ui/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/reader',
      builder: (context, state) {
        final book = state.extra as ComicBook;
        return ReaderScreen(book: book);
      },
    ),
    GoRoute(
      path: '/servers',
      builder: (context, state) => const ServerListScreen(),
    ),
    GoRoute(
      path: '/servers/add',
      builder: (context, state) => const ServerFormScreen(),
    ),
    GoRoute(
      path: '/servers/:id/edit',
      builder: (context, state) {
        final server = state.extra as ServerConfig;
        return ServerFormScreen(server: server);
      },
    ),
    GoRoute(
      path: '/servers/:id/browse',
      builder: (context, state) {
        final server = state.extra as ServerConfig;
        return BrowserScreen(server: server);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
