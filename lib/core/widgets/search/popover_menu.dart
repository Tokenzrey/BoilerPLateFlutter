import 'package:flutter/material.dart';

class PopoverMenu extends StatelessWidget {
  const PopoverMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Image.network(
          'https://comick.io/static/icons/55x55-icon.png'
        ),
        onPressed: () {},
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Handle search action
          },
        ),
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            // Handle account action
          },
        ),
      ],
    );
  }
}