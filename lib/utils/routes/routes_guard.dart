import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/auth/get_current_user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes_config.dart';

class RouteGuard extends StatefulWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const RouteGuard({
    super.key,
    required this.child,
    this.allowedRoles,
  });

  @override
  State<RouteGuard> createState() => _RouteGuardState();

  static final authStateChanges = AuthStateNotifier();

  static String? globalRedirect(BuildContext context, GoRouterState state) {
    final authNotifier = authStateChanges;

    if (authNotifier.isLoading) {
      return null;
    }

    final isLoggedIn = authNotifier.isLoggedIn;
    final publicPaths = RoutesConfig.publicRoutes.map((r) => r.path).toList();
    final isPublicRoute = publicPaths.contains(state.matchedLocation);

    if (!isLoggedIn && !isPublicRoute) {
      return RoutePaths.login;
    }

    if (isLoggedIn && state.matchedLocation == RoutePaths.login) {
      return RoutePaths.home;
    }

    return null;
  }
}

class _RouteGuardState extends State<RouteGuard> {
  final GetCurrentUserUseCase _getCurrentUserUseCase =
      getIt<GetCurrentUserUseCase>();

  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userResult = await _getCurrentUserUseCase.execute(NoParams());

      if (!mounted) return;

      userResult.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _isAuthorized = false;
          });

          if (mounted) {
            context.go(RoutePaths.login);
          }
        },
        (user) {
          final hasAccess = _checkRoleAccess(user);

          setState(() {
            _isLoading = false;
            _isAuthorized = hasAccess;
          });

          if (!hasAccess && mounted) {
            context.go(RoutePaths.unauthorized);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isAuthorized = false;
      });

      if (mounted) {
        context.go(RoutePaths.login);
      }
    }
  }

  bool _checkRoleAccess(User? user) {
    if (user == null) return false;

    if (widget.allowedRoles == null || widget.allowedRoles!.isEmpty) {
      return true;
    }

    return widget.allowedRoles!.any((role) => user.roles.contains(role));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RoutePaths.unauthorized);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}

class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  User? _currentUser;

  AuthStateNotifier() {
    _checkAuthStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase.execute(NoParams());

      result.fold(
        (failure) {
          _isLoggedIn = false;
          _currentUser = null;
        },
        (user) {
          _isLoggedIn = user != null;
          _currentUser = user;
        },
      );
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    if (!value) {
      _currentUser = null;
    }
    notifyListeners();
  }

  void refreshAuthState() {
    _checkAuthStatus();
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    _isLoggedIn = user != null;
    notifyListeners();
  }
}
