import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NavbarItem {
  home,
  myList,
  search,
}

NavbarItem getNavbarItemFromRoute(String? routeName) {
  switch (routeName) {
    case '/home':
    case 'home':
      return NavbarItem.home;
    case '/my-list':
    case 'my-list':
      return NavbarItem.myList;
    case '/search':
    case 'search':
      return NavbarItem.search;
    default:
      return NavbarItem.search;
  }
}

String getRouteFromNavbarItem(NavbarItem item) {
  switch (item) {
    case NavbarItem.home:
      return '/home';
    case NavbarItem.myList:
      return '/my-list';
    case NavbarItem.search:
      return '/search';
  }
}

class BottomNavbar extends StatelessWidget {
  final ValueNotifier<bool> isVisibleNotifier;
  final ValueChanged<NavbarItem>? onItemSelected;

  const BottomNavbar({
    super.key,
    required this.isVisibleNotifier,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // GoRouter: Gunakan GoRouterState
    final String? routeName =
        GoRouterState.of(context).name ?? ModalRoute.of(context)?.settings.name;
    final NavbarItem currentItem = getNavbarItemFromRoute(routeName);

    return ValueListenableBuilder<bool>(
      valueListenable: isVisibleNotifier,
      builder: (context, isVisible, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          offset: isVisible ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            opacity: isVisible ? 1.0 : 0.0,
            child: Material(
              elevation: 12,
              color: Colors.transparent,
              child: Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.97),
                  border: Border(
                    top: BorderSide(color: AppColors.neutral[200]!, width: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: "Home",
                      isActive: currentItem == NavbarItem.home,
                      onTap: () {
                        if (currentItem != NavbarItem.home) {
                          debugPrint('Navigating to Home...');
                          context.goNamed('home');
                        }
                        onItemSelected?.call(NavbarItem.home);
                      },
                    ),
                    _NavItem(
                      icon: Icons.bookmark_rounded,
                      label: "My List",
                      isActive: currentItem == NavbarItem.myList,
                      onTap: () {
                        if (currentItem != NavbarItem.myList) {
                          debugPrint('Navigating to My List...');
                          context.goNamed('my-list');
                        }
                        onItemSelected?.call(NavbarItem.myList);
                      },
                    ),
                    _NavItem(
                      icon: Icons.search_rounded,
                      label: "Search",
                      isActive: currentItem == NavbarItem.search,
                      onTap: () {
                        if (currentItem != NavbarItem.search) {
                          debugPrint('Navigating to Search...');
                          context.goNamed('search');
                        }
                        onItemSelected?.call(NavbarItem.search);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor = AppColors.neutral[500]!;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        splashColor: selectedColor.withAlpha(30),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: isActive ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.8,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? selectedColor : unselectedColor,
                  letterSpacing: 0.1,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  height: 3.5,
                  width: 18,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
