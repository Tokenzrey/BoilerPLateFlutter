import 'package:flutter/material.dart';

enum NavbarItem {
  home,
  myList,
  search,
}

class BottomNavbar extends StatefulWidget {
  final bool isVisible;
  final NavbarItem selectedItem;
  final ValueChanged<NavbarItem>? onItemSelected;

  const BottomNavbar({
    super.key,
    this.isVisible = true,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDark ? Colors.white70 : Colors.black87;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(
              color: themeColor,
              width: 1,
            ),
          ),
          child: BottomNavigationBar(
            elevation: 0,
            currentIndex: NavbarItem.values.indexOf(_selectedItem),
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: themeColor,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: themeColor),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book, color: themeColor),
                label: 'My List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, color: themeColor),
                label: 'Search',
              ),
            ]
          ),
        ),
      ),
    );
  }
}