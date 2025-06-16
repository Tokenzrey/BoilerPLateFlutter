import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/utils/hoc/check_auth.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopoverMenu extends StatelessWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSignoutPressed;
  final bool isLoggedIn;
  final String? username;

  const PopoverMenu({
    super.key,
    this.onProfilePressed,
    this.onSignoutPressed,
    this.isLoggedIn = false,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);
    // Get AuthStore instance from service locator
    final AuthStore authStore = getIt<AuthStore>();
    final avatarId = authStore.currentUser?.avatar ?? "0";

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          minWidth: 150,
          maxHeight: 360, // Increased to accommodate username display
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral[850]?.withValues(alpha: 0.99) ??
              Colors.grey.shade900,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoggedIn && username != null) ...[
              // User profile info section
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/avatar/avatar$avatarId.png'),
                    backgroundColor: AppColors.neutral.shade800,
                    child: _buildPlaceholderIfNeeded(avatarId),
                  ),
                  const SizedBox(width: 12),
                  // Username and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          username!,
                          variant: TextVariant.labelLarge,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        AppText(
                          'Online',
                          variant: TextVariant.labelSmall,
                          color: Colors.green.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: Colors.white.withValues(alpha: 0.15),
                height: 1,
              ),
              const SizedBox(height: 16),
            ],
            _menuItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              desc: isLoggedIn
                  ? 'View and edit your profile'
                  : 'Sign in to view profile',
              onTap: () {
                context.push('/profile');
                closeOverlay(context, 'Profile');
                onProfilePressed?.call();
              },
            ),
            const SizedBox(height: 10),
            _menuItem(
              context,
              icon: Icons.science_outlined,
              label: 'Sandbox',
              desc: 'Sandbox Component',
              danger: true,
              onTap: () {
                context.push('/sandbox');
                closeOverlay(context, 'Sandbox');
              },
            ),
            if (!isLoggedIn)
              _menuItem(
            AuthWidget(
              // Show Sign In option when user is not authenticated
              noAuthBuilder: (context) => _menuItem(
                context,
                icon: Icons.login_rounded,
                label: 'Sign In',
                desc: 'Sign in to your account',
                danger: false,
                onTap: () {
                  context.push('/login');
                  closeOverlay(context, 'SignIn');
                },
              )
            else
              // Show Sign Out option when user is authenticated
              _menuItem(
              ),
              // Show Sign Out option when user is authenticated
              child: _menuItem(
                context,
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                desc: 'Log out from this account',
                danger: true,
                onTap: () {
                  SharedPreferences.getInstance().then((preference) {
                    preference.setBool(Preferences.isLoggedIn, false);
                    authStore.logout();
                    if (context.mounted) {
                      context.go(RoutePaths.unauthorized);
                    }
                  });
                  closeOverlay(context, 'Signout');
                  onSignoutPressed?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // In case images fail to load, show a fallback icon
  Widget? _buildPlaceholderIfNeeded(String avatarId) {
    // This is a placeholder in case image assets fail to load
    try {
      // Try to load the asset
      AssetImage('assets/avatars/avatar_$avatarId.png');
      return null;
    } catch (e) {
      // If asset fails to load, show this icon
      return const Icon(Icons.person, size: 20, color: Colors.white70);
    }
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String desc,
    bool danger = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      splashColor:
          (danger ? Colors.red : AppColors.primary).withValues(alpha: 0.13),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: danger ? Colors.redAccent : Colors.white,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        color: danger ? Colors.redAccent : Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.3,
                        color: danger
                            ? Colors.redAccent.withValues(alpha: 0.74)
                            : Colors.white.withValues(alpha: 0.62)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
