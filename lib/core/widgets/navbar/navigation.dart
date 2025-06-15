import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/navbar/top_navbar.dart';
import 'package:boilerplate/core/widgets/navbar/bottom_navbar.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;
  final bool showTopNav;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    this.showTopNav = true,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  final ValueNotifier<bool> _showTopNav = ValueNotifier(true);
  final ValueNotifier<bool> _showBottomNav = ValueNotifier(true);

  double _lastOffset = 0;
  bool _isAnimating = false;

  @override
  void dispose() {
    _showTopNav.dispose();
    _showBottomNav.dispose();
    super.dispose();
  }

  void _onScroll(double offset) {
    if (_isAnimating) return;
    if (offset > _lastOffset + 10 && _showTopNav.value) {
      _hideTopNav();
    } else if (offset < _lastOffset - 10 && !_showTopNav.value) {
      _showTopNavFunc();
    }
    _lastOffset = offset;
  }

  void _hideTopNav() async {
    _isAnimating = true;
    _showTopNav.value = false;
    await Future.delayed(const Duration(milliseconds: 320));
    _isAnimating = false;
  }

  void _showTopNavFunc() async {
    _isAnimating = true;
    _showTopNav.value = true;
    await Future.delayed(const Duration(milliseconds: 320));
    _isAnimating = false;
  }

  void _toggleTopNav() {
    if (_isAnimating) return;
    if (!_showTopNav.value) {
      _showTopNavFunc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleTopNav,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  _onScroll(notification.metrics.pixels);
                }
                return false;
              },
              child: widget.child,
            ),
            if (widget.showTopNav)
              ValueListenableBuilder<bool>(
                valueListenable: _showTopNav,
                builder: (context, visible, _) {
                  return AnimatedSlide(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut,
                    offset: visible ? Offset.zero : const Offset(0, -1),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: visible ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !visible,
                        child: TopNavbar(),
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavbar(
                isVisibleNotifier: _showBottomNav,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
