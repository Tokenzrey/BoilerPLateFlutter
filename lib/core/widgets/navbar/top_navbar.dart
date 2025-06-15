import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:boilerplate/utils/routes/routes.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  TopNavbar({super.key});

  final LayerLink _searchLayerLink = LayerLink();
  final LayerLink _profileLayerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final double navbarRadius = 16;
    final double horizontalPad = 18;
    final double verticalPad = 12;
    final double logoSize = 38;

    return Container(
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      child: Material(
        elevation: 8,
        color: AppColors.primary.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(navbarRadius),
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: kToolbarHeight + verticalPad * 2,
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPad, vertical: verticalPad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(navbarRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => context.push('home'),
                    child: Container(
                      color: Colors.transparent,
                      child: Image.asset(
                        'assets/icons/ic_app.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Spacer(),
                CompositedTransformTarget(
                  link: _searchLayerLink,
                  child: _MinimalIconButton(
                    icon: Icons.search_rounded,
                    iconColor: Colors.white.withValues(alpha: 0.92),
                    iconSize: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    radius: 20,
                    onTap: () {
                      showPopover(
                        context: context,
                        layerLink: _searchLayerLink,
                        alignment: Alignment.topCenter,
                        anchorAlignment: Alignment.bottomCenter,
                        offset: const Offset(0, 10),
                        alwaysFocus: true,
                        stayVisibleOnScroll: false,
                        enterAnimations: [
                          PopoverAnimationType.fadeIn,
                          PopoverAnimationType.slideDown,
                          PopoverAnimationType.scale
                        ],
                        builder: (_) => const SearchModal(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CompositedTransformTarget(
                  link: _profileLayerLink,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showPopover(
                        context: context,
                        layerLink: _profileLayerLink,
                        alignment: Alignment.topRight,
                        anchorAlignment: Alignment.bottomRight,
                        offset: const Offset(-16, 10),
                        enterAnimations: [
                          PopoverAnimationType.fadeIn,
                          PopoverAnimationType.slideDown,
                          PopoverAnimationType.scale
                        ],
                        builder: (_) => PopoverMenu(
                          onProfilePressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Profile feature coming soon.")),
                            );
                          },
                          onSignoutPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Sign out feature coming soon.")),
                            );
                          },
                        ),
                      );
                    },
                    child: AppImage.avatar(
                      src: "assets/images/avatar/avatar1.png",
                      size: 36,
                      source: ImageSource.asset,
                      errorWidget: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.neutral.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.neutral.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 32);
}

class _MinimalIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double radius;

  const _MinimalIconButton({
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
    this.backgroundColor,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
