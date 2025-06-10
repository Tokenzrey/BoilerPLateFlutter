import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Image.network(
          'https://comick.io/static/icons/55x55-icon.png'
        ),
        onPressed: () {},
      ),
      backgroundColor: Colors.black87,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SearchModal(), 
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white,),
          onPressed: () {
            PopoverMenu();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
