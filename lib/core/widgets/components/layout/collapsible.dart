import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controller to manage state & progress of a collapsible widget (expand/collapse)
class CollapsibleController extends ChangeNotifier {
  bool _isExpanded;
  double _expansionProgress;
  final String _id = UniqueKey().toString().substring(0, 8);

  /// Creates a controller with an initial expanded state
  CollapsibleController({bool initialExpanded = false})
      : _isExpanded = initialExpanded,
        _expansionProgress = initialExpanded ? 1.0 : 0.0;

  /// Whether the collapsible is currently expanded
  bool get isExpanded => _isExpanded;

  /// Progress of expansion (0.0 collapsed, 1.0 fully expanded)
  double get expansionProgress => _expansionProgress;

  /// For debug logging
  String get debugId => _id;

  /// Set expansion progress directly (useful for animation)
  set expansionProgress(double value) {
    final newValue = value.clamp(0.0, 1.0);
    if (_expansionProgress != newValue) {
      _expansionProgress = newValue;
      // Optionally: auto update _isExpanded if progress threshold crossed
      final wasExpanded = _isExpanded;
      _isExpanded = _expansionProgress > 0.5;

      if (wasExpanded != _isExpanded) {
        // Optionally notify only if expanded state changed, or always notify (here: always notify)
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  /// Expand fully (with optional force progress update)
  void expand() {
    if (!_isExpanded || _expansionProgress != 1.0) {
      _isExpanded = true;
      _expansionProgress = 1.0;

      notifyListeners();
    }
  }

  /// Collapse fully (with optional force progress update)
  void collapse() {
    if (_isExpanded || _expansionProgress != 0.0) {
      _isExpanded = false;
      _expansionProgress = 0.0;

      notifyListeners();
    }
  }

  /// Toggle expanded/collapsed state
  void toggle() {
    _isExpanded ? collapse() : expand();
  }

  /// Directly set expanded state, with optional partial/animated effect
  void setExpanded(bool value, {bool animate = false}) {
    if (_isExpanded != value) {
      _isExpanded = value;
      _expansionProgress = value ? 1.0 : 0.0;

      notifyListeners();
    }
  }

  /// Partial expansion (for gestures/drag)
  void setPartialExpansion(double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    final wasExpanded = _isExpanded;
    _expansionProgress = clamped;
    _isExpanded = clamped > 0.5;

    // Notify if either progress or expanded state changed
    if (wasExpanded != _isExpanded ||
        (_expansionProgress - clamped).abs() > 0.001) {
      notifyListeners();
    }
  }
}

/// Defines how a collapsible widget animates
enum CollapsibleAnimationType {
  /// Smoothly slides and fades content
  sizeAndFade,

  /// Only changes the size without fading
  sizeOnly,

  /// Only fades the content without size animation
  fadeOnly,

  /// Slide content from top
  slideFromTop,

  /// Slide content from bottom
  slideFromBottom,

  /// Slide content from left
  slideFromLeft,

  /// Slide content from right
  slideFromRight,

  /// Scale content from center
  scale,

  /// Rotate content while expanding/collapsing
  rotate,

  /// No animation at all
  none,

  /// Custom animation provided by user
  custom
}

/// Defines the direction of expansion
enum ExpansionDirection {
  /// Expands downward (default)
  down,

  /// Expands upward
  up,

  /// Expands to the right
  right,

  /// Expands to the left
  left,

  /// Expands in all directions from center
  center,
}

/// Theme configuration for collapsible widgets
class CollapsibleTheme {
  /// Padding around the trigger widget
  final EdgeInsets? triggerPadding;

  /// Icon shown when the collapsible is expanded
  final IconData expandedIcon;

  /// Icon shown when the collapsible is collapsed
  final IconData collapsedIcon;

  /// Space between the trigger content and icon
  final double iconGap;

  /// Horizontal alignment of the children
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical alignment of the children
  final MainAxisAlignment mainAxisAlignment;

  /// Text style for expandable text buttons
  final TextStyle? textButtonStyle;

  /// Duration of the expand/collapse animation
  final Duration animationDuration;

  /// Curve used for animations
  final Curve animationCurve;

  /// Curve used for collapse animations (fallback to animationCurve if null)
  final Curve? collapseAnimationCurve;

  /// Type of animation to use
  final CollapsibleAnimationType animationType;

  /// Border radius for the trigger
  final BorderRadius? triggerBorderRadius;

  /// Background color for the trigger when hovered
  final Color? hoverColor;

  /// Background color for the trigger when pressed
  final Color? pressedColor;

  /// Background color for the trigger when focused
  final Color? focusColor;

  /// Background color for the trigger when disabled
  final Color? disabledColor;

  /// Color of the divider (if used)
  final Color? dividerColor;

  /// Height of the divider (if used)
  final double dividerThickness;

  /// Padding before the content
  final EdgeInsets contentPadding;

  /// Direction in which the content expands
  final ExpansionDirection expansionDirection;

  /// Border radius for the content
  final BorderRadius? contentBorderRadius;

  /// Background color for the content
  final Color? contentBackgroundColor;

  /// Gradient for content background
  final Gradient? contentGradient;

  /// Border for the content
  final Border? contentBorder;

  /// Shadow for the content
  final List<BoxShadow>? contentShadow;

  /// Border for the trigger
  final Border? triggerBorder;

  /// Gradient for trigger background
  final Gradient? triggerGradient;

  /// Background color for the trigger
  final Color? triggerBackgroundColor;

  /// Color for expanded icon
  final Color? expandedIconColor;

  /// Color for collapsed icon
  final Color? collapsedIconColor;

  /// Size for expanded icon
  final double? expandedIconSize;

  /// Size for collapsed icon
  final double? collapsedIconSize;

  /// Icon rotation angle for expanded state (in radians)
  final double expandedIconRotation;

  /// Icon rotation angle for collapsed state (in radians)
  final double collapsedIconRotation;

  /// Custom hover effect for trigger
  final HoverEffect hoverEffect;

  /// Maximum height constraint for content
  final double? maxContentHeight;

  /// Maximum width constraint for content
  final double? maxContentWidth;

  /// Content overflow behavior
  final Clip contentOverflow;

  /// Creates a theme for collapsible widgets
  const CollapsibleTheme({
    this.triggerPadding,
    this.expandedIcon = Icons.keyboard_arrow_up,
    this.collapsedIcon = Icons.keyboard_arrow_down,
    this.iconGap = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textButtonStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOutCubic,
    this.collapseAnimationCurve,
    this.animationType = CollapsibleAnimationType.sizeAndFade,
    this.triggerBorderRadius,
    this.hoverColor,
    this.pressedColor,
    this.focusColor,
    this.disabledColor,
    this.dividerColor,
    this.dividerThickness = 1.0,
    this.contentPadding = EdgeInsets.zero,
    this.expansionDirection = ExpansionDirection.down,
    this.contentBorderRadius,
    this.contentBackgroundColor,
    this.contentGradient,
    this.contentBorder,
    this.contentShadow,
    this.triggerBorder,
    this.triggerGradient,
    this.triggerBackgroundColor,
    this.expandedIconColor,
    this.collapsedIconColor,
    this.expandedIconSize,
    this.collapsedIconSize,
    this.expandedIconRotation = 0.0,
    this.collapsedIconRotation = 0.0,
    this.hoverEffect = HoverEffect.color,
    this.maxContentHeight,
    this.maxContentWidth,
    this.contentOverflow = Clip.hardEdge,
  });

  /// Creates a copy of this theme with specific properties changed
  CollapsibleTheme copyWith({
    EdgeInsets? triggerPadding,
    IconData? expandedIcon,
    IconData? collapsedIcon,
    double? iconGap,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    TextStyle? textButtonStyle,
    Duration? animationDuration,
    Curve? animationCurve,
    Curve? collapseAnimationCurve,
    CollapsibleAnimationType? animationType,
    BorderRadius? triggerBorderRadius,
    Color? hoverColor,
    Color? pressedColor,
    Color? focusColor,
    Color? disabledColor,
    Color? dividerColor,
    double? dividerThickness,
    EdgeInsets? contentPadding,
    ExpansionDirection? expansionDirection,
    BorderRadius? contentBorderRadius,
    Color? contentBackgroundColor,
    Gradient? contentGradient,
    Border? contentBorder,
    List<BoxShadow>? contentShadow,
    Border? triggerBorder,
    Gradient? triggerGradient,
    Color? triggerBackgroundColor,
    Color? expandedIconColor,
    Color? collapsedIconColor,
    double? expandedIconSize,
    double? collapsedIconSize,
    double? expandedIconRotation,
    double? collapsedIconRotation,
    HoverEffect? hoverEffect,
    double? maxContentHeight,
    double? maxContentWidth,
    Clip? contentOverflow,
  }) {
    return CollapsibleTheme(
      triggerPadding: triggerPadding ?? this.triggerPadding,
      expandedIcon: expandedIcon ?? this.expandedIcon,
      collapsedIcon: collapsedIcon ?? this.collapsedIcon,
      iconGap: iconGap ?? this.iconGap,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      textButtonStyle: textButtonStyle ?? this.textButtonStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      collapseAnimationCurve:
          collapseAnimationCurve ?? this.collapseAnimationCurve,
      animationType: animationType ?? this.animationType,
      triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
      hoverColor: hoverColor ?? this.hoverColor,
      pressedColor: pressedColor ?? this.pressedColor,
      focusColor: focusColor ?? this.focusColor,
      disabledColor: disabledColor ?? this.disabledColor,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      contentPadding: contentPadding ?? this.contentPadding,
      expansionDirection: expansionDirection ?? this.expansionDirection,
      contentBorderRadius: contentBorderRadius ?? this.contentBorderRadius,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
      contentGradient: contentGradient ?? this.contentGradient,
      contentBorder: contentBorder ?? this.contentBorder,
      contentShadow: contentShadow ?? this.contentShadow,
      triggerBorder: triggerBorder ?? this.triggerBorder,
      triggerGradient: triggerGradient ?? this.triggerGradient,
      triggerBackgroundColor:
          triggerBackgroundColor ?? this.triggerBackgroundColor,
      expandedIconColor: expandedIconColor ?? this.expandedIconColor,
      collapsedIconColor: collapsedIconColor ?? this.collapsedIconColor,
      expandedIconSize: expandedIconSize ?? this.expandedIconSize,
      collapsedIconSize: collapsedIconSize ?? this.collapsedIconSize,
      expandedIconRotation: expandedIconRotation ?? this.expandedIconRotation,
      collapsedIconRotation:
          collapsedIconRotation ?? this.collapsedIconRotation,
      hoverEffect: hoverEffect ?? this.hoverEffect,
      maxContentHeight: maxContentHeight ?? this.maxContentHeight,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      contentOverflow: contentOverflow ?? this.contentOverflow,
    );
  }

  /// Creates a theme for collapsible widgets from the current app theme
  factory CollapsibleTheme.fromContext(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CollapsibleTheme(
      triggerPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      expandedIcon: Icons.keyboard_arrow_up,
      collapsedIcon: Icons.keyboard_arrow_down,
      iconGap: 8.0,
      textButtonStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      hoverColor: colorScheme.onSurface.withValues(alpha: 0.05),
      pressedColor: colorScheme.onSurface.withValues(alpha: 0.1),
      focusColor: colorScheme.primary.withValues(alpha: 0.1),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      dividerColor: colorScheme.outlineVariant,
      contentBackgroundColor: colorScheme.surface,
      triggerBorderRadius: BorderRadius.circular(4.0),
      expandedIconColor: colorScheme.primary,
      collapsedIconColor: colorScheme.onSurface.withValues(alpha: 0.75),
    );
  }
}

/// Defines the hover effect for trigger elements
enum HoverEffect {
  /// Changes background color on hover
  color,

  /// Scales element slightly on hover
  scale,

  /// Shows an elevation shadow on hover
  elevation,

  /// Shows a border on hover
  border,

  /// No hover effect
  none,
}

/// Defines the interaction mode for triggers
enum TriggerInteractionMode {
  /// Standard tap/click interaction
  tap,

  /// Hover activates expansion
  hover,

  /// Long press activates expansion
  longPress,

  /// Double tap activates expansion
  doubleTap,

  /// Dragging activates expansion
  drag,

  /// Custom interaction mode
  custom,
}

class AppCollapsible extends StatefulWidget {
  final List<Widget> children; // [trigger, content]
  final bool initialExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final ValueChanged<double>? onProgressChanged;
  final CollapsibleTheme? theme;
  final bool maintainState;
  final bool showDivider;
  final CollapsibleController? controller;
  final bool enabled;
  final TriggerInteractionMode interactionMode;
  final String? semanticsLabel;
  final String? semanticsHint;

  const AppCollapsible({
    super.key,
    required this.children,
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.onProgressChanged,
    this.theme,
    this.maintainState = false,
    this.showDivider = false,
    this.controller,
    this.enabled = true,
    this.interactionMode = TriggerInteractionMode.tap,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible>
    with TickerProviderStateMixin {
  late CollapsibleController _controller;
  late CollapsibleTheme _effectiveTheme;
  late AnimationController _animController;
  bool _isHovering = false;
  final bool _isPressed = false;
  late final FocusNode _focusNode;
  final String _debugId = UniqueKey().toString().substring(0, 8);

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _controller = widget.controller ??
        CollapsibleController(initialExpanded: widget.initialExpanded);
    _effectiveTheme = widget.theme ?? const CollapsibleTheme();

    _animController = AnimationController(
      vsync: this,
      duration: _effectiveTheme.animationDuration,
      value: _controller.isExpanded ? 1.0 : 0.0,
    );

    _controller.addListener(_handleControllerChanged);
    _animController.addListener(_handleAnimationTick);
  }

  @override
  void didUpdateWidget(AppCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if it changed
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChanged);
      _controller = widget.controller ??
          CollapsibleController(initialExpanded: widget.initialExpanded);
      _controller.addListener(_handleControllerChanged);
      _animController.value = _controller.isExpanded ? 1.0 : 0.0;
    }

    // Update theme if it changed
    if (widget.theme != oldWidget.theme) {
      _effectiveTheme = widget.theme ?? const CollapsibleTheme();
      _animController.duration = _effectiveTheme.animationDuration;
    }

    // Update initialExpanded if it changed
    if (widget.initialExpanded != oldWidget.initialExpanded &&
        widget.controller == null &&
        oldWidget.controller == null) {
      if (_controller.isExpanded != widget.initialExpanded) {
        _controller.setExpanded(widget.initialExpanded);
      }
    }
  }

  void _handleAnimationTick() {
    // Notify external listeners about animation progress
    widget.onProgressChanged?.call(_animController.value);
    setState(() {});
  }

  void _handleControllerChanged() {
    if (_controller.isExpanded && _animController.value != 1.0) {
      _animController.animateTo(
        1.0,
        duration: _effectiveTheme.animationDuration,
        curve: _effectiveTheme.animationCurve,
      );
    } else if (!_controller.isExpanded && _animController.value != 0.0) {
      _animController.animateTo(
        0.0,
        duration: _effectiveTheme.animationDuration,
        curve: _effectiveTheme.collapseAnimationCurve ??
            _effectiveTheme.animationCurve,
      );
    }
    widget.onExpansionChanged?.call(_controller.isExpanded);
    widget.onProgressChanged?.call(_controller.expansionProgress);

    setState(() {});
  }

  void _toggleExpanded() {
    if (!widget.enabled) return;

    _controller.toggle();
  }

  void _handleHoverChanged(bool isHovering) {
    if (isHovering != _isHovering) {
      setState(() {
        _isHovering = isHovering;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // We'll implement a simple drag to expand/collapse
    // Negative delta.dy means dragging up, which should expand
    // Positive delta.dy means dragging down, which should collapse
    final delta = details.delta.dy;
    final currentValue = _controller.expansionProgress;

    // Calculate new progress value
    final maxDragDistance = 50.0; // Pixels needed for full expansion/collapse
    final dragProgress = delta / maxDragDistance;
    final newValue = (currentValue - dragProgress).clamp(0.0, 1.0);

    // Update controller
    _controller.setPartialExpansion(newValue);
  }

  void _handleDragEnd(DragEndDetails details) {
    // When drag ends, decide whether to fully expand or collapse
    final velocity = details.velocity.pixelsPerSecond.dy;
    final threshold = 0.5;

    if (_controller.expansionProgress > threshold || velocity < -500) {
      _controller.expand();
    } else {
      _controller.collapse();
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_handleAnimationTick);
    _animController.dispose();

    _controller.removeListener(_handleControllerChanged);
    if (widget.controller == null) {
      // Only dispose the controller if we created it internally
      _controller.dispose();
    }

    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get trigger and content widgets from children
    final Widget? trigger =
        widget.children.isNotEmpty ? widget.children[0] : null;
    final Widget? content =
        widget.children.length > 1 ? widget.children[1] : null;

    // Apply semantics for accessibility
    Widget result = Semantics(
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      expanded: _controller.isExpanded,
      toggled: _controller.isExpanded,
      child: _buildCollapsibleContent(trigger, content),
    );

    // Provide CollapsibleScope to descendants
    return _CollapsibleScope(
      controller: _controller,
      toggleExpanded: _toggleExpanded,
      theme: _effectiveTheme,
      maintainState: widget.maintainState,
      showDivider: widget.showDivider,
      enabled: widget.enabled,
      animationController: _animController,
      isHovering: _isHovering,
      isPressed: _isPressed,
      focusNode: _focusNode,
      onHoverChanged: _handleHoverChanged,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      interactionMode: widget.interactionMode,
      semanticsLabel: widget.semanticsLabel,
      semanticsHint: widget.semanticsHint,
      debugId: _debugId,
      child: result,
    );
  }

  Widget _buildCollapsibleContent(Widget? trigger, Widget? content) {
    return Column(
      crossAxisAlignment: _effectiveTheme.crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trigger != null) trigger,
        if (widget.showDivider && content != null)
          Divider(
            height: _effectiveTheme.dividerThickness,
            thickness: _effectiveTheme.dividerThickness,
            color: _effectiveTheme.dividerColor,
          ),
        if (content != null)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              // Build animated content based on animation type
              return _buildAnimatedContent(
                content: content,
                animation: _animController,
                theme: _effectiveTheme,
                maintainState: widget.maintainState,
                debugId: _debugId,
              );
            },
          ),
      ],
    );
  }

  // Helper method to build animated content
  Widget _buildAnimatedContent({
    required Widget content,
    required Animation<double> animation,
    required CollapsibleTheme theme,
    required bool maintainState,
    required String debugId,
  }) {
    final effectiveAnimation = CurvedAnimation(
      parent: animation,
      curve: theme.animationCurve,
      reverseCurve: theme.collapseAnimationCurve ?? theme.animationCurve,
    );

    switch (theme.animationType) {
      case CollapsibleAnimationType.sizeAndFade:
        return SizeTransition(
          sizeFactor: effectiveAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: effectiveAnimation,
              curve: const Interval(0.4, 1.0),
            ),
            child: maintainState
                ? Visibility(
                    visible: animation.value > 0,
                    maintainState: true,
                    child: content,
                  )
                : content,
          ),
        );

      case CollapsibleAnimationType.sizeOnly:
        return SizeTransition(
          sizeFactor: effectiveAnimation,
          axisAlignment: -1.0,
          child: maintainState
              ? Visibility(
                  visible: _controller.isExpanded,
                  maintainState: true,
                  child: content,
                )
              : content,
        );

      case CollapsibleAnimationType.fadeOnly:
        return FadeTransition(
          opacity: effectiveAnimation,
          child: maintainState
              ? Visibility(
                  visible: _controller.isExpanded,
                  maintainState: true,
                  child: content,
                )
              : content,
        );

      case CollapsibleAnimationType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(effectiveAnimation),
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(effectiveAnimation),
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.2, 0),
            end: Offset.zero,
          ).animate(effectiveAnimation),
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(effectiveAnimation),
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.scale:
        return ScaleTransition(
          scale: effectiveAnimation,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.rotate:
        return RotationTransition(
          turns:
              Tween<double>(begin: 0.05, end: 0.0).animate(effectiveAnimation),
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );

      case CollapsibleAnimationType.none:
        return _controller.isExpanded ? content : const SizedBox.shrink();

      case CollapsibleAnimationType.custom:
        // For custom animations, fall back to size and fade
        return SizeTransition(
          sizeFactor: effectiveAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: effectiveAnimation,
            child: content,
          ),
        );
    }
  }
}

/// InheritedWidget that provides collapsible state to descendant widgets
class _CollapsibleScope extends InheritedWidget {
  final CollapsibleController controller;
  final VoidCallback toggleExpanded;
  final CollapsibleTheme theme;
  final bool maintainState;
  final bool showDivider;
  final bool enabled;
  final AnimationController animationController;
  final bool isHovering;
  final bool isPressed;
  final FocusNode focusNode;
  final Function(bool) onHoverChanged;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final TriggerInteractionMode interactionMode;
  final String? semanticsLabel;
  final String? semanticsHint;
  final String debugId;

  const _CollapsibleScope({
    required this.controller,
    required this.toggleExpanded,
    required this.theme,
    required super.child,
    required this.maintainState,
    required this.showDivider,
    required this.enabled,
    required this.animationController,
    required this.isHovering,
    required this.isPressed,
    required this.focusNode,
    required this.onHoverChanged,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.interactionMode,
    this.semanticsLabel,
    this.semanticsHint,
    required this.debugId,
  });

  /// Look up the nearest _CollapsibleScope instance from the given context
  static _CollapsibleScope? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_CollapsibleScope>();

    return scope;
  }

  @override
  bool updateShouldNotify(_CollapsibleScope oldWidget) {
    final shouldNotify = controller != oldWidget.controller ||
        theme != oldWidget.theme ||
        maintainState != oldWidget.maintainState ||
        enabled != oldWidget.enabled ||
        showDivider != oldWidget.showDivider ||
        isHovering != oldWidget.isHovering ||
        isPressed != oldWidget.isPressed ||
        focusNode != oldWidget.focusNode ||
        interactionMode != oldWidget.interactionMode;

    return shouldNotify;
  }
}

/// Predefined collapsible section with title and content
class AppCollapsibleSection extends StatefulWidget {
  /// Title widget shown as the trigger
  final Widget title;

  /// Content to show when expanded
  final Widget content;

  /// Whether to start expanded
  final bool initialExpanded;

  /// Custom icon for collapsed state
  final IconData? collapsedIcon;

  /// Custom icon for expanded state
  final IconData? expandedIcon;

  /// Called when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether to show a divider between title and content
  final bool showDivider;

  /// Custom content padding
  final EdgeInsets? contentPadding;

  /// Theme configuration (optional)
  final CollapsibleTheme? theme;

  /// Icon position relative to title
  final IconPosition iconPosition;

  /// Controller for programmatic control
  final CollapsibleController? controller;

  /// Custom icon builder
  final Widget Function(BuildContext, bool)? iconBuilder;

  /// Whether the section can be toggled by user
  final bool enabled;

  /// Interaction mode for the trigger
  final TriggerInteractionMode interactionMode;

  const AppCollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.initialExpanded = false,
    this.collapsedIcon,
    this.expandedIcon,
    this.onExpansionChanged,
    this.showDivider = false,
    this.contentPadding,
    this.theme,
    this.iconPosition = IconPosition.end,
    this.controller,
    this.iconBuilder,
    this.enabled = true,
    this.interactionMode = TriggerInteractionMode.tap,
  });

  @override
  State<AppCollapsibleSection> createState() => _AppCollapsibleSectionState();
}

class _AppCollapsibleSectionState extends State<AppCollapsibleSection> {
  @override
  Widget build(BuildContext context) {
    // Create a theme that combines the provided theme with specific overrides
    final effectiveTheme = (widget.theme ?? const CollapsibleTheme()).copyWith(
      collapsedIcon: widget.collapsedIcon ?? (widget.theme?.collapsedIcon),
      expandedIcon: widget.expandedIcon ?? (widget.theme?.expandedIcon),
      contentPadding: widget.contentPadding ?? (widget.theme?.contentPadding),
    );

    return AppCollapsible(
      initialExpanded: widget.initialExpanded,
      onExpansionChanged: widget.onExpansionChanged,
      theme: effectiveTheme,
      showDivider: widget.showDivider,
      controller: widget.controller,
      enabled: widget.enabled,
      interactionMode: widget.interactionMode,
      children: [
        AppCollapsibleTrigger(
          iconPosition: widget.iconPosition,
          iconBuilder: widget.iconBuilder,
          child: widget.title,
        ),
        AppCollapsibleContent(
          child: widget.content,
        ),
      ],
    );
  }
}

/// Trigger widget for a collapsible to toggle expansion state
class AppCollapsibleTrigger extends StatefulWidget {
  /// Content to display in the trigger
  final Widget child;

  /// Whether to show the expand/collapse icon
  final bool showIcon;

  /// Custom padding override
  final EdgeInsets? padding;

  /// Tooltip text for accessibility
  final String? tooltip;

  /// Position of the icon relative to content
  final IconPosition iconPosition;

  /// Custom icon widget to use instead of default
  final Widget Function(BuildContext, bool)? iconBuilder;

  /// Background decoration for the trigger
  final Decoration? decoration;

  /// Additional gestures to handle (besides the primary interaction)
  final Map<Type, GestureRecognizerFactory>? gestureRecognizers;

  /// Custom state builders for different interaction states
  final Widget Function(BuildContext, Widget, bool)? hoveredBuilder;
  final Widget Function(BuildContext, Widget, bool)? pressedBuilder;
  final Widget Function(BuildContext, Widget, bool)? focusedBuilder;
  final Widget Function(BuildContext, Widget, bool)? disabledBuilder;

  /// Custom interaction handler
  final bool Function(BuildContext, PointerDownEvent)? onInteraction;

  /// Creates a trigger for a collapsible
  const AppCollapsibleTrigger({
    super.key,
    required this.child,
    this.showIcon = true,
    this.padding,
    this.tooltip,
    this.iconPosition = IconPosition.end,
    this.iconBuilder,
    this.decoration,
    this.gestureRecognizers,
    this.hoveredBuilder,
    this.pressedBuilder,
    this.focusedBuilder,
    this.disabledBuilder,
    this.onInteraction,
  });

  @override
  State<AppCollapsibleTrigger> createState() => _AppCollapsibleTriggerState();
}

class _AppCollapsibleTriggerState extends State<AppCollapsibleTrigger> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Find the collapsible scope
    final scope = _CollapsibleScope.maybeOf(context);

    // Check for missing scope
    if (scope == null) {
      assert(scope != null,
          'AppCollapsibleTrigger must be a child of AppCollapsible');
      return widget.child; // Fallback to just showing the child
    }

    final theme = scope.theme;
    final effectivePadding =
        widget.padding ?? theme.triggerPadding ?? EdgeInsets.zero;

    Widget? icon;
    if (widget.showIcon) {
      if (widget.iconBuilder != null) {
        icon = widget.iconBuilder!(context, scope.controller.isExpanded);
      } else {
        final iconData = scope.controller.isExpanded
            ? theme.expandedIcon
            : theme.collapsedIcon;
        final iconColor = scope.controller.isExpanded
            ? theme.expandedIconColor
            : theme.collapsedIconColor;
        final iconSize = scope.controller.isExpanded
            ? theme.expandedIconSize
            : theme.collapsedIconSize;
        final rotationAngle = scope.controller.isExpanded
            ? theme.expandedIconRotation
            : theme.collapsedIconRotation;

        icon = Transform.rotate(
          angle: rotationAngle,
          child: Icon(
            iconData,
            size: iconSize ?? 20,
            color: iconColor,
          ),
        );
      }

      if (widget.tooltip != null) {
        icon = Tooltip(
          message: widget.tooltip ??
              (scope.controller.isExpanded ? 'Collapse' : 'Expand'),
          child: icon,
        );
      }
    }

    Widget content;

    // Arrange icon and content based on position
    if (icon == null) {
      content = widget.child;
    } else {
      switch (widget.iconPosition) {
        case IconPosition.start:
          content = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: theme.iconGap),
              Expanded(child: widget.child),
            ],
          );
          break;
        case IconPosition.end:
          content = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: widget.child),
              SizedBox(width: theme.iconGap),
              icon,
            ],
          );
          break;
        case IconPosition.top:
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: theme.iconGap),
              widget.child,
            ],
          );
          break;
        case IconPosition.bottom:
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.child,
              SizedBox(height: theme.iconGap),
              icon,
            ],
          );
          break;
      }
    }

    // Determine background color based on state
    Color? backgroundColor = theme.triggerBackgroundColor;
    if (!scope.enabled) {
      backgroundColor = theme.disabledColor ?? backgroundColor;
    } else if (_isPressed) {
      backgroundColor = theme.pressedColor ?? backgroundColor;
    } else if (_isHovering) {
      backgroundColor = theme.hoverColor ?? backgroundColor;
    } else if (scope.focusNode.hasFocus) {
      backgroundColor = theme.focusColor ?? backgroundColor;
    }

    // Apply hover effect if specified
    Widget effectiveContent = content;
    if (scope.enabled && theme.hoverEffect != HoverEffect.none) {
      switch (theme.hoverEffect) {
        case HoverEffect.scale:
          effectiveContent = AnimatedScale(
            scale: _isHovering ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: content,
          );
          break;
        case HoverEffect.elevation:
          effectiveContent = AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: content,
          );
          break;
        case HoverEffect.border:
          effectiveContent = AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isHovering
                    ? (theme.expandedIconColor ??
                        Theme.of(context).colorScheme.primary)
                    : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: theme.triggerBorderRadius,
            ),
            child: content,
          );
          break;
        default:
          effectiveContent = content;
      }
    }

    // Apply custom state builders if provided
    if (widget.hoveredBuilder != null && _isHovering) {
      effectiveContent = widget.hoveredBuilder!(
          context, effectiveContent, scope.controller.isExpanded);
    } else if (widget.pressedBuilder != null && _isPressed) {
      effectiveContent = widget.pressedBuilder!(
          context, effectiveContent, scope.controller.isExpanded);
    } else if (widget.focusedBuilder != null && scope.focusNode.hasFocus) {
      effectiveContent = widget.focusedBuilder!(
          context, effectiveContent, scope.controller.isExpanded);
    } else if (widget.disabledBuilder != null && !scope.enabled) {
      effectiveContent = widget.disabledBuilder!(
          context, effectiveContent, scope.controller.isExpanded);
    }

    // Setup interaction handlers based on interaction mode
    void handleTap() {
      if (scope.enabled &&
          scope.interactionMode == TriggerInteractionMode.tap) {
        scope.toggleExpanded();
      }
    }

    void handleLongPress() {
      if (scope.enabled &&
          scope.interactionMode == TriggerInteractionMode.longPress) {
        scope.toggleExpanded();
      }
    }

    void handleDoubleTap() {
      if (scope.enabled &&
          scope.interactionMode == TriggerInteractionMode.doubleTap) {
        scope.toggleExpanded();
      }
    }

    void handleHoverChange(bool value) {
      if (scope.enabled) {
        scope.onHoverChanged(value);

        if (scope.interactionMode == TriggerInteractionMode.hover) {
          if (value) {
            scope.controller.expand();
          } else {
            scope.controller.collapse();
          }
        }

        setState(() => _isHovering = value);
      }
    }

    void handlePointerDown(PointerDownEvent event) {
      setState(() => _isPressed = true);

      if (widget.onInteraction != null) {
        if (widget.onInteraction!(context, event)) {
          scope.toggleExpanded();
        }
      }
    }

    void handlePointerUp(PointerUpEvent event) {
      setState(() => _isPressed = false);
    }

    void handlePointerCancel(PointerCancelEvent event) {
      setState(() => _isPressed = false);
    }

    // Build final widget with decoration
    final decoration = widget.decoration ??
        BoxDecoration(
          color: backgroundColor,
          gradient: theme.triggerGradient,
          borderRadius: theme.triggerBorderRadius,
          border: theme.triggerBorder,
        );

    return Focus(
      focusNode: scope.focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          scope.toggleExpanded();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: handlePointerDown,
        onPointerUp: handlePointerUp,
        onPointerCancel: handlePointerCancel,
        child: MouseRegion(
          onEnter: (_) => handleHoverChange(true),
          onExit: (_) => handleHoverChange(false),
          cursor: scope.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: handleTap,
            onLongPress: handleLongPress,
            onDoubleTap: handleDoubleTap,
            onVerticalDragUpdate:
                scope.interactionMode == TriggerInteractionMode.drag
                    ? (details) => scope.onDragUpdate(details)
                    : null,
            onVerticalDragEnd:
                scope.interactionMode == TriggerInteractionMode.drag
                    ? (details) => scope.onDragEnd(details)
                    : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              decoration: decoration,
              padding: effectivePadding,
              child: effectiveContent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Content of a collapsible that can be shown or hidden
class AppCollapsibleContent extends StatelessWidget {
  /// Content to show when expanded
  final Widget child;

  /// Whether this content should collapse/expand
  final bool collapsible;

  /// Whether to animate the transition
  final bool animate;

  /// Custom padding around the content
  final EdgeInsets? padding;

  /// Custom constraints for the content
  final BoxConstraints? constraints;

  /// Custom clip behavior for the content
  final Clip? clipBehavior;

  /// Custom alignment for the content
  final Alignment? alignment;

  /// Custom decoration for the content
  final Decoration? decoration;

  /// Creates collapsible content
  const AppCollapsibleContent({
    super.key,
    required this.child,
    this.collapsible = true,
    this.animate = true,
    this.padding,
    this.constraints,
    this.clipBehavior,
    this.alignment,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final scope = _CollapsibleScope.maybeOf(context);
    UniqueKey().toString().substring(0, 8);

    // Check for missing scope
    if (scope == null) {
      assert(scope != null,
          'AppCollapsibleContent must be a child of AppCollapsible');
      return child; // Fallback to just showing the child
    }

    // Skip collapsing if not collapsible
    if (!collapsible) {
      return Padding(
        padding: padding ?? scope.theme.contentPadding,
        child: child,
      );
    }

    // Skip animation if requested
    if (!scope.controller.isExpanded && !animate) {
      return const SizedBox.shrink();
    }

    Widget content = child;

    // Apply content styling if defined
    if (decoration != null ||
        scope.theme.contentBackgroundColor != null ||
        scope.theme.contentBorderRadius != null ||
        scope.theme.contentBorder != null ||
        scope.theme.contentShadow != null ||
        scope.theme.contentGradient != null) {
      final effectiveDecoration = decoration ??
          BoxDecoration(
            color: scope.theme.contentBackgroundColor,
            gradient: scope.theme.contentGradient,
            borderRadius: scope.theme.contentBorderRadius,
            border: scope.theme.contentBorder,
            boxShadow: scope.theme.contentShadow,
          );

      content = Container(
        decoration: effectiveDecoration,
        child: content,
      );
    }

    // Apply constraint limits if specified
    if (constraints != null ||
        scope.theme.maxContentHeight != null ||
        scope.theme.maxContentWidth != null) {
      final effectiveConstraints = constraints ??
          BoxConstraints(
            maxHeight: scope.theme.maxContentHeight ?? double.infinity,
            maxWidth: scope.theme.maxContentWidth ?? double.infinity,
          );

      content = ConstrainedBox(
        constraints: effectiveConstraints,
        child: content,
      );
    }

    // Apply clip behavior if specified
    final effectiveClipBehavior = clipBehavior ?? scope.theme.contentOverflow;
    if (effectiveClipBehavior != Clip.none) {
      content = ClipRect(
        clipBehavior: effectiveClipBehavior,
        child: content,
      );
    }

    // Apply alignment if specified
    if (alignment != null) {
      content = Align(
        alignment: alignment!,
        child: content,
      );
    }

    // Apply padding
    content = Padding(
      padding: padding ?? scope.theme.contentPadding,
      child: content,
    );

    // Create the animated wrapper for the content
    return AnimatedBuilder(
      animation: scope.animationController,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: scope.animationController,
          curve: scope.theme.animationCurve,
          reverseCurve: scope.theme.collapseAnimationCurve,
        );

        // Create different animations based on the animation type
        switch (scope.theme.animationType) {
          case CollapsibleAnimationType.sizeAndFade:
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.4, 1.0),
                ),
                child: scope.maintainState
                    ? Visibility(
                        visible: animation.value > 0,
                        maintainState: true,
                        child: child!,
                      )
                    : child,
              ),
            );

          case CollapsibleAnimationType.sizeOnly:
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: scope.maintainState
                  ? Visibility(
                      visible: scope.controller.isExpanded,
                      maintainState: true,
                      child: child!,
                    )
                  : child,
            );

          // Other animation types handled in similar fashion
          default:
            // Default fallback
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: scope.animationController.value,
                child: Opacity(
                  opacity: scope.animationController.value,
                  child: child!,
                ),
              ),
            );
        }
      },
      child: content,
    );
  }
}

/// Text that can be expanded to show more content when truncated
class AppExpandableText extends StatefulWidget {
  /// The text to display
  final String text;

  /// Maximum lines to show when collapsed
  final int maxLines;

  /// Style for the text
  final TextStyle? style;

  /// Text for the "read more" button
  final String expandText;

  /// Text for the "read less" button
  final String collapseText;

  /// Whether to start expanded
  final bool initialExpanded;

  /// Called when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Theme configuration
  final CollapsibleTheme? theme;

  /// Widget to show before the expand/collapse text
  final Widget? expandCollapsePrefix;

  /// Widget to show after the expand/collapse text
  final Widget? expandCollapseSuffix;

  /// Controller for programmatic control
  final CollapsibleController? controller;

  /// Creates expandable text
  const AppExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    this.expandText = 'Read more',
    this.collapseText = 'Read less',
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.theme,
    this.expandCollapsePrefix,
    this.expandCollapseSuffix,
    this.controller,
  });

  @override
  State<AppExpandableText> createState() => _AppExpandableTextState();
}

class _AppExpandableTextState extends State<AppExpandableText> {
  late CollapsibleController _controller;
  late final TextSpan _textSpan;
  bool _hasOverflow = false;
  late final CollapsibleTheme _effectiveTheme;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        CollapsibleController(initialExpanded: widget.initialExpanded);
    _effectiveTheme = widget.theme ?? const CollapsibleTheme();
    _textSpan = TextSpan(text: widget.text, style: widget.style);

    if (widget.controller == null) {
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(AppExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if it changed
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_handleControllerChanged);
      }

      _controller = widget.controller ??
          CollapsibleController(initialExpanded: widget.initialExpanded);

      if (widget.controller == null) {
        _controller.addListener(_handleControllerChanged);
      }
    }

    // Update text span if text or style changed
    if (widget.text != oldWidget.text || widget.style != oldWidget.style) {
      _textSpan = TextSpan(text: widget.text, style: widget.style);
    }

    // Update theme if it changed
    if (widget.theme != oldWidget.theme) {
      _effectiveTheme = widget.theme ?? const CollapsibleTheme();
    }

    // Handle initialExpanded changes when using internal controller
    if (widget.initialExpanded != oldWidget.initialExpanded &&
        widget.controller == null &&
        oldWidget.controller == null) {
      if (_controller.isExpanded != widget.initialExpanded) {
        _controller.setExpanded(widget.initialExpanded);
      }
    }
  }

  void _handleControllerChanged() {
    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(_controller.isExpanded);
    }
    setState(() {});
  }

  void _toggleExpanded() {
    _controller.toggle();

    if (widget.onExpansionChanged != null && widget.controller != null) {
      widget.onExpansionChanged!(_controller.isExpanded);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.removeListener(_handleControllerChanged);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textStyle = widget.style ?? defaultTextStyle.style;
    final buttonStyle = _effectiveTheme.textButtonStyle ??
        textStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: _textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        _hasOverflow = textPainter.didExceedMaxLines;

        if (!_hasOverflow) {
          return Text(
            widget.text,
            style: textStyle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                widget.text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
              secondChild: Text(
                widget.text,
                style: textStyle,
              ),
              crossFadeState: _controller.isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: _effectiveTheme.animationDuration,
              sizeCurve: _effectiveTheme.animationCurve,
            ),
            GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.expandCollapsePrefix != null) ...[
                      widget.expandCollapsePrefix!,
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _controller.isExpanded
                          ? widget.collapseText
                          : widget.expandText,
                      style: buttonStyle,
                    ),
                    if (widget.expandCollapseSuffix != null) ...[
                      const SizedBox(width: 4),
                      widget.expandCollapseSuffix!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated collapsible card with hover effects
class AppCollapsibleCard extends StatefulWidget {
  /// Title for the card
  final Widget title;

  /// Content to show when expanded
  final Widget content;

  /// Initial expanded state
  final bool initialExpanded;

  /// Animation type to use
  final CollapsibleAnimationType animationType;

  /// Custom theme configuration
  final CollapsibleTheme? theme;

  /// Whether to show elevation on hover
  final bool elevateOnHover;

  /// Callback when expanded state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Custom controller
  final CollapsibleController? controller;

  /// Creates a collapsible card
  const AppCollapsibleCard({
    super.key,
    required this.title,
    required this.content,
    this.initialExpanded = false,
    this.animationType = CollapsibleAnimationType.sizeAndFade,
    this.theme,
    this.elevateOnHover = true,
    this.onExpansionChanged,
    this.controller,
  });

  @override
  State<AppCollapsibleCard> createState() => _AppCollapsibleCardState();
}

class _AppCollapsibleCardState extends State<AppCollapsibleCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        (widget.theme ?? CollapsibleTheme.fromContext(context)).copyWith(
      animationType: widget.animationType,
      hoverEffect:
          widget.elevateOnHover ? HoverEffect.elevation : HoverEffect.color,
    );

    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovering = true;
      }),
      onExit: (_) => setState(() {
        _isHovering = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: effectiveTheme.contentBackgroundColor ??
              Theme.of(context).cardColor,
          borderRadius:
              effectiveTheme.contentBorderRadius ?? BorderRadius.circular(8),
          border: effectiveTheme.contentBorder,
          boxShadow: _isHovering && widget.elevateOnHover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ]
              : effectiveTheme.contentShadow,
        ),
        child: AppCollapsibleSection(
          title: widget.title,
          content: widget.content,
          initialExpanded: widget.initialExpanded,
          theme: effectiveTheme,
          onExpansionChanged: widget.onExpansionChanged != null
              ? (expanded) {
                  widget.onExpansionChanged!(expanded);
                }
              : null,
          controller: widget.controller,
        ),
      ),
    );
  }
}

/// Advanced draggable collapsible panel
class AppDraggableCollapsible extends StatefulWidget {
  /// Header widget that stays visible and can be dragged
  final Widget header;

  /// Content that collapses/expands
  final Widget content;

  /// Minimum height when collapsed
  final double minHeight;

  /// Maximum height when expanded
  final double maxHeight;

  /// Initial state (expanded or collapsed)
  final bool initialExpanded;

  /// Callback when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Callback when expansion progress changes (0.0-1.0)
  final ValueChanged<double>? onProgressChanged;

  /// Theme configuration
  final CollapsibleTheme? theme;

  /// Whether to add a drag handle indicator
  final bool showDragHandle;

  /// External controller for programmatic control
  final CollapsibleController? controller;

  /// Whether panel can be dragged by user
  final bool draggable;

  /// Creates a draggable collapsible panel
  const AppDraggableCollapsible({
    super.key,
    required this.header,
    required this.content,
    required this.minHeight,
    required this.maxHeight,
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.onProgressChanged,
    this.theme,
    this.showDragHandle = true,
    this.controller,
    this.draggable = true,
  });

  @override
  State<AppDraggableCollapsible> createState() =>
      _AppDraggableCollapsibleState();
}

class _AppDraggableCollapsibleState extends State<AppDraggableCollapsible>
    with SingleTickerProviderStateMixin {
  late CollapsibleController _controller;
  late AnimationController _animController;
  double _currentHeight = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _controller = widget.controller ??
        CollapsibleController(initialExpanded: widget.initialExpanded);

    // Set initial height based on expanded state
    _currentHeight =
        widget.initialExpanded ? widget.maxHeight : widget.minHeight;

    // Initialize animation controller
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.initialExpanded ? 1.0 : 0.0,
    );

    // Add listeners
    if (widget.controller == null) {
      _controller.addListener(_handleControllerChanged);
    }

    _animController.addListener(_handleAnimationChanged);
  }

  @override
  void didUpdateWidget(AppDraggableCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if needed
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_handleControllerChanged);
      }
      _controller = widget.controller ??
          CollapsibleController(initialExpanded: widget.initialExpanded);

      if (widget.controller == null) {
        _controller.addListener(_handleControllerChanged);
      }

      _updateFromController();
    }

    // Update heights if they changed
    if (widget.minHeight != oldWidget.minHeight ||
        widget.maxHeight != oldWidget.maxHeight) {
      _updateHeight();
    }
  }

  void _handleControllerChanged() {
    if (_controller.isExpanded) {
      _animController.animateTo(1.0);
    } else {
      _animController.animateTo(0.0);
    }

    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(_controller.isExpanded);
    }
  }

  void _handleAnimationChanged() {
    _updateHeight();

    if (widget.onProgressChanged != null) {
      widget.onProgressChanged!(_animController.value);
    }
  }

  void _updateHeight() {
    setState(() {
      _currentHeight = widget.minHeight +
          (widget.maxHeight - widget.minHeight) * _animController.value;
    });
  }

  void _updateFromController() {
    if (_controller.isExpanded && _animController.value == 0) {
      _animController.animateTo(1.0);
    } else if (!_controller.isExpanded && _animController.value == 1) {
      _animController.animateTo(0.0);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.draggable) return;

    setState(() {
      _isDragging = true;
      // Update height based on drag
      _currentHeight -= details.delta.dy;

      // Clamp to min/max range
      _currentHeight = _currentHeight.clamp(widget.minHeight, widget.maxHeight);

      // Calculate progress value
      final progress = (_currentHeight - widget.minHeight) /
          (widget.maxHeight - widget.minHeight);

      // Update animation controller without triggering animation
      _animController.value = progress;

      // Update controller state if crossed threshold
      if (progress > 0.5 && !_controller.isExpanded) {
        _controller.setExpanded(true, animate: false);
        if (widget.onExpansionChanged != null) {
          widget.onExpansionChanged!(true);
        }
      } else if (progress <= 0.5 && _controller.isExpanded) {
        _controller.setExpanded(false, animate: false);
        if (widget.onExpansionChanged != null) {
          widget.onExpansionChanged!(false);
        }
      }

      // Report progress
      if (widget.onProgressChanged != null) {
        widget.onProgressChanged!(progress);
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.draggable) return;

    final velocity = details.primaryVelocity ?? 0;
    final expand = velocity < 0 ||
        _currentHeight > (widget.maxHeight + widget.minHeight) / 2;

    setState(() {
      _isDragging = false;

      // Animate to final position
      if (expand) {
        _animController.animateTo(1.0);
        if (!_controller.isExpanded) {
          _controller.setExpanded(true, animate: false);
          if (widget.onExpansionChanged != null) {
            widget.onExpansionChanged!(true);
          }
        }
      } else {
        _animController.animateTo(0.0);
        if (_controller.isExpanded) {
          _controller.setExpanded(false, animate: false);
          if (widget.onExpansionChanged != null) {
            widget.onExpansionChanged!(false);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.removeListener(_handleControllerChanged);
      _controller.dispose();
    }
    _animController.removeListener(_handleAnimationChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? CollapsibleTheme.fromContext(context);

    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: AnimatedContainer(
        duration:
            _isDragging ? Duration.zero : const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        height: _currentHeight,
        decoration: BoxDecoration(
          color: theme.contentBackgroundColor,
          borderRadius: theme.contentBorderRadius,
          boxShadow: theme.contentShadow,
        ),
        child: ClipRRect(
          borderRadius: theme.contentBorderRadius ?? BorderRadius.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag handle
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    if (widget.showDragHandle)
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    widget.header,
                  ],
                ),
              ),

              // Content with scrolling
              Expanded(
                child: SingleChildScrollView(
                  physics: _animController.value < 1.0
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: theme.contentPadding,
                    child: widget.content,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Position options for icons in collapsible triggers
enum IconPosition {
  /// Icon shown at start (left)
  start,

  /// Icon shown at end (right)
  end,

  /// Icon shown above content
  top,

  /// Icon shown below content
  bottom,
}
