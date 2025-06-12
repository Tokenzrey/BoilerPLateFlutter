import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDark ? Colors.white70 : Colors.black87;
    
    return Container(
      padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16)
        ),
        border: Border.all(
          color: themeColor,
          width: 0.5,
        )
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
            icon: Icon(Icons.search, color: themeColor),
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
