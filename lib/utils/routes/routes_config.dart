import 'package:boilerplate/presentation/pages/auth/register/register.dart';
import 'package:boilerplate/presentation/pages/auth/unauthorized/unauthorized.dart';
import 'package:boilerplate/presentation/pages/home/home.dart';
import 'package:boilerplate/presentation/pages/auth/login/login.dart';
import 'package:boilerplate/presentation/pages/sandbox/sandbox_page.dart';
import 'package:boilerplate/presentation/pages/users/profile/profile.dart';
import 'package:boilerplate/presentation/pages/users/profile_detail/profile_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoutePaths {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sandbox = '/sandbox';
  static const String profile = '/profile';
  static const String profileDetails = '/profile/:id';
  static const String unauthorized = '/unauthorized';
  // static const String adminDashboard = '/admin/dashboard';
  // static const String adminUsers = '/admin/users';
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
      path: RoutePaths.home,
      name: 'home',
      builder: (context, params) => const HomeScreen(),
      requiresAuth: true,
    ),
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
  ];

  static final List<RouteConfig> authenticatedRoutes = [
    RouteConfig(
      path: RoutePaths.profile,
      name: 'profile',
      builder: (context, params) => const ProfileScreen(),
      requiresAuth: true,
    ),
    RouteConfig(
      path: RoutePaths.profileDetails,
      name: 'profileDetails',
      builder: (context, params) => ProfileDetailsScreen(
        userId: params.pathParams['id'] ?? '',
      ),
      requiresAuth: true,
    ),
  ];

  // static final List<RouteConfig> adminRoutes = [
  //   RouteConfig(
  //     path: RoutePaths.adminDashboard,
  //     name: 'adminDashboard',
  //     builder: (context, params) => const AdminDashboardScreen(),
  //     requiresAuth: true,
  //     requiresAdmin: true,
  //     allowedRoles: ['admin'],
  //   ),
  //   RouteConfig(
  //     path: RoutePaths.adminUsers,
  //     name: 'adminUsers',
  //     builder: (context, params) => const AdminUsersScreen(),
  //     requiresAuth: true,
  //     requiresAdmin: true,
  //     allowedRoles: ['admin'],
  //   ),
  // ];

  static List<RouteConfig> get allRoutes => [
        ...publicRoutes,
        ...authenticatedRoutes,
        // ...adminRoutes,
      ];
}
