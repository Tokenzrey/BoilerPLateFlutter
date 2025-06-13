import 'package:boilerplate/core/widgets/navbar/bottom_navbar.dart';
import 'package:boilerplate/core/widgets/navbar/top_navbar.dart';
import 'package:flutter/material.dart';

class AppbarSandbox extends StatefulWidget {
  const AppbarSandbox({super.key});

  @override
  State<AppbarSandbox> createState() => _AppbarSandboxState();
}

class _AppbarSandboxState extends State<AppbarSandbox> {
  bool isBottomNavbarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: TopNavbar(),
      bottomNavigationBar: BottomNavbar(
        isVisible: isBottomNavbarVisible, 
        selectedItem: NavbarItem.search, 
        onItemSelected: (value) {},
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification && isBottomNavbarVisible) {
            setState(() {
              isBottomNavbarVisible = false;
            });
          }
          return true;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!isBottomNavbarVisible) {
              setState(() {
                isBottomNavbarVisible = true;
              });
            }
          },




          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            children: [
              const SizedBox(height: 600),
            ],
          ),
        ),
      ),
    );
  }
}
