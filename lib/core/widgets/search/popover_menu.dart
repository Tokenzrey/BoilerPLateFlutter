import 'package:flutter/material.dart';

class PopoverMenu extends StatelessWidget {
  const PopoverMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return PopupMenuButton<int>(
      icon: Icon(Icons.account_circle_rounded, color: textColor),
      shadowColor: isDark ? Colors.grey[200] : Colors.black54,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.accessibility_new, color: textColor),
              const SizedBox(
                width: 10,
              ),
              Text("Profile", style: TextStyle(color: textColor) ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.settings, color: textColor),
              const SizedBox(
                width: 10,
              ),
              Text("Settings", style: TextStyle(color: textColor),)
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.logout, color: textColor),
              const SizedBox(
                width: 10,
              ),
              Text("Logout", style: TextStyle(color: textColor) ),
            ],
          ),
        ),
      ],
      offset: Offset(0, 52),
      color: Theme.of(context).colorScheme.surface,
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