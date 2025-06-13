import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/widgets/components/display/circular.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/constants/colors.dart';

/// Enum representing the current authentication status
enum AuthStatus {
  /// Currently checking authentication state
  loading,

  /// User is authenticated and meets role requirements (if any)
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// User is authenticated but doesn't have required roles
  roleDenied,

  /// An error occurred during authentication check
  error,
}

/// A higher-order component (HOC) for widget-level authentication.
///
/// This widget checks if the current user is authenticated and optionally if they have
/// the required roles. It then renders the appropriate widget based on that status.
class AuthWidget extends StatefulWidget {
  /// Child widget to display when authenticated and role requirements are met.
  /// Either [child] or [builder] must be provided.
  final Widget? child;

  /// Builder function for creating a widget when authenticated and role requirements are met.
  /// Either [child] or [builder] must be provided.
  final WidgetBuilder? builder;

  /// Builder function for creating a loading widget.
  /// Defaults to a centered CircularIndicator.
  final WidgetBuilder? loadingBuilder;

  /// Builder function for creating a widget when not authenticated or role requirements not met.
  /// Defaults to a simple centered text message.
  final WidgetBuilder? noAuthBuilder;

  /// Builder function for creating a widget when an error occurs during authentication check.
  final Widget Function(BuildContext, String)? errorBuilder;

  /// List of roles required to access the content.
  /// If provided, the user must have the required roles based on [roleCheckStrategy].
  final List<String>? requiredRoles;

  /// Strategy for checking roles - default is to require any of the specified roles
  final RoleCheckStrategy roleCheckStrategy;

  /// Custom AuthStore instance for testing or manual dependency injection.
  /// If not provided, it will be obtained from the service locator.
  final AuthStore? authStore;

  /// Callback triggered when authentication status changes.
  final ValueChanged<AuthStatus>? onAuthStateChanged;

  /// Controller for refreshing the auth state
  final AuthWidgetController? controller;

  /// Creates an AuthWidget that conditionally renders content based on authentication status.
  ///
  /// Either [child] or [builder] must be provided.
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
  }) : assert(child != null || builder != null,
            'Either child or builder must be provided');

  /// Creates a refresh controller for externally triggering auth state refresh
  static AuthWidgetController createController() => AuthWidgetController();

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

/// Strategy for checking user roles
enum RoleCheckStrategy {
  /// User must have at least one of the required roles
  requireAny,

  /// User must have all of the required roles
  requireAll,
}

/// Controller for externally refreshing auth widget state
class AuthWidgetController {
  VoidCallback? _refreshCallback;

  /// Register the refresh callback
  void _registerCallback(VoidCallback callback) {
    _refreshCallback = callback;
  }

  /// Manually trigger a refresh of the auth state
  void refresh() {
    _refreshCallback?.call();
  }

  /// Detach the callback when the widget is disposed
  void _detach() {
    _refreshCallback = null;
  }
}

class _AuthWidgetState extends State<AuthWidget> {
  late AuthStore _authStore;
  AuthStatus _authStatus = AuthStatus.loading;
  List<ReactionDisposer> _disposers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Setup controller if provided
    if (widget.controller != null) {
      widget.controller!._registerCallback(_checkAuthStatus);
    }

    // Defer auth store setup to didChangeDependencies where we have context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAuthStore();
    // Immediately check status after setup
    _checkAuthStatus();
  }

  @override
  void didUpdateWidget(AuthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsRecheck = false;

    // Check if controller changed
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._registerCallback(_checkAuthStatus);
    }

    // Check if auth store changed
    if (widget.authStore != oldWidget.authStore) {
      // Clean up old reactions
      _disposeReactions();
      // Setup with new auth store
      _setupAuthStore();
      needsRecheck = true;
    }

    // Check if role requirements changed
    if (_areRoleRequirementsDifferent(oldWidget)) {
      needsRecheck = true;
    }

    // Check if role strategy changed
    if (widget.roleCheckStrategy != oldWidget.roleCheckStrategy) {
      needsRecheck = true;
    }

    // Recheck auth status if needed
    if (needsRecheck) {
      _checkAuthStatus();
    }
  }

  bool _areRoleRequirementsDifferent(AuthWidget oldWidget) {
    if (widget.requiredRoles == oldWidget.requiredRoles) return false;
    if (widget.requiredRoles == null || oldWidget.requiredRoles == null) {
      return true;
    }
    if (widget.requiredRoles!.length != oldWidget.requiredRoles!.length) {
      return true;
    }

    // Check each role in order
    for (int i = 0; i < widget.requiredRoles!.length; i++) {
      if (widget.requiredRoles![i] != oldWidget.requiredRoles![i]) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _disposeReactions();
    widget.controller?._detach();
    super.dispose();
  }

  void _disposeReactions() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers = [];
  }

  void _setupAuthStore() {
    try {
      // Get AuthStore from props or getIt
      _authStore = widget.authStore ?? getIt<AuthStore>();
      _setupReactions();
    } catch (e) {
      _updateAuthStatus(
          AuthStatus.error, 'Failed to initialize authentication: $e');
    }
  }

  void _setupReactions() {
    // Clean up any old reactions first
    _disposeReactions();

    // Listen for changes in auth state and update accordingly
    _disposers.add(reaction(
      (_) => _authStore.isLoggedIn,
      (_) {
        if (mounted) {
          _checkAuthStatus();
        }
      },
    ));

    _disposers.add(reaction(
      (_) => _authStore.isLoading,
      (loading) {
        if (!mounted) return;

        if (loading) {
          _updateAuthStatus(AuthStatus.loading);
        } else {
          _checkAuthStatus();
        }
      },
    ));

    _disposers.add(reaction(
      (_) => _authStore.currentUser?.roles,
      (_) {
        if (mounted) {
          _checkAuthStatus();
        }
      },
    ));

    // Also react to auth errors
    _disposers.add(reaction(
      (_) => _authStore.errorMessage,
      (errorMsg) {
        if (!mounted || errorMsg == null || errorMsg.isEmpty) return;
        _updateAuthStatus(AuthStatus.error, errorMsg);
      },
    ));
  }

  void _checkAuthStatus() {
    if (!mounted) return;

    try {
      // First check if auth is still loading
      if (_authStore.isLoading) {
        _updateAuthStatus(AuthStatus.loading);
        return;
      }

      // Then check if the user is authenticated
      if (!_authStore.isLoggedIn || _authStore.currentUser == null) {
        _updateAuthStatus(AuthStatus.unauthenticated);
        return;
      }

      // Check roles if requiredRoles is provided
      if (widget.requiredRoles != null && widget.requiredRoles!.isNotEmpty) {
        final userRoles = _authStore.currentUser?.roles ?? [];
        bool hasRequiredRoles;

        if (widget.roleCheckStrategy == RoleCheckStrategy.requireAny) {
          // User must have at least one of the required roles
          hasRequiredRoles =
              widget.requiredRoles!.any((role) => userRoles.contains(role));
        } else {
          // User must have all of the required roles
          hasRequiredRoles =
              widget.requiredRoles!.every((role) => userRoles.contains(role));
        }

        if (!hasRequiredRoles) {
          _updateAuthStatus(AuthStatus.roleDenied);
          return;
        }
      }

      _updateAuthStatus(AuthStatus.authenticated);
    } catch (e) {
      _updateAuthStatus(
          AuthStatus.error, 'Error checking authentication status: $e');
    }
  }

  void _updateAuthStatus(AuthStatus status, [String errorMessage = '']) {
    if (!mounted) return;

    // Only update state if something changed
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
        return _buildLoadingWidget(context);
      case AuthStatus.authenticated:
        return _buildAuthenticatedWidget(context);
      case AuthStatus.unauthenticated:
      case AuthStatus.roleDenied:
        return _buildNoAuthWidget(context);
      case AuthStatus.error:
        return _buildErrorWidget(context);
    }
  }

  Widget _buildLoadingWidget(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    return const Center(child: AppCircularProgress());
  }

  Widget _buildAuthenticatedWidget(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context);
    }
    return widget.child!;
  }

  Widget _buildNoAuthWidget(BuildContext context) {
    if (widget.noAuthBuilder != null) {
      return widget.noAuthBuilder!(context);
    }

    final statusMessage = _authStatus == AuthStatus.roleDenied
        ? 'You do not have the required permissions for this content'
        : 'Authentication required to access this content';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: AppText(
          statusMessage,
          variant: TextVariant.bodyLarge,
          color: AppColors.destructive,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _errorMessage);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.destructive.withValues(alpha: .3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.destructive, size: 48),
            const SizedBox(height: 16),
            AppText(
              'Authentication Error',
              variant: TextVariant.titleLarge,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 8),
            AppText(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'An error occurred while checking authentication status',
              variant: TextVariant.bodyMedium,
              color: AppColors.mutedForeground,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAuthStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: const AppText(
                'Retry',
                variant: TextVariant.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
