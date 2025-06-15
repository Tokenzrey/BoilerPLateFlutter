import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';

class PopoverMenu extends StatelessWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSignoutPressed;

  const PopoverMenu({
    super.key,
    this.onProfilePressed,
    this.onSignoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          minWidth: 150,
          maxHeight: 320,
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
            _menuItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              desc: 'View and edit your profile',
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
            _menuItem(
              context,
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              desc: 'Log out from this account',
              danger: true,
              onTap: () {
                closeOverlay(context, 'Signout');
                onSignoutPressed?.call();
              },
            ),
          ],
        ),
      ),
    );
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
