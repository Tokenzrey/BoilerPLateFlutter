import 'package:boilerplate/presentation/pages/profile/profile_tab.dart';
import 'package:boilerplate/presentation/pages/profile/setting_tab.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/hoc/check_auth.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        title: const AppText(
          'Profile Settings',
          variant: TextVariant.headlineSmall,
          color: Colors.white,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.neutral.shade800,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                _buildTab(0, Icons.person, 'Profile'),
                _buildTab(1, Icons.settings, 'Settings'),
              ],
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral.shade400,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _tabController.animateTo(index, duration: Duration.zero);
            });
          }
        },
        children: [
          // Profile tab with auth check
          KeepAlivePage(
            child: AuthWidget(
              builder: (context) => const ProfileTab(),
              noAuthBuilder: (context) => const AuthRequiredView(
                title: 'Profile Access',
                message: 'Sign in to view and manage your profile information.',
                icon: Icons.person_outline,
              ),
            ),
          ),
          // Settings tab (always visible)
          const KeepAlivePage(child: SettingsTab()),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.neutral.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          AppText(
            label,
            variant: TextVariant.labelLarge,
            color: isSelected ? AppColors.primary : AppColors.neutral.shade400,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}

/// Professional UI/UX design for auth-required fallback view
class AuthRequiredView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String buttonText;

  const AuthRequiredView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.buttonText = 'Sign In',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.7),
                      AppColors.primary.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.slate.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AppText(
                title,
                variant: TextVariant.titleLarge,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              AppText(
                message,
                variant: TextVariant.bodyLarge,
                color: AppColors.neutral.shade400,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _AnimatedButton(
                onPressed: () => context.go('/login'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.login, size: 20),
                    const SizedBox(width: 8),
                    AppText(
                      buttonText,
                      variant: TextVariant.labelLarge,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const AppText(
                  'Create an account',
                  variant: TextVariant.bodyMedium,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated button with hover effect for better UX
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: _isHovered
                ? [AppColors.primary, AppColors.primary]
                : [AppColors.primary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper to keep tab pages alive when switching tabs
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
