import 'package:flutter/material.dart';
import 'package:data_widget/data_widget.dart';
import 'popover.dart';
import 'toast.dart';
import 'drawer.dart';

/// Configuration class for overlay display parameters
class OverlayConfig<T> {
  final BuildContext context;
  final WidgetBuilder builder;
  final AlignmentGeometry alignment;
  final Offset? position;
  final AlignmentGeometry? anchorAlignment;
  final PopoverConstraint widthConstraint;
  final PopoverConstraint heightConstraint;
  final Key? key;
  final bool rootOverlay;
  final bool modal;
  final bool barrierDismissable;
  final Clip clipBehavior;
  final Object? regionGroupId;
  final Offset? offset;
  final AlignmentGeometry? transitionAlignment;
  final EdgeInsetsGeometry? margin;
  final bool follow;
  final bool consumeOutsideTaps;
  final ValueChanged<PopoverOverlayWidgetState>? onTickFollow;
  final bool allowInvertHorizontal;
  final bool allowInvertVertical;
  final bool dismissBackdropFocus;
  final Duration? showDuration;
  final Duration? dismissDuration;
  final OverlayBarrier? overlayBarrier;
  final LayerLink? layerLink;
  final Size? fixedSize;
  final Curve showCurve;
  final Curve dismissCurve;
  final int zIndex;
  final bool? stayVisibleOnScroll;
  final List<PopoverAnimationType>? enterAnimations;
  final List<PopoverAnimationType>? exitAnimations;
  final PopoverAnimationConfig? animationConfig;
  final bool? alwaysFocus;

  const OverlayConfig({
    required this.context,
    required this.builder,
    this.alignment = Alignment.center,
    this.position,
    this.anchorAlignment,
    this.widthConstraint = PopoverConstraint.flexible,
    this.heightConstraint = PopoverConstraint.flexible,
    this.key,
    this.rootOverlay = true,
    this.modal = true,
    this.barrierDismissable = true,
    this.clipBehavior = Clip.none,
    this.regionGroupId,
    this.offset,
    this.transitionAlignment,
    this.margin,
    this.follow = true,
    this.consumeOutsideTaps = true,
    this.onTickFollow,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
    this.dismissBackdropFocus = true,
    this.showDuration,
    this.dismissDuration,
    this.overlayBarrier,
    this.layerLink,
    this.fixedSize,
    this.showCurve = Curves.easeOutCubic,
    this.dismissCurve = Curves.easeInCubic,
    this.zIndex = 0,
    this.stayVisibleOnScroll,
    this.enterAnimations,
    this.exitAnimations,
    this.animationConfig,
    this.alwaysFocus = false,
  });

  /// Creates a copy of this config with the given fields replaced with new values
  OverlayConfig<T> copyWith({
    BuildContext? context,
    WidgetBuilder? builder,
    AlignmentGeometry? alignment,
    Offset? position,
    AlignmentGeometry? anchorAlignment,
    PopoverConstraint? widthConstraint,
    PopoverConstraint? heightConstraint,
    Key? key,
    bool? rootOverlay,
    bool? modal,
    bool? barrierDismissable,
    Clip? clipBehavior,
    Object? regionGroupId,
    Offset? offset,
    AlignmentGeometry? transitionAlignment,
    EdgeInsetsGeometry? margin,
    bool? follow,
    bool? consumeOutsideTaps,
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
    bool? allowInvertHorizontal,
    bool? allowInvertVertical,
    bool? dismissBackdropFocus,
    Duration? showDuration,
    Duration? dismissDuration,
    OverlayBarrier? overlayBarrier,
    LayerLink? layerLink,
    Size? fixedSize,
    Curve? showCurve,
    Curve? dismissCurve,
    int? zIndex,
    bool? stayVisibleOnScroll,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    PopoverAnimationConfig? animationConfig,
    bool? alwaysFocus,
  }) {
    return OverlayConfig<T>(
      context: context ?? this.context,
      builder: builder ?? this.builder,
      alignment: alignment ?? this.alignment,
      position: position ?? this.position,
      anchorAlignment: anchorAlignment ?? this.anchorAlignment,
      widthConstraint: widthConstraint ?? this.widthConstraint,
      heightConstraint: heightConstraint ?? this.heightConstraint,
      key: key ?? this.key,
      rootOverlay: rootOverlay ?? this.rootOverlay,
      modal: modal ?? this.modal,
      barrierDismissable: barrierDismissable ?? this.barrierDismissable,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      regionGroupId: regionGroupId ?? this.regionGroupId,
      offset: offset ?? this.offset,
      transitionAlignment: transitionAlignment ?? this.transitionAlignment,
      margin: margin ?? this.margin,
      follow: follow ?? this.follow,
      consumeOutsideTaps: consumeOutsideTaps ?? this.consumeOutsideTaps,
      onTickFollow: onTickFollow ?? this.onTickFollow,
      allowInvertHorizontal:
          allowInvertHorizontal ?? this.allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical ?? this.allowInvertVertical,
      dismissBackdropFocus: dismissBackdropFocus ?? this.dismissBackdropFocus,
      showDuration: showDuration ?? this.showDuration,
      dismissDuration: dismissDuration ?? this.dismissDuration,
      overlayBarrier: overlayBarrier ?? this.overlayBarrier,
      layerLink: layerLink ?? this.layerLink,
      fixedSize: fixedSize ?? this.fixedSize,
      showCurve: showCurve ?? this.showCurve,
      dismissCurve: dismissCurve ?? this.dismissCurve,
      zIndex: zIndex ?? this.zIndex,
      stayVisibleOnScroll: stayVisibleOnScroll ?? this.stayVisibleOnScroll,
      enterAnimations: enterAnimations ?? this.enterAnimations,
      exitAnimations: exitAnimations ?? this.exitAnimations,
      animationConfig: animationConfig ?? this.animationConfig,
      alwaysFocus: alwaysFocus ?? this.alwaysFocus,
    );
  }
}

/// Closes an overlay from the specified context
Future<void> closeOverlay<T>(BuildContext context, [T? value]) {
  // No DrawerHandlerStateMixin: Use OverlayManager
  final manager = OverlayManager.maybeOf(context);
  if (manager != null) {
    return manager.closeLastOverlay();
  }
  return Future.value();
}

/// Mixin for overlay handlers that need to manage state
mixin OverlayHandlerStateMixin<T extends StatefulWidget> on State<T> {
  /// Close the overlay, optionally immediately without animation
  Future<void> close([bool immediate = false]);

  /// Schedule the overlay to close after current operation completes
  void closeLater();

  /// Close the overlay with a result value
  Future<void> closeWithResult<X>([X? value]);

  /// Update the anchor context for the overlay
  set anchorContext(BuildContext value);

  /// Update the alignment of the overlay
  set alignment(AlignmentGeometry value);

  /// Update the anchor alignment of the overlay
  set anchorAlignment(AlignmentGeometry value);

  /// Update the width constraint of the overlay
  set widthConstraint(PopoverConstraint value);

  /// Update the height constraint of the overlay
  set heightConstraint(PopoverConstraint value);

  /// Update the margin of the overlay
  set margin(EdgeInsetsGeometry value);

  /// Update whether the overlay should follow its anchor
  set follow(bool value);

  /// Update the offset of the overlay
  set offset(Offset? value);

  /// Update whether the overlay can invert horizontally
  set allowInvertHorizontal(bool value);

  /// Update whether the overlay can invert vertically
  set allowInvertVertical(bool value);
}

/// Interface for overlay completion handling
abstract class OverlayCompleter<T> {
  /// Remove the overlay from view
  void remove();

  /// Dispose the overlay resources
  void dispose();

  /// Whether the overlay has been completed
  bool get isCompleted;

  /// Whether the overlay animation has completed
  bool get isAnimationCompleted;

  /// Future that completes when the overlay is closed with a result
  Future<T?> get future;

  /// Future that completes when the overlay animation finishes
  Future<void> get animationFuture;
}

/// Base handler for overlays
abstract class OverlayHandler {
  const OverlayHandler();

  /// Shows an overlay with the given configuration
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
    bool? alwaysFocus = false,
  });

  /// Shows an overlay using a configuration object
  OverlayCompleter<T?> showWithConfig<T>(OverlayConfig<T> config) {
    return show<T>(
      context: config.context,
      alignment: config.alignment,
      builder: config.builder,
      position: config.position,
      anchorAlignment: config.anchorAlignment,
      widthConstraint: config.widthConstraint,
      heightConstraint: config.heightConstraint,
      key: config.key,
      rootOverlay: config.rootOverlay,
      modal: config.modal,
      barrierDismissable: config.barrierDismissable,
      clipBehavior: config.clipBehavior,
      regionGroupId: config.regionGroupId,
      offset: config.offset,
      transitionAlignment: config.transitionAlignment,
      margin: config.margin,
      follow: config.follow,
      consumeOutsideTaps: config.consumeOutsideTaps,
      onTickFollow: config.onTickFollow,
      allowInvertHorizontal: config.allowInvertHorizontal,
      allowInvertVertical: config.allowInvertVertical,
      dismissBackdropFocus: config.dismissBackdropFocus,
      showDuration: config.showDuration,
      dismissDuration: config.dismissDuration,
      overlayBarrier: config.overlayBarrier,
      layerLink: config.layerLink,
      fixedSize: config.fixedSize,
      stayVisibleOnScroll: config.stayVisibleOnScroll,
      enterAnimations: config.enterAnimations,
      exitAnimations: config.exitAnimations,
      animationConfig: config.animationConfig,
      alwaysFocus: config.alwaysFocus,
    );
  }

  /// Returns a widget that should be rendered in the overlay manager's build method
  Widget buildOverlayContent(BuildContext context) {
    return const SizedBox();
  }

  /// Initializes the handler with a context from the overlay manager
  void initWithContext(BuildContext context) {}
}

/// Configuration for overlay barriers
class OverlayBarrier {
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color? barrierColor;
  final VoidCallback? onTap;

  const OverlayBarrier({
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.barrierColor,
    this.onTap,
  });
}

/// Manager for overlays with specialized show methods
abstract class OverlayManager implements OverlayHandler {
  /// Get the overlay manager from the widget tree, returns null if not found
  static OverlayManager? maybeOf(BuildContext context) {
    return Data.maybeOf<OverlayManager>(context);
  }

  /// Get the overlay manager from the widget tree, throws if not found
  static OverlayManager of(BuildContext context) {
    var manager = maybeOf(context);
    if (manager == null) {
      throw FlutterError('No OverlayManager found in context.\n'
          'Make sure to wrap your widget tree with OverlayManagerLayer.');
    }
    return manager;
  }

  /// Close the most recently opened overlay
  Future<void> closeLastOverlay();

  /// Get the toast handler
  ToastOverlayHandler get toastHandler;

  /// Get the drawer handler for drawer/sheet interactions
  DrawerOverlayHandler get drawerHandler;

  /// Helper for getting handler by type
  T? getHandler<T>();

  @override
  OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = Alignment.center,
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
    bool? alwaysFocus = false,
  });

  @override
  OverlayCompleter<T?> showWithConfig<T>(OverlayConfig<T> config);

  /// Shows a menu overlay
  OverlayCompleter<T?> showMenu<T>(OverlayConfig<T> config);
}

/// Widget that provides overlay management capabilities
class OverlayManagerLayer extends StatefulWidget {
  final OverlayHandler popoverHandler;
  final OverlayHandler? menuHandler;
  final ToastOverlayHandler toastHandler;
  final DrawerOverlayHandler drawerHandler;
  final Widget child;

  const OverlayManagerLayer({
    super.key,
    required this.popoverHandler,
    this.menuHandler,
    required this.toastHandler,
    required this.drawerHandler,
    required this.child,
  });

  @override
  State<OverlayManagerLayer> createState() => _OverlayManagerLayerState();
}

class _OverlayManagerLayerState extends State<OverlayManagerLayer>
    implements OverlayManager {
  final List<OverlayCompleter> _activeOverlays = [];
  final List<Object> _futureSubscriptions = [];

  @override
  void initState() {
    super.initState();

    // Initialize handlers with context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.toastHandler.initWithContext(context);
        widget.drawerHandler.initWithContext(context);
      }
    });
  }

  @override
  void dispose() {
    // Close all active overlays when the widget is disposed
    for (final overlay in _activeOverlays) {
      overlay.dispose();
    }
    _activeOverlays.clear();
    _futureSubscriptions.clear();
    super.dispose();
  }

  void _registerOverlay(OverlayCompleter completer) {
    _activeOverlays.add(completer);

    // Store the future to prevent potential race conditions
    late Object subscription;
    subscription = completer.future.then((_) {
      if (mounted) {
        _activeOverlays.remove(completer);
        _futureSubscriptions.remove(subscription);
      }
    });
    _futureSubscriptions.add(subscription);
  }

  @override
  Widget build(BuildContext context) {
    return Data<OverlayManager>.inherit(
      data: this,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          // Toast overlay widget rendering
          widget.toastHandler.buildOverlayContent(context),
          // Drawer overlay widget rendering
          widget.drawerHandler.buildOverlayContent(context),
        ],
      ),
    );
  }

  OverlayCompleter<T?> _doShow<T>(
      {required OverlayHandler handler, required OverlayConfig<T> config}) {
    assert(OverlayManager.maybeOf(config.context) != null,
        'OverlayConfig.context must be within an OverlayManagerLayer');

    try {
      final completer = handler.showWithConfig<T>(config);
      _registerOverlay(completer);
      return completer;
    } catch (e) {
      debugPrint('Error showing overlay: $e');
      rethrow;
    }
  }

  @override
  OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = Alignment.center,
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
    bool? alwaysFocus = false,
  }) {
    final config = OverlayConfig<T>(
      context: context,
      builder: builder,
      alignment: alignment,
      position: position,
      anchorAlignment: anchorAlignment,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      key: key,
      rootOverlay: rootOverlay,
      modal: modal,
      barrierDismissable: barrierDismissable,
      clipBehavior: clipBehavior,
      regionGroupId: regionGroupId,
      offset: offset,
      transitionAlignment: transitionAlignment,
      margin: margin,
      follow: follow,
      consumeOutsideTaps: consumeOutsideTaps,
      onTickFollow: onTickFollow,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      dismissBackdropFocus: dismissBackdropFocus,
      showDuration: showDuration,
      dismissDuration: dismissDuration,
      overlayBarrier: overlayBarrier,
      fixedSize: fixedSize,
      stayVisibleOnScroll: stayVisibleOnScroll,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      animationConfig: animationConfig,
      alwaysFocus: alwaysFocus,
    );

    return showWithConfig(config);
  }

  @override
  OverlayCompleter<T?> showWithConfig<T>(OverlayConfig<T> config) {
    return _doShow(
      handler: widget.popoverHandler,
      config: config,
    );
  }

  @override
  OverlayCompleter<T?> showMenu<T>(OverlayConfig<T> config) {
    if (widget.menuHandler == null) {
      debugPrint(
          'Warning: No menuHandler provided, falling back to popoverHandler');
    }

    return _doShow(
      handler: widget.menuHandler ?? widget.popoverHandler,
      config: config,
    );
  }

  @override
  Future<void> closeLastOverlay() {
    if (_activeOverlays.isNotEmpty) {
      final lastOverlay = _activeOverlays.last;
      lastOverlay.remove();
      return lastOverlay.animationFuture;
    }
    return Future.value();
  }

  @override
  ToastOverlayHandler get toastHandler => widget.toastHandler;

  @override
  DrawerOverlayHandler get drawerHandler => widget.drawerHandler;

  @override
  T? getHandler<T>() {
    if (T == ToastOverlayHandler && widget.toastHandler is T) {
      return widget.toastHandler as T;
    }
    if (T == DrawerOverlayHandler && widget.drawerHandler is T) {
      return widget.drawerHandler as T;
    }
    return null;
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    // Manager just delegates to the respective handlers
    return const SizedBox();
  }

  @override
  void initWithContext(BuildContext context) {
    // Manager doesn't need this implementation since it's already initialized
    // through context in the constructor
  }
}

/// Closes a drawer from the specified context
Future<void> closeDrawer<T>(BuildContext context, [T? value]) {
  final manager = OverlayManager.maybeOf(context);
  if (manager != null) {
    return manager.closeLastOverlay();
  }
  return Future.value();
}
