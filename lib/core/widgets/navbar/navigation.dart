import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/navbar/top_navbar.dart';
import 'package:boilerplate/core/widgets/navbar/bottom_navbar.dart';

typedef NavBarBuilder = Widget Function(
    BuildContext context, Animation<double> animation);

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  // --- Top Navbar Options ---
  final bool showTopNav;
  final NavBarBuilder? topNavBarBuilder; // Custom builder
  final double topNavElevation;
  final Color? topNavBgColor;
  final Duration topNavAnimationDuration;
  final Curve topNavAnimationCurve;

  // --- Bottom Navbar Options ---
  final bool showBottomNav;
  final NavBarBuilder? bottomNavBarBuilder; // Custom builder
  final double bottomNavElevation;
  final Color? bottomNavBgColor;
  final Duration bottomNavAnimationDuration;
  final Curve bottomNavAnimationCurve;

  // --- General Styles ---
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // --- Behavior ---
  final bool autoHideOnScroll; // Whether navbar hides on scroll
  final double hideThreshold; // Minimum scroll delta to trigger hide

  const ScaffoldWithNavBar({
    super.key,
    required this.child,

    // TopNav options
    this.showTopNav = true,
    this.topNavBarBuilder,
    this.topNavElevation = 2.0,
    this.topNavBgColor,
    this.topNavAnimationDuration = const Duration(milliseconds: 320),
    this.topNavAnimationCurve = Curves.easeInOut,

    // BottomNav options
    this.showBottomNav = true,
    this.bottomNavBarBuilder,
    this.bottomNavElevation = 8.0,
    this.bottomNavBgColor,
    this.bottomNavAnimationDuration = const Duration(milliseconds: 260),
    this.bottomNavAnimationCurve = Curves.easeInOut,

    // General styles
    this.backgroundColor,
    this.padding,
    this.margin,

    // Behavior
    this.autoHideOnScroll = true,
    this.hideThreshold = 10,
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
    if (!widget.autoHideOnScroll || _isAnimating) return;

    final double delta = offset - _lastOffset;

    if (delta > widget.hideThreshold && _showTopNav.value) {
      _hideTopNav();
    } else if (delta < -widget.hideThreshold && !_showTopNav.value) {
      _showTopNavFunc();
    }
    _lastOffset = offset;
  }

  void _hideTopNav() async {
    _isAnimating = true;
    _showTopNav.value = false;
    await Future.delayed(widget.topNavAnimationDuration);
    _isAnimating = false;
  }

  void _showTopNavFunc() async {
    _isAnimating = true;
    _showTopNav.value = true;
    await Future.delayed(widget.topNavAnimationDuration);
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
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        margin: widget.margin,
        padding: widget.padding,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _toggleTopNav,
          child: Stack(
            children: [
              // Main scrollable content
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _onScroll(notification.metrics.pixels);
                  }
                  return false;
                },
                child: widget.child,
              ),

              // Top Navbar (animated)
              if (widget.showTopNav)
                ValueListenableBuilder<bool>(
                  valueListenable: _showTopNav,
                  builder: (context, visible, _) {
                    return AnimatedSlide(
                      duration: widget.topNavAnimationDuration,
                      curve: widget.topNavAnimationCurve,
                      offset: visible ? Offset.zero : const Offset(0, -1),
                      child: AnimatedOpacity(
                        duration: widget.topNavAnimationDuration * 0.8,
                        opacity: visible ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !visible,
                          child: widget.topNavBarBuilder != null
                              ? widget.topNavBarBuilder!(
                                  context, const AlwaysStoppedAnimation(1.0))
                              : TopNavbar(),
                        ),
                      ),
                    );
                  },
                ),

              // Bottom Navbar (always shown, but can be customized/hide)
              if (widget.showBottomNav)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: widget.bottomNavBarBuilder != null
                      ? widget.bottomNavBarBuilder!(
                          context, const AlwaysStoppedAnimation(1.0))
                      : BottomNavbar(
                          isVisibleNotifier: _showBottomNav,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
