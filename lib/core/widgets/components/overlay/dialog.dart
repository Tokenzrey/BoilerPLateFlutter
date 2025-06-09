// -----------------------------------------------------------------------------
// DIALOG SYSTEM - Enhanced dialog system with comprehensive styling and animations
// Integrates with popover system for flexible positioning and transitions
// -----------------------------------------------------------------------------

import 'dart:math' show pi;
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Dialog, showDialog;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:data_widget/data_widget.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';

// =============================================================================
// SECTION: CONFIGURATION CLASSES
// =============================================================================

/// Animation types for dialog transitions
enum DialogAnimationType {
  fade,
  scale,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  rotation,
}

/// Content alignment within dialog
enum DialogContentAlign {
  start,
  center,
  end,
}

/// Configuration for dialog size responsiveness
class DialogSizeConfig {
  /// Maximum width relative to screen width (0.0-1.0)
  final double maxWidthFactor;

  /// Maximum height relative to screen height (0.0-1.0)
  final double maxHeightFactor;

  /// Minimum width in pixels
  final double? minWidth;

  /// Maximum width in pixels
  final double? maxWidth;

  /// Whether to automatically adjust for keyboard
  final bool avoidKeyboard;

  /// Size constraint for width - integrated from popover
  final PopoverConstraint widthConstraint;

  /// Size constraint for height - integrated from popover
  final PopoverConstraint heightConstraint;

  /// Fixed size for the dialog - integrated from popover
  final Size? fixedSize;

  const DialogSizeConfig({
    this.maxWidthFactor = 0.9,
    this.maxHeightFactor = 0.9,
    this.minWidth,
    this.maxWidth,
    this.avoidKeyboard = true,
    this.widthConstraint = PopoverConstraint.flexible,
    this.heightConstraint = PopoverConstraint.flexible,
    this.fixedSize,
  });

  /// Default configuration for mobile devices
  static const DialogSizeConfig mobile = DialogSizeConfig(
    maxWidthFactor: 0.95,
    maxHeightFactor: 0.8,
    avoidKeyboard: true,
    widthConstraint: PopoverConstraint.flexible,
    heightConstraint: PopoverConstraint.flexible,
  );

  /// Default configuration for tablet devices
  static const DialogSizeConfig tablet = DialogSizeConfig(
    maxWidthFactor: 0.7,
    maxHeightFactor: 0.8,
    minWidth: 400,
    maxWidth: 600,
    widthConstraint: PopoverConstraint.flexible,
    heightConstraint: PopoverConstraint.flexible,
  );

  /// Choose appropriate size config based on screen size
  static DialogSizeConfig forContext(BuildContext context) {
    final width = MediaQuery.of(context).size.shortestSide;
    return width >= 600 ? tablet : mobile;
  }

  /// Creates a copy with modified properties
  DialogSizeConfig copyWith({
    double? maxWidthFactor,
    double? maxHeightFactor,
    double? minWidth,
    double? maxWidth,
    bool? avoidKeyboard,
    PopoverConstraint? widthConstraint,
    PopoverConstraint? heightConstraint,
    Size? fixedSize,
  }) {
    return DialogSizeConfig(
      maxWidthFactor: maxWidthFactor ?? this.maxWidthFactor,
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      avoidKeyboard: avoidKeyboard ?? this.avoidKeyboard,
      widthConstraint: widthConstraint ?? this.widthConstraint,
      heightConstraint: heightConstraint ?? this.heightConstraint,
      fixedSize: fixedSize ?? this.fixedSize,
    );
  }
}

/// Configuration for dialog visual styling
class DialogStyle {
  /// Background color of the dialog
  final Color? backgroundColor;

  /// Border radius of the dialog
  final BorderRadius? borderRadius;

  /// Border color of the dialog
  final Color? borderColor;

  /// Border width of the dialog
  final double? borderWidth;

  /// External margin around the dialog
  final EdgeInsetsGeometry? margin;

  /// Internal padding within the dialog
  final EdgeInsetsGeometry? padding;

  /// Shadow elevation effect for the dialog
  final double? elevation;

  /// List of box shadows (takes precedence over elevation if provided)
  final List<BoxShadow>? boxShadow;

  /// Whether dialog content should be clipped to border radius
  final Clip clipBehavior;

  /// Surface opacity of the dialog (0.0 - 1.0)
  final double? surfaceOpacity;

  /// Surface blur effect strength
  final double? surfaceBlur;

  /// Creates a dialog style configuration
  const DialogStyle({
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.margin,
    this.padding,
    this.elevation,
    this.boxShadow,
    this.clipBehavior = Clip.none,
    this.surfaceOpacity,
    this.surfaceBlur,
  });

  /// Creates a copy with modified properties
  DialogStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    List<BoxShadow>? boxShadow,
    Clip? clipBehavior,
    double? surfaceOpacity,
    double? surfaceBlur,
  }) {
    return DialogStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      boxShadow: boxShadow ?? this.boxShadow,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
    );
  }
}

/// Accessibility configuration for dialogs
class DialogAccessibility {
  /// Label for screen readers
  final String label;

  /// Hint text for screen readers
  final String? hint;

  /// Whether to announce the dialog when opened
  final bool announceOnOpen;

  /// Custom dismiss behavior
  final VoidCallback? onDismiss;

  /// Whether dialog should be navigable by keyboard
  final bool isNavigable;

  /// Whether to enable ESC key to dismiss
  final bool escDismissible;

  /// Whether to enforce focus trapping within the dialog
  final bool trapFocus;

  const DialogAccessibility({
    this.label = 'Dialog',
    this.hint,
    this.announceOnOpen = true,
    this.onDismiss,
    this.isNavigable = true,
    this.escDismissible = true,
    this.trapFocus = true,
  });
}

// =============================================================================
// SECTION: STATE MANAGEMENT
// =============================================================================

/// Manages dialog stacking and focus coordination
class DialogManager {
  // Singleton instance
  static final DialogManager _instance = DialogManager._internal();
  factory DialogManager() => _instance;
  DialogManager._internal();

  // Stack of active dialogs
  final List<_DialogStackEntry> _dialogStack = [];

  // Add a dialog to the stack
  void pushDialog(
      BuildContext context, FocusScopeNode focusNode, VoidCallback dismiss) {
    _dialogStack.add(_DialogStackEntry(context, focusNode, dismiss));
    // Request focus for the new topmost dialog
    if (_dialogStack.isNotEmpty) {
      _dialogStack.last.focusNode.requestFocus();
    }
  }

  // Remove a dialog from the stack
  void popDialog(BuildContext context) {
    _dialogStack.removeWhere((entry) => entry.context == context);
    if (_dialogStack.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dialogStack.last.focusNode.requestFocus();
      });
    }
  }

  // Handle ESC key globally
  void handleEscapeKey() {
    if (_dialogStack.isNotEmpty) {
      // Dismiss the topmost dialog
      _dialogStack.last.dismiss();
    }
  }

  // Check if this is the topmost dialog
  bool isTopmostDialog(BuildContext context) {
    return _dialogStack.isNotEmpty && _dialogStack.last.context == context;
  }

  // Get the current dialog nesting level
  int getDialogLevel(BuildContext context) {
    for (int i = 0; i < _dialogStack.length; i++) {
      if (_dialogStack[i].context == context) {
        return i;
      }
    }
    return -1;
  }
}

/// Controller for managing multiple dialogs - inspired by PopoverController
class DialogController extends ChangeNotifier {
  bool _disposed = false;
  final List<Dialog> _openDialogs = [];

  bool get hasOpenDialog =>
      _openDialogs.isNotEmpty &&
      _openDialogs.any((element) => !element.entry.isCompleted);

  bool get hasMountedDialog =>
      _openDialogs.isNotEmpty &&
      _openDialogs.any((element) => !element.entry.isAnimationCompleted);

  Iterable<Dialog> get openDialogs => List.unmodifiable(_openDialogs);

  /// Shows a new dialog with control through this controller
  Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = Alignment.center,
    AlignmentGeometry? anchorAlignment,
    bool closeOthers = true,
    bool useRootNavigator = true,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    bool fullScreen = false,
    DialogAnimationType animationType = DialogAnimationType.scale,
    PopoverAnimationConfig? animationConfig,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
    AlignmentGeometry? transitionAlignment,
    Curve inCurve = Curves.easeOutQuint,
    Curve outCurve = Curves.easeInQuint,
    Duration? transitionDuration,
    bool avoidKeyboard = true,
    VoidCallback? onBackdropTap,
    DialogAccessibility? accessibility,
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,
    DialogSizeConfig? sizeConfig,
    Size? fixedSize,
    LayerLink? layerLink,
    Offset? offset,
    bool allowInvertHorizontal = true,
    bool allowInvertVertical = true,
    GlobalKey<OverlayHandlerStateMixin>? dialogKey,
    // Visual styling options
    DialogStyle? dialogStyle,
    Color? dialogBackgroundColor,
    BorderRadius? dialogBorderRadius,
    EdgeInsetsGeometry? dialogMargin,
    EdgeInsetsGeometry? dialogPadding,
    double? dialogElevation,
    Color? dialogBorderColor,
    double? dialogBorderWidth,
    Clip? dialogClipBehavior,
    List<BoxShadow>? dialogBoxShadow,
    double? dialogSurfaceOpacity,
    double? dialogSurfaceBlur,
  }) async {
    if (closeOthers) {
      close();
    }

    dialogKey ??= GlobalKey<OverlayHandlerStateMixin>(
        debugLabel: 'DialogAnchor$hashCode');

    // Create the dialog style from parameters
    final effectiveDialogStyle = (dialogStyle ?? const DialogStyle()).copyWith(
      backgroundColor: dialogBackgroundColor,
      borderRadius: dialogBorderRadius,
      margin: dialogMargin,
      padding: dialogPadding,
      elevation: dialogElevation,
      borderColor: dialogBorderColor,
      borderWidth: dialogBorderWidth,
      clipBehavior: dialogClipBehavior,
      boxShadow: dialogBoxShadow,
      surfaceOpacity: dialogSurfaceOpacity,
      surfaceBlur: dialogSurfaceBlur,
    );

    // Create dialog configuration
    final result = await showDialog<T>(
      context: context,
      builder: builder,
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      fullScreen: fullScreen,
      animationType: animationType,
      animationConfig: animationConfig,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      transitionAlignment: transitionAlignment,
      inCurve: inCurve,
      outCurve: outCurve,
      transitionDuration: transitionDuration,
      avoidKeyboard: avoidKeyboard,
      onBackdropTap: onBackdropTap,
      accessibility: accessibility,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      sizeConfig: sizeConfig,
      fixedSize: fixedSize,
      layerLink: layerLink,
      offset: offset,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      dialogKey: dialogKey,
      dialogController: this,
      dialogStyle: effectiveDialogStyle,
    );

    return result;
  }

  /// Register a dialog with this controller
  void _registerDialog(Dialog dialog) {
    _openDialogs.add(dialog);
    notifyListeners();

    // Setup future completion handling
    dialog.entry.future.then((_) {
      if (!_disposed) {
        _openDialogs.remove(dialog);
        notifyListeners();
      }
    });
  }

  /// Close all currently open dialogs
  void close([bool immediate = false]) {
    for (final dialog in List<Dialog>.from(_openDialogs)) {
      dialog.close(immediate);
    }
    _openDialogs.clear();
    notifyListeners();
  }

  /// Schedule all dialogs to close after current operation
  void closeLater() {
    for (final dialog in List.from(_openDialogs)) {
      dialog.closeLater();
    }
    notifyListeners();
  }

  /// Close the topmost dialog
  Future<void> closeLastDialog() async {
    if (_openDialogs.isNotEmpty) {
      final last = _openDialogs.last;
      if (last.currentState?.mounted ?? false) {
        await last.close();
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    close(true);
    super.dispose();
  }
}

/// Wrapper for reference to a displayed dialog - similar to Popover class
class Dialog {
  final GlobalKey<OverlayHandlerStateMixin> key;
  final OverlayCompleter entry;

  Dialog._(this.key, this.entry);

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

// Entry for the dialog stack
class _DialogStackEntry {
  final BuildContext context;
  final FocusScopeNode focusNode;
  final VoidCallback dismiss;

  _DialogStackEntry(this.context, this.focusNode, this.dismiss);
}

// =============================================================================
// SECTION: CORE UI COMPONENTS
// =============================================================================

/// SurfaceCard implementation integrated directly in dialog.dart
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final bool filled;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Duration? duration;
  final Clip clipBehavior;

  const SurfaceCard({
    super.key,
    required this.child,
    this.filled = false,
    this.fillColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.boxShadow,
    this.padding,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.duration,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        fillColor ?? Theme.of(context).colorScheme.surface;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.0);
    final effectiveBorderWidth = borderWidth ?? 1.0;
    final effectiveBorderColor = borderColor ??
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.12);
    final effectiveBoxShadow = boxShadow ??
        [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ];
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveDuration = duration ?? const Duration(milliseconds: 200);

    Widget content = child;

    // Apply padding if specified
    if (effectivePadding != EdgeInsets.zero) {
      content = Padding(
        padding: effectivePadding,
        child: content,
      );
    }

    // Conditionally apply blur effect
    if (surfaceBlur != null && surfaceBlur! > 0) {
      content = ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: surfaceBlur!,
            sigmaY: surfaceBlur!,
          ),
          child: content,
        ),
      );
    }

    // Create base container
    return AnimatedContainer(
      duration: effectiveDuration,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: filled
            ? (surfaceOpacity != null
                ? effectiveBackgroundColor.withValues(alpha: surfaceOpacity!)
                : effectiveBackgroundColor)
            : Colors.transparent,
        borderRadius: effectiveBorderRadius,
        border: borderColor != null || borderWidth != null
            ? Border.all(
                color: effectiveBorderColor,
                width: effectiveBorderWidth,
              )
            : null,
        boxShadow: boxShadow ?? effectiveBoxShadow,
      ),
      child: content,
    );
  }
}

class ModalBackdrop extends StatelessWidget {
  static bool shouldClipSurface(double? surfaceOpacity) {
    if (surfaceOpacity == null) {
      return true;
    }
    return surfaceOpacity < 1;
  }

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final Color barrierColor;
  final Animation<double>? fadeAnimation;
  final bool modal;
  final bool surfaceClip;
  final VoidCallback? onTap;
  final bool avoidKeyboard;

  const ModalBackdrop({
    super.key,
    this.modal = true,
    this.surfaceClip = true,
    this.borderRadius = BorderRadius.zero,
    this.barrierColor = const Color.fromRGBO(0, 0, 0, 0.8),
    this.padding = EdgeInsets.zero,
    this.fadeAnimation,
    this.onTap,
    this.avoidKeyboard = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!modal) {
      return child;
    }
    var textDirection = Directionality.of(context);
    var resolvedBorderRadius = borderRadius.resolve(textDirection);
    var resolvedPadding = padding.resolve(textDirection);

    Widget paintWidget = CustomPaint(
      painter: SurfaceBarrierPainter(
        clip: surfaceClip,
        borderRadius: resolvedBorderRadius,
        barrierColor: barrierColor,
        padding: resolvedPadding,
      ),
    );

    if (fadeAnimation != null) {
      paintWidget = FadeTransition(
        opacity: fadeAnimation!,
        child: paintWidget,
      );
    }

    // If onTap is provided, wrap barrier with gesture detector
    if (onTap != null) {
      paintWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: paintWidget,
      );
    }

    Widget content = RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (!surfaceClip)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: onTap == null,
                child: paintWidget,
              ),
            ),
          child,
          if (surfaceClip)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: onTap == null,
                child: paintWidget,
              ),
            ),
        ],
      ),
    );

    // Add keyboard avoidance if needed
    if (avoidKeyboard) {
      return KeyboardDismissOnTap(
        child: AnimatedPadding(
          padding: MediaQuery.viewInsetsOf(context),
          duration: const Duration(milliseconds: 100),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Widget that dismisses keyboard when tapped outside of interactive elements
class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}

class SurfaceBarrierPainter extends CustomPainter {
  static const double bigSize = 1000000;
  static const bigScreen = Size(bigSize, bigSize);
  static const bigOffset = Offset(-bigSize / 2, -bigSize / 2);

  final bool clip;
  final BorderRadius borderRadius;
  final Color barrierColor;
  final EdgeInsets padding;

  SurfaceBarrierPainter({
    required this.clip,
    required this.borderRadius,
    required this.barrierColor,
    this.padding = EdgeInsets.zero,
  });

  Rect _padRect(Rect rect) {
    return Rect.fromLTRB(
      rect.left + padding.left,
      rect.top + padding.top,
      rect.right - padding.right,
      rect.bottom - padding.bottom,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = barrierColor
      ..blendMode = BlendMode.srcOver
      ..style = PaintingStyle.fill;
    if (clip) {
      var rect = (Offset.zero & size);
      rect = _padRect(rect);
      Path path = Path()
        ..addRect(bigOffset & bigScreen)
        ..addRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ));
      path.fillType = PathFillType.evenOdd;
      canvas.clipPath(path);
    }
    canvas.drawRect(
      bigOffset & bigScreen,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SurfaceBarrierPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.barrierColor != barrierColor ||
        oldDelegate.padding != padding ||
        oldDelegate.clip != clip;
  }
}

/// Keeps focus trapped within a dialog and handles ESC key
class DialogFocusTrap extends StatefulWidget {
  final Widget child;
  final bool trapFocus;
  final bool escDismissible;
  final VoidCallback? onDismiss;
  final FocusScopeNode? focusNode;

  const DialogFocusTrap({
    super.key,
    required this.child,
    this.trapFocus = true,
    this.escDismissible = true,
    this.onDismiss,
    this.focusNode,
  });

  @override
  State<DialogFocusTrap> createState() => _DialogFocusTrapState();
}

class _DialogFocusTrapState extends State<DialogFocusTrap> {
  late FocusScopeNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusScopeNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Register with dialog manager
        DialogManager()
            .pushDialog(context, _focusNode, widget.onDismiss ?? () {});

        // Request focus after build is complete
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    DialogManager().popDialog(context);
    if (widget.focusNode == null && _focusNode.hasFocus) {
      _focusNode.unfocus();
      _focusNode.dispose();
    } else if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        widget.escDismissible) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
        return KeyEventResult.handled;
      } else {
        closeOverlayWithResult(context);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        node: _focusNode,
        onKeyEvent: _handleKeyEvent,
        canRequestFocus: true,
        // Use a custom traversal policy to trap focus if needed
        child: FocusTraversalGroup(
          policy: widget.trapFocus
              ? _DialogTraversalPolicy()
              : ReadingOrderTraversalPolicy(),
          descendantsAreFocusable: true,
          child: widget.child,
        ));
  }
}

/// Custom traversal policy that keeps focus within the dialog
class _DialogTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  FocusNode? findFirstFocusInDirection(
      FocusNode currentNode, TraversalDirection direction) {
    final FocusNode? firstFocus =
        super.findFirstFocusInDirection(currentNode, direction);

    // If we're about to move outside the scope, cycle back
    if (firstFocus == null) {
      final FocusScopeNode scope = currentNode.nearestScope!;

      // Cycle to first node when at the end
      if (direction == TraversalDirection.down ||
          direction == TraversalDirection.right) {
        return super.findFirstFocus(scope);
      }

      // Cycle to last node when at the beginning
      if (direction == TraversalDirection.up ||
          direction == TraversalDirection.left) {
        return super.findLastFocus(scope);
      }
    }

    return firstFocus;
  }
}

class ModalContainer extends StatelessWidget {
  static const kFullScreenMode = #modal_surface_card_fullscreen;
  static bool isFullScreenMode(BuildContext context) {
    return Model.maybeOf<bool>(context, kFullScreenMode) == true;
  }

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool filled;
  final Color? fillColor;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Clip clipBehavior;
  final List<BoxShadow>? boxShadow;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Duration? duration;
  final DialogContentAlign contentAlign;
  final DialogSizeConfig? sizeConfig;
  final DialogAccessibility? accessibility;
  final VoidCallback? onDismiss;

  // Style properties from DialogStyle
  final DialogStyle? dialogStyle;
  final double? elevation;

  // Integrated properties from popover
  final Alignment? alignment;
  final Alignment? anchorAlignment;
  final Offset? position;
  final Size? anchorSize;
  final Offset? offset;
  final LayerLink? layerLink;
  final bool allowInvertHorizontal;
  final bool allowInvertVertical;

  const ModalContainer({
    super.key,
    required this.child,
    this.padding,
    this.filled = false,
    this.fillColor,
    this.borderRadius,
    this.clipBehavior = Clip.none,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.duration,
    this.contentAlign = DialogContentAlign.center,
    this.sizeConfig,
    this.accessibility,
    this.onDismiss,
    // Added styling properties
    this.dialogStyle,
    this.elevation,
    // Added popover-like positioning properties
    this.alignment,
    this.anchorAlignment,
    this.position,
    this.anchorSize,
    this.offset,
    this.layerLink,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final fullScreenMode = Model.maybeOf<bool>(context, kFullScreenMode);
    final screenSize = MediaQuery.of(context).size;

    // Apply responsive constraints - enhanced with popover constraints
    final config = sizeConfig ?? DialogSizeConfig.forContext(context);
    final BoxConstraints constraints = _buildConstraints(config, screenSize);

    // Determine mainAxisAlignment based on content alignment
    MainAxisAlignment mainAlignment;
    CrossAxisAlignment crossAlignment;

    switch (contentAlign) {
      case DialogContentAlign.start:
        mainAlignment = MainAxisAlignment.start;
        crossAlignment = CrossAxisAlignment.start;
        break;
      case DialogContentAlign.end:
        mainAlignment = MainAxisAlignment.end;
        crossAlignment = CrossAxisAlignment.end;
        break;
      case DialogContentAlign.center:
        mainAlignment = MainAxisAlignment.center;
        crossAlignment = CrossAxisAlignment.center;
        break;
    }

    // Get the text direction for resolving BorderRadiusGeometry
    final textDirection = Directionality.of(context);

    // Merge style properties, with direct props overriding dialogStyle
    final effectiveFillColor = fillColor ?? dialogStyle?.backgroundColor;
    final effectiveBorderRadius = fullScreenMode == true
        ? BorderRadius.zero
        : (borderRadius ?? dialogStyle?.borderRadius)?.resolve(textDirection);
    final effectiveBorderWidth = fullScreenMode == true
        ? 0.0
        : borderWidth?.toDouble() ?? dialogStyle?.borderWidth?.toDouble();
    final effectiveBorderColor = borderColor ?? dialogStyle?.borderColor;
    final effectiveBoxShadow = fullScreenMode == true
        ? const <BoxShadow>[]
        : (boxShadow ??
            dialogStyle?.boxShadow ??
            (elevation != null || dialogStyle?.elevation != null
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: elevation ?? dialogStyle?.elevation ?? 6.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null));
    final effectivePadding = padding ?? dialogStyle?.padding;
    final effectiveSurfaceOpacity =
        surfaceOpacity ?? dialogStyle?.surfaceOpacity;
    final effectiveSurfaceBlur = surfaceBlur ?? dialogStyle?.surfaceBlur;
    final effectiveClipBehavior = dialogStyle?.clipBehavior != null
        ? dialogStyle!.clipBehavior
        : clipBehavior;

    Widget dialogContent = SurfaceCard(
      clipBehavior: effectiveClipBehavior,
      borderRadius: effectiveBorderRadius,
      borderWidth: effectiveBorderWidth,
      borderColor: effectiveBorderColor,
      filled: filled || effectiveFillColor != null,
      fillColor: effectiveFillColor,
      boxShadow: effectiveBoxShadow,
      padding: effectivePadding,
      surfaceOpacity: effectiveSurfaceOpacity,
      surfaceBlur: effectiveSurfaceBlur,
      duration: duration,
      child: ConstrainedBox(
        constraints: constraints,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAlignment,
          crossAxisAlignment: crossAlignment,
          children: [
            Flexible(child: child),
          ],
        ),
      ),
    );

    // Apply margin if specified in dialogStyle
    if (dialogStyle?.margin != null) {
      dialogContent = Padding(
        padding: dialogStyle!.margin!,
        child: dialogContent,
      );
    }

    // If using LayerLink, wrap with CompositedTransformFollower
    if (layerLink != null) {
      dialogContent = CompositedTransformFollower(
        link: layerLink!,
        showWhenUnlinked: false,
        offset: offset ?? Offset.zero,
        child: dialogContent,
      );
    }

    // Wrap with focus trap and accessibility features
    final bool trapFocus = accessibility?.trapFocus ?? true;
    final bool escDismissible = accessibility?.escDismissible ?? true;

    dialogContent = DialogFocusTrap(
      trapFocus: trapFocus,
      escDismissible: escDismissible,
      onDismiss: onDismiss,
      child: Semantics(
        container: true,
        label: accessibility?.label ?? 'Dialog',
        hint: accessibility?.hint,
        scopesRoute: true,
        explicitChildNodes: true,
        onDismiss: accessibility?.onDismiss ?? onDismiss,
        child: dialogContent,
      ),
    );

    // Announce dialog opening if configured
    if (accessibility?.announceOnOpen ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SemanticsService.announce(
          accessibility?.label ?? 'Dialog',
          TextDirection.ltr,
        );
      });
    }

    // Create an indexing decoration to indicate dialog level
    final int level = DialogManager().getDialogLevel(context);
    if (level > 0) {
      final double elevationOffset = level * 8.0;
      dialogContent = Padding(
        padding: EdgeInsets.only(top: elevationOffset, left: elevationOffset),
        child: dialogContent,
      );
    }

    return dialogContent;
  }

  /// Build constraints based on config, incorporating PopoverConstraint system
  BoxConstraints _buildConstraints(DialogSizeConfig config, Size screenSize) {
    double minWidth = 0;
    double maxWidth = screenSize.width * config.maxWidthFactor;
    double minHeight = 0;
    double maxHeight = screenSize.height * config.maxHeightFactor;

    // Apply minimum width from config
    if (config.minWidth != null) {
      minWidth = config.minWidth!;
    }

    // Apply maximum width from config
    if (config.maxWidth != null) {
      maxWidth = config.maxWidth!;
    }

    // Handle width constraint types from PopoverConstraint
    switch (config.widthConstraint) {
      case PopoverConstraint.fixed:
        if (config.fixedSize != null) {
          minWidth = maxWidth = config.fixedSize!.width;
        }
        break;
      case PopoverConstraint.fullScreen:
        minWidth = maxWidth = screenSize.width;
        break;
      case PopoverConstraint.anchorFixedSize:
        if (anchorSize != null) {
          minWidth = maxWidth = anchorSize!.width;
        }
        break;
      case PopoverConstraint.anchorMinSize:
        if (anchorSize != null) {
          minWidth = anchorSize!.width;
        }
        break;
      case PopoverConstraint.anchorMaxSize:
        if (anchorSize != null) {
          maxWidth = anchorSize!.width;
        }
        break;
      case PopoverConstraint.contentSize:
      case PopoverConstraint.intrinsic:
      case PopoverConstraint.flexible:
        // Use default constraints
        break;
    }

    // Handle height constraint types from PopoverConstraint
    switch (config.heightConstraint) {
      case PopoverConstraint.fixed:
        if (config.fixedSize != null) {
          minHeight = maxHeight = config.fixedSize!.height;
        }
        break;
      case PopoverConstraint.fullScreen:
        minHeight = maxHeight = screenSize.height;
        break;
      case PopoverConstraint.anchorFixedSize:
        if (anchorSize != null) {
          minHeight = maxHeight = anchorSize!.height;
        }
        break;
      case PopoverConstraint.anchorMinSize:
        if (anchorSize != null) {
          minHeight = anchorSize!.height;
        }
        break;
      case PopoverConstraint.anchorMaxSize:
        if (anchorSize != null) {
          maxHeight = anchorSize!.height;
        }
        break;
      case PopoverConstraint.contentSize:
      case PopoverConstraint.intrinsic:
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
}

// =============================================================================
// SECTION: ROUTING & ANIMATION
// =============================================================================

/// Enhanced dialog route supporting both legacy and popover features
class EnhancedDialogRoute<T> extends RawDialogRoute<T> {
  final CapturedData? data;
  final AlignmentGeometry alignment;
  final bool fullScreen;
  final DialogAnimationType animationType;
  final Curve inCurve;
  final Curve outCurve;
  final DialogAccessibility? accessibility;

  // Integrated properties from popover
  final PopoverAnimationConfig? animationConfig;
  final List<PopoverAnimationType>? enterAnimations;
  final List<PopoverAnimationType>? exitAnimations;
  final PopoverConstraint widthConstraint;
  final PopoverConstraint heightConstraint;
  final Size? fixedSize;
  final LayerLink? layerLink;
  final Offset? offset;
  final bool allowInvertHorizontal;
  final bool allowInvertVertical;
  final AlignmentGeometry? anchorAlignment;
  final GlobalKey<OverlayHandlerStateMixin>? dialogKey;
  final DialogController? dialogController;

  // Added styling properties
  final DialogStyle? dialogStyle;

  @override
  final Duration transitionDuration;

  EnhancedDialogRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    super.barrierColor = const Color.fromRGBO(0, 0, 0, 0),
    super.barrierDismissible,
    String? barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    required this.alignment,
    required super.transitionBuilder,
    this.fullScreen = false,
    this.data,
    this.animationType = DialogAnimationType.scale,
    this.inCurve = Curves.easeOut,
    this.outCurve = Curves.easeIn,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.accessibility,
    // Added popover properties
    this.animationConfig,
    this.enterAnimations,
    this.exitAnimations,
    this.widthConstraint = PopoverConstraint.flexible,
    this.heightConstraint = PopoverConstraint.flexible,
    this.fixedSize,
    this.layerLink,
    this.offset,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
    this.anchorAlignment,
    this.dialogKey,
    this.dialogController,
    // Added styling properties
    this.dialogStyle,
  }) : super(
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(
              builder: (context) {
                return Padding(
                  // Apply dialog margin only if not fullscreen and not overridden
                  padding: fullScreen
                      ? EdgeInsets.zero
                      : dialogStyle?.margin
                              ?.resolve(Directionality.of(context)) ??
                          const EdgeInsets.all(16),
                  child: builder(context),
                );
              },
            );
            Widget dialog = themes?.wrap(pageChild) ?? pageChild;
            if (data != null) {
              dialog = data.wrap(dialog);
            }
            if (useSafeArea) {
              dialog = SafeArea(child: dialog);
            }
            return dialog;
          },
          barrierLabel: barrierLabel ?? 'Dismiss',
          transitionDuration: transitionDuration,
        );
}

/// Unified dialog transition builder that supports both legacy DialogAnimationType
/// and PopoverAnimationType/PopoverAnimationConfig
Widget _buildUnifiedDialogTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child, {
  // Legacy dialog properties
  required DialogAnimationType animationType,
  required AlignmentGeometry alignment,
  AlignmentGeometry? transitionAlignment,
  required bool fullScreen,
  Curve inCurve = Curves.easeOutQuint,
  Curve outCurve = Curves.easeInQuint,
  // Integrated popover properties
  PopoverAnimationConfig? animationConfig,
  List<PopoverAnimationType>? enterAnimations,
  List<PopoverAnimationType>? exitAnimations,
}) {
  // If popover animation config is provided, use it for more advanced animations
  if (animationConfig != null ||
      (enterAnimations != null && enterAnimations.isNotEmpty)) {
    return _buildPopoverStyleTransition(
      context,
      animation,
      secondaryAnimation,
      child,
      animationConfig: animationConfig,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      alignment: alignment,
      fullScreen: fullScreen,
    );
  }

  // Otherwise, use the legacy dialog animation approach
  return _buildDialogTransition(
    context,
    animationType,
    alignment,
    transitionAlignment,
    animation,
    secondaryAnimation,
    fullScreen,
    child,
    inCurve,
    outCurve,
  );
}

/// Legacy dialog transition builder
Widget _buildDialogTransition(
  BuildContext context,
  DialogAnimationType animationType,
  AlignmentGeometry alignment,
  AlignmentGeometry? transitionAlignment,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  bool fullScreen,
  Widget child,
  Curve inCurve,
  Curve outCurve,
) {
  // Create animations with custom curves
  final Animation<double> curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: inCurve,
    reverseCurve: outCurve,
  );

  // Apply appropriate transition based on animation type
  Widget transition;
  final Alignment effectiveTransitionAlignment =
      (transitionAlignment as Alignment?) ?? Alignment.center;

  switch (animationType) {
    case DialogAnimationType.scale:
      transition = ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
        alignment: effectiveTransitionAlignment,
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
      break;

    case DialogAnimationType.slideUp:
      transition = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
      break;

    case DialogAnimationType.slideDown:
      transition = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
      break;

    case DialogAnimationType.slideLeft:
      transition = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
      break;

    case DialogAnimationType.slideRight:
      transition = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
      break;

    case DialogAnimationType.rotation:
      transition = RotationTransition(
        turns: Tween<double>(begin: 0.05, end: 0.0).animate(curvedAnimation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        ),
      );
      break;

    case DialogAnimationType.fade:
      transition = FadeTransition(
        opacity: curvedAnimation,
        child: child,
      );
      break;
  }

  return FocusScope(
    canRequestFocus: animation.value == 1, // Only focus when fully visible
    child: fullScreen
        ? MultiModel(
            data: const [
              Model(ModalContainer.kFullScreenMode, true),
            ],
            child: transition,
          )
        : Align(
            alignment: alignment,
            child: transition,
          ),
  );
}

/// Popover-style transition builder using PopoverAnimationConfig
Widget _buildPopoverStyleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child, {
  PopoverAnimationConfig? animationConfig,
  List<PopoverAnimationType>? enterAnimations,
  List<PopoverAnimationType>? exitAnimations,
  required AlignmentGeometry alignment,
  required bool fullScreen,
}) {
  // Default animation config if none provided
  final effectiveConfig = animationConfig ??
      PopoverAnimationConfig(
        enterAnimations: enterAnimations ??
            [
              PopoverAnimationType.fadeIn,
              PopoverAnimationType.scale,
            ],
        exitAnimations: exitAnimations ??
            [
              PopoverAnimationType.fadeOut,
              PopoverAnimationType.scale,
            ],
      );

  // Create curved animation with the config's curve
  final Animation<double> curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: effectiveConfig.enterCurve,
    reverseCurve: effectiveConfig.exitCurve,
  );

  // Initialize with identity (no animation)
  Widget transition = child;

  // Add animations in sequence based on the enterAnimations list

  // Apply slide effects for different directions
  if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.slideUp) ||
      effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideDown) ||
      effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideLeft) ||
      effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideRight)) {
    // Determine slide direction
    Offset slideBegin = effectiveConfig.slideBegin;
    if (slideBegin == Offset.zero) {
      // Fallback slide direction if not specified
      if (effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideUp)) {
        slideBegin = const Offset(0, 20);
      } else if (effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideDown)) {
        slideBegin = const Offset(0, -20);
      } else if (effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideLeft)) {
        slideBegin = const Offset(20, 0);
      } else if (effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.slideRight)) {
        slideBegin = const Offset(-20, 0);
      }
    }

    transition = SlideTransition(
      position: Tween<Offset>(
        begin: slideBegin,
        end: effectiveConfig.slideEnd,
      ).animate(curvedAnimation),
      child: transition,
    );
  }

  // Apply rotation if needed
  if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.rotate)) {
    transition = RotationTransition(
      turns: Tween<double>(
        begin: effectiveConfig.rotateBegin / (2 * pi),
        end: effectiveConfig.rotateEnd / (2 * pi),
      ).animate(curvedAnimation),
      alignment: effectiveConfig.transformOrigin,
      child: transition,
    );
  }

  // Apply scale effect
  if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.scale)) {
    transition = ScaleTransition(
      scale: Tween<double>(
        begin: effectiveConfig.initialScale,
        end: 1.0,
      ).animate(curvedAnimation),
      alignment: effectiveConfig.transformOrigin,
      child: transition,
    );
  }
  // Apply scaleX and scaleY effects
  else if (effectiveConfig.enterAnimations
          .contains(PopoverAnimationType.scaleX) ||
      effectiveConfig.enterAnimations.contains(PopoverAnimationType.scaleY)) {
    transition = Transform(
      transform: Matrix4.diagonal3Values(
        effectiveConfig.enterAnimations.contains(PopoverAnimationType.scaleX)
            ? Tween<double>(begin: effectiveConfig.initialScale, end: 1.0)
                .evaluate(curvedAnimation)
            : 1.0,
        effectiveConfig.enterAnimations.contains(PopoverAnimationType.scaleY)
            ? Tween<double>(begin: effectiveConfig.initialScale, end: 1.0)
                .evaluate(curvedAnimation)
            : 1.0,
        1.0,
      ),
      alignment: effectiveConfig.transformOrigin,
      child: transition,
    );
  }

  // Apply skew effects
  if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.skewX) ||
      effectiveConfig.enterAnimations.contains(PopoverAnimationType.skewY)) {
    final Matrix4 skewMatrix = Matrix4.identity();

    if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.skewX)) {
      skewMatrix.setEntry(
          1,
          0,
          Tween<double>(
            begin: effectiveConfig.skewXBegin,
            end: effectiveConfig.skewXEnd,
          ).evaluate(curvedAnimation));
    }

    if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.skewY)) {
      skewMatrix.setEntry(
          0,
          1,
          Tween<double>(
            begin: effectiveConfig.skewYBegin,
            end: effectiveConfig.skewYEnd,
          ).evaluate(curvedAnimation));
    }

    transition = Transform(
      transform: skewMatrix,
      alignment: effectiveConfig.transformOrigin,
      child: transition,
    );
  }

  // Apply fade effect - applied last so it doesn't affect other transforms
  if (effectiveConfig.enterAnimations.contains(PopoverAnimationType.fadeIn) ||
      effectiveConfig.exitAnimations.contains(PopoverAnimationType.fadeOut)) {
    transition = FadeTransition(
      opacity: curvedAnimation,
      child: transition,
    );
  }

  return FocusScope(
    canRequestFocus: animation.value == 1, // Only focus when fully visible
    child: fullScreen
        ? MultiModel(
            data: const [
              Model(ModalContainer.kFullScreenMode, true),
            ],
            child: transition,
          )
        : Align(
            alignment: alignment,
            child: transition,
          ),
  );
}

// =============================================================================
// SECTION: OVERLAY HANDLERS & DIALOG COMPONENTS
// =============================================================================

/// Standard dialog components with enhanced customization
class DialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? leading;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;
  final Widget? titleWidget; // Allow complete replacement of title text
  final Widget? closeButton; // Allow custom close button

  const DialogHeader({
    super.key,
    this.title = '',
    this.onClose,
    this.leading,
    this.titleStyle,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    this.titleWidget,
    this.closeButton,
  }) : assert(title != '' || titleWidget != null,
            'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitleStyle = titleStyle ?? theme.textTheme.titleLarge;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: titleWidget ??
                Text(
                  title,
                  style: effectiveTitleStyle,
                  semanticsLabel: title,
                ),
          ),
          if (onClose != null)
            closeButton ??
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  tooltip: 'Close',
                  // Make sure this is keyboard focusable
                  focusNode: FocusNode(debugLabel: 'Close Dialog'),
                  autofocus: false,
                ),
        ],
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final BoxConstraints? constraints;

  const DialogContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.scrollable = true,
    this.physics,
    this.controller,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding,
      child: constraints != null
          ? ConstrainedBox(
              constraints: constraints!,
              child: child,
            )
          : child,
    );

    // If scrollable, wrap in SingleChildScrollView
    if (scrollable) {
      return SingleChildScrollView(
        controller: controller,
        physics: physics ?? const ClampingScrollPhysics(),
        child: content,
      );
    }

    return content;
  }
}

class DialogFooter extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry padding;
  final bool compact;
  final double? spacing;
  final bool? useVerticalLayout;
  final Widget? customContent;

  const DialogFooter({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.compact = false,
    this.spacing,
    this.useVerticalLayout,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    // Use custom content if provided
    if (customContent != null) {
      return Padding(
        padding: padding,
        child: customContent,
      );
    }

    // For small screens or many buttons, use a vertical layout
    final screenWidth = MediaQuery.of(context).size.width;
    final bool effectiveUseVerticalLayout = useVerticalLayout ??
        (compact == false && (screenWidth < 400 || actions.length > 2));

    if (effectiveUseVerticalLayout) {
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(height: spacing ?? 8),
              actions[i],
            ]
          ],
        ),
      );
    } else {
      // For larger screens, use horizontal layout
      return Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: alignment,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(width: spacing ?? 8),
              actions[i],
            ]
          ],
        ),
      );
    }
  }
}

/// Helper class to easily build standard dialog layouts with enhanced customization
class StandardDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? content;
  final List<Widget> actions;
  final VoidCallback? onClose;
  final Widget? icon;
  final Widget? closeButton;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry footerPadding;
  final bool scrollable;
  final DialogAccessibility? accessibility;
  final MainAxisAlignment footerAlignment;
  final bool useVerticalButtonLayout;
  final TextStyle? titleStyle;
  final Widget? header;
  final Widget? footer;
  final Widget? leading;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final BoxConstraints? contentConstraints;
  final double? buttonSpacing;

  const StandardDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.actions = const [],
    this.onClose,
    this.icon,
    this.closeButton,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.headerPadding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    this.footerPadding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.scrollable = true,
    this.accessibility,
    this.footerAlignment = MainAxisAlignment.end,
    this.useVerticalButtonLayout = false,
    this.titleStyle,
    this.header,
    this.footer,
    this.leading,
    this.scrollPhysics,
    this.scrollController,
    this.contentConstraints,
    this.buttonSpacing,
  }) : assert(
            (title != null || titleWidget != null || header != null) ||
                (content != null) ||
                (actions.length > 0 || footer != null),
            'At least one of title/titleWidget/header, content, or actions/footer must be provided');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom header or standard DialogHeader
        if (header != null)
          header!
        else if (title != null || titleWidget != null)
          DialogHeader(
            title: title ?? '',
            titleWidget: titleWidget,
            onClose: onClose,
            leading: icon ?? leading,
            padding: headerPadding,
            titleStyle: titleStyle,
            closeButton: closeButton,
          ),

        // Content section
        if (content != null)
          DialogContent(
            padding: contentPadding,
            scrollable: scrollable,
            physics: scrollPhysics,
            controller: scrollController,
            constraints: contentConstraints,
            child: content!,
          ),

        // Custom footer or standard DialogFooter
        if (footer != null)
          footer!
        else if (actions.isNotEmpty)
          DialogFooter(
            actions: actions,
            padding: footerPadding,
            alignment: footerAlignment,
            useVerticalLayout: useVerticalButtonLayout,
            spacing: buttonSpacing,
          ),
      ],
    );
  }
}

/// Dialog handler implementing OverlayHandler interface - allows dialogs to be used with OverlayManager
class DialogOverlayHandler extends OverlayHandler {
  static bool isDialogOverlay(BuildContext context) {
    return Model.maybeOf<bool>(context, #shadcn_flutter_dialog_overlay) == true;
  }

  const DialogOverlayHandler();
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
    PopoverAnimationConfig? animationConfig,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
  }) {
    // Default dialog animation type
    final DialogAnimationType animationType = DialogAnimationType.scale;
    final bool avoidKeyboard = true;
    DialogAccessibility? accessibility;
    VoidCallback? onBackdropTap;

    // Convert the key to a GlobalKey<OverlayHandlerStateMixin> if needed
    GlobalKey<OverlayHandlerStateMixin>? dialogKey;
    if (key is GlobalKey<OverlayHandlerStateMixin>) {
      dialogKey = key;
    } else if (key != null) {
      // Create a new key if necessary
      dialogKey = GlobalKey<OverlayHandlerStateMixin>();
    }

    // Create DialogStyle from margin
    final dialogStyle = margin != null ? DialogStyle(margin: margin) : null;

    var navigatorState = Navigator.of(
      context,
      rootNavigator: rootOverlay,
    );
    final CapturedThemes themes =
        InheritedTheme.capture(from: context, to: navigatorState.context);
    final CapturedData data =
        Data.capture(from: context, to: navigatorState.context);
    var dialogRoute = EnhancedDialogRoute<T>(
      context: context,
      builder: (context) {
        final surfaceOpacity = 0.14;
        var child = _DialogOverlayWrapper(
          route: ModalRoute.of(context) as EnhancedDialogRoute<T>,
          onBackdropTap: onBackdropTap,
          avoidKeyboard: avoidKeyboard,
          accessibility: accessibility,
          child: Builder(builder: (context) {
            return builder(context);
          }),
        );

        if (overlayBarrier != null) {
          return MultiModel(
            data: const [
              Model(#shadcn_flutter_dialog_overlay, true),
            ],
            child: ModalBackdrop(
              modal: modal,
              avoidKeyboard: avoidKeyboard,
              onTap: onBackdropTap ??
                  (barrierDismissable
                      ? () => Navigator.of(context).pop()
                      : null),
              surfaceClip: ModalBackdrop.shouldClipSurface(surfaceOpacity),
              borderRadius: overlayBarrier.borderRadius,
              padding: overlayBarrier.padding,
              barrierColor: overlayBarrier.barrierColor ??
                  const Color.fromRGBO(0, 0, 0, 0.8),
              child: child,
            ),
          );
        }

        return MultiModel(
          data: const [
            Model(#shadcn_flutter_dialog_overlay, true),
          ],
          child: child,
        );
      },
      themes: themes,
      barrierDismissible: barrierDismissable,
      barrierColor: overlayBarrier == null
          ? const Color.fromRGBO(0, 0, 0, 0.8)
          : Colors.transparent,
      barrierLabel: 'Dismiss',
      useSafeArea: true,
      data: data,
      accessibility: accessibility,
      animationType: animationType,
      transitionDuration:
          showDuration ?? dismissDuration ?? const Duration(milliseconds: 200),
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      // Integrated popover properties
      animationConfig: animationConfig,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      fixedSize: fixedSize,
      layerLink: layerLink,
      offset: offset,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      anchorAlignment: anchorAlignment,
      dialogKey: dialogKey,
      dialogStyle: dialogStyle,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _buildUnifiedDialogTransition(
          context,
          animation,
          secondaryAnimation,
          child,
          animationType: animationType,
          alignment: alignment,
          transitionAlignment: transitionAlignment,
          fullScreen: false,
          inCurve: Curves.easeOutQuint,
          outCurve: Curves.easeInQuint,
          animationConfig: animationConfig,
          enterAnimations: enterAnimations,
          exitAnimations: exitAnimations,
        );
      },
      alignment: alignment,
    );

    navigatorState.push(
      dialogRoute,
    );
    return DialogOverlayCompleter(dialogRoute);
  }
}

class FullScreenDialogOverlayHandler extends OverlayHandler {
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
    PopoverAnimationConfig? animationConfig,
    List<PopoverAnimationType>? enterAnimations,
    List<PopoverAnimationType>? exitAnimations,
  }) {
    // Default fullscreen dialog settings
    final DialogAnimationType animationType = DialogAnimationType.fade;
    final bool avoidKeyboard = false;
    DialogAccessibility? accessibility;

    // Create DialogStyle from margin if provided
    final dialogStyle = margin != null ? DialogStyle(margin: margin) : null;

    // Convert the key to a GlobalKey<OverlayHandlerStateMixin> if needed
    GlobalKey<OverlayHandlerStateMixin>? dialogKey;
    if (key is GlobalKey<OverlayHandlerStateMixin>) {
      dialogKey = key;
    } else if (key != null) {
      // Create a new key if necessary
      dialogKey = GlobalKey<OverlayHandlerStateMixin>();
    }

    var navigatorState = Navigator.of(
      context,
      rootNavigator: rootOverlay,
    );
    final CapturedThemes themes =
        InheritedTheme.capture(from: context, to: navigatorState.context);
    final CapturedData data =
        Data.capture(from: context, to: navigatorState.context);

    var dialogRoute = EnhancedDialogRoute<T>(
      context: context,
      fullScreen: true,
      builder: (context) {
        final surfaceOpacity = 0.14;
        var child = _DialogOverlayWrapper(
          route: ModalRoute.of(context) as EnhancedDialogRoute<T>,
          avoidKeyboard: avoidKeyboard,
          accessibility: accessibility,
          child: Builder(builder: (context) {
            return builder(context);
          }),
        );

        if (overlayBarrier != null) {
          return MultiModel(
            data: const [
              Model(#shadcn_flutter_dialog_overlay, true),
            ],
            child: ModalBackdrop(
              modal: modal,
              avoidKeyboard: avoidKeyboard,
              surfaceClip: ModalBackdrop.shouldClipSurface(surfaceOpacity),
              borderRadius: overlayBarrier.borderRadius,
              padding: overlayBarrier.padding,
              barrierColor: overlayBarrier.barrierColor ??
                  const Color.fromRGBO(0, 0, 0, 0.8),
              child: child,
            ),
          );
        }

        return MultiModel(
          data: const [
            Model(#shadcn_flutter_dialog_overlay, true),
          ],
          child: child,
        );
      },
      themes: themes,
      barrierDismissible: barrierDismissable,
      barrierColor: overlayBarrier == null
          ? const Color.fromRGBO(0, 0, 0, 0.8)
          : Colors.transparent,
      barrierLabel: 'Dismiss',
      useSafeArea: true,
      data: data,
      accessibility: accessibility,
      animationType: animationType,
      transitionDuration: showDuration ?? const Duration(milliseconds: 300),
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      // Integrated popover properties
      animationConfig: animationConfig,
      enterAnimations: enterAnimations,
      exitAnimations: exitAnimations,
      widthConstraint: widthConstraint,
      heightConstraint: heightConstraint,
      fixedSize: fixedSize,
      layerLink: layerLink,
      offset: offset,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      anchorAlignment: anchorAlignment,
      dialogKey: dialogKey,
      dialogStyle: dialogStyle,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _buildUnifiedDialogTransition(
          context,
          animation,
          secondaryAnimation,
          child,
          animationType: animationType,
          alignment: alignment,
          transitionAlignment: transitionAlignment,
          fullScreen: true,
          inCurve: Curves.easeOutQuint,
          outCurve: Curves.easeInQuint,
          animationConfig: animationConfig,
          enterAnimations: enterAnimations,
          exitAnimations: exitAnimations,
        );
      },
      alignment: alignment,
    );

    navigatorState.push(
      dialogRoute,
    );
    return DialogOverlayCompleter(dialogRoute);
  }
}

class DialogOverlayCompleter<T> extends OverlayCompleter<T> {
  final EnhancedDialogRoute<T> route;

  DialogOverlayCompleter(this.route);

  @override
  Future<void> get animationFuture => route.completed;

  @override
  void dispose() {
    route.dispose();
  }

  @override
  Future<T> get future => route.popped.then((value) {
        return value as T;
      });

  @override
  bool get isAnimationCompleted => route.animation?.isCompleted ?? true;

  @override
  bool get isCompleted => route.animation?.isCompleted ?? true;

  @override
  void remove() {
    if (route.isCurrent) {
      if (route.navigator?.canPop() ?? false) {
        route.navigator?.pop();
      }
    } else if (route.isActive) {
      route.navigator?.removeRoute(route);
    }
  }
}

class _DialogOverlayWrapper<T> extends StatefulWidget {
  final EnhancedDialogRoute<T> route;
  final Widget child;
  final VoidCallback? onBackdropTap;
  final bool avoidKeyboard;
  final DialogAccessibility? accessibility;

  const _DialogOverlayWrapper({
    super.key,
    required this.route,
    required this.child,
    this.onBackdropTap,
    this.avoidKeyboard = true,
    this.accessibility,
  });

  @override
  State<_DialogOverlayWrapper<T>> createState() =>
      _DialogOverlayWrapperState<T>();
}

class _DialogOverlayWrapperState<T> extends State<_DialogOverlayWrapper<T>>
    with OverlayHandlerStateMixin {
  // Implementation of methods required by OverlayHandlerStateMixin
  @override
  set alignment(AlignmentGeometry value) {
    // Dialog doesn't use alignment like popover
    // Dummy implementation
  }

  @override
  set anchorAlignment(AlignmentGeometry value) {
    // Dialog doesn't use anchorAlignment like popover
    // Dummy implementation
  }

  @override
  set anchorContext(BuildContext value) {
    // Dialog doesn't use anchorContext like popover
    // Dummy implementation
  }

  @override
  set widthConstraint(PopoverConstraint value) {
    // Dialog doesn't use widthConstraint like popover
    // Dummy implementation
  }

  @override
  set heightConstraint(PopoverConstraint value) {
    // Dialog doesn't use heightConstraint like popover
    // Dummy implementation
  }

  @override
  set margin(EdgeInsetsGeometry value) {
    // Dialog doesn't use margin like popover
    // Dummy implementation
  }

  @override
  set follow(bool value) {
    // Dialog doesn't use follow like popover
    // Dummy implementation
  }

  @override
  set offset(Offset? value) {
    // Dialog doesn't use offset like popover
    // Dummy implementation
  }

  @override
  set allowInvertHorizontal(bool value) {
    // Dialog doesn't use allowInvertHorizontal like popover
    // Dummy implementation
  }

  @override
  set allowInvertVertical(bool value) {
    // Dialog doesn't use allowInvertVertical like popover
    // Dummy implementation
  }

  @override
  Widget build(BuildContext context) {
    return Data<OverlayHandlerStateMixin>.inherit(
      data: this,
      child: DialogFocusTrap(
        trapFocus: widget.accessibility?.trapFocus ?? true,
        escDismissible: widget.accessibility?.escDismissible ?? true,
        onDismiss: handleBackdropTap,
        child: widget.child,
      ),
    );
  }

  @override
  Future<void> close([bool immediate = false]) {
    if (!mounted) return Future.value();
    if (immediate || !widget.route.isCurrent) {
      widget.route.navigator?.removeRoute(widget.route);
    } else {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pop();
      }
      widget.route.navigator?.pop();
    }
    return widget.route.completed;
  }

  @override
  void closeLater() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.route.isCurrent) {
        widget.route.navigator?.pop();
      } else {
        widget.route.navigator?.removeRoute(widget.route);
      }
    });
  }

  @override
  Future<void> closeWithResult<X>([X? value]) {
    if (widget.route.isCurrent) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pop(value);
      }
      widget.route.navigator?.pop(value);
    } else {
      widget.route.navigator?.removeRoute(widget.route);
    }
    return widget.route.completed;
  }

  void handleBackdropTap() {
    if (widget.onBackdropTap != null) {
      widget.onBackdropTap!();
    } else if (widget.route.barrierDismissible) {
      close();
    }
  }
}

/// Enhanced showDialog function with extensive customization options
Future<T?> showDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  AlignmentGeometry? alignment,
  AlignmentGeometry? anchorAlignment,
  bool fullScreen = false,
  DialogAnimationType animationType = DialogAnimationType.scale,
  AlignmentGeometry? transitionAlignment,
  Curve inCurve = Curves.easeOutQuint,
  Curve outCurve = Curves.easeInQuint,
  Duration? transitionDuration,
  bool avoidKeyboard = true,
  VoidCallback? onBackdropTap,
  DialogAccessibility? accessibility,
  // Integrated popover properties
  PopoverAnimationConfig? animationConfig,
  List<PopoverAnimationType>? enterAnimations,
  List<PopoverAnimationType>? exitAnimations,
  PopoverConstraint widthConstraint = PopoverConstraint.flexible,
  PopoverConstraint heightConstraint = PopoverConstraint.flexible,
  DialogSizeConfig? sizeConfig,
  Size? fixedSize,
  LayerLink? layerLink,
  Offset? offset,
  bool allowInvertHorizontal = true,
  bool allowInvertVertical = true,
  GlobalKey<OverlayHandlerStateMixin>? dialogKey,
  DialogController? dialogController,
  // New visual styling options
  DialogStyle? dialogStyle,
  Color? dialogBackgroundColor,
  BorderRadius? dialogBorderRadius,
  EdgeInsetsGeometry? dialogMargin,
  EdgeInsetsGeometry? dialogPadding,
  double? dialogElevation,
  Color? dialogBorderColor,
  double? dialogBorderWidth,
  Clip? dialogClipBehavior,
  List<BoxShadow>? dialogBoxShadow,
  double? dialogSurfaceOpacity,
  double? dialogSurfaceBlur,
}) {
  var navigatorState = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );

  final CapturedThemes themes =
      InheritedTheme.capture(from: context, to: navigatorState.context);
  final CapturedData data =
      Data.capture(from: context, to: navigatorState.context);

  final duration = transitionDuration ?? const Duration(milliseconds: 200);
  final effectiveAlignment = alignment ?? Alignment.center;

  // Create combined DialogStyle from all styling parameters
  final effectiveDialogStyle = (dialogStyle ?? const DialogStyle()).copyWith(
    backgroundColor: dialogBackgroundColor,
    borderRadius: dialogBorderRadius,
    margin: dialogMargin,
    padding: dialogPadding,
    elevation: dialogElevation,
    borderColor: dialogBorderColor,
    borderWidth: dialogBorderWidth,
    clipBehavior: dialogClipBehavior,
    boxShadow: dialogBoxShadow,
    surfaceOpacity: dialogSurfaceOpacity,
    surfaceBlur: dialogSurfaceBlur,
  );

  // Create a wrapper for the dialog content that adds dismiss capability
  Widget dialogWrapper(BuildContext context) {
    final route = ModalRoute.of(context) as EnhancedDialogRoute<T>;

    return Builder(builder: (innerContext) {
      // Create the original content
      final originalContent = builder(innerContext);

      // Determine size config based on parameters
      final effectiveSizeConfig = sizeConfig ??
          DialogSizeConfig(
            widthConstraint: widthConstraint,
            heightConstraint: heightConstraint,
            fixedSize: fixedSize,
            avoidKeyboard: avoidKeyboard,
          );

      // Add a wrapper for handling ESC key and focus trapping
      return ModalContainer(
        accessibility: accessibility,
        onDismiss: () {
          // Handle ESC key dismiss
          if ((accessibility?.escDismissible ?? true) && route.isCurrent) {
            Navigator.of(innerContext).pop();
          }
        },
        sizeConfig: effectiveSizeConfig,
        dialogStyle: effectiveDialogStyle,
        // Integrated popover positioning properties
        alignment: effectiveAlignment as Alignment?,
        anchorAlignment: anchorAlignment as Alignment?,
        position: anchorPoint,
        offset: offset,
        layerLink: layerLink,
        allowInvertHorizontal: allowInvertHorizontal,
        allowInvertVertical: allowInvertVertical,
        child: originalContent,
      );
    });
  }

  // Create dialog route with unified animation approach
  var dialogRoute = EnhancedDialogRoute<T>(
    context: context,
    builder: dialogWrapper,
    themes: themes,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? const Color.fromRGBO(0, 0, 0, 0.5),
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    anchorPoint: anchorPoint,
    data: data,
    accessibility: accessibility,
    traversalEdgeBehavior:
        traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
    animationType: animationType,
    inCurve: inCurve,
    outCurve: outCurve,
    transitionDuration: duration,
    // Integrated popover properties
    animationConfig: animationConfig,
    enterAnimations: enterAnimations,
    exitAnimations: exitAnimations,
    widthConstraint: widthConstraint,
    heightConstraint: heightConstraint,
    fixedSize: fixedSize,
    layerLink: layerLink,
    offset: offset,
    allowInvertHorizontal: allowInvertHorizontal,
    allowInvertVertical: allowInvertVertical,
    anchorAlignment: anchorAlignment,
    dialogKey: dialogKey,
    dialogController: dialogController,
    dialogStyle: effectiveDialogStyle,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return _buildUnifiedDialogTransition(
        context,
        animation,
        secondaryAnimation,
        child,
        animationType: animationType,
        alignment: effectiveAlignment,
        transitionAlignment: transitionAlignment,
        fullScreen: fullScreen,
        inCurve: inCurve,
        outCurve: outCurve,
        animationConfig: animationConfig,
        enterAnimations: enterAnimations,
        exitAnimations: exitAnimations,
      );
    },
    alignment: effectiveAlignment,
  );

  // Push the route and get result
  final Future<T?> result = navigatorState.push(dialogRoute);

  // If using controller, register the dialog
  if (dialogController != null && dialogKey != null) {
    final dialog = Dialog._(dialogKey, DialogOverlayCompleter(dialogRoute));
    dialogController._registerDialog(dialog);
  }

  return result;
}

/// Function to close overlay from any context - works with both dialogs and popovers
Future<void> closeOverlayWithResult<T>(BuildContext context, [T? value]) async {
  final handler = Data.maybeFind<OverlayHandlerStateMixin>(context);
  if (handler != null) {
    await handler.closeWithResult<T>(value);
    return;
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop(value);
    return;
  }

  final dialogController = DialogController();
  if (dialogController.hasOpenDialog) {
    await dialogController.closeLastDialog();
    return;
  }

  final popoverManager = OverlayManager.maybeOf(context);
  if (popoverManager != null) {
    await popoverManager.closeLastOverlay();
    return;
  }
}
