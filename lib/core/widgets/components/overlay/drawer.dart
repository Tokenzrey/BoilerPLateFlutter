import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'overlay.dart';
import 'popover.dart';

/// A handler for drawer and sheet overlays within the OverlayManager system.
/// Register this handler with OverlayManagerLayer to enable drawer and sheet functionality.
class DrawerOverlayHandler extends OverlayHandler {
  /// Active drawers managed by this handler
  final List<DrawerEntry> _activeDrawers = [];

  /// Notifier for the number of active drawers
  final ValueNotifier<int> _drawerCountNotifier = ValueNotifier(0);

  /// Tracks whether initialization has been completed
  bool _isInitialized = false;

  /// Creates a drawer overlay handler
  DrawerOverlayHandler();

  /// Get the number of active drawers
  int get drawerCount => _activeDrawers.length;

  /// Get notifier for drawer count changes
  ValueNotifier<int> get drawerCountNotifier => _drawerCountNotifier;

  @override
  void initWithContext(BuildContext context) {
    _isInitialized = true;
  }

  /// Shows a drawer with the specified configuration
  DrawerCompleter<T> showDrawer<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    DrawerPosition position = DrawerPosition.left,
    bool modal = true,
    bool barrierDismissible = true,
    bool draggable = true,
    bool useSafeArea = true,
    bool showDragHandle = true,
    BorderRadius? borderRadius,
    Size? dragHandleSize,
    BoxDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? backgroundColor,
    Color? barrierColor,
    EdgeInsets? padding,
    BoxConstraints? constraints,
    DrawerAnimation? animation,
    DrawerController? controller,
    VoidCallback? onOpen,
    VoidCallback? onClose,
    bool Function()? onWillClose,
    bool resizable = false,
    double minResizeWidth = 200,
    double maxResizeWidth = 600,
    double minResizeHeight = 100,
    double maxResizeHeight = 800,
    Widget Function(BuildContext, Widget)? headerBuilder,
    Widget Function(BuildContext, Widget)? footerBuilder,
  }) {
    assert(_isInitialized,
        "DrawerOverlayHandler must be initialized with OverlayManagerLayer");

    // Create config from parameters
    final config = DrawerConfig(
      position: position,
      modal: modal,
      barrierDismissible: barrierDismissible,
      draggable: draggable,
      useSafeArea: useSafeArea,
      showDragHandle: showDragHandle,
      borderRadius: borderRadius,
      dragHandleSize: dragHandleSize,
      decoration: decoration,
      width: width,
      height: height,
      elevation: elevation,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      padding: padding,
      constraints: constraints,
      animation: animation,
      resizable: resizable,
      minResizeWidth: minResizeWidth,
      maxResizeWidth: maxResizeWidth,
      minResizeHeight: minResizeHeight,
      maxResizeHeight: maxResizeHeight,
      headerBuilder: headerBuilder,
      footerBuilder: footerBuilder,
    );

    return _showDrawer<T>(
      context: context,
      builder: builder,
      config: config,
      controller: controller,
      onOpen: onOpen,
      onClose: onClose,
      onWillClose: onWillClose,
    );
  }

  /// Shows a sheet with the specified configuration
  DrawerCompleter<T> showSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    DrawerPosition position = DrawerPosition.bottom,
    bool modal = true,
    bool barrierDismissible = true,
    bool draggable = false,
    bool useSafeArea = true,
    BorderRadius? borderRadius = const BorderRadius.all(Radius.zero),
    BoxDecoration? decoration,
    Color? backgroundColor,
    Color? barrierColor,
    EdgeInsets? padding,
    BoxConstraints? constraints,
    DrawerAnimation? animation,
    SheetController? controller,
    List<double>? snapPoints,
    int? initialSnapIndex,
    double? minHeight,
    double? maxHeight,
    VoidCallback? onOpen,
    VoidCallback? onClose,
    bool Function()? onWillClose,
    ValueChanged<int>? onSnapPointChanged,
    bool isDismissible = true,
    bool showDragHandle = false,
    bool hideKeyboard = true,
    Widget Function(BuildContext, Widget)? headerBuilder,
  }) {
    assert(_isInitialized,
        "DrawerOverlayHandler must be initialized with OverlayManagerLayer");

    // Validate snap points
    if (snapPoints != null) {
      assert(snapPoints.isNotEmpty, "Snap points list cannot be empty");
      for (final point in snapPoints) {
        assert(point >= 0.0 && point <= 1.0,
            "Snap points must be between 0.0 and 1.0");
      }
      assert(
          initialSnapIndex == null ||
              (initialSnapIndex >= 0 && initialSnapIndex < snapPoints.length),
          "Initial snap index out of bounds");
    }

    final effectiveSnapPoints =
        (snapPoints == null || snapPoints.isEmpty) ? [0.5, 1.0] : snapPoints;

    // Create config from parameters
    final config = SheetConfig(
      position: position,
      modal: modal,
      barrierDismissible: barrierDismissible,
      draggable: draggable,
      useSafeArea: useSafeArea,
      borderRadius: borderRadius,
      decoration: decoration,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      padding: padding,
      constraints: constraints,
      animation: animation,
      snapPoints: effectiveSnapPoints,
      initialSnapIndex: initialSnapIndex ?? 0,
      minHeight: minHeight,
      maxHeight: maxHeight,
      isDismissible: isDismissible,
      showDragHandle: showDragHandle,
      hideKeyboard: hideKeyboard,
      headerBuilder: headerBuilder,
    );

    final sheetController = controller ?? SheetController();

    return _showDrawer<T>(
      context: context,
      builder: builder,
      config: config,
      controller: sheetController._asDrawerController(),
      onOpen: () {
        onOpen?.call();
        sheetController._notifyOpen();
      },
      onClose: () {
        onClose?.call();
        sheetController._notifyClose();
      },
      onWillClose: onWillClose,
      isSheet: true,
      onSnapPointChanged: (index) {
        sheetController._notifySnap(index);
        onSnapPointChanged?.call(index);
      },
    );
  }

  /// Internal method to show a drawer or sheet
  DrawerCompleter<T> _showDrawer<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required DrawerConfig config,
    DrawerController? controller,
    VoidCallback? onOpen,
    VoidCallback? onClose,
    bool Function()? onWillClose,
    bool isSheet = false,
    ValueChanged<int>? onSnapPointChanged,
  }) {
    closeAllDrawers();
    final completer = Completer<T?>();
    final id =
        'drawer_${DateTime.now().millisecondsSinceEpoch}_${_activeDrawers.length}';

    // Create drawer controller if not provided
    final effectiveController = controller ?? DrawerController();

    // Use late variable to break circular reference
    late DrawerEntry<T> newEntry;

    // Create the entry instance
    newEntry = DrawerEntry<T>(
        id: id,
        completer: completer,
        controller: effectiveController,
        config: config,
        onWillClose: () {
          // Allow custom will-close handler to override
          if (onWillClose != null) {
            return onWillClose();
          }
          return true;
        },
        onRemove: () {
          _activeDrawers.removeWhere((d) => d.id == id);
          _drawerCountNotifier.value = _activeDrawers.length;
          onClose?.call();
        },
        builder: (context) {
          final drawerContent = isSheet
              ? _SheetContent(
                  config: config as SheetConfig,
                  controller: effectiveController,
                  onSnapPointChanged: onSnapPointChanged,
                  child: builder(context),
                )
              : _DrawerContent(
                  config: config,
                  controller: effectiveController,
                  child: builder(context),
                );

          return _DrawerOverlay(
            entry: newEntry,
            config: config,
            child: drawerContent,
          );
        });

    // Link controller to entry
    effectiveController._entry = newEntry;

    // Add to active drawers
    _activeDrawers.add(newEntry);
    _drawerCountNotifier.value = _activeDrawers.length;

    // Hide keyboard if requested for sheet
    if (isSheet && config is SheetConfig && config.hideKeyboard) {
      FocusScope.of(context).unfocus();
    }

    // Notify open callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!newEntry.completer.isCompleted) {
        onOpen?.call();
        effectiveController._notifyOpen();
      }
    });

    return DrawerCompleter<T>(newEntry);
  }

  /// Close a specific drawer by its ID
  void closeDrawerById(String id, [dynamic result]) {
    final drawer = _activeDrawers.cast<DrawerEntry?>().firstWhere(
          (d) => d!.id == id,
          orElse: () => null,
        );
    if (drawer != null) {
      drawer.close(result);
    }
  }

  /// Close all drawers
  void closeAllDrawers([dynamic result]) {
    // Create a copy to avoid modification during iteration
    final drawers = List.from(_activeDrawers);
    for (final drawer in drawers) {
      drawer.close(result);
    }
  }

  /// Close the most recently opened drawer
  void closeLastDrawer([dynamic result]) {
    if (_activeDrawers.isNotEmpty) {
      _activeDrawers.last.close(result);
    }
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _drawerCountNotifier,
      builder: (context, count, child) {
        if (count == 0) return const SizedBox();

        final entries = _activeDrawers.map((drawer) {
          return OverlayEntry(builder: (ctx) => drawer.builder(ctx));
        }).toList();

        return Material(
          type: MaterialType.transparency,
          child: Overlay(
            initialEntries: entries,
          ),
        );
      },
    );
  }

  @override
  OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required WidgetBuilder builder,
    Offset? position,
    AlignmentGeometry? anchorAlignment,
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,
    Key? key,
    bool rootOverlay = true,
    bool modal = true,
    bool barrierDismissable = true,
    Clip clipBehavior = Clip.none,
    Object? regionGroupId,
    Offset? offset,
    AlignmentGeometry? transitionAlignment,
    EdgeInsetsGeometry? margin,
    bool follow = true,
    bool consumeOutsideTaps = true,
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
    bool allowInvertHorizontal = true,
    bool allowInvertVertical = true,
    bool dismissBackdropFocus = true,
    Duration? showDuration,
    Duration? dismissDuration,
    OverlayBarrier? overlayBarrier,
    LayerLink? layerLink,
    Size? fixedSize,
    bool? stayVisibleOnScroll,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    PopoverAnimationConfig? animationConfig,
  }) {
    throw UnimplementedError(
        'DrawerOverlayHandler does not implement standard overlay show method. '
        'Use showDrawer() or showSheet() instead.');
  }
}

/// Position of the drawer/sheet on the screen
enum DrawerPosition {
  /// Left side of the screen
  left,

  /// Right side of the screen
  right,

  /// Top of the screen
  top,

  /// Bottom of the screen
  bottom,

  /// Start side (depends on text direction)
  start,

  /// End side (depends on text direction)
  end,
}

/// Animation configuration for drawers and sheets
class DrawerAnimation {
  /// Duration for opening animation
  final Duration openDuration;

  /// Duration for closing animation
  final Duration closeDuration;

  /// Curve for opening animation
  final Curve openCurve;

  /// Curve for closing animation
  final Curve closeCurve;

  /// Type of animation
  final DrawerAnimationType type;

  /// Whether to include a fade effect
  final bool withFade;

  /// Creates a drawer animation configuration
  const DrawerAnimation({
    this.openDuration = const Duration(milliseconds: 300),
    this.closeDuration = const Duration(milliseconds: 250),
    this.openCurve = Curves.easeOutQuint,
    this.closeCurve = Curves.easeInCubic,
    this.type = DrawerAnimationType.slide,
    this.withFade = true,
  });

  /// Default animation for drawers
  static const DrawerAnimation defaults = DrawerAnimation();

  /// Fast animation preset
  static const DrawerAnimation fast = DrawerAnimation(
    openDuration: Duration(milliseconds: 200),
    closeDuration: Duration(milliseconds: 150),
  );

  /// Scale animation preset
  static const DrawerAnimation scale = DrawerAnimation(
    type: DrawerAnimationType.scale,
  );

  /// Fade animation preset
  static const DrawerAnimation fade = DrawerAnimation(
    type: DrawerAnimationType.fade,
  );
}

/// Types of animations for drawers and sheets
enum DrawerAnimationType {
  /// Slide in from edge
  slide,

  /// Scale up/down
  scale,

  /// Fade in/out
  fade,
}

/// Configuration for drawers
class DrawerConfig {
  /// Position of the drawer
  final DrawerPosition position;

  /// Whether drawer blocks interaction with content behind it
  final bool modal;

  /// Whether tapping outside dismisses the drawer
  final bool barrierDismissible;

  /// Whether drawer can be dragged to close/open
  final bool draggable;

  /// Whether to respect safe areas
  final bool useSafeArea;

  /// Whether to show drag handle
  final bool showDragHandle;

  /// Border radius of the drawer
  final BorderRadius? borderRadius;

  /// Size of the drag handle
  final Size? dragHandleSize;

  /// Custom decoration override
  final BoxDecoration? decoration;

  /// Fixed width of the drawer
  final double? width;

  /// Fixed height of the drawer
  final double? height;

  /// Elevation of the drawer surface
  final double? elevation;

  /// Background color of the drawer
  final Color? backgroundColor;

  /// Color of the barrier behind the drawer
  final Color? barrierColor;

  /// Padding inside the drawer
  final EdgeInsets? padding;

  /// Constraints for the drawer size
  final BoxConstraints? constraints;

  /// Animation configuration
  final DrawerAnimation? animation;

  /// Whether drawer can be resized
  final bool resizable;

  /// Minimum width when resizing
  final double minResizeWidth;

  /// Maximum width when resizing
  final double maxResizeWidth;

  /// Minimum height when resizing
  final double minResizeHeight;

  /// Maximum height when resizing
  final double maxResizeHeight;

  /// Optional builder for header content
  final Widget Function(BuildContext, Widget)? headerBuilder;

  /// Optional builder for footer content
  final Widget Function(BuildContext, Widget)? footerBuilder;

  /// Creates a drawer configuration
  const DrawerConfig({
    this.position = DrawerPosition.left,
    this.modal = true,
    this.barrierDismissible = true,
    this.draggable = true,
    this.useSafeArea = true,
    this.showDragHandle = true,
    this.borderRadius,
    this.dragHandleSize,
    this.decoration,
    this.width,
    this.height,
    this.elevation,
    this.backgroundColor,
    this.barrierColor,
    this.padding,
    this.constraints,
    this.animation,
    this.resizable = true,
    this.minResizeWidth = 200,
    this.maxResizeWidth = 600,
    this.minResizeHeight = 100,
    this.maxResizeHeight = 800,
    this.headerBuilder,
    this.footerBuilder,
  });

  /// Create a copy with some properties changed
  DrawerConfig copyWith({
    DrawerPosition? position,
    bool? modal,
    bool? barrierDismissible,
    bool? draggable,
    bool? useSafeArea,
    bool? showDragHandle,
    BorderRadius? borderRadius,
    Size? dragHandleSize,
    BoxDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? backgroundColor,
    Color? barrierColor,
    EdgeInsets? padding,
    BoxConstraints? constraints,
    DrawerAnimation? animation,
    bool? resizable,
    double? minResizeWidth,
    double? maxResizeWidth,
    double? minResizeHeight,
    double? maxResizeHeight,
    Widget Function(BuildContext, Widget)? headerBuilder,
    Widget Function(BuildContext, Widget)? footerBuilder,
  }) {
    return DrawerConfig(
      position: position ?? this.position,
      modal: modal ?? this.modal,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      draggable: draggable ?? this.draggable,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      borderRadius: borderRadius ?? this.borderRadius,
      dragHandleSize: dragHandleSize ?? this.dragHandleSize,
      decoration: decoration ?? this.decoration,
      width: width ?? this.width,
      height: height ?? this.height,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barrierColor: barrierColor ?? this.barrierColor,
      padding: padding ?? this.padding,
      constraints: constraints ?? this.constraints,
      animation: animation ?? this.animation,
      resizable: resizable ?? this.resizable,
      minResizeWidth: minResizeWidth ?? this.minResizeWidth,
      maxResizeWidth: maxResizeWidth ?? this.maxResizeWidth,
      minResizeHeight: minResizeHeight ?? this.minResizeHeight,
      maxResizeHeight: maxResizeHeight ?? this.maxResizeHeight,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
    );
  }
}

/// Configuration for sheets
class SheetConfig extends DrawerConfig {
  /// Snap points as fractions of screen height
  final List<double> snapPoints;

  /// Initial snap point index
  final int initialSnapIndex;

  /// Minimum height of the sheet
  final double? minHeight;

  /// Maximum height of the sheet
  final double? maxHeight;

  /// Whether the sheet can be dismissed
  final bool isDismissible;

  /// Whether to hide keyboard when sheet opens
  final bool hideKeyboard;

  /// Creates a sheet configuration
  const SheetConfig({
    super.position = DrawerPosition.bottom,
    super.modal = true,
    super.barrierDismissible = true,
    super.draggable = false,
    super.useSafeArea = true,
    super.borderRadius,
    super.decoration,
    super.backgroundColor,
    super.barrierColor,
    super.padding,
    super.constraints,
    super.animation,
    super.headerBuilder,
    this.snapPoints = const [0.5, 1.0],
    this.initialSnapIndex = 0,
    this.minHeight,
    this.maxHeight,
    this.isDismissible = true,
    super.showDragHandle = false,
    this.hideKeyboard = true,
  });

  @override
  SheetConfig copyWith({
    DrawerPosition? position,
    bool? modal,
    bool? barrierDismissible,
    bool? draggable,
    bool? useSafeArea,
    bool? showDragHandle,
    BorderRadius? borderRadius,
    Size? dragHandleSize,
    BoxDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? backgroundColor,
    Color? barrierColor,
    EdgeInsets? padding,
    BoxConstraints? constraints,
    DrawerAnimation? animation,
    bool? resizable,
    double? minResizeWidth,
    double? maxResizeWidth,
    double? minResizeHeight,
    double? maxResizeHeight,
    Widget Function(BuildContext, Widget)? headerBuilder,
    Widget Function(BuildContext, Widget)? footerBuilder,
    List<double>? snapPoints,
    int? initialSnapIndex,
    double? minHeight,
    double? maxHeight,
    bool? isDismissible,
    bool? hideKeyboard,
  }) {
    return SheetConfig(
      position: position ?? this.position,
      modal: modal ?? this.modal,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      draggable: draggable ?? this.draggable,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      borderRadius: borderRadius ?? this.borderRadius,
      decoration: decoration ?? this.decoration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barrierColor: barrierColor ?? this.barrierColor,
      padding: padding ?? this.padding,
      constraints: constraints ?? this.constraints,
      animation: animation ?? this.animation,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      snapPoints: snapPoints ?? this.snapPoints,
      initialSnapIndex: initialSnapIndex ?? this.initialSnapIndex,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      isDismissible: isDismissible ?? this.isDismissible,
      hideKeyboard: hideKeyboard ?? this.hideKeyboard,
    );
  }
}

/// Controller for programmatically managing a drawer
class DrawerController {
  /// Callbacks for drawer state changes
  final List<VoidCallback> _openCallbacks = [];
  final List<VoidCallback> _closeCallbacks = [];

  /// Whether the drawer is open
  bool _isOpen = false;

  /// Internal drawer entry
  DrawerEntry? _entry;

  /// Creates a drawer controller
  DrawerController();

  /// Whether the drawer is currently open
  bool get isOpen => _isOpen;

  /// Register a callback for when drawer opens
  void addOpenCallback(VoidCallback callback) {
    _openCallbacks.add(callback);
  }

  /// Register a callback for when drawer closes
  void addCloseCallback(VoidCallback callback) {
    _closeCallbacks.add(callback);
  }

  /// Remove an open callback
  void removeOpenCallback(VoidCallback callback) {
    _openCallbacks.remove(callback);
  }

  /// Remove a close callback
  void removeCloseCallback(VoidCallback callback) {
    _closeCallbacks.remove(callback);
  }

  /// Close the drawer
  void close([dynamic result]) {
    _entry?.close(result);
  }

  /// Notify that drawer has opened
  void _notifyOpen() {
    _isOpen = true;
    for (final callback in List.from(_openCallbacks)) {
      if (_openCallbacks.contains(callback)) {
        callback();
      }
    }
  }

  /// Notify that drawer has closed
  void _notifyClose() {
    _isOpen = false;
    for (final callback in List.from(_closeCallbacks)) {
      if (_closeCallbacks.contains(callback)) {
        callback();
      }
    }
  }

  bool get isDisposed => _entry == null;

  void dispose() {
    _openCallbacks.clear();
    _closeCallbacks.clear();
    _entry = null;
  }
}

/// Controller for programmatically managing a sheet
class SheetController extends DrawerController {
  /// Current snap point index
  int _currentSnapIndex = 0;

  /// Callbacks for snap point changes
  final List<ValueChanged<int>> _snapCallbacks = [];

  /// Creates a sheet controller
  SheetController() : super();

  /// Current snap point index
  int get currentSnapIndex => _currentSnapIndex;

  /// Register a callback for snap point changes
  void addSnapCallback(ValueChanged<int> callback) {
    _snapCallbacks.add(callback);
  }

  /// Remove a snap point callback
  void removeSnapCallback(ValueChanged<int> callback) {
    _snapCallbacks.remove(callback);
  }

  /// Snap to the specified index
  void snapTo(int index) {
    // Implementation added to _SheetContentState class
    final entry = _entry;
    if (entry != null) {
      try {
        // Find SheetContent widget and access state
        final context = entry._context;
        if (context != null) {
          final state = context.findAncestorStateOfType<_SheetContentState>();
          state?._snapToIndex(index);
        }
      } catch (e) {
        // Silently ignore if state can't be found
      }
    }
  }

  /// Notify that snap point has changed
  void _notifySnap(int index) {
    _currentSnapIndex = index;
    for (final callback in List.from(_snapCallbacks)) {
      if (_snapCallbacks.contains(callback)) {
        callback(index);
      }
    }
  }

  /// Create a DrawerController that delegates to this SheetController
  DrawerController _asDrawerController() {
    final controller = DrawerController();

    // Add forwarding methods
    controller.addOpenCallback(() {
      _notifyOpen();
    });

    controller.addCloseCallback(() {
      _notifyClose();
    });

    return controller;
  }

  @override
  void dispose() {
    _snapCallbacks.clear();
    super.dispose();
  }
}

/// Entry for a drawer in the overlay system
class DrawerEntry<T> {
  /// Unique identifier
  final String id;

  /// Completer for future result
  final Completer<T?> completer;

  /// Controller for programmatic control
  final DrawerController controller;

  /// Configuration
  final DrawerConfig config;

  /// Callback when drawer should close
  final VoidCallback onRemove;

  /// Callback to decide if drawer can close
  final bool Function() onWillClose;

  /// Builder function for drawer content
  final Widget Function(BuildContext) builder;

  /// Context for this drawer entry
  BuildContext? _context;

  /// Creates a drawer entry
  DrawerEntry({
    required this.id,
    required this.completer,
    required this.controller,
    required this.config,
    required this.onRemove,
    required this.builder,
    required this.onWillClose,
  });

  /// Whether the drawer has completed
  bool get isCompleted => completer.isCompleted;

  /// Safe dispose for DrawerEntry to avoid double close
  void close([T? result]) {
    if (completer.isCompleted) return;
    if (!onWillClose()) return;

    try {
      completer.complete(result);
    } catch (_) {}
    onRemove();
    controller._notifyClose();
    controller.dispose();
  }

  Future<void> closeAsync([T? result]) async {
    if (completer.isCompleted) return;
    final canClose = (onWillClose.call());
    if (!canClose) return;
    try {
      completer.complete(result);
    } catch (_) {}
    onRemove();
    controller._notifyClose();
    controller.dispose();
  }
}

/// Completer for drawer operations
class DrawerCompleter<T> implements OverlayCompleter<T> {
  final DrawerEntry<T> _entry;

  /// Creates a drawer completer
  DrawerCompleter(this._entry);

  @override
  void dispose() {
    if (!_entry.completer.isCompleted) {
      _entry.close();
    }
  }

  @override
  Future<T?> get future => _entry.completer.future;

  @override
  Future<void> get animationFuture => _entry.completer.future;

  @override
  bool get isCompleted => _entry.completer.isCompleted;

  @override
  bool get isAnimationCompleted => _entry.completer.isCompleted;

  @override
  void remove() {
    _entry.close();
  }
}

/// Main overlay widget for a drawer
class _DrawerOverlay extends StatefulWidget {
  final DrawerEntry entry;
  final DrawerConfig config;
  final Widget child;

  const _DrawerOverlay({
    required this.entry,
    required this.config,
    required this.child,
  });

  @override
  _DrawerOverlayState createState() => _DrawerOverlayState();
}

class _DrawerOverlayState extends State<_DrawerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _dragOffsetController;
  late Animation<double> _dragOffsetAnimation;
  final FocusScopeNode _focusNode = FocusScopeNode();
  bool _closing = false;

  // Drag‐to‐close state
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late double _drawerExtent;
  late DrawerPosition _position;

  @override
  void initState() {
    super.initState();
    final animation = widget.config.animation ?? DrawerAnimation.defaults;
    _animationController = AnimationController(
      vsync: this,
      duration: animation.openDuration,
      reverseDuration: animation.closeDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: animation.openCurve,
      reverseCurve: animation.closeCurve,
    );
    _animationController.forward();

    _dragOffsetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _dragOffset = _dragOffsetAnimation.value;
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _DrawerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldAnim = oldWidget.config.animation ?? DrawerAnimation.defaults;
    final newAnim = widget.config.animation ?? DrawerAnimation.defaults;
    if (oldAnim.openDuration != newAnim.openDuration ||
        oldAnim.closeDuration != newAnim.closeDuration) {
      _animationController
        ..duration = newAnim.openDuration
        ..reverseDuration = newAnim.closeDuration;
    }
    if (oldAnim.openCurve != newAnim.openCurve ||
        oldAnim.closeCurve != newAnim.closeCurve) {
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: newAnim.openCurve,
        reverseCurve: newAnim.closeCurve,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dragOffsetController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void close([dynamic result]) {
    if (_closing) return;
    _closing = true;
    if (!_animationController.isDismissed) {
      _animationController.reverse().then((_) {
        if (mounted && !widget.entry.isCompleted) {
          widget.entry.close(result);
        }
      });
    } else {
      widget.entry.close(result);
    }
  }

  void _handleBackdropTap() {
    if (widget.config.barrierDismissible) close();
  }

  DrawerPosition _getResolvedPosition(BuildContext ctx) {
    final pos = widget.config.position;
    if (pos == DrawerPosition.start || pos == DrawerPosition.end) {
      final isLtr = Directionality.of(ctx) == TextDirection.ltr;
      return (pos == DrawerPosition.start)
          ? (isLtr ? DrawerPosition.left : DrawerPosition.right)
          : (isLtr ? DrawerPosition.right : DrawerPosition.left);
    }
    return pos;
  }

  Alignment _getAlignment(DrawerPosition pos) {
    switch (pos) {
      case DrawerPosition.left:
        return Alignment.centerLeft;
      case DrawerPosition.right:
        return Alignment.centerRight;
      case DrawerPosition.top:
        return Alignment.topCenter;
      case DrawerPosition.bottom:
        return Alignment.bottomCenter;
      default:
        return Alignment.center;
    }
  }

  Offset _getStartOffset(DrawerPosition pos) {
    switch (pos) {
      case DrawerPosition.left:
        return const Offset(-1, 0);
      case DrawerPosition.right:
        return const Offset(1, 0);
      case DrawerPosition.top:
        return const Offset(0, -1);
      case DrawerPosition.bottom:
        return const Offset(0, 1);
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    _position = _getResolvedPosition(context);
    final anim = widget.config.animation ?? DrawerAnimation.defaults;
    widget.entry._context = context;

    final backdrop = widget.config.modal
        ? Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleBackdropTap,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  color: widget.config.barrierColor ??
                      Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        : const SizedBox();

    final drawerWithHandle =
        _buildAnimatedDrawerContentWithHandle(_position, anim);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.config.barrierDismissible && !_closing) close();
      },
      child: FocusScope(
        node: _focusNode,
        child: Stack(fit: StackFit.passthrough, children: [
          backdrop,
          drawerWithHandle,
        ]),
      ),
    );
  }

  Widget _buildAnimatedDrawerContentWithHandle(
      DrawerPosition pos, DrawerAnimation anim) {
    return Positioned.fill(
      child: SafeArea(
        left: widget.config.useSafeArea && pos == DrawerPosition.left,
        right: widget.config.useSafeArea && pos == DrawerPosition.right,
        top: widget.config.useSafeArea && pos == DrawerPosition.top,
        bottom: widget.config.useSafeArea && pos == DrawerPosition.bottom,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, child) {
            final slide = SlideTransition(
              position: Tween<Offset>(
                begin: _getStartOffset(pos),
                end: Offset.zero,
              ).animate(_animation),
              child: FadeTransition(
                opacity: widget.config.animation?.withFade == true
                    ? _animation
                    : const AlwaysStoppedAnimation(1),
                child: child,
              ),
            );
            return Align(
              alignment: _getAlignment(pos),
              child: Transform.translate(
                offset:
                    pos == DrawerPosition.left || pos == DrawerPosition.right
                        ? Offset(_dragOffset, 0)
                        : Offset(0, _dragOffset),
                child: slide,
              ),
            );
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,
                if (widget.config.draggable && widget.config.showDragHandle)
                  _buildHandle(pos),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(DrawerPosition position) {
    final size = MediaQuery.of(context).size;
    switch (position) {
      case DrawerPosition.left:
        return Positioned(
          right: -12,
          top: size.height / 2 - 20,
          child: _handleWidget(horizontal: true),
        );
      case DrawerPosition.right:
        return Positioned(
          left: -12,
          top: size.height / 2 - 20,
          child: _handleWidget(horizontal: true),
        );
      case DrawerPosition.top:
        return Positioned(
          bottom: -12,
          left: size.width / 2 - 20,
          child: _handleWidget(horizontal: false),
        );
      case DrawerPosition.bottom:
        return Positioned(
          top: -12,
          left: size.width / 2 - 20,
          child: _handleWidget(horizontal: false),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _handleWidget({required bool horizontal}) {
    return GestureDetector(
      onHorizontalDragStart: horizontal ? _onDragStart : null,
      onHorizontalDragUpdate: horizontal ? _onDragUpdate : null,
      onHorizontalDragEnd: horizontal ? _onDragEnd : null,
      onVerticalDragStart: !horizontal ? _onDragStart : null,
      onVerticalDragUpdate: !horizontal ? _onDragUpdate : null,
      onVerticalDragEnd: !horizontal ? _onDragEnd : null,
      child: Container(
        width: horizontal ? 30 : 60,
        height: horizontal ? 60 : 24,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails _) {
    _isDragging = true;
    _drawerExtent = _calculateExtent(context);
    if (_dragOffsetController.isAnimating) {
      _dragOffsetController.stop();
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_isDragging) return;
    final delta =
        (_position == DrawerPosition.left || _position == DrawerPosition.right)
            ? d.delta.dx
            : d.delta.dy;

    setState(() {
      switch (_position) {
        case DrawerPosition.left:
          if (delta < 0 || (_dragOffset < 0 && delta > 0)) {
            _dragOffset = (_dragOffset + delta).clamp(-_drawerExtent, 0.0);
          }
          break;
        case DrawerPosition.right:
          if (delta > 0 || (_dragOffset > 0 && delta < 0)) {
            _dragOffset = (_dragOffset + delta).clamp(0.0, _drawerExtent);
          }
          break;
        case DrawerPosition.top:
          if (delta < 0 || (_dragOffset < 0 && delta > 0)) {
            _dragOffset = (_dragOffset + delta).clamp(-_drawerExtent, 0.0);
          }
          break;
        case DrawerPosition.bottom:
          if (delta > 0 || (_dragOffset > 0 && delta < 0)) {
            _dragOffset = (_dragOffset + delta).clamp(0.0, _drawerExtent);
          }
          break;
        default:
      }
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _isDragging = false;
    final threshold = _drawerExtent * 0.15;
    bool shouldClose = false;

    switch (_position) {
      case DrawerPosition.left:
        shouldClose = _dragOffset < -threshold;
        break;
      case DrawerPosition.right:
        shouldClose = _dragOffset > threshold;
        break;
      case DrawerPosition.top:
        shouldClose = _dragOffset < -threshold;
        break;
      case DrawerPosition.bottom:
        shouldClose = _dragOffset > threshold;
        break;
      default:
    }

    if (shouldClose) {
      close();
    } else {
      _dragOffsetAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _dragOffsetController,
        curve: Curves.easeOut,
      ));
      _dragOffsetController.forward(from: 0.0);
    }
  }

  double _calculateExtent(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    return (_position == DrawerPosition.left ||
            _position == DrawerPosition.right)
        ? widget.config.width ?? size.width * 0.85
        : widget.config.height ?? size.height * 0.5;
  }
}

/// Content widget for drawers
class _DrawerContent extends StatefulWidget {
  final DrawerConfig config;
  final DrawerController controller;
  final Widget child;

  const _DrawerContent({
    required this.config,
    required this.controller,
    required this.child,
  });

  @override
  _DrawerContentState createState() => _DrawerContentState();
}

class _DrawerContentState extends State<_DrawerContent> {
  double _currentWidth = 0;
  double _currentHeight = 0;
  bool _resizing = false;

  @override
  void didUpdateWidget(_DrawerContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if fixed width or height changed
    if (widget.config.width != oldWidget.config.width ||
        widget.config.height != oldWidget.config.height) {
      setState(() {
        _currentWidth = 0; // Reset to use new width
        _currentHeight = 0; // Reset to use new height
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPosition = _resolvePosition(context);

    // Apply constraints based on position
    BoxConstraints constraints = const BoxConstraints();

    // Apply width/height based on position
    if (resolvedPosition == DrawerPosition.left ||
        resolvedPosition == DrawerPosition.right) {
      if (widget.config.width != null) {
        constraints = constraints.copyWith(
          minWidth: widget.config.width,
          maxWidth: widget.config.width,
        );
      } else if (_currentWidth > 0) {
        constraints = constraints.copyWith(
          minWidth: _currentWidth,
          maxWidth: _currentWidth,
        );
      } else {
        constraints = constraints.copyWith(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        );
      }

      // Full height by default
      constraints = constraints.copyWith(
        minHeight: 0,
        maxHeight: double.infinity,
      );
    } else {
      if (widget.config.height != null) {
        constraints = constraints.copyWith(
          minHeight: widget.config.height,
          maxHeight: widget.config.height,
        );
      } else if (_currentHeight > 0) {
        constraints = constraints.copyWith(
          minHeight: _currentHeight,
          maxHeight: _currentHeight,
        );
      } else {
        constraints = constraints.copyWith(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        );
      }

      // Full width by default
      constraints = constraints.copyWith(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    }

    // If widget has constraints, use those
    if (widget.config.constraints != null) {
      constraints = constraints.copyWith(
        minWidth: widget.config.constraints!.minWidth,
        maxWidth: widget.config.constraints!.maxWidth,
        minHeight: widget.config.constraints!.minHeight,
        maxHeight: widget.config.constraints!.maxHeight,
      );
    }

    // Create decoration
    final decoration = widget.config.decoration ??
        BoxDecoration(
          color: widget.config.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: widget.config.borderRadius ??
              _getDefaultBorderRadius(resolvedPosition),
          boxShadow: widget.config.elevation != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: widget.config.elevation! * 2,
                    spreadRadius: widget.config.elevation! / 2,
                  )
                ]
              : null,
        );

    // Create the content with possible header/footer
    Widget content = widget.child;

    // Apply header if provided
    if (widget.config.headerBuilder != null) {
      content = widget.config.headerBuilder!(context, content);
    }

    // Apply footer if provided
    if (widget.config.footerBuilder != null) {
      content = widget.config.footerBuilder!(context, content);
    }

    // Apply padding
    if (widget.config.padding != null) {
      content = Padding(
        padding: widget.config.padding!,
        child: content,
      );
    }

    // Build the drawer with proper layout based on position
    Widget drawer;

    if (resolvedPosition == DrawerPosition.left ||
        resolvedPosition == DrawerPosition.right) {
      drawer = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (resolvedPosition == DrawerPosition.right &&
              widget.config.resizable)
            _buildHorizontalResizeHandle(theme, resolvedPosition),
          Flexible(child: content),
          if (resolvedPosition == DrawerPosition.left &&
              widget.config.resizable)
            _buildHorizontalResizeHandle(theme, resolvedPosition),
        ],
      );
    } else {
      drawer = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (resolvedPosition == DrawerPosition.bottom &&
              widget.config.resizable)
            _buildVerticalResizeHandle(theme, resolvedPosition),
          Flexible(child: content),
          if (resolvedPosition == DrawerPosition.top && widget.config.resizable)
            _buildVerticalResizeHandle(theme, resolvedPosition),
        ],
      );
    }

    // Apply constraints and decoration
    return Container(
      constraints: constraints,
      decoration: decoration,
      child: drawer,
    );
  }

  /// Resolve position based on text direction
  DrawerPosition _resolvePosition(BuildContext context) {
    switch (widget.config.position) {
      case DrawerPosition.start:
        return Directionality.of(context) == TextDirection.ltr
            ? DrawerPosition.left
            : DrawerPosition.right;
      case DrawerPosition.end:
        return Directionality.of(context) == TextDirection.ltr
            ? DrawerPosition.right
            : DrawerPosition.left;
      default:
        return widget.config.position;
    }
  }

  /// Get default border radius based on position
  BorderRadius _getDefaultBorderRadius(DrawerPosition position) {
    switch (position) {
      case DrawerPosition.left:
        return const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      case DrawerPosition.right:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        );
      case DrawerPosition.top:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      case DrawerPosition.bottom:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        );
      default:
        return BorderRadius.circular(16);
    }
  }

  /// Build horizontal resize handle
  Widget _buildHorizontalResizeHandle(
      ThemeData theme, DrawerPosition position) {
    return GestureDetector(
      onHorizontalDragStart: _handleResizeStart,
      onHorizontalDragUpdate: (details) => _handleResize(details, position),
      onHorizontalDragEnd: _handleResizeEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          width: 20,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Build vertical resize handle
  Widget _buildVerticalResizeHandle(ThemeData theme, DrawerPosition position) {
    return GestureDetector(
      onVerticalDragStart: _handleResizeStart,
      onVerticalDragUpdate: (details) => _handleResize(details, position),
      onVerticalDragEnd: _handleResizeEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          height: 20,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle resize start
  void _handleResizeStart(DragStartDetails details) {
    final size = (context.findRenderObject() as RenderBox?)?.size;
    if (size == null) return;

    setState(() {
      _resizing = true;
      final resolvedPosition = _resolvePosition(context);
      if (resolvedPosition == DrawerPosition.left ||
          resolvedPosition == DrawerPosition.right) {
        _currentWidth = size.width;
      } else {
        _currentHeight = size.height;
      }
    });
  }

  /// Handle resize update
  void _handleResize(DragUpdateDetails details, DrawerPosition position) {
    if (!widget.config.resizable || !_resizing) return;

    setState(() {
      switch (position) {
        case DrawerPosition.left:
          _currentWidth += details.delta.dx;
          _currentWidth = _currentWidth.clamp(
            widget.config.minResizeWidth,
            widget.config.maxResizeWidth,
          );
          break;

        case DrawerPosition.right:
          _currentWidth -= details.delta.dx;
          _currentWidth = _currentWidth.clamp(
            widget.config.minResizeWidth,
            widget.config.maxResizeWidth,
          );
          break;

        case DrawerPosition.top:
          _currentHeight += details.delta.dy;
          _currentHeight = _currentHeight.clamp(
            widget.config.minResizeHeight,
            widget.config.maxResizeHeight,
          );
          break;

        case DrawerPosition.bottom:
          _currentHeight -= details.delta.dy;
          _currentHeight = _currentHeight.clamp(
            widget.config.minResizeHeight,
            widget.config.maxResizeHeight,
          );
          break;

        default:
          break;
      }
    });
  }

  /// Handle resize end
  void _handleResizeEnd(DragEndDetails details) {
    setState(() {
      _resizing = false;
    });
  }
}

/// Content widget for sheets
class _SheetContent extends StatefulWidget {
  final SheetConfig config;
  final DrawerController controller;
  final Widget child;
  final ValueChanged<int>? onSnapPointChanged;

  const _SheetContent({
    required this.config,
    required this.controller,
    required this.child,
    this.onSnapPointChanged,
  });

  @override
  _SheetContentState createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent>
    with SingleTickerProviderStateMixin {
  late double _currentHeight;
  late int _currentSnapIndex;
  late AnimationController _snapAnimationController;
  late Animation<double> _snapAnimation;
  double? _dragStartHeight;
  bool _initialHeightMeasured = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Initialize snap index safely
    _currentSnapIndex = widget.config.initialSnapIndex
        .clamp(0, widget.config.snapPoints.length - 1);

    // Initialize animation controller
    _snapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _snapAnimation = CurvedAnimation(
      parent: _snapAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Set initial height (will be set in first build)
    _currentHeight = 0;

    // Link to sheet controller if available
    if (widget.controller is SheetController) {
      final sheetController = widget.controller as SheetController;
      sheetController._currentSnapIndex = _currentSnapIndex;
    }

    // Schedule measurement after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _measureInitialHeight();
      }
    });
  }

  @override
  void didUpdateWidget(_SheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.snapPoints != oldWidget.config.snapPoints ||
        widget.config.initialSnapIndex != oldWidget.config.initialSnapIndex) {
      _currentSnapIndex = widget.config.initialSnapIndex
          .clamp(0, widget.config.snapPoints.length - 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _measureInitialHeight();
        }
      });
    }
  }

  @override
  void dispose() {
    _snapAnimation.removeListener(_heightListener);
    _snapAnimationController.dispose();
    super.dispose();
  }

  void _heightListener() {
    if (mounted) setState(() => _currentHeight = _snapAnimation.value);
  }

  /// Measure the initial height of the sheet
  void _measureInitialHeight() {
    final screenHeight = MediaQuery.of(context).size.height;

    // Use snap point for initial height
    _currentHeight = widget.config.snapPoints[_currentSnapIndex] * screenHeight;
    _initialHeightMeasured = true;

    // Force rebuild to use measured height
    if (mounted) {
      setState(() {});
    }
  }

  /// Snap to specified index
  void _snapToIndex(int index) {
    if (!mounted) return;
    final validIndex = index.clamp(0, widget.config.snapPoints.length - 1);
    if (validIndex == _currentSnapIndex) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = widget.config.snapPoints[validIndex] * screenHeight;

    setState(() {
      _currentSnapIndex = validIndex;
      if (widget.controller is SheetController) {
        (widget.controller as SheetController)._notifySnap(validIndex);
      }
    });

    widget.onSnapPointChanged?.call(validIndex);
    _animateToHeight(targetHeight);
  }

  /// Animate to target height
  void _animateToHeight(double targetHeight) {
    _snapAnimationController.reset();

    _snapAnimation.removeListener(_heightListener);
    _snapAnimation = Tween<double>(
      begin: _currentHeight,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _snapAnimationController,
      curve: Curves.easeOutCubic,
    ));
    _snapAnimation.addListener(_heightListener);

    _snapAnimationController.forward();
  }

  /// Handle drag start
  void _handleDragStart(DragStartDetails details) {
    if (_isDragging) return;

    _isDragging = true;
    _dragStartHeight = _currentHeight;
    _snapAnimationController.stop();
  }

  /// Handle drag update
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!mounted || _dragStartHeight == null || !_isDragging) return;

    setState(() {
      // Adjust height with resistance
      final screenHeight = MediaQuery.of(context).size.height;
      final maxHeight = widget.config.maxHeight ?? screenHeight * 0.9;
      final minHeight = widget.config.minHeight ?? screenHeight * 0.2;

      // Apply drag with resistance at edges
      double newHeight = _dragStartHeight! - details.delta.dy;

      if (newHeight > maxHeight) {
        // Apply resistance at top
        newHeight = maxHeight + (newHeight - maxHeight) * 0.2;
      } else if (newHeight < minHeight) {
        // Apply resistance at bottom
        newHeight = minHeight - (minHeight - newHeight) * 0.2;
      }

      _currentHeight = newHeight;
    });
  }

  /// Handle drag end
  void _handleDragEnd(DragEndDetails details) {
    if (!mounted || !_isDragging) return;

    _isDragging = false;
    _dragStartHeight = null;

    final velocity = details.velocity.pixelsPerSecond.dy;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dismiss if velocity is high enough and dismissible
    if (velocity > 1000 && widget.config.isDismissible) {
      widget.onSnapPointChanged?.call(-1);
      widget.controller.close();
      return;
    }

    // Find closest snap point
    int closestIndex = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < widget.config.snapPoints.length; i++) {
      final snapHeight = widget.config.snapPoints[i] * screenHeight;
      final distance = (_currentHeight - snapHeight).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    // Consider velocity for snap decision
    if (velocity.abs() > 500) {
      if (velocity > 0 && closestIndex > 0) {
        // Snap to lower point
        closestIndex--;
      } else if (velocity < 0 &&
          closestIndex < widget.config.snapPoints.length - 1) {
        // Snap to higher point
        closestIndex++;
      }
    }

    _snapToIndex(closestIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPosition = _resolvePosition(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Initialize current height if not set and set flag
    if (!_initialHeightMeasured) {
      _currentHeight =
          widget.config.snapPoints[_currentSnapIndex] * screenHeight;
    }

    // Create decoration
    final decoration = widget.config.decoration ??
        BoxDecoration(
          color: widget.config.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: widget.config.borderRadius ??
              _getDefaultBorderRadius(resolvedPosition),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        );

    // Create sheet content with header
    Widget content = widget.child;

    // Apply header if provided
    if (widget.config.headerBuilder != null) {
      content = widget.config.headerBuilder!(context, content);
    }

    // Apply padding
    if (widget.config.padding != null) {
      content = Padding(
        padding: widget.config.padding!,
        child: content,
      );
    }

    // Build drag handle if needed
    Widget? dragHandle;
    if (widget.config.showDragHandle) {
      dragHandle = Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    // Build the sheet based on position
    Widget sheet;
    switch (resolvedPosition) {
      case DrawerPosition.bottom:
        sheet = SizedBox(
          width: screenWidth,
          height: _currentHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dragHandle != null) ...[
                const Gap(12),
                dragHandle,
                const Gap(8),
              ],
              Expanded(child: content),
            ],
          ),
        );
        break;

      case DrawerPosition.top:
        sheet = SizedBox(
          width: screenWidth,
          height: _currentHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: content),
              if (dragHandle != null) ...[
                const Gap(8),
                dragHandle,
                const Gap(12),
              ],
            ],
          ),
        );
        break;

      case DrawerPosition.left:
        sheet = SizedBox(
          width: _currentHeight, // Use height for width in this orientation
          height: screenHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: content),
              if (dragHandle != null) ...[
                const Gap(8),
                RotatedBox(
                  quarterTurns: 1,
                  child: dragHandle,
                ),
                const Gap(12),
              ],
            ],
          ),
        );
        break;

      case DrawerPosition.right:
        sheet = SizedBox(
          width: _currentHeight, // Use height for width in this orientation
          height: screenHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dragHandle != null) ...[
                const Gap(12),
                RotatedBox(
                  quarterTurns: 1,
                  child: dragHandle,
                ),
                const Gap(8),
              ],
              Expanded(child: content),
            ],
          ),
        );
        break;

      default:
        sheet = const SizedBox.shrink();
    }

    // Apply gesture detector for dragging if enabled
    if (widget.config.draggable) {
      sheet = GestureDetector(
        onVerticalDragStart: resolvedPosition == DrawerPosition.top ||
                resolvedPosition == DrawerPosition.bottom
            ? _handleDragStart
            : null,
        onVerticalDragUpdate: resolvedPosition == DrawerPosition.top ||
                resolvedPosition == DrawerPosition.bottom
            ? _handleDragUpdate
            : null,
        onVerticalDragEnd: resolvedPosition == DrawerPosition.top ||
                resolvedPosition == DrawerPosition.bottom
            ? _handleDragEnd
            : null,
        onHorizontalDragStart: resolvedPosition == DrawerPosition.left ||
                resolvedPosition == DrawerPosition.right
            ? _handleDragStart
            : null,
        onHorizontalDragUpdate: resolvedPosition == DrawerPosition.left ||
                resolvedPosition == DrawerPosition.right
            ? _handleDragUpdate
            : null,
        onHorizontalDragEnd: resolvedPosition == DrawerPosition.left ||
                resolvedPosition == DrawerPosition.right
            ? _handleDragEnd
            : null,
        child: sheet,
      );
    }

    // Apply decoration
    return Container(
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: sheet,
    );
  }

  /// Resolve position based on text direction
  DrawerPosition _resolvePosition(BuildContext context) {
    switch (widget.config.position) {
      case DrawerPosition.start:
        return Directionality.of(context) == TextDirection.ltr
            ? DrawerPosition.left
            : DrawerPosition.right;
      case DrawerPosition.end:
        return Directionality.of(context) == TextDirection.ltr
            ? DrawerPosition.right
            : DrawerPosition.left;
      default:
        return widget.config.position;
    }
  }

  /// Get default border radius based on position
  BorderRadius _getDefaultBorderRadius(DrawerPosition position) {
    switch (position) {
      case DrawerPosition.left:
        return const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      case DrawerPosition.right:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        );
      case DrawerPosition.top:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      case DrawerPosition.bottom:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        );
      default:
        return BorderRadius.circular(16);
    }
  }
}

/// Helper functions for closing drawers/sheets from any context
Future<void> closeDrawer<T>(BuildContext context, [T? result]) async {
  final manager = OverlayManager.maybeOf(context);
  if (manager != null) {
    final handler = manager.drawerHandler;
    handler.closeLastDrawer(result);
    return;
  }
  return Future.value();
}

Future<void> closeSheet<T>(BuildContext context, [T? result]) async {
  return closeDrawer(context, result);
}

/// Shows a drawer with the specified configuration
DrawerCompleter<T> showDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  DrawerPosition position = DrawerPosition.left,
  bool modal = true,
  bool barrierDismissible = true,
  bool draggable = true,
  bool useSafeArea = true,
  bool showDragHandle = true,
  BorderRadius? borderRadius,
  Size? dragHandleSize,
  BoxDecoration? decoration,
  double? width,
  double? height,
  double? elevation,
  Color? backgroundColor,
  Color? barrierColor,
  EdgeInsets? padding,
  BoxConstraints? constraints,
  DrawerAnimation? animation,
  DrawerController? controller,
  VoidCallback? onOpen,
  VoidCallback? onClose,
  bool Function()? onWillClose,
  bool resizable = false,
  double minResizeWidth = 200,
  double maxResizeWidth = 600,
  double minResizeHeight = 100,
  double maxResizeHeight = 800,
  Widget Function(BuildContext, Widget)? headerBuilder,
  Widget Function(BuildContext, Widget)? footerBuilder,
}) {
  final manager = OverlayManager.of(context);
  final handler = manager.drawerHandler;
  return handler.showDrawer(
    context: context,
    builder: builder,
    position: position,
    modal: modal,
    barrierDismissible: barrierDismissible,
    draggable: draggable,
    useSafeArea: useSafeArea,
    showDragHandle: showDragHandle,
    borderRadius: borderRadius,
    dragHandleSize: dragHandleSize,
    decoration: decoration,
    width: width,
    height: height,
    elevation: elevation,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    padding: padding,
    constraints: constraints,
    animation: animation,
    controller: controller,
    onOpen: onOpen,
    onClose: onClose,
    onWillClose: onWillClose,
    resizable: resizable,
    minResizeWidth: minResizeWidth,
    maxResizeWidth: maxResizeWidth,
    minResizeHeight: minResizeHeight,
    maxResizeHeight: maxResizeHeight,
    headerBuilder: headerBuilder,
    footerBuilder: footerBuilder,
  );
}

/// Shows a sheet with the specified configuration
DrawerOverlayHandler showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  DrawerPosition position = DrawerPosition.bottom,
  bool modal = true,
  bool barrierDismissible = true,
  bool draggable = true,
  bool useSafeArea = true,
  BorderRadius? borderRadius = const BorderRadius.all(Radius.zero),
  BoxDecoration? decoration,
  Color? backgroundColor,
  Color? barrierColor,
  EdgeInsets? padding,
  BoxConstraints? constraints,
  DrawerAnimation? animation,
  SheetController? controller,
  List<double>? snapPoints,
  int? initialSnapIndex,
  double? minHeight,
  double? maxHeight,
  VoidCallback? onOpen,
  VoidCallback? onClose,
  bool Function()? onWillClose,
  ValueChanged<int>? onSnapPointChanged,
  bool isDismissible = true,
  bool showDragHandle = false,
  bool hideKeyboard = true,
  Widget Function(BuildContext, Widget)? headerBuilder,
}) {
  final manager = OverlayManager.of(context);
  final handler = manager.drawerHandler;
  return handler
    ..showSheet(
      context: context,
      builder: builder,
      position: position,
      modal: modal,
      barrierDismissible: barrierDismissible,
      draggable: draggable,
      useSafeArea: useSafeArea,
      borderRadius: borderRadius,
      decoration: decoration,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      padding: padding,
      constraints: constraints,
      animation: animation,
      controller: controller,
      snapPoints: snapPoints,
      initialSnapIndex: initialSnapIndex,
      minHeight: minHeight,
      maxHeight: maxHeight,
      onOpen: onOpen,
      onClose: onClose,
      onWillClose: onWillClose,
      onSnapPointChanged: onSnapPointChanged,
      isDismissible: isDismissible,
      showDragHandle: showDragHandle,
      hideKeyboard: hideKeyboard,
      headerBuilder: headerBuilder,
    );
}
