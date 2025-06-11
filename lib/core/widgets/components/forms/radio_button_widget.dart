import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';

/// Represents an option for radio/checkbox selection
class RadioOption<T> {
  /// The value of this option
  final T value;

  /// The display label
  final String label;

  /// Whether this option is enabled
  final bool enabled;

  /// Optional icon to display with the option
  final IconData? icon;

  /// Optional custom widget to display alongside the option
  final Widget? leading;

  /// Optional tooltip text
  final String? tooltip;

  /// Custom style for this specific option
  final RadioOptionStyle? style;

  const RadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.icon,
    this.leading,
    this.tooltip,
    this.style,
  });
}

/// Group of radio options with a title
class RadioOptionGroup<T> {
  /// Title of the group
  final String title;

  /// List of options in this group
  final List<RadioOption<T>> options;

  /// Whether this group is initially expanded (when collapsible)
  final bool expanded;

  const RadioOptionGroup({
    required this.title,
    required this.options,
    this.expanded = true,
  });
}

/// Styling options for radio/checkbox options
class RadioOptionStyle {
  /// Color for the selected state
  final Color? activeColor;

  /// Color for the hover state
  final Color? hoverColor;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Custom background color
  final Color? backgroundColor;

  /// Color when option is selected
  final Color? selectedBackgroundColor;

  /// Border color
  final Color? borderColor;

  /// Icon color
  final Color? iconColor;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Custom border radius
  final BorderRadius? borderRadius;

  const RadioOptionStyle({
    this.activeColor,
    this.hoverColor,
    this.labelStyle,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.borderColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
  });

  /// Merge this style with another, with the other taking precedence
  RadioOptionStyle merge(RadioOptionStyle? other) {
    if (other == null) return this;
    return RadioOptionStyle(
      activeColor: other.activeColor ?? activeColor,
      hoverColor: other.hoverColor ?? hoverColor,
      labelStyle: other.labelStyle ?? labelStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      borderColor: other.borderColor ?? borderColor,
      iconColor: other.iconColor ?? iconColor,
      padding: other.padding ?? padding,
      borderRadius: other.borderRadius ?? borderRadius,
    );
  }
}

/// Layout options for radio/checkbox groups
enum RadioLayout {
  /// Options are displayed vertically
  vertical,

  /// Options are displayed horizontally with wrapping
  horizontal,

  /// Options are displayed in a grid
  grid,
}

/// Selection mode for the field
enum RadioSelectionMode {
  /// Single selection (radio buttons)
  single,

  /// Multiple selection (checkboxes)
  multiple
}

/// A customizable radio/checkbox field component
class RadioButtonWidget<T> extends StatelessWidget {
  /// Field label
  final String? label;

  /// Helper text shown below the field
  final String? helperText;

  /// Error text shown when validation fails
  final String? errorText;

  /// Whether this field is required
  final bool isRequired;

  /// List of available options
  final List<RadioOption<T>>? options;

  /// Grouped options with collapsible sections
  final List<RadioOptionGroup<T>>? groups;

  /// Currently selected value(s)
  final dynamic value;

  /// Callback when selection changes
  final ValueChanged<dynamic>? onChanged;

  /// Layout arrangement of options
  final RadioLayout layout;

  /// Selection mode (single or multiple)
  final RadioSelectionMode selectionMode;

  /// Whether groups are collapsible
  final bool collapsibleGroups;

  /// Alignment of content
  final CrossAxisAlignment crossAxisAlignment;

  /// Spacing between options
  final double spacing;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Style for option labels
  final TextStyle? optionLabelStyle;

  /// Active color for selected options
  final Color? activeColor;

  /// Default option style
  final RadioOptionStyle? optionStyle;

  /// Style for selected options
  final RadioOptionStyle? selectedOptionStyle;

  /// Number of columns when using grid layout
  final int gridColumns;

  /// Custom builder for option items
  final Widget Function(BuildContext, RadioOption<T>, bool, VoidCallback)?
      optionBuilder;

  /// Custom builder for group headers
  final Widget Function(BuildContext, RadioOptionGroup<T>, bool, VoidCallback)?
      groupHeaderBuilder;

  const RadioButtonWidget({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.options,
    this.groups,
    required this.value,
    this.onChanged,
    this.layout = RadioLayout.vertical,
    this.selectionMode = RadioSelectionMode.single,
    this.collapsibleGroups = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 12.0,
    this.verticalSpacing = 8.0,
    this.optionLabelStyle,
    this.activeColor,
    this.optionStyle,
    this.selectedOptionStyle,
    this.gridColumns = 2,
    this.optionBuilder,
    this.groupHeaderBuilder,
  }) : assert(options != null || groups != null,
            'Either options or groups must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final effectiveLabelStyle = optionLabelStyle ?? theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          LabelText(
            label!,
            isRequired: isRequired,
          ),
          SizedBox(height: verticalSpacing),
        ],
        _buildOptionsLayout(context, theme, effectiveLabelStyle),
        if (helperText != null && helperText!.isNotEmpty && !hasError) ...[
          SizedBox(height: verticalSpacing),
          HelperText(helperText!),
        ],
        if (hasError) ...[
          SizedBox(height: verticalSpacing),
          ErrorMessage(errorText: errorText!),
        ],
      ],
    );
  }

  Widget _buildOptionsLayout(
      BuildContext context, ThemeData theme, TextStyle? labelStyle) {
    // If we have groups, build them
    if (groups != null && groups!.isNotEmpty) {
      return _buildGroupedOptions(context, theme, labelStyle);
    }

    // Otherwise build the flat options list
    switch (layout) {
      case RadioLayout.vertical:
        return _buildVerticalOptions(context, theme, labelStyle);
      case RadioLayout.horizontal:
        return _buildHorizontalOptions(context, theme, labelStyle);
      case RadioLayout.grid:
        return _buildGridOptions(context, theme, labelStyle);
    }
  }

  Widget _buildVerticalOptions(
      BuildContext context, ThemeData theme, TextStyle? labelStyle) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: options!.map((option) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: option != options!.last ? spacing : 0),
          child: _buildOption(context, option, theme, labelStyle),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalOptions(
      BuildContext context, ThemeData theme, TextStyle? labelStyle) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: options!.map((option) {
        return _buildOption(context, option, theme, labelStyle);
      }).toList(),
    );
  }

  Widget _buildGridOptions(
      BuildContext context, ThemeData theme, TextStyle? labelStyle) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        childAspectRatio: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: options!.length,
      itemBuilder: (context, index) {
        return _buildOption(context, options![index], theme, labelStyle);
      },
    );
  }

  Widget _buildGroupedOptions(
      BuildContext context, ThemeData theme, TextStyle? labelStyle) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups!.length,
      itemBuilder: (context, groupIndex) {
        final group = groups![groupIndex];
        return _buildOptionGroup(context, group, groupIndex, theme, labelStyle);
      },
    );
  }

  Widget _buildOptionGroup(BuildContext context, RadioOptionGroup<T> group,
      int groupIndex, ThemeData theme, TextStyle? labelStyle) {
    // Use custom group header builder if provided
    if (groupHeaderBuilder != null) {
      return groupHeaderBuilder!(
        context,
        group,
        group.expanded,
        () {}, // Toggle callback would be implemented here in stateful version
      );
    }

    // Default group implementation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: verticalSpacing),
          child: Text(
            group.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: group.options.map((option) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: option != group.options.last ? spacing : 0),
                child: _buildOption(context, option, theme, labelStyle),
              );
            }).toList(),
          ),
        ),
        SizedBox(
            height: groupIndex < groups!.length - 1 ? verticalSpacing * 2 : 0),
      ],
    );
  }

  Widget _buildOption(BuildContext context, RadioOption<T> option,
      ThemeData theme, TextStyle? labelStyle) {
    // Check if this option is selected
    bool isSelected = false;
    if (selectionMode == RadioSelectionMode.single) {
      isSelected = value == option.value;
    } else {
      isSelected = (value as List?)?.contains(option.value) ?? false;
    }

    // Use custom option builder if provided
    if (optionBuilder != null) {
      return optionBuilder!(
        context,
        option,
        isSelected,
        () => _handleOptionTap(option),
      );
    }

    // Apply styles
    final baseStyle = optionStyle ?? const RadioOptionStyle();
    final selectedStyle = selectedOptionStyle ?? const RadioOptionStyle();
    final optionCustomStyle = option.style ?? const RadioOptionStyle();

    final mergedStyle = baseStyle.merge(
      isSelected ? selectedStyle.merge(optionCustomStyle) : optionCustomStyle,
    );

    final effectiveActiveColor =
        mergedStyle.activeColor ?? activeColor ?? theme.colorScheme.primary;

    final effectiveLabelStyle =
        (mergedStyle.labelStyle ?? labelStyle)?.copyWith(
      color: option.enabled
          ? (isSelected ? effectiveActiveColor : null)
          : theme.disabledColor,
    );

    final effectiveBackgroundColor = isSelected
        ? mergedStyle.selectedBackgroundColor
        : mergedStyle.backgroundColor;

    final effectivePadding = mergedStyle.padding ??
        EdgeInsets.symmetric(
            vertical: 4,
            horizontal: selectionMode == RadioSelectionMode.multiple ? 8 : 0);

    final effectiveBorderRadius =
        mergedStyle.borderRadius ?? BorderRadius.circular(8);

    // Build the option widget
    Widget optionWidget = InkWell(
      onTap: option.enabled ? () => _handleOptionTap(option) : null,
      borderRadius: effectiveBorderRadius,
      hoverColor: mergedStyle.hoverColor,
      child: Container(
        padding: effectivePadding,
        decoration: effectiveBackgroundColor != null
            ? BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: effectiveBorderRadius,
                border: mergedStyle.borderColor != null
                    ? Border.all(color: mergedStyle.borderColor!)
                    : null,
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selectionMode == RadioSelectionMode.single)
              Radio<T>(
                value: option.value,
                groupValue: value,
                onChanged: option.enabled
                    ? (newValue) => _handleOptionTap(option)
                    : null,
                activeColor: effectiveActiveColor,
              )
            else
              Checkbox(
                value: isSelected,
                onChanged:
                    option.enabled ? (value) => _handleOptionTap(option) : null,
                activeColor: effectiveActiveColor,
              ),
            if (option.leading != null) ...[
              option.leading!,
              const SizedBox(width: 8),
            ] else if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 18,
                color:
                    isSelected ? effectiveActiveColor : mergedStyle.iconColor,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                option.label,
                style: effectiveLabelStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with tooltip if provided
    if (option.tooltip != null) {
      optionWidget = Tooltip(
        message: option.tooltip!,
        child: optionWidget,
      );
    }

    return optionWidget;
  }

  void _handleOptionTap(RadioOption<T> option) {
    if (onChanged == null) return;

    if (selectionMode == RadioSelectionMode.single) {
      onChanged!(option.value);
    } else {
      // Handle multi-selection mode
      final selectedValues = List<T>.from(value ?? []);

      if (selectedValues.contains(option.value)) {
        selectedValues.remove(option.value);
      } else {
        selectedValues.add(option.value);
      }

      onChanged!(selectedValues);
    }
  }
}

/// A form input field that integrates RadioButtonWidget with the form validation system
class FormRadioField<T> extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<dynamic>> rules;

  /// Initial selected value(s)
  final dynamic initialValue;

  /// List of available options
  final List<RadioOption<T>>? options;

  /// Grouped options with collapsible sections
  final List<RadioOptionGroup<T>>? groups;

  /// Field label
  final String? label;

  /// Helper text shown below the field
  final String? helperText;

  /// Whether this field is required
  final bool isRequired;

  /// Selection mode (single or multiple)
  final RadioSelectionMode selectionMode;

  /// Layout arrangement of options
  final RadioLayout layout;

  /// Whether groups are collapsible
  final bool collapsibleGroups;

  /// Alignment of content
  final CrossAxisAlignment crossAxisAlignment;

  /// Spacing between options
  final double spacing;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Style for option labels
  final TextStyle? optionLabelStyle;

  /// Active color for selected options
  final Color? activeColor;

  /// Default option style
  final RadioOptionStyle? optionStyle;

  /// Style for selected options
  final RadioOptionStyle? selectedOptionStyle;

  /// Number of columns when using grid layout
  final int gridColumns;

  /// Custom builder for option items
  final Widget Function(BuildContext, RadioOption<T>, bool, VoidCallback)?
      optionBuilder;

  /// Custom builder for group headers
  final Widget Function(BuildContext, RadioOptionGroup<T>, bool, VoidCallback)?
      groupHeaderBuilder;

  /// Called when the field content changes
  final void Function(dynamic)? onChanged;

  const FormRadioField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.initialValue,
    this.options,
    this.groups,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.selectionMode = RadioSelectionMode.single,
    this.layout = RadioLayout.vertical,
    this.collapsibleGroups = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 12.0,
    this.verticalSpacing = 8.0,
    this.optionLabelStyle,
    this.activeColor,
    this.optionStyle,
    this.selectedOptionStyle,
    this.gridColumns = 2,
    this.optionBuilder,
    this.groupHeaderBuilder,
    this.onChanged,
  }) : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        );

  @override
  FormRadioFieldState<T> createState() => FormRadioFieldState<T>();
}

class FormRadioFieldState<T> extends State<FormRadioField<T>> {
  FieldController? _fieldController;
  dynamic _currentValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // If we have a form controller and name, register the field
    if (widget.formController != null && widget.name != null) {
      _fieldController = widget.formController!.register<dynamic>(
        widget.name!,
        defaultValue: widget.initialValue,
        rules: widget.rules,
      );

      _currentValue = _fieldController?.value ?? widget.initialValue;

      // Listen for field state changes
      _fieldController!.stateNotifier.addListener(_onFieldStateChanged);
    } else {
      // Standalone mode
      _currentValue = widget.initialValue;
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
  void didUpdateWidget(FormRadioField<T> oldWidget) {
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

    // Update value if initialValue changed and we're not in form controller mode
    if (widget.initialValue != oldWidget.initialValue &&
        widget.formController == null) {
      _currentValue = widget.initialValue;
    }
  }

  void _disposeController() {
    if (_fieldController != null) {
      _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      _fieldController = null;
    }
  }

  void _handleValueChanged(dynamic value) {
    setState(() {
      _currentValue = value;
    });

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
        return RadioButtonWidget<T>(
          label: widget.label,
          isRequired: widget.isRequired,
          helperText: widget.helperText,
          errorText: fieldState.error ?? _errorText,
          options: widget.options,
          groups: widget.groups,
          value: fieldState.value ?? _currentValue,
          onChanged: _handleValueChanged,
          selectionMode: widget.selectionMode,
          layout: widget.layout,
          collapsibleGroups: widget.collapsibleGroups,
          crossAxisAlignment: widget.crossAxisAlignment,
          spacing: widget.spacing,
          verticalSpacing: widget.verticalSpacing,
          optionLabelStyle: widget.optionLabelStyle,
          activeColor: widget.activeColor,
          optionStyle: widget.optionStyle,
          selectedOptionStyle: widget.selectedOptionStyle,
          gridColumns: widget.gridColumns,
          optionBuilder: widget.optionBuilder,
          groupHeaderBuilder: widget.groupHeaderBuilder,
        );
      },
    );
  }
}
