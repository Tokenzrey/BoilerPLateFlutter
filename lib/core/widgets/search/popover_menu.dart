import 'package:boilerplate/constants/app_theme.dart';
import 'package:flutter/material.dart';

class PopoverMenu extends StatelessWidget {
  const PopoverMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final darkThemeColor = AppThemeData.darkThemeData.colorScheme.surface;
    final iconColor = AppThemeData.darkThemeData.colorScheme.onSurface;

    return PopupMenuButton<int>(
      icon: Icon(Icons.account_circle_rounded, color: iconColor),
      shadowColor: Colors.grey[200],
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.accessibility_new, color: iconColor),
              const SizedBox(
                width: 10,
              ),
              Text("Profile", style: TextStyle(color: iconColor) ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.settings, color: iconColor),
              const SizedBox(
                width: 10,
              ),
              Text("Settings", style: TextStyle(color: iconColor),)
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.logout, color: iconColor),
              const SizedBox(
                width: 10,
              ),
              Text("Logout", style: TextStyle(color: iconColor) ),
            ],
          ),
        ),
      ],
      offset: Offset(0, 52),
      color: darkThemeColor,
      elevation: 2,
      onSelected: (value) {
        if (value == 1) {
          // _showDialog(context);
        } else if (value == 2) {
          // _showDialog(context);
        } else if (value == 3) {
          // _showDialog(context);
        }
      },
    );
  }
}