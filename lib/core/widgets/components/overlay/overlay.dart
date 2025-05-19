/// {@template overlay_library}
/// # Overlay System for Flutter
///
/// A powerful and flexible overlay management system for Flutter applications.
/// This library provides a unified API to show popovers, tooltips, menus, and custom overlays,
/// making it easy to manage overlay widgets, modal dialogs, popups, and more—
/// all with advanced alignment, animation, and interaction options.
///
/// ## Features
/// - Unified interface for popovers, tooltips, and menus
/// - Fine-grained control over positioning, alignment, and constraints
/// - Modal and non-modal overlays
/// - Barrier customization (color, radius, dismiss behavior)
/// - Anchor/follow behavior for dynamic widgets
/// - Overlay state management and completion futures
/// - LayerLink and region grouping for advanced use-cases
///
/// ## Basic Example
/// ```dart
/// // To show a popover overlay:
/// OverlayManager.of(context).show(
///   context: context,
///   builder: (context) => MyPopoverContent(),
///   alignment: Alignment.topCenter,
/// );
/// ```
///
/// ## Layer Integration
/// Wrap your app or part of your widget tree with [OverlayManagerLayer] to provide overlay context:
/// ```dart
/// OverlayManagerLayer(
///   popoverHandler: MyPopoverHandler(),
///   tooltipHandler: MyTooltipHandler(),
///   menuHandler: MyMenuHandler(),
///   child: MyApp(),
/// )
/// ```
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:data_widget/data_widget.dart';
import 'popover.dart';

/// Closes any open overlay managed by [OverlayHandlerStateMixin] within the widget tree.
///
/// This utility will find the nearest [OverlayHandlerStateMixin] in the widget context
/// and close it, optionally returning a value.
///
/// {@template close_overlay_example}
/// ## Example
/// ```dart
/// // Close overlay and return a result
/// await closeOverlay(context, resultValue);
/// ```
/// {@endtemplate}
Future<void> closeOverlay<T>(BuildContext context, [T? value]) {
  return Data.maybeFind<OverlayHandlerStateMixin>(context)
          ?.closeWithResult(value) ??
      Future.value();
}

/// {@template overlay_handler_state_mixin}
/// # OverlayHandlerStateMixin
///
/// Mixin for overlay-capable widgets to manage closing, alignment, and constraints.
///
/// Provides methods and setters for manipulating overlay positioning, alignment,
/// margin, and state transitions.
///
/// Implement this mixin in your overlay widget's State class for advanced overlay control.
///
/// ## Example
/// ```dart
/// class MyPopoverState extends State<MyPopoverWidget> with OverlayHandlerStateMixin<MyPopoverWidget> {
///   // Implement abstract members...
/// }
/// ```
///
/// ---
///
/// ## API Reference & Usage
///
/// ### 1. Closing the Overlay
///
/// #### close([immediate = false])
/// Closes the overlay. If [immediate] is true, closes without animation.
/// ```dart
/// // Instantly close overlay (no animation)
/// await close(true);
///
/// // Close with animation (default)
/// await close();
/// ```
///
/// #### closeLater()
/// Schedules the overlay to close after a short delay (e.g., after animation or user interaction).
/// ```dart
/// closeLater();
/// ```
///
/// #### closeWithResult`<`X`>`([X? value])
/// Closes the overlay and returns a result value (useful for pickers/dialogs).
/// ```dart
/// await closeWithResult<String>('picked value');
/// ```
///
/// ---
///
/// ### 2. Anchor and Alignment
///
/// #### anchorContext = BuildContext
/// Sets the anchor widget/context for positioning the overlay.
/// ```dart
/// anchorContext = myAnchorContext;
/// ```
///
/// #### alignment = AlignmentGeometry
/// Sets the overlay's own alignment relative to its anchor.
/// ```dart
/// alignment = Alignment.bottomCenter;
/// ```
///
/// #### anchorAlignment = AlignmentGeometry
/// Sets the anchor's alignment point for overlay positioning.
/// ```dart
/// anchorAlignment = Alignment.topCenter;
/// ```
///
/// ---
///
/// ### 3. Size Constraints
///
/// #### widthConstraint = PopoverConstraint
/// Sets the width constraint for the overlay (min/max/fixed).
/// ```dart
/// widthConstraint = PopoverConstraint.fixed(240);
/// ```
///
/// #### heightConstraint = PopoverConstraint
/// Sets the height constraint for the overlay.
/// ```dart
/// heightConstraint = PopoverConstraint.max(400);
/// ```
///
/// ---
///
/// ### 4. Margin, Offset, and Following
///
/// #### margin = EdgeInsets
/// Sets the margin around the overlay.
/// ```dart
/// margin = EdgeInsets.all(8);
/// ```
///
/// #### offset = Offset?
/// Adds a custom offset to the overlay position (relative to anchor).
/// ```dart
/// offset = Offset(0, 12);
/// ```
///
/// #### follow = bool
/// If true, overlay follows its anchor during layout changes or scrolling.
/// ```dart
/// follow = true;
/// ```
///
/// ---
///
/// ### 5. Overflow Handling (Inversion)
///
/// #### allowInvertHorizontal = bool
/// Allows overlay to flip horizontally if not enough space.
/// ```dart
/// allowInvertHorizontal = true;
/// ```
///
/// #### allowInvertVertical = bool
/// Allows overlay to flip vertically when needed.
/// ```dart
/// allowInvertVertical = true;
/// ```
///
/// ---
///
/// ## Typical Usage Example
/// ```dart
/// class MyPopoverState extends State<MyPopoverWidget> with OverlayHandlerStateMixin<MyPopoverWidget> {
///   @override
///   void initState() {
///     super.initState();
///     anchorContext = widget.anchorContext;
///     alignment = Alignment.bottomCenter;
///     anchorAlignment = Alignment.topCenter;
///     widthConstraint = PopoverConstraint.max(300);
///     margin = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
///     follow = true;
///   }
///
///   void closePopover() => close();
/// }
/// ```
/// {@endtemplate}
mixin OverlayHandlerStateMixin<T extends StatefulWidget> on State<T> {
  /// Request the overlay to close.
  ///
  /// * [immediate]: If true, closes instantly without animation.
  ///
  /// ---
  /// **Usage:**
  /// ```dart
  /// await close();           // Close with animation (default)
  /// await close(true);       // Instantly close overlay (no animation)
  /// ```
  Future<void> close([bool immediate = false]);

  /// Request the overlay to close after a short delay.
  ///
  /// ---
  /// **Usage:**
  /// ```dart
  /// closeLater();
  /// ```
  void closeLater();

  /// Closes the overlay and optionally returns a value to the caller.
  ///
  /// * [value]: Value to return to the overlay's completion future.
  ///
  /// ---
  /// **Usage:**
  /// ```dart
  /// await closeWithResult<String>('picked value');
  /// ```
  Future<void> closeWithResult<X>([X? value]);

  /// Set the anchor context for alignment.
  ///
  /// ---
  /// **Usage:** Set the context of the anchor widget for overlay positioning.
  /// ```dart
  /// anchorContext = myAnchorContext;
  /// ```
  set anchorContext(BuildContext value) {}

  /// Set the overlay's main alignment.
  ///
  /// ---
  /// **Usage:** Controls how the overlay aligns relative to its anchor.
  /// ```dart
  /// alignment = Alignment.bottomCenter;
  /// ```
  set alignment(AlignmentGeometry value) {}

  /// Set the anchor's alignment.
  ///
  /// ---
  /// **Usage:** Controls which point on the anchor is used for positioning.
  /// ```dart
  /// anchorAlignment = Alignment.topCenter;
  /// ```
  set anchorAlignment(AlignmentGeometry value) {}

  /// Set width constraint for the overlay.
  ///
  /// ---
  /// **Usage:** Restrict the overlay's width.
  /// ```dart
  /// widthConstraint = PopoverConstraint.max;
  /// ```
  set widthConstraint(PopoverConstraint value) {}

  /// Set height constraint for the overlay.
  ///
  /// ---
  /// **Usage:** Restrict the overlay's height.
  /// ```dart
  /// heightConstraint = PopoverConstraint.fixed(350);
  /// ```
  set heightConstraint(PopoverConstraint value) {}

  /// Set margin around the overlay.
  ///
  /// ---
  /// **Usage:** Add spacing around the overlay.
  /// ```dart
  /// margin = EdgeInsets.all(12);
  /// ```
  set margin(EdgeInsets value) {}

  /// Whether the overlay should follow its anchor.
  ///
  /// ---
  /// **Usage:** Overlay follows anchor during scroll or layout changes.
  /// ```dart
  /// follow = true;
  /// ```
  set follow(bool value) {}

  /// Set a custom offset for the overlay position.
  ///
  /// ---
  /// **Usage:** Add pixel offset to overlay position.
  /// ```dart
  /// offset = Offset(0, 16);
  /// ```
  set offset(Offset? value) {}

  /// Allow horizontal inversion for overflow handling.
  ///
  /// ---
  /// **Usage:** Flip overlay horizontally when overflowing.
  /// ```dart
  /// allowInvertHorizontal = true;
  /// ```
  set allowInvertHorizontal(bool value) {}

  /// Allow vertical inversion for overflow handling.
  ///
  /// ---
  /// **Usage:** Flip overlay vertically when overflowing.
  /// ```dart
  /// allowInvertVertical = true;
  /// ```
  set allowInvertVertical(bool value) {}
}

/// {@template overlay_completer}
/// # OverlayCompleter
///
/// A handle returned by [OverlayHandler.show] or [OverlayManager.show] for managing the lifecycle, result,
/// and animation state of an overlay entry (such as dialogs, snackbars, toasts, popovers, drawers, etc).
///
/// Use this object to:
/// - **Programmatically close or remove** the overlay at any time
/// - **Dispose** any resources associated with the overlay
/// - **Check completion state** (whether the overlay has finished or been dismissed)
/// - **Await result and animation** via futures
///
/// ---
/// ## Usage Overview
///
/// ```dart
/// // Show an overlay and obtain a completer
/// final completer = OverlayManager.of(context).show<MyResultType>(
///   builder: (context) => MyOverlayWidget(),
/// );
///
/// // Await the overlay's result (completes when closed)
/// final result = await completer.future;
///
/// // Remove/dismiss the overlay early
/// completer.remove();
///
/// // Dispose overlay resources (if not auto-disposed)
/// completer.dispose();
///
/// // Check if overlay was already completed (dismissed or closed)
/// if (completer.isCompleted) { ... }
///
/// // Await animation finish (useful for chaining UI transitions)
/// await completer.animationFuture;
/// ```
///
/// ---
/// ## API Details
///
/// - **remove()**: Immediately removes the overlay from view.
///   Use when you need to force-close the overlay programmatically (e.g., on timeout, navigation, etc).
///
/// - **dispose()**: Releases any resources associated with the overlay.
///   Call if your overlay manages custom resources or listeners. Usually called automatically.
///
/// - **isCompleted**: `true` if the overlay has already been closed and its result delivered.
///   Useful to prevent double-closing or for safe logic chaining.
///
/// - **isAnimationCompleted**: `true` if the exit (hide) animation has finished.
///   Use to sequence animations or UI transitions after overlay disappears.
///
/// - **future**: Completes with the result value (if any) when the overlay is closed or dismissed.
///   Await to get the return value (similar to how [showDialog] returns a value).
///
/// - **animationFuture**: Completes when the overlay's exit animation is done.
///   Await to chain UI changes after the overlay visually disappears (good for snackbars, toasts, etc).
///
/// ---
/// ## Example: Manual Control
///
/// ```dart
/// final completer = OverlayManager.of(context).show<String>(
///   builder: (context) => MyDialog(),
/// );
///
/// // Wait for result (user pressed confirm/cancel)
/// final result = await completer.future;
///
/// // Or programmatically remove:
/// completer.remove();
///
/// // Optional: Wait until exit animation completes (before showing new overlay)
/// await completer.animationFuture;
/// ```
///
/// ---
/// ## Example: Checking State
///
/// ```dart
/// if (!completer.isCompleted) {
///   completer.remove(); // Only remove if still open
/// }
/// ```
///
/// ---
/// ## Example: Disposing (Advanced)
///
/// ```dart
/// completer.dispose();
/// ```
///
/// ---
/// {@endtemplate}
abstract class OverlayCompleter<T> {
  /// Remove the overlay from the UI immediately.
  void remove();

  /// Dispose resources associated with the overlay.
  void dispose();

  /// Whether the overlay's result has been completed.
  bool get isCompleted;

  /// Whether the overlay's exit animation is completed.
  bool get isAnimationCompleted;

  /// A future that completes with the overlay's result value.
  Future<T?> get future;

  /// A future that completes when the overlay's animation completes.
  Future<void> get animationFuture;
}

/// {@template overlay_handler}
/// # OverlayHandler
///
/// Base class for overlay managers. Provides the common API for showing overlays
/// (popover, tooltip, menu) with configuration for alignment, constraints, barrier, etc.
///
/// You can create custom handlers for popovers, tooltips, or menus by implementing this class.
///
/// ## Example
/// ```dart
/// class MyPopoverHandler extends OverlayHandler { ... }
/// ```
/// {@endtemplate}
abstract class OverlayHandler {
  /// Const constructor for overlay handler.
  const OverlayHandler();

  /// Shows an overlay (popover, tooltip, menu) with the given configuration.
  ///
  /// Returns an [OverlayCompleter] that can be used to await the result or remove the overlay.
  ///
  /// {@template overlay_handler_show_example}
  /// ## Example
  /// ```dart
  /// OverlayManager.of(context).show(
  ///   context: context,
  ///   builder: (ctx) => MyOverlayContent(),
  ///   alignment: Alignment.topCenter,
  /// );
  /// ```
  /// {@endtemplate}
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
  });
}

/// {@template overlay_barrier}
/// # OverlayBarrier
///
/// Defines the barrier/background around an overlay (such as a modal or popover).
///
/// Allows customization of visual appearance and touch interaction.
///
/// ## Example
/// ```dart
/// OverlayBarrier(
///   padding: EdgeInsets.all(8),
///   borderRadius: BorderRadius.circular(16),
///   barrierColor: Colors.black.withOpacity(0.2),
/// )
/// ```
/// {@endtemplate}
class OverlayBarrier {
  /// Padding around the overlay barrier.
  ///
  /// *Type*: `EdgeInsetsGeometry`
  ///
  /// - Default: `EdgeInsets.zero`
  /// - Example: `padding: EdgeInsets.all(8)`
  final EdgeInsetsGeometry padding;

  /// Border radius for the overlay barrier.
  ///
  /// *Type*: `BorderRadiusGeometry`
  ///
  /// - Default: `BorderRadius.zero`
  /// - Example: `borderRadius: BorderRadius.circular(16)`
  final BorderRadiusGeometry borderRadius;

  /// The color of the overlay barrier.
  ///
  /// *Type*: `Color?`
  ///
  /// - Default: `null` (transparent)
  /// - Example: `barrierColor: Colors.black54`
  final Color? barrierColor;

  /// Creates an [OverlayBarrier] with the provided configuration.
  const OverlayBarrier({
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.barrierColor,
  });
}

/// {@template overlay_manager}
/// # OverlayManager
///
/// Central overlay management interface. Use [OverlayManager.of] to access the manager from a widget context.
///
/// Provides methods to show popovers, tooltips, and menus with unified configuration.
///
/// ## Accessing the Manager
/// ```dart
/// // Obtain the overlay manager from context
/// final overlayManager = OverlayManager.of(context);
/// ```
///
/// ## Showing an Overlay
/// ```dart
/// overlayManager.show(
///   context: context,
///   builder: (context) => MyPopoverContent(),
///   alignment: Alignment.bottomLeft,
/// );
/// ```
/// {@endtemplate}
abstract class OverlayManager implements OverlayHandler {
  /// Returns the nearest [OverlayManager] in the widget tree.
  ///
  /// Throws an assertion error if none is found.
  ///
  /// *Example:*
  /// ```dart
  /// OverlayManager.of(context).show(...);
  /// ```
  static OverlayManager of(BuildContext context) {
    var manager = Data.maybeOf<OverlayManager>(context);
    assert(manager != null, 'No OverlayManager found in context');
    return manager!;
  }

  /// {@macro overlay_handler_show_example}
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
  });

  /// Shows a tooltip overlay.
  ///
  /// Same parameters as [show], but intended for tooltip presentation.
  OverlayCompleter<T?> showTooltip<T>({
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
  });

  /// Shows a menu overlay.
  ///
  /// Same parameters as [show], but intended for menus/popups.
  OverlayCompleter<T?> showMenu<T>({
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
  });
}

/// {@template overlay_manager_layer}
/// # OverlayManagerLayer
///
/// The widget to place at the root of your app or any subtree to provide [OverlayManager] context and handlers.
///
/// Use this to inject your popover, tooltip, and menu handlers for unified overlay management.
///
/// ## Example
/// ```dart
/// OverlayManagerLayer(
///   popoverHandler: MyPopoverHandler(),
///   tooltipHandler: MyTooltipHandler(),
///   menuHandler: MyMenuHandler(),
///   child: MyApp(),
/// )
/// ```
/// {@endtemplate}
class OverlayManagerLayer extends StatefulWidget {
  /// Handler for popover overlays.
  ///
  /// *Type*: `OverlayHandler`
  ///
  /// - Example: `popoverHandler: MyPopoverHandler()`
  final OverlayHandler popoverHandler;

  /// Handler for tooltip overlays.
  ///
  /// *Type*: `OverlayHandler`
  ///
  /// - Example: `tooltipHandler: MyTooltipHandler()`
  final OverlayHandler tooltipHandler;

  /// Handler for menu overlays.
  ///
  /// *Type*: `OverlayHandler`
  ///
  /// - Example: `menuHandler: MyMenuHandler()`
  final OverlayHandler menuHandler;

  /// The subtree to which this overlay manager applies.
  ///
  /// *Type*: `Widget`
  ///
  /// - Example: `child: MyApp()`
  final Widget child;

  /// Creates an [OverlayManagerLayer] with the given handlers and child.
  ///
  /// {@macro overlay_manager_layer}
  const OverlayManagerLayer({
    super.key,
    required this.popoverHandler,
    required this.tooltipHandler,
    required this.menuHandler,
    required this.child,
  });

  @override
  State<OverlayManagerLayer> createState() => _OverlayManagerLayerState();
}

class _OverlayManagerLayerState extends State<OverlayManagerLayer>
    implements OverlayManager {
  @override
  Widget build(BuildContext context) {
    return Data<OverlayManager>.inherit(
      data: this,
      child: widget.child,
    );
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
  }) {
    return widget.popoverHandler.show(
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
      showDuration: showDuration,
      dismissDuration: dismissDuration,
      overlayBarrier: overlayBarrier,
      layerLink: layerLink,
      fixedSize: fixedSize,
    );
  }

  @override
  OverlayCompleter<T?> showTooltip<T>({
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
  }) {
    return widget.tooltipHandler.show(
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
      showDuration: showDuration,
      dismissDuration: dismissDuration,
      overlayBarrier: overlayBarrier,
      layerLink: layerLink,
      fixedSize: fixedSize,
    );
  }

  @override
  OverlayCompleter<T?> showMenu<T>({
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
  }) {
    return widget.menuHandler.show(
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
      showDuration: showDuration,
      dismissDuration: dismissDuration,
      overlayBarrier: overlayBarrier,
      layerLink: layerLink,
      fixedSize: fixedSize,
    );
  }
}
