// class NavigationAppBarExample extends StatelessWidget {
//   const NavigationAppBarExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My App'),
//         actions: [
//           _buildMainNavigation(context),
//           const SizedBox(width: 8),
//           _buildUserMenu(context),
//         ],
//       ),
//       body: const Center(
//         child: Text('Content Area'),
//       ),
//     );
//   }

//   Widget _buildMainNavigation(BuildContext context) {
//     final theme = Theme.of(context);

//     return NavigationMenu(
//       style: NavigationMenuStyle(
//         activeItemColor: theme.colorScheme.primary,
//         activeItemBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
//         contentBorderRadius: BorderRadius.circular(12),
//         contentElevation: 4,
//         itemSize: ButtonSize.small,
//       ),
//       items: [
// Dashboard - Simple navigation item
//         NavigationMenuItem.simple(
//           child: 'Dashboard',
//           leadingIcon: Icons.dashboard,
//           onPressed: () => Navigator.pushNamed(context, '/dashboard'),
//         ),

// Products - With dropdown content in grid
//         NavigationMenuItem.withContent(
//           child: 'Products',
//           content: NavigationMenuContent(
//             title: 'Product Categories',
//             description: 'Browse or manage products',
//             child: NavigationMenuContentList(
//               crossAxisCount: 2,
//               spacing: 12.0,
//               runSpacing: 16.0,
//               children: [
//                 _buildProductNavCard(
//                   context,
//                   'Electronics',
//                   Icons.devices,
//                   Colors.blue,
//                   '/products/electronics'
//                 ),
//                 _buildProductNavCard(
//                   context,
//                   'Clothing',
//                   Icons.checkroom,
//                   Colors.green,
//                   '/products/clothing'
//                 ),
//                 _buildProductNavCard(
//                   context,
//                   'Home & Garden',
//                   Icons.home,
//                   Colors.amber,
//                   '/products/home'
//                 ),
//                 _buildProductNavCard(
//                   context,
//                   'Books',
//                   Icons.book,
//                   Colors.purple,
//                   '/products/books'
//                 ),
//                 _buildProductNavCard(
//                   context,
//                   'Sports',
//                   Icons.sports_basketball,
//                   Colors.orange,
//                   '/products/sports'
//                 ),
//                 _buildProductNavCard(
//                   context,
//                   'View All',
//                   Icons.view_list,
//                   Colors.grey,
//                   '/products'
//                 ),
//               ],
//             ),
//             footer: TextButton.icon(
//               onPressed: () => Navigator.pushNamed(context, '/products/add'),
//               icon: const Icon(Icons.add),
//               label: const Text('Add New Product'),
//             ),
//           ),
//         ),

// Orders - With custom list content
//         NavigationMenuItem.withContent(
//           child: 'Orders',
//           content: NavigationMenuContent(
//             title: 'Order Management',
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 NavigationMenuLink(
//                   child: 'Recent Orders',
//                   icon: Icons.receipt_long,
//                   description: 'View latest orders',
//                   onPressed: () => Navigator.pushNamed(context, '/orders/recent'),
//                 ),
//                 NavigationMenuLink(
//                   child: 'Processing',
//                   icon: Icons.local_shipping,
//                   description: '${_getRandomNumber(10)} orders in progress',
//                   onPressed: () => Navigator.pushNamed(context, '/orders/processing'),
//                 ),
//                 NavigationMenuLink(
//                   child: 'Returns',
//                   icon: Icons.assignment_return,
//                   description: '${_getRandomNumber(5)} pending returns',
//                   onPressed: () => Navigator.pushNamed(context, '/orders/returns'),
//                 ),
//                 const Divider(),
//                 NavigationMenuLink(
//                   child: 'Order Settings',
//                   icon: Icons.settings,
//                   onPressed: () => Navigator.pushNamed(context, '/orders/settings'),
//                 ),
//               ],
//             ),
//           ),
//         ),

// Analytics - With nested navigation example
//         NavigationMenuItem.withContent(
//           child: 'Analytics',
//           content: SizedBox(
//             width: 500,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
// Left sidebar with nested navigation
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
//                     child: NavigationMenu(
//                       direction: Axis.vertical,
//                       style: NavigationMenuStyle(
//                         itemPadding: EdgeInsets.zero,
//                         contentWidth: 250,
//                       ),
//                       items: [
//                         NavigationMenuItem.withContent(
//                           child: 'Sales',
//                           leadingIcon: Icons.trending_up,
//                           content: NavigationMenuContent(
//                             title: 'Sales Analytics',
//                             child: Column(
//                               children: [
//                                 NavigationMenuLink(
//                                   child: 'Daily Sales',
//                                   icon: Icons.today,
//                                   onPressed: () {},
//                                 ),
//                                 NavigationMenuLink(
//                                   child: 'Monthly Reports',
//                                   icon: Icons.calendar_month,
//                                   onPressed: () {},
//                                 ),
//                                 NavigationMenuLink(
//                                   child: 'Annual Overview',
//                                   icon: Icons.calendar_view_year,
//                                   onPressed: () {},
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         NavigationMenuItem.withContent(
//                           child: 'Traffic',
//                           leadingIcon: Icons.people,
//                           content: NavigationMenuContent(
//                             title: 'Traffic Sources',
//                             child: Column(
//                               children: [
//                                 NavigationMenuLink(
//                                   child: 'Website',
//                                   icon: Icons.web,
//                                   onPressed: () {},
//                                 ),
//                                 NavigationMenuLink(
//                                   child: 'Mobile App',
//                                   icon: Icons.phone_android,
//                                   onPressed: () {},
//                                 ),
//                                 NavigationMenuLink(
//                                   child: 'Social Media',
//                                   icon: Icons.share,
//                                   onPressed: () {},
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         NavigationMenuItem.simple(
//                           child: 'Custom Reports',
//                           leadingIcon: Icons.analytics,
//                           onPressed: () => Navigator.pushNamed(context, '/analytics/custom'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

// Right content panel
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Quick Insights',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold
//                           )
//                         ),
//                         const SizedBox(height: 16),
//                         Wrap(
//                           spacing: 12,
//                           runSpacing: 12,
//                           children: [
//                             _buildMetricCard('Today\'s Sales', '\$${_getRandomNumber(1000)}', Icons.attach_money),
//                             _buildMetricCard('Active Users', '${_getRandomNumber(100)}', Icons.person),
//                             _buildMetricCard('Conversion', '${_getRandomNumber(10)}%', Icons.pie_chart),
//                             _buildMetricCard('New Customers', '+${_getRandomNumber(20)}', Icons.person_add),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextButton.icon(
//                           onPressed: () => Navigator.pushNamed(context, '/analytics/dashboard'),
//                           icon: const Icon(Icons.dashboard),
//                           label: const Text('Open Full Dashboard'),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserMenu(BuildContext context) {
//     return NavigationMenu(
//       items: [
//         NavigationMenuItem.withContent(
//           child: const CircleAvatar(
//             radius: 18,
//             backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
//           ),
//           content: NavigationMenuContent(
//             header: ListTile(
//               leading: const CircleAvatar(
//                 backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
//               ),
//               title: const Text('John Doe'),
//               subtitle: const Text('john.doe@example.com'),
//               contentPadding: const EdgeInsets.all(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 NavigationMenuLink(
//                   child: 'Profile',
//                   icon: Icons.person,
//                   onPressed: () => Navigator.pushNamed(context, '/profile'),
//                 ),
//                 NavigationMenuLink(
//                   child: 'Settings',
//                   icon: Icons.settings,
//                   onPressed: () => Navigator.pushNamed(context, '/settings'),
//                 ),
//                 NavigationMenuLink(
//                   child: 'Help & Support',
//                   icon: Icons.help,
//                   onPressed: () => Navigator.pushNamed(context, '/help'),
//                 ),
//                 const Divider(),
//                 NavigationMenuLink(
//                   child: 'Sign Out',
//                   icon: Icons.exit_to_app,
//                   onPressed: () {
// Show confirmation dialog
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Sign Out'),
//                         content: const Text('Are you sure you want to sign out?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
// Sign out logic here
//                             },
//                             child: const Text('Sign Out'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

// Helper method to build product category cards
//   Widget _buildProductNavCard(BuildContext context, String title, IconData icon, Color color, String route) {
//     return InkWell(
//       onTap: () => Navigator.pushNamed(context, route),
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleSmall,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// Helper method to build analytics metric cards
//   Widget _buildMetricCard(String title, String value, IconData icon) {
//     return Container(
//       width: 120,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 16, color: Colors.grey),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// Helper method to generate random numbers for the example
//   int _getRandomNumber(int max) {
//     return DateTime.now().millisecondsSinceEpoch % max + 1;
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';
import '../buttons/button.dart';

class NavigationMenu extends StatefulWidget {
  final List<NavigationMenuItem> items;
  final NavigationMenuStyle? style;
  final Axis direction;
  final Widget Function(BuildContext, NavigationMenuItem, bool isActive)?
      itemBuilder;
  final void Function(NavigationMenuItem)? onMenuOpen;
  final void Function(NavigationMenuItem)? onMenuClose;
  final bool useViewportBoundary;
  final bool preventCloseOnInternalClick;

  const NavigationMenu({
    super.key,
    required this.items,
    this.style,
    this.direction = Axis.horizontal,
    this.itemBuilder,
    this.onMenuOpen,
    this.onMenuClose,
    this.useViewportBoundary = true,
    this.preventCloseOnInternalClick = false,
  });

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  NavigationMenuItem? _activeItem;
  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.items.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(NavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      _itemKeys.clear();
      for (int i = 0; i < widget.items.length; i++) {
        _itemKeys[i] = GlobalKey();
      }
    }
  }

  @override
  void dispose() {
    _dismissOverlay();
    _closeTimer?.cancel();
    super.dispose();
  }

  void _handleItemTapped(NavigationMenuItem item) {
    if (item.onPressed != null) {
      item.onPressed!();
    }

    if (item.content != null) {
      if (_activeItem == item) {
        _dismissOverlay();
      } else {
        _showOverlay(item);
      }
    } else {
      _dismissOverlay();
    }
  }

  void _showOverlay(NavigationMenuItem item) {
    _dismissOverlay();

    setState(() {
      _activeItem = item;
    });

    if (widget.onMenuOpen != null) {
      widget.onMenuOpen!(item);
    }

    _closeTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderBox? renderBox = _findRenderBox(item);
      if (renderBox == null) return;

      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);

      final NavigationMenuStyle effectiveStyle =
          widget.style ?? const NavigationMenuStyle();

      _overlayEntry = OverlayEntry(
        builder: (context) {
          return _buildOverlay(item, size, position, effectiveStyle);
        },
      );

      if (_overlayEntry != null) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  RenderBox? _findRenderBox(NavigationMenuItem item) {
    final int index = widget.items.indexOf(item);
    if (index < 0 || !_itemKeys.containsKey(index)) return null;

    final GlobalKey itemKey = _itemKeys[index]!;
    if (!itemKey.currentContext!.mounted) return null;

    return itemKey.currentContext?.findRenderObject() as RenderBox?;
  }

  void _dismissOverlay() {
    _closeTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (_activeItem != null && widget.onMenuClose != null) {
      widget.onMenuClose!(_activeItem!);
    }

    if (mounted) {
      setState(() {
        _activeItem = null;
      });
    }
  }

  Widget _buildOverlay(
    NavigationMenuItem item,
    Size itemSize,
    Offset itemPosition,
    NavigationMenuStyle style,
  ) {
    final screenSize = MediaQuery.of(context).size;

    double left = itemPosition.dx;
    double top = itemPosition.dy + itemSize.height;

    double maxWidth = style.contentWidth ?? (screenSize.width * 0.8);
    double minWidth = style.contentMinWidth ?? itemSize.width;

    final rightEdge = left + maxWidth;
    final bottomEdge = top + (style.contentMaxHeight ?? 400);

    bool flipHorizontal = false;
    bool flipVertical = false;

    if (widget.useViewportBoundary) {
      if (rightEdge > screenSize.width) {
        flipHorizontal = true;
      }

      if (bottomEdge > screenSize.height) {
        flipVertical = true;
      }
    }

    if (flipHorizontal) {
      left = (itemPosition.dx + itemSize.width) - maxWidth;
    }

    if (flipVertical) {
      top = itemPosition.dy - (style.contentMaxHeight ?? 400);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _dismissOverlay(),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: MouseRegion(
            onEnter: (_) {
              _closeTimer?.cancel();
            },
            onExit: (_) {
              _scheduleClose();
            },
            child: GestureDetector(
              onTap: widget.preventCloseOnInternalClick ? () {} : null,
              child: Material(
                color:
                    style.contentBackgroundColor ?? Theme.of(context).cardColor,
                elevation: style.contentElevation ?? 8.0,
                borderRadius:
                    style.contentBorderRadius ?? BorderRadius.circular(12.0),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    maxHeight: style.contentMaxHeight ?? 400.0,
                  ),
                  child: item.content,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 300), _dismissOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildMenuItems(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildMenuItems(),
          );
  }

  List<Widget> _buildMenuItems() {
    return List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      final isActive = _activeItem == item;

      final Widget itemWidget = widget.itemBuilder != null
          ? widget.itemBuilder!(context, item, isActive)
          : _buildDefaultMenuItem(item, isActive);

      return _wrapMenuItem(index, item, itemWidget);
    });
  }

  Widget _wrapMenuItem(int index, NavigationMenuItem item, Widget child) {
    return MouseRegion(
      key: _itemKeys[index],
      onEnter: (_) {
        _closeTimer?.cancel();
        if (item.content != null && item.triggerOnHover) {
          _showOverlay(item);
        }
      },
      onExit: (_) {
        if (_activeItem == item) {
          _scheduleClose();
        }
      },
      child: GestureDetector(
        onTap: () => _handleItemTapped(item),
        child: child,
      ),
    );
  }

  Widget _buildDefaultMenuItem(NavigationMenuItem item, bool isActive) {
    final style = widget.style ?? const NavigationMenuStyle();

    Widget? trailingWidget = item.trailing;
    if (trailingWidget == null && item.content != null) {
      trailingWidget = Icon(
        Icons.arrow_drop_down,
        size: 16,
        color: isActive ? style.activeItemColor : style.itemColor,
      );
    }

    return Padding(
        padding:
            style.itemPadding ?? const EdgeInsets.symmetric(horizontal: 8.0),
        child: Button(
          variant: isActive ? ButtonVariant.primary : ButtonVariant.ghost,
          leftWidget: item.leading,
          rightWidget: trailingWidget,
          text: item.child is String ? item.child as String : null,
          leftIcon: item.leadingIcon,
          rightIcon: item.trailingIcon,
          size: style.itemSize ?? ButtonSize.normal,
          density: style.itemDensity ?? ButtonDensity.normal,
          colors: ButtonColors(
            background: isActive ? style.activeItemBackgroundColor : null,
            text: isActive ? style.activeItemColor : style.itemColor,
          ),
          disabled: !item.enabled,
          onPressed: null,
        ));
  }
}

class NavigationMenuItem {
  final dynamic child;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool triggerOnHover;

  const NavigationMenuItem({
    required this.child,
    this.content,
    this.leading,
    this.trailing,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.onPressed,
    this.triggerOnHover = true,
  });

  factory NavigationMenuItem.simple({
    required dynamic child,
    VoidCallback? onPressed,
    bool enabled = true,
    IconData? icon,
  }) {
    return NavigationMenuItem(
      child: child,
      leadingIcon: icon,
      enabled: enabled,
      onPressed: onPressed,
    );
  }

  factory NavigationMenuItem.withContent({
    required dynamic child,
    required Widget content,
    VoidCallback? onPressed,
    bool enabled = true,
    IconData? icon,
    bool triggerOnHover = true,
  }) {
    return NavigationMenuItem(
      child: child,
      content: content,
      leadingIcon: icon,
      enabled: enabled,
      onPressed: onPressed,
      triggerOnHover: triggerOnHover,
    );
  }
}

class NavigationMenuContent extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets padding;

  const NavigationMenuContent({
    super.key,
    this.title,
    this.description,
    required this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          header!
        else if (title != null)
          Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              top: padding.top,
              right: padding.right,
              bottom: description != null ? 4.0 : padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Flexible(
          child: Padding(
            padding: title != null || header != null
                ? EdgeInsets.only(
                    left: padding.left,
                    right: padding.right,
                    bottom: footer != null ? 0 : padding.bottom,
                    top: title != null && description == null ? 0 : padding.top,
                  )
                : padding,
            child: child,
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
              top: 8.0,
            ),
            child: footer!,
          ),
      ],
    );
  }
}

class NavigationMenuContentList extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final bool reverse;

  const NavigationMenuContentList({
    super.key,
    required this.children,
    this.crossAxisCount = 1,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = reverse ? children.reversed.toList() : children;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((child) {
        return SizedBox(
          width: crossAxisCount == 1
              ? double.infinity
              : (MediaQuery.of(context).size.width -
                      (spacing * (crossAxisCount - 1))) /
                  crossAxisCount,
          child: child,
        );
      }).toList(),
    );
  }
}

class NavigationMenuLink extends StatefulWidget {
  final dynamic child;
  final IconData? icon;
  final String? description;
  final VoidCallback? onPressed;
  final bool isActive;

  const NavigationMenuLink({
    super.key,
    required this.child,
    this.icon,
    this.description,
    this.onPressed,
    this.isActive = false,
  });

  @override
  State<NavigationMenuLink> createState() => _NavigationMenuLinkState();
}

class _NavigationMenuLinkState extends State<NavigationMenuLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(8.0),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: isActive || _isHovered
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                const SizedBox(width: 12.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.child is String
                        ? Text(
                            widget.child,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isActive || _isHovered
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isActive || _isHovered
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          )
                        : widget.child,
                    if (widget.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          widget.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationMenuStyle {
  final Color? activeItemBackgroundColor;
  final Color? activeItemColor;
  final Color? itemColor;
  final ButtonSize? itemSize;
  final ButtonDensity? itemDensity;
  final EdgeInsets? itemPadding;
  final Color? contentBackgroundColor;
  final double? contentElevation;
  final BorderRadius? contentBorderRadius;
  final double? contentWidth;
  final double? contentMinWidth;
  final double? contentMaxHeight;

  const NavigationMenuStyle({
    this.activeItemBackgroundColor,
    this.activeItemColor,
    this.itemColor,
    this.itemSize,
    this.itemDensity,
    this.itemPadding,
    this.contentBackgroundColor,
    this.contentElevation,
    this.contentBorderRadius,
    this.contentWidth,
    this.contentMinWidth,
    this.contentMaxHeight,
  });
}
