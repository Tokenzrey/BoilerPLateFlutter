import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final darkThemeColor = AppThemeData.darkThemeData.colorScheme.surface;
    final iconColor = AppThemeData.darkThemeData.colorScheme.onSurface;
    
    return Container(
      padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
      decoration: BoxDecoration(
        color: darkThemeColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16)
        ),
      ),
      child: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Image.network(
            'https://comick.io/static/icons/55x55-icon.png'
          ),
          onPressed: () {},
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: iconColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SearchModal(), 
              );
            },
          ),
          PopoverMenu(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
