import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/widgets/components/display/circular.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/constants/colors.dart';

enum AuthStatus { loading, authenticated, unauthenticated, roleDenied, error }

class AuthWidget extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? builder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noAuthBuilder;
  final Widget Function(BuildContext, String)? errorBuilder;
  final List<String>? requiredRoles;
  final RoleCheckStrategy roleCheckStrategy;
  final AuthStore? authStore;
  final ValueChanged<AuthStatus>? onAuthStateChanged;
  final AuthWidgetController? controller;

  const AuthWidget({
    super.key,
    this.child,
    this.builder,
    this.loadingBuilder,
    this.noAuthBuilder,
    this.errorBuilder,
    this.requiredRoles,
    this.roleCheckStrategy = RoleCheckStrategy.requireAny,
    this.authStore,
    this.onAuthStateChanged,
    this.controller,
  }) : assert(child != null || builder != null);

  static AuthWidgetController createController() => AuthWidgetController();

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

enum RoleCheckStrategy { requireAny, requireAll }

class AuthWidgetController {
  VoidCallback? _refreshCallback;
  void _registerCallback(VoidCallback callback) => _refreshCallback = callback;
  void refresh() => _refreshCallback?.call();
  void _detach() => _refreshCallback = null;
}

class _AuthWidgetState extends State<AuthWidget> {
  late AuthStore _authStore;
  AuthStatus _authStatus = AuthStatus.loading;
  List<ReactionDisposer> _disposers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    widget.controller?._registerCallback(_checkAuthStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authStore = widget.authStore ?? getIt<AuthStore>();
    _setupReactions();
    _checkAuthStatus();
  }

  @override
  void didUpdateWidget(covariant AuthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._registerCallback(_checkAuthStatus);
    }
    if (widget.authStore != oldWidget.authStore) {
      _disposeReactions();
      _authStore = widget.authStore ?? getIt<AuthStore>();
      _setupReactions();
      _checkAuthStatus();
    }
    if (widget.requiredRoles != oldWidget.requiredRoles ||
        widget.roleCheckStrategy != oldWidget.roleCheckStrategy) {
      _checkAuthStatus();
    }
  }

  @override
  void dispose() {
    _disposeReactions();
    widget.controller?._detach();
    super.dispose();
  }

  void _setupReactions() {
    _disposeReactions();
    _disposers.add(reaction((_) => _authStore.isLoggedIn, (_) {
      if (mounted) _checkAuthStatus();
    }));
    _disposers.add(reaction((_) => _authStore.isLoading, (_) {
      if (mounted) _checkAuthStatus();
    }));
    _disposers.add(reaction((_) => _authStore.currentUser?.roles, (_) {
      if (mounted) _checkAuthStatus();
    }));
    _disposers.add(reaction((_) => _authStore.errorMessage, (msg) {
      if (!mounted || msg == null || msg.isEmpty) return;
      _updateAuthStatus(AuthStatus.error, msg);
    }));
  }

  void _disposeReactions() {
    for (final d in _disposers) {
      d();
    }
    _disposers = [];
  }

  void _checkAuthStatus() {
    if (!mounted) return;
    try {
      if (_authStore.isLoading) {
        _updateAuthStatus(AuthStatus.loading);
        return;
      }
      if (!_authStore.isLoggedIn || _authStore.currentUser == null) {
        _updateAuthStatus(AuthStatus.unauthenticated);
        return;
      }
      // Check roles if specified
      if (widget.requiredRoles != null && widget.requiredRoles!.isNotEmpty) {
        final roles = _authStore.currentUser?.roles ?? [];
        bool hasRoles = widget.roleCheckStrategy == RoleCheckStrategy.requireAll
            ? widget.requiredRoles!.every((r) => roles.contains(r))
            : widget.requiredRoles!.any((r) => roles.contains(r));
        if (!hasRoles) {
          _updateAuthStatus(AuthStatus.roleDenied);
          return;
        }
      }
      _updateAuthStatus(AuthStatus.authenticated);
    } catch (e) {
      _updateAuthStatus(AuthStatus.error, e.toString());
    }
  }

  void _updateAuthStatus(AuthStatus status, [String errorMessage = '']) {
    if (!mounted) return;
    if (_authStatus != status ||
        (status == AuthStatus.error && _errorMessage != errorMessage)) {
      setState(() {
        _authStatus = status;
        _errorMessage = errorMessage;
      });
      widget.onAuthStateChanged?.call(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.loading:
        return widget.loadingBuilder?.call(context) ??
            const Center(child: AppCircularProgress());
      case AuthStatus.authenticated:
        return widget.builder?.call(context) ?? widget.child!;
      case AuthStatus.unauthenticated:
      case AuthStatus.roleDenied:
        return widget.noAuthBuilder?.call(context) ??
            Center(
              child: AppText(
                _authStatus == AuthStatus.roleDenied
                    ? 'You do not have permission to view this content.'
                    : 'Sign in to view your followed comics.',
                variant: TextVariant.bodyLarge,
                color: AppColors.destructive,
              ),
            );
      case AuthStatus.error:
        return widget.errorBuilder?.call(context, _errorMessage) ??
            Center(
              child: AppText(
                'Auth Error: $_errorMessage',
                color: AppColors.destructive,
              ),
            );
    }
  }
}
