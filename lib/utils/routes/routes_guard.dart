import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'routes_config.dart';

/// RouteGuard terintegrasi MobX AuthStore dan UseCase.
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

  /// NOTIFIER untuk GoRouter (refreshListenable)
  static final AuthStateNotifier authStateChanges = AuthStateNotifier();

  /// Redirect global GoRouter (pakai state dari AuthStateNotifier)
  static String? globalRedirect(BuildContext context, GoRouterState state) {
    final authNotifier = authStateChanges;

    if (authNotifier.isLoading) {
      // Biarkan router menunggu proses auth
      return null;
    }

    final isLoggedIn = authNotifier.isLoggedIn;
    final location = state.matchedLocation;

    // Improved route matching function
    bool isPublicRoute(String location) {
      // First, handle exact matches
      if (RoutesConfig.publicRoutes.any((route) => route.path == location)) {
        return true;
      }

      // Then handle routes with parameters
      for (final route in RoutesConfig.publicRoutes) {
        // Convert route path pattern like '/comicDetail/:comicId' to regex
        final pattern =
            '^${route.path.replaceAllMapped(RegExp(r':(\w+)'), (match) => '([^/]+)')}\$';

        try {
          if (RegExp(pattern).hasMatch(location)) {
            return true;
          }
        } catch (e) {
          // Log error but continue checking other routes
          debugPrint('Error matching route pattern: $e');
        }
      }
      return false;
    }

    // First check: Is this a public route? If yes, allow navigation regardless of auth
    if (isPublicRoute(location)) {
      return null;
    }

    // Second check: For non-public routes, check auth status
    if (!isLoggedIn) {
      // Only redirect to login for non-public routes when not logged in
      return RoutePaths.login;
    }

    // Special case: If logged in but trying to access login/register, redirect home
    if (isLoggedIn &&
        (location == RoutePaths.login || location == RoutePaths.register)) {
      return RoutePaths.home;
    }

    // Allow the navigation
    return null;
  }
}

/// Widget guard untuk role-based access di page
class _RouteGuardState extends State<RouteGuard> {
  final AuthStore _authStore = getIt<AuthStore>();
  final bool _isLocalAuthCheck = true; // Made final as it's never reassigned

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
      await _authStore.loadCurrentUser();

      if (!mounted) return;

      final user = _authStore.currentUser;
      final hasAccess = _checkRoleAccess(user);

      setState(() {
        _isLoading = false;
        _isAuthorized = hasAccess;
      });

      // Only navigate if this isn't just a local UI check
      if (!_isLocalAuthCheck) {
        if (!hasAccess && mounted) {
          context.go(RoutePaths.unauthorized);
        }
        if (user == null && mounted) {
          context.go(RoutePaths.login);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isAuthorized = false;
      });

      // Only navigate if this isn't just a local UI check
      if (!_isLocalAuthCheck && mounted) {
        context.go(RoutePaths.login);
      }
    }
  }

  bool _checkRoleAccess(User? user) {
    if (user == null) return false;
    final allowed = widget.allowedRoles;
    if (allowed == null || allowed.isEmpty) return true;
    return allowed.any((role) => user.roles.contains(role));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized) {
      // Only navigate if this isn't a local UI check
      if (!_isLocalAuthCheck) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RoutePaths.unauthorized);
        });
      }

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}

/// AuthStateNotifier listen ke AuthStore MobX,
/// dan trigger refresh ke GoRouter jika auth berubah.
class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  User? _currentUser;
  bool _isNavigating = false; // Added to prevent notification loops

  final AuthStore _authStore = getIt<AuthStore>();
  late final List<ReactionDisposer> _disposers;

  AuthStateNotifier() {
    // Sync awal
    _setupReactions();
    _initAuthState();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  void _setupReactions() {
    // Reaction MobX agar GoRouter refresh jika Auth berubah
    _disposers = [
      reaction((_) => _authStore.isLoggedIn, (bool isLoggedIn) {
        if (_isLoggedIn != isLoggedIn && !_isNavigating) {
          _isLoggedIn = isLoggedIn;
          _isNavigating = true;
          notifyListeners();
          // Reset flag after notification has been processed
          Future.microtask(() => _isNavigating = false);
        }
      }),
      reaction((_) => _authStore.isLoading, (bool loading) {
        if (_isLoading != loading && !_isNavigating) {
          _isLoading = loading;
          notifyListeners();
        }
      }),
      reaction((_) => _authStore.currentUser, (user) {
        if (_currentUser?.id != user?.id && !_isNavigating) {
          _currentUser = user;
          _isLoggedIn = user != null;
          _isNavigating = true;
          notifyListeners();
          // Reset flag after notification has been processed
          Future.microtask(() => _isNavigating = false);
        }
      }),
    ];
  }

  Future<void> _initAuthState() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authStore.checkLoginStatus();
      _currentUser = _authStore.currentUser;
      _isLoggedIn = _authStore.isLoggedIn;
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    super.dispose();
  }

  // Untuk force refresh dari luar jika perlu
  void refreshAuthState() {
    _initAuthState();
  }
}
