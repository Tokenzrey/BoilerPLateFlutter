import 'package:boilerplate/presentation/pages/not_found/not_found.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:boilerplate/utils/routes/routes_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static AppRouter? _instance;

  static AppRouter get instance {
    _instance ??= AppRouter._();
    return _instance!;
  }

  AppRouter._();
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final provider = Provider<GoRouter>(
    create: (context) => router,
    dispose: (_, router) => router.dispose(),
  );

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.comicContent,
    debugLogDiagnostics: true,
    routerNeglect: true,
    refreshListenable: RouteGuard.authStateChanges,
    redirect: RouteGuard.globalRedirect,
    routes: _buildRoutes(),
    errorBuilder: (context, state) => const RouteErrorScreen(),
  );

  static List<RouteBase> _buildRoutes() {
    final routes = <RouteBase>[];

    for (final routeConfig in RoutesConfig.publicRoutes) {
      routes.add(_createRoute(routeConfig));
    }

    for (final routeConfig in RoutesConfig.authenticatedRoutes) {
      routes.add(_createRoute(routeConfig, withGuard: true));
    }

    return routes;
  }

  static RouteBase _createRoute(RouteConfig config,
      {bool withGuard = false, bool adminOnly = false}) {
    Widget pageBuilder(BuildContext context, GoRouterState state) {
      final params = state.pathParameters;
      final queryParams = state.uri.queryParameters;
      final extra = state.extra;

      return config.builder(
          context,
          RouteParams(
              pathParams: params, queryParams: queryParams, extra: extra));
    }

    if (config.isShell) {
      return ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            config.shellBuilder!(context, state, child),
        routes: config.children
                ?.map((child) => _createRoute(child,
                    withGuard: withGuard || child.requiresAuth,
                    adminOnly: adminOnly || child.requiresAdmin))
                .toList() ??
            [],
      );
    }

    final route = GoRoute(
      path: config.path,
      name: config.name,
      parentNavigatorKey: config.fullscreenDialog ? _rootNavigatorKey : null,
      builder: withGuard
          ? (context, state) => RouteGuard(
                allowedRoles: adminOnly ? ['admin'] : config.allowedRoles,
                child:
                    Builder(builder: (context) => pageBuilder(context, state)),
              )
          : pageBuilder,
    );

    return route;
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Map<String, String>? params,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    GoRouterContextExtensions(context).goNamed(
      routeName,
      pathParameters: params ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }

  static void navigateReplacement(
    BuildContext context,
    String routeName, {
    Map<String, String>? params,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    GoRouterContextExtensions(context).replaceNamed(
      routeName,
      pathParameters: params ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }

  static String namedLocation(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    String? fragment,
  }) =>
      GoRouter.of(context).namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        fragment: fragment,
      );

  static void go(BuildContext context, String location, {Object? extra}) =>
      GoRouter.of(context).go(location, extra: extra);

  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) =>
      GoRouter.of(context).goNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
        fragment: fragment,
      );

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) =>
      GoRouter.of(context).push<T>(location, extra: extra);

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(context).pushNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  static bool canPop(BuildContext context) => GoRouter.of(context).canPop();

  static void pop<T extends Object?>(BuildContext context, [T? result]) =>
      GoRouter.of(context).pop(result);

  static void pushReplacement(
    BuildContext context,
    String location, {
    Object? extra,
  }) =>
      GoRouter.of(context).pushReplacement(location, extra: extra);

  static void pushReplacementNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(context).pushReplacementNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  static void replace(BuildContext context, String location, {Object? extra}) =>
      GoRouter.of(context).replace(location, extra: extra);

  static void replaceNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(context).replaceNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
}

extension GoRouterContextExtensions on BuildContext {
  GoRouter get router => GoRouter.of(this);

  void go(String location, {Object? extra}) =>
      AppRouter.go(this, location, extra: extra);

  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) =>
      AppRouter.goNamed(
        this,
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
        fragment: fragment,
      );

  Future<T?> push<T extends Object?>(String location, {Object? extra}) =>
      AppRouter.push<T>(this, location, extra: extra);

  bool canPop() => AppRouter.canPop(this);

  void pop<T extends Object?>([T? result]) => AppRouter.pop<T>(this, result);

  void replace(String location, {Object? extra}) =>
      AppRouter.replace(this, location, extra: extra);

  void replaceNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      AppRouter.replaceNamed(
        this,
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
}
