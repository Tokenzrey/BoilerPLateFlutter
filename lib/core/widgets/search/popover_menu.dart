import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:flutter/material.dart';

class PopoverMenu extends StatefulWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onSignoutPressed;

  const PopoverMenu({
    super.key,
    this.onProfilePressed,
    this.onSettingsPressed,
    this.onSignoutPressed,
  });

  @override
  State<PopoverMenu> createState() => _PopoverMenuState();
}

class _PopoverMenuState extends State<PopoverMenu> {
  final _popoverTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: AppColors.cardForeground,
  );

  final _popoverIconColor = AppColors.cardForeground;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.account_circle, 
        color: AppColors.primaryForeground,
      ),
      onPressed: () {
        showPopover(
          context: context, 
          alignment: Alignment.topRight, 
          anchorAlignment: Alignment.bottomRight,
          stayVisibleOnScroll: false,
          offset: Offset(0, 4),
          enterAnimations: [
            PopoverAnimationType.fadeIn,
            PopoverAnimationType.slideDown,
          ],
          exitAnimations: [
            PopoverAnimationType.fadeOut,
            PopoverAnimationType.slideUp,
          ],
          builder: (_) => _buildPopoverContent(),
        );
      },
    );
  }

  Widget _buildPopoverContent() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              closeOverlay(context, 'Profile');
              widget.onProfilePressed?.call();
            },
            child: Row(
              children: [
                Icon(
                  Icons.accessibility_new,
                  color: _popoverIconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Profile',
                    style: _popoverTextStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              closeOverlay(context, 'Settings');
              widget.onSettingsPressed?.call();
            },
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: _popoverIconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Settings',
                    style: _popoverTextStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              closeOverlay(context, 'Signout');
              widget.onSignoutPressed?.call();
            },
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: _popoverIconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sign Out',
                    style: _popoverTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}