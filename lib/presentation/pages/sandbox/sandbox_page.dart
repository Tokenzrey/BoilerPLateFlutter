import 'package:boilerplate/core/widgets/navbar/bottom_navbar.dart';
import 'package:boilerplate/core/widgets/navbar/top_navbar.dart';
import 'package:boilerplate/presentation/pages/sandbox/animation_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/button_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/popover_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/select_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/typography_sandbox.dart';
import 'package:flutter/material.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
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
              const SizedBox(height: 200),
              const TypographyExamplePage(),
              const SizedBox(height: 200),
              const ButtonSandboxPage(),
              const SizedBox(height: 200),
              const PopoverSandbox(),
              const SizedBox(height: 200),
              // const SelectSandbox(),
              const SizedBox(height: 200),
              const SizedBox(height: 200),
              const SizedBox(height: 200),
              const AnimationSandboxPage(),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
