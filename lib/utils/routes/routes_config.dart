import 'package:boilerplate/presentation/pages/auth/register/register.dart';
import 'package:boilerplate/presentation/pages/auth/unauthorized/unauthorized.dart';
import 'package:boilerplate/presentation/pages/comick_detail/comick_detail.dart';
import 'package:boilerplate/presentation/pages/comic/reader.dart';
import 'package:boilerplate/presentation/pages/history/history.dart';
import 'package:boilerplate/presentation/pages/home/home.dart';
import 'package:boilerplate/presentation/pages/auth/login/login.dart';
import 'package:boilerplate/presentation/pages/search/search.dart';
import 'package:boilerplate/presentation/pages/users/list.dart';
import 'package:boilerplate/presentation/pages/profile/profile.dart';
import 'package:boilerplate/presentation/pages/sandbox/sandbox_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoutePaths {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sandbox = '/sandbox';
  static const String profile = '/profile';
  static const String unauthorized = '/unauthorized';
  static const String mylist = '/my-list';
  static const String comicDetail = '/comicDetail/:comicId';
  static const String comicContent = '/comic-content/:slug/:hid/:chap';
  static const String search = '/search';
  static const String history = '/history';
}

class RouteParams {
  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  final Object? extra;

  const RouteParams({
    this.pathParams = const {},
    this.queryParams = const {},
    this.extra,
  });
}

class RouteConfig {
  final String path;
  final String? name;
  final Widget Function(BuildContext context, RouteParams params) builder;
  final List<String> allowedRoles;
  final bool requiresAuth;
  final bool requiresAdmin;
  final bool fullscreenDialog;
  final bool isShell;
  final Widget Function(BuildContext, GoRouterState, Widget)? shellBuilder;
  final List<RouteConfig>? children;

  const RouteConfig({
    required this.path,
    this.name,
    required this.builder,
    this.allowedRoles = const [],
    this.requiresAuth = false,
    this.requiresAdmin = false,
    this.fullscreenDialog = false,
    this.isShell = false,
    this.shellBuilder,
    this.children,
  });
}

class RoutesConfig {
  static final List<RouteConfig> publicRoutes = [
    RouteConfig(
      path: RoutePaths.sandbox,
      name: 'sandbox',
      builder: (context, params) => const SandboxScreen(),
      requiresAuth: true,
    ),
    RouteConfig(
      path: RoutePaths.login,
      name: 'login',
      builder: (context, params) => const LoginScreen(),
    ),
    RouteConfig(
      path: RoutePaths.register,
      name: 'register',
      builder: (context, params) => const RegisterScreen(),
    ),
    RouteConfig(
      path: RoutePaths.unauthorized,
      name: 'unauthorized',
      builder: (context, params) => const UnauthorizedScreen(),
    ),
    RouteConfig(
      path: RoutePaths.profile,
      name: 'profile',
      builder: (context, params) => const ProfileSettingsScreen(),
    ),
    RouteConfig(
        path: RoutePaths.mylist,
        name: 'my-list',
        builder: (context, params) => const MylistScreen()),
    RouteConfig(
      path: RoutePaths.comicDetail,
      name: 'comicDetail',
      builder: (context, params) {
        final comicId = params.pathParams['comicId'] ?? '1';
        return ComicDetailScreen(comicId: comicId);
      },
    ),
    RouteConfig(
      path: RoutePaths.home,
      name: 'home',
      builder: (context, params) => const HomeScreen(),
    ),
    RouteConfig(
        path: RoutePaths.comicContent,
        name: 'comic-content',
        builder: (context, params) {
          final slug = params.pathParams['slug'] ?? '';
          final hid = params.pathParams['hid'] ?? '1';
          final chap = params.pathParams['chap'] ?? '1';
          return ReaderScreen(
            slug: slug,
            hid: hid, 
            chap: chap
          );
        }),
    RouteConfig(
        path: RoutePaths.search,
        name: 'search',
        builder: (context, params) => const SearchScreen()),
    RouteConfig(
        path: RoutePaths.history,
        name: 'history',
        builder: (context, params) => const HistoryScreen()),
  ];

  static final List<RouteConfig> authenticatedRoutes = [];

  static List<RouteConfig> get allRoutes => [
        ...publicRoutes,
        ...authenticatedRoutes,
        // ...adminRoutes,
      ];
}
