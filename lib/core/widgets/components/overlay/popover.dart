import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:data_widget/data_widget.dart';
import 'package:boilerplate/core/widgets/animation.dart';
import 'package:boilerplate/core/widgets/utils.dart';
import 'overlay.dart';

/// {@template popover_constraint}
/// # PopoverConstraint
///
/// Controls how popovers are sized relative to their content, anchor, or available space.
///
/// These constraints determine both width and height behavior, providing precise
/// control over how popovers adapt to different content and screen sizes.
///
/// ## Available Options
///
/// | Constraint | Description | Use Case |
/// |------------|-------------|----------|
/// | flexible | Adapts to content with system limits | General purpose popovers |
/// | intrinsic | Uses intrinsic content size | Text or form popovers |
/// | anchorFixedSize | Exactly matches anchor width/height | Dropdown replacements |
/// | anchorMinSize | Uses anchor size as minimum | Expandable tooltips |
/// | anchorMaxSize | Uses anchor size as maximum | Constrained dialogs |
/// | fixed | Uses exact size specified by developer | Precise design requirements |
/// | fullScreen | Expands to fill available screen | Modal dialogs, full menus |
/// | contentSize | Precisely follows content size | Custom widgets with known dimensions |
///
/// ## Usage Example
/// ```dart
/// OverlayManager.of(context).show(
///   context: context,
///   builder: (context) => MyPopoverContent(),
///   widthConstraint: PopoverConstraint.anchorMaxSize,
///   heightConstraint: PopoverConstraint.flexible,
/// );
/// ```
/// {@endtemplate}
enum PopoverConstraint {
  /// Adapts to content with system-defined max limits.
  ///
  /// *Behavior*: Popover sizes to fit content but won't exceed screen bounds.
  /// A default maximum width/height is applied to prevent excessive sizing.
  ///
  /// *Best for*: General-purpose popovers, tooltips, and most UI components
  /// where specific sizing isn't critical.
  flexible,

  /// Uses intrinsic content size without any constraints.
  ///
  /// *Behavior*: Allows content to determine its own natural size.
  /// This may result in clipping if content exceeds screen bounds.
  ///
  /// *Best for*: Simple text tooltips, small widgets with well-defined dimensions.
  intrinsic,

  /// Exactly matches anchor size (width or height).
  ///
  /// *Behavior*: Forces popover to be exactly the same size as its anchor widget.
  /// Content may need to adapt or scroll if it doesn't fit.
  ///
  /// *Best for*: Dropdown menus that replace their trigger widget, select inputs.
  anchorFixedSize,

  /// Uses anchor size as minimum (width or height).
  ///
  /// *Behavior*: Ensures popover is at least as large as its anchor,
  /// but allows expansion for content that requires more space.
  ///
  /// *Best for*: Expandable tooltips, dropdowns that may contain larger content.
  anchorMinSize,

  /// Uses anchor size as maximum (width or height).
  ///
  /// *Behavior*: Limits popover to be no larger than its anchor,
  /// potentially requiring scrolling for content that doesn't fit.
  ///
  /// *Best for*: Constrained menus, compact information displays.
  anchorMaxSize,

  /// Uses a fixed size defined by fixedSize parameter.
  ///
  /// *Behavior*: Forces exact dimensions regardless of content or anchor.
  /// Requires explicit width/height values to be provided.
  ///
  /// *Best for*: Components with strict design requirements, cards, panels.
  fixed,

  /// Expands to fill available screen (width or height).
  ///
  /// *Behavior*: Uses maximum available space while respecting safe areas.
  /// Useful for modal overlays or full-screen panels.
  ///
  /// *Best for*: Modal dialogs, full-screen menus, immersive UIs.
  fullScreen,

  /// Precisely follows content size (width or height).
  ///
  /// *Behavior*: Similar to intrinsic but with higher priority to respect
  /// content's preferred dimensions. May still clip if exceeding screen bounds.
  ///
  /// *Best for*: Custom widgets that need precise layout control.
  contentSize,
}

/// {@template popover_callbacks}
/// # Popover Callback Types
///
/// These specialized callback types are used throughout the popover system for
/// handling asynchronous operations and specific popover events.
///
/// - **FutureVoidCallback**: Simple asynchronous callback with no parameters
/// - **PopoverFutureVoidCallback**: Asynchronous callback that receives a value from a popover
///
/// ## Usage Example
/// ```dart
/// // Define a FutureVoidCallback
/// FutureVoidCallback closeAndRefresh = () async {
///   await closePopover();
///   await refreshData();
/// };
///
/// // Define a PopoverFutureVoidCallback
/// PopoverFutureVoidCallback<String> handleSelection = (value) async {
///   await saveSelection(value);
///   notifyListeners();
/// };
/// ```
/// {@endtemplate}
typedef FutureVoidCallback = Future<void> Function();
typedef PopoverFutureVoidCallback<T> = Future<void> Function(T value);

/// {@template popover_overlay_handler}
/// # PopoverOverlayHandler
///
/// A specialized handler for displaying popover overlays with advanced positioning,
/// alignment, animation, and interaction features.
///
/// This handler implements the [OverlayHandler] interface, providing a comprehensive
/// implementation for showing popovers anchored to specific widgets or positions on screen.
/// It handles complex positioning logic, size constraints, animations, barriers, and focus management.
///
/// ## Key Features
///
/// - **Precise Positioning**: Anchor popovers to widgets or exact coordinates
/// - **Automatic Alignment**: Smart alignment with configurability
/// - **Size Constraints**: Various sizing strategies (fixed, flexible, content-based)
/// - **Animation Effects**: Smooth entrance/exit with customizable durations
/// - **Modal or Non-modal**: Optional barrier with dismissal control
/// - **Follow Behavior**: Popovers can follow their anchor during scrolling
/// - **Overflow Protection**: Automatic repositioning when near screen edges
///
/// ## Basic Usage
/// ```dart
/// final handler = PopoverOverlayHandler();
/// handler.show(
///   context: context,
///   builder: (context) => MyPopoverContent(),
///   alignment: Alignment.bottomLeft,
/// );
/// ```
///
/// ## Usage with OverlayManager
/// ```dart
/// OverlayManagerLayer(
///   popoverHandler: PopoverOverlayHandler(),
///   tooltipHandler: MyTooltipHandler(),
///   menuHandler: MyMenuHandler(),
///   child: MyApp(),
/// )
/// ```
/// {@endtemplate}
class PopoverOverlayHandler extends OverlayHandler {
  /// {@template popover_overlay_handler_constructor}
  /// Creates a handler for showing popover overlays.
  ///
  /// Use this handler with [OverlayManager] to show popovers with consistent behavior.
  /// {@endtemplate}
  const PopoverOverlayHandler();

  /// {@template popover_overlay_handler_show}
  /// Shows a popover overlay with the given configuration.
  ///
  /// This comprehensive method handles all aspects of showing a popover, including
  /// positioning, animation, interaction, and dismissal. It returns an [OverlayCompleter]
  /// that can be used to await the result or dismiss the popover programmatically.
  ///
  /// ## Basic Usage
  /// ```dart
  /// final result = await PopoverOverlayHandler().show(
  ///   context: buttonContext,
  ///   builder: (context) => OptionsMenu(),
  ///   alignment: Alignment.bottomCenter,
  /// );
  /// ```
  ///
  /// ## Advanced Configuration
  /// ```dart
  /// final result = await PopoverOverlayHandler().show(
  ///   context: buttonContext,
  ///   builder: (context) => FilterOptions(initialFilter: currentFilter),
  ///   alignment: Alignment.topRight,
  ///   anchorAlignment: Alignment.bottomRight,
  ///   widthConstraint: PopoverConstraint.fixed,
  ///   heightConstraint: PopoverConstraint.flexible,
  ///   follow: true,
  ///   modal: true,
  ///   barrierDismissable: true,
  ///   margin: EdgeInsets.all(8),
  ///   offset: Offset(0, 4),
  ///   fixedSize: Size(250, null),
  /// );
  ///
  /// if (result != null) {
  ///   applyFilter(result);
  /// }
  /// ```
  ///
  /// ## Parameters
  /// {@endtemplate}
  @override
  OverlayCompleter<T> show<T>({
    /// {@template popover_context}
    /// The context from which to anchor the popover.
    ///
    /// *Type*: `BuildContext`
    ///
    /// This context is used to find the anchor widget's position and size.
    /// The popover will be anchored relative to this widget.
    ///
    /// *Example*: `context: buttonContext`
    /// {@endtemplate}
    required BuildContext context,

    /// {@template popover_alignment}
    /// The alignment of the popover relative to its anchor.
    ///
    /// *Type*: `AlignmentGeometry`
    ///
    /// Determines which edge or corner of the popover aligns with the anchor.
    /// Common values include:
    /// - `Alignment.bottomCenter` - Popover appears below anchor
    /// - `Alignment.topCenter` - Popover appears above anchor
    /// - `Alignment.centerLeft` - Popover appears to the left of anchor
    /// - `Alignment.centerRight` - Popover appears to the right of anchor
    ///
    /// *Default*: `Alignment.center`
    ///
    /// *Example*: `alignment: Alignment.bottomLeft`
    /// {@endtemplate}
    required AlignmentGeometry alignment,

    /// {@template popover_builder}
    /// The builder function for creating the popover content.
    ///
    /// *Type*: `WidgetBuilder`
    ///
    /// This function builds the content widget for the popover.
    /// It receives a [BuildContext] that allows closing the popover via [closeOverlay].
    ///
    /// *Example*:
    /// ```dart
    /// builder: (context) => MenuOptions(
    ///   onSelect: (option) {
    ///     handleOption(option);
    ///     closeOverlay(context, option);
    ///   },
    /// )
    /// ```
    /// {@endtemplate}
    required WidgetBuilder builder,

    /// {@template popover_position}
    /// Optional manual position for the popover on screen.
    ///
    /// *Type*: `ui.Offset?`
    ///
    /// When provided, overrides the automatic positioning from [context].
    /// Coordinates are in global screen space.
    ///
    /// If `null`, position is calculated from the anchor widget's position.
    ///
    /// *Example*: `position: Offset(100, 200)`
    /// {@endtemplate}
    ui.Offset? position,

    /// {@template popover_anchor_alignment}
    /// The alignment point on the anchor to which the popover is attached.
    ///
    /// *Type*: `AlignmentGeometry?`
    ///
    /// Determines which point on the anchor widget aligns with the popover.
    /// By default, this is the inverse of [alignment] to create natural pairings.
    ///
    /// Common pairs:
    /// - Popover below: `alignment: Alignment.topCenter, anchorAlignment: Alignment.bottomCenter`
    /// - Popover above: `alignment: Alignment.bottomCenter, anchorAlignment: Alignment.topCenter`
    ///
    /// If `null`, defaults to the inverse of [alignment].
    ///
    /// *Example*: `anchorAlignment: Alignment.topRight`
    /// {@endtemplate}
    AlignmentGeometry? anchorAlignment,

    /// {@template popover_width_constraint}
    /// How to constrain the popover's width.
    ///
    /// *Type*: `PopoverConstraint`
    ///
    /// Controls how the popover's width is determined relative to its content,
    /// anchor, or available space.
    ///
    /// *Default*: `PopoverConstraint.flexible`
    ///
    /// *Example*: `widthConstraint: PopoverConstraint.anchorMinSize`
    /// {@endtemplate}
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,

    /// {@template popover_height_constraint}
    /// How to constrain the popover's height.
    ///
    /// *Type*: `PopoverConstraint`
    ///
    /// Controls how the popover's height is determined relative to its content,
    /// anchor, or available space.
    ///
    /// *Default*: `PopoverConstraint.flexible`
    ///
    /// *Example*: `heightConstraint: PopoverConstraint.contentSize`
    /// {@endtemplate}
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,

    /// {@template popover_key}
    /// Optional key for the popover widget.
    ///
    /// *Type*: `Key?`
    ///
    /// Unique identifier for the popover widget, useful for testing or
    /// finding the widget in the tree.
    ///
    /// *Example*: `key: ValueKey('filter_popover')`
    /// {@endtemplate}
    Key? key,

    /// {@template popover_root_overlay}
    /// Whether to use the root overlay or the nearest one.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Use the root overlay (typically at app level)
    /// - `false`: Use the nearest overlay (e.g., within a Navigator)
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `rootOverlay: false`
    /// {@endtemplate}
    bool rootOverlay = true,

    /// {@template popover_modal}
    /// Whether the popover is modal (has a barrier).
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Display a barrier behind the popover that blocks interaction
    /// - `false`: Allow interaction with widgets behind the popover
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `modal: false`
    /// {@endtemplate}
    bool modal = true,

    /// {@template popover_barrier_dismissable}
    /// Whether tapping the barrier dismisses the popover.
    ///
    /// *Type*: `bool`
    ///
    /// Only applies when [modal] is `true`.
    ///
    /// - `true`: Tapping outside the popover closes it
    /// - `false`: Popover must be dismissed programmatically
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `barrierDismissable: false`
    /// {@endtemplate}
    bool barrierDismissable = true,

    /// {@template popover_clip_behavior}
    /// How to clip the popover's content.
    ///
    /// *Type*: `ui.Clip`
    ///
    /// Controls content clipping behavior:
    /// - `Clip.none`: No clipping (may overflow)
    /// - `Clip.hardEdge`: Fast, aliased clipping
    /// - `Clip.antiAlias`: Smooth-edged clipping
    /// - `Clip.antiAliasWithSaveLayer`: Highest quality (slowest)
    ///
    /// *Default*: `Clip.none`
    ///
    /// *Example*: `clipBehavior: Clip.antiAlias`
    /// {@endtemplate}
    ui.Clip clipBehavior = Clip.none,

    /// {@template popover_region_group_id}
    /// Optional identifier for grouping related popovers.
    ///
    /// *Type*: `Object?`
    ///
    /// When provided, popovers with the same ID may interact or coordinate
    /// with each other (e.g., only one popover in group may be open).
    ///
    /// *Example*: `regionGroupId: 'main_menu_popovers'`
    /// {@endtemplate}
    Object? regionGroupId,

    /// {@template popover_offset}
    /// Additional manual offset from calculated position.
    ///
    /// *Type*: `ui.Offset?`
    ///
    /// Fine-tune placement after automatic positioning is applied.
    /// Useful for small adjustments like adding margins.
    ///
    /// *Example*: `offset: Offset(0, 10)` // Move down by 10 pixels
    /// {@endtemplate}
    ui.Offset? offset,

    /// {@template popover_transition_alignment}
    /// Alignment for entrance transition effects.
    ///
    /// *Type*: `AlignmentGeometry?`
    ///
    /// Controls how the popover animates in (e.g., grows from top-left).
    /// If `null`, uses [alignment].
    ///
    /// *Example*: `transitionAlignment: Alignment.center`
    /// {@endtemplate}
    AlignmentGeometry? transitionAlignment,

    /// {@template popover_margin}
    /// Margin around the popover.
    ///
    /// *Type*: `EdgeInsetsGeometry?`
    ///
    /// Adds space around the popover, useful for providing breathing room
    /// between popover and anchor or screen edges.
    ///
    /// *Example*: `margin: EdgeInsets.all(8)`
    /// {@endtemplate}
    EdgeInsetsGeometry? margin,

    /// {@template popover_follow}
    /// Whether the popover follows its anchor when it moves.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Popover repositions when anchor moves (during scrolling, etc.)
    /// - `false`: Popover stays in initial position
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `follow: false`
    /// {@endtemplate}
    bool follow = true,

    /// {@template popover_consume_outside_taps}
    /// Whether taps outside the popover are consumed.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Taps outside popover are intercepted
    /// - `false`: Taps pass through to widgets behind
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `consumeOutsideTaps: false`
    /// {@endtemplate}
    bool consumeOutsideTaps = true,

    /// {@template popover_on_tick_follow}
    /// Callback fired on each frame when following anchor.
    ///
    /// *Type*: `ValueChanged<PopoverOverlayWidgetState>?`
    ///
    /// Advanced callback for custom logic during anchor following.
    /// Provides access to the popover's state on each tick.
    ///
    /// *Example*:
    /// ```dart
    /// onTickFollow: (state) {
    ///   customFollowLogic(state);
    /// }
    /// ```
    /// {@endtemplate}
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,

    /// {@template popover_allow_invert_horizontal}
    /// Whether the popover can flip horizontally when near screen edges.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Popover may invert horizontal alignment to fit on screen
    /// - `false`: Popover maintains original horizontal alignment
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `allowInvertHorizontal: false`
    /// {@endtemplate}
    bool allowInvertHorizontal = true,

    /// {@template popover_allow_invert_vertical}
    /// Whether the popover can flip vertically when near screen edges.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Popover may invert vertical alignment to fit on screen
    /// - `false`: Popover maintains original vertical alignment
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `allowInvertVertical: false`
    /// {@endtemplate}
    bool allowInvertVertical = true,

    /// {@template popover_dismiss_backdrop_focus}
    /// Whether to dismiss when backdrop gains focus.
    ///
    /// *Type*: `bool`
    ///
    /// - `true`: Popover closes if focus moves to barrier/backdrop
    /// - `false`: Focus shifting to backdrop doesn't affect popover
    ///
    /// *Default*: `true`
    ///
    /// *Example*: `dismissBackdropFocus: false`
    /// {@endtemplate}
    bool dismissBackdropFocus = true,

    /// {@template popover_show_duration}
    /// Duration for the entrance animation.
    ///
    /// *Type*: `Duration?`
    ///
    /// Controls how long the popover takes to appear.
    /// If `null`, uses system default (typically 150-300ms).
    ///
    /// *Example*: `showDuration: Duration(milliseconds: 200)`
    /// {@endtemplate}
    Duration? showDuration,

    /// {@template popover_dismiss_duration}
    /// Duration for the exit animation.
    ///
    /// *Type*: `Duration?`
    ///
    /// Controls how long the popover takes to disappear.
    /// If `null`, uses system default (typically 100-200ms).
    ///
    /// *Example*: `dismissDuration: Duration(milliseconds: 150)`
    /// {@endtemplate}
    Duration? dismissDuration,

    /// {@template popover_overlay_barrier}
    /// Custom configuration for the overlay barrier.
    ///
    /// *Type*: `OverlayBarrier?`
    ///
    /// Allows customizing the modal barrier's appearance and behavior.
    /// Only applies when [modal] is `true`.
    ///
    /// *Example*:
    /// ```dart
    /// overlayBarrier: OverlayBarrier(
    ///   padding: EdgeInsets.all(16),
    ///   borderRadius: BorderRadius.circular(8),
    ///   barrierColor: Colors.black54,
    /// )
    /// ```
    /// {@endtemplate}
    OverlayBarrier? overlayBarrier,

    /// {@template popover_layer_link}
    /// Optional layer link for advanced positioning scenarios.
    ///
    /// *Type*: `LayerLink?`
    ///
    /// For integrating with CompositedTransformTarget/Follower pattern.
    /// When provided, [follow] is automatically disabled.
    ///
    /// *Example*:
    /// ```dart
    /// final _layerLink = LayerLink();
    /// // Later in build:
    /// CompositedTransformTarget(
    ///   link: _layerLink,
    ///   child: anchorWidget,
    /// )
    /// // Then in show call:
    /// layerLink: _layerLink
    /// ```
    /// {@endtemplate}
    LayerLink? layerLink,

    /// {@template popover_fixed_size}
    /// Fixed size for the popover.
    ///
    /// *Type*: `Size?`
    ///
    /// Explicitly sets width and/or height.
    /// Only used when [widthConstraint] or [heightConstraint] is [PopoverConstraint.fixed].
    ///
    /// Set width or height to `null` to use content size for that dimension.
    ///
    /// *Example*: `fixedSize: Size(300, 400)`
    /// {@endtemplate}
    Size? fixedSize,
  }) {
    // Implementation remains the same
    // Resolve text direction and alignments
    final TextDirection textDirection = Directionality.of(context);
    final Alignment resolvedAlignment = alignment.resolve(textDirection);
    anchorAlignment ??= alignment * -1;
    final Alignment resolvedAnchorAlignment =
        anchorAlignment.resolve(textDirection);

    // Get overlay and capture themes
    final OverlayState overlay = Overlay.of(context, rootOverlay: rootOverlay);
    final themes = InheritedTheme.capture(from: context, to: overlay.context);
    final data = Data.capture(from: context, to: overlay.context);

    // Calculate position and anchor size if not provided
    Size? anchorSize;
    if (position == null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset pos = renderBox.localToGlobal(Offset.zero);
      anchorSize = renderBox.size;
      position = Offset(
        pos.dx +
            anchorSize.width / 2 +
            anchorSize.width / 2 * resolvedAnchorAlignment.x,
        pos.dy +
            anchorSize.height / 2 +
            anchorSize.height / 2 * resolvedAnchorAlignment.y,
      );
    }

    // Create overlay entry
    final OverlayPopoverEntry<T> popoverEntry = OverlayPopoverEntry<T>();
    final completer = popoverEntry.completer;
    final animationCompleter = popoverEntry.animationCompleter;
    final ValueNotifier<bool> isClosed = ValueNotifier<bool>(false);

    // Create barrier entry if modal
    OverlayEntry? barrierEntry;
    late OverlayEntry overlayEntry;

    if (modal) {
      barrierEntry = OverlayEntry(
        builder: (context) {
          return consumeOutsideTaps
              ? GestureDetector(
                  onTap: () {
                    if (!barrierDismissable || isClosed.value) return;
                    isClosed.value = true;
                    completer.complete();
                  },
                )
              : Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) {
                    if (!barrierDismissable || isClosed.value) return;
                    isClosed.value = true;
                    completer.complete();
                  },
                );
        },
      );
    }

    // Create main overlay entry
    overlayEntry = OverlayEntry(
      builder: (innerContext) {
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: isClosed,
            builder: (innerContext, child) {
              return FocusScope(
                autofocus: dismissBackdropFocus,
                canRequestFocus: !isClosed.value,
                child: AnimatedValueBuilder.animation(
                  value: isClosed.value ? 0.0 : 1.0,
                  initialValue: 0.0,
                  curve:
                      isClosed.value ? const Interval(0, 2 / 3) : Curves.linear,
                  duration: isClosed.value
                      ? (dismissDuration ?? const Duration(milliseconds: 100))
                      : (showDuration ?? kDefaultDuration),
                  onEnd: (value) {
                    if (value == 0.0 && isClosed.value) {
                      popoverEntry.remove();
                      popoverEntry.dispose();
                      animationCompleter.complete();
                    }
                  },
                  builder: (innerContext, animation) {
                    return PopoverOverlayWidget(
                      animation: animation,
                      onTapOutside: () {
                        if (isClosed.value) return;
                        if (!modal) {
                          isClosed.value = true;
                          completer.complete();
                        }
                      },
                      key: key,
                      anchorContext: context,
                      position: position!,
                      alignment: resolvedAlignment,
                      themes: themes,
                      builder: builder,
                      anchorSize: anchorSize,
                      anchorAlignment: resolvedAnchorAlignment,
                      widthConstraint: widthConstraint,
                      heightConstraint: heightConstraint,
                      regionGroupId: regionGroupId,
                      offset: offset,
                      transitionAlignment: transitionAlignment,
                      margin: margin,
                      follow: follow &&
                          layerLink ==
                              null, // Only follow if not using layerLink
                      consumeOutsideTaps: consumeOutsideTaps,
                      onTickFollow: onTickFollow,
                      allowInvertHorizontal: allowInvertHorizontal,
                      allowInvertVertical: allowInvertVertical,
                      data: data,
                      onClose: () {
                        if (isClosed.value) return Future.value();
                        isClosed.value = true;
                        completer.complete();
                        return animationCompleter.future;
                      },
                      onImmediateClose: () {
                        popoverEntry.remove();
                        completer.complete();
                      },
                      onCloseWithResult: (value) {
                        if (isClosed.value) return Future.value();
                        isClosed.value = true;
                        completer.complete(value as T);
                        return animationCompleter.future;
                      },
                      layerLink: layerLink,
                      fixedSize: fixedSize,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );

    // Initialize and insert overlay entries
    popoverEntry.initialize(overlayEntry, barrierEntry);
    if (barrierEntry != null) {
      overlay.insert(barrierEntry);
    }
    overlay.insert(overlayEntry);

    return popoverEntry;
  }
}

/// {@template popover_overlay_widget}
/// # PopoverOverlayWidget
///
/// A specialized widget that renders popover content with precise positioning,
/// alignment, and animation relative to an anchor element.
///
/// This widget handles the actual rendering of popover content inside the overlay system,
/// with support for automatic positioning, following anchors as they move, handling
/// screen edge detection, and animating transitions.
///
/// ## Key Features
///
/// - **Smart Positioning**: Automatically positions relative to an anchor with alignment control
/// - **Follow Behavior**: Tracks anchor movement during scrolling or layout changes
/// - **Boundary Detection**: Intelligently flips positioning when near screen edges
/// - **Animation Integration**: Smooth scale and fade animations for entrances and exits
/// - **Size Constraints**: Various sizing modes relative to content, anchor, or fixed dimensions
///
/// ## Usage Context
///
/// This widget is typically used internally by the [PopoverOverlayHandler] or [showPopover]
/// function rather than being created directly. For most use cases, use these higher-level APIs.
///
/// For advanced scenarios requiring custom overlay behavior, this widget can be used directly
/// within your own overlay implementation.
///
/// ## Example: Direct Usage (Advanced)
///
/// ```dart
/// OverlayEntry(
///   builder: (context) => PopoverOverlayWidget(
///     anchorContext: buttonContext,
///     position: anchorPosition,
///     alignment: Alignment.topCenter,
///     anchorAlignment: Alignment.bottomCenter,
///     animation: CurvedAnimation(
///       parent: _controller,
///       curve: Curves.easeOutQuad,
///     ),
///     builder: (context) => MyCustomPopoverContent(),
///     onClose: () async {
///       await _controller.reverse();
///     },
///   ),
/// )
/// ```
/// {@endtemplate}
class PopoverOverlayWidget extends StatefulWidget {
  /// {@template popover_position}
  /// The manual position for the popover.
  ///
  /// *Type*: `Offset?`
  ///
  /// Global screen coordinates where the popover should be positioned.
  /// If null and [anchorContext] is provided, position is calculated based on the anchor.
  ///
  /// *Example*: `position: Offset(100, 200)`
  /// {@endtemplate}
  final Offset? position;

  /// {@template popover_alignment}
  /// The alignment of the popover relative to its position.
  ///
  /// *Type*: `AlignmentGeometry`
  ///
  /// Controls which part of the popover aligns with the [position] or anchor point.
  /// For example, [Alignment.topCenter] places the top-center of the popover at the position.
  ///
  /// *Example*: `alignment: Alignment.bottomLeft`
  /// {@endtemplate}
  final AlignmentGeometry alignment;

  /// {@template popover_anchor_alignment}
  /// The alignment point on the anchor widget.
  ///
  /// *Type*: `AlignmentGeometry`
  ///
  /// Determines which point on the anchor is used as the attachment point.
  /// For example, [Alignment.bottomCenter] uses the bottom-center of the anchor.
  ///
  /// *Example*: `anchorAlignment: Alignment.topRight`
  /// {@endtemplate}
  final AlignmentGeometry anchorAlignment;

  /// {@template popover_themes}
  /// Captured themes from the anchor context.
  ///
  /// *Type*: `CapturedThemes?`
  ///
  /// Themes captured from the anchor widget's context to maintain consistent
  /// styling in the overlay.
  /// {@endtemplate}
  final CapturedThemes? themes;

  /// {@template popover_data}
  /// Captured inherited data from the anchor context.
  ///
  /// *Type*: `CapturedData?`
  ///
  /// Inherited data (like providers) captured from the anchor widget's context
  /// to maintain state access in the overlay.
  /// {@endtemplate}
  final CapturedData? data;

  /// {@template popover_builder}
  /// Builder function for the popover content.
  ///
  /// *Type*: `WidgetBuilder`
  ///
  /// Creates the content to display inside the popover.
  /// The provided context allows access to [OverlayHandlerStateMixin] for controlling the popover.
  ///
  /// *Example*:
  /// ```dart
  /// builder: (context) => MenuItems(
  ///   onSelect: (item) => closeOverlay(context, item),
  /// )
  /// ```
  /// {@endtemplate}
  final WidgetBuilder builder;

  /// {@template popover_anchor_size}
  /// The size of the anchor widget.
  ///
  /// *Type*: `Size?`
  ///
  /// Used for positioning calculations and constraints when using size-relative constraint modes.
  /// If null and [anchorContext] is provided, size is measured from the anchor widget.
  ///
  /// *Example*: `anchorSize: Size(100, 40)`
  /// {@endtemplate}
  final Size? anchorSize;

  /// {@template popover_animation}
  /// Animation controller for popover appearance.
  ///
  /// *Type*: `Animation<double>`
  ///
  /// Controls the scale and opacity animations.
  /// Typically ranges from 0.0 (invisible) to 1.0 (fully visible).
  ///
  /// *Example*: `animation: _controller.drive(CurveTween(curve: Curves.easeOut))`
  /// {@endtemplate}
  final Animation<double> animation;

  /// {@template popover_width_constraint}
  /// How to constrain the popover's width.
  ///
  /// *Type*: `PopoverConstraint`
  ///
  /// Determines how the width is calculated relative to content, anchor, or screen.
  /// See [PopoverConstraint] for available options.
  ///
  /// *Default*: `PopoverConstraint.flexible`
  ///
  /// *Example*: `widthConstraint: PopoverConstraint.anchorMinSize`
  /// {@endtemplate}
  final PopoverConstraint widthConstraint;

  /// {@template popover_height_constraint}
  /// How to constrain the popover's height.
  ///
  /// *Type*: `PopoverConstraint`
  ///
  /// Determines how the height is calculated relative to content, anchor, or screen.
  /// See [PopoverConstraint] for available options.
  ///
  /// *Default*: `PopoverConstraint.flexible`
  ///
  /// *Example*: `heightConstraint: PopoverConstraint.contentSize`
  /// {@endtemplate}
  final PopoverConstraint heightConstraint;

  /// {@template popover_on_close}
  /// Callback when the popover should close.
  ///
  /// *Type*: `FutureVoidCallback?`
  ///
  /// Called when close is requested with normal animation.
  /// Return a Future that completes when closing animation finishes.
  ///
  /// *Example*:
  /// ```dart
  /// onClose: () async {
  ///   await animationController.reverse();
  /// }
  /// ```
  /// {@endtemplate}
  final FutureVoidCallback? onClose;

  /// {@template popover_on_immediate_close}
  /// Callback for immediate closing without animation.
  ///
  /// *Type*: `VoidCallback?`
  ///
  /// Called when the popover should close immediately, bypassing animation.
  ///
  /// *Example*: `onImmediateClose: () => removeOverlayEntry()`
  /// {@endtemplate}
  final VoidCallback? onImmediateClose;

  /// {@template popover_on_tap_outside}
  /// Callback when tapping outside the popover.
  ///
  /// *Type*: `VoidCallback?`
  ///
  /// Called when a tap is detected outside the popover region.
  /// Typically used to dismiss non-modal popovers.
  ///
  /// *Example*: `onTapOutside: () => handleDismiss()`
  /// {@endtemplate}
  final VoidCallback? onTapOutside;

  /// {@template popover_region_group_id}
  /// Identifier for the tap region group.
  ///
  /// *Type*: `Object?`
  ///
  /// When provided, allows coordinating interactions between related tap regions.
  /// Used for complex nested popovers or menus.
  ///
  /// *Example*: `regionGroupId: 'main_menu_popovers'`
  /// {@endtemplate}
  final Object? regionGroupId;

  /// {@template popover_offset}
  /// Additional offset from the calculated position.
  ///
  /// *Type*: `Offset?`
  ///
  /// Fine-tuning adjustment to the popover's position after all other calculations.
  /// Useful for subtle positioning tweaks.
  ///
  /// *Example*: `offset: Offset(0, 8)` // Move 8 pixels down
  /// {@endtemplate}
  final Offset? offset;

  /// {@template popover_transition_alignment}
  /// Alignment for the scale transition animation.
  ///
  /// *Type*: `AlignmentGeometry?`
  ///
  /// Controls which point remains fixed during scaling animation.
  /// If null, uses [alignment].
  ///
  /// *Example*: `transitionAlignment: Alignment.topCenter`
  /// {@endtemplate}
  final AlignmentGeometry? transitionAlignment;

  /// {@template popover_margin}
  /// Margin around the popover.
  ///
  /// *Type*: `EdgeInsetsGeometry?`
  ///
  /// Space between the popover and the edges of the screen or anchor.
  /// Helps prevent popovers from touching screen edges.
  ///
  /// *Example*: `margin: EdgeInsets.all(8)`
  /// {@endtemplate}
  final EdgeInsetsGeometry? margin;

  /// {@template popover_follow}
  /// Whether the popover follows its anchor when moved.
  ///
  /// *Type*: `bool`
  ///
  /// If true, the popover will update its position when the anchor moves,
  /// such as during scrolling or layout changes.
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `follow: true`
  /// {@endtemplate}
  final bool follow;

  /// {@template popover_anchor_context}
  /// The context of the widget to which this popover is anchored.
  ///
  /// *Type*: `BuildContext`
  ///
  /// Used to measure position and size of the anchor widget for
  /// positioning calculations.
  ///
  /// *Example*: `anchorContext: buttonKey.currentContext!`
  /// {@endtemplate}
  final BuildContext anchorContext;

  /// {@template popover_consume_outside_taps}
  /// Whether to consume taps outside the popover.
  ///
  /// *Type*: `bool`
  ///
  /// If true, taps outside the popover are intercepted.
  /// If false, taps pass through to widgets behind the popover.
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `consumeOutsideTaps: true`
  /// {@endtemplate}
  final bool consumeOutsideTaps;

  /// {@template popover_on_tick_follow}
  /// Callback for advanced position tracking.
  ///
  /// *Type*: `ValueChanged<PopoverOverlayWidgetState>?`
  ///
  /// Called on each tick when following is active.
  /// Provides access to the state for custom follow behavior.
  ///
  /// *Example*:
  /// ```dart
  /// onTickFollow: (state) {
  ///   customPositionLogic(state);
  /// }
  /// ```
  /// {@endtemplate}
  final ValueChanged<PopoverOverlayWidgetState>? onTickFollow;

  /// {@template popover_allow_invert_horizontal}
  /// Whether to allow horizontal flipping to fit on screen.
  ///
  /// *Type*: `bool`
  ///
  /// If true, the popover may flip horizontally when near screen edges
  /// to ensure it remains fully visible.
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `allowInvertHorizontal: true`
  /// {@endtemplate}
  final bool allowInvertHorizontal;

  /// {@template popover_allow_invert_vertical}
  /// Whether to allow vertical flipping to fit on screen.
  ///
  /// *Type*: `bool`
  ///
  /// If true, the popover may flip vertically when near screen edges
  /// to ensure it remains fully visible.
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `allowInvertVertical: true`
  /// {@endtemplate}
  final bool allowInvertVertical;

  /// {@template popover_on_close_with_result}
  /// Callback with result value when closing.
  ///
  /// *Type*: `PopoverFutureVoidCallback<Object?>?`
  ///
  /// Called when closing with a result value (e.g., selected item).
  /// Return a Future that completes when closing animation finishes.
  ///
  /// *Example*:
  /// ```dart
  /// onCloseWithResult: (value) async {
  ///   await saveSelection(value);
  /// }
  /// ```
  /// {@endtemplate}
  final PopoverFutureVoidCallback<Object?>? onCloseWithResult;

  /// {@template popover_layer_link}
  /// Optional layer link for compositor-based positioning.
  ///
  /// *Type*: `LayerLink?`
  ///
  /// When provided, uses Flutter's CompositedTransformFollower for positioning.
  /// This offers smoother following during scrolling, but requires a paired
  /// CompositedTransformTarget.
  ///
  /// *Example*:
  /// ```dart
  /// // On anchor widget:
  /// CompositedTransformTarget(
  ///   link: _layerLink,
  ///   child: anchorWidget,
  /// )
  ///
  /// // Then in popover:
  /// layerLink: _layerLink
  /// ```
  /// {@endtemplate}
  final LayerLink? layerLink;

  /// {@template popover_fixed_size}
  /// Fixed dimensions for the popover.
  ///
  /// *Type*: `Size?`
  ///
  /// Used when width or height constraint is [PopoverConstraint.fixed].
  /// Explicitly sets dimensions regardless of content.
  ///
  /// *Example*: `fixedSize: Size(300, 400)`
  /// {@endtemplate}
  final Size? fixedSize;

  /// Creates a PopoverOverlayWidget with the specified configuration.
  ///
  /// {@macro popover_overlay_widget}
  const PopoverOverlayWidget({
    super.key,
    required this.anchorContext,
    this.position,
    required this.alignment,
    this.themes,
    required this.builder,
    required this.animation,
    required this.anchorAlignment,
    this.widthConstraint = PopoverConstraint.flexible,
    this.heightConstraint = PopoverConstraint.flexible,
    this.anchorSize,
    this.onTapOutside,
    this.regionGroupId,
    this.offset,
    this.transitionAlignment,
    this.margin,
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
  });

  @override
  State<PopoverOverlayWidget> createState() => PopoverOverlayWidgetState();
}

/// {@template popover_overlay_widget_state}
/// # PopoverOverlayWidgetState
///
/// State management and positioning logic for [PopoverOverlayWidget].
///
/// This class implements [OverlayHandlerStateMixin] to provide a unified API for
/// controlling popover behavior, position, and animations. It handles anchor tracking,
/// positioning calculations, and lifecycle management for popovers.
///
/// ## Key Responsibilities
///
/// - **Position Tracking**: Updates popover position when anchors move
/// - **Animation Coordination**: Manages entrance and exit animations
/// - **Reactive Updates**: Responds to property changes and context changes
/// - **Lifecycle Management**: Handles proper cleanup of resources
///
/// ## Controlling Popovers
///
/// This state can be accessed from within popover content to control the popover:
///
/// ```dart
/// // Inside popover content:
/// final handler = Data.maybeFind<OverlayHandlerStateMixin>(context);
/// if (handler != null) {
///   handler.close(); // Close the popover
/// }
/// ```
///
/// ## Performance Optimization
///
/// Includes optimizations like:
/// - Frame skipping for smooth scrolling performance
/// - Position change detection with threshold to avoid unnecessary updates
/// - Efficient state update batching
/// {@endtemplate}
class PopoverOverlayWidgetState extends State<PopoverOverlayWidget>
    with SingleTickerProviderStateMixin, OverlayHandlerStateMixin {
  // State variables
  late BuildContext _anchorContext;
  late Offset? _position;
  late Offset? _offset;
  late AlignmentGeometry _alignment;
  late AlignmentGeometry _anchorAlignment;
  late PopoverConstraint _widthConstraint;
  late PopoverConstraint _heightConstraint;
  late EdgeInsetsGeometry? _margin;
  Size? _anchorSize;
  Size? _fixedSize;
  late bool _follow;
  late bool _allowInvertHorizontal;
  late bool _allowInvertVertical;
  late Ticker? _ticker;
  late LayerLink? _layerLink;

  // Performance optimization: cache for layout computation
  Offset? _lastMeasuredPosition;
  Size? _lastMeasuredAnchorSize;
  int _skipPositionUpdateCount = 0;

  @override
  set offset(Offset? offset) {
    if (offset != _offset) {
      setState(() {
        _offset = offset;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize values from widget
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

    // Setup ticker for following anchor if needed
    if (_follow && _layerLink == null) {
      _ticker = createTicker(_tick);
      _ticker!.start();
    } else {
      _ticker = null;
    }
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

  @override
  void didUpdateWidget(covariant PopoverOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update state variables when widget properties change
    bool needsRebuild = false;

    if (oldWidget.alignment != widget.alignment) {
      _alignment = widget.alignment;
      needsRebuild = true;
    }

    if (oldWidget.anchorSize != widget.anchorSize) {
      _anchorSize = widget.anchorSize;
      needsRebuild = true;
    }

    if (oldWidget.anchorAlignment != widget.anchorAlignment) {
      _anchorAlignment = widget.anchorAlignment;
      needsRebuild = true;
    }

    if (oldWidget.widthConstraint != widget.widthConstraint) {
      _widthConstraint = widget.widthConstraint;
      needsRebuild = true;
    }

    if (oldWidget.heightConstraint != widget.heightConstraint) {
      _heightConstraint = widget.heightConstraint;
      needsRebuild = true;
    }

    if (oldWidget.offset != widget.offset) {
      _offset = widget.offset;
      needsRebuild = true;
    }

    if (oldWidget.fixedSize != widget.fixedSize) {
      _fixedSize = widget.fixedSize;
      needsRebuild = true;
    }

    if (oldWidget.margin != widget.margin) {
      _margin = widget.margin;
      needsRebuild = true;
    }

    // Handle ticker/follow state changes
    bool shouldUseFollowTicker = widget.follow && widget.layerLink == null;
    bool wasUsingFollowTicker = oldWidget.follow && oldWidget.layerLink == null;

    if (shouldUseFollowTicker != wasUsingFollowTicker) {
      if (shouldUseFollowTicker) {
        _ticker ??= createTicker(_tick);
        if (!(_ticker?.isActive ?? false)) {
          _ticker?.start();
        }
      } else if (_ticker?.isActive ?? false) {
        _ticker?.stop();
      }
    }

    _follow = widget.follow;

    // Update LayerLink
    if (oldWidget.layerLink != widget.layerLink) {
      _layerLink = widget.layerLink;
      if (_layerLink != null && (_ticker?.isActive ?? false)) {
        _ticker?.stop();
      }
      needsRebuild = true;
    }

    if (oldWidget.anchorContext != widget.anchorContext) {
      _anchorContext = widget.anchorContext;
      needsRebuild = true;
    }

    if (oldWidget.allowInvertHorizontal != widget.allowInvertHorizontal) {
      _allowInvertHorizontal = widget.allowInvertHorizontal;
      needsRebuild = true;
    }

    if (oldWidget.allowInvertVertical != widget.allowInvertVertical) {
      _allowInvertVertical = widget.allowInvertVertical;
      needsRebuild = true;
    }

    if (oldWidget.position != widget.position && !_follow) {
      _position = widget.position;
      needsRebuild = true;
    }

    // Only rebuild if necessary
    if (needsRebuild) {
      setState(() {});
    }
  }

  // Getters and setters for state properties
  Size? get anchorSize => _anchorSize;
  AlignmentGeometry get anchorAlignment => _anchorAlignment;
  Offset? get position => _position;
  AlignmentGeometry get alignment => _alignment;
  PopoverConstraint get widthConstraint => _widthConstraint;
  PopoverConstraint get heightConstraint => _heightConstraint;
  Offset? get offset => _offset;
  EdgeInsetsGeometry? get margin => _margin;
  bool get follow => _follow;
  BuildContext get anchorContext => _anchorContext;
  bool get allowInvertHorizontal => _allowInvertHorizontal;
  bool get allowInvertVertical => _allowInvertVertical;
  LayerLink? get layerLink => _layerLink;
  Size? get fixedSize => _fixedSize;

  set fixedSize(Size? value) {
    if (_fixedSize != value) {
      setState(() => _fixedSize = value);
    }
  }

  set layerLink(LayerLink? value) {
    if (_layerLink != value) {
      setState(() {
        _layerLink = value;
        if (_follow && _layerLink == null) {
          _ticker ??= createTicker(_tick);
          if (!(_ticker?.isActive ?? false)) {
            _ticker?.start();
          }
        } else if (_ticker?.isActive ?? false) {
          _ticker?.stop();
        }
      });
    }
  }

  @override
  set alignment(AlignmentGeometry value) {
    if (_alignment != value) {
      setState(() => _alignment = value);
    }
  }

  set position(Offset? value) {
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
  set margin(EdgeInsetsGeometry? value) {
    if (_margin != value) {
      setState(() => _margin = value);
    }
  }

  @override
  set follow(bool value) {
    if (_follow != value) {
      setState(() {
        _follow = value;
        if (_follow && _layerLink == null) {
          _ticker ??= createTicker(_tick);
          if (!(_ticker?.isActive ?? false)) {
            _ticker?.start();
          }
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
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  // Performance-optimized ticker callback
  void _tick(Duration elapsed) {
    if (!mounted || !anchorContext.mounted) return;

    // Skip some updates to reduce processing load (every 3rd frame)
    if (_skipPositionUpdateCount > 0) {
      _skipPositionUpdateCount--;
      return;
    }
    _skipPositionUpdateCount = 2; // Skip next 2 frames

    // Update position based on anchorContext
    final RenderBox? renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset pos = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Check if position actually changed significantly (1px threshold)
    final bool positionChanged = _lastMeasuredPosition == null ||
        (_lastMeasuredPosition! - pos).distance > 1.0;
    final bool sizeChanged = _lastMeasuredAnchorSize == null ||
        _lastMeasuredAnchorSize!.width != size.width ||
        _lastMeasuredAnchorSize!.height != size.height;

    if (!positionChanged && !sizeChanged) return;

    _lastMeasuredPosition = pos;
    _lastMeasuredAnchorSize = size;

    final anchorAlignment = _anchorAlignment.optionallyResolve(context);
    final Offset newPos = Offset(
      pos.dx + size.width / 2 + size.width / 2 * anchorAlignment.x,
      pos.dy + size.height / 2 + size.height / 2 * anchorAlignment.y,
    );

    if (_position != newPos || _anchorSize != size) {
      setState(() {
        _anchorSize = size;
        _position = newPos;
        widget.onTickFollow?.call(this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Data<OverlayHandlerStateMixin>.inherit(
      data: this,
      child: TapRegion(
        onTapOutside: widget.onTapOutside != null
            ? (event) => widget.onTapOutside?.call()
            : null,
        groupId: widget.regionGroupId,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          removeTop: true,
          child: _layerLink != null
              ? CompositedTransformFollower(
                  link: _layerLink!,
                  showWhenUnlinked: false,
                  offset: _offset ?? Offset.zero,
                  child: _buildPopoverContent(),
                )
              : _buildPopoverContent(),
        ),
      ),
    );

    // Wrap with captured themes and data if provided
    if (widget.themes != null) {
      childWidget = widget.themes!.wrap(childWidget);
    }
    if (widget.data != null) {
      childWidget = widget.data!.wrap(childWidget);
    }

    return childWidget;
  }

  // Extract popover content building to reduce method length
  Widget _buildPopoverContent() {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return PopoverLayout(
          alignment: _alignment.optionallyResolve(context),
          position: _position,
          anchorSize: _anchorSize,
          anchorAlignment: _anchorAlignment.optionallyResolve(context),
          widthConstraint: _widthConstraint,
          heightConstraint: _heightConstraint,
          offset: _offset,
          margin:
              _margin?.optionallyResolve(context) ?? const EdgeInsets.all(8),
          scale: tweenValue(0.9, 1.0, widget.animation.value),
          scaleAlignment: (widget.transitionAlignment ?? _alignment)
              .optionallyResolve(context),
          allowInvertVertical: _allowInvertVertical,
          allowInvertHorizontal: _allowInvertHorizontal,
          filterQuality: ui.FilterQuality.low, // Optimize rendering quality
          fixedSize: _fixedSize,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: widget.animation,
        child: Builder(builder: widget.builder),
      ),
    );
  }

  @override
  Future<void> closeWithResult<X>([X? value]) {
    return widget.onCloseWithResult?.call(value) ?? Future.value();
  }
}

/// {@template overlay_popover_entry}
/// # OverlayPopoverEntry
///
/// An implementation of [OverlayCompleter] that manages the lifecycle and state
/// of a popover overlay entry.
///
/// This class handles the overlay entries, completion state, and animation state
/// for popovers. It provides methods to remove, dispose, and manage completion of popovers.
///
/// ## Key Features
///
/// - **Entry Management**: Controls overlay and barrier entries
/// - **Result Handling**: Provides completion futures for awaiting results
/// - **Animation Tracking**: Separate completion tracking for animations and results
/// - **Safe Removal**: Handles cleanup and disposal with safety checks
///
/// ## Usage
/// ```dart
/// final entry = OverlayPopoverEntry<String>();
/// // Initialize with overlay entries
/// entry.initialize(overlayEntry, barrierEntry);
///
/// // Later, await result
/// final result = await entry.future;
///
/// // Programmatically remove
/// entry.remove();
/// ```
/// {@endtemplate}
class OverlayPopoverEntry<T> implements OverlayCompleter<T> {
  late OverlayEntry _overlayEntry;
  late OverlayEntry? _barrierEntry;
  final Completer<T?> completer = Completer<T?>();
  final Completer<T?> animationCompleter = Completer<T?>();

  bool _removed = false;
  bool _disposed = false;

  /// {@template overlay_popover_entry_is_completed}
  /// Whether the popover has been completed with a result.
  ///
  /// Returns `true` if the popover has been closed and its result delivered.
  /// {@endtemplate}
  @override
  bool get isCompleted => completer.isCompleted;

  /// {@template overlay_popover_entry_initialize}
  /// Initializes the entry with overlay entries.
  ///
  /// *Parameters:*
  /// - **overlayEntry**: The main overlay entry containing the popover content
  /// - **barrierEntry**: Optional barrier entry for modal popovers
  ///
  /// Must be called before using other methods.
  /// {@endtemplate}
  void initialize(OverlayEntry overlayEntry, [OverlayEntry? barrierEntry]) {
    _overlayEntry = overlayEntry;
    _barrierEntry = barrierEntry;
  }

  /// {@template overlay_popover_entry_remove}
  /// Removes the popover from the UI.
  ///
  /// *Behavior:*
  /// - Safely removes overlay entries from the overlay
  /// - Does nothing if already removed
  /// - Does not complete the result future
  ///
  /// Call when you want to immediately remove the popover without animation.
  /// {@endtemplate}
  @override
  void remove() {
    if (_removed) return;
    _removed = true;
    _overlayEntry.remove();
    _barrierEntry?.remove();
  }

  /// {@template overlay_popover_entry_dispose}
  /// Disposes resources used by the popover.
  ///
  /// *Behavior:*
  /// - Releases resources associated with overlay entries
  /// - Does nothing if already disposed
  /// - Should be called after removal
  ///
  /// This is typically called automatically after animations complete.
  /// {@endtemplate}
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _overlayEntry.dispose();
    _barrierEntry?.dispose();
  }

  /// {@template overlay_popover_entry_future}
  /// Future that completes with the popover's result value.
  ///
  /// *Returns:*
  /// - A `Future<T?>` that completes when the popover is closed
  /// - The value may be `null` if no result was provided
  ///
  /// Use this to await the result of user interaction with the popover.
  /// {@endtemplate}
  @override
  Future<T?> get future => completer.future;

  /// {@template overlay_popover_entry_animation_future}
  /// Future that completes when the popover's exit animation completes.
  ///
  /// *Returns:*
  /// - A `Future<T?>` that completes after the exit animation
  /// - May complete later than [future] if animations are used
  ///
  /// Useful for sequencing UI changes after the popover fully disappears.
  /// {@endtemplate}
  @override
  Future<T?> get animationFuture => animationCompleter.future;

  /// {@template overlay_popover_entry_is_animation_completed}
  /// Whether the popover's exit animation has completed.
  ///
  /// Returns `true` if the exit animation has finished and the popover is fully removed.
  /// {@endtemplate}
  @override
  bool get isAnimationCompleted => animationCompleter.isCompleted;
}

/// {@template show_popover}
/// # showPopover
///
/// A convenient function to display a popover anchored to a specific widget or position.
///
/// This function provides a simplified API for showing popovers with all the power of
/// [PopoverOverlayHandler]. It handles positioning, animations, interaction, and
/// returns the result when the popover is closed.
///
/// ## Basic Usage
/// ```dart
/// final result = await showPopover(
///   context: context,
///   alignment: Alignment.bottomLeft,
///   builder: (context) => MenuItems(
///     onSelect: (item) => closeOverlay(context, item),
///   ),
/// );
///
/// if (result != null) {
///   // Handle the selected item
///   handleSelection(result);
/// }
/// ```
///
/// ## Positioning Examples
///
/// ### Bottom Popover (e.g., Dropdown)
/// ```dart
/// showPopover(
///   context: buttonContext,
///   alignment: Alignment.topCenter,    // Popover's top-center
///   anchorAlignment: Alignment.bottomCenter,  // Anchor's bottom-center
///   builder: (context) => DropdownMenu(...),
/// );
/// ```
///
/// ### Side Popover (e.g., Context Menu)
/// ```dart
/// showPopover(
///   context: itemContext,
///   alignment: Alignment.centerLeft,   // Popover's center-left
///   anchorAlignment: Alignment.centerRight,  // Anchor's center-right
///   offset: Offset(8, 0),             // Add 8px spacing
///   builder: (context) => ContextMenu(...),
/// );
/// ```
///
/// ### Custom Positioned Popover
/// ```dart
/// // Show at specific screen coordinates
/// showPopover(
///   context: context,
///   position: Offset(100, 200),       // Explicit position
///   alignment: Alignment.center,      // Centered at position
///   modal: true,                      // With barrier
///   builder: (context) => InfoPanel(...),
/// );
/// ```
/// {@endtemplate}
OverlayCompleter<T?> showPopover<T>({
  /// {@macro popover_context}
  required BuildContext context,

  /// {@macro popover_alignment}
  required AlignmentGeometry alignment,

  /// {@macro popover_builder}
  required WidgetBuilder builder,

  /// {@macro popover_position}
  Offset? position,

  /// {@macro popover_anchor_alignment}
  AlignmentGeometry? anchorAlignment,

  /// {@macro popover_width_constraint}
  PopoverConstraint widthConstraint = PopoverConstraint.flexible,

  /// {@macro popover_height_constraint}
  PopoverConstraint heightConstraint = PopoverConstraint.flexible,

  /// Optional key for the popover widget.
  Key? key,

  /// {@template popover_root_overlay}
  /// Whether to use the root overlay (true) or closest overlay (false).
  ///
  /// *Type*: `bool`
  ///
  /// - `true`: Use the top-level overlay (usually app-wide)
  /// - `false`: Use the nearest overlay in widget tree
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `rootOverlay: true`
  /// {@endtemplate}
  bool rootOverlay = true,

  /// {@template popover_modal}
  /// Whether to show a modal barrier behind the popover.
  ///
  /// *Type*: `bool`
  ///
  /// - `true`: Show a barrier that blocks interaction with content behind
  /// - `false`: Allow interaction with content behind the popover
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `modal: true`
  /// {@endtemplate}
  bool modal = true,

  /// {@template popover_barrier_dismissable}
  /// Whether tapping outside the popover dismisses it.
  ///
  /// *Type*: `bool`
  ///
  /// - `true`: Tapping outside the popover closes it
  /// - `false`: Popover must be closed programmatically
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `barrierDismissable: true`
  /// {@endtemplate}
  bool barrierDismissable = true,

  /// {@template popover_clip_behavior}
  /// How to clip the popover content.
  ///
  /// *Type*: `Clip`
  ///
  /// Controls how content exceeding the popover bounds is clipped:
  /// - `Clip.none`: No clipping (may overflow)
  /// - `Clip.hardEdge`: Fast clipping with aliased edges
  /// - `Clip.antiAlias`: Smooth-edged clipping
  ///
  /// *Default*: `Clip.none`
  ///
  /// *Example*: `clipBehavior: Clip.antiAlias`
  /// {@endtemplate}
  Clip clipBehavior = Clip.none,

  /// {@macro popover_region_group_id}
  Object? regionGroupId,

  /// {@macro popover_offset}
  Offset? offset,

  /// {@macro popover_transition_alignment}
  AlignmentGeometry? transitionAlignment,

  /// {@macro popover_margin}
  EdgeInsetsGeometry? margin,

  /// {@macro popover_follow}
  bool follow = true,

  /// {@macro popover_consume_outside_taps}
  bool consumeOutsideTaps = true,

  /// {@macro popover_on_tick_follow}
  ValueChanged<PopoverOverlayWidgetState>? onTickFollow,

  /// {@macro popover_allow_invert_horizontal}
  bool allowInvertHorizontal = true,

  /// {@macro popover_allow_invert_vertical}
  bool allowInvertVertical = true,

  /// {@template popover_dismiss_backdrop_focus}
  /// Whether to dismiss when focus moves to backdrop.
  ///
  /// *Type*: `bool`
  ///
  /// - `true`: Close popover if focus moves to backdrop/barrier
  /// - `false`: Keep popover open even if focus moves elsewhere
  ///
  /// *Default*: `true`
  ///
  /// *Example*: `dismissBackdropFocus: true`
  /// {@endtemplate}
  bool dismissBackdropFocus = true,

  /// {@template popover_show_duration}
  /// Duration for the entrance animation.
  ///
  /// *Type*: `Duration?`
  ///
  /// Controls how long the popover takes to animate in.
  /// If `null`, uses default duration (typically 150ms).
  ///
  /// *Example*: `showDuration: Duration(milliseconds: 200)`
  /// {@endtemplate}
  Duration? showDuration,

  /// {@template popover_dismiss_duration}
  /// Duration for the exit animation.
  ///
  /// *Type*: `Duration?`
  ///
  /// Controls how long the popover takes to animate out.
  /// If `null`, uses default duration (typically 100ms).
  ///
  /// *Example*: `dismissDuration: Duration(milliseconds: 150)`
  /// {@endtemplate}
  Duration? dismissDuration,

  /// {@template popover_overlay_barrier}
  /// Custom barrier configuration.
  ///
  /// *Type*: `OverlayBarrier?`
  ///
  /// Allows customization of the modal barrier appearance and behavior.
  /// Only applies when [modal] is `true`.
  ///
  /// *Example*:
  /// ```dart
  /// overlayBarrier: OverlayBarrier(
  ///   padding: EdgeInsets.all(8),
  ///   borderRadius: BorderRadius.circular(16),
  ///   barrierColor: Colors.black54,
  /// )
  /// ```
  /// {@endtemplate}
  OverlayBarrier? overlayBarrier,

  /// {@template popover_handler}
  /// Custom overlay handler to use instead of default.
  ///
  /// *Type*: `OverlayHandler?`
  ///
  /// When provided, uses the specified handler instead of looking up
  /// via [OverlayManager.of].
  ///
  /// *Example*: `handler: myCustomHandler`
  /// {@endtemplate}
  OverlayHandler? handler,

  /// {@macro popover_fixed_size}
  Size? fixedSize,

  /// {@template popover_layer_link}
  /// Optional layer link for compositor-based positioning.
  ///
  /// *Type*: `LayerLink?`
  ///
  /// When provided, uses Flutter's CompositedTransformFollower for positioning.
  /// This offers smoother following during scrolling, but requires a paired
  /// CompositedTransformTarget.
  ///
  /// *Example*:
  /// ```dart
  /// // On anchor widget:
  /// showPopover(
  ///   layerLink: _layerLink,
  ///   child: anchorWidget,
  /// )
  ///
  /// // Then in popover:
  /// layerLink: _layerLink
  /// ```
  /// {@endtemplate}
  final LayerLink? layerLink,
}) {
  handler ??= OverlayManager.of(context);
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
    showDuration: showDuration,
    dismissDuration: dismissDuration,
    overlayBarrier: overlayBarrier,
    fixedSize: fixedSize,
    layerLink: layerLink,
  );
}

/// {@template popover}
/// # Popover
///
/// A handle representing a displayed popover with controls to manage its state.
///
/// This class encapsulates a popover instance and provides methods to update or dismiss it.
/// It's typically created by the [PopoverController] and not meant to be directly instantiated.
///
/// ## Key Features
///
/// - **State Access**: Get the current state of the popover
/// - **Graceful Closing**: Close with or without animation
/// - **Immediate Removal**: Remove from the overlay directly
///
/// ## Usage Example
///
/// ```dart
/// // Via PopoverController
/// final controller = PopoverController();
/// final result = await controller.show(
///   context: buttonContext,
///   builder: (context) => MenuContent(),
///   alignment: Alignment.topCenter,
/// );
///
/// // Later, to close a specific popover:
/// controller.openPopovers.first.close();
/// ```
///
/// ## Closing Options
///
/// | Method | Animation | Use Case |
/// |--------|-----------|----------|
/// | close() | Yes | Normal dismissal with animation |
/// | close(true) | No | Immediate dismissal without animation |
/// | closeLater() | Yes | Schedule dismissal after current frame |
/// | remove() | No | Forcefully remove from overlay |
/// {@endtemplate}
class Popover {
  /// {@template popover_key}
  /// Key to access the popover's state.
  ///
  /// *Type*: `GlobalKey<OverlayHandlerStateMixin>`
  ///
  /// Provides access to the popover's state to control alignment, position, etc.
  /// {@endtemplate}
  final GlobalKey<OverlayHandlerStateMixin> key;

  /// {@template popover_entry}
  /// Overlay entry reference for this popover.
  ///
  /// *Type*: `OverlayCompleter`
  ///
  /// Provides direct access to the overlay entry for removal and completion status.
  /// {@endtemplate}
  final OverlayCompleter entry;

  /// {@template popover_constructor}
  /// Private constructor to prevent direct instantiation.
  ///
  /// Popovers should be created through [PopoverController.show].
  /// {@endtemplate}
  Popover._(this.key, this.entry);

  /// {@template popover_close}
  /// Closes the popover, optionally bypassing exit animation.
  ///
  /// *Parameters:*
  /// - **immediate**: Whether to skip exit animation (defaults to false)
  ///
  /// *Returns:*
  /// - `Future<void>` that completes when the popover is closed
  ///
  /// When [immediate] is false (default), a smooth exit animation is played.
  /// When [immediate] is true, the popover is immediately removed.
  ///
  /// *Example:*
  /// ```dart
  /// // Close with animation
  /// await popover.close();
  ///
  /// // Close immediately without animation
  /// await popover.close(true);
  /// ```
  /// {@endtemplate}
  Future<void> close([bool immediate = false]) {
    var currentState = key.currentState;
    if (currentState != null) {
      return currentState.close(immediate);
    } else {
      entry.remove();
    }
    return Future.value();
  }

  /// {@template popover_close_later}
  /// Schedules the popover to close after the current frame.
  ///
  /// This method avoids potential issues with closing a popover during a build phase
  /// by deferring the close operation to the next frame.
  ///
  /// *Example:*
  /// ```dart
  /// // Inside a setState or build method:
  /// if (condition) {
  ///   popover.closeLater(); // Safely schedule closure
  /// }
  /// ```
  /// {@endtemplate}
  void closeLater() {
    var currentState = key.currentState;
    if (currentState != null) {
      currentState.closeLater();
    } else {
      entry.remove();
    }
  }

  /// {@template popover_remove}
  /// Immediately removes the popover from the overlay.
  ///
  /// Unlike [close], this method bypasses any state handling and animations,
  /// directly removing the overlay entry. Use only when necessary.
  ///
  /// *Example:*
  /// ```dart
  /// // Force immediate removal with no animations
  /// popover.remove();
  /// ```
  /// {@endtemplate}
  void remove() {
    entry.remove();
  }

  /// {@template popover_current_state}
  /// Current state of the popover's overlay handler.
  ///
  /// *Type*: `OverlayHandlerStateMixin?`
  ///
  /// May be null if the popover is not currently mounted.
  /// When available, provides access to modify properties like position and alignment.
  ///
  /// *Example:*
  /// ```dart
  /// // Update popover properties if mounted
  /// if (popover.currentState != null) {
  ///   popover.currentState!.alignment = Alignment.centerRight;
  /// }
  /// ```
  /// {@endtemplate}
  OverlayHandlerStateMixin? get currentState => key.currentState;
}

/// {@template popover_controller}
/// # PopoverController
///
/// A controller for managing multiple popovers with centralized state control.
///
/// This controller allows showing popovers with rich configuration options and
/// provides methods to manage their lifecycle. It keeps track of all open popovers
/// and can update their properties collectively or close them as needed.
///
/// ## Key Features
///
/// - **State Management**: Track and control multiple popovers
/// - **Bulk Updates**: Update properties of all active popovers at once
/// - **Clean Disposal**: Automatically handle popover cleanup
/// - **Status Queries**: Check if popovers are open or mounted
///
/// ## Basic Usage
///
/// ```dart
/// // Create a controller
/// final controller = PopoverController();
///
/// // Show a popover
/// await controller.show(
///   context: buttonContext,
///   builder: (context) => MenuItems(),
///   alignment: Alignment.bottomLeft,
/// );
///
/// // Close all popovers
/// controller.close();
/// ```
///
/// ## Lifecycle Management
///
/// The controller properly cleans up all popovers when disposed, making it safe
/// to use with StatefulWidget lifecycle or Provider patterns.
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final PopoverController _popoverController = PopoverController();
///
///   @override
///   void dispose() {
///     _popoverController.dispose(); // Cleans up all popovers
///     super.dispose();
///   }
/// }
/// ```
///
/// ## Status Queries
///
/// ```dart
/// if (controller.hasOpenPopover) {
///   // At least one popover is open and active
/// }
///
/// if (controller.hasMountedPopover) {
///   // At least one popover is still visible (may be animating out)
/// }
/// ```
/// {@endtemplate}
class PopoverController extends ChangeNotifier {
  bool _disposed = false;
  final List<Popover> _openPopovers = [];

  /// {@template popover_controller_has_open_popover}
  /// Whether there are any active popovers.
  ///
  /// *Type*: `bool`
  ///
  /// Returns `true` if there is at least one uncompleted popover.
  /// This indicates popovers that are open and can still receive user interaction.
  ///
  /// *Example:*
  /// ```dart
  /// if (controller.hasOpenPopover) {
  ///   // Don't allow another action until popovers are closed
  /// }
  /// ```
  /// {@endtemplate}
  bool get hasOpenPopover =>
      _openPopovers.isNotEmpty &&
      _openPopovers.any((element) => !element.entry.isCompleted);

  /// {@template popover_controller_has_mounted_popover}
  /// Whether there are any popovers still visible in the UI.
  ///
  /// *Type*: `bool`
  ///
  /// Returns `true` if there is at least one popover whose exit animation
  /// hasn't completed. This can include popovers that are animating out.
  ///
  /// *Example:*
  /// ```dart
  /// if (!controller.hasMountedPopover) {
  ///   // Safe to proceed - all popovers have fully disappeared
  /// }
  /// ```
  /// {@endtemplate}
  bool get hasMountedPopover =>
      _openPopovers.isNotEmpty &&
      _openPopovers.any((element) => !element.entry.isAnimationCompleted);

  /// {@template popover_controller_open_popovers}
  /// List of all currently open popovers.
  ///
  /// *Type*: `Iterable<Popover>`
  ///
  /// Provides read-only access to all popovers managed by this controller.
  /// Useful for selectively closing specific popovers or checking their state.
  ///
  /// *Example:*
  /// ```dart
  /// // Close only the oldest popover
  /// if (controller.openPopovers.isNotEmpty) {
  ///   controller.openPopovers.first.close();
  /// }
  /// ```
  /// {@endtemplate}
  Iterable<Popover> get openPopovers => List.unmodifiable(_openPopovers);

  /// {@template popover_controller_show}
  /// Shows a popover with the given configuration.
  ///
  /// *Type*: `Future<T?> Function<T>(...)`
  ///
  /// Displays a popover using the provided builder and configuration options.
  /// Returns a Future that completes with a value when the popover is closed.
  ///
  /// ## Core Parameters
  /// - **context**: The BuildContext from which to anchor the popover
  /// - **builder**: Function to build the popover content
  /// - **alignment**: Alignment of the popover relative to the anchor point
  ///
  /// ## Positioning & Sizing
  /// - **anchorAlignment**: Alignment point on the anchor (defaults to inverse of alignment)
  /// - **widthConstraint**: How to constrain the popover's width
  /// - **heightConstraint**: How to constrain the popover's height
  /// - **offset**: Additional offset from calculated position
  /// - **margin**: Edge margin to maintain around the popover
  /// - **fixedSize**: Exact size when using fixed constraints
  ///
  /// ## Behavior Options
  /// - **modal**: Whether to show a barrier behind the popover (default: true)
  /// - **closeOthers**: Whether to close other popovers when showing this one (default: true)
  /// - **follow**: Whether the popover follows its anchor when it moves
  /// - **consumeOutsideTaps**: Whether to consume taps outside the popover
  /// - **allowInvertHorizontal/Vertical**: Whether to flip the popover when near screen edges
  ///
  /// ## Animation Options
  /// - **showDuration**: Duration for the entrance animation
  /// - **hideDuration**: Duration for the exit animation
  ///
  /// ## Advanced Options
  /// - **regionGroupId**: Identifier for tap regions
  /// - **transitionAlignment**: Alignment for the scale transition
  /// - **dismissBackdropFocus**: Whether to dismiss when backdrop gains focus
  /// - **overlayBarrier**: Custom barrier configuration
  /// - **layerLink**: Custom LayerLink for composite transforms
  ///
  /// ## Usage Examples
  ///
  /// ### Basic Menu Popover
  /// ```dart
  /// final result = await controller.show<String>(
  ///   context: buttonContext,
  ///   builder: (context) => MenuItems(),
  ///   alignment: Alignment.bottomLeft,
  /// );
  ///
  /// if (result != null) {
  ///   handleMenuSelection(result);
  /// }
  /// ```
  ///
  /// ### Tooltip with Custom Positioning
  /// ```dart
  /// controller.show(
  ///   context: iconContext,
  ///   builder: (context) => Tooltip(message: "Help text"),
  ///   alignment: Alignment.topRight,
  ///   anchorAlignment: Alignment.bottomCenter,
  ///   modal: false,
  ///   offset: Offset(0, 4),
  ///   widthConstraint: PopoverConstraint.contentSize,
  /// );
  /// ```
  ///
  /// ### Modal Dialog with Fixed Size
  /// ```dart
  /// controller.show(
  ///   context: context,
  ///   builder: (context) => DialogContent(),
  ///   alignment: Alignment.center,
  ///   widthConstraint: PopoverConstraint.fixed,
  ///   heightConstraint: PopoverConstraint.fixed,
  ///   fixedSize: Size(400, 300),
  ///   modal: true,
  /// );
  /// ```
  /// {@endtemplate}
  Future<T?> show<T>({
    /// The context from which to anchor the popover
    required BuildContext context,

    /// Builder function for the popover content
    required WidgetBuilder builder,

    /// Alignment of the popover relative to its position
    required AlignmentGeometry alignment,

    /// Alignment point on the anchor widget
    AlignmentGeometry? anchorAlignment,

    /// How to constrain the popover's width
    PopoverConstraint widthConstraint = PopoverConstraint.flexible,

    /// How to constrain the popover's height
    PopoverConstraint heightConstraint = PopoverConstraint.flexible,

    /// Whether to show a barrier behind the popover
    bool modal = true,

    /// Whether to close existing popovers when showing this one
    bool closeOthers = true,

    /// Additional offset from calculated position
    Offset? offset,

    /// Key for accessing the popover state
    GlobalKey<OverlayHandlerStateMixin>? key,

    /// Identifier for coordinating tap regions
    Object? regionGroupId,

    /// Alignment for the scale transition
    AlignmentGeometry? transitionAlignment,

    /// Whether taps outside the popover are consumed
    bool consumeOutsideTaps = true,

    /// Margin around the popover
    EdgeInsetsGeometry? margin,

    /// Callback when anchor position changes
    ValueChanged<PopoverOverlayWidgetState>? onTickFollow,

    /// Whether the popover follows its anchor when it moves
    bool follow = true,

    /// Whether to allow horizontal flipping when near screen edges
    bool allowInvertHorizontal = true,

    /// Whether to allow vertical flipping when near screen edges
    bool allowInvertVertical = true,

    /// Whether to dismiss when backdrop gains focus
    bool dismissBackdropFocus = true,

    /// Duration for the entrance animation
    Duration? showDuration,

    /// Duration for the exit animation
    Duration? hideDuration,

    /// Custom barrier configuration
    OverlayBarrier? overlayBarrier,

    /// Custom overlay handler
    OverlayHandler? handler,

    /// Fixed size when using fixed constraints
    Size? fixedSize,

    /// LayerLink for compositor-based positioning
    LayerLink? layerLink,
  }) async {
    if (closeOthers) {
      close();
    }

    key ??= GlobalKey<OverlayHandlerStateMixin>(
        debugLabel: 'PopoverAnchor$hashCode');

    OverlayCompleter<T?> res = showPopover<T>(
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
      dismissDuration: hideDuration,
      overlayBarrier: overlayBarrier,
      handler: handler,
      fixedSize: fixedSize,
    );

    var popover = Popover._(
      key,
      res,
    );
    _openPopovers.add(popover);
    notifyListeners();

    try {
      await res.future;
    } finally {
      _openPopovers.remove(popover);
      if (!_disposed) {
        notifyListeners();
      }
    }

    return res.future;
  }

  /// {@template popover_controller_close}
  /// Closes all open popovers.
  ///
  /// *Parameters:*
  /// - **immediate**: Whether to skip exit animations (defaults to false)
  ///
  /// When [immediate] is false (default), popovers will close with their exit animation.
  /// When [immediate] is true, popovers are removed immediately without animation.
  ///
  /// *Example:*
  /// ```dart
  /// // Close all popovers with animation
  /// controller.close();
  ///
  /// // Close all popovers immediately
  /// controller.close(true);
  /// ```
  /// {@endtemplate}
  void close([bool immediate = false]) {
    for (Popover popover in _openPopovers) {
      popover.close(immediate);
    }
    _openPopovers.clear();
    notifyListeners();
  }

  /// {@template popover_controller_close_later}
  /// Schedules all popovers to close after the current frame.
  ///
  /// This method is useful when you need to close popovers from within a build
  /// method or other context where immediate state changes might cause issues.
  ///
  /// *Example:*
  /// ```dart
  /// // Schedule closure after frame completion
  /// controller.closeLater();
  /// ```
  /// {@endtemplate}
  void closeLater() {
    for (Popover popover in _openPopovers) {
      popover.closeLater();
    }
    _openPopovers.clear();
    notifyListeners();
  }

  /// {@template popover_controller_anchor_context}
  /// Updates the anchor context for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new BuildContext to use as anchor
  ///
  /// Sets the anchor context property on all active popovers, causing them
  /// to reposition relative to the new context.
  ///
  /// *Example:*
  /// ```dart
  /// // Update all popovers to follow a new widget
  /// controller.anchorContext = newButtonContext;
  /// ```
  /// {@endtemplate}
  set anchorContext(BuildContext value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.anchorContext = value;
    }
  }

  /// {@template popover_controller_alignment}
  /// Updates the alignment for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new alignment value
  ///
  /// Sets the alignment property on all active popovers, causing them
  /// to reposition according to the new alignment.
  ///
  /// *Example:*
  /// ```dart
  /// // Move all popovers to align to the bottom
  /// controller.alignment = Alignment.bottomCenter;
  /// ```
  /// {@endtemplate}
  set alignment(AlignmentGeometry value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.alignment = value;
    }
  }

  /// {@template popover_controller_anchor_alignment}
  /// Updates the anchor alignment for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new anchor alignment value
  ///
  /// Sets the anchorAlignment property on all active popovers, changing
  /// which point on the anchor they attach to.
  ///
  /// *Example:*
  /// ```dart
  /// // Attach all popovers to the top of their anchors
  /// controller.anchorAlignment = Alignment.topCenter;
  /// ```
  /// {@endtemplate}
  set anchorAlignment(AlignmentGeometry value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.anchorAlignment = value;
    }
  }

  /// {@template popover_controller_width_constraint}
  /// Updates the width constraint for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new width constraint value
  ///
  /// Sets the widthConstraint property on all active popovers, changing
  /// how their width is determined.
  ///
  /// *Example:*
  /// ```dart
  /// // Make all popovers match their anchor width
  /// controller.widthConstraint = PopoverConstraint.anchorFixedSize;
  /// ```
  /// {@endtemplate}
  set widthConstraint(PopoverConstraint value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.widthConstraint = value;
    }
  }

  /// {@template popover_controller_height_constraint}
  /// Updates the height constraint for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new height constraint value
  ///
  /// Sets the heightConstraint property on all active popovers, changing
  /// how their height is determined.
  ///
  /// *Example:*
  /// ```dart
  /// // Make all popovers use content-based height
  /// controller.heightConstraint = PopoverConstraint.contentSize;
  /// ```
  /// {@endtemplate}
  set heightConstraint(PopoverConstraint value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.heightConstraint = value;
    }
  }

  /// {@template popover_controller_margin}
  /// Updates the margin for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new margin value
  ///
  /// Sets the margin property on all active popovers, changing
  /// the space around them.
  ///
  /// *Example:*
  /// ```dart
  /// // Add more margin around all popovers
  /// controller.margin = EdgeInsets.all(16);
  /// ```
  /// {@endtemplate}
  set margin(EdgeInsets value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.margin = value;
    }
  }

  /// {@template popover_controller_follow}
  /// Updates the follow behavior for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new follow value
  ///
  /// Sets the follow property on all active popovers, controlling whether
  /// they reposition when their anchor moves.
  ///
  /// *Example:*
  /// ```dart
  /// // Stop all popovers from following their anchors
  /// controller.follow = false;
  /// ```
  /// {@endtemplate}
  set follow(bool value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.follow = value;
    }
  }

  /// {@template popover_controller_offset}
  /// Updates the offset for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new offset value
  ///
  /// Sets the offset property on all active popovers, adding a
  /// custom offset to their calculated position.
  ///
  /// *Example:*
  /// ```dart
  /// // Move all popovers down by 10 pixels
  /// controller.offset = Offset(0, 10);
  /// ```
  /// {@endtemplate}
  set offset(Offset? value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.offset = value;
    }
  }

  /// {@template popover_controller_allow_invert_horizontal}
  /// Updates the horizontal inversion behavior for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new allowInvertHorizontal value
  ///
  /// Sets whether popovers are allowed to flip horizontally when they
  /// would otherwise extend beyond screen edges.
  ///
  /// *Example:*
  /// ```dart
  /// // Prevent horizontal flipping
  /// controller.allowInvertHorizontal = false;
  /// ```
  /// {@endtemplate}
  set allowInvertHorizontal(bool value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.allowInvertHorizontal = value;
    }
  }

  /// {@template popover_controller_allow_invert_vertical}
  /// Updates the vertical inversion behavior for all open popovers.
  ///
  /// *Parameters:*
  /// - **value**: The new allowInvertVertical value
  ///
  /// Sets whether popovers are allowed to flip vertically when they
  /// would otherwise extend beyond screen edges.
  ///
  /// *Example:*
  /// ```dart
  /// // Prevent vertical flipping
  /// controller.allowInvertVertical = false;
  /// ```
  /// {@endtemplate}
  set allowInvertVertical(bool value) {
    for (Popover popover in _openPopovers) {
      popover.currentState?.allowInvertVertical = value;
    }
  }

  /// {@template popover_controller_dispose_popovers}
  /// Schedules all popovers to close.
  ///
  /// Cleanly closes all open popovers, typically used during controller disposal.
  /// This ensures no popovers are left orphaned when the controller is disposed.
  /// {@endtemplate}
  void disposePopovers() {
    for (Popover popover in _openPopovers) {
      popover.closeLater();
    }
  }

  /// {@template popover_controller_dispose}
  /// Disposes the controller and cleans up all popovers.
  ///
  /// Ensures all popovers are properly closed and resources are released.
  /// Always call this method when the controller is no longer needed.
  ///
  /// *Example:*
  /// ```dart
  /// @override
  /// void dispose() {
  ///   popoverController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  /// {@endtemplate}
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    disposePopovers();
    super.dispose();
  }
}

/// {@template popover_layout}
/// # PopoverLayout
///
/// A specialized widget that handles the positioning, sizing, and animation
/// of popover content.
///
/// This widget manages complex layout calculations for popovers, including screen
/// edge detection, size constraints, margin handling, and transform animation.
/// It works together with [PopoverLayoutRender] to efficiently render popovers
/// at their correct position with proper sizing and animation.
///
/// ## Features
///
/// - **Smart Positioning**: Positions popovers relative to anchors or fixed coordinates
/// - **Size Constraints**: Various constraint modes for popover dimensions
/// - **Edge Detection**: Handles screen boundaries with optional flipping
/// - **Hardware Acceleration**: Optimized rendering with compositing layers
/// - **Scale Animation**: Smooth transition effects with customizable alignment
///
/// ## Usage Note
///
/// This is an internal implementation detail of the popover system and shouldn't
/// be used directly in most cases. Instead, use [PopoverController] or [showPopover].
///
/// ## Advanced Usage
///
/// For custom overlay implementations that need precise control:
///
/// ```dart
/// PopoverLayout(
///   alignment: Alignment.topCenter,
///   position: anchorPosition,
///   anchorAlignment: Alignment.bottomCenter,
///   anchorSize: anchorSize,
///   widthConstraint: PopoverConstraint.flexible,
///   heightConstraint: PopoverConstraint.contentSize,
///   margin: EdgeInsets.all(8),
///   scale: animationController.value,
///   scaleAlignment: Alignment.topCenter,
///   child: MyPopoverContent(),
/// )
/// ```
/// {@endtemplate}
class PopoverLayout extends SingleChildRenderObjectWidget {
  /// {@template popover_layout_alignment}
  /// The alignment of the popover relative to its position.
  ///
  /// *Type*: `Alignment`
  ///
  /// Controls which part of the popover aligns with the position.
  /// For example, [Alignment.topLeft] places the top-left corner of the popover at the position.
  /// {@endtemplate}
  final Alignment alignment;

  /// {@template popover_layout_anchor_alignment}
  /// The alignment point on the anchor.
  ///
  /// *Type*: `Alignment`
  ///
  /// Defines which point on the anchor is used for positioning.
  /// For example, [Alignment.bottomRight] uses the bottom-right corner of the anchor.
  /// {@endtemplate}
  final Alignment anchorAlignment;

  /// {@template popover_layout_position}
  /// The target position for popover placement.
  ///
  /// *Type*: `Offset?`
  ///
  /// Global screen coordinates where the popover should be positioned.
  /// If null, position is calculated based on other properties.
  /// {@endtemplate}
  final Offset? position;

  /// {@template popover_layout_anchor_size}
  /// The size of the anchor widget.
  ///
  /// *Type*: `Size?`
  ///
  /// Used for positioning and sizing calculations, especially with
  /// anchor-relative constraints like [PopoverConstraint.anchorFixedSize].
  /// {@endtemplate}
  final Size? anchorSize;

  /// {@template popover_layout_width_constraint}
  /// How to constrain the popover's width.
  ///
  /// *Type*: `PopoverConstraint`
  ///
  /// Controls how the width is calculated (e.g., flexible, fixed, content-based).
  /// {@endtemplate}
  final PopoverConstraint widthConstraint;

  /// {@template popover_layout_height_constraint}
  /// How to constrain the popover's height.
  ///
  /// *Type*: `PopoverConstraint`
  ///
  /// Controls how the height is calculated (e.g., flexible, fixed, content-based).
  /// {@endtemplate}
  final PopoverConstraint heightConstraint;

  /// {@template popover_layout_offset}
  /// Additional offset from calculated position.
  ///
  /// *Type*: `Offset?`
  ///
  /// Fine-tuning adjustment applied after all other positioning.
  /// {@endtemplate}
  final Offset? offset;

  /// {@template popover_layout_margin}
  /// Margin around the popover.
  ///
  /// *Type*: `EdgeInsets`
  ///
  /// Space to maintain between the popover and screen edges.
  /// {@endtemplate}
  final EdgeInsets margin;

  /// {@template popover_layout_scale}
  /// Scale factor for the popover.
  ///
  /// *Type*: `double`
  ///
  /// Used for entrance/exit animations, typically between 0.0 and 1.0.
  /// {@endtemplate}
  final double scale;

  /// {@template popover_layout_scale_alignment}
  /// Alignment for the scale transform.
  ///
  /// *Type*: `Alignment`
  ///
  /// Controls which point remains fixed during scaling animation.
  /// {@endtemplate}
  final Alignment scaleAlignment;

  /// {@template popover_layout_filter_quality}
  /// Render quality for the scaled popover.
  ///
  /// *Type*: `FilterQuality?`
  ///
  /// Controls the quality of filtering when scaling the popover.
  /// {@endtemplate}
  final FilterQuality? filterQuality;

  /// {@template popover_layout_allow_invert_horizontal}
  /// Whether to allow horizontal flipping.
  ///
  /// *Type*: `bool`
  ///
  /// If true, the popover can flip horizontally when near screen edges.
  /// {@endtemplate}
  final bool allowInvertHorizontal;

  /// {@template popover_layout_allow_invert_vertical}
  /// Whether to allow vertical flipping.
  ///
  /// *Type*: `bool`
  ///
  /// If true, the popover can flip vertically when near screen edges.
  /// {@endtemplate}
  final bool allowInvertVertical;

  /// {@template popover_layout_fixed_size}
  /// Fixed dimensions for the popover.
  ///
  /// *Type*: `Size?`
  ///
  /// Used when width or height constraint is [PopoverConstraint.fixed].
  /// {@endtemplate}
  final Size? fixedSize;

  /// Creates a PopoverLayout with the specified parameters.
  ///
  /// {@macro popover_layout}
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
    required Widget super.child,
    required this.scale,
    required this.scaleAlignment,
    this.filterQuality,
    this.allowInvertHorizontal = true,
    this.allowInvertVertical = true,
    this.fixedSize,
  });

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
      scale: scale,
      scaleAlignment: scaleAlignment,
      filterQuality: filterQuality,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      fixedSize: fixedSize,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant PopoverLayoutRender renderObject) {
    bool hasChanged = false;

    // Only update properties that changed to minimize repaints
    if (renderObject._alignment != alignment) {
      renderObject._alignment = alignment;
      hasChanged = true;
    }
    if (renderObject._position != position) {
      renderObject._position = position;
      hasChanged = true;
    }
    if (renderObject._anchorAlignment != anchorAlignment) {
      renderObject._anchorAlignment = anchorAlignment;
      hasChanged = true;
    }
    if (renderObject._widthConstraint != widthConstraint) {
      renderObject._widthConstraint = widthConstraint;
      hasChanged = true;
    }
    if (renderObject._heightConstraint != heightConstraint) {
      renderObject._heightConstraint = heightConstraint;
      hasChanged = true;
    }
    if (renderObject._anchorSize != anchorSize) {
      renderObject._anchorSize = anchorSize;
      hasChanged = true;
    }
    if (renderObject._offset != offset) {
      renderObject._offset = offset;
      hasChanged = true;
    }
    if (renderObject._margin != margin) {
      renderObject._margin = margin;
      hasChanged = true;
    }
    if (renderObject._scale != scale) {
      renderObject._scale = scale;
      hasChanged = true;
    }
    if (renderObject._scaleAlignment != scaleAlignment) {
      renderObject._scaleAlignment = scaleAlignment;
      hasChanged = true;
    }
    if (renderObject._filterQuality != filterQuality) {
      renderObject._filterQuality = filterQuality;
      hasChanged = true;
    }
    if (renderObject._allowInvertHorizontal != allowInvertHorizontal) {
      renderObject._allowInvertHorizontal = allowInvertHorizontal;
      hasChanged = true;
    }
    if (renderObject._allowInvertVertical != allowInvertVertical) {
      renderObject._allowInvertVertical = allowInvertVertical;
      hasChanged = true;
    }
    if (renderObject._fixedSize != fixedSize) {
      renderObject._fixedSize = fixedSize;
      hasChanged = true;
    }

    if (hasChanged) {
      renderObject.markNeedsLayout();
    }
  }
}

/// {@template popover_layout_render}
/// # PopoverLayoutRender
///
/// The render object implementation for [PopoverLayout] that handles positioning,
/// layout, transformations, and compositing.
///
/// This specialized render object efficiently calculates popover positioning,
/// applies size constraints, handles screen edge detection, and performs
/// transformation for animations.
///
/// ## Key Features
///
/// - **Efficient Positioning**: Optimized calculation of popover position
/// - **Smart Edge Detection**: Flips popovers when they would overflow screen edges
/// - **Performance Optimizations**: Caching of calculations and transformations
/// - **Hardware Acceleration**: Uses optimized layers for transformations
/// - **Coordinate Transformation**: Handles hit-testing with transforms
///
/// ## Implementation Details
///
/// The render object applies several optimizations:
///
/// 1. **Transform Caching**: Avoids recalculating transforms when possible
/// 2. **Constraint Caching**: Reuses constraint calculations
/// 3. **Selective Updates**: Only invalidates layout when necessary
/// 4. **Adaptive Compositing**: Uses appropriate layer types based on transform
/// 5. **Quality Control**: Adapts image quality based on performance needs
///
/// This is an internal implementation detail that works with [PopoverLayout].
/// {@endtemplate}
class PopoverLayoutRender extends RenderShiftedBox {
  Alignment _alignment;
  Alignment _anchorAlignment;
  Offset? _position;
  Size? _anchorSize;
  PopoverConstraint _widthConstraint;
  PopoverConstraint _heightConstraint;
  Offset? _offset;
  EdgeInsets _margin;
  double _scale;
  Alignment _scaleAlignment;
  FilterQuality? _filterQuality;
  bool _allowInvertHorizontal;
  bool _allowInvertVertical;
  Size? _fixedSize;

  bool _invertX = false;
  bool _invertY = false;

  // Cache for layout calculations
  Matrix4? _lastTransform;
  BoxConstraints? _lastConstraints;
  BoxConstraints? _lastChildConstraints;

  /// Creates a [PopoverLayoutRender] with the given parameters.
  ///
  /// {@macro popover_layout_render}
  PopoverLayoutRender({
    RenderBox? child,
    required Alignment alignment,
    required Offset? position,
    required Alignment anchorAlignment,
    required PopoverConstraint widthConstraint,
    required PopoverConstraint heightConstraint,
    Size? anchorSize,
    Offset? offset,
    EdgeInsets margin = const EdgeInsets.all(8),
    required double scale,
    required Alignment scaleAlignment,
    FilterQuality? filterQuality,
    bool allowInvertHorizontal = true,
    bool allowInvertVertical = true,
    Size? fixedSize,
  })  : _alignment = alignment,
        _position = position,
        _anchorAlignment = anchorAlignment,
        _widthConstraint = widthConstraint,
        _heightConstraint = heightConstraint,
        _anchorSize = anchorSize,
        _offset = offset,
        _margin = margin,
        _scale = scale,
        _scaleAlignment = scaleAlignment,
        _filterQuality = filterQuality,
        _allowInvertHorizontal = allowInvertHorizontal,
        _allowInvertVertical = allowInvertVertical,
        _fixedSize = fixedSize,
        super(child);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  Matrix4 get _effectiveTransform {
    if (_lastTransform != null) return _lastTransform!;

    Size childSize = child!.size;
    Offset childOffset = (child!.parentData as BoxParentData).offset;
    var scaleAlignment = _scaleAlignment;
    if (_invertX || _invertY) {
      scaleAlignment = Alignment(
        _invertX ? -scaleAlignment.x : scaleAlignment.x,
        _invertY ? -scaleAlignment.y : scaleAlignment.y,
      );
    }

    // Optimize transform calculation by reusing matrix
    Matrix4 transform = Matrix4.identity();

    // Apply transform operations in correct order
    // 1. Move to child's position
    transform.translate(childOffset.dx, childOffset.dy);

    // 2. Move to alignment point within child
    Offset alignmentTranslation = scaleAlignment.alongSize(childSize);
    transform.translate(alignmentTranslation.dx, alignmentTranslation.dy);

    // 3. Apply scale
    transform.scale(_scale, _scale);

    // 4. Move back from alignment point
    transform.translate(-alignmentTranslation.dx, -alignmentTranslation.dy);

    // 5. Move back from child's position
    transform.translate(-childOffset.dx, -childOffset.dy);

    _lastTransform = transform;
    return transform;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    Matrix4 effectiveTransform = _effectiveTransform;
    transform.multiply(effectiveTransform);
    super.applyPaintTransform(child, transform);
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _filterQuality != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final Matrix4 transform = _effectiveTransform;

      // Optimize image filtering based on scale
      if (_filterQuality == null || _scale == 1.0) {
        final Offset? childOffset = MatrixUtils.getAsTranslation(transform);
        if (childOffset != null) {
          // Simple translation - no need for a transform layer
          super.paint(context, offset + childOffset);
          layer = null;
        } else {
          // Use transform layer for complex transforms
          final double det = transform.determinant();
          if (det == 0 || !det.isFinite) {
            layer = null;
            return; // Invalid transform
          }

          layer = context.pushTransform(
            needsCompositing,
            offset,
            transform,
            super.paint,
            oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
          );
        }
      } else {
        // Use image filter for scaled rendering with quality control
        final Matrix4 effectiveTransform =
            Matrix4.translationValues(offset.dx, offset.dy, 0.0)
              ..multiply(transform)
              ..translate(-offset.dx, -offset.dy);

        final ui.ImageFilter filter = ui.ImageFilter.matrix(
          effectiveTransform.storage,
          filterQuality: _filterQuality!,
        );

        // Reuse existing filter layer when possible
        if (layer is ImageFilterLayer) {
          final ImageFilterLayer filterLayer = layer! as ImageFilterLayer;
          filterLayer.imageFilter = filter;
        } else {
          layer = ImageFilterLayer(imageFilter: filter);
        }

        context.pushLayer(layer!, super.paint, offset);
      }
    }
  }

  // Optimized constraint calculation
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Return cached constraints if they haven't changed
    if (_lastConstraints == constraints && _lastChildConstraints != null) {
      return _lastChildConstraints!;
    }

    double minWidth = 0;
    double maxWidth = constraints.maxWidth;
    double minHeight = 0;
    double maxHeight = constraints.maxHeight;

    // Handle width constraints
    if (_widthConstraint == PopoverConstraint.fixed) {
      assert(_fixedSize != null,
          'fixedSize must not be null when using PopoverConstraint.fixed');
      minWidth = maxWidth = _fixedSize!.width;
    } else if (_widthConstraint == PopoverConstraint.fullScreen) {
      minWidth = maxWidth = constraints.maxWidth;
    } else if (_widthConstraint == PopoverConstraint.contentSize) {
      // Only calculate intrinsic width when necessary
      final double intrinsicWidth =
          child!.getMaxIntrinsicWidth(double.infinity);
      if (intrinsicWidth.isFinite) {
        minWidth = maxWidth = intrinsicWidth;
      }
    } else if (_widthConstraint == PopoverConstraint.anchorFixedSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      minWidth = maxWidth = _anchorSize!.width;
    } else if (_widthConstraint == PopoverConstraint.anchorMinSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      minWidth = _anchorSize!.width;
    } else if (_widthConstraint == PopoverConstraint.anchorMaxSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      maxWidth = _anchorSize!.width;
    } else if (_widthConstraint == PopoverConstraint.intrinsic) {
      // Only calculate intrinsic width when necessary
      final double intrinsicWidth =
          child!.getMaxIntrinsicWidth(double.infinity);
      if (intrinsicWidth.isFinite) {
        maxWidth = max(minWidth, intrinsicWidth);
      }
    }

    // Handle height constraints
    if (_heightConstraint == PopoverConstraint.fixed) {
      assert(_fixedSize != null,
          'fixedSize must not be null when using PopoverConstraint.fixed');
      minHeight = maxHeight = _fixedSize!.height;
    } else if (_heightConstraint == PopoverConstraint.fullScreen) {
      minHeight = maxHeight = constraints.maxHeight;
    } else if (_heightConstraint == PopoverConstraint.contentSize) {
      // Only calculate intrinsic height when necessary
      final double intrinsicHeight =
          child!.getMaxIntrinsicHeight(double.infinity);
      if (intrinsicHeight.isFinite) {
        minHeight = maxHeight = intrinsicHeight;
      }
    } else if (_heightConstraint == PopoverConstraint.anchorFixedSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      minHeight = maxHeight = _anchorSize!.height;
    } else if (_heightConstraint == PopoverConstraint.anchorMinSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      minHeight = _anchorSize!.height;
    } else if (_heightConstraint == PopoverConstraint.anchorMaxSize) {
      assert(_anchorSize != null, 'anchorSize must not be null');
      maxHeight = _anchorSize!.height;
    } else if (_heightConstraint == PopoverConstraint.intrinsic) {
      // Only calculate intrinsic height when necessary
      final double intrinsicHeight =
          child!.getMaxIntrinsicHeight(double.infinity);
      if (intrinsicHeight.isFinite) {
        maxHeight = max(minHeight, intrinsicHeight);
      }
    }

    // Cache and return the computed constraints
    _lastConstraints = constraints;
    _lastChildConstraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    return _lastChildConstraints!;
  }

  @override
  void performLayout() {
    // Layout child with calculated constraints
    child!.layout(getConstraintsForChild(constraints), parentUsesSize: true);
    size = constraints.biggest;

    Size childSize = child!.size;
    double offsetX = _offset?.dx ?? 0;
    double offsetY = _offset?.dy ?? 0;

    // Get or calculate position
    var position = _position;
    position ??= Offset(
      size.width / 2 + size.width / 2 * _anchorAlignment.x,
      size.height / 2 + size.height / 2 * _anchorAlignment.y,
    );

    // Calculate initial position
    double x = position.dx -
        childSize.width / 2 -
        (childSize.width / 2 * _alignment.x);
    double y = position.dy -
        childSize.height / 2 -
        (childSize.height / 2 * _alignment.y);

    // Account for margins
    double left = x - _margin.left;
    double top = y - _margin.top;
    double right = x + childSize.width + _margin.right;
    double bottom = y + childSize.height + _margin.bottom;

    // Handle horizontal overflow by inverting if needed
    bool shouldInvertX =
        (left < 0 || right > size.width) && _allowInvertHorizontal;
    if (shouldInvertX) {
      x = position.dx -
          childSize.width / 2 -
          (childSize.width / 2 * -_alignment.x);
      if (_anchorSize != null) {
        x -= _anchorSize!.width * _anchorAlignment.x;
      }
      left = x - _margin.left;
      right = x + childSize.width + _margin.right;
      offsetX *= -1;
      _invertX = true;
    } else {
      _invertX = false;
    }

    // Handle vertical overflow by inverting if needed
    bool shouldInvertY =
        (top < 0 || bottom > size.height) && _allowInvertVertical;
    if (shouldInvertY) {
      y = position.dy -
          childSize.height / 2 -
          (childSize.height / 2 * -_alignment.y);
      if (_anchorSize != null) {
        y -= _anchorSize!.height * _anchorAlignment.y;
      }
      top = y - _margin.top;
      bottom = y + childSize.height + _margin.bottom;
      offsetY *= -1;
      _invertY = true;
    } else {
      _invertY = false;
    }

    // Apply final adjustments to keep popover on screen
    final double dx = left < 0
        ? -left
        : right > size.width
            ? size.width - right
            : 0;
    final double dy = top < 0
        ? -top
        : bottom > size.height
            ? size.height - bottom
            : 0;

    // Set final position
    Offset result = Offset(x + dx + offsetX, y + dy + offsetY);
    BoxParentData childParentData = child!.parentData as BoxParentData;
    childParentData.offset = result;

    // Clear transform cache since position changed
    _lastTransform = null;
  }

  @override
  void markNeedsLayout() {
    // Clear caches when layout needs to be recalculated
    _lastTransform = null;
    _lastConstraints = null;
    _lastChildConstraints = null;
    super.markNeedsLayout();
  }
}
