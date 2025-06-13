import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/utils/hoc/check_auth.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';

class AuthSandbox extends StatefulWidget {
  const AuthSandbox({super.key});

  @override
  State<AuthSandbox> createState() => _AuthSandboxState();
}

class _AuthSandboxState extends State<AuthSandbox> {
  late AuthStore _authStore;

  // AuthWidget controller for refreshing auth state
  final AuthWidgetController _authController = AuthWidget.createController();

  // UI state
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  List<String> _userRoles = ['user'];
  final List<String> _requiredRoles = ['user'];
  RoleCheckStrategy _roleCheckStrategy = RoleCheckStrategy.requireAny;

  // Track the current displayed component
  int _currentExample = 0;

  // Track auth status changes for demo purposes
  AuthStatus _lastAuthStatus = AuthStatus.loading;

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
  }

  void _toggleLoggedIn() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
      if (_errorMessage != null) _errorMessage = null;
    });
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _setError(String? message) {
    setState(() {
      _errorMessage = message;
      if (message != null) {
        _isLoggedIn = false;
        _isLoading = false;
      }
    });
  }

  void _toggleRole(String role) {
    setState(() {
      if (_userRoles.contains(role)) {
        _userRoles.remove(role);
      } else {
        _userRoles.add(role);
      }
    });
  }

  void _toggleRequiredRole(String role) {
    setState(() {
      if (_requiredRoles.contains(role)) {
        _requiredRoles.remove(role);
      } else {
        _requiredRoles.add(role);
      }
    });
  }

  void _toggleRoleCheckStrategy() {
    setState(() {
      _roleCheckStrategy = _roleCheckStrategy == RoleCheckStrategy.requireAny
          ? RoleCheckStrategy.requireAll
          : RoleCheckStrategy.requireAny;
    });
  }

  // Fix: Save auth status changes without using setState during build
  void _handleAuthStateChanged(AuthStatus status) {
    // Schedule state update for after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _lastAuthStatus = status;
        });
      }
    });
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Auth Widget Sandbox Controls',
            variant: TextVariant.titleLarge,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Auth State Controls
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildControlButton(
                'Toggle Logged In',
                onPressed: _toggleLoggedIn,
                active: _isLoggedIn,
                activeColor: AppColors.success,
              ),
              _buildControlButton(
                'Toggle Loading',
                onPressed: _toggleLoading,
                active: _isLoading,
                activeColor: AppColors.primary,
              ),
              _buildControlButton(
                'Set Error',
                onPressed: () => _setError('Authentication error for demo'),
                active: _errorMessage != null,
                activeColor: AppColors.destructive,
              ),
              _buildControlButton(
                'Clear Error',
                onPressed: () => _setError(null),
                active: false,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Role Controls
          AppText(
            'User Roles:',
            variant: TextVariant.titleSmall,
            color: AppColors.foreground,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip('user', _userRoles.contains('user'),
                  onTap: () => _toggleRole('user')),
              _buildRoleChip('admin', _userRoles.contains('admin'),
                  onTap: () => _toggleRole('admin')),
              _buildRoleChip('editor', _userRoles.contains('editor'),
                  onTap: () => _toggleRole('editor')),
              _buildRoleChip('viewer', _userRoles.contains('viewer'),
                  onTap: () => _toggleRole('viewer')),
            ],
          ),
          const SizedBox(height: 12),

          // Required Role Controls
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Required Roles:',
                      variant: TextVariant.titleSmall,
                      color: AppColors.foreground,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRoleChip('user', _requiredRoles.contains('user'),
                            onTap: () => _toggleRequiredRole('user')),
                        _buildRoleChip(
                            'admin', _requiredRoles.contains('admin'),
                            onTap: () => _toggleRequiredRole('admin')),
                        _buildRoleChip(
                            'editor', _requiredRoles.contains('editor'),
                            onTap: () => _toggleRequiredRole('editor')),
                        _buildRoleChip(
                            'viewer', _requiredRoles.contains('viewer'),
                            onTap: () => _toggleRequiredRole('viewer')),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Role Strategy:',
                    variant: TextVariant.titleSmall,
                    color: AppColors.foreground,
                  ),
                  const SizedBox(height: 8),
                  _buildControlButton(
                    _roleCheckStrategy == RoleCheckStrategy.requireAny
                        ? 'Require Any'
                        : 'Require All',
                    onPressed: _toggleRoleCheckStrategy,
                    active: true,
                    activeColor:
                        _roleCheckStrategy == RoleCheckStrategy.requireAny
                            ? AppColors.accent
                            : AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Example Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Example: ${_currentExample + 1}/5',
                variant: TextVariant.titleSmall,
                color: AppColors.foreground,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentExample > 0
                        ? () => setState(() => _currentExample--)
                        : null,
                    color: AppColors.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentExample < 4
                        ? () => setState(() => _currentExample++)
                        : null,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 24),

          // Current Auth Status Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAuthStatusColor(_lastAuthStatus),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppText(
                  'Auth Status: ${_lastAuthStatus.name}',
                  variant: TextVariant.labelMedium,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAuthStatusColor(AuthStatus status) {
    switch (status) {
      case AuthStatus.loading:
        return AppColors.blue;
      case AuthStatus.authenticated:
        return AppColors.green;
      case AuthStatus.unauthenticated:
        return AppColors.accent;
      case AuthStatus.roleDenied:
        return AppColors.warning;
      case AuthStatus.error:
        return AppColors.destructive;
    }
  }

  Widget _buildControlButton(String label,
      {required VoidCallback onPressed,
      bool active = false,
      Color activeColor = AppColors.primary}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            active ? activeColor : AppColors.muted.withValues(alpha: 0.2),
        foregroundColor: active ? Colors.white : AppColors.mutedForeground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildRoleChip(String role, bool isSelected,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: AppText(
          role,
          variant: TextVariant.labelSmall,
          color: isSelected ? AppColors.cardForeground : AppColors.foreground,
        ),
        backgroundColor:
            isSelected ? AppColors.primary : AppColors.subtleBackground,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildExampleDisplay() {
    switch (_currentExample) {
      case 0:
        return _buildBasicExample();
      case 1:
        return _buildCustomBuildersExample();
      case 2:
        return _buildRoleBasedExample();
      case 3:
        return _buildNestedAuthExample();
      case 4:
        return _buildAdvancedExample();
      default:
        return _buildBasicExample();
    }
  }

  Widget _buildBasicExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Basic Example',
          variant: TextVariant.headlineSmall,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          'Simple authentication check with default loading, error, and unauthenticated views.',
          variant: TextVariant.bodyMedium,
          color: AppColors.foreground,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 250,
            child: AuthWidget(
              authStore: _authStore,
              // Fix: Move setState to post-frame callback
              onAuthStateChanged: _handleAuthStateChanged,
              controller: _authController,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.success.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Authenticated Content',
                        variant: TextVariant.titleLarge,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'You are viewing protected content',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.foreground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomBuildersExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Custom Builders Example',
          variant: TextVariant.headlineSmall,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          'Customized loading, error, and unauthenticated views using builder functions.',
          variant: TextVariant.bodyMedium,
          color: AppColors.foreground,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 250,
            child: AuthWidget(
              authStore: _authStore,
              onAuthStateChanged: _handleAuthStateChanged,
              controller: _authController,

              // Custom loading builder
              loadingBuilder: (context) => Container(
                color: AppColors.background.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Loading your experience...',
                        variant: TextVariant.titleMedium,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),

              // Custom no auth builder
              noAuthBuilder: (context) => Container(
                color: AppColors.warning.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        color: AppColors.warning,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Access Restricted',
                        variant: TextVariant.titleLarge,
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Please sign in to view this content',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.foreground,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _toggleLoggedIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.accentForeground,
                        ),
                        child: const Text('Sign In Now'),
                      ),
                    ],
                  ),
                ),
              ),

              // Custom error builder
              errorBuilder: (context, error) => Container(
                color: AppColors.destructive.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.destructive,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Something went wrong',
                        variant: TextVariant.titleLarge,
                        color: AppColors.destructive,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppText(
                          error,
                          variant: TextVariant.bodyMedium,
                          color: AppColors.destructiveForeground,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _setError(null),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: AppColors.destructiveForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main content
              builder: (context) => Container(
                color: AppColors.accent.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: AppColors.accent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'VIP Content',
                        variant: TextVariant.titleLarge,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Welcome to the exclusive area',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.foreground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBasedExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Role-Based Example',
          variant: TextVariant.headlineSmall,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          'Access control based on user roles with different role check strategies.',
          variant: TextVariant.bodyMedium,
          color: AppColors.foreground,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 250,
            child: AuthWidget(
              authStore: _authStore,
              onAuthStateChanged: _handleAuthStateChanged,
              controller: _authController,
              requiredRoles: _requiredRoles,
              roleCheckStrategy: _roleCheckStrategy,

              // Custom no auth builder that distinguishes between unauthenticated and role denied
              noAuthBuilder: (context) {
                // Check roles manually to determine which message to show
                final bool isAuthenticatedButDenied =
                    _authStore.isLoggedIn && _authStore.currentUser != null;

                return Container(
                  color: isAuthenticatedButDenied
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.muted.withValues(alpha: 0.1),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAuthenticatedButDenied
                              ? Icons.no_accounts
                              : Icons.login,
                          color: isAuthenticatedButDenied
                              ? AppColors.warning
                              : AppColors.muted,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          isAuthenticatedButDenied
                              ? 'Insufficient Permissions'
                              : 'Authentication Required',
                          variant: TextVariant.titleLarge,
                          color: isAuthenticatedButDenied
                              ? AppColors.warning
                              : AppColors.muted,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: AppText(
                            isAuthenticatedButDenied
                                ? 'You do not have the required roles: ${_requiredRoles.join(", ")}'
                                : 'Please sign in to access this content',
                            variant: TextVariant.bodyMedium,
                            color: AppColors.foreground,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isAuthenticatedButDenied)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _userRoles = List.from(_requiredRoles);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: AppColors.warningForeground,
                            ),
                            child: const Text('Grant Required Roles'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _toggleLoggedIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.muted,
                              foregroundColor: AppColors.mutedForeground,
                            ),
                            child: const Text('Sign In'),
                          ),
                      ],
                    ),
                  ),
                );
              },

              // Protected content
              child: Container(
                color: AppColors.secondary.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.secondary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Role-Protected Content',
                        variant: TextVariant.titleLarge,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Your roles: ${_userRoles.join(", ")}',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.secondaryForeground,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppText(
                          'Required roles: ${_requiredRoles.join(", ")} (${_roleCheckStrategy == RoleCheckStrategy.requireAny ? "Any" : "All"})',
                          variant: TextVariant.bodyMedium,
                          color: AppColors.foreground,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNestedAuthExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Nested Auth Example',
          variant: TextVariant.headlineSmall,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          'Multiple AuthWidgets with different role requirements.',
          variant: TextVariant.bodyMedium,
          color: AppColors.foreground,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 250,
            child: AuthWidget(
              authStore: _authStore,
              onAuthStateChanged: _handleAuthStateChanged,
              controller: _authController,
              requiredRoles: ['user'], // Basic auth check

              builder: (context) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // User content
                    Container(
                      width: 180,
                      color: AppColors.blue.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.blue,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'User Content',
                            variant: TextVariant.titleMedium,
                            color: AppColors.blue,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'Available to all users',
                            variant: TextVariant.bodySmall,
                            color: AppColors.foreground,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Admin content
                    SizedBox(
                      width: 180,
                      child: AuthWidget(
                        authStore: _authStore,
                        requiredRoles: ['admin'],
                        noAuthBuilder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.neutral[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                color: AppColors.neutral[500],
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Admin Only',
                                variant: TextVariant.titleMedium,
                                color: AppColors.neutral[600],
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Requires admin role',
                                variant: TextVariant.bodySmall,
                                color: AppColors.neutral[700],
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: AppColors.secondary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Admin Content',
                                variant: TextVariant.titleMedium,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Restricted admin tools',
                                variant: TextVariant.bodySmall,
                                color: AppColors.foreground,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Editor content
                    SizedBox(
                      width: 180,
                      child: AuthWidget(
                        authStore: _authStore,
                        requiredRoles: ['editor'],
                        noAuthBuilder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.neutral[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                color: AppColors.neutral[500],
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Editor Only',
                                variant: TextVariant.titleMedium,
                                color: AppColors.neutral[600],
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Requires editor role',
                                variant: TextVariant.bodySmall,
                                color: AppColors.neutral[700],
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.green.withValues(alpha: 0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                color: AppColors.green,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Editor Content',
                                variant: TextVariant.titleMedium,
                                color: AppColors.green,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Content creation tools',
                                variant: TextVariant.bodySmall,
                                color: AppColors.foreground,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Advanced Example',
          variant: TextVariant.headlineSmall,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          'Multiple auth states in tabs with refresh capability.',
          variant: TextVariant.bodyMedium,
          color: AppColors.foreground,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: AppColors.primary,
                  child: TabBar(
                    tabs: const [
                      Tab(text: 'User View'),
                      Tab(text: 'Admin View'),
                      Tab(text: 'Multi-Role'),
                    ],
                    labelColor: AppColors.primaryForeground,
                    unselectedLabelColor:
                        AppColors.primaryForeground.withValues(alpha: 0.7),
                    indicatorColor: AppColors.primaryForeground,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      // User tab
                      AuthWidget(
                        authStore: _authStore,
                        requiredRoles: ['user'],
                        onAuthStateChanged: _handleAuthStateChanged,
                        controller: _authController,
                        child: _buildDashboardContent(
                          'User Dashboard',
                          'Basic user features available here',
                          Icons.person,
                          AppColors.accent,
                        ),
                      ),

                      // Admin tab
                      AuthWidget(
                        authStore: _authStore,
                        requiredRoles: ['admin'],
                        controller: _authController,
                        child: _buildDashboardContent(
                          'Admin Dashboard',
                          'Powerful admin controls available',
                          Icons.admin_panel_settings,
                          AppColors.secondary,
                        ),
                      ),

                      // Multi-role tab
                      AuthWidget(
                        authStore: _authStore,
                        requiredRoles: ['editor', 'admin'],
                        roleCheckStrategy: RoleCheckStrategy.requireAny,
                        controller: _authController,
                        child: _buildDashboardContent(
                          'Content Management',
                          'Available to editors or admins',
                          Icons.edit_document,
                          AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          AppText(
            title,
            variant: TextVariant.titleLarge,
            color: color,
          ),
          const SizedBox(height: 8),
          AppText(
            subtitle,
            variant: TextVariant.bodyMedium,
            color: AppColors.foreground,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _authController.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh Auth State'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlPanel(),
          _buildExampleDisplay(),
        ],
      ),
    );
  }
}
