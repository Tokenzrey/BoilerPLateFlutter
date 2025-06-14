import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';

enum NavbarItem {
  home,
  myList,
  search,
}

class BottomNavbar extends StatefulWidget {
  final ValueNotifier<bool> isVisibleNotifier;
  final NavbarItem selectedItem;
  final ValueChanged<NavbarItem>? onItemSelected;

  const BottomNavbar({
    super.key,
    required this.isVisibleNotifier,
    this.selectedItem = NavbarItem.home,
    this.onItemSelected,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  late NavbarItem _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  void _onItemTapped(int index) {
    final tappedItem = NavbarItem.values[index];
    setState(() {
      _selectedItem = tappedItem;
    });
    widget.onItemSelected?.call(tappedItem);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isVisibleNotifier,
      builder: (context, isVisible, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: isVisible ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isVisible ? 1.0 : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: BottomNavigationBar(
                elevation: 0,
                currentIndex: NavbarItem.values.indexOf(_selectedItem),
                selectedItemColor: AppColors.blue[300],
                unselectedItemColor: AppColors.primaryForeground,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'My List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                ]
              ),
            ),
          ),
        );
      }
    );
  }
}