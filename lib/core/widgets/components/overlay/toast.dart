import 'dart:async';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'overlay.dart';

/// Toast level affecting appearance
enum ToastLevel { info, success, warning, error }

/// Toast position on screen
enum ToastPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  custom,
}

/// Toast animation type
enum ToastAnimationType {
  fade,
  scale,
  slideUp,
  slideDown,
  slideLeft,
  slideRight
}

/// Toast shifting animation type for transitions between visible and queued state
enum ToastShiftingAnimationType {
  slide,
  fade,
  scale,
  slideAndFade,
  scaleAndFade,
}

/// Toast interaction type
enum ToastInteraction { none, tapToDismiss, swipeToDismiss, tapToExpand }

/// Grouping behavior for toasts
enum ToastGroupBehavior { stack, collapse, replace }

/// Toast priority level
enum ToastPriority { low, normal, high, urgent }

/// Global configuration for toasts
class ToastConfig {
  // Core settings
  Duration defaultDuration;
  Duration animationDuration;
  ToastPosition defaultPosition;
  ToastAnimationType entryAnimation;
  ToastAnimationType exitAnimation;
  Set<ToastInteraction> interactions;
  EdgeInsetsGeometry padding;
  double spacing;
  int maxVisibleToasts;

  // Style settings
  Map<ToastLevel, ToastStyle> styles;

  // Responsive settings
  double mobileMaxWidth;
  double tabletMaxWidth;

  // Shifting animation settings
  ToastShiftingAnimationType shiftingAnimationType;
  Duration shiftingAnimationDuration;
  Curve shiftingAnimationCurve;

  // Accessibility settings
  bool announceToasts;
  String defaultAnnouncementLabel;

  // Singleton implementation
  static final ToastConfig _instance = ToastConfig._();
  factory ToastConfig() => _instance;

  ToastConfig._()
      : defaultDuration = const Duration(seconds: 4),
        animationDuration = const Duration(milliseconds: 300),
        defaultPosition = ToastPosition.bottomRight,
        entryAnimation = ToastAnimationType.scale,
        exitAnimation = ToastAnimationType.fade,
        interactions = {
          ToastInteraction.swipeToDismiss,
          ToastInteraction.tapToExpand
        },
        padding = const EdgeInsets.all(16),
        spacing = 8.0,
        maxVisibleToasts = 3,
        mobileMaxWidth = 320,
        tabletMaxWidth = 400,
        shiftingAnimationType = ToastShiftingAnimationType.slideAndFade,
        shiftingAnimationDuration = const Duration(milliseconds: 300),
        shiftingAnimationCurve = Curves.easeOutCubic,
        announceToasts = true,
        defaultAnnouncementLabel = 'Notification',
        styles = {
          ToastLevel.info: ToastStyle(
            backgroundColor: const Color(0xFF2196F3),
            iconData: Icons.info_outline,
          ),
          ToastLevel.success: ToastStyle(
            backgroundColor: const Color(0xFF4CAF50),
            iconData: Icons.check_circle_outline,
          ),
          ToastLevel.warning: ToastStyle(
            backgroundColor: const Color(0xFFFFC107),
            iconData: Icons.warning_amber_outlined,
          ),
          ToastLevel.error: ToastStyle(
            backgroundColor: const Color(0xFFF44336),
            iconData: Icons.error_outline,
          ),
        };

  /// Configure global toast settings
  static void configure({
    Duration? defaultDuration,
    Duration? animationDuration,
    ToastPosition? defaultPosition,
    ToastAnimationType? entryAnimation,
    ToastAnimationType? exitAnimation,
    Set<ToastInteraction>? interactions,
    EdgeInsetsGeometry? padding,
    double? spacing,
    int? maxVisibleToasts,
    double? mobileMaxWidth,
    double? tabletMaxWidth,
    Map<ToastLevel, ToastStyle>? styles,
    ToastShiftingAnimationType? shiftingAnimationType,
    Duration? shiftingAnimationDuration,
    Curve? shiftingAnimationCurve,
    bool? announceToasts,
    String? defaultAnnouncementLabel,
  }) {
    final instance = ToastConfig();

    if (defaultDuration != null) instance.defaultDuration = defaultDuration;
    if (animationDuration != null) {
      instance.animationDuration = animationDuration;
    }
    if (defaultPosition != null) instance.defaultPosition = defaultPosition;
    if (entryAnimation != null) instance.entryAnimation = entryAnimation;
    if (exitAnimation != null) instance.exitAnimation = exitAnimation;
    if (interactions != null) instance.interactions = interactions;
    if (padding != null) instance.padding = padding;
    if (spacing != null) instance.spacing = spacing;
    if (maxVisibleToasts != null) instance.maxVisibleToasts = maxVisibleToasts;
    if (mobileMaxWidth != null) instance.mobileMaxWidth = mobileMaxWidth;
    if (tabletMaxWidth != null) instance.tabletMaxWidth = tabletMaxWidth;
    if (styles != null) {
      instance.styles.clear();
      instance.styles.addAll(styles);
    }
    if (shiftingAnimationType != null) {
      instance.shiftingAnimationType = shiftingAnimationType;
    }
    if (shiftingAnimationDuration != null) {
      instance.shiftingAnimationDuration = shiftingAnimationDuration;
    }
    if (shiftingAnimationCurve != null) {
      instance.shiftingAnimationCurve = shiftingAnimationCurve;
    }
    if (announceToasts != null) {
      instance.announceToasts = announceToasts;
    }
    if (defaultAnnouncementLabel != null) {
      instance.defaultAnnouncementLabel = defaultAnnouncementLabel;
    }
  }

  /// Get appropriate max width based on screen size
  double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobileMaxWidth;
    return tabletMaxWidth;
  }

  /// Get appropriate padding based on screen size
  EdgeInsetsGeometry getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return padding.add(const EdgeInsets.all(-4));
    }
    return padding;
  }
}

/// Style for toasts
class ToastStyle {
  final Color backgroundColor;
  final Color? textColor;
  final IconData? iconData;
  final Color? iconColor;
  final BorderRadius borderRadius;
  final double elevation;
  final Color? progressColor;

  const ToastStyle({
    required this.backgroundColor,
    this.textColor,
    this.iconData,
    this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 4,
    this.progressColor,
  });

  /// Get text color based on background brightness
  Color getTextColor(BuildContext context) {
    return textColor ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black87);
  }

  /// Get icon color (defaults to text color)
  Color getIconColor(BuildContext context) {
    return iconColor ?? getTextColor(context);
  }

  /// Get progress indicator color
  Color getProgressColor(BuildContext context) {
    return progressColor ?? getTextColor(context).withValues(alpha: 0.3);
  }

  /// Create a copy with some properties changed
  ToastStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    IconData? iconData,
    Color? iconColor,
    BorderRadius? borderRadius,
    double? elevation,
    Color? progressColor,
  }) {
    return ToastStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconData: iconData ?? this.iconData,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      progressColor: progressColor ?? this.progressColor,
    );
  }
}

/// Action button for toast
class ToastAction {
  final String label;
  final VoidCallback onPressed;
  final bool closeOnPressed;
  final ButtonStyle? style;
  final IconData? icon;

  const ToastAction({
    required this.label,
    required this.onPressed,
    this.closeOnPressed = true,
    this.style,
    this.icon,
  });
}

/// Configuration for shifting animation
class ShiftingAnimationConfig {
  final ToastShiftingAnimationType type;
  final Duration duration;
  final Curve curve;

  const ShiftingAnimationConfig({
    required this.type,
    required this.duration,
    required this.curve,
  });

  /// Create from global config (fallback)
  factory ShiftingAnimationConfig.fromGlobalConfig() {
    final config = ToastConfig();
    return ShiftingAnimationConfig(
      type: config.shiftingAnimationType,
      duration: config.shiftingAnimationDuration,
      curve: config.shiftingAnimationCurve,
    );
  }
}

/// Toast entry data
class ToastEntry {
  // Identification
  final String? id;
  final String? group;
  final ToastGroupBehavior? groupBehavior;

  // Content
  final Widget Function(BuildContext, ToastOverlay)? builder;
  final String? title;
  final String? message;
  final Widget? content;
  final List<ToastAction>? actions;
  final Widget? leading;

  // Appearance
  final ToastPosition position;
  final Offset? customPosition;
  final ToastLevel? level;
  final ToastStyle? style;

  // Behavior
  final ToastPriority? priority;
  final bool dismissible;
  final bool persistent; // New: persistent toast flag
  final Set<ToastInteraction>? interactions;
  final Duration? duration;
  final Duration? animationDuration;
  final ToastAnimationType? entryAnimation;
  final ToastAnimationType? exitAnimation;

  // New: Custom shifting animation config
  final ToastShiftingAnimationType? shiftingAnimationType;
  final Duration? shiftingAnimationDuration;
  final Curve? shiftingAnimationCurve;

  // Accessibility
  final String? semanticLabel;
  final String? semanticHint;
  final bool announceOnUpdate;

  // Callbacks
  final VoidCallback? onClosed;

  const ToastEntry({
    this.id,
    this.builder,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.position = ToastPosition.bottomRight,
    this.customPosition,
    this.level,
    this.style,
    this.priority,
    this.dismissible = true,
    this.persistent = false, // Default: not persistent
    this.interactions,
    this.duration,
    this.animationDuration,
    this.entryAnimation,
    this.exitAnimation,
    this.shiftingAnimationType, // New field
    this.shiftingAnimationDuration, // New field
    this.shiftingAnimationCurve, // New field
    this.leading,
    this.onClosed,
    this.group,
    this.groupBehavior,
    this.semanticLabel,
    this.semanticHint,
    this.announceOnUpdate = true,
  });

  /// Get toast shifting animation configuration
  ShiftingAnimationConfig getShiftingAnimationConfig() {
    // Return toast-specific shifting animation if provided, else global config
    if (shiftingAnimationType != null ||
        shiftingAnimationDuration != null ||
        shiftingAnimationCurve != null) {
      final config = ToastConfig();
      return ShiftingAnimationConfig(
        type: shiftingAnimationType ?? config.shiftingAnimationType,
        duration: shiftingAnimationDuration ?? config.shiftingAnimationDuration,
        curve: shiftingAnimationCurve ?? config.shiftingAnimationCurve,
      );
    }

    // Fall back to global config
    return ShiftingAnimationConfig.fromGlobalConfig();
  }

  /// Get semantic announcement text for accessibility
  String getAnnouncement() {
    final labelPart =
        semanticLabel ?? title ?? ToastConfig().defaultAnnouncementLabel;
    final messagePart = message != null ? ', $message' : '';
    final priorityPart = priority != null ? ', ${_getPriorityText()}' : '';

    return '$labelPart$messagePart$priorityPart';
  }

  /// Get priority text for accessibility announcements
  String _getPriorityText() {
    switch (priority) {
      case ToastPriority.low:
        return 'low priority';
      case ToastPriority.high:
        return 'high priority';
      case ToastPriority.urgent:
        return 'urgent';
      case ToastPriority.normal:
      default:
        return '';
    }
  }

  /// Get priority index for sorting (higher number = higher priority)
  int getPriorityIndex() {
    return priority?.index ?? ToastPriority.normal.index;
  }
}

/// Position data for a toast
class _ToastPositionData {
  final int index;
  final bool visible;
  final bool expanded;
  final bool wasVisibleBefore;

  const _ToastPositionData({
    required this.index,
    required this.visible,
    required this.expanded,
    this.wasVisibleBefore = false,
  });

  _ToastPositionData copyWith({
    int? index,
    bool? visible,
    bool? expanded,
    bool? wasVisibleBefore,
  }) {
    return _ToastPositionData(
      index: index ?? this.index,
      visible: visible ?? this.visible,
      expanded: expanded ?? this.expanded,
      wasVisibleBefore: wasVisibleBefore ?? this.wasVisibleBefore,
    );
  }

  /// Check if visibility status changed
  bool visibilityChanged(bool newVisible) {
    return visible != newVisible;
  }
}

/// Visibility change type enum
enum _VisibilityChangeType {
  noChange,
  becameVisible,
  becameHidden,
}

/// Location data for toast positions
class _ToastLocationData {
  // All toasts at this location
  final ValueNotifier<List<_AttachedToastEntry>> entries = ValueNotifier([]);

  // Toast position data
  final ValueNotifier<Map<String, _ToastPositionData>> positionData =
      ValueNotifier({});

  /// Add a new toast entry
  void addEntry(_AttachedToastEntry entry) {
    // Add entry and update data
    final newEntries = [...entries.value, entry];
    entries.value = newEntries;

    // Sort by priority and timestamp
    _sortEntries();

    // Apply priority-based replacement
    _applyPriorityReplacement(entry);

    // Update position data
    _updatePositionData();
  }

  /// Apply priority-based replacement logic
  void _applyPriorityReplacement(_AttachedToastEntry newEntry) {
    final maxVisible = ToastConfig().maxVisibleToasts;
    final allEntries = entries.value;

    // Don't handle replacement if we have enough visible slots
    if (allEntries.length <= maxVisible) return;

    // Get the new entry priority
    final newEntryPriority = newEntry.entry.getPriorityIndex();

    // Sort entries without the new one to find candidates for replacement
    final existingEntries = allEntries.where((e) => e != newEntry).toList()
      ..sort((a, b) {
        // Sort by priority first (higher priority comes first)
        final aPriority = a.entry.getPriorityIndex();
        final bPriority = b.entry.getPriorityIndex();
        final priorityCompare = bPriority - aPriority;
        if (priorityCompare != 0) return priorityCompare;

        // Then by created time (newer first)
        return b.createdAt.compareTo(a.createdAt);
      });

    // Check if this new toast should replace a visible toast with lower priority
    if (existingEntries.length >= maxVisible) {
      // Get the lowest priority visible toast
      final lowestPriorityVisible = existingEntries[maxVisible - 1];
      final lowestPriority = lowestPriorityVisible.entry.getPriorityIndex();

      // If new toast has higher priority, replace the lowest priority one
      if (newEntryPriority > lowestPriority) {
        // Modify the entries list to place new toast in visible section
        final updatedEntries = [
          ...existingEntries.sublist(0, maxVisible - 1),
          newEntry,
          lowestPriorityVisible,
          ...existingEntries.sublist(maxVisible)
        ];

        entries.value = updatedEntries;

        // We'll pause the timer for the replaced toast in updatePositionData
      }
    }
  }

  /// Remove a toast entry
  void removeEntry(_AttachedToastEntry entry) {
    // Store old entries list for comparison
    final oldEntries = List<_AttachedToastEntry>.from(entries.value);
    final oldPositionData =
        Map<String, _ToastPositionData>.from(positionData.value);

    // Remove entry
    final newEntries = entries.value.where((e) => e != entry).toList();
    if (newEntries.length == oldEntries.length) return; // No change
    entries.value = newEntries;

    // Update position data
    _updatePositionData();

    // Reset timers for entries that changed visibility
    _resetTimersForChangedVisibility(oldPositionData);

    // Announce removal for accessibility if needed
    if (ToastConfig().announceToasts) {
      final entryLabel = entry.entry.semanticLabel ??
          entry.entry.title ??
          ToastConfig().defaultAnnouncementLabel;
      SemanticsService.announce('$entryLabel dismissed', TextDirection.ltr);
    }
  }

  /// Toggle expanded state for an entry
  void toggleExpanded(String id) {
    final currentData =
        Map<String, _ToastPositionData>.from(positionData.value);
    final entryData = currentData[id];

    if (entryData != null) {
      // Toggle expanded state
      currentData[id] = entryData.copyWith(expanded: !entryData.expanded);
      positionData.value = currentData;

      // Reset timer for this entry
      final entry = entries.value.firstWhere((e) => e.id == id);
      entry._resetTimerStatus();

      // Announce expanded state for accessibility if needed
      if (ToastConfig().announceToasts) {
        final entryLabel = entry.entry.semanticLabel ??
            entry.entry.title ??
            ToastConfig().defaultAnnouncementLabel;
        final expandState = !entryData.expanded ? 'expanded' : 'collapsed';
        SemanticsService.announce(
            '$entryLabel $expandState', TextDirection.ltr);
      }
    }
  }

  /// Check if entry is expanded
  bool isExpanded(String id) => positionData.value[id]?.expanded ?? false;

  /// Check if entry is visible
  bool isVisible(String id) => positionData.value[id]?.visible ?? false;

  /// Check if location has a toast in specific group
  bool hasGroup(String groupId) =>
      entries.value.any((e) => e.groupId == groupId);

  /// Get entries in a specific group
  List<_AttachedToastEntry> getEntriesInGroup(String groupId) {
    return entries.value.where((e) => e.groupId == groupId).toList();
  }

  /// Handle group behavior
  void handleGroupBehavior(String groupId, ToastGroupBehavior behavior,
      _AttachedToastEntry newEntry) {
    switch (behavior) {
      case ToastGroupBehavior.replace:
        // Remove old toasts with same group
        final oldEntries = getEntriesInGroup(groupId);
        for (final entry in oldEntries) {
          entry._startClosing();
        }
        // Add new entry
        addEntry(newEntry);
        break;

      case ToastGroupBehavior.collapse:
        // Get existing entries in group
        final groupEntries = getEntriesInGroup(groupId);
        if (groupEntries.isEmpty) {
          addEntry(newEntry);
          return;
        }

        // Update badge count
        newEntry._badgeCount = groupEntries.length + 1;

        // Check if any entry was expanded
        final wasExpanded = groupEntries.any((e) => isExpanded(e.id));

        // Remove old entries
        for (final entry in groupEntries) {
          removeEntry(entry);
        }

        // Add new entry
        addEntry(newEntry);

        // Preserve expanded state
        if (wasExpanded) {
          toggleExpanded(newEntry.id);
        }
        break;

      case ToastGroupBehavior.stack:
        // Default behavior, just add
        addEntry(newEntry);
        break;
    }
  }

  /// Sort entries by priority and time
  void _sortEntries() {
    final sortedEntries = List<_AttachedToastEntry>.from(entries.value);
    sortedEntries.sort((a, b) {
      // Sort by priority first (higher priority comes first)
      final aPriority = a.entry.getPriorityIndex();
      final bPriority = b.entry.getPriorityIndex();
      final priorityCompare = bPriority - aPriority;
      if (priorityCompare != 0) return priorityCompare;

      // Then by created time (newer first)
      return b.createdAt.compareTo(a.createdAt);
    });

    entries.value = sortedEntries;
  }

  /// Update position data for all entries
  void _updatePositionData() {
    final maxVisible = ToastConfig().maxVisibleToasts;
    final allEntries = entries.value;
    final newPositionData = <String, _ToastPositionData>{};
    final oldPositionData = positionData.value;

    // For each entry, calculate position data
    for (var i = 0; i < allEntries.length; i++) {
      final entry = allEntries[i];
      final isVisible = i < maxVisible;

      // Get previous data to preserve expanded state and track visibility changes
      final prevData = oldPositionData[entry.id];
      final wasVisible = prevData?.visible ?? false;
      final wasExpanded = prevData?.expanded ?? false;

      // Create new position data
      newPositionData[entry.id] = _ToastPositionData(
        index: i,
        visible: isVisible,
        expanded: wasExpanded,
        wasVisibleBefore: wasVisible,
      );

      // Check for visibility changes and update timer status
      if (wasVisible != isVisible) {
        if (isVisible) {
          // Toast became visible - resume timer
          entry._resetTimerStatus(becameVisible: true);

          // Announce for accessibility if needed
          if (ToastConfig().announceToasts && entry.entry.announceOnUpdate) {
            SemanticsService.announce(
              entry.entry.getAnnouncement(),
              TextDirection.ltr,
            );
          }
        } else {
          // Toast became hidden - pause timer
          entry._cancelTimer();
        }
      }
    }

    positionData.value = newPositionData;
  }

  /// Reset timers for entries that changed visibility
  void _resetTimersForChangedVisibility(
      Map<String, _ToastPositionData> oldPositionData) {
    final newPositionData = positionData.value;

    // Check each entry for visibility changes
    for (final entry in entries.value) {
      final oldData = oldPositionData[entry.id];
      final newData = newPositionData[entry.id];

      if (oldData == null || newData == null) continue;

      // Determine visibility change type
      final _VisibilityChangeType changeType;
      if (!oldData.visible && newData.visible) {
        changeType = _VisibilityChangeType.becameVisible;
      } else if (oldData.visible && !newData.visible) {
        changeType = _VisibilityChangeType.becameHidden;
      } else {
        changeType = _VisibilityChangeType.noChange;
      }

      // Handle timer based on visibility change
      switch (changeType) {
        case _VisibilityChangeType.becameVisible:
          // Resume timer
          entry._resetTimerStatus(becameVisible: true);
          break;

        case _VisibilityChangeType.becameHidden:
          // Pause timer
          entry._cancelTimer();
          break;

        case _VisibilityChangeType.noChange:
          // No change needed
          break;
      }
    }
  }
}

/// Interface for toast overlay
abstract class ToastOverlay {
  bool get isShowing;
  void close();
  String get id;
  String? get groupId;
  void update({String? title, String? message, Widget? content});
  int get badgeCount;
  void toggleExpanded();
  bool get isExpanded;
  bool get isVisible;
  bool get isPersistent; // New: check if the toast is persistent
  Duration get remainingDuration;
}

/// Implementation of ToastOverlay
class _AttachedToastEntry implements ToastOverlay {
  final GlobalKey<_ToastEntryWidgetState> key = GlobalKey();
  final ToastEntry entry;
  @override
  final String id;
  @override
  final String? groupId;
  final DateTime createdAt = DateTime.now();

  int _badgeCount = 0;
  final ValueNotifier<bool> _isClosing = ValueNotifier(false);

  Timer? _autoCloseTimer;
  DateTime? _timerStartTime;
  Duration _remainingDuration = Duration.zero;
  bool _timerPaused = false;

  ToastOverlayHandler? _handler;
  _ToastLocationData? _location;

  _AttachedToastEntry({
    required this.entry,
    required this.id,
    this.groupId,
  }) {
    // Initialize remaining duration from entry
    if (entry.duration != null) {
      _remainingDuration = entry.duration!;
    }
  }

  /// Connect to handler
  void _connect(ToastOverlayHandler handler, _ToastLocationData location) {
    _handler = handler;
    _location = location;
  }

  @override
  bool get isShowing => _handler != null && !_isClosing.value;

  @override
  bool get isExpanded => _location?.isExpanded(id) ?? false;

  @override
  bool get isVisible => _location?.isVisible(id) ?? false;

  @override
  bool get isPersistent => entry.persistent;

  @override
  int get badgeCount => _badgeCount;

  @override
  Duration get remainingDuration {
    if (_timerStartTime != null &&
        !_timerPaused &&
        entry.duration != null &&
        _autoCloseTimer?.isActive == true) {
      final elapsed = DateTime.now().difference(_timerStartTime!);
      final remaining = entry.duration! - elapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return _remainingDuration;
  }

  /// Start closing animation
  void _startClosing() {
    if (_isClosing.value) return;
    _isClosing.value = true;
    _cancelTimer();
  }

  /// Start auto-close timer
  void _startTimer() {
    _cancelTimer();

    // Skip timer if persistent, no duration, or already complete
    if (entry.persistent ||
        entry.duration == null ||
        entry.duration!.inMilliseconds <= 0 ||
        _remainingDuration.inMilliseconds <= 0) {
      return;
    }

    // Skip timer if toast is expanded or not visible
    if ((_location?.isExpanded(id) ?? false) ||
        !(_location?.isVisible(id) ?? false)) {
      _timerPaused = true;
      return;
    }

    _timerStartTime = DateTime.now();
    _timerPaused = false;

    // Use remaining duration
    _autoCloseTimer = Timer(_remainingDuration, () {
      if (_handler != null && !_isClosing.value) {
        close();
      }
    });
  }

  /// Cancel auto-close timer
  void _cancelTimer() {
    // Save remaining time if timer is active
    if (_timerStartTime != null &&
        !_timerPaused &&
        entry.duration != null &&
        _autoCloseTimer?.isActive == true) {
      final elapsed = DateTime.now().difference(_timerStartTime!);
      _remainingDuration = entry.duration! - elapsed;
      if (_remainingDuration.isNegative) {
        _remainingDuration = Duration.zero;
      }
    }

    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    _timerPaused = true;
  }

  /// Reset timer status based on visibility and state
  void _resetTimerStatus({bool becameVisible = false}) {
    if (_isClosing.value || entry.persistent) return;

    final visible = isVisible;
    final expanded = isExpanded;

    // If not visible or expanded, pause timer
    if (!visible || expanded) {
      _cancelTimer();
      return;
    }

    // If visible and not expanded, start timer
    if (visible && !expanded && _remainingDuration.inMilliseconds > 0) {
      _startTimer();

      // Announce for accessibility if became visible and announceToast is enabled
      if (becameVisible &&
          ToastConfig().announceToasts &&
          entry.announceOnUpdate) {
        SemanticsService.announce(entry.getAnnouncement(), TextDirection.ltr);
      }
    }
  }

  @override
  void close() {
    if (_isClosing.value) return;

    _startClosing();

    if (_handler == null) {
      entry.onClosed?.call();
      return;
    }

    final duration = entry.animationDuration ?? ToastConfig().animationDuration;

    Future.delayed(duration, () {
      if (_handler != null) {
        _handler!.removeEntry(entry);
        entry.onClosed?.call();
      }
    });
  }

  @override
  void update({String? title, String? message, Widget? content}) {
    if (_isClosing.value) return;
    key.currentState?.updateContent(title, message, content);

    // Announce update for accessibility if needed
    if (ToastConfig().announceToasts && entry.announceOnUpdate && isVisible) {
      final labelPart = entry.semanticLabel ??
          title ??
          entry.title ??
          ToastConfig().defaultAnnouncementLabel;
      final messagePart = message ?? entry.message ?? '';
      SemanticsService.announce(
        '$labelPart updated${messagePart.isNotEmpty ? ', $messagePart' : ''}',
        TextDirection.ltr,
      );
    }
  }

  @override
  void toggleExpanded() {
    if (_isClosing.value) return;
    _location?.toggleExpanded(id);
  }
}

/// Toast overlay handler for integration with OverlayManagerLayer
class ToastOverlayHandler extends OverlayHandler {
  /// Map of locations to data
  final Map<ToastPosition, _ToastLocationData> _locations = {
    ToastPosition.topLeft: _ToastLocationData(),
    ToastPosition.topCenter: _ToastLocationData(),
    ToastPosition.topRight: _ToastLocationData(),
    ToastPosition.bottomLeft: _ToastLocationData(),
    ToastPosition.bottomCenter: _ToastLocationData(),
    ToastPosition.bottomRight: _ToastLocationData(),
    ToastPosition.custom: _ToastLocationData(),
  };

  /// Map of custom position offsets
  final Map<String, Offset> _customPositions = {};

  /// Pending removals to avoid visual glitches
  final Set<String> _pendingRemovals = {};

  /// Initialize the handler with context from the overlay manager
  @override
  void initWithContext(BuildContext context) {}

  /// Check if has any toasts
  bool get hasToasts {
    for (var location in _locations.values) {
      if (location.entries.value.isNotEmpty) return true;
    }
    return false;
  }

  /// Add a new toast entry
  ToastOverlay addEntry(ToastEntry entry) {
    // Create unique ID if not provided
    final id = entry.id ??
        '${entry.hashCode}_${DateTime.now().millisecondsSinceEpoch}';

    // Create attached entry
    final attachedEntry = _AttachedToastEntry(
      entry: entry,
      id: id,
      groupId: entry.group,
    );

    final location = _locations[entry.position]!;

    // Handle custom position
    if (entry.position == ToastPosition.custom &&
        entry.customPosition != null) {
      _customPositions[id] = entry.customPosition!;
    }

    // Connect entry to this handler
    attachedEntry._connect(this, location);

    // Handle group behavior
    if (entry.group != null && entry.groupBehavior != null) {
      if (location.hasGroup(entry.group!)) {
        location.handleGroupBehavior(
            entry.group!, entry.groupBehavior!, attachedEntry);
        return attachedEntry;
      }
    }

    // Add entry normally
    location.addEntry(attachedEntry);

    // Start auto-dismiss timer if needed and visible
    if (!entry.persistent &&
        entry.duration != null &&
        entry.duration!.inMilliseconds > 0 &&
        location.isVisible(id)) {
      attachedEntry._startTimer();
    }

    // Announce for accessibility if needed
    if (ToastConfig().announceToasts &&
        entry.announceOnUpdate &&
        location.isVisible(id)) {
      SemanticsService.announce(entry.getAnnouncement(), TextDirection.ltr);
    }

    return attachedEntry;
  }

  /// Remove a toast entry
  void removeEntry(ToastEntry entry) {
    if (entry.id != null) {
      _pendingRemovals.add(entry.id!);
    }

    final location = _locations[entry.position]!;
    final entriesCopy = List.from(location.entries.value);

    for (final e in entriesCopy) {
      if (e.entry == entry) {
        location.removeEntry(e);
        break;
      }
    }

    if (entry.position == ToastPosition.custom && entry.id != null) {
      _customPositions.remove(entry.id);
    }

    if (entry.id != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _pendingRemovals.remove(entry.id);
      });
    }
  }

  /// Remove all toast entries
  void removeAllEntries() {
    for (var location in _locations.values) {
      for (var toast in List.from(location.entries.value)) {
        toast.close();
      }
    }
  }

  /// The handler doesn't really use the standard overlay parameters
  /// This is a special handler for toasts only, not general popover/dialogs
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
        'Toast handler does not use standard overlay params. '
        'Use ToastEntry instead with showToast() or similar methods.');
  }

  /// Show a toast using a ToastEntry - this is the main API for the handler
  ToastOverlay showToastEntry(ToastEntry entry) {
    return addEntry(entry);
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    List<Widget> children = [];

    // Build stack for each position
    for (var locationEntry in _locations.entries) {
      final position = locationEntry.key;
      final location = locationEntry.value;

      // Build stack using ValueListenableBuilder
      children.add(
        ValueListenableBuilder<List<_AttachedToastEntry>>(
          valueListenable: location.entries,
          builder: (context, entries, _) {
            if (entries.isEmpty) return const SizedBox();

            return ValueListenableBuilder<Map<String, _ToastPositionData>>(
              valueListenable: location.positionData,
              builder: (context, positionData, _) {
                return _buildToastStack(
                    context, position, entries, positionData);
              },
            );
          },
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: children,
    );
  }

  /// Build toast stack for a specific position
  Widget _buildToastStack(
    BuildContext context,
    ToastPosition position,
    List<_AttachedToastEntry> entries,
    Map<String, _ToastPositionData> positionData,
  ) {
    // Get configuration
    final config = ToastConfig();
    final alignment = _getAlignmentForPosition(position);
    final effectivePadding = config.getPadding(context);

    // Filter active entries (not pending removal)
    final activeEntries =
        entries.where((e) => !_pendingRemovals.contains(e.id)).toList();
    if (activeEntries.isEmpty) return const SizedBox();

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: effectivePadding,
          child: Align(
            alignment: alignment,
            child: position == ToastPosition.custom
                ? _buildCustomPositionToasts(
                    context, activeEntries, positionData)
                : _buildStandardPositionToasts(
                    context, position, activeEntries, positionData),
          ),
        ),
      ),
    );
  }

  /// Build toasts with custom positioning
  Widget _buildCustomPositionToasts(
    BuildContext context,
    List<_AttachedToastEntry> entries,
    Map<String, _ToastPositionData> positionData,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: entries.map((entry) {
        final data = positionData[entry.id];
        if (data == null) return const SizedBox();

        final customPos = _customPositions[entry.id] ?? Offset.zero;
        final visible = data.visible;
        final wasVisible = data.wasVisibleBefore;
        final visibilityChanged = visible != wasVisible;

        // Get shifting animation config for this entry
        final shiftConfig = entry.entry.getShiftingAnimationConfig();

        return AnimatedPositioned(
          left: customPos.dx,
          top: customPos.dy,
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: _buildShiftingAnimatedToast(entry, data, visible, shiftConfig),
        );
      }).toList(),
    );
  }

  /// Build standard positioned toasts
  Widget _buildStandardPositionToasts(
    BuildContext context,
    ToastPosition position,
    List<_AttachedToastEntry> entries,
    Map<String, _ToastPositionData> positionData,
  ) {
    final effectiveConstraints = BoxConstraints(
      maxWidth: ToastConfig().getMaxWidth(context),
    );

    // Determine if this is a top position
    final isTopPosition = position == ToastPosition.topLeft ||
        position == ToastPosition.topCenter ||
        position == ToastPosition.topRight;

    // Filter to just visible and next few entries (for shifting animation)
    final relevantEntries = entries.where((entry) {
      final data = positionData[entry.id];
      if (data == null) return false;

      // Include visible entries and a few beyond the visible ones
      final maxIndex = ToastConfig().maxVisibleToasts + 2;
      return data.index < maxIndex;
    }).toList();

    if (relevantEntries.isEmpty) return const SizedBox();

    // Get cross alignment
    CrossAxisAlignment crossAlignment;
    switch (position) {
      case ToastPosition.topLeft:
      case ToastPosition.bottomLeft:
        crossAlignment = CrossAxisAlignment.start;
        break;
      case ToastPosition.topRight:
      case ToastPosition.bottomRight:
        crossAlignment = CrossAxisAlignment.end;
        break;
      default:
        crossAlignment = CrossAxisAlignment.center;
    }

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlignment,
        mainAxisAlignment:
            isTopPosition ? MainAxisAlignment.start : MainAxisAlignment.end,
        verticalDirection:
            isTopPosition ? VerticalDirection.down : VerticalDirection.up,
        children: relevantEntries.map((entry) {
          final data = positionData[entry.id];
          if (data == null) return const SizedBox();

          final visible = data.visible;

          // Get shifting animation config for this entry
          final shiftConfig = entry.entry.getShiftingAnimationConfig();

          return Padding(
            padding: EdgeInsets.only(
              bottom: isTopPosition ? ToastConfig().spacing : 0,
              top: !isTopPosition ? ToastConfig().spacing : 0,
            ),
            child:
                _buildShiftingAnimatedToast(entry, data, visible, shiftConfig),
          );
        }).toList(),
      ),
    );
  }

  /// Build toast with shifting animation
  Widget _buildShiftingAnimatedToast(
    _AttachedToastEntry entry,
    _ToastPositionData data,
    bool visible,
    ShiftingAnimationConfig shiftConfig,
  ) {
    // Check if visibility changed
    final wasVisible = data.wasVisibleBefore;
    final visibilityChanged = visible != wasVisible;

    // Based on the shifting animation type
    switch (shiftConfig.type) {
      case ToastShiftingAnimationType.fade:
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: _ToastEntryWidget(
            key: entry.key,
            entry: entry.entry,
            attachedEntry: entry,
            expanded: data.expanded,
            visible: visible,
          ),
        );

      case ToastShiftingAnimationType.scale:
        return AnimatedScale(
          scale: visible ? 1.0 : 0.85,
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: visibilityChanged
                ? shiftConfig.duration
                : const Duration(milliseconds: 200),
            curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
            child: _ToastEntryWidget(
              key: entry.key,
              entry: entry.entry,
              attachedEntry: entry,
              expanded: data.expanded,
              visible: visible,
            ),
          ),
        );

      case ToastShiftingAnimationType.slide:
        return AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0.1, 0),
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: _ToastEntryWidget(
            key: entry.key,
            entry: entry.entry,
            attachedEntry: entry,
            expanded: data.expanded,
            visible: visible,
          ),
        );

      case ToastShiftingAnimationType.slideAndFade:
        return AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0.1, 0),
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: visibilityChanged
                ? shiftConfig.duration
                : const Duration(milliseconds: 200),
            curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
            child: _ToastEntryWidget(
              key: entry.key,
              entry: entry.entry,
              attachedEntry: entry,
              expanded: data.expanded,
              visible: visible,
            ),
          ),
        );

      case ToastShiftingAnimationType.scaleAndFade:
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: visibilityChanged
              ? shiftConfig.duration
              : const Duration(milliseconds: 200),
          curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
          child: AnimatedScale(
            scale: visible ? 1.0 : 0.9,
            duration: visibilityChanged
                ? shiftConfig.duration
                : const Duration(milliseconds: 200),
            curve: visibilityChanged ? shiftConfig.curve : Curves.easeOutCubic,
            child: _ToastEntryWidget(
              key: entry.key,
              entry: entry.entry,
              attachedEntry: entry,
              expanded: data.expanded,
              visible: visible,
            ),
          ),
        );
    }
  }

  /// Get alignment for toast position
  Alignment _getAlignmentForPosition(ToastPosition position) {
    switch (position) {
      case ToastPosition.topLeft:
        return Alignment.topLeft;
      case ToastPosition.topCenter:
        return Alignment.topCenter;
      case ToastPosition.topRight:
        return Alignment.topRight;
      case ToastPosition.bottomLeft:
        return Alignment.bottomLeft;
      case ToastPosition.bottomCenter:
        return Alignment.bottomCenter;
      case ToastPosition.bottomRight:
        return Alignment.bottomRight;
      case ToastPosition.custom:
        return Alignment.center;
    }
  }
}

/// Widget for displaying a toast entry with animations
class _ToastEntryWidget extends StatefulWidget {
  final ToastEntry entry;
  final _AttachedToastEntry attachedEntry;
  final bool expanded;
  final bool visible;

  const _ToastEntryWidget({
    super.key,
    required this.entry,
    required this.attachedEntry,
    required this.expanded,
    required this.visible,
  });

  @override
  State<_ToastEntryWidget> createState() => _ToastEntryWidgetState();
}

class _ToastEntryWidgetState extends State<_ToastEntryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _dismissAnimation;

  String? _title;
  String? _message;
  Widget? _customContent;

  bool _dismissing = false;
  double _dismissProgress = 0;
  Timer? _progressUpdateTimer;

  @override
  void initState() {
    super.initState();
    _title = widget.entry.title;
    _message = widget.entry.message;
    _customContent = widget.entry.content;

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration:
          widget.entry.animationDuration ?? ToastConfig().animationDuration,
    );

    // Animations
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _dismissAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    );

    // Start animation
    _controller.forward();

    // Listen for closing signal
    widget.attachedEntry._isClosing.addListener(_handleClosing);

    // Start progress indicator timer
    _startProgressTimer();
  }

  @override
  void dispose() {
    widget.attachedEntry._isClosing.removeListener(_handleClosing);
    _controller.dispose();
    _stopProgressTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ToastEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update listener if entry changed
    if (oldWidget.attachedEntry != widget.attachedEntry) {
      oldWidget.attachedEntry._isClosing.removeListener(_handleClosing);
      widget.attachedEntry._isClosing.addListener(_handleClosing);
    }

    // Update expanded state
    if (oldWidget.expanded != widget.expanded) {
      if (widget.expanded) {
        widget.attachedEntry._cancelTimer();
      } else {
        widget.attachedEntry._resetTimerStatus();
      }
    }

    // Update visibility state
    if (oldWidget.visible != widget.visible) {
      widget.attachedEntry._resetTimerStatus();
    }
  }

  /// Handle closing signal
  void _handleClosing() {
    if (widget.attachedEntry._isClosing.value && mounted) {
      _controller.reverse();
      _stopProgressTimer();
    }
  }

  /// Update content
  void updateContent(String? title, String? message, Widget? content) {
    if (mounted) {
      setState(() {
        if (title != null) _title = title;
        if (message != null) _message = message;
        if (content != null) _customContent = content;
      });
    }
  }

  /// Start timer for progress indicator
  void _startProgressTimer() {
    _progressUpdateTimer?.cancel();

    // Only start if we have a duration and toast is not persistent
    if (!widget.entry.persistent &&
        widget.entry.duration != null &&
        widget.entry.duration!.inMilliseconds > 0) {
      _progressUpdateTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted && widget.visible && !widget.expanded) {
          setState(() {});
        }
      });
    }
  }

  /// Stop progress timer
  void _stopProgressTimer() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
  }

  /// Check if interaction is enabled
  bool _isInteractionEnabled(ToastInteraction interaction) {
    final config = ToastConfig();
    final defaultInteractions = config.interactions;
    final interactions = widget.entry.interactions ?? defaultInteractions;

    return interactions.contains(interaction) &&
        (interaction != ToastInteraction.swipeToDismiss &&
                interaction != ToastInteraction.tapToDismiss ||
            widget.entry.dismissible);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // If closing and animation done, don't render
        if (widget.attachedEntry._isClosing.value && _controller.isDismissed) {
          return const SizedBox();
        }

        return _buildAnimatedToast(context);
      },
    );
  }

  /// Build toast with animations
  Widget _buildAnimatedToast(BuildContext context) {
    // Calculate opacity
    final effectiveOpacity = (widget.attachedEntry._isClosing.value
            ? _dismissAnimation.value
            : _animation.value) *
        (1.0 - _dismissProgress.abs());

    // Get style
    final config = ToastConfig();
    final style = widget.entry.style ??
        (widget.entry.level != null
            ? config.styles[widget.entry.level!]
            : config.styles[ToastLevel.info]);

    // Build content
    Widget content = _buildToastContent(context, style);

    // Add semantics
    final isPersistent = widget.entry.persistent;
    final semanticLabel = widget.entry.semanticLabel ??
        _title ??
        ToastConfig().defaultAnnouncementLabel;

    String persistentHint = '';
    if (isPersistent) {
      persistentHint = ', persistent notification. ';
    }

    String interactionHint = '';
    if (_isInteractionEnabled(ToastInteraction.swipeToDismiss)) {
      interactionHint = '$interactionHint Swipe to dismiss.';
    }
    if (_isInteractionEnabled(ToastInteraction.tapToDismiss)) {
      interactionHint = '$interactionHint Tap to dismiss.';
    }
    if (_isInteractionEnabled(ToastInteraction.tapToExpand)) {
      interactionHint =
          '$interactionHint Tap to ${widget.expanded ? 'collapse' : 'expand'}.';
    }

    final semanticHint =
        widget.entry.semanticHint ?? '$persistentHint$interactionHint';

    content = Semantics(
      container: true,
      label: semanticLabel,
      hint: semanticHint,
      liveRegion: true,
      onDismiss:
          widget.entry.dismissible ? () => widget.attachedEntry.close() : null,
      child: content,
    );

    // Add gesture handlers
    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) {
        if (_isInteractionEnabled(ToastInteraction.swipeToDismiss)) {
          setState(() => _dismissing = true);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (_dismissing) {
          setState(() {
            _dismissProgress += details.primaryDelta! / context.size!.width;
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (_dismissing) {
          setState(() => _dismissing = false);

          if (_dismissProgress.abs() > 0.3) {
            widget.attachedEntry.close();
          } else {
            setState(() => _dismissProgress = 0);
          }
        }
      },
      onTap: () {
        if (_isInteractionEnabled(ToastInteraction.tapToDismiss)) {
          widget.attachedEntry.close();
        } else if (_isInteractionEnabled(ToastInteraction.tapToExpand)) {
          widget.attachedEntry.toggleExpanded();
        }
      },
      child: content,
    );

    return Opacity(
      opacity: effectiveOpacity,
      child: Transform.translate(
        offset: Offset(_dismissProgress * MediaQuery.of(context).size.width, 0),
        child: _applyEntryAnimation(content),
      ),
    );
  }

  /// Apply entry/exit animation
  Widget _applyEntryAnimation(Widget child) {
    final config = ToastConfig();
    final animationType = widget.attachedEntry._isClosing.value
        ? (widget.entry.exitAnimation ?? config.exitAnimation)
        : (widget.entry.entryAnimation ?? config.entryAnimation);

    final animation =
        widget.attachedEntry._isClosing.value ? _dismissAnimation : _animation;

    switch (animationType) {
      case ToastAnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case ToastAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: child,
        );

      case ToastAnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(animation),
          child: child,
        );

      case ToastAnimationType.slideDown:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
                  .animate(animation),
          child: child,
        );

      case ToastAnimationType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );

      case ToastAnimationType.slideRight:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero)
                  .animate(animation),
          child: child,
        );
    }
  }

  /// Build toast content
  Widget _buildToastContent(BuildContext context, ToastStyle? style) {
    // Use custom builder if provided
    if (widget.entry.builder != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: widget.entry.builder!(context, widget.attachedEntry),
      );
    }

    // Get style properties
    final borderRadius = style?.borderRadius ?? BorderRadius.circular(8);
    final bgColor =
        style?.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final textColor =
        style?.getTextColor(context) ?? Theme.of(context).colorScheme.onSurface;

    // Calculate remaining time for progress indicator
    final remainingDuration = widget.attachedEntry.remainingDuration;
    final totalDuration = widget.entry.duration ?? Duration.zero;
    final progress = totalDuration.inMilliseconds > 0
        ? 1.0 -
            (remainingDuration.inMilliseconds / totalDuration.inMilliseconds)
        : 0.0;

    // Build standard toast
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: style?.elevation ?? 4,
          margin: EdgeInsets.zero,
          color: bgColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main content
              _buildToastLayout(context, style, textColor),

              // Progress indicator for non-persistent toasts with duration
              if (!widget.entry.persistent &&
                  totalDuration.inMilliseconds > 0 &&
                  !widget.expanded)
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    style?.getProgressColor(context) ??
                        textColor.withValues(alpha: 0.3),
                  ),
                  minHeight: 2,
                  semanticsLabel:
                      'Time remaining: ${(remainingDuration.inMilliseconds / 1000).toStringAsFixed(1)} seconds',
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build toast internal layout
  Widget _buildToastLayout(
      BuildContext context, ToastStyle? style, Color textColor) {
    // Setup leading icon
    final Widget? leadingWidget = widget.entry.leading ??
        (style?.iconData != null
            ? Icon(
                style!.iconData,
                color: style.getIconColor(context),
                size: 24,
              )
            : null);

    // Setup badge
    final hasBadge = widget.attachedEntry._badgeCount > 0;

    // Determine if we should show expand indicator
    final canExpand = _isInteractionEnabled(ToastInteraction.tapToExpand);
    final expandIcon = canExpand
        ? Icon(
            widget.expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            size: 16,
            color: textColor.withValues(alpha: 0.7),
          )
        : null;

    // Check if has actions
    final hasActions = widget.entry.actions?.isNotEmpty == true;

    // Check if persistent
    final isPersistent = widget.entry.persistent;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon
          if (leadingWidget != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: leadingWidget,
            ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & badge
                if (_title != null || hasBadge || isPersistent)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom:
                          _message != null || _customContent != null ? 4 : 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: widget.expanded ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPersistent) _buildPersistentIndicator(context),
                        if (hasBadge) _buildBadge(context),
                        if (expandIcon != null) ...[
                          const SizedBox(width: 4),
                          expandIcon,
                        ],
                      ],
                    ),
                  ),

                // Message
                if (_message != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: hasActions ? 4 : 12,
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.9),
                      ),
                      maxLines: widget.expanded ? null : 2,
                      overflow: widget.expanded ? null : TextOverflow.ellipsis,
                    ),
                  ),

                // Custom content
                if (_customContent != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: hasActions ? 4 : 12,
                    ),
                    child: _customContent!,
                  ),

                // Actions
                if (hasActions)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.entry.actions!.map((action) {
                        return _buildActionButton(context, action, textColor);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Close button - only for dismissible toasts
          if (widget.entry.dismissible)
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  widget.attachedEntry.close();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Semantics(
                    button: true,
                    label: 'Close notification',
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build persistent indicator
  Widget _buildPersistentIndicator(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // Fallback: Tampilkan icon saja jika tidak ada overlay (hindari error)
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.push_pin,
          size: 14,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: 'Persistent notification',
        child: Icon(
          Icons.push_pin,
          size: 14,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(
      BuildContext context, ToastAction action, Color textColor) {
    return TextButton(
      onPressed: () {
        // Capture action callback
        final callback = action.onPressed;

        // Handle closure if needed
        if (action.closeOnPressed) {
          widget.attachedEntry.close();
        }

        // Execute callback
        callback();
      },
      style: action.style ??
          TextButton.styleFrom(
            foregroundColor: textColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(44, 36),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action.icon != null) ...[
            Icon(action.icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(action.label),
        ],
      ),
    );
  }

  /// Build badge counter
  Widget _buildBadge(BuildContext context) {
    final count = widget.attachedEntry._badgeCount;
    return Semantics(
      label: '$count notifications',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Class for managing Toast functionality without requiring ToastLayer
class ToastManager {
  /// Get the toast handler from the overlay manager
  static ToastOverlayHandler? _getToastHandler(BuildContext context) {
    final overlayManager = OverlayManager.maybeOf(context);
    if (overlayManager != null) {
      return overlayManager.toastHandler;
    }
    return null;
  }

  /// Show a toast notification
  static ToastOverlay showToast({
    required BuildContext context,
    Widget Function(BuildContext, ToastOverlay)? builder,
    String? title,
    String? message,
    Widget? content,
    List<ToastAction>? actions,
    Widget? leading,
    ToastPosition position = ToastPosition.bottomRight,
    Offset? customPosition,
    ToastLevel? level,
    ToastPriority? priority,
    bool dismissible = true,
    bool persistent = false,
    Set<ToastInteraction>? interactions,
    Duration? duration,
    Duration? animationDuration,
    ToastAnimationType? entryAnimation,
    ToastAnimationType? exitAnimation,
    ToastShiftingAnimationType? shiftingAnimationType,
    Duration? shiftingAnimationDuration,
    Curve? shiftingAnimationCurve,
    ToastStyle? style,
    String? group,
    ToastGroupBehavior? groupBehavior,
    String? semanticLabel,
    String? semanticHint,
    bool announceOnUpdate = true,
    String? id,
  }) {
    final handler = _getToastHandler(context);
    if (handler == null) {
      throw Exception(
          'ToastOverlayHandler not found. Make sure your app is wrapped with OverlayManagerLayer with toastHandler.');
    }

    // Create toast entry
    final entry = ToastEntry(
      id: id,
      builder: builder,
      title: title,
      message: message,
      content: content,
      actions: actions,
      position: position,
      customPosition: customPosition,
      level: level,
      priority: priority,
      dismissible: dismissible,
      persistent: persistent,
      interactions: interactions,
      duration: duration ?? ToastConfig().defaultDuration,
      animationDuration: animationDuration ?? ToastConfig().animationDuration,
      entryAnimation: entryAnimation,
      exitAnimation: exitAnimation,
      shiftingAnimationType: shiftingAnimationType,
      shiftingAnimationDuration: shiftingAnimationDuration,
      shiftingAnimationCurve: shiftingAnimationCurve,
      style: style,
      leading: leading,
      onClosed: null,
      group: group,
      groupBehavior: groupBehavior,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      announceOnUpdate: announceOnUpdate,
    );

    return handler.showToastEntry(entry);
  }

  /// Show an info toast
  static ToastOverlay showInfoToast({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<ToastAction>? actions,
    ToastPosition position = ToastPosition.bottomRight,
    ToastPriority? priority,
    bool persistent = false,
    Duration? duration,
  }) {
    return showToast(
      context: context,
      title: title,
      message: message,
      content: content,
      actions: actions,
      level: ToastLevel.info,
      position: position,
      priority: priority,
      persistent: persistent,
      duration: duration,
    );
  }

  /// Show a success toast
  static ToastOverlay showSuccessToast({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<ToastAction>? actions,
    ToastPosition position = ToastPosition.bottomRight,
    ToastPriority? priority,
    bool persistent = false,
    Duration? duration,
  }) {
    return showToast(
      context: context,
      title: title,
      message: message,
      content: content,
      actions: actions,
      level: ToastLevel.success,
      position: position,
      priority: priority,
      persistent: persistent,
      duration: duration,
    );
  }

  /// Show a warning toast
  static ToastOverlay showWarningToast({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<ToastAction>? actions,
    ToastPosition position = ToastPosition.bottomRight,
    ToastPriority? priority,
    bool persistent = false,
    Duration? duration,
  }) {
    return showToast(
      context: context,
      title: title,
      message: message,
      content: content,
      actions: actions,
      level: ToastLevel.warning,
      position: position,
      priority: priority,
      persistent: persistent,
      duration: duration,
    );
  }

  /// Show an error toast
  static ToastOverlay showErrorToast({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<ToastAction>? actions,
    ToastPosition position = ToastPosition.bottomRight,
    ToastPriority? priority,
    bool persistent = false,
    Duration? duration,
  }) {
    return showToast(
      context: context,
      title: title,
      message: message,
      content: content,
      actions: actions,
      level: ToastLevel.error,
      position: position,
      priority: priority,
      persistent: persistent,
      duration: duration ?? const Duration(seconds: 8),
    );
  }

  /// Show a custom toast
  static ToastOverlay showCustomToast({
    required BuildContext context,
    required Widget Function(BuildContext, ToastOverlay) builder,
    ToastPosition position = ToastPosition.bottomRight,
    Offset? customPosition,
    ToastPriority? priority,
    bool persistent = false,
    Duration? duration,
    ToastShiftingAnimationType? shiftingAnimationType,
    Duration? shiftingAnimationDuration,
    Curve? shiftingAnimationCurve,
  }) {
    return showToast(
      context: context,
      builder: builder,
      position: position,
      customPosition: customPosition,
      priority: priority,
      persistent: persistent,
      duration: duration,
      shiftingAnimationType: shiftingAnimationType,
      shiftingAnimationDuration: shiftingAnimationDuration,
      shiftingAnimationCurve: shiftingAnimationCurve,
    );
  }
}

// For backwards compatibility, retain the global functions with same signatures
// but redirect to ToastManager implementation

/// Show a toast notification
ToastOverlay showToast({
  required BuildContext context,
  Widget Function(BuildContext, ToastOverlay)? builder,
  String? title,
  String? message,
  Widget? content,
  List<ToastAction>? actions,
  Widget? leading,
  ToastPosition position = ToastPosition.bottomRight,
  Offset? customPosition,
  ToastLevel? level,
  ToastPriority? priority,
  bool dismissible = true,
  bool persistent = false,
  Set<ToastInteraction>? interactions,
  Duration? duration,
  Duration? animationDuration,
  ToastAnimationType? entryAnimation,
  ToastAnimationType? exitAnimation,
  ToastShiftingAnimationType? shiftingAnimationType,
  Duration? shiftingAnimationDuration,
  Curve? shiftingAnimationCurve,
  ToastStyle? style,
  String? group,
  ToastGroupBehavior? groupBehavior,
  String? semanticLabel,
  String? semanticHint,
  bool announceOnUpdate = true,
  String? id,
}) {
  return ToastManager.showToast(
    context: context,
    builder: builder,
    title: title,
    message: message,
    content: content,
    actions: actions,
    position: position,
    customPosition: customPosition,
    level: level,
    priority: priority,
    dismissible: dismissible,
    persistent: persistent,
    interactions: interactions,
    duration: duration,
    animationDuration: animationDuration,
    entryAnimation: entryAnimation,
    exitAnimation: exitAnimation,
    shiftingAnimationType: shiftingAnimationType,
    shiftingAnimationDuration: shiftingAnimationDuration,
    shiftingAnimationCurve: shiftingAnimationCurve,
    style: style,
    leading: leading,
    group: group,
    groupBehavior: groupBehavior,
    semanticLabel: semanticLabel,
    semanticHint: semanticHint,
    announceOnUpdate: announceOnUpdate,
    id: id,
  );
}

/// Show an info toast
ToastOverlay showInfoToast({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<ToastAction>? actions,
  ToastPosition position = ToastPosition.bottomRight,
  ToastPriority? priority,
  bool persistent = false,
  Duration? duration,
}) {
  return ToastManager.showInfoToast(
    context: context,
    title: title,
    message: message,
    content: content,
    actions: actions,
    position: position,
    priority: priority,
    persistent: persistent,
    duration: duration,
  );
}

/// Show a success toast
ToastOverlay showSuccessToast({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<ToastAction>? actions,
  ToastPosition position = ToastPosition.bottomRight,
  ToastPriority? priority,
  bool persistent = false,
  Duration? duration,
}) {
  return ToastManager.showSuccessToast(
    context: context,
    title: title,
    message: message,
    content: content,
    actions: actions,
    position: position,
    priority: priority,
    persistent: persistent,
    duration: duration,
  );
}

/// Show a warning toast
ToastOverlay showWarningToast({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<ToastAction>? actions,
  ToastPosition position = ToastPosition.bottomRight,
  ToastPriority? priority,
  bool persistent = false,
  Duration? duration,
}) {
  return ToastManager.showWarningToast(
    context: context,
    title: title,
    message: message,
    content: content,
    actions: actions,
    position: position,
    priority: priority,
    persistent: persistent,
    duration: duration,
  );
}

/// Show an error toast
ToastOverlay showErrorToast({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<ToastAction>? actions,
  ToastPosition position = ToastPosition.bottomRight,
  ToastPriority? priority,
  bool persistent = false,
  Duration? duration,
}) {
  return ToastManager.showErrorToast(
    context: context,
    title: title,
    message: message,
    content: content,
    actions: actions,
    position: position,
    priority: priority,
    persistent: persistent,
    duration: duration,
  );
}

/// Show a custom toast
ToastOverlay showCustomToast({
  required BuildContext context,
  required Widget Function(BuildContext, ToastOverlay) builder,
  ToastPosition position = ToastPosition.bottomRight,
  Offset? customPosition,
  ToastPriority? priority,
  bool persistent = false,
  Duration? duration,
  ToastShiftingAnimationType? shiftingAnimationType,
  Duration? shiftingAnimationDuration,
  Curve? shiftingAnimationCurve,
}) {
  return ToastManager.showCustomToast(
    context: context,
    builder: builder,
    position: position,
    customPosition: customPosition,
    priority: priority,
    persistent: persistent,
    duration: duration,
    shiftingAnimationType: shiftingAnimationType,
    shiftingAnimationDuration: shiftingAnimationDuration,
    shiftingAnimationCurve: shiftingAnimationCurve,
  );
}
