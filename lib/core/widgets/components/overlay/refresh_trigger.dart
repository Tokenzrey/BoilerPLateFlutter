import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Callback for refresh operations that return a Future
typedef FutureVoidCallback = Future<void> Function();

/// Builder function for custom refresh indicators
typedef RefreshIndicatorBuilder = Widget Function(
    BuildContext context, RefreshTriggerStage stage);

/// Notifier for refresh state changes
typedef RefreshNotifier = void Function(TriggerStage state);

/// Filter callback to decide if a notification should be handled
typedef NotificationFilter = bool Function(ScrollNotification notification);

/// Configuration for animation timing and behavior
class RefreshAnimationConfig {
  /// Curve for the animation
  final Curve curve;

  /// Duration for the completed state before returning to idle
  final Duration completeDuration;

  /// Duration for indicator transitions
  final Duration transitionDuration;

  /// Duration for fade animations between states
  final Duration fadeDuration;

  /// Specific curve for pulling stage
  final Curve? pullingCurve;

  /// Specific curve for refreshing stage
  final Curve? refreshingCurve;

  /// Specific curve for completed stage
  final Curve? completedCurve;

  /// Specific curve for error stage
  final Curve? errorCurve;

  /// Duration for snap-back animation
  final Duration snapBackDuration;

  /// Whether to snap the indicator to the min extent during refresh
  final bool enableSnapEffect;

  const RefreshAnimationConfig({
    this.curve = Curves.easeOutSine,
    this.completeDuration = const Duration(milliseconds: 500),
    this.transitionDuration = const Duration(milliseconds: 300),
    this.fadeDuration = const Duration(milliseconds: 200),
    this.pullingCurve,
    this.refreshingCurve,
    this.completedCurve,
    this.errorCurve,
    this.snapBackDuration = const Duration(milliseconds: 200),
    this.enableSnapEffect = false,
  });
}

/// Configuration for indicator placement and appearance
class IndicatorPlacementConfig {
  /// Offset from edge in main axis direction
  final double offset;

  /// Alignment of the indicator within its container
  final Alignment alignment;

  /// Whether to float the indicator (overlay) or push content
  final bool floating;

  /// Optional padding around the indicator
  final EdgeInsets padding;

  /// Width constraint for the indicator
  final double? width;

  /// Height constraint for the indicator
  final double? height;

  const IndicatorPlacementConfig({
    this.offset = 0.0,
    this.alignment = Alignment.center,
    this.floating = false,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
  });
}

/// Result of a refresh operation
enum RefreshResult {
  /// Refresh completed successfully
  success,

  /// Refresh failed with an error
  error,

  /// Refresh was cancelled
  cancelled,
}

/// States of the refresh trigger
enum TriggerStage {
  /// Default state when not refreshing
  idle,

  /// User is pulling to trigger refresh
  pulling,

  /// Refresh operation is in progress
  refreshing,

  /// Refresh operation completed
  completed,

  /// Refresh operation failed
  error,
}

/// Main widget for pull-to-refresh functionality
class RefreshTrigger extends StatefulWidget {
  /// Default builder for the refresh indicator
  static Widget defaultIndicatorBuilder(
      BuildContext context, RefreshTriggerStage stage) {
    return DefaultRefreshIndicator(stage: stage);
  }

  /// Minimum extent required to trigger refresh
  final double minExtent;

  /// Maximum extent for visual feedback
  final double? maxExtent;

  /// Callback for refresh operation
  final FutureVoidCallback? onRefresh;

  /// Child widget that can be scrolled
  final Widget child;

  /// Direction of the refresh trigger (vertical or horizontal)
  final Axis direction;

  /// Whether to trigger from the opposite direction
  final bool reverse;

  /// Builder for custom indicator
  final RefreshIndicatorBuilder indicatorBuilder;

  final EdgeInsets indicatorMargin;

  /// Animation configuration
  final RefreshAnimationConfig animationConfig;

  /// Whether to only trigger refresh at scroll edges
  final bool triggerOnlyAtEdge;

  /// Optional semantic label for accessibility
  final String? semanticLabel;

  /// Callback when refresh state changes
  final RefreshNotifier? onStateChanged;

  /// Error builder for failed refresh
  final Widget Function(BuildContext, dynamic)? errorBuilder;

  /// History callback to track refresh operations
  final void Function(DateTime, RefreshResult)? onRefreshHistory;

  /// Whether to show indicator for manual refresh
  final bool showIndicatorOnManualRefresh;

  /// Debounce duration for multiple refresh triggers
  final Duration? debounceDuration;

  /// Configure the notification depth to handle (null = default depth 0)
  final int? notificationDepth;

  /// Custom filter for scroll notifications
  final NotificationFilter? shouldHandleNotification;

  /// Configuration for indicator placement
  final IndicatorPlacementConfig placementConfig;

  /// Styling for indicator (passed to builders)
  final Map<String, dynamic>? indicatorStyle;

  /// Whether to automatically keep scrolling position on refresh
  final bool maintainScrollPosition;

  const RefreshTrigger({
    super.key,
    this.minExtent = 75.0,
    this.maxExtent = 150.0,
    this.onRefresh,
    this.direction = Axis.vertical,
    this.reverse = false,
    this.indicatorBuilder = defaultIndicatorBuilder,
    this.indicatorMargin = const EdgeInsets.all(0),
    this.triggerOnlyAtEdge = true,
    this.semanticLabel,
    this.onStateChanged,
    this.errorBuilder,
    this.onRefreshHistory,
    this.showIndicatorOnManualRefresh = true,
    this.debounceDuration,
    this.notificationDepth,
    this.shouldHandleNotification,
    this.placementConfig = const IndicatorPlacementConfig(),
    this.indicatorStyle,
    this.maintainScrollPosition = true,
    RefreshAnimationConfig? animationConfig,
    required this.child,
  }) : animationConfig = animationConfig ?? const RefreshAnimationConfig();

  @override
  State<RefreshTrigger> createState() => RefreshTriggerState();
}

/// Stage information for the refresh indicator
class RefreshTriggerStage {
  /// Current stage of the refresh operation
  final TriggerStage stage;

  /// Animation value for the extent (between 0.0 and 1.0+)
  final Animation<double> extent;

  /// Direction of the refresh trigger
  final Axis direction;

  /// Whether the trigger is in reverse mode
  final bool reverse;

  /// Any error that occurred during refresh
  final dynamic error;

  /// When the last refresh occurred
  final DateTime? lastRefreshTime;

  /// Number of refreshes performed
  final int refreshCount;

  /// Whether refresh was manually triggered
  final bool isManualRefresh;

  /// Custom indicator styling
  final Map<String, dynamic>? style;

  const RefreshTriggerStage(
    this.stage,
    this.extent,
    this.direction, {
    required this.reverse,
    this.error,
    this.lastRefreshTime,
    this.refreshCount = 0,
    this.isManualRefresh = false,
    this.style,
  });

  /// The percent of progress for pulling (0.0 to 1.0)
  double get pullProgress => extent.value.clamp(0.0, 1.0);

  /// Whether the pull has reached the trigger threshold
  bool get canRefresh => extent.value >= 1.0;

  @override
  String toString() =>
      'RefreshTriggerStage($stage, ${extent.value}, reverse: $reverse)';
}

/// Default indicator implementation
class DefaultRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const DefaultRefreshIndicator({super.key, required this.stage});

  @override
  State<DefaultRefreshIndicator> createState() =>
      _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState extends State<DefaultRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.stage.stage == TriggerStage.refreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(DefaultRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stage.stage == TriggerStage.refreshing &&
        !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.stage.stage != TriggerStage.refreshing &&
        _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildRefreshingContent(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: widget.stage.isManualRefresh
          ? "Manually refreshing content"
          : "Refreshing content",
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(widget.stage.isManualRefresh
              ? 'Manual refresh...'
              : 'Refreshing...'),
          const SizedBox(width: 12),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget buildCompletedContent(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: "Refresh complete",
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          const Text('Completed'),
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget buildErrorContent(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: "Refresh failed",
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          const Text('Failed'),
          const SizedBox(width: 8),
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget buildPullingContent(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.stage.extent,
        builder: (context, child) {
          double angle;
          if (widget.stage.direction == Axis.vertical) {
            // Handle reverse mode correctly for vertical direction
            if (widget.stage.reverse) {
              // 0 -> 1 -> pi for bottom pull
              angle = pi * widget.stage.extent.value.clamp(0, 1);
            } else {
              // 0 -> 1 -> -pi for top pull
              angle = -pi * widget.stage.extent.value.clamp(0, 1);
            }
          } else {
            // Handle reverse mode correctly for horizontal direction
            if (widget.stage.reverse) {
              // Right pull
              angle = -pi / 2 + pi * widget.stage.extent.value.clamp(0, 1);
            } else {
              // Left pull
              angle = -pi / 2 - pi * widget.stage.extent.value.clamp(0, 1);
            }
          }

          // Arrow direction based on direction and reverse
          IconData arrowIcon;
          if (widget.stage.direction == Axis.vertical) {
            arrowIcon = widget.stage.reverse
                ? Icons.arrow_upward
                : Icons.arrow_downward;
          } else {
            arrowIcon =
                widget.stage.reverse ? Icons.arrow_back : Icons.arrow_forward;
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Transform.rotate(
                angle: angle,
                child: Icon(
                  arrowIcon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.stage.extent.value < 1
                      ? 'Pull to refresh'
                      : 'Release to refresh',
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: widget.stage.extent.value.clamp(0.0, 1.0),
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          );
        });
  }

  Widget buildIdleContent(BuildContext context) {
    // Get appropriate icon based on direction and reverse
    IconData arrowIcon;
    if (widget.stage.direction == Axis.vertical) {
      arrowIcon =
          widget.stage.reverse ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      arrowIcon = widget.stage.reverse ? Icons.arrow_back : Icons.arrow_forward;
    }

    final refreshTime = widget.stage.lastRefreshTime;
    final refreshCountText =
        widget.stage.refreshCount > 0 ? ' (${widget.stage.refreshCount}×)' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Icon(
          arrowIcon,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pull to refresh$refreshCountText'),
            if (refreshTime != null)
              Text(
                'Last: ${_formatDateTime(refreshTime)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(width: 8),
        Icon(
          arrowIcon,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        child = buildRefreshingContent(context);
        break;
      case TriggerStage.completed:
        child = buildCompletedContent(context);
        break;
      case TriggerStage.pulling:
        child = buildPullingContent(context);
        break;
      case TriggerStage.error:
        child = buildErrorContent(context);
        break;
      case TriggerStage.idle:
        child = buildIdleContent(context);
        break;
    }

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Card(
          key: ValueKey(widget.stage.stage),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: widget.stage.stage == TriggerStage.pulling
                ? const EdgeInsets.all(6)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A tween for the refresh trigger extent
class _RefreshTriggerTween extends Animatable<double> {
  final double minExtent;

  const _RefreshTriggerTween(this.minExtent);

  @override
  double transform(double t) {
    return t / minExtent;
  }
}

/// Main state class for RefreshTrigger
class RefreshTriggerState extends State<RefreshTrigger>
    with SingleTickerProviderStateMixin {
  // State variables
  double _currentExtent = 0;
  bool _scrolling = false;
  bool _isManualRefresh = false;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;
  TriggerStage _stage = TriggerStage.idle;
  Future<void>? _currentFuture;
  int _currentFutureCount = 0;
  DateTime? _lastRefreshTime;
  int _refreshCount = 0;
  dynamic _lastError;
  Timer? _debounceTimer;

  // Controller for animations
  late AnimationController _animationController;

  // For exposing state programmatically
  final ValueNotifier<bool> _isRefreshingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<TriggerStage> _stageNotifier =
      ValueNotifier<TriggerStage>(TriggerStage.idle);

  /// Public getter to check if refreshing is in progress
  bool get isRefreshing => _stage == TriggerStage.refreshing;

  /// ValueNotifier for observing refresh state
  ValueNotifier<bool> get refreshingNotifier => _isRefreshingNotifier;

  /// ValueNotifier for observing all stages
  ValueNotifier<TriggerStage> get stageNotifier => _stageNotifier;

  /// Get current refresh stage
  TriggerStage get currentStage => _stage;

  /// Get last error if any
  dynamic get lastError => _lastError;

  /// Get refresh count
  int get refreshCount => _refreshCount;

  /// Get last refresh time
  DateTime? get lastRefreshTime => _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.transitionDuration,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    _isRefreshingNotifier.dispose();
    _stageNotifier.dispose();
    super.dispose();
  }

  /// Calculate the indicator extent with deceleration
  double _calculateSafeExtent(double extent) {
    if (extent > widget.minExtent) {
      double relativeExtent = extent - widget.minExtent;
      double? maxExtent = widget.maxExtent;
      if (maxExtent == null) {
        return widget.minExtent;
      }
      double diff = (maxExtent - widget.minExtent) - relativeExtent;
      double diffNormalized = diff / (maxExtent - widget.minExtent);
      return maxExtent - _decelerateCurve(diffNormalized.clamp(0, 1)) * diff;
    }
    return extent;
  }

  /// Deceleration curve for smooth slowing
  double _decelerateCurve(double value) {
    return Curves.decelerate.transform(value);
  }

  /// Position the indicator widget based on configuration
  Widget _wrapPositioned(Widget child) {
    // Handle floating indicator separately with Positioned
    if (widget.placementConfig.floating) {
      // Calculate position based on direction and reverse
      if (widget.direction == Axis.vertical) {
        return Positioned(
          top: !widget.reverse ? widget.placementConfig.offset : null,
          bottom: widget.reverse ? widget.placementConfig.offset : null,
          left: 0,
          right: 0,
          child: Align(
            alignment: widget.placementConfig.alignment,
            child: Container(
              width: widget.placementConfig.width,
              height: widget.placementConfig.height,
              padding: widget.placementConfig.padding,
              child: child,
            ),
          ),
        );
      } else {
        return Positioned(
          top: 0,
          bottom: 0,
          left: !widget.reverse ? widget.placementConfig.offset : null,
          right: widget.reverse ? widget.placementConfig.offset : null,
          child: Align(
            alignment: widget.placementConfig.alignment,
            child: Container(
              width: widget.placementConfig.width,
              height: widget.placementConfig.height,
              padding: widget.placementConfig.padding,
              child: child,
            ),
          ),
        );
      }
    }

    // Non-floating indicator follows pull direction
    if (widget.direction == Axis.vertical) {
      return Positioned(
        top: !widget.reverse ? widget.indicatorMargin.top : null,
        bottom: widget.reverse ? widget.indicatorMargin.bottom : null,
        left: widget.indicatorMargin.left,
        right: widget.indicatorMargin.right,
        child: Container(
          width: widget.placementConfig.width,
          height: widget.placementConfig.height,
          padding: widget.placementConfig.padding,
          child: child,
        ),
      );
    } else {
      return Positioned(
        top: widget.indicatorMargin.top,
        bottom: widget.indicatorMargin.bottom,
        left: !widget.reverse ? widget.indicatorMargin.left : null,
        right: widget.reverse ? widget.indicatorMargin.right : null,
        child: Container(
          width: widget.placementConfig.width,
          height: widget.placementConfig.height,
          padding: widget.placementConfig.padding,
          child: child,
        ),
      );
    }
  }

  /// Get the offset direction based on orientation and reverse mode
  Offset _getOffset() {
    if (widget.direction == Axis.vertical) {
      return Offset(0, widget.reverse ? 1 : -1);
    } else {
      return Offset(widget.reverse ? 1 : -1, 0);
    }
  }

  /// Check if we can trigger a refresh at the current scroll position
  bool _canTriggerAtPosition(ScrollMetrics metrics) {
    if (!widget.triggerOnlyAtEdge) return true;

    if (widget.direction == Axis.vertical) {
      return widget.reverse
          ? metrics.pixels >= metrics.maxScrollExtent
          : metrics.pixels <= metrics.minScrollExtent;
    } else {
      return widget.reverse
          ? metrics.pixels >= metrics.maxScrollExtent
          : metrics.pixels <= metrics.minScrollExtent;
    }
  }

  /// Handle scroll notifications from the child
  bool _handleScrollNotification(ScrollNotification notification) {
    // Check if notification should be handled based on depth
    final int targetDepth = widget.notificationDepth ?? 0;
    if (notification.depth != targetDepth) {
      return false;
    }

    // Prevent handling during refresh/completed stages
    if (_stage == TriggerStage.refreshing || _stage == TriggerStage.completed) {
      return false;
    }

    // Apply custom notification filter if provided
    if (widget.shouldHandleNotification != null &&
        !widget.shouldHandleNotification!(notification)) {
      return false;
    }

    // Check if we should handle this scroll
    final canTrigger = _canTriggerAtPosition(notification.metrics);

    if (notification is ScrollEndNotification && _scrolling) {
      setState(() {
        if (_currentExtent >= widget.minExtent) {
          _scrolling = false;
          _triggerRefresh();
        } else {
          _setStage(TriggerStage.idle);
          _currentExtent = 0;
        }
      });
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null && canTrigger) {
        // Correctly handle delta based on direction and reverse
        final effectiveDelta = widget.reverse ? -delta : delta;

        if (_stage == TriggerStage.pulling) {
          // For vertical: negative delta = dragging down (or up in reverse)
          // For horizontal: negative delta = dragging right (or left in reverse)
          final isPullingCorrectDirection = effectiveDelta < 0;

          if (isPullingCorrectDirection) {
            setState(() {
              _currentExtent += effectiveDelta.abs();
              if (_currentExtent >= widget.minExtent &&
                  (_userScrollDirection == ScrollDirection.idle ||
                      (widget.direction == Axis.vertical &&
                          ((widget.reverse &&
                                  _userScrollDirection ==
                                      ScrollDirection.forward) ||
                              (!widget.reverse &&
                                  _userScrollDirection ==
                                      ScrollDirection.reverse))) ||
                      (widget.direction == Axis.horizontal &&
                          ((widget.reverse &&
                                  _userScrollDirection ==
                                      ScrollDirection.forward) ||
                              (!widget.reverse &&
                                  _userScrollDirection ==
                                      ScrollDirection.reverse))))) {
                // User has pulled enough and in the right direction
                _scrolling = false;
                _triggerRefresh();
              }
            });
          } else {
            // User is scrolling in opposite direction
            setState(() {
              _currentExtent = max(0, _currentExtent - effectiveDelta.abs());
              if (_currentExtent <= 0) {
                _setStage(TriggerStage.idle);
              }
            });
          }
        } else if (_stage == TriggerStage.idle &&
            effectiveDelta < 0 &&
            canTrigger) {
          // Start pulling state
          setState(() {
            _currentExtent = effectiveDelta.abs();
            _scrolling = true;
            _setStage(TriggerStage.pulling);
          });
        }
      }
    } else if (notification is UserScrollNotification) {
      _userScrollDirection = notification.direction;
    } else if (notification is OverscrollNotification && canTrigger) {
      // Handle overscroll correctly based on direction and reverse
      final effectiveOverscroll =
          widget.reverse ? -notification.overscroll : notification.overscroll;

      if (_stage == TriggerStage.idle && effectiveOverscroll < 0) {
        setState(() {
          _currentExtent = effectiveOverscroll.abs();
          _scrolling = true;
          _setStage(TriggerStage.pulling);
        });
      } else if (_stage == TriggerStage.pulling) {
        setState(() {
          _currentExtent += effectiveOverscroll < 0
              ? effectiveOverscroll.abs()
              : -effectiveOverscroll.abs();
          _currentExtent = max(0, _currentExtent);

          if (_currentExtent <= 0) {
            _setStage(TriggerStage.idle);
          } else if (_currentExtent >= widget.minExtent) {
            _scrolling = false;
            _triggerRefresh();
          }
        });
      }
    }

    return false;
  }

  /// Change the stage and notify
  void _setStage(TriggerStage newStage) {
    if (_stage != newStage) {
      setState(() {
        _stage = newStage;
        _stageNotifier.value = newStage;

        // Update isRefreshing notifier
        _isRefreshingNotifier.value = newStage == TriggerStage.refreshing;

        if (widget.onStateChanged != null) {
          widget.onStateChanged!(newStage);
        }

        // Announce for screen readers
        if (newStage == TriggerStage.refreshing) {
          SemanticsService.announce(
              _isManualRefresh
                  ? 'Manually refreshing content'
                  : 'Refreshing content',
              TextDirection.ltr,
              assertiveness: Assertiveness.assertive);
        } else if (newStage == TriggerStage.completed) {
          SemanticsService.announce('Refresh completed', TextDirection.ltr,
              assertiveness: Assertiveness.assertive);
        } else if (newStage == TriggerStage.error) {
          SemanticsService.announce('Refresh failed', TextDirection.ltr,
              assertiveness: Assertiveness.assertive);
        }
      });
    }
  }

  /// Trigger the refresh with optional debounce
  void _triggerRefresh() {
    // Check if debounce is enabled and a refresh is not already in progress
    if (widget.debounceDuration != null && _debounceTimer?.isActive != true) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration!, () {
        refresh();
      });
    } else {
      refresh();
    }
  }

  /// Initiate a refresh operation - exposed as public API
  Future<void> refresh([FutureVoidCallback? refreshCallback]) async {
    _scrolling = false;

    // Cancel any pending debounced refresh
    _debounceTimer?.cancel();

    int count = ++_currentFutureCount;
    if (_currentFuture != null) {
      // Wait for any current refresh to finish
      await _currentFuture;

      // If another call has been made, exit this one
      if (count != _currentFutureCount) {
        return;
      }
    }

    // Set this to true if manually triggered
    final wasManualRefresh = refreshCallback != null ||
        (refreshCallback == null && widget.onRefresh != null);
    if (wasManualRefresh && widget.showIndicatorOnManualRefresh) {
      setState(() {
        _isManualRefresh = true;
        _currentExtent = widget.minExtent; // Set extent to show indicator
        _setStage(TriggerStage.pulling); // First set to pulling briefly
      });

      // Wait briefly to show pulling state before moving to refreshing
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if widget is still mounted
      if (!mounted || count != _currentFutureCount) {
        return;
      }
    }

    setState(() {
      _currentFuture = _refresh(refreshCallback);
    });

    return _currentFuture!.whenComplete(() {
      if (!mounted || count != _currentFutureCount) {
        return;
      }

      setState(() {
        _currentFuture = null;

        // Record refresh history
        _lastRefreshTime = DateTime.now();
        _refreshCount++;

        if (widget.onRefreshHistory != null) {
          widget.onRefreshHistory!(_lastRefreshTime!,
              _lastError != null ? RefreshResult.error : RefreshResult.success);
        }

        // Set the appropriate completed stage
        _setStage(
            _lastError != null ? TriggerStage.error : TriggerStage.completed);

        // Reset after a delay
        Timer(widget.animationConfig.completeDuration, () {
          if (!mounted) {
            return;
          }
          setState(() {
            _setStage(TriggerStage.idle);
            _currentExtent = 0;
            _lastError = null;
            _isManualRefresh = false;
          });
        });
      });
    });
  }

  /// Execute the refresh callback
  Future<void> _refresh([FutureVoidCallback? refresh]) async {
    if (_stage != TriggerStage.refreshing) {
      _setStage(TriggerStage.refreshing);
    }

    refresh ??= widget.onRefresh;
    _lastError = null;

    try {
      return await (refresh?.call() ?? Future.value());
    } catch (error) {
      setState(() {
        _lastError = error;
      });
      return Future.value();
    }
  }

  /// Gets the animation curve based on the current stage
  Curve _getCurveForStage(TriggerStage stage) {
    switch (stage) {
      case TriggerStage.pulling:
        return widget.animationConfig.pullingCurve ??
            widget.animationConfig.curve;
      case TriggerStage.refreshing:
        return widget.animationConfig.refreshingCurve ??
            widget.animationConfig.curve;
      case TriggerStage.completed:
        return widget.animationConfig.completedCurve ??
            widget.animationConfig.curve;
      case TriggerStage.error:
        return widget.animationConfig.errorCurve ??
            widget.animationConfig.curve;
      default:
        return widget.animationConfig.curve;
    }
  }

  @override
  Widget build(BuildContext context) {
    var tween = _RefreshTriggerTween(widget.minExtent);

    // Apply snap effect for fixed indicator position during refresh
    final useSnapEffect = widget.animationConfig.enableSnapEffect;

    return Semantics(
      label: widget.semanticLabel ?? 'Pull to refresh',
      hint: "Pull to refresh content",
      liveRegion: true,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _animationController,
            ValueNotifier<double>(_currentExtent),
            ValueNotifier<TriggerStage>(_stage),
          ]),
          builder: (context, _) {
            final showIndicator = (_stage == TriggerStage.refreshing ||
                _stage == TriggerStage.completed ||
                _stage == TriggerStage.error ||
                _stage == TriggerStage.pulling && _currentExtent > 0);

            // Determine indicator position based on snap or normal behavior
            double indicatorExtent;
            if (useSnapEffect &&
                (_stage == TriggerStage.refreshing ||
                    _stage == TriggerStage.completed ||
                    _stage == TriggerStage.error)) {
              // Snap to minimum extent for consistent position
              indicatorExtent = widget.minExtent;
            } else {
              indicatorExtent = (_stage == TriggerStage.refreshing ||
                      _stage == TriggerStage.completed ||
                      _stage == TriggerStage.error)
                  ? widget.minExtent
                  : _currentExtent;
            }

            // Calculate curve based on current state
            final curve = _getCurveForStage(_stage);

            return Stack(
              fit: StackFit.passthrough,
              children: [
                widget.child,
                if (showIndicator)
                  Positioned.fill(
                    child: ClipRect(
                      child: Stack(
                        children: [
                          _wrapPositioned(
                            AnimatedContainer(
                              duration: widget.animationConfig.snapBackDuration,
                              curve: curve,
                              child: FractionalTranslation(
                                translation: _getOffset(),
                                child: Transform.translate(
                                  offset: widget.direction == Axis.vertical
                                      ? Offset(
                                          0,
                                          _calculateSafeExtent(
                                                  indicatorExtent) *
                                              (widget.reverse ? -1 : 1))
                                      : Offset(
                                          _calculateSafeExtent(
                                                  indicatorExtent) *
                                              (widget.reverse ? -1 : 1),
                                          0),
                                  child: widget.indicatorBuilder(
                                    context,
                                    RefreshTriggerStage(
                                      _lastError != null
                                          ? TriggerStage.error
                                          : _stage,
                                      tween.animate(AlwaysStoppedAnimation(
                                          indicatorExtent)),
                                      widget.direction,
                                      reverse: widget.reverse,
                                      error: _lastError,
                                      lastRefreshTime: _lastRefreshTime,
                                      refreshCount: _refreshCount,
                                      isManualRefresh: _isManualRefresh,
                                      style: widget.indicatorStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // This widget shows the error content if applicable
                if (_lastError != null &&
                    widget.errorBuilder != null &&
                    _stage == TriggerStage.error)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: widget.errorBuilder!(context, _lastError),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Animated check mark painter for completed state
class AnimatedCheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedCheckPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // First part of the check (shorter line)
    final firstPartProgress = progress * 2;
    if (firstPartProgress > 0) {
      final firstProgress = min(1.0, firstPartProgress);
      path.moveTo(size.width * 0.25, size.height * 0.5);
      path.lineTo(
        size.width * 0.25 + (size.width * 0.2) * firstProgress,
        size.height * 0.5 + (size.height * 0.2) * firstProgress,
      );
    }

    // Second part of the check (longer line)
    final secondPartProgress = max(0.0, progress * 2 - 1.0);
    if (secondPartProgress > 0) {
      path.moveTo(
        size.width * 0.45,
        size.height * 0.7,
      );
      path.lineTo(
        size.width * 0.45 + (size.width * 0.4) * secondPartProgress,
        size.height * 0.7 - (size.height * 0.4) * secondPartProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Modern indicator style with animated spinner
class ModernRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const ModernRefreshIndicator({super.key, required this.stage});

  @override
  State<ModernRefreshIndicator> createState() => _ModernRefreshIndicatorState();
}

class _ModernRefreshIndicatorState extends State<ModernRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.stage.stage == TriggerStage.refreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ModernRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stage.stage == TriggerStage.refreshing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Access custom style if provided
    final customStyles = widget.stage.style ?? {};
    final Color primaryColor =
        customStyles['primaryColor'] ?? theme.colorScheme.primary;
    final double height = customStyles['height'] ?? 60.0;
    final double indicatorSize = customStyles['indicatorSize'] ?? 24.0;
    final double fontSize = customStyles['fontSize'] ?? 16.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(theme, primaryColor, indicatorSize, fontSize),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Color primaryColor,
      double indicatorSize, double fontSize) {
    // Get appropriate icon based on direction and reverse
    IconData arrowIcon;
    if (widget.stage.direction == Axis.vertical) {
      arrowIcon =
          widget.stage.reverse ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      arrowIcon = widget.stage.reverse ? Icons.arrow_back : Icons.arrow_forward;
    }

    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        return Row(
          key: const ValueKey('refreshing'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: RotationTransition(
                turns: _controller,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.stage.isManualRefresh
                  ? 'Manual refresh...'
                  : 'Refreshing...',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 20),
          ],
        );

      case TriggerStage.completed:
        final refreshTime = widget.stage.lastRefreshTime;
        return Row(
          key: const ValueKey('completed'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: Icon(
                Icons.check,
                size: indicatorSize * 0.7,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refreshed',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                if (refreshTime != null)
                  Text(
                    'at ${_formatTime(refreshTime)}',
                    style: TextStyle(
                      fontSize: fontSize * 0.75,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
          ],
        );

      case TriggerStage.error:
        return Row(
          key: const ValueKey('error'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.error,
              ),
              child: Icon(
                Icons.close,
                size: indicatorSize * 0.7,
                color: theme.colorScheme.onError,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refresh failed',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  ),
                ),
                Text(
                  'Pull to try again',
                  style: TextStyle(
                    fontSize: fontSize * 0.75,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
          ],
        );

      case TriggerStage.pulling:
        final progress = widget.stage.pullProgress;
        return Row(
          key: const ValueKey('pulling'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  if (progress >= 1.0)
                    Icon(
                      arrowIcon,
                      size: indicatorSize * 0.7,
                      color: primaryColor,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              progress >= 1.0 ? 'Release to refresh' : 'Pull to refresh',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: primaryColor.withValues(alpha: progress),
              ),
            ),
            const SizedBox(width: 20),
          ],
        );

      case TriggerStage.idle:
        return Row(
          key: const ValueKey('idle'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            Icon(
              arrowIcon,
              size: indicatorSize * 0.8,
              color: primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 16),
            Text(
              'Pull to refresh',
              style: TextStyle(
                fontSize: fontSize,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 20),
          ],
        );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Water drop style indicator
class WaterDropRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const WaterDropRefreshIndicator({super.key, required this.stage});

  @override
  State<WaterDropRefreshIndicator> createState() =>
      _WaterDropRefreshIndicatorState();
}

class _WaterDropRefreshIndicatorState extends State<WaterDropRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.stage.stage == TriggerStage.refreshing) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(WaterDropRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stage.stage == TriggerStage.refreshing &&
        !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (widget.stage.stage != TriggerStage.refreshing &&
        _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Read custom styles if provided
    final customStyles = widget.stage.style ?? {};
    final Color primaryColor =
        customStyles['primaryColor'] ?? theme.colorScheme.primary;
    final double dropSize = customStyles['dropSize'] ?? 60.0;
    final double containerHeight = customStyles['height'] ?? 80.0;

    return Container(
      height: containerHeight,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStageContent(theme, primaryColor, dropSize),
      ),
    );
  }

  Widget _buildStageContent(
      ThemeData theme, Color primaryColor, double dropSize) {
    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        return _buildWaterDrop(
          theme,
          primaryColor: primaryColor,
          dropSize: dropSize,
          isAnimating: true,
          fillPercentage: 1.0,
          child: SizedBox(
            width: dropSize * 0.5,
            height: dropSize * 0.5,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    color: primaryColor.withValues(alpha: 0.3),
                    progress: _waveController.value,
                    waveHeight: dropSize * 0.08,
                  ),
                );
              },
            ),
          ),
        );

      case TriggerStage.completed:
        return _buildWaterDrop(
          theme,
          primaryColor: primaryColor,
          dropSize: dropSize,
          isCompleted: true,
          fillPercentage: 1.0,
          child: Icon(
            Icons.check,
            size: dropSize * 0.4,
            color: theme.colorScheme.onPrimary,
          ),
        );

      case TriggerStage.error:
        return _buildWaterDrop(
          theme,
          primaryColor: theme.colorScheme.error,
          dropSize: dropSize,
          isError: true,
          fillPercentage: 1.0,
          child: Icon(
            Icons.close,
            size: dropSize * 0.4,
            color: theme.colorScheme.onError,
          ),
        );

      case TriggerStage.pulling:
        final progress = widget.stage.pullProgress;

        // Get appropriate icon based on direction and reverse
        IconData arrowIcon;
        if (widget.stage.direction == Axis.vertical) {
          arrowIcon =
              widget.stage.reverse ? Icons.arrow_upward : Icons.arrow_downward;
        } else {
          arrowIcon =
              widget.stage.reverse ? Icons.arrow_back : Icons.arrow_forward;
        }

        return _buildWaterDrop(
          theme,
          primaryColor: primaryColor,
          dropSize: dropSize,
          fillPercentage: progress,
          child: progress >= 1.0
              ? Icon(
                  arrowIcon,
                  size: dropSize * 0.4,
                  color: Colors.white70,
                )
              : Icon(
                  arrowIcon,
                  size: dropSize * 0.4,
                  color: Colors.white.withValues(alpha: progress),
                ),
        );

      case TriggerStage.idle:
        // Get appropriate icon based on direction and reverse
        IconData arrowIcon;
        if (widget.stage.direction == Axis.vertical) {
          arrowIcon =
              widget.stage.reverse ? Icons.arrow_upward : Icons.arrow_downward;
        } else {
          arrowIcon =
              widget.stage.reverse ? Icons.arrow_back : Icons.arrow_forward;
        }

        return _buildWaterDrop(
          theme,
          primaryColor: primaryColor,
          dropSize: dropSize,
          fillPercentage: 0.0,
          child: Icon(
            arrowIcon,
            size: dropSize * 0.4,
            color: primaryColor.withValues(alpha: 0.5),
          ),
        );
    }
  }

  Widget _buildWaterDrop(
    ThemeData theme, {
    required Color primaryColor,
    required double dropSize,
    required Widget child,
    bool isAnimating = false,
    bool isCompleted = false,
    bool isError = false,
    required double fillPercentage,
  }) {
    final color = isError
        ? theme.colorScheme.error
        : (isCompleted ? primaryColor : primaryColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: dropSize,
          height: dropSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
        ),
        ClipOval(
          child: Container(
            width: dropSize,
            height: dropSize,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: dropSize,
              height: dropSize * fillPercentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.4),
                    color,
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Wave painter for water drop animation
class WavePainter extends CustomPainter {
  final Color color;
  final double progress;
  final double waveHeight;

  WavePainter({
    required this.color,
    required this.progress,
    this.waveHeight = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    // Starting point
    path.moveTo(0, height / 2);

    // Draw the wave
    for (double i = 0; i < width; i++) {
      final x = i;
      final sinValue = sin((progress * 2 * pi) + (i / width * 2 * pi));
      final y = (height / 2) + sinValue * waveHeight;
      path.lineTo(x, y);
    }

    // Complete the path
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.waveHeight != waveHeight;
  }
}

/// Lottie-style SVG animation indicator
class LottieStyleRefreshIndicator extends StatefulWidget {
  final RefreshTriggerStage stage;

  const LottieStyleRefreshIndicator({super.key, required this.stage});

  @override
  State<LottieStyleRefreshIndicator> createState() =>
      _LottieStyleRefreshIndicatorState();
}

class _LottieStyleRefreshIndicatorState
    extends State<LottieStyleRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.stage.stage == TriggerStage.refreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LottieStyleRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stage.stage == TriggerStage.refreshing &&
        !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.stage.stage != TriggerStage.refreshing &&
        _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read custom styles if provided
    final customStyles = widget.stage.style ?? {};
    final double containerSize = customStyles['containerSize'] ?? 100.0;
    final Color backgroundColor =
        customStyles['backgroundColor'] ?? Colors.white;
    final double borderRadius = customStyles['borderRadius'] ?? 20.0;

    return Center(
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildAnimation(),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    final theme = Theme.of(context);

    // Read custom styles if provided
    final customStyles = widget.stage.style ?? {};
    final Color primaryColor =
        customStyles['primaryColor'] ?? theme.colorScheme.primary;
    final Color errorColor =
        customStyles['errorColor'] ?? theme.colorScheme.error;

    switch (widget.stage.stage) {
      case TriggerStage.refreshing:
        return AnimatedBuilder(
          key: const ValueKey('refreshing'),
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: RefreshingPainter(
                progress: _controller.value,
                color: primaryColor,
              ),
            );
          },
        );

      case TriggerStage.completed:
        return AnimatedBuilder(
          key: const ValueKey('completed'),
          animation: const AlwaysStoppedAnimation<double>(1.0),
          builder: (context, child) {
            return CustomPaint(
              painter: SuccessPainter(
                color: primaryColor,
              ),
            );
          },
        );

      case TriggerStage.error:
        return AnimatedBuilder(
          key: const ValueKey('error'),
          animation: const AlwaysStoppedAnimation<double>(1.0),
          builder: (context, child) {
            return CustomPaint(
              painter: ErrorPainter(
                color: errorColor,
              ),
            );
          },
        );

      case TriggerStage.pulling:
        final progress = widget.stage.extent.value.clamp(0.0, 1.0);
        return AnimatedBuilder(
          key: const ValueKey('pulling'),
          animation: AlwaysStoppedAnimation<double>(progress),
          builder: (context, child) {
            return CustomPaint(
              painter: PullingPainter(
                progress: progress,
                color: primaryColor,
                isReady: progress >= 1.0,
                isReverse: widget.stage.reverse,
                direction: widget.stage.direction,
              ),
            );
          },
        );

      case TriggerStage.idle:
        return AnimatedBuilder(
          key: const ValueKey('idle'),
          animation: const AlwaysStoppedAnimation<double>(0.0),
          builder: (context, child) {
            return CustomPaint(
              painter: IdlePainter(
                color: primaryColor.withValues(alpha: 0.3),
                isReverse: widget.stage.reverse,
                direction: widget.stage.direction,
              ),
            );
          },
        );
    }
  }
}

/// Refreshing animation painter
class RefreshingPainter extends CustomPainter {
  final double progress;
  final Color color;

  RefreshingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw spinning arc
    final startAngle = 0.0 + progress * 2 * pi;
    final sweepAngle = pi / 2 + sin(progress * 2 * pi) * pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(RefreshingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Success animation painter
class SuccessPainter extends CustomPainter {
  final Color color;

  SuccessPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw check mark
    final path = Path();
    path.moveTo(center.dx - radius * 0.4, center.dy);
    path.lineTo(center.dx - radius * 0.1, center.dy + radius * 0.3);
    path.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SuccessPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Error animation painter
class ErrorPainter extends CustomPainter {
  final Color color;

  ErrorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw X mark
    canvas.drawLine(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.3),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.3),
      Offset(center.dx - radius * 0.3, center.dy + radius * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(ErrorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Pulling animation painter
class PullingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isReady;
  final bool isReverse;
  final Axis direction;

  PullingPainter({
    required this.progress,
    required this.color,
    required this.isReady,
    required this.isReverse,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 + progress * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw progress arc
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Determine appropriate arrow direction based on parameters
    double arrowAngle = 0;
    if (direction == Axis.vertical) {
      arrowAngle = isReverse ? pi : 0; // Up arrow if reverse, down arrow if not
    } else {
      arrowAngle = isReverse
          ? -pi / 2
          : pi / 2; // Left arrow if reverse, right arrow if not
    }

    // If ready, flip arrow direction
    if (isReady) {
      arrowAngle += pi;
    }

    // Draw arrow
    final arrowPaint = Paint()
      ..color = isReady ? color : color.withValues(alpha: progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Calculate arrow points based on angle

    // Draw arrow shaft
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(arrowAngle);

    // Draw arrow
    canvas.drawLine(
      Offset(0, -10),
      Offset(0, 10),
      arrowPaint,
    );

    // Draw arrow head
    if (isReady) {
      // Arrow points up
      canvas.drawLine(
        Offset(-8, 2),
        Offset(0, -10),
        arrowPaint,
      );

      canvas.drawLine(
        Offset(8, 2),
        Offset(0, -10),
        arrowPaint,
      );
    } else {
      // Arrow points down
      canvas.drawLine(
        Offset(-8, -2),
        Offset(0, 10),
        arrowPaint,
      );

      canvas.drawLine(
        Offset(8, -2),
        Offset(0, 10),
        arrowPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PullingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isReady != isReady ||
        oldDelegate.isReverse != isReverse ||
        oldDelegate.direction != direction;
  }
}

/// Idle animation painter
class IdlePainter extends CustomPainter {
  final Color color;
  final bool isReverse;
  final Axis direction;

  IdlePainter({
    required this.color,
    required this.isReverse,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw dashed circle
    final dashCount = 8;
    final dashLength = 2 * pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashLength;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength * 0.7,
        false,
        paint,
      );
    }

    // Determine appropriate arrow direction based on parameters
    double arrowAngle = 0;
    if (direction == Axis.vertical) {
      arrowAngle = isReverse ? pi : 0; // Up arrow if reverse, down arrow if not
    } else {
      arrowAngle = isReverse
          ? -pi / 2
          : pi / 2; // Left arrow if reverse, right arrow if not
    }

    // Draw arrow
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(arrowAngle);

    // Draw arrow shaft
    canvas.drawLine(
      Offset(0, -10),
      Offset(0, 10),
      paint,
    );

    // Draw arrow head
    canvas.drawLine(
      Offset(-8, -2),
      Offset(0, 10),
      paint,
    );

    canvas.drawLine(
      Offset(8, -2),
      Offset(0, 10),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(IdlePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isReverse != isReverse ||
        oldDelegate.direction != direction;
  }
}

/// Provide multiple built-in indicator options
class RefreshTriggerIndicators {
  /// Default indicator
  static RefreshIndicatorBuilder defaultIndicator =
      RefreshTrigger.defaultIndicatorBuilder;

  /// Modern style indicator
  static RefreshIndicatorBuilder modernIndicator =
      (context, stage) => ModernRefreshIndicator(stage: stage);

  /// Water drop style indicator
  static RefreshIndicatorBuilder waterDropIndicator =
      (context, stage) => WaterDropRefreshIndicator(stage: stage);

  /// Lottie-style SVG animation indicator
  static RefreshIndicatorBuilder lottieStyleIndicator =
      (context, stage) => LottieStyleRefreshIndicator(stage: stage);

  /// Create a custom indicator by extending one of the built-in ones
  /// and applying custom styles
  static RefreshIndicatorBuilder custom({
    required RefreshIndicatorBuilder baseIndicator,
    required Map<String, dynamic> style,
  }) {
    return (context, stage) {
      // Create a new RefreshTriggerStage with custom style
      final stageWithStyle = RefreshTriggerStage(
        stage.stage,
        stage.extent,
        stage.direction,
        reverse: stage.reverse,
        error: stage.error,
        lastRefreshTime: stage.lastRefreshTime,
        refreshCount: stage.refreshCount,
        isManualRefresh: stage.isManualRefresh,
        style: style,
      );

      return baseIndicator(context, stageWithStyle);
    };
  }
}
