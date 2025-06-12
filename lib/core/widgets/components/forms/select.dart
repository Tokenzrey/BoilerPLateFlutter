import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/forms/chip.dart';

/// Styling options for the SelectField trigger
class SelectTriggerStyle {
  /// Background color for the trigger
  final Color? backgroundColor;

  /// Border color for the trigger
  final Color? borderColor;

  /// Text color for the trigger
  final Color? textColor;

  /// Placeholder text color
  final Color? placeholderColor;

  /// Border width for the trigger
  final double? borderWidth;

  /// Border radius for the trigger
  final BorderRadius? borderRadius;

  /// Padding for the trigger content
  final EdgeInsetsGeometry? padding;

  /// Icon for the dropdown indicator
  final IconData? dropdownIcon;

  /// Color for the dropdown icon
  final Color? dropdownIconColor;

  /// Size for the dropdown icon
  final double? dropdownIconSize;

  /// Text style for the trigger
  final TextStyle? textStyle;

  /// Error state border color
  final Color? errorBorderColor;

  /// Disabled state colors
  final Color? disabledBorderColor;
  final Color? disabledTextColor;
  final Color? disabledBackgroundColor;

  const SelectTriggerStyle({
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.placeholderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.dropdownIcon,
    this.dropdownIconColor,
    this.dropdownIconSize,
    this.textStyle,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.disabledTextColor,
    this.disabledBackgroundColor,
  });
}

/// Configuration for the select popover
class SelectPopoverConfig {
  /// Maximum height of the popover
  final double? maxHeight;

  /// Minimum width of the popover
  final double? minWidth;

  /// Background color of the popover
  final Color? backgroundColor;

  /// Border radius of the popover
  final BorderRadius? borderRadius;

  /// Shadow for the popover
  final List<BoxShadow>? boxShadow;

  /// Padding inside the popover
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to show the search field
  final bool showSearch;

  /// Whether to show footer actions for multi-select
  final bool showFooterActions;

  /// Labels for footer buttons
  final String? confirmButtonLabel;
  final String? cancelButtonLabel;

  /// Search field placeholder text
  final String searchPlaceholder;

  /// Text to display when no options match search
  final String noMatchesText;

  /// Alignment of the popover with respect to the trigger
  final Alignment popoverAlignment;

  /// Alignment of anchor point on the trigger
  final Alignment anchorAlignment;

  /// Offset between trigger and popover
  final Offset offset;

  const SelectPopoverConfig({
    this.maxHeight = 350,
    this.minWidth = 200,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.contentPadding,
    this.showSearch = false,
    this.showFooterActions = true,
    this.confirmButtonLabel = 'OK',
    this.cancelButtonLabel = 'Cancel',
    this.searchPlaceholder = 'Search...',
    this.noMatchesText = 'No matching options',
    this.popoverAlignment = Alignment.topRight,
    this.anchorAlignment = Alignment.bottomRight,
    this.offset = const Offset(0, 8),
  });
}

/// A versatile select/dropdown field for Flutter forms using custom popover for menu display.
/// Supports both single and multi select, grouped/collapsible options with smooth animations.
class SelectField<T> extends StatefulWidget {
  /// Label displayed above the select field
  final String? label;

  /// Currently selected value(s)
  final T? value;

  /// Currently selected values for multi-select
  final List<T>? values;

  /// Callback when selection changes
  final void Function(T?)? onChanged;

  /// Callback when multiple selection changes
  final void Function(List<T>)? onValuesChanged;

  /// List of options to display
  final List<SelectOption<T>>? options;

  /// List of option groups to display
  final List<SelectGroup<T>>? groups;

  /// Whether to allow multiple selections
  final bool isMulti;

  /// Placeholder text when no selection
  final String? placeholder;

  /// Whether the field is disabled
  final bool disabled;

  /// Whether to show search field in the popover
  final bool searchable;

  /// Whether to show clear button
  final bool showClear;

  /// Trigger type (button, textField, chip)
  final SelectTriggerType triggerType;

  /// Custom builder for trigger
  final Widget Function(BuildContext, dynamic, VoidCallback)? triggerBuilder;

  /// Custom builder for option items
  final Widget Function(BuildContext, SelectOption<T>, bool, VoidCallback)?
      optionBuilder;

  /// Custom builder for group headers
  final Widget Function(
          BuildContext, SelectGroup<T>, bool, VoidCallback, int selectedCount)?
      groupBuilder;

  /// Custom builder for empty state
  final Widget Function(BuildContext, String)? emptyStateBuilder;

  /// Custom builder for the entire popover content
  final Widget Function(BuildContext, SelectPopoverProps<T>)? popoverBuilder;

  /// Configuration for the popover
  final SelectPopoverConfig popoverConfig;

  /// Styling for the trigger
  final SelectTriggerStyle? triggerStyle;

  /// Button styles when using button trigger
  final ButtonVariant? buttonVariant;
  final ButtonColors? buttonColors;
  final ButtonLayout? buttonLayout;

  /// Error text to display
  final String? errorText;

  /// Helper text to display
  final String? helperText;

  const SelectField({
    super.key,
    this.label,
    this.value,
    this.values,
    this.onChanged,
    this.onValuesChanged,
    this.options,
    this.groups,
    this.isMulti = false,
    this.placeholder = 'Select an option',
    this.disabled = false,
    this.searchable = false,
    this.showClear = false,
    this.triggerType = SelectTriggerType.button,
    this.triggerBuilder,
    this.optionBuilder,
    this.groupBuilder,
    this.emptyStateBuilder,
    this.popoverBuilder,
    this.popoverConfig = const SelectPopoverConfig(),
    this.triggerStyle,
    this.buttonVariant,
    this.buttonColors,
    this.buttonLayout,
    this.errorText,
    this.helperText,
  })  : assert(
          (options != null || groups != null),
          'Either options or groups must be provided',
        ),
        assert(
          isMulti
              ? (onValuesChanged != null || values != null)
              : (onChanged != null || value != null),
          'For multi-select, provide onValuesChanged callback or values. For single-select, provide onChanged callback or value.',
        );

  @override
  State<SelectField<T>> createState() => _SelectFieldState<T>();
}

/// Props passed to custom popover builder
class SelectPopoverProps<T> {
  /// Options to display
  final List<SelectOption<T>>? options;

  /// Option groups to display
  final List<SelectGroup<T>>? groups;

  /// Whether multi-selection is enabled
  final bool isMulti;

  /// Current value (for single select)
  final T? value;

  /// Current values (for multi select)
  final List<T> values;

  /// Called when selection changes
  final void Function(dynamic) onSelect;

  /// Called to confirm multi-selection
  final VoidCallback? onConfirm;

  /// Called to cancel multi-selection
  final VoidCallback? onCancel;

  /// Whether search is enabled
  final bool searchable;

  /// Search query string - replaces the controller to avoid lifecycle issues
  final String searchQuery;

  /// Called when search query changes
  final ValueChanged<String> onSearchChanged;

  /// Custom builder for options
  final Widget Function(BuildContext, SelectOption<T>, bool, VoidCallback)?
      optionBuilder;

  /// Custom builder for groups
  final Widget Function(
          BuildContext, SelectGroup<T>, bool, VoidCallback, int selectedCount)?
      groupBuilder;

  /// Custom builder for empty state
  final Widget Function(BuildContext, String)? emptyStateBuilder;

  /// Popover configuration
  final SelectPopoverConfig config;

  const SelectPopoverProps({
    required this.options,
    required this.groups,
    required this.isMulti,
    required this.value,
    required this.values,
    required this.onSelect,
    this.onConfirm,
    this.onCancel,
    required this.searchable,
    required this.searchQuery,
    required this.onSearchChanged,
    this.optionBuilder,
    this.groupBuilder,
    this.emptyStateBuilder,
    required this.config,
  });
}

class _SelectFieldState<T> extends State<SelectField<T>> {
  // For current value in single-select mode
  T? _currentValue;
  // For current values in multi-select mode
  late List<T> _currentValues;
  // Controller for input text field display
  final _textEditingController = TextEditingController();
  // Focus node for the trigger
  final _focusNode = FocusNode();
  // Layer link for popover positioning
  final _layerLink = LayerLink();
  // Search query text for the popover
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _updateTextController();
  }

  void _initializeValues() {
    // Initialize values based on controlled/uncontrolled mode
    if (widget.isMulti) {
      _currentValues =
          widget.values != null ? List<T>.from(widget.values!) : [];
    } else {
      _currentValue = widget.value;
    }
  }

  @override
  void didUpdateWidget(SelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle prop changes separately for multi vs single select
    if (widget.isMulti) {
      if (widget.values != oldWidget.values && widget.values != null) {
        // Only update if we're in controlled mode and values changed
        _currentValues = List<T>.from(widget.values!);
        _updateTextController();
      }
    } else {
      if (widget.value != oldWidget.value) {
        // Update if value prop changed
        _currentValue = widget.value;
        _updateTextController();
      }
    }

    // Handle switching between multi and single select
    if (widget.isMulti != oldWidget.isMulti) {
      _initializeValues();
      _updateTextController();
    }
  }

  void _updateTextController() {
    _textEditingController.text = _displayLabel;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  // Get all options flattened (from both options and groups)
  List<SelectOption<T>> get _allOptions {
    final List<SelectOption<T>> allOptions = [];

    if (widget.options != null) {
      allOptions.addAll(widget.options!);
    }

    if (widget.groups != null) {
      for (final group in widget.groups!) {
        allOptions.addAll(group.options);
      }
    }

    return allOptions;
  }

  // Get display label for current selection
  String get _displayLabel {
    if (widget.isMulti) {
      final selectedValues = widget.values ?? _currentValues;
      if (selectedValues.isEmpty) return widget.placeholder ?? '';

      if (selectedValues.length == 1) {
        final option = _findOptionByValue(selectedValues.first);
        return option?.label ?? selectedValues.first.toString();
      }

      return '${selectedValues.length} selected';
    } else {
      final currentValue = widget.value ?? _currentValue;
      if (currentValue == null) return widget.placeholder ?? '';

      final option = _findOptionByValue(currentValue);
      return option?.label ?? currentValue.toString();
    }
  }

  // Find option by value
  SelectOption<T>? _findOptionByValue(T? value) {
    if (value == null) return null;
    try {
      return _allOptions.firstWhere(
        (opt) => opt.value == value,
        orElse: () => SelectOption<T>(value: value, label: value.toString()),
      );
    } catch (_) {
      return null;
    }
  }

  // Handle search query changes from popover
  void _handleSearchChanged(String query) {
    _searchQuery = query;
  }

  // Handle opening the popover with improved focus handling
  void _showOptions() {
    if (widget.disabled) return;

    // Reset search query
    _searchQuery = '';

    // Open the popover
    showPopover(
      context: context,
      layerLink: _layerLink,
      alignment: widget.popoverConfig.popoverAlignment,
      anchorAlignment: widget.popoverConfig.anchorAlignment,
      widthConstraint: PopoverConstraint.flexible,
      offset: widget.popoverConfig.offset,
      stayVisibleOnScroll: true,
      alwaysFocus: true,
      builder: (_) {
        final props = SelectPopoverProps<T>(
          options: widget.options,
          groups: widget.groups,
          isMulti: widget.isMulti,
          value: widget.isMulti ? null : (widget.value ?? _currentValue),
          values: widget.isMulti ? (widget.values ?? _currentValues) : [],
          onSelect: _handleSelect,
          onConfirm: widget.isMulti ? _handleConfirm : null,
          onCancel: widget.isMulti ? _handleCancel : null,
          searchable: widget.searchable,
          searchQuery: _searchQuery,
          onSearchChanged: _handleSearchChanged,
          optionBuilder: widget.optionBuilder,
          groupBuilder: widget.groupBuilder,
          emptyStateBuilder: widget.emptyStateBuilder,
          config: widget.popoverConfig,
        );

        // Use custom popover builder if provided, otherwise use default
        return widget.popoverBuilder != null
            ? widget.popoverBuilder!(context, props)
            : SelectPopover<T>(
                options: props.options,
                groups: props.groups,
                isMulti: props.isMulti,
                value: props.value,
                values: props.values,
                onSelect: props.onSelect,
                onConfirm: props.onConfirm,
                onCancel: props.onCancel,
                searchable: props.searchable,
                searchQuery: props.searchQuery,
                onSearchChanged: props.onSearchChanged,
                optionBuilder: props.optionBuilder,
                groupBuilder: props.groupBuilder,
                emptyStateBuilder: props.emptyStateBuilder,
                config: props.config,
              );
      },
    );
  }

  // Handle selection from popover (single mode)
  void _handleSelect(dynamic value) {
    if (widget.isMulti) {
      if (value is List) {
        // Cast to ensure type safety and handle multi-select
        final typedList = value.cast<T>().toList();

        // Update internal state if we're in uncontrolled mode
        if (widget.values == null) {
          setState(() {
            _currentValues = typedList;
          });
        }

        // Always notify parent through callback if provided
        if (widget.onValuesChanged != null) {
          widget.onValuesChanged!(typedList);
        }
      }
    } else {
      // Single select mode
      final typedValue = value as T?;

      // Update internal state if we're in uncontrolled mode
      if (widget.value == null) {
        setState(() {
          _currentValue = typedValue;
        });
      }

      // Notify parent through callback if provided
      if (widget.onChanged != null) {
        widget.onChanged!(typedValue);
      }

      // Close popover for single select after selection
      closeOverlay(context);
    }
  }

  // Handle confirm for multi-select
  void _handleConfirm() {
    // For multi-select, we only notify parent of changes when confirmed
    if (widget.isMulti && widget.onValuesChanged != null) {
      widget.onValuesChanged!(_currentValues);
    }

    // Close the popover
    closeOverlay(context);
  }

  // Handle cancel for multi-select
  void _handleCancel() {
    // Revert temp values to match controlled props
    if (widget.values != null) {
      setState(() {
        _currentValues = List<T>.from(widget.values!);
      });
    }

    // Close the popover without saving changes
    closeOverlay(context);
  }

  // Clear selection
  void _clearSelection() {
    if (widget.disabled) return;

    if (widget.isMulti) {
      // Update internal state if we're in uncontrolled mode
      if (widget.values == null) {
        setState(() {
          _currentValues = [];
        });
      }

      // Notify parent through callback
      if (widget.onValuesChanged != null) {
        widget.onValuesChanged!([]);
      }
    } else {
      // Update internal state if we're in uncontrolled mode
      if (widget.value == null) {
        setState(() {
          _currentValue = null;
        });
      }

      // Notify parent through callback
      if (widget.onChanged != null) {
        widget.onChanged!(null);
      }
    }
  }

  // Handle removal of a single chip
  void _handleChipRemoval(T valueToRemove) {
    if (widget.disabled) return;

    if (widget.isMulti) {
      // Create a new list excluding the removed value
      final updatedValues = List<T>.from(widget.values ?? _currentValues)
        ..removeWhere((value) => value == valueToRemove);

      // Update internal state if we're in uncontrolled mode
      if (widget.values == null) {
        setState(() {
          _currentValues = updatedValues;
        });
      }

      // Always notify parent through callback if provided
      if (widget.onValuesChanged != null) {
        widget.onValuesChanged!(updatedValues);
      }
    } else {
      // Single value - just clear it
      _clearSelection();
    }
  }

  // Build the trigger widget based on type
  Widget _buildTrigger() {
    // Use custom trigger builder if provided
    if (widget.triggerBuilder != null) {
      return widget.triggerBuilder!(
          context,
          widget.isMulti
              ? (widget.values ?? _currentValues)
              : (widget.value ?? _currentValue),
          _showOptions);
    }

    // Default trigger builder based on triggerType
    switch (widget.triggerType) {
      case SelectTriggerType.textField:
        return _buildTextFieldTrigger();
      case SelectTriggerType.chip:
        return _buildChipTrigger();
      case SelectTriggerType.button:
        return _buildButtonTrigger();
    }
  }

  // Button style trigger using the Button component
  Widget _buildButtonTrigger() {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final style = widget.triggerStyle ?? const SelectTriggerStyle();

    // Apply style in order: default → triggerStyle → buttonColors
    final ButtonColors effectiveColors = ButtonColors(
      text: widget.disabled
          ? style.disabledTextColor ?? AppColors.neutral[600]
          : style.textColor ??
              (widget.value == null && widget.values?.isEmpty != false
                  ? style.placeholderColor ?? AppColors.neutral[600]
                  : AppColors.neutral[950]),
      background: widget.disabled
          ? style.disabledBackgroundColor ?? AppColors.neutral[100]
          : style.backgroundColor ?? (AppColors.neutral[50] ?? Colors.white),
      border: hasError
          ? style.errorBorderColor ?? AppColors.red[400]
          : (widget.disabled
              ? style.disabledBorderColor ?? AppColors.neutral[300]
              : style.borderColor ?? AppColors.neutral[400]),
    );

    final ButtonColors mergedColors = widget.buttonColors != null
        ? ButtonColors(
            text: widget.buttonColors?.text ?? effectiveColors.text,
            background:
                widget.buttonColors?.background ?? effectiveColors.background,
            border: widget.buttonColors?.border ?? effectiveColors.border,
          )
        : effectiveColors;

    return Button(
      onPressed: widget.disabled ? null : _showOptions,
      disabled: widget.disabled,
      text: _displayLabel,
      variant: widget.buttonVariant ?? ButtonVariant.outlined,
      rightIcon: style.dropdownIcon ?? Icons.arrow_drop_down,
      layout: (widget.buttonLayout ??
          ButtonLayout(
            expanded: true,
            contentAlignment: MainAxisAlignment.spaceBetween,
          )),
      colors: mergedColors,
      rightWidget: widget.showClear &&
              ((widget.isMulti && (widget.values?.isNotEmpty ?? false)) ||
                  (!widget.isMulti && widget.value != null))
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _clearSelection,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              splashRadius: 20,
              color: AppColors.neutral[600],
            )
          : null,
    );
  }

  // TextField style trigger using InputTextField component
  Widget _buildTextFieldTrigger() {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final style = widget.triggerStyle ?? const SelectTriggerStyle();

    final borderRadius = style.borderRadius ?? BorderRadius.circular(8);
    final borderColor = hasError
        ? style.errorBorderColor ?? AppColors.red[400] ?? Colors.red
        : (widget.disabled
            ? style.disabledBorderColor ??
                AppColors.neutral[300] ??
                Colors.grey.shade300
            : style.borderColor ?? AppColors.neutral[400] ?? Colors.grey);

    return GestureDetector(
      onTap: widget.disabled ? null : _showOptions,
      child: InputTextField(
        controller: _textEditingController,
        focusNode: _focusNode,
        readOnly: true,
        enabled: !widget.disabled,
        errorText: widget.errorText,
        hintText: widget.placeholder,
        textStyle: style.textStyle,
        features: [
          if (widget.showClear &&
              ((widget.isMulti && (widget.values?.isNotEmpty ?? false)) ||
                  (!widget.isMulti && widget.value != null)))
            InputFeature.trailing(
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: _clearSelection,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
              visibility: InputFeatureVisibility.always,
            ),
          InputFeature.trailing(
            child: Icon(
              style.dropdownIcon ?? Icons.arrow_drop_down,
              color: style.dropdownIconColor ??
                  (widget.disabled
                      ? AppColors.neutral[400]
                      : AppColors.neutral[700]),
              size: style.dropdownIconSize ?? 24,
            ),
            visibility: InputFeatureVisibility.always,
          ),
        ],
        decoration: InputDecoration(
          contentPadding: style.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: borderColor,
              width: style.borderWidth ?? 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: borderColor,
              width: style.borderWidth ?? 1.0,
            ),
          ),
          fillColor: widget.disabled
              ? style.disabledBackgroundColor ?? AppColors.neutral[100]
              : style.backgroundColor ?? AppColors.neutral[50],
          filled: true,
        ),
      ),
    );
  }

  // Chip style trigger using ChipField component with improved chip deletion
  Widget _buildChipTrigger() {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final style = widget.triggerStyle ?? const SelectTriggerStyle();

    // Convert selected values to ChipData format for ChipField
    List<ChipData> selectedChips = [];

    if (widget.isMulti) {
      final values = widget.values ?? _currentValues;
      if (values.isNotEmpty) {
        selectedChips = values.map((item) {
          final option = _findOptionByValue(item);
          final label = option?.label ?? item.toString();

          return ChipData(
            label: label,
            value: item,
            deletable: !widget.disabled,
            // Don't make chips togglable - they should always appear selected
            disabled: widget
                .disabled, // Disable chip interaction, only delete button works
          );
        }).toList();
      }
    } else if (widget.value != null) {
      final option = _findOptionByValue(widget.value);
      final label = option?.label ?? widget.value.toString();

      selectedChips = [
        ChipData(
          label: label,
          value: widget.value,
          deletable: !widget.disabled,
          disabled: widget.disabled, // Disable chip interaction
        )
      ];
    }

    final borderRadius = style.borderRadius ?? BorderRadius.circular(8);
    final borderColor = hasError
        ? style.errorBorderColor ?? AppColors.red[400] ?? Colors.red
        : (widget.disabled
            ? style.disabledBorderColor ??
                AppColors.neutral[300] ??
                Colors.grey.shade300
            : style.borderColor ??
                AppColors.neutral[400] ??
                Colors.grey.shade400);

    final backgroundColor = widget.disabled
        ? style.disabledBackgroundColor ??
            AppColors.neutral[100] ??
            Colors.grey.shade100
        : style.backgroundColor ?? AppColors.neutral[50] ?? Colors.white;

    final textColor = widget.disabled
        ? style.disabledTextColor ?? AppColors.neutral[500]
        : (selectedChips.isEmpty
            ? style.placeholderColor ??
                AppColors.neutral[600] ??
                Colors.grey.shade600
            : style.textColor ??
                AppColors.neutral[800] ??
                Colors.grey.shade800);

    return InkWell(
      onTap: widget.disabled ? null : _showOptions,
      borderRadius: borderRadius,
      child: Container(
        padding: style.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: style.borderWidth ?? 1.0,
          ),
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedChips.isNotEmpty
                  ? ChipField(
                      chips: selectedChips,
                      onChanged: (values) {
                        // This handler is only called when chips are removed via delete icon
                        if (widget.isMulti) {
                          // Find values that were removed
                          final currentValues = widget.values ?? _currentValues;
                          final remainingValues = <T>[];

                          // Keep only values that still exist in the values parameter
                          for (final value in currentValues) {
                            if (values.contains(value)) {
                              remainingValues.add(value);
                            }
                          }

                          // Update via the dedicated handler
                          if (remainingValues.length != currentValues.length) {
                            if (widget.onValuesChanged != null) {
                              widget.onValuesChanged!(remainingValues);
                            } else {
                              setState(() {
                                _currentValues = remainingValues;
                              });
                            }
                          }
                        } else if (values.isEmpty && widget.onChanged != null) {
                          // For single select, just clear if the chip was deleted
                          widget.onChanged!(null);
                        }
                      },
                      // Chips are not interactive - only their delete buttons
                      inputEnabled: false,
                      // Custom chip builder to ensure only delete icon is clickable
                      chipBuilder: (context, chip, selected, onTap, onDelete) {
                        return ChipWidget(
                          label: chip.label,
                          selected: true, // Always show as selected
                          disabled: chip.disabled, // Disable the chip itself
                          deletable: chip.deletable,
                          icon: chip.icon,
                          avatar: chip.avatar,
                          onTap: () {}, // No-op - chips shouldn't toggle
                          onDelete: chip.deletable && !widget.disabled
                              ? () => _handleChipRemoval(chip.value as T)
                              : null,
                          style: ChipStyle(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            borderColor: AppColors.primary,
                            textColor: AppColors.primary,
                          ),
                        );
                      },
                    )
                  : Text(
                      widget.placeholder ?? '',
                      style: style.textStyle?.copyWith(color: textColor) ??
                          TextStyle(color: textColor),
                    ),
            ),
            if (widget.showClear && selectedChips.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: _clearSelection,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                splashRadius: 16,
                color: AppColors.neutral[600],
              ),
            Icon(
              style.dropdownIcon ?? Icons.arrow_drop_down,
              color: style.dropdownIconColor ??
                  (widget.disabled
                      ? AppColors.neutral[400] ?? Colors.grey.shade400
                      : AppColors.neutral[700] ?? Colors.grey.shade700),
              size: style.dropdownIconSize ?? 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.disabled
                  ? AppColors.neutral[500] ?? Colors.grey.shade500
                  : AppColors.neutral[800] ?? Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: _buildTrigger(),
        ),
        if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          ErrorMessage(errorText: widget.errorText!),
        ] else if (widget.helperText != null &&
            widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          HelperText(widget.helperText!),
        ],
      ],
    );
  }
}

/// Popover content for displaying select options
class SelectPopover<T> extends StatefulWidget {
  final List<SelectOption<T>>? options;
  final List<SelectGroup<T>>? groups;
  final bool isMulti;
  final T? value;
  final List<T> values;
  final Function(dynamic) onSelect;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool searchable;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Widget Function(BuildContext, SelectOption<T>, bool, VoidCallback)?
      optionBuilder;
  final Widget Function(
          BuildContext, SelectGroup<T>, bool, VoidCallback, int selectedCount)?
      groupBuilder;
  final Widget Function(BuildContext, String)? emptyStateBuilder;
  final SelectPopoverConfig config;

  const SelectPopover({
    super.key,
    this.options,
    this.groups,
    required this.isMulti,
    this.value,
    required this.values,
    required this.onSelect,
    this.onConfirm,
    this.onCancel,
    this.searchable = false,
    required this.searchQuery,
    required this.onSearchChanged,
    this.optionBuilder,
    this.groupBuilder,
    this.emptyStateBuilder,
    required this.config,
  });

  @override
  State<SelectPopover<T>> createState() => _SelectPopoverState<T>();
}

class _SelectPopoverState<T> extends State<SelectPopover<T>> {
  // For expanded/collapsed state of groups
  final Map<int, bool> _expandedGroups = {};
  // For filtered options based on search
  late String _searchQuery;
  // For managing selected values locally
  late List<T> _localSelectedValues;
  // For managing single selection locally
  T? _localSelectedValue;
  // Dedicated FocusNode for search field to ensure it can be focused
  final FocusNode _searchFocusNode = FocusNode();
  // Dedicated TextEditingController that lives and dies with this widget instance
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize group expansion state
    if (widget.groups != null) {
      for (int i = 0; i < widget.groups!.length; i++) {
        _expandedGroups[i] = true;
      }
    }

    // Initialize local selection state
    if (widget.isMulti) {
      _localSelectedValues = List<T>.from(widget.values);
    } else {
      _localSelectedValue = widget.value;
    }

    // Initialize search controller and query
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchQuery = widget.searchQuery;

    // Setup search controller listener
    if (widget.searchable) {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void didUpdateWidget(SelectPopover<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update local values if props change
    if (widget.isMulti && widget.values != oldWidget.values) {
      _localSelectedValues = List<T>.from(widget.values);
    } else if (!widget.isMulti && widget.value != oldWidget.value) {
      _localSelectedValue = widget.value;
    }

    // Update search query if it changed externally
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchQuery = widget.searchQuery;
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
    });
    widget.onSearchChanged(query);
  }

  // Check if an option matches the search query
  bool _matchesSearch(SelectOption<T> option) {
    if (!widget.searchable || _searchQuery.isEmpty) return true;
    return option.label.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  // Count selected options in a group
  int _getSelectedCountInGroup(SelectGroup<T> group) {
    if (!widget.isMulti) return 0;

    final selectedValues = _localSelectedValues;
    return group.options
        .where((option) => selectedValues.contains(option.value))
        .length;
  }

  // Handle option selection
  void _handleOptionSelect(T value) {
    if (widget.isMulti) {
      setState(() {
        // Toggle selection in multi-select mode
        if (_localSelectedValues.contains(value)) {
          _localSelectedValues.remove(value);
        } else {
          _localSelectedValues.add(value);
        }
      });

      // Notify parent of selection change
      widget.onSelect(List<T>.from(_localSelectedValues));
    } else {
      // Single select mode - immediately select and notify
      setState(() {
        _localSelectedValue = value;
      });

      // Notify parent of selection
      widget.onSelect(value);
    }
  }

  // Select all options in a group
  void _selectAllInGroup(int groupIndex) {
    if (!widget.isMulti) return;

    setState(() {
      final group = widget.groups![groupIndex];

      // Get enabledOptions that match search
      final enabledOptions = group.options
          .where((option) => !option.disabled && _matchesSearch(option))
          .toList();

      // Check if all enabled options are already selected
      final bool allSelected = enabledOptions
          .every((option) => _localSelectedValues.contains(option.value));

      if (allSelected) {
        // Deselect all in group
        for (final option in enabledOptions) {
          _localSelectedValues.remove(option.value);
        }
      } else {
        // Select all in group
        for (final option in enabledOptions) {
          if (!_localSelectedValues.contains(option.value)) {
            _localSelectedValues.add(option.value);
          }
        }
      }
    });

    // Notify parent of selection change
    widget.onSelect(List<T>.from(_localSelectedValues));
  }

  // Toggle group expanded state
  void _toggleGroup(int groupIndex) {
    setState(() {
      _expandedGroups[groupIndex] = !(_expandedGroups[groupIndex] ?? true);
    });
  }

  // Build option item
  Widget _buildOptionItem(SelectOption<T> option) {
    final bool isSelected = widget.isMulti
        ? _localSelectedValues.contains(option.value)
        : _localSelectedValue == option.value;

    // Skip if doesn't match search query
    if (!_matchesSearch(option)) return const SizedBox.shrink();

    // Use custom builder if provided
    if (widget.optionBuilder != null) {
      return widget.optionBuilder!(
          context, option, isSelected, () => _handleOptionSelect(option.value));
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: AppColors.blue.withValues(alpha: 20),
        enabled: !option.disabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: option.disabled ? null : () => _handleOptionSelect(option.value),
        leading: widget.isMulti
            ? Checkbox(
                value: isSelected,
                onChanged: option.disabled
                    ? null
                    : (_) => _handleOptionSelect(option.value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.blue,
              )
            : Radio<T>(
                value: option.value,
                groupValue: _localSelectedValue,
                onChanged: option.disabled
                    ? null
                    : (_) => _handleOptionSelect(option.value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.blue,
              ),
        title: Text(
          option.label,
          style: TextStyle(
            color: option.disabled
                ? AppColors.neutral[400] ?? Colors.grey.shade400
                : AppColors.neutral[950] ?? Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Build a group with its options
  Widget _buildGroup(int groupIndex, SelectGroup<T> group) {
    // Check if any option in the group matches search
    final hasMatchingOptions = group.options.any(_matchesSearch);
    if (!hasMatchingOptions) return const SizedBox.shrink();

    final bool isExpanded = _expandedGroups[groupIndex] ?? true;
    final int selectedCount = _getSelectedCountInGroup(group);

    // Use custom group builder if provided
    if (widget.groupBuilder != null) {
      return widget.groupBuilder!(context, group, isExpanded,
          () => _toggleGroup(groupIndex), selectedCount);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            onTap: () => _toggleGroup(groupIndex),
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.isMulti && selectedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blue.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isMulti)
                  IconButton(
                    icon: const Icon(Icons.select_all, size: 20),
                    onPressed: () => _selectAllInGroup(groupIndex),
                    tooltip: 'Toggle all',
                    splashRadius: 20,
                  ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),

        // Animated options container
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Offstage(
                offstage: !isExpanded,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...group.options
                        .where(_matchesSearch)
                        .map((option) => _buildOptionItem(option))
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build empty state widget when no options match search
  Widget _buildEmptyState() {
    // Use custom empty state builder if provided
    if (widget.emptyStateBuilder != null) {
      return widget.emptyStateBuilder!(context, widget.config.noMatchesText);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.config.noMatchesText,
        style: TextStyle(
          color: AppColors.neutral[600] ?? Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate constrained width to align with the field above
    final Size parentSize =
        (context.findRenderObject() as RenderBox?)?.size ?? Size.zero;
    final double constrainedWidth =
        parentSize.width > 0 ? parentSize.width : 250;

    // Check if we have any matching options after search
    final bool hasMatchingOptions = (widget.options != null &&
            widget.options!.any(_matchesSearch)) ||
        (widget.groups != null &&
            widget.groups!.any((group) => group.options.any(_matchesSearch)));

    // Use border radius from config or default
    final borderRadius = widget.config.borderRadius ?? BorderRadius.circular(8);

    // Use box shadow from config or default
    final boxShadow = widget.config.boxShadow ??
        [
          BoxShadow(
            color:
                (AppColors.neutral[950] ?? Colors.black).withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ];

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(
          minWidth: widget.config.minWidth ?? 200,
          maxWidth: constrainedWidth,
          maxHeight: widget.config.maxHeight ?? 350,
        ),
        decoration: BoxDecoration(
          color: widget.config.backgroundColor ??
              AppColors.neutral[50] ??
              Colors.white,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field with dedicated focus handling
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintText: widget.config.searchPlaceholder,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.neutral[300] ?? Colors.grey.shade300,
                      ),
                    ),
                  ),
                  autocorrect: false,
                ),
              ),

            // Options list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flat options (if any)
                    if (widget.options != null)
                      ...widget.options!
                          .map((option) => _buildOptionItem(option)),

                    // Grouped options (if any)
                    if (widget.groups != null)
                      ...widget.groups!
                          .asMap()
                          .entries
                          .map((entry) => _buildGroup(entry.key, entry.value)),

                    // Empty state when no results match search
                    if (_searchQuery.isNotEmpty && !hasMatchingOptions)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),

            // Footer actions for multi-select
            if (widget.isMulti &&
                widget.config.showFooterActions &&
                widget.onConfirm != null &&
                widget.onCancel != null)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.neutral[200] ?? Colors.grey.shade200,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                      text: widget.config.cancelButtonLabel ?? 'Cancel',
                      variant: ButtonVariant.text,
                      onPressed: widget.onCancel,
                    ),
                    const SizedBox(width: 8),
                    Button(
                      text: widget.config.confirmButtonLabel ?? 'OK',
                      variant: ButtonVariant.primary,
                      onPressed: widget.onConfirm,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Model for a select option
class SelectOption<T> {
  final T value;
  final String label;
  final bool disabled;
  final IconData? icon;
  final Widget? leading;
  final String? description;

  const SelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.icon,
    this.leading,
    this.description,
  });
}

/// Model for a group of options
class SelectGroup<T> {
  final String title;
  final List<SelectOption<T>> options;
  final bool expanded;

  const SelectGroup({
    required this.title,
    required this.options,
    this.expanded = true,
  });
}

/// Trigger types for select field
enum SelectTriggerType {
  button,
  textField,
  chip,
}

/// A form input field that integrates SelectField with the form validation system
class FormSelectField<T> extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<dynamic>> rules;

  /// List of options to display
  final List<SelectOption<T>>? options;

  /// List of option groups to display
  final List<SelectGroup<T>>? groups;

  /// Whether to allow multiple selections
  final bool isMulti;

  /// Initial selected value(s)
  final T? initialValue;

  /// Initial selected values for multi-select
  final List<T>? initialValues;

  /// Label text shown above the input field
  final String? label;

  /// Whether this field is required (affects label display)
  final bool isRequired;

  /// Whether the field is disabled
  final bool disabled;

  /// Whether to show search field in the popover
  final bool searchable;

  /// Whether to show clear button
  final bool showClear;

  /// Trigger type (button, textField, chip)
  final SelectTriggerType triggerType;

  /// Custom builder for trigger
  final Widget Function(BuildContext, dynamic, VoidCallback)? triggerBuilder;

  /// Custom builder for option items
  final Widget Function(BuildContext, SelectOption<T>, bool, VoidCallback)?
      optionBuilder;

  /// Custom builder for group headers
  final Widget Function(
          BuildContext, SelectGroup<T>, bool, VoidCallback, int selectedCount)?
      groupBuilder;

  /// Custom builder for empty state
  final Widget Function(BuildContext, String)? emptyStateBuilder;

  /// Custom builder for the entire popover content
  final Widget Function(BuildContext, SelectPopoverProps<T>)? popoverBuilder;

  /// Configuration for the popover
  final SelectPopoverConfig popoverConfig;

  /// Styling for the trigger
  final SelectTriggerStyle? triggerStyle;

  /// Button styles when using button trigger
  final ButtonVariant? buttonVariant;
  final ButtonColors? buttonColors;
  final ButtonLayout? buttonLayout;

  /// Spacing between the field elements
  final double verticalSpacing;

  /// Placeholder text when no selection
  final String? placeholder;

  /// Helper text shown below the field
  final String? helperText;

  /// Called when the field content changes
  final void Function(dynamic)? onChanged;

  const FormSelectField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.options,
    this.groups,
    this.isMulti = false,
    this.initialValue,
    this.initialValues,
    this.label,
    this.isRequired = false,
    this.disabled = false,
    this.searchable = false,
    this.showClear = false,
    this.triggerType = SelectTriggerType.button,
    this.triggerBuilder,
    this.optionBuilder,
    this.groupBuilder,
    this.emptyStateBuilder,
    this.popoverBuilder,
    this.popoverConfig = const SelectPopoverConfig(),
    this.triggerStyle,
    this.buttonVariant,
    this.buttonColors,
    this.buttonLayout,
    this.verticalSpacing = 6.0,
    this.placeholder = 'Select an option',
    this.helperText,
    this.onChanged,
  })  : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        ),
        assert(
          !(isMulti && initialValue != null && initialValues != null),
          'Cannot provide both initialValue and initialValues for multi-select',
        );

  @override
  FormSelectFieldState<T> createState() => FormSelectFieldState<T>();
}

class FormSelectFieldState<T> extends State<FormSelectField<T>> {
  FieldController? _fieldController;
  dynamic _currentValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Determine initial value based on single/multi select mode
    final initialValue = widget.isMulti
        ? (widget.initialValues ?? (widget.initialValue as List<T>? ?? []))
        : widget.initialValue;

    // If we have a form controller and name, register the field
    if (widget.formController != null && widget.name != null) {
      _fieldController = widget.formController!.register<dynamic>(
        widget.name!,
        defaultValue: initialValue,
        rules: widget.rules,
      );

      _currentValue = _fieldController?.value ?? initialValue;

      // Listen for field state changes
      _fieldController!.stateNotifier.addListener(_onFieldStateChanged);
    } else {
      // Standalone mode
      _currentValue = initialValue;
    }
  }

  void _onFieldStateChanged() {
    if (_fieldController != null) {
      final currentFieldState = _fieldController!.state;

      setState(() {
        // Only update the value if it's different to prevent loops
        if (_currentValue != currentFieldState.value) {
          _currentValue = currentFieldState.value;
        }
        _errorText = currentFieldState.error;
      });
    }
  }

  @override
  void didUpdateWidget(FormSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If form controller or name changed, re-register the field
    if (widget.formController != oldWidget.formController ||
        widget.name != oldWidget.name) {
      if (_fieldController != null) {
        _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      }

      _disposeController();
      _initializeController();
    }

    // Update value if initialValue/initialValues changed and we're in uncontrolled mode
    if (widget.formController == null) {
      if (widget.isMulti) {
        if (widget.initialValues != oldWidget.initialValues ||
            widget.initialValue != oldWidget.initialValue) {
          _currentValue = widget.initialValues ??
              (widget.initialValue is List ? widget.initialValue : []);
        }
      } else if (widget.initialValue != oldWidget.initialValue) {
        _currentValue = widget.initialValue;
      }
    }

    // Handle switching between multi and single select
    if (widget.isMulti != oldWidget.isMulti && widget.formController == null) {
      if (widget.isMulti) {
        // Convert single value to list
        if (_currentValue != null && _currentValue is! List) {
          _currentValue = [_currentValue];
        } else {
          _currentValue ??= [];
        }
      } else {
        // Convert list to single value
        if (_currentValue is List && (_currentValue as List).isNotEmpty) {
          _currentValue = (_currentValue as List).first;
        } else {
          _currentValue = null;
        }
      }
    }
  }

  void _disposeController() {
    if (_fieldController != null) {
      _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      _fieldController = null;
    }
  }

  void _handleValueChanged(dynamic value) {
    // Update internal state if needed (uncontrolled mode)
    if (widget.formController == null) {
      setState(() {
        _currentValue = value;
      });
    }

    // If we have a field controller, update it
    if (_fieldController != null) {
      _fieldController!.setValue(value);
      _fieldController!.markAsTouched();
    }

    // Call the onChange callback if provided
    widget.onChanged?.call(value);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FieldState>(
      valueListenable:
          _fieldController?.stateNotifier ?? ValueNotifier(const FieldState()),
      builder: (context, fieldState, _) {
        // Determine current values based on form state or internal state
        final currentValue = widget.isMulti
            ? null // Use null for single-select mode in multi-select field
            : (fieldState.value ?? _currentValue as T?);

        List<T>? currentValues;
        if (widget.isMulti) {
          if (fieldState.value != null) {
            currentValues = (fieldState.value is List)
                ? List<T>.from(fieldState.value as List)
                : [];
          } else if (_currentValue != null) {
            currentValues = (_currentValue is List)
                ? List<T>.from(_currentValue as List)
                : [];
          } else {
            currentValues = [];
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              LabelText(
                widget.label!,
                isRequired: widget.isRequired,
              ),
              SizedBox(height: widget.verticalSpacing / 2),
            ],
            SelectField<T>(
              value: currentValue,
              values: currentValues,
              onChanged: widget.isMulti ? null : _handleValueChanged,
              onValuesChanged: widget.isMulti
                  ? (values) => _handleValueChanged(values)
                  : null,
              options: widget.options,
              groups: widget.groups,
              isMulti: widget.isMulti,
              placeholder: widget.placeholder,
              disabled: widget.disabled,
              searchable: widget.searchable,
              showClear: widget.showClear,
              triggerType: widget.triggerType,
              triggerBuilder: widget.triggerBuilder,
              optionBuilder: widget.optionBuilder,
              groupBuilder: widget.groupBuilder,
              emptyStateBuilder: widget.emptyStateBuilder,
              popoverBuilder: widget.popoverBuilder,
              popoverConfig: widget.popoverConfig,
              triggerStyle: widget.triggerStyle,
              buttonVariant: widget.buttonVariant,
              buttonColors: widget.buttonColors,
              buttonLayout: widget.buttonLayout,
              errorText: fieldState.error ?? _errorText,
              helperText: fieldState.error == null && _errorText == null
                  ? widget.helperText
                  : null,
            ),
          ],
        );
      },
    );
  }
}
