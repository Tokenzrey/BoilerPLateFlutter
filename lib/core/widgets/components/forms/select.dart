import 'dart:async';

import 'package:boilerplate/core/widgets/async.dart';
import 'package:boilerplate/core/widgets/components/buttons/button.dart';
import 'package:boilerplate/core/widgets/components/control/clickable.dart';
import 'package:boilerplate/core/widgets/components/control/hover.dart';
import 'package:boilerplate/core/widgets/components/display/chip.dart';
import 'package:boilerplate/core/widgets/components/forms/control.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';
import 'package:boilerplate/core/widgets/components/forms/form.dart' hide Data;
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/utils.dart';
import 'package:data_widget/data_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/services.dart';

/// Controller untuk single-select dropdown/overlay.
class SelectController<T> extends ValueNotifier<T?>
    implements ComponentController<T?> {
  SelectController([super.value]);

  // Hooks untuk testing/analytics
  final _onOpenController = StreamController<void>.broadcast();
  final _onCloseController = StreamController<void>.broadcast();
  final _onSelectController = StreamController<T?>.broadcast();
  final _onClearController = StreamController<void>.broadcast();

  /// Fired when dropdown is opened.
  Stream<void> get onOpen => _onOpenController.stream;

  /// Fired when dropdown is closed.
  Stream<void> get onClose => _onCloseController.stream;

  /// Fired whenever the selection is changed (including clear).
  Stream<T?> get onSelect => _onSelectController.stream;

  /// Fired specifically when the selection is cleared.
  Stream<void> get onClear => _onClearController.stream;

  /// Opens the dropdown (for analytics).
  void notifyOpen() => _onOpenController.add(null);

  /// Closes the dropdown (for analytics).
  void notifyClose() => _onCloseController.add(null);

  /// Internal: emits selection change.
  void _notifySelect(T? item) => _onSelectController.add(item);

  /// Internal: emits clear event.
  void _notifyClear() => _onClearController.add(null);

  /// Returns true if [item] is the currently selected value.
  bool isSelected(T item) => value == item;

  /// Selects [item], or clears if already selected.
  void toggle(T item) {
    if (value == item) {
      clear();
    } else {
      select(item);
    }
  }

  /// Explicitly select [item].
  void select(T item) {
    value = item;
    _notifySelect(item);
  }

  /// Clear the current selection.
  void clear() {
    if (value != null) {
      value = null;
      _notifySelect(null);
      _notifyClear();
    }
  }

  @override
  void dispose() {
    _onOpenController.close();
    _onCloseController.close();
    _onSelectController.close();
    _onClearController.close();
    super.dispose();
  }
}

/// Controller untuk multi-select dropdown/overlay.
class MultiSelectController<T> extends SelectController<Iterable<T>>
    implements ComponentController<Iterable<T>?> {
  MultiSelectController([super.value]);

  /// Clear all selections.
  @override
  void clear() {
    if (value != null && value!.isNotEmpty) {
      super.clear();
    }
  }

  /// Replace current selection with [allItems].
  void selectAll(Iterable<T> allItems) {
    value = List<T>.from(allItems);
    _notifySelect(value);
  }

  /// Add a single [item] to the selection.
  void add(T item) {
    final current = value == null ? <T>[] : List<T>.from(value!);
    if (!current.contains(item)) {
      current.add(item);
      value = current;
      _notifySelect(value);
    }
  }

  /// Remove a single [item] from the selection.
  void remove(T item) {
    if (value != null && value!.contains(item)) {
      final current = List<T>.from(value!);
      current.remove(item);
      if (current.isEmpty) {
        clear();
      } else {
        value = current;
        _notifySelect(value);
      }
    }
  }

  /// Toggle presence of [item] in the selection.
  void toggleItem(T item) {
    if (value == null || !value!.contains(item)) {
      add(item);
    } else {
      remove(item);
    }
  }

  /// Returns true if [item] is contained in the selection.

  bool contains(T item) => value?.contains(item) ?? false;
}

typedef SelectPopupBuilder = Widget Function(BuildContext context);
typedef SelectValueBuilder<T> = Widget Function(BuildContext context, T value);
typedef SelectValueSelectionHandler<T> = T? Function(
    T? oldValue, Object? value, bool selected);
typedef SelectValueSelectionPredicate<T> = bool Function(
    T? value, Object? test);
typedef SelectValueChanged<T> = bool Function(T value, bool selected);
typedef SelectFilterFunction<T> = bool Function(T item, String query);
typedef SelectItemBuilder = Widget Function(
  BuildContext context,
  bool selected,
  bool highlighted,
);

/// Intent for navigating through select options
class SelectNavigateIntent extends Intent {
  final bool isNext;
  const SelectNavigateIntent({this.isNext = true});
}

/// Intent for selecting current option
class SelectItemIntent extends Intent {
  const SelectItemIntent();
}

/// Intent for escaping/closing popup
class SelectEscapeIntent extends Intent {
  const SelectEscapeIntent();
}

/// Intent for clearing the current selection
class SelectClearIntent extends Intent {
  const SelectClearIntent();
}

mixin SelectBase<T> {
  ValueChanged<T?>? get onChanged;
  Widget? get placeholder;
  bool get filled;
  FocusNode? get focusNode;
  BoxConstraints? get constraints;
  BoxConstraints? get popupConstraints;
  PopoverConstraint get popupWidthConstraint;
  BorderRadius? get borderRadius;
  EdgeInsetsGeometry? get padding;
  AlignmentGeometry get popoverAlignment;
  AlignmentGeometry? get popoverAnchorAlignment;
  bool get disableHoverEffect;
  bool get canUnselect;
  bool? get autoClosePopover;
  SelectPopupBuilder get popup;
  SelectValueBuilder<T> get itemBuilder;
  SelectValueSelectionHandler<T>? get valueSelectionHandler;
  SelectValueSelectionPredicate<T>? get valueSelectionPredicate;
  Predicate<T>? get showValuePredicate;
  bool get showClearButton;

  // Animation properties
  Duration get animationDuration;
  Curve get animationCurve;

  // Event callbacks
  VoidCallback? get onOpen;
  VoidCallback? get onClose;
  ValueChanged<T?>? get onSelect;
}

T? _defaultSingleSelectValueSelectionHandler<T>(
    T? oldValue, Object? value, bool selected) {
  if (value is! T?) {
    return null;
  }
  return selected ? value : null;
}

bool _defaultSingleSelectValueSelectionPredicate<T>(T? value, Object? test) {
  return value == test;
}

Iterable<T>? _defaultMultiSelectValueSelectionHandler<T>(
    Iterable<T>? oldValue, Object? newValue, bool selected) {
  if (newValue == null) {
    return null;
  }
  Iterable<T> wrappedNewValue = [newValue as T];
  if (oldValue == null) {
    return selected ? wrappedNewValue : null;
  }
  if (selected) {
    return oldValue.followedBy(wrappedNewValue);
  } else {
    var newIterable = oldValue.where((element) => element != newValue);
    return newIterable.isEmpty ? null : newIterable;
  }
}

bool _defaultMultiSelectValueSelectionPredicate<T>(
    Iterable<T>? value, Object? test) {
  if (value == null) {
    return test == null;
  }
  if (test == null) {
    return false;
  }
  return value.contains(test);
}

class SelectField<T> extends StatefulWidget with SelectBase<T> {
  static const kDefaultSelectMaxHeight = 240.0;

  @override
  final ValueChanged<T?>? onChanged;
  @override
  final Widget? placeholder;
  @override
  final bool filled;
  @override
  final FocusNode? focusNode;
  @override
  final BoxConstraints? constraints;
  @override
  final BoxConstraints? popupConstraints;
  @override
  final PopoverConstraint popupWidthConstraint;
  final T? value;
  @override
  final BorderRadius? borderRadius;
  @override
  final EdgeInsetsGeometry? padding;
  @override
  final AlignmentGeometry popoverAlignment;
  @override
  final AlignmentGeometry? popoverAnchorAlignment;
  @override
  final bool disableHoverEffect;
  @override
  final bool canUnselect;
  @override
  final bool? autoClosePopover;
  final bool? enabled;
  @override
  final SelectPopupBuilder popup;
  @override
  final SelectValueBuilder<T> itemBuilder;
  @override
  final SelectValueSelectionHandler<T>? valueSelectionHandler;
  @override
  final SelectValueSelectionPredicate<T>? valueSelectionPredicate;
  @override
  final Predicate<T>? showValuePredicate;
  @override
  final bool showClearButton;
  @override
  final Duration animationDuration;
  @override
  final Curve animationCurve;
  @override
  final VoidCallback? onOpen;
  @override
  final VoidCallback? onClose;
  @override
  final ValueChanged<T?>? onSelect;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Elevation for the popup
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;

  // Optional decoration for visual customization
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;

  // RTL support and direction
  final TextDirection? textDirection;

  final Size? fixedSize;

  const SelectField({
    super.key,
    this.onChanged,
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.fixed,
    this.value,
    this.disableHoverEffect = false,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.canUnselect = false,
    this.autoClosePopover = true,
    this.enabled,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.showValuePredicate,
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.onOpen,
    this.onClose,
    this.onSelect,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
    required this.popup,
    required this.itemBuilder,
    this.fixedSize,
  });

  @override
  SelectFieldState<T> createState() => SelectFieldState<T>();
}

class SelectFieldState<T> extends State<SelectField<T>> {
  late FocusNode _focusNode;
  final PopoverController _popoverController = PopoverController();
  late ValueNotifier<T?> _valueNotifier;
  bool _isHovered = false;
  bool _isOpen = false;

  // Index for keyboard navigation within the popup
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _valueNotifier = ValueNotifier(widget.value);
  }

  @override
  void didUpdateWidget(SelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode = widget.focusNode ?? FocusNode();
    }
    if (widget.value != oldWidget.value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _valueNotifier.value = widget.value;
      });
    } else if (widget.valueSelectionPredicate !=
        oldWidget.valueSelectionPredicate) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _valueNotifier.value = widget.value;
      });
    }
    if (widget.enabled != oldWidget.enabled ||
        widget.onChanged != oldWidget.onChanged) {
      bool enabled = widget.enabled ?? widget.onChanged != null;
      if (!enabled) {
        _focusNode.unfocus();
        _closePopup();
      }
    }
  }

  Widget get _placeholder {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }
    return const SizedBox();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _popoverController.dispose();
    _valueNotifier.dispose();
    super.dispose();
  }

  bool _onChanged(Object? value, bool selected) {
    if (!selected && !widget.canUnselect) {
      return false;
    }
    var selectionHandler = widget.valueSelectionHandler ??
        _defaultSingleSelectValueSelectionHandler;
    var newValue = selectionHandler(widget.value, value, selected);

    // Call onSelect for analytics/hooks
    widget.onSelect?.call(newValue);

    // Main value change
    widget.onChanged?.call(newValue);
    return true;
  }

  bool _isSelected(Object? value) {
    final selectionPredicate = widget.valueSelectionPredicate ??
        _defaultSingleSelectValueSelectionPredicate;
    return selectionPredicate(widget.value, value);
  }

  void _openPopup() {
    if (_isOpen) return;
    setState(() {
      _isOpen = true;
    });

    // Reset keyboard navigation
    _selectedIndex = -1;

    // Call the onOpen callback
    widget.onOpen?.call();

    GlobalKey popupKey = GlobalKey();
    final effectiveDirection =
        widget.textDirection ?? Directionality.of(context);

    _popoverController
        .show(
      context: context,
      offset: const Offset(0, 8),
      alignment: widget.popoverAlignment,
      anchorAlignment: widget.popoverAnchorAlignment,
      widthConstraint: widget.popupWidthConstraint,
      fixedSize: widget.fixedSize ?? Size(300, 600),
      overlayBarrier: OverlayBarrier(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) {
        return TrapFocus(
          focusNode: FocusNode(skipTraversal: false),
          child: Directionality(
            textDirection: effectiveDirection,
            child: Actions(
              actions: {
                SelectEscapeIntent: CallbackAction<SelectEscapeIntent>(
                  onInvoke: (_) => _closePopup(),
                ),
              },
              child: Shortcuts(
                shortcuts: {
                  LogicalKeySet(LogicalKeyboardKey.arrowDown):
                      const SelectNavigateIntent(isNext: true),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp):
                      const SelectNavigateIntent(isNext: false),
                  LogicalKeySet(LogicalKeyboardKey.enter):
                      const SelectItemIntent(),
                  LogicalKeySet(LogicalKeyboardKey.space):
                      const SelectItemIntent(),
                  LogicalKeySet(LogicalKeyboardKey.escape):
                      const SelectEscapeIntent(),
                },
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  constraints: widget.popupConstraints ??
                      BoxConstraints(
                        maxHeight: SelectField.kDefaultSelectMaxHeight,
                      ),
                  decoration: BoxDecoration(
                    color: widget.popupBackgroundColor ??
                        Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.popupBorderColor ??
                          Theme.of(context).colorScheme.outline,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: widget.popupElevation,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListenableBuilder(
                    listenable: _valueNotifier,
                    builder: (context, _) {
                      return Data.inherit(
                        key: ValueKey(widget.value),
                        data: SelectData(
                          enabled: widget.enabled ?? widget.onChanged != null,
                          autoClose: widget.autoClosePopover,
                          isSelected: _isSelected,
                          onChanged: _onChanged,
                          hasSelection: widget.value != null,
                          selectedIndex: _selectedIndex,
                          setSelectedIndex: _setSelectedIndex,
                        ),
                        child: Builder(
                          key: popupKey,
                          builder: (context) => widget.popup(context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    )
        .then((_) {
      _handlePopupClosed();
    });
  }

  void _handlePopupClosed() {
    if (!_isOpen) return;
    setState(() {
      _isOpen = false;
    });
    widget.onClose?.call();
    _focusNode.requestFocus();
  }

  void _closePopup() {
    if (!_isOpen) return;
    _popoverController.close();
  }

  void _setSelectedIndex(int index) {
    _selectedIndex = index;
  }

  void _clearSelection() {
    if (widget.value != null && widget.canUnselect) {
      widget.onChanged?.call(null);
      widget.onSelect?.call(null);
    }
  }

  BoxDecoration _getEffectiveDecoration(ThemeData theme) {
    final isEnabled = widget.enabled ?? widget.onChanged != null;

    if (!isEnabled && widget.disabledDecoration != null) {
      return widget.disabledDecoration!;
    }

    if (_focusNode.hasFocus && widget.focusedDecoration != null) {
      return widget.focusedDecoration!;
    }

    if (_isHovered && widget.hoverDecoration != null) {
      return widget.hoverDecoration!;
    }

    // Default decoration
    return widget.decoration ??
        BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          border: Border.all(
            color: _focusNode.hasFocus
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: _focusNode.hasFocus ? 2.0 : 1.0,
          ),
          color:
              widget.filled ? theme.colorScheme.surfaceContainerHighest : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.enabled ?? widget.onChanged != null;
    final effectiveDirection =
        widget.textDirection ?? Directionality.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Directionality(
        textDirection: effectiveDirection,
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: widget.constraints ?? const BoxConstraints(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: widget.accessibilityLabel,
                  hint: widget.accessibilityHint,
                  enabled: isEnabled,
                  onTap: isEnabled ? () => _openPopup() : null,
                  child: TapRegion(
                    onTapOutside: (event) {
                      _focusNode.unfocus();
                    },
                    child: Focus(
                      focusNode: _focusNode,
                      child: GestureDetector(
                        onTap: isEnabled ? () => _openPopup() : null,
                        child: AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          decoration: _getEffectiveDecoration(theme),
                          padding: widget.padding ??
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: widget.value != null &&
                                        (widget.showValuePredicate
                                                ?.call(widget.value as T) ??
                                            true)
                                    ? Builder(builder: (context) {
                                        return widget.itemBuilder(
                                          context,
                                          widget.value as T,
                                        );
                                      })
                                    : _placeholder,
                              ),
                              if (widget.showClearButton &&
                                  isEnabled &&
                                  widget.canUnselect &&
                                  widget.value != null) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: _clearSelection,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  splashRadius: 20,
                                  tooltip: 'Clear selection',
                                ),
                              ],
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: _isOpen ? 0.5 : 0,
                                duration: widget.animationDuration,
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: isEnabled ? 0.8 : 0.4,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

class FormSelectField<T> extends StatelessWidget {
  final FormKey<T?> formKey;
  final T? initialValue;
  final List<Validator<T?>> validators;

  final Widget? placeholder;
  final bool filled;
  final FocusNode? focusNode;
  final BoxConstraints? constraints;
  final BoxConstraints? popupConstraints;
  final PopoverConstraint popupWidthConstraint;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final bool disableHoverEffect;
  final bool canUnselect;
  final bool autoClosePopover;
  final bool enabled;
  final SelectPopupBuilder popup;
  final SelectValueBuilder<T> itemBuilder;
  final SelectValueSelectionHandler<T?>? valueSelectionHandler;
  final SelectValueSelectionPredicate<T?>? valueSelectionPredicate;
  final Predicate<T?>? showValuePredicate;
  final bool showClearButton;
  final Duration animationDuration;
  final Curve animationCurve;

  final String? label;
  final bool isRequired;
  final String? helperText;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Event callbacks
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final ValueChanged<T?>? onSelect;

  // Appearance
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;
  final TextDirection? textDirection;

  const FormSelectField({
    super.key,
    required this.formKey,
    this.initialValue,
    this.validators = const [],
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.anchorFixedSize,
    this.disableHoverEffect = false,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.canUnselect = false,
    this.autoClosePopover = true,
    this.enabled = true,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.showValuePredicate,
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    required this.popup,
    required this.itemBuilder,
    this.label,
    this.isRequired = false,
    this.helperText,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.onOpen,
    this.onClose,
    this.onSelect,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return FormEntry<T?>(
      formKey: formKey,
      initialValue: initialValue,
      validators: validators,
      builder: (context, field) {
        // Build error decoration when we have a validation error
        final effectiveErrorDecoration = field.error != null
            ? errorDecoration ??
                BoxDecoration(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.0,
                  ),
                )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              LabelText(label!, isRequired: isRequired),
              const SizedBox(height: 6),
            ],
            SelectField<T>(
              value: field.value,
              onChanged: (value) {
                field.setValue(value);
              },
              placeholder: placeholder,
              filled: filled,
              focusNode: focusNode,
              constraints: constraints,
              popupConstraints: popupConstraints,
              popupWidthConstraint: popupWidthConstraint,
              borderRadius: borderRadius,
              padding: padding,
              popoverAlignment: popoverAlignment,
              popoverAnchorAlignment: popoverAnchorAlignment,
              disableHoverEffect: disableHoverEffect,
              canUnselect: canUnselect,
              autoClosePopover: autoClosePopover,
              enabled: enabled && !field.isPending,
              popup: popup,
              itemBuilder: itemBuilder,
              valueSelectionHandler: valueSelectionHandler,
              valueSelectionPredicate: valueSelectionPredicate,
              showValuePredicate: showValuePredicate,
              showClearButton: showClearButton,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              accessibilityLabel: accessibilityLabel ??
                  (label != null
                      ? 'Select $label${isRequired ? " (required)" : ""}'
                      : null),
              accessibilityHint: accessibilityHint,
              onOpen: onOpen,
              onClose: onClose,
              onSelect: onSelect,
              popupElevation: popupElevation,
              popupBorderColor: popupBorderColor,
              popupBackgroundColor: popupBackgroundColor,
              decoration: decoration,
              focusedDecoration: focusedDecoration,
              hoverDecoration: hoverDecoration,
              errorDecoration: effectiveErrorDecoration,
              disabledDecoration: disabledDecoration,
              textDirection: textDirection,
            ),
            if (field.error != null) ...[
              const SizedBox(height: 6),
              ErrorMessage(errorText: field.error!),
            ] else if (field.isPending) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Validating...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ] else if (helperText != null) ...[
              const SizedBox(height: 6),
              HelperText(helperText!),
            ],
          ],
        );
      },
    );
  }
}

class MultiSelectField<T> extends StatefulWidget with SelectBase<Iterable<T>> {
  @override
  final ValueChanged<Iterable<T>?>? onChanged;
  @override
  final Widget? placeholder;
  @override
  final bool filled;
  @override
  final FocusNode? focusNode;
  @override
  final BoxConstraints? constraints;
  @override
  final BoxConstraints? popupConstraints;
  @override
  final PopoverConstraint popupWidthConstraint;
  final Iterable<T>? value;
  final Iterable<T>? allItems;
  @override
  final BorderRadius? borderRadius;
  @override
  final EdgeInsetsGeometry? padding;
  @override
  final AlignmentGeometry popoverAlignment;
  @override
  final AlignmentGeometry? popoverAnchorAlignment;
  @override
  final bool disableHoverEffect;
  @override
  final bool canUnselect;
  @override
  final bool? autoClosePopover;
  final bool? enabled;
  @override
  final SelectPopupBuilder popup;
  @override
  SelectValueBuilder<Iterable<T>> get itemBuilder => (context, value) {
        return _buildItem(multiItemBuilder, context, value);
      };
  @override
  final SelectValueSelectionHandler<Iterable<T>>? valueSelectionHandler;
  @override
  final SelectValueSelectionPredicate<Iterable<T>>? valueSelectionPredicate;
  final SelectValueBuilder<T> multiItemBuilder;
  @override
  final Predicate<Iterable<T>>? showValuePredicate;

  @override
  final bool showClearButton;
  @override
  final Duration animationDuration;
  @override
  final Curve animationCurve;

  @override
  final VoidCallback? onOpen;
  @override
  final VoidCallback? onClose;
  @override
  final ValueChanged<Iterable<T>?>? onSelect;

  // Whether to show Select All option
  final bool showSelectAll;
  final String selectAllLabel;
  final String clearAllLabel;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Appearance
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;
  final TextDirection? textDirection;
  final Size? fixedSize;

  const MultiSelectField({
    super.key,
    this.onChanged,
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.anchorFixedSize,
    this.value,
    this.allItems,
    this.disableHoverEffect = false,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.canUnselect = true,
    this.autoClosePopover = false,
    this.enabled,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.showValuePredicate,
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.onOpen,
    this.onClose,
    this.onSelect,
    this.showSelectAll = false,
    this.selectAllLabel = 'Select All',
    this.clearAllLabel = 'Clear All',
    required this.popup,
    required SelectValueBuilder<T> itemBuilder,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
    this.fixedSize,
  }) : multiItemBuilder = itemBuilder;

  static Widget _buildItem<T>(SelectValueBuilder<T> multiItemBuilder,
      BuildContext context, Iterable<T> value) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var item in value) multiItemBuilder(context, item),
      ],
    );
  }

  @override
  State<MultiSelectField<T>> createState() => _MultiSelectFieldState<T>();
}

class _MultiSelectFieldState<T> extends State<MultiSelectField<T>> {
  // State for Select All functionality
  bool? _allSelected;

  @override
  void initState() {
    super.initState();
    _updateSelectAllState();
  }

  @override
  void didUpdateWidget(MultiSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.allItems != oldWidget.allItems) {
      _updateSelectAllState();
    }
  }

  void _updateSelectAllState() {
    if (widget.allItems == null || widget.allItems!.isEmpty) {
      _allSelected = false;
      return;
    }

    if (widget.value == null || widget.value!.isEmpty) {
      _allSelected = false;
    } else if (widget.value!.length == widget.allItems!.length) {
      _allSelected = true;
    } else {
      _allSelected = null; // indeterminate state
    }
  }

  void _handleSelectAll() {
    if (_allSelected == true) {
      // Deselect all
      widget.onChanged?.call(null);
      widget.onSelect?.call(null);
    } else {
      // Select all
      widget.onChanged?.call(widget.allItems);
      widget.onSelect?.call(widget.allItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the standard SelectField to inject our Select All functionality
    final standardPopup = widget.popup;

    // Create a modified popup that includes Select All option when needed
    final wrappedPopup = widget.showSelectAll && widget.allItems != null
        ? (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      value: _allSelected,
                      tristate: true,
                      title: Text(_allSelected == true
                          ? widget.clearAllLabel
                          : widget.selectAllLabel),
                      onChanged: (_) => _handleSelectAll(),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      dense: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: standardPopup(context)),
              ],
            );
          }
        : standardPopup;

    return SelectField<Iterable<T>>(
      popup: wrappedPopup,
      itemBuilder: widget.itemBuilder,
      onChanged: widget.onChanged,
      placeholder: widget.placeholder,
      filled: widget.filled,
      focusNode: widget.focusNode,
      constraints: widget.constraints,
      popupConstraints: widget.popupConstraints,
      popupWidthConstraint: widget.popupWidthConstraint,
      value: widget.value,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      popoverAlignment: widget.popoverAlignment,
      popoverAnchorAlignment: widget.popoverAnchorAlignment,
      disableHoverEffect: widget.disableHoverEffect,
      canUnselect: widget.canUnselect,
      autoClosePopover: widget.autoClosePopover ?? false,
      enabled: widget.enabled,
      showValuePredicate: (test) {
        return test.isNotEmpty &&
            (widget.showValuePredicate?.call(test) ?? true);
      },
      valueSelectionHandler: widget.valueSelectionHandler ??
          _defaultMultiSelectValueSelectionHandler,
      valueSelectionPredicate: widget.valueSelectionPredicate ??
          _defaultMultiSelectValueSelectionPredicate,
      showClearButton: widget.showClearButton,
      animationDuration: widget.animationDuration,
      animationCurve: widget.animationCurve,
      onOpen: widget.onOpen,
      onClose: widget.onClose,
      onSelect: widget.onSelect,
      accessibilityLabel: widget.accessibilityLabel,
      accessibilityHint: widget.accessibilityHint,
      popupElevation: widget.popupElevation,
      popupBorderColor: widget.popupBorderColor,
      popupBackgroundColor: widget.popupBackgroundColor,
      decoration: widget.decoration,
      focusedDecoration: widget.focusedDecoration,
      hoverDecoration: widget.hoverDecoration,
      errorDecoration: widget.errorDecoration,
      disabledDecoration: widget.disabledDecoration,
      textDirection: widget.textDirection,
      fixedSize: widget.fixedSize,
    );
  }
}

class FormMultiSelectField<T> extends StatelessWidget {
  final FormKey<Iterable<T>> formKey;
  final Iterable<T>? initialValue;
  final List<Validator<Iterable<T>>> validators;

  final Widget? placeholder;
  final bool filled;
  final FocusNode? focusNode;
  final BoxConstraints? constraints;
  final BoxConstraints? popupConstraints;
  final PopoverConstraint popupWidthConstraint;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final bool disableHoverEffect;
  final bool canUnselect;
  final bool autoClosePopover;
  final bool enabled;
  final SelectPopupBuilder popup;
  final SelectValueBuilder<T> itemBuilder;
  final SelectValueSelectionHandler<Iterable<T>>? valueSelectionHandler;
  final SelectValueSelectionPredicate<Iterable<T>>? valueSelectionPredicate;
  final Predicate<Iterable<T>>? showValuePredicate;
  final Iterable<T>? allItems;
  final bool showSelectAll;
  final String selectAllLabel;
  final String clearAllLabel;

  final String? label;
  final bool isRequired;
  final String? helperText;
  final bool showClearButton;
  final Duration animationDuration;
  final Curve animationCurve;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Event callbacks
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final ValueChanged<Iterable<T>?>? onSelect;

  // Appearance
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;
  final TextDirection? textDirection;

  const FormMultiSelectField({
    super.key,
    required this.formKey,
    this.initialValue,
    this.validators = const [],
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.anchorFixedSize,
    this.disableHoverEffect = false,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.canUnselect = true,
    this.autoClosePopover = false,
    this.enabled = true,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.showValuePredicate,
    this.allItems,
    this.showSelectAll = false,
    this.selectAllLabel = 'Select All',
    this.clearAllLabel = 'Clear All',
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    required this.popup,
    required this.itemBuilder,
    this.label,
    this.isRequired = false,
    this.helperText,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.onOpen,
    this.onClose,
    this.onSelect,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return FormEntry<Iterable<T>>(
      formKey: formKey,
      initialValue: initialValue ?? <T>[],
      validators: validators,
      builder: (context, field) {
        // Build error decoration when we have a validation error
        final effectiveErrorDecoration = field.error != null
            ? errorDecoration ??
                BoxDecoration(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.0,
                  ),
                )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              LabelText(label!, isRequired: isRequired),
              const SizedBox(height: 6),
            ],
            MultiSelectField<T>(
              value: field.value,
              onChanged: (value) {
                field.setValue(value ?? <T>[]);
              },
              placeholder: placeholder,
              filled: filled,
              focusNode: focusNode,
              constraints: constraints,
              popupConstraints: popupConstraints,
              popupWidthConstraint: popupWidthConstraint,
              borderRadius: borderRadius,
              padding: padding,
              popoverAlignment: popoverAlignment,
              popoverAnchorAlignment: popoverAnchorAlignment,
              disableHoverEffect: disableHoverEffect,
              canUnselect: canUnselect,
              autoClosePopover: autoClosePopover,
              enabled: enabled && !field.isPending,
              popup: popup,
              itemBuilder: itemBuilder,
              valueSelectionHandler: valueSelectionHandler,
              valueSelectionPredicate: valueSelectionPredicate,
              showValuePredicate: showValuePredicate,
              allItems: allItems,
              showSelectAll: showSelectAll && allItems != null,
              selectAllLabel: selectAllLabel,
              clearAllLabel: clearAllLabel,
              showClearButton: showClearButton,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              accessibilityLabel: accessibilityLabel ??
                  (label != null
                      ? 'Multi-select $label${isRequired ? " (required)" : ""}'
                      : null),
              accessibilityHint: accessibilityHint,
              onOpen: onOpen,
              onClose: onClose,
              onSelect: onSelect,
              popupElevation: popupElevation,
              popupBorderColor: popupBorderColor,
              popupBackgroundColor: popupBackgroundColor,
              decoration: decoration,
              focusedDecoration: focusedDecoration,
              hoverDecoration: hoverDecoration,
              errorDecoration: effectiveErrorDecoration,
              disabledDecoration: disabledDecoration,
              textDirection: textDirection,
            ),
            if (field.error != null) ...[
              const SizedBox(height: 6),
              ErrorMessage(errorText: field.error!),
            ] else if (field.isPending) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Validating...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ] else if (helperText != null) ...[
              const SizedBox(height: 6),
              HelperText(helperText!),
            ],
          ],
        );
      },
    );
  }
}

class ControlledSelect<T> extends StatelessWidget with ControlledComponent<T?> {
  @override
  final T? initialValue;
  @override
  final ValueChanged<T?>? onChanged;
  @override
  final bool enabled;
  final SelectController<T>? selectController;

  final Widget? placeholder;
  final bool filled;
  final FocusNode? focusNode;
  final BoxConstraints? constraints;
  final BoxConstraints? popupConstraints;
  final PopoverConstraint popupWidthConstraint;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final bool disableHoverEffect;
  final bool canUnselect;
  final bool autoClosePopover;
  final SelectPopupBuilder popup;
  final SelectValueBuilder<T> itemBuilder;
  final SelectValueSelectionHandler<T?>? valueSelectionHandler;
  final SelectValueSelectionPredicate<T?>? valueSelectionPredicate;
  final Predicate<T?>? showValuePredicate;
  final bool showClearButton;
  final Duration animationDuration;
  final Curve animationCurve;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Appearance
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;
  final TextDirection? textDirection;
  final Size? fixedSize;

  const ControlledSelect({
    super.key,
    this.selectController,
    this.onChanged,
    this.enabled = true,
    this.initialValue,
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.anchorFixedSize,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.disableHoverEffect = false,
    this.canUnselect = false,
    this.autoClosePopover = true,
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    required this.popup,
    required this.itemBuilder,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.showValuePredicate,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
    this.fixedSize,
  });

  @override
  ComponentController<T?>? get controller => selectController;

  @override
  Widget build(BuildContext context) {
    return ControlledComponentAdapter<T?>(
      builder: (context, data) {
        return SelectField<T>(
          onChanged: data.onChanged,
          onSelect: selectController?._notifySelect,
          placeholder: placeholder,
          filled: filled,
          focusNode: focusNode,
          constraints: constraints,
          popupConstraints: popupConstraints,
          popupWidthConstraint: popupWidthConstraint,
          value: data.value,
          borderRadius: borderRadius,
          padding: padding,
          popoverAlignment: popoverAlignment,
          popoverAnchorAlignment: popoverAnchorAlignment,
          disableHoverEffect: disableHoverEffect,
          canUnselect: canUnselect,
          autoClosePopover: autoClosePopover,
          enabled: data.enabled,
          itemBuilder: itemBuilder,
          valueSelectionHandler: valueSelectionHandler,
          valueSelectionPredicate: valueSelectionPredicate,
          showValuePredicate: showValuePredicate,
          showClearButton: showClearButton,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          popup: popup,
          onOpen: selectController?.notifyOpen,
          onClose: selectController?.notifyClose,
          accessibilityLabel: accessibilityLabel,
          accessibilityHint: accessibilityHint,
          popupElevation: popupElevation,
          popupBorderColor: popupBorderColor,
          popupBackgroundColor: popupBackgroundColor,
          decoration: decoration,
          focusedDecoration: focusedDecoration,
          hoverDecoration: hoverDecoration,
          errorDecoration: errorDecoration,
          disabledDecoration: disabledDecoration,
          textDirection: textDirection,
          fixedSize: fixedSize,
        );
      },
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      controller: selectController,
    );
  }
}

class ControlledMultiSelect<T> extends StatelessWidget
    with ControlledComponent<Iterable<T>?> {
  @override
  final Iterable<T>? initialValue;
  @override
  final ValueChanged<Iterable<T>?>? onChanged;
  @override
  final bool enabled;
  final MultiSelectController<T>? multiSelectController;

  final Widget? placeholder;
  final bool filled;
  final FocusNode? focusNode;
  final BoxConstraints? constraints;
  final BoxConstraints? popupConstraints;
  final PopoverConstraint popupWidthConstraint;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final bool disableHoverEffect;
  final bool canUnselect;
  final bool autoClosePopover;
  final SelectPopupBuilder popup;
  final SelectValueBuilder<T> itemBuilder;
  final SelectValueSelectionHandler<Iterable<T>>? valueSelectionHandler;
  final SelectValueSelectionPredicate<Iterable<T>>? valueSelectionPredicate;
  final Predicate<Iterable<T>>? showValuePredicate;
  final Iterable<T>? allItems;
  final bool showSelectAll;
  final String selectAllLabel;
  final String clearAllLabel;
  final bool showClearButton;
  final Duration animationDuration;
  final Curve animationCurve;

  // Additional accessibility properties
  final String? accessibilityLabel;
  final String? accessibilityHint;

  // Appearance
  final double popupElevation;
  final Color? popupBorderColor;
  final Color? popupBackgroundColor;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final BoxDecoration? hoverDecoration;
  final BoxDecoration? errorDecoration;
  final BoxDecoration? disabledDecoration;
  final TextDirection? textDirection;
  final Size? fixedSize;

  const ControlledMultiSelect({
    super.key,
    this.multiSelectController,
    this.onChanged,
    this.enabled = true,
    this.initialValue,
    this.placeholder,
    this.filled = false,
    this.focusNode,
    this.constraints,
    this.popupConstraints,
    this.popupWidthConstraint = PopoverConstraint.anchorFixedSize,
    this.borderRadius,
    this.padding,
    this.popoverAlignment = Alignment.topCenter,
    this.popoverAnchorAlignment,
    this.disableHoverEffect = false,
    this.canUnselect = true,
    this.autoClosePopover = false,
    this.showValuePredicate,
    this.allItems,
    this.showSelectAll = false,
    this.selectAllLabel = 'Select All',
    this.clearAllLabel = 'Clear All',
    this.showClearButton = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    required this.popup,
    required this.itemBuilder,
    this.valueSelectionHandler,
    this.valueSelectionPredicate,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.popupElevation = 4.0,
    this.popupBorderColor,
    this.popupBackgroundColor,
    this.decoration,
    this.focusedDecoration,
    this.hoverDecoration,
    this.errorDecoration,
    this.disabledDecoration,
    this.textDirection,
    this.fixedSize,
  });

  @override
  ComponentController<Iterable<T>?>? get controller => multiSelectController;

  @override
  Widget build(BuildContext context) {
    return ControlledComponentAdapter<Iterable<T>?>(
      builder: (context, data) {
        return MultiSelectField<T>(
          onChanged: (value) {
            data.onChanged(value);
            multiSelectController?._notifySelect(value);
          },
          placeholder: placeholder,
          filled: filled,
          focusNode: focusNode,
          constraints: constraints,
          popupConstraints: popupConstraints,
          popupWidthConstraint: popupWidthConstraint,
          value: data.value ?? <T>[],
          borderRadius: borderRadius,
          padding: padding,
          popoverAlignment: popoverAlignment,
          popoverAnchorAlignment: popoverAnchorAlignment,
          disableHoverEffect: disableHoverEffect,
          canUnselect: canUnselect,
          autoClosePopover: autoClosePopover,
          enabled: data.enabled,
          popup: popup,
          itemBuilder: itemBuilder,
          valueSelectionHandler: valueSelectionHandler,
          valueSelectionPredicate: valueSelectionPredicate,
          showValuePredicate: showValuePredicate,
          allItems: allItems,
          showSelectAll: showSelectAll && allItems != null,
          selectAllLabel: selectAllLabel,
          clearAllLabel: clearAllLabel,
          showClearButton: showClearButton,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          onOpen: multiSelectController?.notifyOpen,
          onClose: multiSelectController?.notifyClose,
          accessibilityLabel: accessibilityLabel,
          accessibilityHint: accessibilityHint,
          popupElevation: popupElevation,
          popupBorderColor: popupBorderColor,
          popupBackgroundColor: popupBackgroundColor,
          decoration: decoration,
          focusedDecoration: focusedDecoration,
          hoverDecoration: hoverDecoration,
          errorDecoration: errorDecoration,
          disabledDecoration: disabledDecoration,
          textDirection: textDirection,
          fixedSize: fixedSize,
        );
      },
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      controller: multiSelectController,
    );
  }
}

class SelectData {
  final bool? autoClose;
  final Predicate<Object?> isSelected;
  final SelectValueChanged<Object?> onChanged;
  final bool hasSelection;
  final bool enabled;
  final int selectedIndex;
  final void Function(int) setSelectedIndex;

  const SelectData({
    required this.autoClose,
    required this.isSelected,
    required this.onChanged,
    required this.hasSelection,
    required this.enabled,
    this.selectedIndex = -1,
    required this.setSelectedIndex,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectData) return false;
    return other.isSelected == isSelected &&
        other.onChanged == onChanged &&
        other.hasSelection == hasSelection &&
        other.autoClose == autoClose &&
        other.enabled == enabled &&
        other.selectedIndex == selectedIndex;
  }

  @override
  int get hashCode => Object.hash(
      isSelected, onChanged, autoClose, hasSelection, enabled, selectedIndex);
}

class SelectItemButton<T> extends StatelessWidget {
  final T value;
  final Widget child;
  final ButtonVariant variant;
  final bool disabled;
  final String? tooltip;

  const SelectItemButton({
    super.key,
    required this.value,
    required this.child,
    this.variant = ButtonVariant.ghost,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final data = Data.maybeOf<SelectPopupHandle>(context);
    final bool isSelected = data?.isSelected(value) ?? false;
    final bool isEnabled = !disabled && (data?.isEnabled ?? true);
    return Semantics(
        selected: isSelected,
        enabled: isEnabled,
        hint: tooltip,
        button: true,
        child: Button(
          onPressed:
              isEnabled ? () => data?.selectItem(value, !isSelected) : null,
          disabled: !isEnabled,
          rightIcon: isSelected ? Icons.check : null,
          layout: ButtonLayout(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
          mouseCursor:
              isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          variant: variant,
          child: child,
        ));
  }
}

class MultiSelectChip extends StatelessWidget {
  final Object? value;
  final Widget child;
  final bool disabled;
  final String? tooltip;

  const MultiSelectChip({
    super.key,
    required this.value,
    required this.child,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final data = Data.maybeOf<SelectData>(context);
    final bool isEnabled = !disabled && (data?.enabled ?? true);

    return Semantics(
      selected: true,
      enabled: isEnabled,
      hint: tooltip,
      child: Chip(
        trailing: isEnabled
            ? ChipButton(
                onPressed: () {
                  data?.onChanged(value, false);
                },
                child: const Icon(Icons.close, size: 16),
              )
            : null,
        child: child,
      ),
    );
  }
}

class SelectItem extends StatelessWidget {
  final SelectItemBuilder builder;
  final Object? value;
  final bool disabled;
  final String? tooltip;

  const SelectItem({
    super.key,
    required this.value,
    required this.builder,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final data = Data.maybeOf<SelectData>(context);
    final selected = data?.isSelected(value) ?? false;
    final isEnabled = !disabled && (data?.enabled ?? true);

    final popupHandle = Data.maybeOf<SelectPopupHandle>(context);
    final isHighlighted = popupHandle?.highlightedIndex != null &&
        popupHandle?.itemAtIndex(popupHandle.highlightedIndex!) == value;

    return Semantics(
      selected: selected,
      enabled: isEnabled,
      hint: tooltip,
      focusable: isEnabled,
      focused: isHighlighted,
      child: WidgetStatesProvider(
        states: {
          if (selected) WidgetState.selected,
          if (isHighlighted) WidgetState.hovered,
          if (disabled) WidgetState.disabled,
        },
        child: InkWell(
          onTap: isEnabled ? () => data?.onChanged(value, !selected) : null,
          child: builder(context, selected, isHighlighted),
        ),
      ),
    );
  }
}

class SelectGroup extends StatelessWidget {
  final List<Widget>? headers;
  final List<Widget> children;
  final List<Widget>? footers;
  final String? groupLabel;

  const SelectGroup({
    super.key,
    this.headers,
    this.footers,
    required this.children,
    this.groupLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: groupLabel,
      explicitChildNodes: true,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headers != null) ...headers!,
          ...children,
          if (footers != null) ...footers!,
        ],
      ),
    );
  }
}

class SelectLabel extends StatelessWidget {
  final Widget child;

  const SelectLabel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: child,
      ),
    );
  }
}

// Focus trapping helper for keeping focus within the popup
class TrapFocus extends StatefulWidget {
  final FocusNode focusNode;
  final Widget child;

  const TrapFocus({
    super.key,
    required this.focusNode,
    required this.child,
  });

  @override
  State<TrapFocus> createState() => _TrapFocusState();
}

class _TrapFocusState extends State<TrapFocus> {
  @override
  void initState() {
    super.initState();
    // Request focus when first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Focus(
        focusNode: widget.focusNode,
        // Trap focus inside this widget
        onFocusChange: (focused) {
          if (!focused) {
            // If focus is lost, re-focus
            widget.focusNode.requestFocus();
          }
        },
        child: widget.child,
      ),
    );
  }
}

// Popup handling classes

mixin SelectPopupHandle {
  bool isSelected(Object? value);
  void selectItem(Object? value, bool selected);
  bool get hasSelection;
  bool get isEnabled;
  int? get highlightedIndex;
  Object? itemAtIndex(int index);

  static SelectPopupHandle of(BuildContext context) {
    return Data.of<SelectPopupHandle>(context);
  }
}

typedef SelectItemsBuilder<T> = FutureOr<SelectItemDelegate> Function(
    BuildContext context, String? searchQuery);

class SelectPopup<T> extends StatefulWidget {
  final SelectItemsBuilder<T>? builder;
  final FutureOr<SelectItemDelegate?>? items;
  final TextEditingController? searchController;
  final String? searchPlaceholder;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace)? errorBuilder;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final bool? autoClose;
  final bool? canUnselect;
  final bool enableSearch;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final bool disableVirtualization;
  final Duration searchDebounceTime;
  final bool showSelectAll;
  final Widget Function(BuildContext, bool?, VoidCallback)? selectAllBuilder;
  final Widget? divider;
  final EdgeInsetsGeometry? padding;
  final SelectFilterFunction<T>? filterFunction;
  final double? popupElevation;
  final bool keyboardNavigation;

  // Item height for virtualization optimization
  final double? itemHeight;
  final int? itemCacheCount;

  const SelectPopup.builder({
    super.key,
    required this.builder,
    this.searchController,
    this.searchPlaceholder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.autoClose,
    this.canUnselect,
    this.enableSearch = true,
    this.errorBuilder,
    this.scrollController,
    this.searchDebounceTime = const Duration(milliseconds: 300),
    this.showSelectAll = false,
    this.selectAllBuilder,
    this.divider,
    this.padding,
    this.filterFunction,
    this.popupElevation,
    this.keyboardNavigation = true,
    this.itemHeight,
    this.itemCacheCount,
  })  : items = null,
        shrinkWrap = false,
        disableVirtualization = false;

  const SelectPopup({
    super.key,
    this.items,
    this.searchController,
    this.searchPlaceholder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.autoClose,
    this.canUnselect,
    this.scrollController,
    this.shrinkWrap = true,
    this.searchDebounceTime = const Duration(milliseconds: 300),
    this.showSelectAll = false,
    this.selectAllBuilder,
    this.divider,
    this.padding,
    this.filterFunction,
    this.popupElevation,
    this.keyboardNavigation = true,
    this.itemHeight,
    this.itemCacheCount,
  })  : builder = null,
        enableSearch = false,
        disableVirtualization = false;

  const SelectPopup.noVirtualization({
    super.key,
    FutureOr<SelectItemList?>? this.items,
    this.searchController,
    this.searchPlaceholder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.autoClose,
    this.canUnselect,
    this.scrollController,
    this.searchDebounceTime = const Duration(milliseconds: 300),
    this.showSelectAll = false,
    this.selectAllBuilder,
    this.divider,
    this.padding,
    this.filterFunction,
    this.popupElevation,
    this.keyboardNavigation = true,
  })  : builder = null,
        enableSearch = false,
        disableVirtualization = true,
        shrinkWrap = false,
        itemHeight = null,
        itemCacheCount = null;

  /// A method used to implement SelectPopupBuilder
  SelectPopup<T> call(BuildContext context) {
    return this;
  }

  @override
  State<SelectPopup<T>> createState() => _SelectPopupState<T>();
}

class _SelectPopupState<T> extends State<SelectPopup<T>>
    with SelectPopupHandle {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  SelectData? _selectData;
  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  List<Object?> _itemValues = [];
  int? _highlightedIndex;

  // Value used to force rebuild on keyboard navigation
  final _navigationKey = ValueNotifier<int>(0);

  // Store the items delegate for accessing items during keyboard navigation
  SelectItemDelegate? _currentItems;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _scrollController = widget.scrollController ?? ScrollController();

    // Setup debounced search
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onSearchChanged() {
    // Debounce search query
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(widget.searchDebounceTime, () {
      if (_searchController.text != _lastSearchQuery) {
        setState(() {
          _lastSearchQuery = _searchController.text;
          // Reset highlighted index when search changes
          _highlightedIndex = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SelectPopup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchController != oldWidget.searchController) {
      _searchController.removeListener(_onSearchChanged);
      _searchController = widget.searchController ?? TextEditingController();
      _searchController.addListener(_onSearchChanged);
    }
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectData = Data.maybeOf<SelectData>(context);
  }

  @override
  int? get highlightedIndex => _highlightedIndex;

  @override
  Object? itemAtIndex(int index) {
    if (index < 0 || index >= _itemValues.length) return null;
    return _itemValues[index];
  }

  @override
  bool get hasSelection => _selectData?.hasSelection ?? false;

  @override
  bool get isEnabled => _selectData?.enabled ?? true;

  @override
  bool isSelected(Object? value) {
    return _selectData?.isSelected(value) ?? false;
  }

  @override
  void selectItem(Object? value, bool selected) {
    _selectData?.onChanged(value, selected);
    if (widget.autoClose ?? _selectData?.autoClose == true) {
      closeOverlay(context, value);
    }
  }

  // Keyboard navigation
  void _handleKeyboardNavigation(bool isDown) {
    if (_currentItems == null ||
        (_currentItems?.estimatedChildCount ?? 0) == 0) {
      return;
    }

    final itemCount = _currentItems!.estimatedChildCount!;

    if (_highlightedIndex == null) {
      // First navigation, select first/last item
      _highlightedIndex = isDown ? 0 : itemCount - 1;
    } else {
      // Move up/down
      if (isDown) {
        _highlightedIndex = (_highlightedIndex! + 1) % itemCount;
      } else {
        _highlightedIndex = (_highlightedIndex! - 1 + itemCount) % itemCount;
      }
    }

    // Notify SelectData about current highlight
    _selectData?.setSelectedIndex(_highlightedIndex!);

    // Ensure the highlighted item is visible
    if (_scrollController.hasClients) {
      final itemHeight =
          widget.itemHeight ?? 48.0; // Default item height estimate
      final targetScrollPos = _highlightedIndex! * itemHeight;

      if (targetScrollPos < _scrollController.offset) {
        _scrollController.jumpTo(targetScrollPos);
      } else if (targetScrollPos + itemHeight >
          _scrollController.offset +
              _scrollController.position.viewportDimension) {
        _scrollController.jumpTo(targetScrollPos +
            itemHeight -
            _scrollController.position.viewportDimension);
      }
    }

    // Force rebuild for visual feedback
    _navigationKey.value++;
  }

  void _selectHighlightedItem() {
    if (_highlightedIndex != null &&
        _highlightedIndex! >= 0 &&
        _highlightedIndex! < _itemValues.length) {
      final value = _itemValues[_highlightedIndex!];
      selectItem(value, !isSelected(value));
    }
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    _searchController.removeListener(_onSearchChanged);

    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    _debounceTimer?.cancel();
    _navigationKey.dispose();

    super.dispose();
  }

  // Build default widgets for consistent UX
  Widget _buildDefaultEmptyState(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        _searchController.text.isNotEmpty
            ? 'No results match "${_searchController.text}"'
            : 'No options available',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDefaultLoadingState(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading options...',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultErrorState(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load options',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSelectAll(
      BuildContext context, bool? allSelected, VoidCallback onToggle) {
    return Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        value: allSelected,
        tristate: true,
        title: Text(
          allSelected == true ? 'Deselect All' : 'Select All',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onChanged: (_) => onToggle(),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
      ),
    );
  }

  Widget _buildModal(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ModalContainer(
        clipBehavior: Clip.hardEdge,
        surfaceBlur: widget.surfaceBlur,
        surfaceOpacity: widget.surfaceOpacity,
        padding: EdgeInsets.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: widget.popupElevation ?? 0,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.enableSearch)
              InputTextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                features: [
                  InputFeature.leading(
                    child: const Icon(Icons.search),
                  ),
                  InputFeature.clear(
                    visibility: InputFeatureVisibility.textNotEmpty,
                  ),
                ],
                hintText: widget.searchPlaceholder ?? 'Search...',
              ),
            Flexible(
              child: CachedValueWidget(
                value: _lastSearchQuery,
                builder: (context, searchQuery) {
                  return FutureOrBuilder<SelectItemDelegate?>(
                    future: widget.builder != null
                        ? widget.builder!.call(context, searchQuery)
                        : widget.items != null
                            ? widget.items!
                            : SelectItemDelegate.empty,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        Widget loadingBuilder =
                            widget.loadingBuilder?.call(context) ??
                                _buildDefaultLoadingState(context);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.enableSearch)
                              widget.divider ?? const Divider(height: 1),
                            Flexible(child: loadingBuilder),
                          ],
                        );
                      }

                      if (snapshot.hasError) {
                        Widget errorBuilder = widget.errorBuilder?.call(
                              context,
                              snapshot.error!,
                              snapshot.stackTrace ?? StackTrace.current,
                            ) ??
                            _buildDefaultErrorState(
                                context, snapshot.error!, snapshot.stackTrace);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.enableSearch)
                              widget.divider ?? const Divider(height: 1),
                            Flexible(child: errorBuilder),
                          ],
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data?.estimatedChildCount != 0) {
                        var data = snapshot.data!;
                        _currentItems = data;

                        return CachedValueWidget(
                          value: data,
                          builder: (context, data) {
                            // Extract item values for keyboard navigation
                            if (data is SelectItemList &&
                                widget.keyboardNavigation) {
                              _itemValues = data.itemValues ??
                                  List.generate(data.estimatedChildCount,
                                      (index) => index);
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.enableSearch)
                                  widget.divider ?? const Divider(height: 1),

                                // Select All option for multi-select
                                if (widget.showSelectAll)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      widget.selectAllBuilder?.call(
                                            context,
                                            null, // Would need more context to determine true/false/null state
                                            () {}, // Callback for select all toggle
                                          ) ??
                                          _buildDefaultSelectAll(
                                            context,
                                            null, // Would need more context to determine true/false/null state
                                            () {}, // Callback for select all toggle
                                          ),
                                      widget.divider ??
                                          const Divider(height: 1),
                                    ],
                                  ),

                                Flexible(
                                  child: Padding(
                                    padding: widget.padding ?? EdgeInsets.zero,
                                    child: Stack(
                                      fit: StackFit.passthrough,
                                      children: [
                                        if (widget.disableVirtualization)
                                          SingleChildScrollView(
                                            controller: _scrollController,
                                            padding: const EdgeInsets.all(4),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                for (var i = 0;
                                                    i <
                                                        (data as SelectItemList)
                                                            .children
                                                            .length;
                                                    i++)
                                                  data.build(context, i),
                                              ],
                                            ),
                                          )
                                        else
                                          ListView.builder(
                                            controller: _scrollController,
                                            padding: const EdgeInsets.all(4),
                                            itemBuilder: data.build,
                                            shrinkWrap: widget.shrinkWrap,
                                            itemCount: data.estimatedChildCount,
                                            itemExtent: widget.itemHeight,
                                            cacheExtent:
                                                widget.itemHeight != null &&
                                                        widget.itemCacheCount !=
                                                            null
                                                    ? widget.itemHeight! *
                                                        widget.itemCacheCount!
                                                    : null,
                                          ),

                                        // Scroll indicators
                                        ListenableBuilder(
                                          listenable: _scrollController,
                                          builder: (context, child) {
                                            return Visibility(
                                              visible: _scrollController
                                                      .hasClients &&
                                                  _scrollController.offset > 0,
                                              child: Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: HoverActivity(
                                                  hitTestBehavior:
                                                      HitTestBehavior
                                                          .translucent,
                                                  debounceDuration:
                                                      const Duration(
                                                          milliseconds: 16),
                                                  onHover: () {
                                                    if (!_scrollController
                                                        .hasClients) {
                                                      return;
                                                    }
                                                    var value =
                                                        _scrollController
                                                                .offset -
                                                            8;
                                                    value = value.clamp(
                                                      0.0,
                                                      _scrollController.position
                                                          .maxScrollExtent,
                                                    );
                                                    _scrollController
                                                        .jumpTo(value);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withValues(
                                                                  alpha: 0.8),
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withValues(
                                                                  alpha: 0.0),
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons
                                                          .keyboard_arrow_up),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        ListenableBuilder(
                                          listenable: _scrollController,
                                          builder: (context, child) {
                                            return Visibility(
                                              visible: _scrollController
                                                      .hasClients &&
                                                  _scrollController.position
                                                      .hasContentDimensions &&
                                                  _scrollController.offset <
                                                      _scrollController.position
                                                          .maxScrollExtent,
                                              child: Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: HoverActivity(
                                                  hitTestBehavior:
                                                      HitTestBehavior
                                                          .translucent,
                                                  debounceDuration:
                                                      const Duration(
                                                          milliseconds: 16),
                                                  onHover: () {
                                                    if (!_scrollController
                                                        .hasClients) {
                                                      return;
                                                    }
                                                    var value =
                                                        _scrollController
                                                                .offset +
                                                            8;
                                                    value = value.clamp(
                                                      0.0,
                                                      _scrollController.position
                                                          .maxScrollExtent,
                                                    );
                                                    _scrollController
                                                        .jumpTo(value);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withValues(
                                                                  alpha: 0.8),
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withValues(
                                                                  alpha: 0.0),
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons
                                                          .keyboard_arrow_down),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      // Empty state
                      Widget emptyBuilder =
                          widget.emptyBuilder?.call(context) ??
                              _buildDefaultEmptyState(context);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.enableSearch)
                            widget.divider ?? const Divider(height: 1),
                          Flexible(child: emptyBuilder),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navigationKey,
      builder: (context, _) {
        return Data<SelectPopupHandle>.inherit(
          data: this,
          child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowDown):
                  SelectNavigateIntent(isNext: true),
              LogicalKeySet(LogicalKeyboardKey.arrowUp):
                  SelectNavigateIntent(isNext: false),
              LogicalKeySet(LogicalKeyboardKey.enter): SelectItemIntent(),
              LogicalKeySet(LogicalKeyboardKey.space): SelectItemIntent(),
              LogicalKeySet(LogicalKeyboardKey.escape): SelectEscapeIntent(),
            },
            child: Actions(
              actions: {
                SelectNavigateIntent: CallbackAction<SelectNavigateIntent>(
                  onInvoke: (intent) =>
                      _handleKeyboardNavigation(intent.isNext),
                ),
                SelectItemIntent: CallbackAction<SelectItemIntent>(
                  onInvoke: (_) => _selectHighlightedItem(),
                ),
                SelectEscapeIntent: CallbackAction<SelectEscapeIntent>(
                  onInvoke: (_) => closeOverlay(context),
                ),
              },
              child: _buildModal(context),
            ),
          ),
        );
      },
    );
  }
}

abstract class SelectItemDelegate with CachedValue {
  static const empty = EmptySelectItem();
  const SelectItemDelegate();

  Widget? build(BuildContext context, int index);
  int? get estimatedChildCount => null;

  List<Object?>? get itemValues => null;

  @override
  bool shouldRebuild(covariant SelectItemDelegate oldDelegate);
}

class EmptySelectItem extends SelectItemDelegate {
  const EmptySelectItem();

  @override
  Widget? build(BuildContext context, int index) => null;

  @override
  int get estimatedChildCount => 0;

  @override
  bool shouldRebuild(covariant EmptySelectItem oldDelegate) {
    return false;
  }
}

class SelectItemList extends SelectItemDelegate {
  final List<Widget> children;
  final List<Object?>? _itemValues;

  const SelectItemList({
    required this.children,
    List<Object?>? itemValues,
  }) : _itemValues = itemValues;

  @override
  Widget build(BuildContext context, int index) {
    return children[index];
  }

  @override
  int get estimatedChildCount => children.length;

  @override
  List<Object?>? get itemValues => _itemValues;

  @override
  bool shouldRebuild(covariant SelectItemList oldDelegate) {
    return !listEquals(oldDelegate.children, children);
  }
}
