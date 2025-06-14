import 'package:boilerplate/core/widgets/navbar/bottom_navbar.dart';
import 'package:boilerplate/core/widgets/navbar/top_navbar.dart';
import 'package:flutter/material.dart';

class AppbarSandbox extends StatefulWidget {
  const AppbarSandbox({super.key});

  @override
  State<AppbarSandbox> createState() => _AppbarSandboxState();
}

class _AppbarSandboxState extends State<AppbarSandbox> {
  final ValueNotifier<bool> _navbarVisibleNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _navbarVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: TopNavbar(),
      bottomNavigationBar: BottomNavbar(
        isVisibleNotifier: _navbarVisibleNotifier, 
        selectedItem: NavbarItem.home, 
        onItemSelected: (value) {},
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification && _navbarVisibleNotifier.value) {
              _navbarVisibleNotifier.value = false;
          }
          return true;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!_navbarVisibleNotifier.value) {
                _navbarVisibleNotifier.value = true;
            }
          },




          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            children: [
              const SizedBox(height: 1000),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
