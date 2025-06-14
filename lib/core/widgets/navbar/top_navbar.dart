import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16)
        ),
      ),
      child: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/ic_app.png',
            height: 32,
            width: 32,
          ),
          onPressed: () {},
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.primaryForeground,
            ),
            onPressed: () {
              showPopover(
                context: context, 
                alignment: Alignment.center,
                alwaysFocus: true,
                enterAnimations: [
                  PopoverAnimationType.fadeIn
                ],
                stayVisibleOnScroll: false,
                builder: (context) => SearchModal(),
              );
            }
          ),
          
          PopoverMenu(
            onProfilePressed: () => context.push('/profile'), 
            onSettingsPressed: () {}, 
            onSignoutPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
