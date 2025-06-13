import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:data_widget/data_widget.dart';
import 'overlay.dart';

// --- Types and Enums ---

/// Determines how the popover should be constrained in size
enum PopoverConstraint {
  flexible, // Flexible size based on content and constraints
  intrinsic, // Use intrinsic content size
  anchorFixedSize, // Use the same size as the anchor
  anchorMinSize, // Use anchor size as minimum
  anchorMaxSize, // Use anchor size as maximum
  fixed, // Fixed size from fixedSize
  fullScreen, // Use full screen size
  contentSize, // Use content size as is
}

/// Animation types available for popovers
enum PopoverAnimationType {
  none,
  fadeIn,
  fadeOut,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  scaleX,
  scaleY,
  rotate,
  skewX,
  skewY,
}

/// Type definitions for callbacks
typedef FutureVoidCallback = Future<void> Function();
typedef PopoverFutureVoidCallback<T> = Future<void> Function(T value);

// --- Animation Configuration ---

/// Animation configuration for popover
class PopoverAnimationConfig {
  /// Enter animation duration
  final Duration enterDuration;

  /// Exit animation duration
  final Duration exitDuration;

  /// Enter animation curve
  final Curve enterCurve;

  /// Exit animation curve
  final Curve exitCurve;

  /// Resize animation duration
  final Duration resizeDuration;

  /// Resize animation curve
  final Curve resizeCurve;

  /// Keyboard transition duration
  final Duration keyboardTransitionDuration;

  /// Keyboard transition curve
  final Curve keyboardTransitionCurve;

  /// List of enter animation effects
  final List<PopoverAnimationType> enterAnimations;

  /// List of exit animation effects
  final List<PopoverAnimationType> exitAnimations;

  /// Initial scale factor for enter animation (e.g., 0.8)
  final double initialScale;

  /// Transform origin for scale and rotate animations
  final Alignment transformOrigin;

  /// Starting offset for slide animation
  final Offset slideBegin;

  /// Ending offset for slide animation (usually Offset.zero)
  final Offset slideEnd;

  /// Initial rotation angle in radians
  final double rotateBegin;

  /// Ending rotation angle in radians
  final double rotateEnd;

  /// Starting skew value (for skewX)
  final double skewXBegin;

  /// Ending skew value (for skewX)
  final double skewXEnd;

  /// Starting skew value (for skewY)
  final double skewYBegin;

  /// Ending skew value (for skewY)
  final double skewYEnd;

  /// Minimum interval for position updates in manual follow mode (ms)
  final Duration minFollowInterval;

  /// Threshold distance for horizontal inversion (px)
  final double horizontalInversionThreshold;

  /// Threshold distance for vertical inversion (px)
  final double verticalInversionThreshold;

  const PopoverAnimationConfig({
    this.enterDuration = const Duration(milliseconds: 300),
    this.exitDuration = const Duration(milliseconds: 200),
    this.enterCurve = Curves.easeOutCubic,
    this.exitCurve = Curves.easeIn,
    this.resizeDuration = const Duration(milliseconds: 250),
    this.resizeCurve = Curves.easeInOutCubic,
    this.keyboardTransitionDuration = const Duration(milliseconds: 200),
    this.keyboardTransitionCurve = Curves.easeInOut,
    this.enterAnimations = const [
      PopoverAnimationType.fadeIn,
      PopoverAnimationType.scale
    ],
    this.exitAnimations = const [
      PopoverAnimationType.fadeOut,
      PopoverAnimationType.scale
    ],
    this.initialScale = 0.9,
    this.transformOrigin = Alignment.center,
    this.slideBegin = const Offset(0, 20),
    this.slideEnd = Offset.zero,
    this.rotateBegin = 0,
    this.rotateEnd = 0,
    this.skewXBegin = 0,
    this.skewXEnd = 0,
    this.skewYBegin = 0,
    this.skewYEnd = 0,
    this.minFollowInterval = const Duration(milliseconds: 16),
    this.horizontalInversionThreshold = 12.0,
    this.verticalInversionThreshold = 12.0,
  });

  /// Creates a copy of this config with modified values
  PopoverAnimationConfig copyWith({
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    Duration? resizeDuration,
    Curve? resizeCurve,
    Duration? keyboardTransitionDuration,
    Curve? keyboardTransitionCurve,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    double? initialScale,
    Alignment? transformOrigin,
    Offset? slideBegin,
    Offset? slideEnd,
    double? rotateBegin,
    double? rotateEnd,
    double? skewXBegin,
    double? skewXEnd,
    double? skewYBegin,
    double? skewYEnd,
    Duration? minFollowInterval,
    double? horizontalInversionThreshold,
    double? verticalInversionThreshold,
  }) {
    return PopoverAnimationConfig(
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      resizeDuration: resizeDuration ?? this.resizeDuration,
      resizeCurve: resizeCurve ?? this.resizeCurve,
      keyboardTransitionDuration:
          keyboardTransitionDuration ?? this.keyboardTransitionDuration,
      keyboardTransitionCurve:
          keyboardTransitionCurve ?? this.keyboardTransitionCurve,
      enterAnimations: enterAnimations ?? this.enterAnimations,
      exitAnimations: exitAnimations ?? this.exitAnimations,
      initialScale: initialScale ?? this.initialScale,
      transformOrigin: transformOrigin ?? this.transformOrigin,
      slideBegin: slideBegin ?? this.slideBegin,
      slideEnd: slideEnd ?? this.slideEnd,
      rotateBegin: rotateBegin ?? this.rotateBegin,
      rotateEnd: rotateEnd ?? this.rotateEnd,
      skewXBegin: skewXBegin ?? this.skewXBegin,
      skewXEnd: skewXEnd ?? this.skewXEnd,
      skewYBegin: skewYBegin ?? this.skewYBegin,
      skewYEnd: skewYEnd ?? this.skewYEnd,
      minFollowInterval: minFollowInterval ?? this.minFollowInterval,
      horizontalInversionThreshold:
          horizontalInversionThreshold ?? this.horizontalInversionThreshold,
      verticalInversionThreshold:
          verticalInversionThreshold ?? this.verticalInversionThreshold,
    );
  }

  /// Creates animation configuration based on anchor alignment
  factory PopoverAnimationConfig.fromAnchorAlignment(
    AlignmentGeometry alignment, {
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
  }) {
    // Resolve alignment
    final resolvedAlignment = alignment is Alignment
        ? alignment
        : alignment.resolve(TextDirection.ltr);

    // Determine animation type based on alignment
    List<PopoverAnimationType> enterAnimations = [];
    List<PopoverAnimationType> exitAnimations = [];
    Offset slideBegin = Offset.zero;

    // Add fade effect by default
    enterAnimations.add(PopoverAnimationType.fadeIn);
    exitAnimations.add(PopoverAnimationType.fadeOut);

    // Add direction-specific animations
    if (resolvedAlignment.y < 0) {
      // Top alignment -> slide up
      enterAnimations.add(PopoverAnimationType.slideUp);
      exitAnimations.add(PopoverAnimationType.slideUp);
      slideBegin = const Offset(0, 20);
    } else if (resolvedAlignment.y > 0) {
      // Bottom alignment -> slide down
      enterAnimations.add(PopoverAnimationType.slideDown);
      exitAnimations.add(PopoverAnimationType.slideDown);
      slideBegin = const Offset(0, -20);
    } else if (resolvedAlignment.x < 0) {
      // Left alignment -> slide left
      enterAnimations.add(PopoverAnimationType.slideLeft);
      exitAnimations.add(PopoverAnimationType.slideLeft);
      slideBegin = const Offset(20, 0);
    } else if (resolvedAlignment.x > 0) {
      // Right alignment -> slide right
      enterAnimations.add(PopoverAnimationType.slideRight);
      exitAnimations.add(PopoverAnimationType.slideRight);
      slideBegin = const Offset(-20, 0);
    } else {
      // Center alignment -> scale
      enterAnimations.add(PopoverAnimationType.scale);
      exitAnimations.add(PopoverAnimationType.scale);
    }

    return PopoverAnimationConfig(
      enterDuration: enterDuration ?? const Duration(milliseconds: 300),
      exitDuration: exitDuration ?? const Duration(milliseconds: 200),
      enterCurve: enterCurve ?? Curves.easeOutCubic,
      exitCurve: exitCurve ?? Curves.easeIn,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      slideBegin: slideBegin,
    );
  }
}

// --- Overlay Entry Management ---

/// OverlayPopoverEntry to manage overlay entries and lifecycle
class OverlayPopoverEntry<T> implements OverlayCompleter<T?> {
  late OverlayEntry _overlayEntry;
  OverlayEntry? _barrierEntry;
  final Completer<T?> _completer = Completer<T?>();
  final Completer<void> _animationCompleter = Completer<void>();
  ValueNotifier<bool>? _isClosed;

  bool _removed = false;
  bool _disposed = false;

  @override
  bool get isCompleted => _completer.isCompleted;

  @override
  bool get isAnimationCompleted => _animationCompleter.isCompleted;

  @override
  Future<T?> get future => _completer.future;

  @override
  Future<void> get animationFuture => _animationCompleter.future;

  void initialize({
    required OverlayEntry overlayEntry,
    required OverlayEntry? barrierEntry,
    required ValueNotifier<bool> isClosed,
  }) {
    _overlayEntry = overlayEntry;
    _barrierEntry = barrierEntry;
    _isClosed = isClosed;

    _isClosed?.addListener(_handleClosedChanged);
  }

  void _handleClosedChanged() {
    if (_isClosed?.value == true && !_removed) {
      // Trigger close animation but don't remove immediately
      // Let the animation controller handle the dismissal
    }
  }

  @override
  void remove() {
    if (_removed) return;
    _removed = true;

    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }

    if (_barrierEntry?.mounted ?? false) {
      _barrierEntry?.remove();
    }

    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    if (_isClosed != null) {
      _isClosed!.removeListener(_handleClosedChanged);
    }

    if (!_completer.isCompleted) {
      _completer.complete(null);
    }

    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }

    if (!_removed) {
      remove();
    }
  }

  void complete([T? value]) {
    if (!_completer.isCompleted) {
      _completer.complete(value);
    }
  }

  void animationComplete() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }
}

// --- Handlers and Controllers ---

/// Main handler for displaying popovers
class PopoverOverlayHandler extends OverlayHandler {
  const PopoverOverlayHandler();

  @override
  OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required WidgetBuilder builder,
    ui.Offset? position,
    AlignmentGeometry? anchorAlignment,
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,
    Key? key,
    bool rootOverlay = true,
    bool modal = false,
    bool barrierDismissable = true,
    ui.Clip clipBehavior = Clip.none,
    Object? regionGroupId,
    ui.Offset? offset,
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
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    Curve? showCurve,
    Curve? dismissCurve,
    Duration? resizeDuration,
    Curve? resizeCurve,
    double initialScale = 0.9,
    PopoverAnimationConfig? animationConfig,
    bool autoFocus = false,
    bool? stayVisibleOnScroll,
    bool? alwaysFocus = false,
  }) {
    final OverlayPopoverEntry<T> popoverEntry = _createPopoverEntry<T>(
      context: context,
      alignment: alignment,
      builder: builder,
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
      overlayBarrier: overlayBarrier,
      layerLink: layerLink,
      fixedSize: fixedSize,
      animationConfig: animationConfig ??
          PopoverAnimationConfig(
            enterDuration: showDuration ?? const Duration(milliseconds: 300),
            exitDuration: dismissDuration ?? const Duration(milliseconds: 200),
            enterCurve: showCurve ?? Curves.easeOutCubic,
            exitCurve: dismissCurve ?? Curves.easeIn,
            resizeDuration: resizeDuration ?? const Duration(milliseconds: 250),
            resizeCurve: resizeCurve ?? Curves.easeInOutCubic,
            initialScale: initialScale,
            enterAnimations: enterAnimations ??
                [PopoverAnimationType.fadeIn, PopoverAnimationType.scale],
            exitAnimations: exitAnimations ??
                [PopoverAnimationType.fadeOut, PopoverAnimationType.scale],
          ),
      autoFocus: autoFocus,
      stayVisibleOnScroll: stayVisibleOnScroll ?? true,
      alwaysFocus: alwaysFocus,
    );

    return popoverEntry;
  }

  OverlayPopoverEntry<T> _createPopoverEntry<T>({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required WidgetBuilder builder,
    Offset? position,
    AlignmentGeometry? anchorAlignment,
    required PopoverConstraint widthConstraint,
    required PopoverConstraint heightConstraint,
    Key? key,
    required bool rootOverlay,
    required bool modal,
    required bool barrierDismissable,
    required ui.Clip clipBehavior,
    Object? regionGroupId,
    Offset? offset,
    AlignmentGeometry? transitionAlignment,
    EdgeInsetsGeometry? margin,
    required bool follow,
    required bool consumeOutsideTaps,
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
    required bool allowInvertHorizontal,
    required bool allowInvertVertical,
    required bool dismissBackdropFocus,
    OverlayBarrier? overlayBarrier,
    LayerLink? layerLink,
    Size? fixedSize,
    required PopoverAnimationConfig animationConfig,
    required bool autoFocus,
    required bool stayVisibleOnScroll,
    bool? alwaysFocus = false,
  }) {
    final TextDirection textDirection = Directionality.of(context);
    final Alignment resolvedAlignment = alignment.resolve(textDirection);
    anchorAlignment ??= alignment * -1;
    final Alignment resolvedAnchorAlignment =
        anchorAlignment.resolve(textDirection);

    final OverlayState overlay = Overlay.of(context, rootOverlay: rootOverlay);
    final themes = InheritedTheme.capture(from: context, to: overlay.context);
    final data = Data.capture(from: context, to: overlay.context);

    final _ResolvedPosition resolvedPos = layerLink != null
        // when using a LayerLink, we drive positioning via CompositedTransformFollower,
        // so we don’t need to look up any RenderBox on the original context
        ? _ResolvedPosition(position: Offset.zero, anchorSize: null)
        : _resolvePosition(
            context: context,
            initialPosition: position,
            resolvedAnchorAlignment: resolvedAnchorAlignment,
          );

    final OverlayPopoverEntry<T> popoverEntry = OverlayPopoverEntry<T>();
    final isClosed = ValueNotifier<bool>(false);

    OverlayEntry? barrierEntry;
    late OverlayEntry overlayEntry;

    if (modal) {
      barrierEntry = _buildBarrierEntry(
        barrierDismissable: barrierDismissable,
        consumeOutsideTaps: consumeOutsideTaps,
        isClosed: isClosed,
        popoverCompleter: popoverEntry,
        overlayBarrier: overlayBarrier,
        modal: modal,
      );
    }

    // Use default animation config based on anchor alignment if none provided
    final effectiveAnimConfig = animationConfig.enterAnimations.isEmpty &&
            animationConfig.exitAnimations.isEmpty
        ? PopoverAnimationConfig.fromAnchorAlignment(
            anchorAlignment,
            enterDuration: animationConfig.enterDuration,
            exitDuration: animationConfig.exitDuration,
            enterCurve: animationConfig.enterCurve,
            exitCurve: animationConfig.exitCurve,
          )
        : animationConfig;

    overlayEntry = _buildOverlayEntry<T>(
      context: context,
      builder: builder,
      alignment: resolvedAlignment,
      position: resolvedPos.position,
      anchorSize: resolvedPos.anchorSize,
      anchorAlignment: resolvedAnchorAlignment,
      key: key,
      isClosed: isClosed,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      regionGroupId: regionGroupId,
      offset: offset,
      transitionAlignment: transitionAlignment,
      margin: margin ?? const EdgeInsets.all(8),
      follow: follow,
      consumeOutsideTaps: consumeOutsideTaps,
      onTickFollow: onTickFollow,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      dismissBackdropFocus: dismissBackdropFocus && modal,
      themes: themes,
      data: data,
      popoverEntry: popoverEntry,
      layerLink: layerLink,
      fixedSize: fixedSize,
      modal: modal,
      animationConfig: effectiveAnimConfig,
      autoFocus: autoFocus,
      stayVisibleOnScroll: stayVisibleOnScroll,
      alwaysFocus: alwaysFocus,
    );

    popoverEntry.initialize(
      overlayEntry: overlayEntry,
      barrierEntry: barrierEntry,
      isClosed: isClosed,
    );

    if (barrierEntry != null) {
      overlay.insert(barrierEntry);
    }
    overlay.insert(overlayEntry);

    return popoverEntry;
  }

  OverlayEntry _buildBarrierEntry({
    required bool barrierDismissable,
    required bool consumeOutsideTaps,
    required ValueNotifier<bool> isClosed,
    required OverlayPopoverEntry popoverCompleter,
    OverlayBarrier? overlayBarrier,
    required bool modal,
  }) {
    return OverlayEntry(
      builder: (context) {
        Widget barrierWidget = Container(
          color: overlayBarrier?.barrierColor ?? Colors.transparent,
        );

        if (overlayBarrier != null) {
          barrierWidget = Container(
            padding: overlayBarrier.padding,
            decoration: BoxDecoration(
              color: overlayBarrier.barrierColor,
              borderRadius: overlayBarrier.borderRadius,
            ),
            child: barrierWidget,
          );
        }

        void onTap() {
          if (!barrierDismissable || isClosed.value) return;
          if (overlayBarrier?.onTap != null) {
            overlayBarrier!.onTap!();
          } else {
            isClosed.value = true;
            popoverCompleter.complete();
          }
        }

        // Animate the barrier with fade-in animation
        return AnimatedBuilder(
          animation: const AlwaysStoppedAnimation(1.0),
          builder: (context, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, opacity, child) {
                final barrierWithOpacity = Opacity(
                  opacity: opacity,
                  child: child,
                );

                // For modal=false, use IgnorePointer to allow scrolling behind the popover
                if (!modal) {
                  return IgnorePointer(
                    child: barrierWithOpacity,
                  );
                }

                return consumeOutsideTaps
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onTap,
                        child: barrierWithOpacity,
                      )
                    : Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: (event) {
                          onTap();
                        },
                        child: barrierWithOpacity,
                      );
              },
              child: barrierWidget,
            );
          },
        );
      },
    );
  }

  OverlayEntry _buildOverlayEntry<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Alignment alignment,
    required Offset position,
    required Size? anchorSize,
    required Alignment anchorAlignment,
    Key? key,
    required ValueNotifier<bool> isClosed,
    required PopoverConstraint widthConstraint,
    required PopoverConstraint heightConstraint,
    required Object? regionGroupId,
    required Offset? offset,
    required AlignmentGeometry? transitionAlignment,
    required EdgeInsetsGeometry margin,
    required bool follow,
    required bool consumeOutsideTaps,
    required ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
    required bool allowInvertHorizontal,
    required bool allowInvertVertical,
    required bool dismissBackdropFocus,
    required CapturedThemes? themes,
    required CapturedData? data,
    required OverlayPopoverEntry<T> popoverEntry,
    required LayerLink? layerLink,
    required Size? fixedSize,
    required bool modal,
    required PopoverAnimationConfig animationConfig,
    required bool autoFocus,
    required bool stayVisibleOnScroll,
    bool? alwaysFocus = false,
  }) {
    return OverlayEntry(
      builder: (innerContext) {
        return Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: isClosed,
              builder: (innerContext, child) {
                return FocusScope(
                  autofocus:
                      alwaysFocus! || (autoFocus && dismissBackdropFocus),
                  canRequestFocus:
                      alwaysFocus || (!isClosed.value && autoFocus),
                  child: PopoverOverlayWidget<T>(
                    animationConfig: animationConfig,
                    onTapOutside: modal
                        ? null
                        : () {
                            if (isClosed.value) {
                              return;
                            }
                            isClosed.value = true;
                            popoverEntry.complete();
                          },
                    onAnimationEnd: (isClosing) {
                      if (isClosing && isClosed.value) {
                        popoverEntry.remove();
                        popoverEntry.animationComplete();
                      }
                    },
                    isClosing: isClosed.value,
                    key: key,
                    anchorContext: context,
                    position: position,
                    alignment: alignment,
                    themes: themes,
                    builder: builder,
                    anchorSize: anchorSize,
                    anchorAlignment: anchorAlignment,
                    widthConstraint: widthConstraint,
                    heightConstraint: heightConstraint,
                    regionGroupId: regionGroupId,
                    offset: offset,
                    transitionAlignment: transitionAlignment,
                    margin: margin,
                    follow: follow,
                    consumeOutsideTaps: consumeOutsideTaps,
                    onTickFollow: onTickFollow,
                    allowInvertHorizontal: allowInvertHorizontal,
                    allowInvertVertical: allowInvertVertical,
                    data: data,
                    onClose: () {
                      if (isClosed.value) {
                        return Future.value();
                      }
                      isClosed.value = true;
                      popoverEntry.complete();
                      return popoverEntry.animationFuture;
                    },
                    onImmediateClose: () {
                      popoverEntry.remove();
                      popoverEntry.complete();
                      popoverEntry.animationComplete();
                    },
                    onCloseWithResult: (value) {
                      if (isClosed.value) {
                        return Future.value();
                      }
                      isClosed.value = true;
                      popoverEntry.complete(value);
                      return popoverEntry.animationFuture;
                    },
                    layerLink: layerLink,
                    fixedSize: fixedSize,
                    stayVisibleOnScroll: stayVisibleOnScroll,
                    modal: modal,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  _ResolvedPosition _resolvePosition({
    required BuildContext context,
    required Offset? initialPosition,
    required Alignment resolvedAnchorAlignment,
  }) {
    if (initialPosition != null) {
      return _ResolvedPosition(position: initialPosition, anchorSize: null);
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return _ResolvedPosition(
        position: Offset.zero,
        anchorSize: null,
      );
    }

    final RenderBox renderBox = renderObject;
    final Offset pos = renderBox.localToGlobal(Offset.zero);
    final Size anchorSize = renderBox.size;

    final position = Offset(
      pos.dx +
          anchorSize.width / 2 +
          anchorSize.width / 2 * resolvedAnchorAlignment.x,
      pos.dy +
          anchorSize.height / 2 +
          anchorSize.height / 2 * resolvedAnchorAlignment.y,
    );

    return _ResolvedPosition(position: position, anchorSize: anchorSize);
  }
}

/// Controller for managing multiple popovers
class PopoverController extends ChangeNotifier {
  bool _disposed = false;
  final List<Popover> _openPopovers = [];

  bool get hasOpenPopover =>
      _openPopovers.isNotEmpty &&
      _openPopovers.any((element) => !element.entry.isCompleted);

  bool get hasMountedPopover =>
      _openPopovers.isNotEmpty &&
      _openPopovers.any((element) => !element.entry.isAnimationCompleted);

  Iterable<Popover> get openPopovers => List.unmodifiable(_openPopovers);

  /// Shows a new popover with control through this controller
  Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required AlignmentGeometry alignment,
    AlignmentGeometry? anchorAlignment,
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,
    bool modal = false,
    bool closeOthers = true,
    Offset? offset,
    GlobalKey<OverlayHandlerStateMixin>? key,
    Object? regionGroupId,
    AlignmentGeometry? transitionAlignment,
    bool consumeOutsideTaps = true,
    EdgeInsetsGeometry? margin,
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
    bool follow = true,
    bool allowInvertHorizontal = true,
    bool allowInvertVertical = true,
    bool dismissBackdropFocus = true,
    Duration? showDuration,
    Duration? dismissDuration,
    OverlayBarrier? overlayBarrier,
    OverlayHandler? handler,
    Size? fixedSize,
    LayerLink? layerLink,
    Duration? resizeDuration,
    Curve? resizeCurve,
    Curve? showCurve,
    Curve? dismissCurve,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    Alignment? transformOrigin,
    PopoverAnimationConfig? animationConfig,
    bool stayVisibleOnScroll = true,
  }) async {
    if (closeOthers) {
      close();
    }

    key ??= GlobalKey<OverlayHandlerStateMixin>(
        debugLabel: 'PopoverAnchor$hashCode');

    // Create animation config if provided parameters
    PopoverAnimationConfig? effectiveAnimConfig;
    if (animationConfig == null &&
        (enterAnimations != null ||
            exitAnimations != null ||
            transformOrigin != null ||
            showDuration != null ||
            dismissDuration != null ||
            showCurve != null ||
            dismissCurve != null)) {
      effectiveAnimConfig = PopoverAnimationConfig(
        enterDuration: showDuration ?? const Duration(milliseconds: 300),
        exitDuration: dismissDuration ?? const Duration(milliseconds: 200),
        enterCurve: showCurve ?? Curves.easeOutCubic,
        exitCurve: dismissCurve ?? Curves.easeIn,
        resizeDuration: resizeDuration ?? const Duration(milliseconds: 250),
        resizeCurve: resizeCurve ?? Curves.easeInOutCubic,
        enterAnimations: enterAnimations ??
            [PopoverAnimationType.fadeIn, PopoverAnimationType.scale],
        exitAnimations: exitAnimations ??
            [PopoverAnimationType.fadeOut, PopoverAnimationType.scale],
        transformOrigin: transformOrigin ?? Alignment.center,
      );
    } else if (animationConfig != null) {
      effectiveAnimConfig = animationConfig;
    }

    final overlayCompleter = showPopover<T>(
      context: context,
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      builder: builder,
      modal: modal,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      key: key,
      regionGroupId: regionGroupId,
      offset: offset,
      transitionAlignment: transitionAlignment,
      consumeOutsideTaps: consumeOutsideTaps,
      margin: margin,
      onTickFollow: onTickFollow,
      follow: follow,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      dismissBackdropFocus: dismissBackdropFocus,
      showDuration: showDuration,
      dismissDuration: dismissDuration,
      overlayBarrier: overlayBarrier,
      handler: handler,
      fixedSize: fixedSize,
      layerLink: layerLink,
      resizeDuration: resizeDuration,
      resizeCurve: resizeCurve,
      showCurve: showCurve,
      dismissCurve: dismissCurve,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      animationConfig: effectiveAnimConfig,
      stayVisibleOnScroll: stayVisibleOnScroll,
    );

    final popover = Popover._(key, overlayCompleter);
    _openPopovers.add(popover);
    notifyListeners();

    T? result;
    try {
      result = await overlayCompleter.future;
    } finally {
      _openPopovers.remove(popover);
      if (!_disposed) {
        notifyListeners();
      }
    }

    return result;
  }

  /// Close all currently open popovers
  void close([bool immediate = false]) {
    for (final popover in List.from(_openPopovers)) {
      popover.close(immediate);
    }
    _openPopovers.clear();
    notifyListeners();
  }

  /// Schedule all popovers to close after current operation
  void closeLater() {
    for (final popover in List.from(_openPopovers)) {
      popover.closeLater();
    }
    _openPopovers.clear();
    notifyListeners();
  }

  // Property setters to control all open popovers
  set anchorContext(BuildContext value) {
    for (final popover in _openPopovers) {
      popover.currentState?.anchorContext = value;
    }
  }

  set alignment(AlignmentGeometry value) {
    for (final popover in _openPopovers) {
      popover.currentState?.alignment = value;
    }
  }

  set anchorAlignment(AlignmentGeometry value) {
    for (final popover in _openPopovers) {
      popover.currentState?.anchorAlignment = value;
    }
  }

  set widthConstraint(PopoverConstraint value) {
    for (final popover in _openPopovers) {
      popover.currentState?.widthConstraint = value;
    }
  }

  set heightConstraint(PopoverConstraint value) {
    for (final popover in _openPopovers) {
      popover.currentState?.heightConstraint = value;
    }
  }

  set margin(EdgeInsetsGeometry value) {
    for (final popover in _openPopovers) {
      if (popover.currentState != null) {
        popover.currentState!.margin = value;
      }
    }
  }

  set follow(bool value) {
    for (final popover in _openPopovers) {
      popover.currentState?.follow = value;
    }
  }

  set offset(Offset? value) {
    for (final popover in _openPopovers) {
      popover.currentState?.offset = value;
    }
  }

  set allowInvertHorizontal(bool value) {
    for (final popover in _openPopovers) {
      popover.currentState?.allowInvertHorizontal = value;
    }
  }

  set allowInvertVertical(bool value) {
    for (final popover in _openPopovers) {
      popover.currentState?.allowInvertVertical = value;
    }
  }

  /// Set enter animation for all open popovers
  void setEnterAnimation(
    List<PopoverAnimationType> types, {
    Duration? duration,
    Curve? curve,
  }) {
    for (final popover in _openPopovers) {
      if (popover.currentState is PopoverOverlayWidgetState) {
        (popover.currentState as PopoverOverlayWidgetState)
            .setEnterAnimation(types, duration: duration, curve: curve);
      }
    }
  }

  /// Set exit animation for all open popovers
  void setExitAnimation(
    List<PopoverAnimationType> types, {
    Duration? duration,
    Curve? curve,
  }) {
    for (final popover in _openPopovers) {
      if (popover.currentState is PopoverOverlayWidgetState) {
        (popover.currentState as PopoverOverlayWidgetState)
            .setExitAnimation(types, duration: duration, curve: curve);
      }
    }
  }

  /// Set transform origin for all open popovers
  void setTransformOrigin(Alignment origin) {
    for (final popover in _openPopovers) {
      if (popover.currentState is PopoverOverlayWidgetState) {
        (popover.currentState as PopoverOverlayWidgetState)
            .setTransformOrigin(origin);
      }
    }
  }

  // Update stayVisibleOnScroll for all popovers
  void updateStayVisibleOnScroll(bool value) {
    for (final popover in _openPopovers) {
      if (popover.currentState is PopoverOverlayWidgetState) {
        (popover.currentState as PopoverOverlayWidgetState)
            .stayVisibleOnScroll = value;
      }
    }
  }

  void disposePopovers() {
    for (final popover in List.from(_openPopovers)) {
      popover.closeLater();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    disposePopovers();
    super.dispose();
  }
}

/// Wrapper for reference to a displayed popover
class Popover {
  final GlobalKey<OverlayHandlerStateMixin> key;
  final OverlayCompleter entry;

  Popover._(this.key, this.entry);

  Future<void> close([bool immediate = false]) {
    final currentState = key.currentState;
    if (currentState != null) {
      return currentState.close(immediate);
    } else {
      entry.remove();
    }
    return Future.value();
  }

  void closeLater() {
    final currentState = key.currentState;
    if (currentState != null) {
      currentState.closeLater();
    } else {
      entry.remove();
    }
  }

  void remove() {
    entry.remove();
  }

  OverlayHandlerStateMixin? get currentState => key.currentState;
}

// --- Widgets ---

/// Main widget for displaying popover
class PopoverOverlayWidget<T> extends StatefulWidget {
  final Offset position;
  final AlignmentGeometry alignment;
  final AlignmentGeometry anchorAlignment;
  final CapturedThemes? themes;
  final CapturedData? data;
  final WidgetBuilder builder;
  final Size? anchorSize;
  final PopoverConstraint widthConstraint;
  final PopoverConstraint heightConstraint;
  final FutureVoidCallback? onClose;
  final VoidCallback? onImmediateClose;
  final VoidCallback? onTapOutside;
  final Object? regionGroupId;
  final Offset? offset;
  final AlignmentGeometry? transitionAlignment;
  final EdgeInsetsGeometry margin;
  final bool follow;
  final BuildContext anchorContext;
  final bool consumeOutsideTaps;
  final ValueChanged<PopoverOverlayWidgetState>? onTickFollow;
  final bool allowInvertHorizontal;
  final bool allowInvertVertical;
  final PopoverFutureVoidCallback<T>? onCloseWithResult;
  final LayerLink? layerLink;
  final Size? fixedSize;
  final Function(bool)? onAnimationEnd;
  final PopoverAnimationConfig animationConfig;
  final bool isClosing;
  final bool stayVisibleOnScroll;
  final bool modal;

  const PopoverOverlayWidget({
    super.key,
    required this.anchorContext,
    required this.position,
    required this.alignment,
    this.themes,
    required this.builder,
    required this.anchorAlignment,
    this.widthConstraint = PopoverConstraint.flexible,
    this.heightConstraint = PopoverConstraint.flexible,
    this.anchorSize,
    this.onTapOutside,
    this.regionGroupId,
    this.offset,
    this.transitionAlignment,
    required this.margin,
    this.follow = true,
    this.consumeOutsideTaps = true,
    this.onTickFollow,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
    this.data,
    this.onClose,
    this.onImmediateClose,
    this.onCloseWithResult,
    this.layerLink,
    this.fixedSize,
    this.onAnimationEnd,
    required this.animationConfig,
    this.isClosing = false,
    this.stayVisibleOnScroll = true,
    this.modal = false,
  });

  @override
  State<PopoverOverlayWidget> createState() => PopoverOverlayWidgetState();
}

class PopoverOverlayWidgetState extends State<PopoverOverlayWidget>
    with TickerProviderStateMixin, OverlayHandlerStateMixin {
  late BuildContext _anchorContext;
  late Offset _position;
  late Offset? _offset;
  late AlignmentGeometry _alignment;
  late AlignmentGeometry _anchorAlignment;
  late PopoverConstraint _widthConstraint;
  late PopoverConstraint _heightConstraint;
  late EdgeInsetsGeometry _margin;
  Size? _anchorSize;
  Size? _fixedSize;
  late bool _follow;
  late bool _allowInvertHorizontal;
  late bool _allowInvertVertical;
  Ticker? _ticker;
  late LayerLink? _layerLink;
  late bool _stayVisibleOnScroll;
  late bool _modal;

  // Animation configuration
  late PopoverAnimationConfig _animationConfig;

  // Property animations
  late AnimationController _controller;

  // Animation values
  late Animation<double> _scaleAnimation;
  late Animation<double> _scaleXAnimation;
  late Animation<double> _scaleYAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _skewXAnimation;
  late Animation<double> _skewYAnimation;
  late Animation<Offset> _keyboardOffsetAnimation;

  // Animation flags
  late List<PopoverAnimationType> _enterAnimations;
  late List<PopoverAnimationType> _exitAnimations;
  late Alignment _transformOrigin;

  // Flag to mark that enter animation is running
  bool _isEntering = false;

  // Using configured update throttler
  late _UpdateThrottler _positionUpdateThrottle;

  MediaQueryData? _lastMediaQuery;

  // Track if dispose has been called
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeProperties();
    _setupAnimationController();
    _setupAnimations();
    _setupTicker();

    _startEnterAnimation();
  }

  void _initializeProperties() {
    _offset = widget.offset;
    _position = widget.position;
    _alignment = widget.alignment;
    _anchorSize = widget.anchorSize;
    _anchorAlignment = widget.anchorAlignment;
    _widthConstraint = widget.widthConstraint;
    _heightConstraint = widget.heightConstraint;
    _margin = widget.margin;
    _follow = widget.follow;
    _anchorContext = widget.anchorContext;
    _allowInvertHorizontal = widget.allowInvertHorizontal;
    _allowInvertVertical = widget.allowInvertVertical;
    _layerLink = widget.layerLink;
    _fixedSize = widget.fixedSize;
    _stayVisibleOnScroll = widget.stayVisibleOnScroll;
    _modal = widget.modal;
    _animationConfig = widget.animationConfig;
    _enterAnimations = widget.animationConfig.enterAnimations;
    _exitAnimations = widget.animationConfig.exitAnimations;
    _transformOrigin = widget.animationConfig.transformOrigin;

    _positionUpdateThrottle =
        _UpdateThrottler(widget.animationConfig.minFollowInterval);
  }

  void _setupAnimationController() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationConfig.enterDuration,
      reverseDuration: _animationConfig.exitDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && widget.isClosing) {
        widget.onAnimationEnd?.call(true);
      } else if (status == AnimationStatus.completed && !widget.isClosing) {
        _isEntering = false;
      }
    });
  }

  void _setupAnimations() {
    // Create curved animations for forward (enter) and reverse (exit)
    final forwardCurve = CurvedAnimation(
      parent: _controller,
      curve: _animationConfig.enterCurve,
    );

    // Initialize scale animation
    final useScale = _enterAnimations.contains(PopoverAnimationType.scale) ||
        _exitAnimations.contains(PopoverAnimationType.scale);
    _scaleAnimation = Tween<double>(
      begin: useScale ? _animationConfig.initialScale : 1.0,
      end: 1.0,
    ).animate(forwardCurve);

    // Initialize scale X & Y animations
    final useScaleX = _enterAnimations.contains(PopoverAnimationType.scaleX) ||
        _exitAnimations.contains(PopoverAnimationType.scaleX);
    _scaleXAnimation = Tween<double>(
      begin: useScaleX ? _animationConfig.initialScale : 1.0,
      end: 1.0,
    ).animate(forwardCurve);

    final useScaleY = _enterAnimations.contains(PopoverAnimationType.scaleY) ||
        _exitAnimations.contains(PopoverAnimationType.scaleY);
    _scaleYAnimation = Tween<double>(
      begin: useScaleY ? _animationConfig.initialScale : 1.0,
      end: 1.0,
    ).animate(forwardCurve);

    // Initialize opacity animation
    final useFadeIn = _enterAnimations.contains(PopoverAnimationType.fadeIn);
    final useFadeOut = _exitAnimations.contains(PopoverAnimationType.fadeOut);
    _opacityAnimation = Tween<double>(
      begin: useFadeIn || useFadeOut ? 0.0 : 1.0,
      end: 1.0,
    ).animate(forwardCurve);

    // Initialize slide animation
    Offset slideOffset = Offset.zero;

    // Determine slide direction based on animations
    if (_enterAnimations.contains(PopoverAnimationType.slideUp)) {
      slideOffset = const Offset(0, 20);
    } else if (_enterAnimations.contains(PopoverAnimationType.slideDown)) {
      slideOffset = const Offset(0, -20);
    } else if (_enterAnimations.contains(PopoverAnimationType.slideLeft)) {
      slideOffset = const Offset(20, 0);
    } else if (_enterAnimations.contains(PopoverAnimationType.slideRight)) {
      slideOffset = const Offset(-20, 0);
    }

    _slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(forwardCurve);

    // Initialize rotate animation
    final useRotate = _enterAnimations.contains(PopoverAnimationType.rotate) ||
        _exitAnimations.contains(PopoverAnimationType.rotate);
    _rotateAnimation = Tween<double>(
      begin: useRotate ? _animationConfig.rotateBegin : 0.0,
      end: _animationConfig.rotateEnd,
    ).animate(forwardCurve);

    // Initialize skew animations
    final useSkewX = _enterAnimations.contains(PopoverAnimationType.skewX) ||
        _exitAnimations.contains(PopoverAnimationType.skewX);
    _skewXAnimation = Tween<double>(
      begin: useSkewX ? _animationConfig.skewXBegin : 0.0,
      end: _animationConfig.skewXEnd,
    ).animate(forwardCurve);

    final useSkewY = _enterAnimations.contains(PopoverAnimationType.skewY) ||
        _exitAnimations.contains(PopoverAnimationType.skewY);
    _skewYAnimation = Tween<double>(
      begin: useSkewY ? _animationConfig.skewYBegin : 0.0,
      end: _animationConfig.skewYEnd,
    ).animate(forwardCurve);

    // Initialize keyboard offset animation
    _keyboardOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _animationConfig.keyboardTransitionCurve,
      ),
    );
  }

  // Always setup ticker if follow is active
  void _setupTicker() {
    if (!_follow || widget.layerLink != null) return;

    _positionUpdateThrottle =
        _UpdateThrottler(widget.animationConfig.minFollowInterval);

    _ticker ??= createTicker(_tick);
    if (!(_ticker?.isActive ?? false)) {
      _ticker!.start();
    }
  }

  void _startEnterAnimation() {
    _isEntering = true;
    _controller.forward(from: 0.0);
  }

  void _startExitAnimation() {
    // If animation was interrupted during enter, capture current values
    if (_isEntering) {
      _isEntering = false;
    }

    _controller.reverse(from: _controller.value);
  }

  @override
  Future<void> close([bool immediate = false]) {
    if (immediate) {
      widget.onImmediateClose?.call();
      return Future.value();
    }
    return widget.onClose?.call() ?? Future.value();
  }

  @override
  void closeLater() {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onClose?.call();
        }
      });
    }
  }

  /// Set enter animation type
  void setEnterAnimation(
    List<PopoverAnimationType> types, {
    Duration? duration,
    Curve? curve,
  }) {
    if (!mounted) return;

    setState(() {
      _enterAnimations = types;

      if (duration != null) {
        _animationConfig = _animationConfig.copyWith(enterDuration: duration);
        _controller.duration = duration;
      }

      if (curve != null) {
        _animationConfig = _animationConfig.copyWith(enterCurve: curve);
      }

      // Re-setup animations with new values
      _setupAnimations();
    });
  }

  /// Set exit animation type
  void setExitAnimation(
    List<PopoverAnimationType> types, {
    Duration? duration,
    Curve? curve,
  }) {
    if (!mounted) return;

    setState(() {
      _exitAnimations = types;

      if (duration != null) {
        _animationConfig = _animationConfig.copyWith(exitDuration: duration);
        _controller.reverseDuration = duration;
      }

      if (curve != null) {
        _animationConfig = _animationConfig.copyWith(exitCurve: curve);
      }

      // Re-setup animations with new values
      _setupAnimations();
    });
  }

  /// Set transform origin for scale and rotate animations
  void setTransformOrigin(Alignment origin) {
    if (!mounted) return;

    setState(() {
      _transformOrigin = origin;
      _animationConfig = _animationConfig.copyWith(transformOrigin: origin);
    });
  }

  @override
  void didUpdateWidget(covariant PopoverOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation durations if they changed
    if (oldWidget.animationConfig.enterDuration !=
        widget.animationConfig.enterDuration) {
      _controller.duration = widget.animationConfig.enterDuration;
      _animationConfig = _animationConfig.copyWith(
          enterDuration: widget.animationConfig.enterDuration);
    }

    if (oldWidget.animationConfig.exitDuration !=
        widget.animationConfig.exitDuration) {
      _controller.reverseDuration = widget.animationConfig.exitDuration;
      _animationConfig = _animationConfig.copyWith(
          exitDuration: widget.animationConfig.exitDuration);
    }

    _updatePropertiesIfChanged(oldWidget);
    _updateTickerIfNeeded(oldWidget);

    // Handle exit animation when isClosing changes
    if (!oldWidget.isClosing && widget.isClosing) {
      _startExitAnimation();
    }

    // Update stayVisibleOnScroll if it changed
    if (oldWidget.stayVisibleOnScroll != widget.stayVisibleOnScroll) {
      _stayVisibleOnScroll = widget.stayVisibleOnScroll;
    }

    // Update modal flag if it changed
    if (oldWidget.modal != widget.modal) {
      _modal = widget.modal;
    }

    // Check if animation configuration has changed
    final animConfigChanged = oldWidget.animationConfig.enterAnimations !=
            widget.animationConfig.enterAnimations ||
        oldWidget.animationConfig.exitAnimations !=
            widget.animationConfig.exitAnimations ||
        oldWidget.animationConfig.transformOrigin !=
            widget.animationConfig.transformOrigin ||
        oldWidget.animationConfig.enterCurve !=
            widget.animationConfig.enterCurve ||
        oldWidget.animationConfig.exitCurve !=
            widget.animationConfig.exitCurve ||
        oldWidget.animationConfig.initialScale !=
            widget.animationConfig.initialScale ||
        oldWidget.animationConfig.slideBegin !=
            widget.animationConfig.slideBegin ||
        oldWidget.animationConfig.slideEnd != widget.animationConfig.slideEnd ||
        oldWidget.animationConfig.rotateBegin !=
            widget.animationConfig.rotateBegin ||
        oldWidget.animationConfig.rotateEnd !=
            widget.animationConfig.rotateEnd ||
        oldWidget.animationConfig.skewXBegin !=
            widget.animationConfig.skewXBegin ||
        oldWidget.animationConfig.skewXEnd != widget.animationConfig.skewXEnd ||
        oldWidget.animationConfig.skewYBegin !=
            widget.animationConfig.skewYBegin ||
        oldWidget.animationConfig.skewYEnd != widget.animationConfig.skewYEnd;

    if (animConfigChanged) {
      _animationConfig = widget.animationConfig;
      _enterAnimations = widget.animationConfig.enterAnimations;
      _exitAnimations = widget.animationConfig.exitAnimations;
      _transformOrigin = widget.animationConfig.transformOrigin;
      _setupAnimations();
    }
  }

  void _updatePropertiesIfChanged(PopoverOverlayWidget oldWidget) {
    if (oldWidget.alignment != widget.alignment) {
      setState(() => _alignment = widget.alignment);
    }

    if (oldWidget.anchorSize != widget.anchorSize) {
      setState(() => _anchorSize = widget.anchorSize);
    }

    if (oldWidget.anchorAlignment != widget.anchorAlignment) {
      setState(() => _anchorAlignment = widget.anchorAlignment);
    }

    if (oldWidget.widthConstraint != widget.widthConstraint) {
      setState(() => _widthConstraint = widget.widthConstraint);
    }

    if (oldWidget.heightConstraint != widget.heightConstraint) {
      setState(() => _heightConstraint = widget.heightConstraint);
    }

    if (oldWidget.offset != widget.offset) {
      setState(() => _offset = widget.offset);
    }

    if (oldWidget.fixedSize != widget.fixedSize) {
      setState(() => _fixedSize = widget.fixedSize);
    }

    if (oldWidget.margin != widget.margin) {
      setState(() => _margin = widget.margin);
    }

    if (oldWidget.follow != widget.follow) {
      setState(() => _follow = widget.follow);
    }

    if (oldWidget.anchorContext != widget.anchorContext) {
      setState(() => _anchorContext = widget.anchorContext);
    }

    if (oldWidget.allowInvertHorizontal != widget.allowInvertHorizontal) {
      setState(() => _allowInvertHorizontal = widget.allowInvertHorizontal);
    }

    if (oldWidget.allowInvertVertical != widget.allowInvertVertical) {
      setState(() => _allowInvertVertical = widget.allowInvertVertical);
    }

    if (oldWidget.position != widget.position) {
      setState(() => _position = widget.position);
    }

    if (oldWidget.animationConfig.minFollowInterval !=
        widget.animationConfig.minFollowInterval) {
      _positionUpdateThrottle =
          _UpdateThrottler(widget.animationConfig.minFollowInterval);

      if (_ticker?.isActive ?? false) {
        _ticker?.stop();
        _ticker?.start();
      }
    }
  }

  void _updateTickerIfNeeded(PopoverOverlayWidget oldWidget) {
    bool shouldUseFollowTicker = widget.follow && widget.layerLink == null;
    bool wasUsingFollowTicker = oldWidget.follow && oldWidget.layerLink == null;

    if (shouldUseFollowTicker != wasUsingFollowTicker) {
      if (shouldUseFollowTicker) {
        _ticker ??= createTicker(_tick);
        if (!(_ticker?.isActive ?? false)) {
          _ticker!.start();
        }
      } else {
        if (_ticker?.isActive ?? false) {
          _ticker!.stop();
        }
      }
    }

    if (oldWidget.layerLink != widget.layerLink) {
      setState(() {
        _layerLink = widget.layerLink;
      });
    }
  }

  // Getters and setters
  Size? get anchorSize => _anchorSize;
  AlignmentGeometry get anchorAlignment => _anchorAlignment;
  Offset get position => _position;
  AlignmentGeometry get alignment => _alignment;
  PopoverConstraint get widthConstraint => _widthConstraint;
  PopoverConstraint get heightConstraint => _heightConstraint;
  Offset? get offset => _offset;
  EdgeInsetsGeometry get margin => _margin;
  bool get follow => _follow;
  BuildContext get anchorContext => _anchorContext;
  bool get allowInvertHorizontal => _allowInvertHorizontal;
  bool get allowInvertVertical => _allowInvertVertical;
  LayerLink? get layerLink => _layerLink;
  Size? get fixedSize => _fixedSize;
  bool get stayVisibleOnScroll => _stayVisibleOnScroll;
  bool get modal => _modal;

  set fixedSize(Size? value) {
    if (_fixedSize != value) {
      setState(() => _fixedSize = value);
    }
  }

  set layerLink(LayerLink? value) {
    if (_layerLink != value) {
      setState(() {
        _layerLink = value;
      });
    }
  }

  @override
  set alignment(AlignmentGeometry value) {
    if (_alignment != value) {
      setState(() => _alignment = value);
    }
  }

  set position(Offset value) {
    if (_position != value) {
      setState(() => _position = value);
    }
  }

  @override
  set anchorAlignment(AlignmentGeometry value) {
    if (_anchorAlignment != value) {
      setState(() => _anchorAlignment = value);
    }
  }

  @override
  set widthConstraint(PopoverConstraint value) {
    if (_widthConstraint != value) {
      setState(() => _widthConstraint = value);
    }
  }

  @override
  set heightConstraint(PopoverConstraint value) {
    if (_heightConstraint != value) {
      setState(() => _heightConstraint = value);
    }
  }

  @override
  set margin(EdgeInsetsGeometry value) {
    if (_margin != value) {
      setState(() => _margin = value);
    }
  }

  @override
  set follow(bool value) {
    if (_follow != value) {
      setState(() {
        _follow = value;
        if (_follow) {
          _setupTicker();
        } else if (_ticker?.isActive ?? false) {
          _ticker?.stop();
        }
      });
    }
  }

  @override
  set anchorContext(BuildContext value) {
    if (_anchorContext != value) {
      setState(() => _anchorContext = value);
    }
  }

  @override
  set allowInvertHorizontal(bool value) {
    if (_allowInvertHorizontal != value) {
      setState(() => _allowInvertHorizontal = value);
    }
  }

  @override
  set allowInvertVertical(bool value) {
    if (_allowInvertVertical != value) {
      setState(() => _allowInvertVertical = value);
    }
  }

  @override
  set offset(Offset? value) {
    if (_offset != value) {
      setState(() {
        _offset = value;
      });
    }
  }

  set stayVisibleOnScroll(bool value) {
    if (_stayVisibleOnScroll != value) {
      setState(() {
        _stayVisibleOnScroll = value;
      });
    }
  }

  set modal(bool value) {
    if (_modal != value) {
      setState(() {
        _modal = value;
      });
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    if (_ticker != null) {
      _ticker!.dispose();
      _ticker = null;
    }

    _controller.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (widget.layerLink != null) {
      return;
    }

    if (!mounted || !_anchorContext.mounted) {
      _ticker?.stop();
      if (!_isDisposed) {
        widget.onImmediateClose?.call();
        widget.onClose?.call();
      }
      widget.onImmediateClose?.call();
      return;
    }

    if (!_follow) {
      _ticker?.stop();
      return;
    }

    if (!_positionUpdateThrottle.shouldUpdate()) {
      return;
    }

    final renderObject = _anchorContext.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _updatePositionFromAnchor(renderObject);
    } else {
      _ticker?.stop();
      widget.onImmediateClose?.call();
      if (!_stayVisibleOnScroll) {
        _handleAnchorDisappeared();
      }
    }
  }

  void _updatePositionFromAnchor(RenderBox renderBox) {
    if (!mounted) return;

    final Offset pos = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Get the current media query data
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool mediaQueryChanged = _lastMediaQuery == null ||
        _lastMediaQuery!.viewInsets != mediaQuery.viewInsets;

    _lastMediaQuery = mediaQuery;

    final anchorAlignment = _anchorAlignment.optionallyResolve(context);
    final Offset newPos = Offset(
      pos.dx + size.width / 2 + size.width / 2 * anchorAlignment.x,
      pos.dy + size.height / 2 + size.height / 2 * anchorAlignment.y,
    );

    if (_position != newPos || _anchorSize != size || mediaQueryChanged) {
      setState(() {
        _anchorSize = size;

        final targetPosition = newPos;

        _position = targetPosition;
        widget.onTickFollow?.call(this);
      });
    }
  }

  void _handleAnchorDisappeared() {
    if (_ticker?.isActive ?? false) {
      _ticker?.stop();
    }

    // Only close if stayVisibleOnScroll is false
    if (!_stayVisibleOnScroll) {
      widget.onImmediateClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Data<OverlayHandlerStateMixin>.inherit(
      data: this,
      child: _buildTapRegion(
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          removeTop: true,
          child: _buildPositionedContent(),
        ),
      ),
    );

    if (widget.themes != null) {
      childWidget = widget.themes!.wrap(childWidget);
    }
    if (widget.data != null) {
      childWidget = widget.data!.wrap(childWidget);
    }

    return childWidget;
  }

  Widget _buildTapRegion({required Widget child}) {
    if (!widget.stayVisibleOnScroll) {
      return Stack(
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) {
                if (mounted) widget.onImmediateClose?.call();
              },
            ),
          ),
          child,
        ],
      );
    }
    // Mode biasa
    if (widget.onTapOutside != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onTapOutside,
              child: Container(),
            ),
          ),
          child,
        ],
      );
    }
    return child;
  }

  Widget _buildPositionedContent() {
    if (_layerLink != null) {
      return Builder(
        builder: (context) {
          final calculatedOffset = _calculateLayerLinkOffset();
          return CompositedTransformFollower(
            link: _layerLink!,
            showWhenUnlinked: false,
            offset: calculatedOffset,
            child: _buildPopoverContent(),
          );
        },
      );
    } else {
      return _buildPopoverContent();
    }
  }

  Offset _calculateLayerLinkOffset() {
    final baseOffset = _offset ?? Offset.zero;
    final alignment = _alignment.optionallyResolve(context);
    final anchorAlignment = _anchorAlignment.optionallyResolve(context);

    double offsetX = baseOffset.dx;
    double offsetY = baseOffset.dy;

    if (_anchorSize != null) {
      offsetX += (alignment.x - anchorAlignment.x) * _anchorSize!.width / 2;
      offsetY += (alignment.y - anchorAlignment.y) * _anchorSize!.height / 2;
    }

    return Offset(offsetX, offsetY);
  }

  Widget _buildPopoverContent() {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final effectiveTransitionAlignment =
              (widget.transitionAlignment ?? _alignment)
                  .optionallyResolve(context);

          final effectiveMargin = _margin is EdgeInsets
              ? _margin as EdgeInsets
              : _margin.resolve(Directionality.of(context));

          // Use AnimatedSize for smooth resize animations
          Widget content = AnimatedSize(
            duration: _animationConfig.resizeDuration,
            curve: _animationConfig.resizeCurve,
            alignment: effectiveTransitionAlignment,
            child: PopoverLayout(
              alignment: _alignment.optionallyResolve(context),
              position: _position,
              anchorSize: _anchorSize,
              anchorAlignment: _anchorAlignment.optionallyResolve(context),
              widthConstraint: _widthConstraint,
              heightConstraint: _heightConstraint,
              offset: _offset,
              margin: effectiveMargin,
              allowInvertVertical: _allowInvertVertical,
              allowInvertHorizontal: _allowInvertHorizontal,
              filterQuality: null,
              fixedSize: _fixedSize,
              horizontalInversionThreshold:
                  _animationConfig.horizontalInversionThreshold,
              verticalInversionThreshold:
                  _animationConfig.verticalInversionThreshold,
              child: Builder(builder: widget.builder),
            ),
          );

          // Apply animations based on configured types
          // Start with keyboard offset
          if (_keyboardOffsetAnimation.value != Offset.zero) {
            content = Transform.translate(
              offset: _keyboardOffsetAnimation.value,
              child: content,
            );
          }

          // Apply slide effects for different directions
          if (_enterAnimations.contains(PopoverAnimationType.slideUp) ||
              _enterAnimations.contains(PopoverAnimationType.slideDown) ||
              _enterAnimations.contains(PopoverAnimationType.slideLeft) ||
              _enterAnimations.contains(PopoverAnimationType.slideRight) ||
              _exitAnimations.contains(PopoverAnimationType.slideUp) ||
              _exitAnimations.contains(PopoverAnimationType.slideDown) ||
              _exitAnimations.contains(PopoverAnimationType.slideLeft) ||
              _exitAnimations.contains(PopoverAnimationType.slideRight)) {
            content = Transform.translate(
              offset: _slideAnimation.value,
              child: content,
            );
          }

          // Apply scale effect
          if (_enterAnimations.contains(PopoverAnimationType.scale) ||
              _exitAnimations.contains(PopoverAnimationType.scale)) {
            content = Transform.scale(
              scale: _scaleAnimation.value,
              alignment: _transformOrigin,
              child: content,
            );
          }
          // Apply scaleX and scaleY effects
          else if (_enterAnimations.contains(PopoverAnimationType.scaleX) ||
              _enterAnimations.contains(PopoverAnimationType.scaleY) ||
              _exitAnimations.contains(PopoverAnimationType.scaleX) ||
              _exitAnimations.contains(PopoverAnimationType.scaleY)) {
            content = Transform(
              transform: Matrix4.diagonal3Values(
                _enterAnimations.contains(PopoverAnimationType.scaleX) ||
                        _exitAnimations.contains(PopoverAnimationType.scaleX)
                    ? _scaleXAnimation.value
                    : 1.0,
                _enterAnimations.contains(PopoverAnimationType.scaleY) ||
                        _exitAnimations.contains(PopoverAnimationType.scaleY)
                    ? _scaleYAnimation.value
                    : 1.0,
                1.0,
              ),
              alignment: _transformOrigin,
              child: content,
            );
          }

          // Apply rotation effect
          if (_enterAnimations.contains(PopoverAnimationType.rotate) ||
              _exitAnimations.contains(PopoverAnimationType.rotate)) {
            content = Transform.rotate(
              angle: _rotateAnimation.value,
              alignment: _transformOrigin,
              child: content,
            );
          }

          // Apply skew effects
          if (_enterAnimations.contains(PopoverAnimationType.skewX) ||
              _enterAnimations.contains(PopoverAnimationType.skewY) ||
              _exitAnimations.contains(PopoverAnimationType.skewX) ||
              _exitAnimations.contains(PopoverAnimationType.skewY)) {
            final Matrix4 skewMatrix = Matrix4.identity();

            if (_enterAnimations.contains(PopoverAnimationType.skewX) ||
                _exitAnimations.contains(PopoverAnimationType.skewX)) {
              skewMatrix.setEntry(1, 0, _skewXAnimation.value);
            }

            if (_enterAnimations.contains(PopoverAnimationType.skewY) ||
                _exitAnimations.contains(PopoverAnimationType.skewY)) {
              skewMatrix.setEntry(0, 1, _skewYAnimation.value);
            }

            content = Transform(
              transform: skewMatrix,
              alignment: _transformOrigin,
              child: content,
            );
          }

          // Apply fade effect - applied last so it doesn't affect other transforms
          if (_enterAnimations.contains(PopoverAnimationType.fadeIn) ||
              _exitAnimations.contains(PopoverAnimationType.fadeOut)) {
            content = Opacity(
              opacity: _opacityAnimation.value,
              child: content,
            );
          }

          return content;
        });
  }

  @override
  Future<void> closeWithResult<X>([X? value]) {
    if (widget.onCloseWithResult != null) {
      try {
        return widget.onCloseWithResult!(value as dynamic);
      } catch (e) {
        debugPrint('Error closing overlay with result: $e');
      }
    }
    return Future.value();
  }
}

/// Widget to calculate and position popover correctly
class PopoverLayout extends SingleChildRenderObjectWidget {
  final Alignment alignment;
  final Alignment anchorAlignment;
  final Offset position;
  final Size? anchorSize;
  final PopoverConstraint widthConstraint;
  final PopoverConstraint heightConstraint;
  final Offset? offset;
  final EdgeInsets margin;
  final FilterQuality? filterQuality;
  final bool allowInvertHorizontal;
  final bool allowInvertVertical;
  final Size? fixedSize;
  final double horizontalInversionThreshold;
  final double verticalInversionThreshold;

  const PopoverLayout({
    super.key,
    required this.alignment,
    required this.position,
    required this.anchorAlignment,
    required this.widthConstraint,
    required this.heightConstraint,
    this.anchorSize,
    this.offset,
    required this.margin,
    required Widget child,
    this.filterQuality,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
    this.fixedSize,
    this.horizontalInversionThreshold = 12.0,
    this.verticalInversionThreshold = 12.0,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverLayoutRender(
      alignment: alignment,
      position: position,
      anchorAlignment: anchorAlignment,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      anchorSize: anchorSize,
      offset: offset,
      margin: margin,
      filterQuality: filterQuality,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      fixedSize: fixedSize,
      horizontalInversionThreshold: horizontalInversionThreshold,
      verticalInversionThreshold: verticalInversionThreshold,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, PopoverLayoutRender renderObject) {
    renderObject
      ..alignment = alignment
      ..position = position
      ..anchorAlignment = anchorAlignment
      ..widthConstraint = widthConstraint
      ..heightConstraint = heightConstraint
      ..anchorSize = anchorSize
      ..offset = offset
      ..margin = margin
      ..filterQuality = filterQuality
      ..allowInvertHorizontal = allowInvertHorizontal
      ..allowInvertVertical = allowInvertVertical
      ..fixedSize = fixedSize
      ..horizontalInversionThreshold = horizontalInversionThreshold
      ..verticalInversionThreshold = verticalInversionThreshold;
  }
}

/// Custom render object for popover layout
class PopoverLayoutRender extends RenderShiftedBox {
  Alignment _alignment;
  Alignment _anchorAlignment;
  Offset _position;
  Size? _anchorSize;
  PopoverConstraint _widthConstraint;
  PopoverConstraint _heightConstraint;
  Offset? _offset;
  EdgeInsets _margin;
  FilterQuality? _filterQuality;
  bool _allowInvertHorizontal;
  bool _allowInvertVertical;
  Size? _fixedSize;
  double _horizontalInversionThreshold;
  double _verticalInversionThreshold;

  PopoverLayoutRender({
    RenderBox? child,
    required Alignment alignment,
    required Offset position,
    required Alignment anchorAlignment,
    required PopoverConstraint widthConstraint,
    required PopoverConstraint heightConstraint,
    Size? anchorSize,
    Offset? offset,
    required EdgeInsets margin,
    FilterQuality? filterQuality,
    bool allowInvertHorizontal = true,
    bool allowInvertVertical = true,
    Size? fixedSize,
    double horizontalInversionThreshold = 12.0,
    double verticalInversionThreshold = 12.0,
  })  : _alignment = alignment,
        _position = position,
        _anchorAlignment = anchorAlignment,
        _widthConstraint = widthConstraint,
        _heightConstraint = heightConstraint,
        _anchorSize = anchorSize,
        _offset = offset,
        _margin = margin,
        _filterQuality = filterQuality,
        _allowInvertHorizontal = allowInvertHorizontal,
        _allowInvertVertical = allowInvertVertical,
        _fixedSize = fixedSize,
        _horizontalInversionThreshold = horizontalInversionThreshold,
        _verticalInversionThreshold = verticalInversionThreshold,
        super(child);

  // Getters and setters
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  Offset get position => _position;
  set position(Offset value) {
    if (_position == value) return;
    _position = value;
    markNeedsLayout();
  }

  Alignment get anchorAlignment => _anchorAlignment;
  set anchorAlignment(Alignment value) {
    if (_anchorAlignment == value) return;
    _anchorAlignment = value;
    markNeedsLayout();
  }

  PopoverConstraint get widthConstraint => _widthConstraint;
  set widthConstraint(PopoverConstraint value) {
    if (_widthConstraint == value) return;
    _widthConstraint = value;
    markNeedsLayout();
  }

  PopoverConstraint get heightConstraint => _heightConstraint;
  set heightConstraint(PopoverConstraint value) {
    if (_heightConstraint == value) return;
    _heightConstraint = value;
    markNeedsLayout();
  }

  Size? get anchorSize => _anchorSize;
  set anchorSize(Size? value) {
    if (_anchorSize == value) return;
    _anchorSize = value;
    markNeedsLayout();
  }

  Offset? get offset => _offset;
  set offset(Offset? value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsLayout();
  }

  EdgeInsets get margin => _margin;
  set margin(EdgeInsets value) {
    if (_margin == value) return;
    _margin = value;
    markNeedsLayout();
  }

  FilterQuality? get filterQuality => _filterQuality;
  set filterQuality(FilterQuality? value) {
    if (_filterQuality == value) return;
    _filterQuality = value;
    markNeedsPaint();
  }

  bool get allowInvertHorizontal => _allowInvertHorizontal;
  set allowInvertHorizontal(bool value) {
    if (_allowInvertHorizontal == value) return;
    _allowInvertHorizontal = value;
    markNeedsLayout();
  }

  bool get allowInvertVertical => _allowInvertVertical;
  set allowInvertVertical(bool value) {
    if (_allowInvertVertical == value) return;
    _allowInvertVertical = value;
    markNeedsLayout();
  }

  Size? get fixedSize => _fixedSize;
  set fixedSize(Size? value) {
    if (_fixedSize == value) return;
    _fixedSize = value;
    markNeedsLayout();
  }

  double get horizontalInversionThreshold => _horizontalInversionThreshold;
  set horizontalInversionThreshold(double value) {
    if (_horizontalInversionThreshold == value) return;
    _horizontalInversionThreshold = value;
    markNeedsLayout();
  }

  double get verticalInversionThreshold => _verticalInversionThreshold;
  set verticalInversionThreshold(double value) {
    if (_verticalInversionThreshold == value) return;
    _verticalInversionThreshold = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final BoxParentData childParentData = child!.parentData as BoxParentData;

    final adjustedPosition = position - childParentData.offset;

    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: adjustedPosition);
      },
    );
  }

  BoxConstraints _computeConstraints(BoxConstraints constraints) {
    double minWidth = 0;
    double maxWidth = constraints.maxWidth;
    double minHeight = 0;
    double maxHeight = constraints.maxHeight;

    // Handle width constraints
    switch (_widthConstraint) {
      case PopoverConstraint.fixed:
        assert(_fixedSize != null,
            'fixedSize must not be null when using PopoverConstraint.fixed');
        if (_fixedSize != null) {
          minWidth = maxWidth = _fixedSize!.width;
        }
        break;
      case PopoverConstraint.fullScreen:
        minWidth = maxWidth = constraints.maxWidth;
        break;
      case PopoverConstraint.contentSize:
        if (child != null) {
          final double intrinsicWidth =
              child!.getMaxIntrinsicWidth(double.infinity);
          if (intrinsicWidth.isFinite) {
            minWidth =
                maxWidth = intrinsicWidth.clamp(0.0, constraints.maxWidth);
          }
        }
        break;
      case PopoverConstraint.anchorFixedSize:
        if (_anchorSize != null) {
          minWidth = maxWidth = _anchorSize!.width;
        }
        break;
      case PopoverConstraint.anchorMinSize:
        if (_anchorSize != null) {
          minWidth = _anchorSize!.width;
        }
        break;
      case PopoverConstraint.anchorMaxSize:
        if (_anchorSize != null) {
          maxWidth = _anchorSize!.width;
        }
        break;
      case PopoverConstraint.intrinsic:
        if (child != null) {
          final double intrinsicWidth =
              child!.getMaxIntrinsicWidth(double.infinity);
          if (intrinsicWidth.isFinite) {
            maxWidth = min(maxWidth, intrinsicWidth);
          }
        }
        break;
      case PopoverConstraint.flexible:
        // Use default constraints
        break;
    }

    // Handle height constraints
    switch (_heightConstraint) {
      case PopoverConstraint.fixed:
        assert(_fixedSize != null,
            'fixedSize must not be null when using PopoverConstraint.fixed');
        if (_fixedSize != null) {
          minHeight = maxHeight = _fixedSize!.height;
        }
        break;
      case PopoverConstraint.fullScreen:
        minHeight = maxHeight = constraints.maxHeight;
        break;
      case PopoverConstraint.contentSize:
        if (child != null) {
          final double intrinsicHeight =
              child!.getMaxIntrinsicHeight(double.infinity);
          if (intrinsicHeight.isFinite) {
            minHeight =
                maxHeight = intrinsicHeight.clamp(0.0, constraints.maxHeight);
          }
        }
        break;
      case PopoverConstraint.anchorFixedSize:
        if (_anchorSize != null) {
          minHeight = maxHeight = _anchorSize!.height;
        }
        break;
      case PopoverConstraint.anchorMinSize:
        if (_anchorSize != null) {
          minHeight = _anchorSize!.height;
        }
        break;
      case PopoverConstraint.anchorMaxSize:
        if (_anchorSize != null) {
          maxHeight = _anchorSize!.height;
        }
        break;
      case PopoverConstraint.intrinsic:
        if (child != null) {
          final double intrinsicHeight =
              child!.getMaxIntrinsicHeight(double.infinity);
          if (intrinsicHeight.isFinite) {
            maxHeight = min(maxHeight, intrinsicHeight);
          }
        }
        break;
      case PopoverConstraint.flexible:
        // Use default constraints
        break;
    }

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.biggest;
      return;
    }

    // Lay out the child with our computed constraints
    final childConstraints = _computeConstraints(constraints);
    child!.layout(childConstraints, parentUsesSize: true);
    size = constraints.biggest;

    final Size childSize = child!.size;

    // Pick the best raw position (before clamping)
    final _PositionOption bestOption = _findBestPosition(childSize);
    final double x = bestOption.position.dx;
    final double y = bestOption.position.dy;
    final double offsetX = bestOption.offsetX;
    final double offsetY = bestOption.offsetY;

    // Compute screen‐edge bounds
    final double minX = _margin.left;
    final double maxX = size.width - childSize.width - _margin.right;
    final double minY = _margin.top;
    final double maxY = size.height - childSize.height - _margin.bottom;

    // Apply offset then clamp the final coordinates inside the allowed area
    final double finalX = (x + offsetX).clamp(minX, maxX);
    final double finalY = (y + offsetY).clamp(minY, maxY);

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    childParentData.offset = Offset(finalX, finalY);
  }

  _PositionOption _findBestPosition(Size childSize) {
    double offsetX = _offset?.dx ?? 0;
    double offsetY = _offset?.dy ?? 0;

    // Calculate the initial position based on alignment
    double x = _position.dx -
        childSize.width / 2 -
        (childSize.width / 2 * _alignment.x);
    double y = _position.dy -
        childSize.height / 2 -
        (childSize.height / 2 * _alignment.y);

    // Check if we need to invert based on screen edges and margins with thresholds
    double left = x - _margin.left;
    double top = y - _margin.top;
    double right = x + childSize.width + _margin.right;
    double bottom = y + childSize.height + _margin.bottom;

    // Auto-invert logic - try different orientations to find best fit
    List<_PositionOption> options = [];

    // Original position
    options.add(_PositionOption(
      position: Offset(x, y),
      score: _calculatePositionScore(left, top, right, bottom, size),
      invertX: false,
      invertY: false,
      offsetX: offsetX,
      offsetY: offsetY,
    ));

    // X-inverted position
    if (_allowInvertHorizontal) {
      double invertedX = _calculateInvertedXPosition(childSize);
      double invertedLeft = invertedX - _margin.left;
      double invertedRight = invertedX + childSize.width + _margin.right;

      options.add(_PositionOption(
        position: Offset(invertedX, y),
        score: _calculatePositionScore(
            invertedLeft, top, invertedRight, bottom, size),
        invertX: true,
        invertY: false,
        offsetX: -offsetX,
        offsetY: offsetY,
      ));
    }

    // Y-inverted position
    if (_allowInvertVertical) {
      double invertedY = _calculateInvertedYPosition(childSize);
      double invertedTop = invertedY - _margin.top;
      double invertedBottom = invertedY + childSize.height + _margin.bottom;

      options.add(_PositionOption(
        position: Offset(x, invertedY),
        score: _calculatePositionScore(
            left, invertedTop, right, invertedBottom, size),
        invertX: false,
        invertY: true,
        offsetX: offsetX,
        offsetY: -offsetY,
      ));
    }

    // Both X and Y inverted
    if (_allowInvertHorizontal && _allowInvertVertical) {
      double invertedX = _calculateInvertedXPosition(childSize);
      double invertedY = _calculateInvertedYPosition(childSize);

      double invertedLeft = invertedX - _margin.left;
      double invertedRight = invertedX + childSize.width + _margin.right;
      double invertedTop = invertedY - _margin.top;
      double invertedBottom = invertedY + childSize.height + _margin.bottom;

      options.add(_PositionOption(
        position: Offset(invertedX, invertedY),
        score: _calculatePositionScore(
            invertedLeft, invertedTop, invertedRight, invertedBottom, size),
        invertX: true,
        invertY: true,
        offsetX: -offsetX,
        offsetY: -offsetY,
      ));
    }

    options.sort((a, b) => b.score.compareTo(a.score));
    return options.first;
  }

  double _calculateInvertedXPosition(Size childSize) {
    // Horizontal inversion position - place on the opposite side of alignment.x
    double invertedX = _position.dx -
        childSize.width / 2 -
        (childSize.width / 2 * -_alignment.x);

    // If anchorSize exists, adjust based on anchor size
    if (_anchorSize != null) {
      invertedX -= _anchorSize!.width * _anchorAlignment.x;
    }

    return invertedX;
  }

  double _calculateInvertedYPosition(Size childSize) {
    // Vertical inversion position - place on the opposite side of alignment.y
    double invertedY = _position.dy -
        childSize.height / 2 -
        (childSize.height / 2 * -_alignment.y);

    // If anchorSize exists, adjust based on anchor size
    if (_anchorSize != null) {
      invertedY -= _anchorSize!.height * _anchorAlignment.y;
    }

    return invertedY;
  }

  double _calculatePositionScore(double left, double top, double right,
      double bottom, Size containerSize) {
    // Calculate how much is outside the container in each direction
    // Now using thresholds to trigger inversion sooner

    double leftOverflow = max(0, _horizontalInversionThreshold - left);
    double rightOverflow =
        max(0, right - (containerSize.width - _horizontalInversionThreshold));
    double topOverflow = max(0, _verticalInversionThreshold - top);
    double bottomOverflow =
        max(0, bottom - (containerSize.height - _verticalInversionThreshold));

    // Weight for overflow
    double totalOverflow =
        leftOverflow + rightOverflow + topOverflow + bottomOverflow;

    // Calculate distance from anchor point as a penalty (lower is better)
    double anchorDistance =
        (_position - Offset((left + right) / 2, (top + bottom) / 2)).distance;

    // Score formula: higher is better
    return -totalOverflow * 10 - anchorDistance;
  }
}

// --- Helper Classes ---

class _ResolvedPosition {
  final Offset position;
  final Size? anchorSize;

  _ResolvedPosition({
    required this.position,
    required this.anchorSize,
  });
}

class _PositionOption {
  final Offset position;
  final double score;
  final bool invertX;
  final bool invertY;
  final double offsetX;
  final double offsetY;

  _PositionOption({
    required this.position,
    required this.score,
    required this.invertX,
    required this.invertY,
    required this.offsetX,
    required this.offsetY,
  });
}

/// Throttler to limit position update frequency
class _UpdateThrottler {
  final Duration minInterval;
  DateTime? _lastUpdate;

  _UpdateThrottler(this.minInterval);

  bool shouldUpdate() {
    final now = DateTime.now();
    if (_lastUpdate == null || now.difference(_lastUpdate!) >= minInterval) {
      _lastUpdate = now;
      return true;
    }
    return false;
  }
}

// --- Utility Functions ---

/// Helper function to display a popover
OverlayCompleter<T?> showPopover<T>({
  required BuildContext context,
  required AlignmentGeometry alignment,
  required WidgetBuilder builder,
  Offset? position,
  AlignmentGeometry? anchorAlignment,
  PopoverConstraint widthConstraint = PopoverConstraint.flexible,
  PopoverConstraint heightConstraint = PopoverConstraint.flexible,
  Key? key,
  bool rootOverlay = true,
  bool modal = false,
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
  OverlayHandler? handler,
  Size? fixedSize,
  LayerLink? layerLink,
  List<PopoverAnimationType>? enterAnimations,
  List<PopoverAnimationType>? exitAnimations,
  Curve? showCurve,
  Curve? dismissCurve,
  Duration? resizeDuration,
  Curve? resizeCurve,
  double initialScale = 0.9,
  PopoverAnimationConfig? animationConfig,
  bool stayVisibleOnScroll = true,
  bool? alwaysFocus = false,
}) {
  handler ??= OverlayManager.of(context);
  // Create animation config if not provided
  final effectiveAnimConfig = animationConfig ??
      PopoverAnimationConfig(
        enterDuration: showDuration ?? const Duration(milliseconds: 300),
        exitDuration: dismissDuration ?? const Duration(milliseconds: 200),
        enterCurve: showCurve ?? Curves.easeOutCubic,
        exitCurve: dismissCurve ?? Curves.easeIn,
        resizeDuration: resizeDuration ?? const Duration(milliseconds: 250),
        resizeCurve: resizeCurve ?? Curves.easeInOutCubic,
        initialScale: initialScale,
        enterAnimations: enterAnimations ??
            [PopoverAnimationType.fadeIn, PopoverAnimationType.scale],
        exitAnimations: exitAnimations ??
            [PopoverAnimationType.fadeOut, PopoverAnimationType.scale],
      );

  // Only pass parameters that are defined in the OverlayHandler interface
  return handler.show<T>(
    context: context,
    alignment: alignment,
    builder: builder,
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
    showDuration: effectiveAnimConfig.enterDuration,
    dismissDuration: effectiveAnimConfig.exitDuration,
    overlayBarrier: overlayBarrier,
    layerLink: layerLink,
    fixedSize: fixedSize,
    stayVisibleOnScroll: stayVisibleOnScroll,
    enterAnimations: enterAnimations,
    exitAnimations: exitAnimations,
    animationConfig: effectiveAnimConfig,
    alwaysFocus: alwaysFocus,
  );
}

/// Extension to resolve EdgeInsetsGeometry with the correct context
extension EdgeInsetsGeometryExtension on EdgeInsetsGeometry {
  /// Resolve edge insets using the directionality from context
  EdgeInsets resolveInReverse(BuildContext context) {
    return resolve(Directionality.of(context));
  }
}

/// Extension on AlignmentGeometry for easier resolution
extension AlignmentGeometryExtension on AlignmentGeometry {
  /// Safely resolves alignment with the given context
  Alignment optionallyResolve(BuildContext? context) {
    if (this is Alignment) {
      return this as Alignment;
    }

    if (context != null) {
      final TextDirection? direction = Directionality.maybeOf(context);
      if (direction != null) {
        return resolve(direction);
      }
    }

    return resolve(TextDirection.ltr);
  }
}
