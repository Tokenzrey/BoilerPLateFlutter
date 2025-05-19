import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'routes_config.dart';

/// RouteGuard terintegrasi MobX AuthStore dan UseCase.
/// Pastikan AuthStore sudah singleton di getIt.
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
      // Biarkan router menunggu
      return null;
    }

    final isLoggedIn = authNotifier.isLoggedIn;
    final publicPaths = RoutesConfig.publicRoutes.map((r) => r.path).toList();
    final isPublicRoute = publicPaths.contains(state.matchedLocation);

    // Jika belum login dan akses route privat, arahkan ke login
    if (!isLoggedIn && !isPublicRoute) {
      return RoutePaths.login;
    }

    // Jika sudah login dan akses ke login page, arahkan ke home
    if (isLoggedIn && state.matchedLocation == RoutePaths.login) {
      return RoutePaths.home;
    }

    return null;
  }
}

/// Widget guard untuk role-based access di page
class _RouteGuardState extends State<RouteGuard> {
  final AuthStore _authStore = getIt<AuthStore>();

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
      // Pastikan status user sudah up-to-date
      await _authStore.loadCurrentUser();

      if (!mounted) return;

      final user = _authStore.currentUser;
      final hasAccess = _checkRoleAccess(user);

      setState(() {
        _isLoading = false;
        _isAuthorized = hasAccess;
      });

      if (!hasAccess && mounted) {
        context.go(RoutePaths.unauthorized);
      }
      if (user == null && mounted) {
        context.go(RoutePaths.login);
      }
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
    final allowed = widget.allowedRoles;
    if (allowed == null || allowed.isEmpty) return true; // Semua role boleh
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

/// AuthStateNotifier listen ke AuthStore MobX,
/// dan trigger refresh ke GoRouter jika auth berubah.
class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  User? _currentUser;

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
        _isLoggedIn = isLoggedIn;
        notifyListeners();
      }),
      reaction((_) => _authStore.isLoading, (bool loading) {
        _isLoading = loading;
        notifyListeners();
      }),
      reaction((_) => _authStore.currentUser, (user) {
        _currentUser = user;
        _isLoggedIn = user != null;
        notifyListeners();
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
