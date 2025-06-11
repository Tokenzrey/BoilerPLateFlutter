import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';

/// Represents an option for checkbox selection
class CheckboxOption<T> {
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
  final CheckboxStyle? style;

  /// Optional description text
  final String? description;

  /// Whether this option is indeterminate (only for tristate)
  final bool? isIndeterminate;

  const CheckboxOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.icon,
    this.leading,
    this.tooltip,
    this.style,
    this.description,
    this.isIndeterminate,
  });
}

/// Group of checkbox options with a title
class CheckboxGroup<T> {
  /// Title of the group
  final String title;

  /// List of options in this group
  final List<CheckboxOption<T>> options;

  /// Whether this group is initially expanded (when collapsible)
  final bool expanded;

  /// Whether to show a "Select All" option for this group
  final bool showSelectAll;

  /// Custom text for the "Select All" option
  final String? selectAllText;

  const CheckboxGroup({
    required this.title,
    required this.options,
    this.expanded = true,
    this.showSelectAll = false,
    this.selectAllText,
  });
}

/// Styling options for checkbox options
class CheckboxStyle {
  /// Color when checkbox is checked
  final Color? activeColor;

  /// Color for the check mark
  final Color? checkColor;

  /// Color for the hover state
  final Color? hoverColor;

  /// Color for focus state
  final Color? focusColor;

  /// Color for the border
  final Color? borderColor;

  /// Width of the border
  final double? borderWidth;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Text style for the description
  final TextStyle? descriptionStyle;

  /// Custom background color
  final Color? backgroundColor;

  /// Color when option is checked
  final Color? selectedBackgroundColor;

  /// Icon color
  final Color? iconColor;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Shape of the checkbox
  final OutlinedBorder? shape;

  /// Size of the checkbox
  final double? size;

  /// Whether to show a custom outline
  final bool? showOutline;

  /// Splash radius
  final double? splashRadius;

  const CheckboxStyle({
    this.activeColor,
    this.checkColor,
    this.hoverColor,
    this.focusColor,
    this.borderColor,
    this.borderWidth,
    this.labelStyle,
    this.descriptionStyle,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
    this.shape,
    this.size,
    this.showOutline,
    this.splashRadius,
  });

  /// Merge this style with another, with the other taking precedence
  CheckboxStyle merge(CheckboxStyle? other) {
    if (other == null) return this;
    return CheckboxStyle(
      activeColor: other.activeColor ?? activeColor,
      checkColor: other.checkColor ?? checkColor,
      hoverColor: other.hoverColor ?? hoverColor,
      focusColor: other.focusColor ?? focusColor,
      borderColor: other.borderColor ?? borderColor,
      borderWidth: other.borderWidth ?? borderWidth,
      labelStyle: other.labelStyle ?? labelStyle,
      descriptionStyle: other.descriptionStyle ?? descriptionStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      iconColor: other.iconColor ?? iconColor,
      padding: other.padding ?? padding,
      borderRadius: other.borderRadius ?? borderRadius,
      shape: other.shape ?? shape,
      size: other.size ?? size,
      showOutline: other.showOutline ?? showOutline,
      splashRadius: other.splashRadius ?? splashRadius,
    );
  }
}

/// Layout options for checkbox groups
enum CheckboxLayout {
  /// Options are displayed vertically
  vertical,

  /// Options are displayed horizontally with wrapping
  horizontal,

  /// Options are displayed in a grid
  grid,

  /// Options are displayed in a flow layout
  flow,
}

/// Available checkbox shapes
enum CheckboxShape {
  /// Standard square checkbox
  square,

  /// Rounded checkbox
  rounded,

  /// Circular checkbox
  circular,

  /// Custom shape (use with style.shape)
  custom
}

/// A customizable checkbox component for single items or groups
class CheckboxWidget<T> extends StatefulWidget {
  /// Field title
  final String? title;

  /// Label text beside the checkbox
  final String? label;

  /// Helper text shown below
  final String? helperText;

  /// Error text for validation errors
  final String? errorText;

  /// Whether this field is required
  final bool isRequired;

  /// Current value - can be bool for single, or List for multiple
  final dynamic value;

  /// Callback when value changes
  final ValueChanged<dynamic>? onChanged;

  /// Whether the checkbox is enabled
  final bool enabled;

  /// Cross axis alignment for layout
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Space between checkbox and label
  final double spacing;

  /// Style for the checkbox
  final CheckboxStyle? style;

  /// Whether to use tristate checkbox (null = indeterminate)
  final bool tristate;

  /// Shape of the checkbox
  final CheckboxShape shape;

  /// List of options for checkbox group
  final List<CheckboxOption<T>>? options;

  /// List of option groups for grouped checkboxes
  final List<CheckboxGroup<T>>? groups;

  /// Layout for multiple options
  final CheckboxLayout layout;

  /// Whether groups are collapsible
  final bool collapsibleGroups;

  /// Number of columns when using grid layout
  final int gridColumns;

  /// Custom builder for option items
  final Widget Function(
      BuildContext, CheckboxOption<T>, bool, ValueChanged<bool>)? optionBuilder;

  /// Custom builder for single checkbox
  final Widget Function(BuildContext, bool, ValueChanged<bool>)?
      checkboxBuilder;

  /// Custom builder for group headers
  final Widget Function(BuildContext, CheckboxGroup<T>, bool, VoidCallback)?
      groupHeaderBuilder;

  /// Whether to display a "Select All" option for groups
  final bool showSelectAll;

  /// Optional icon to show with label
  final IconData? icon;

  /// Description text to show below label
  final String? description;

  /// Density of the layout
  final VisualDensity? visualDensity;

  /// Tooltip text for the checkbox
  final String? tooltip;

  /// Whether to show a border around the checkbox container
  final bool showBorder;

  /// Color when checkbox is hovered
  final Color? hoverColor;

  /// Color when checkbox is focused
  final Color? focusColor;

  const CheckboxWidget({
    super.key,
    this.title,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.verticalSpacing = 8.0,
    this.spacing = 8.0,
    this.style,
    this.tristate = false,
    this.shape = CheckboxShape.square,
    this.options,
    this.groups,
    this.layout = CheckboxLayout.vertical,
    this.collapsibleGroups = false,
    this.gridColumns = 2,
    this.optionBuilder,
    this.checkboxBuilder,
    this.groupHeaderBuilder,
    this.showSelectAll = false,
    this.icon,
    this.description,
    this.visualDensity,
    this.tooltip,
    this.showBorder = false,
    this.hoverColor,
    this.focusColor,
  });

  @override
  State<CheckboxWidget<T>> createState() => _CheckboxWidgetState<T>();
}

class _CheckboxWidgetState<T> extends State<CheckboxWidget<T>> {
  // For expandable groups
  final Map<int, bool> _expandedGroups = {};
  // Focus and hover states
  final List<FocusNode> _focusNodes = [];
  final List<bool> _hoverStates = [];

  @override
  void initState() {
    super.initState();
    _initExpandedGroups();
    _initFocusNodes();
  }

  @override
  void didUpdateWidget(CheckboxWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update expanded groups if groups changed
    if (widget.groups != oldWidget.groups) {
      _initExpandedGroups();
    }

    // Update focus nodes if options changed
    if (widget.options != oldWidget.options ||
        widget.groups != oldWidget.groups) {
      _disposeFocusNodes();
      _initFocusNodes();
    }
  }

  void _initExpandedGroups() {
    if (widget.groups != null) {
      _expandedGroups.clear();
      for (int i = 0; i < widget.groups!.length; i++) {
        _expandedGroups[i] = widget.groups![i].expanded;
      }
    }
  }

  void _initFocusNodes() {
    _focusNodes.clear();
    _hoverStates.clear();

    // For single checkbox
    if (widget.options == null && widget.groups == null) {
      _focusNodes.add(FocusNode());
      _hoverStates.add(false);
      return;
    }

    // For options
    if (widget.options != null) {
      for (int i = 0; i < widget.options!.length; i++) {
        _focusNodes.add(FocusNode());
        _hoverStates.add(false);
      }
    }

    // For grouped options
    if (widget.groups != null) {
      for (final group in widget.groups!) {
        // Add one for select all if needed
        if (group.showSelectAll || widget.showSelectAll) {
          _focusNodes.add(FocusNode());
          _hoverStates.add(false);
        }

        for (int i = 0; i < group.options.length; i++) {
          _focusNodes.add(FocusNode());
          _hoverStates.add(false);
        }
      }
    }
  }

  void _disposeFocusNodes() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    _focusNodes.clear();
    _hoverStates.clear();
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Main content widget that will contain the checkbox(es)
    Widget content;

    // Single checkbox vs. group of checkboxes
    if (widget.options == null && widget.groups == null) {
      // Single checkbox
      content = _buildSingleCheckbox(theme);
    } else {
      // Multiple checkboxes (options or groups)
      content = _buildCheckboxGroup(theme);
    }

    // Add border if requested
    if (widget.showBorder) {
      final borderColor = hasError
          ? theme.colorScheme.error
          : widget.style?.borderColor ?? theme.dividerColor;

      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: widget.style?.borderRadius ?? BorderRadius.circular(8),
          color: widget.style?.backgroundColor,
        ),
        padding: widget.style?.padding ?? const EdgeInsets.all(12),
        child: content,
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      content = Tooltip(
        message: widget.tooltip!,
        child: content,
      );
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          LabelText(
            widget.title!,
            isRequired: widget.isRequired,
          ),
          SizedBox(height: widget.verticalSpacing),
        ],
        content,
        if (widget.helperText != null &&
            widget.helperText!.isNotEmpty &&
            !hasError) ...[
          SizedBox(height: widget.verticalSpacing),
          HelperText(widget.helperText!),
        ],
        if (hasError) ...[
          SizedBox(height: widget.verticalSpacing),
          ErrorMessage(errorText: widget.errorText!),
        ],
      ],
    );
  }

  Widget _buildSingleCheckbox(ThemeData theme) {
    if (widget.checkboxBuilder != null) {
      return widget.checkboxBuilder!(
          context, widget.value as bool, _handleSingleValueChanged);
    }

    final bool isChecked = widget.value == true;
    final effectiveStyle = widget.style ?? const CheckboxStyle();

    // Build checkbox with label
    return InkWell(
      onTap:
          widget.enabled ? () => _handleSingleValueChanged(!isChecked) : null,
      borderRadius: effectiveStyle.borderRadius ?? BorderRadius.circular(4),
      hoverColor: widget.hoverColor ?? effectiveStyle.hoverColor,
      focusColor: widget.focusColor ?? effectiveStyle.focusColor,
      child: Padding(
        padding: effectiveStyle.padding ?? EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCheckbox(
              isChecked: isChecked,
              tristate: widget.tristate,
              onChanged: widget.enabled ? _handleSingleValueChanged : null,
              style: effectiveStyle,
              theme: theme,
              focusNode: _focusNodes.isNotEmpty ? _focusNodes[0] : null,
              index: 0,
            ),
            SizedBox(width: widget.spacing),
            if (widget.label != null || widget.icon != null)
              Expanded(
                child: _buildCheckboxLabel(
                  label: widget.label,
                  icon: widget.icon,
                  description: widget.description,
                  isChecked: isChecked,
                  enabled: widget.enabled,
                  style: effectiveStyle,
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxGroup(ThemeData theme) {
    // If we have groups, build them
    if (widget.groups != null && widget.groups!.isNotEmpty) {
      return _buildGroupedOptions(theme);
    }

    // Otherwise build flat options
    switch (widget.layout) {
      case CheckboxLayout.vertical:
        return _buildVerticalOptions(theme);
      case CheckboxLayout.horizontal:
        return _buildHorizontalOptions(theme);
      case CheckboxLayout.grid:
        return _buildGridOptions(theme);
      case CheckboxLayout.flow:
        return _buildFlowOptions(theme);
    }
  }

  Widget _buildVerticalOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: _buildOptionWidgets(theme),
    );
  }

  Widget _buildHorizontalOptions(ThemeData theme) {
    return Wrap(
      spacing: widget.spacing * 2,
      runSpacing: widget.verticalSpacing,
      children: _buildOptionWidgets(theme),
    );
  }

  Widget _buildGridOptions(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumns,
        childAspectRatio: 4,
        crossAxisSpacing: widget.spacing,
        mainAxisSpacing: widget.verticalSpacing,
      ),
      itemCount: widget.options!.length,
      itemBuilder: (context, index) {
        final option = widget.options![index];
        final isChecked =
            (widget.value as List<T>?)?.contains(option.value) ?? false;
        return _buildCheckboxOption(
          option: option,
          isChecked: isChecked,
          theme: theme,
          index: index,
        );
      },
    );
  }

  Widget _buildFlowOptions(ThemeData theme) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: _buildOptionWidgets(theme),
    );
  }

  List<Widget> _buildOptionWidgets(ThemeData theme) {
    final List<Widget> widgets = [];

    // Add select all option if requested
    if (widget.showSelectAll && widget.options != null) {
      widgets.add(
        _buildSelectAllOption(
          theme,
          widget.options!,
          -1, // Special index for select all
        ),
      );
    }

    // Add regular options
    for (int i = 0; i < widget.options!.length; i++) {
      final option = widget.options![i];
      final isChecked =
          (widget.value as List<T>?)?.contains(option.value) ?? false;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i < widget.options!.length - 1 ? widget.verticalSpacing : 0,
          ),
          child: _buildCheckboxOption(
            option: option,
            isChecked: isChecked,
            theme: theme,
            index: i,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildGroupedOptions(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.groups!.length,
      itemBuilder: (context, groupIndex) {
        final group = widget.groups![groupIndex];
        return _buildOptionGroup(
          group: group,
          groupIndex: groupIndex,
          theme: theme,
        );
      },
    );
  }

  Widget _buildOptionGroup({
    required CheckboxGroup<T> group,
    required int groupIndex,
    required ThemeData theme,
  }) {
    final bool isExpanded = _expandedGroups[groupIndex] ?? true;

    // Use custom group header builder if provided
    if (widget.groupHeaderBuilder != null) {
      return widget.groupHeaderBuilder!(
          context, group, isExpanded, () => _toggleGroupExpansion(groupIndex));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header with title and expand/collapse control
        if (widget.collapsibleGroups)
          InkWell(
            onTap: () => _toggleGroupExpansion(groupIndex),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              group.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Group options with animation when collapsible
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: isExpanded ? null : 0,
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildGroupOptions(group, groupIndex, theme),
            ),
          ),
        ),

        SizedBox(height: groupIndex < widget.groups!.length - 1 ? 16 : 0),
      ],
    );
  }

  List<Widget> _buildGroupOptions(
      CheckboxGroup<T> group, int groupIndex, ThemeData theme) {
    final List<Widget> options = [];
    int optionIndexOffset = 0;

    // Add "Select All" for the group if requested
    if (group.showSelectAll || widget.showSelectAll) {
      options.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildSelectAllOption(
            theme,
            group.options,
            groupIndex,
          ),
        ),
      );
      optionIndexOffset = 1;
    }

    // Add all options for this group
    for (int i = 0; i < group.options.length; i++) {
      final option = group.options[i];
      final isChecked =
          (widget.value as List<T>?)?.contains(option.value) ?? false;

      options.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i < group.options.length - 1 ? 8 : 0,
          ),
          child: _buildCheckboxOption(
            option: option,
            isChecked: isChecked,
            theme: theme,
            // Calculate index based on groups
            index: _calculateFocusIndex(groupIndex, i, optionIndexOffset),
          ),
        ),
      );
    }

    return options;
  }

  int _calculateFocusIndex(int groupIndex, int optionIndex, int offset) {
    // For single checkbox
    if (_focusNodes.length == 1 &&
        widget.options == null &&
        widget.groups == null) {
      return 0;
    }

    // For flat options
    if (widget.options != null && widget.groups == null) {
      return optionIndex;
    }

    // For grouped options - more complex calculation
    int index = 0;

    // Add select all for main list if needed
    if (widget.options != null && widget.showSelectAll) {
      index++;
    }

    // Add all options from main list
    if (widget.options != null) {
      index += widget.options!.length;
    }

    // For groups before the current one
    for (int i = 0; i < groupIndex; i++) {
      // Add select all if needed
      if (widget.groups![i].showSelectAll || widget.showSelectAll) {
        index++;
      }
      // Add options from this group
      index += widget.groups![i].options.length;
    }

    // Add select all for current group if needed
    if (offset > 0) {
      index++;
    }

    // Add option index
    index += optionIndex;

    return index < _focusNodes.length ? index : 0;
  }

  Widget _buildSelectAllOption(
    ThemeData theme,
    List<CheckboxOption<T>> options,
    int groupIndex,
  ) {
    // Calculate if all enabled options are selected
    final enabledOptions = options.where((opt) => opt.enabled).toList();

    final selectedValues = widget.value as List<T>? ?? [];

    bool allSelected = enabledOptions.isNotEmpty &&
        enabledOptions.every((opt) => selectedValues.contains(opt.value));

    bool someSelected = enabledOptions.isNotEmpty &&
        enabledOptions.any((opt) => selectedValues.contains(opt.value)) &&
        !allSelected;

    // Determine text to use
    final String selectAllText = groupIndex >= 0 &&
            widget.groups != null &&
            groupIndex < widget.groups!.length &&
            widget.groups![groupIndex].selectAllText != null
        ? widget.groups![groupIndex].selectAllText!
        : 'Select All';

    // Create a faux option for the select all
    final selectAllOption = CheckboxOption<dynamic>(
      value: null,
      label: selectAllText,
      enabled: enabledOptions.isNotEmpty,
      style: CheckboxStyle(
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return InkWell(
      onTap: enabledOptions.isEmpty
          ? null
          : () => _handleSelectAll(enabledOptions, allSelected, groupIndex),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            _buildCheckbox(
              isChecked: allSelected,
              isIndeterminate: someSelected,
              tristate: true,
              onChanged: enabledOptions.isEmpty
                  ? null
                  : (bool value) =>
                      _handleSelectAll(enabledOptions, allSelected, groupIndex),
              style: const CheckboxStyle(),
              theme: theme,
              focusNode: _getFocusNode(groupIndex, -1),
              index: _calculateFocusIndex(groupIndex, -1, 0),
            ),
            SizedBox(width: widget.spacing),
            Expanded(
              child: _buildCheckboxLabel(
                label: selectAllText,
                isChecked: allSelected,
                enabled: enabledOptions.isNotEmpty,
                style: selectAllOption.style ?? const CheckboxStyle(),
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FocusNode? _getFocusNode(int groupIndex, int optionIndex) {
    final index = _calculateFocusIndex(groupIndex, optionIndex, 0);
    if (index >= 0 && index < _focusNodes.length) {
      return _focusNodes[index];
    }
    return null;
  }

  Widget _buildCheckboxOption({
    required CheckboxOption<T> option,
    required bool isChecked,
    required ThemeData theme,
    required int index,
  }) {
    // Use custom option builder if provided
    if (widget.optionBuilder != null) {
      return widget.optionBuilder!(context, option, isChecked,
          (newValue) => _handleOptionValueChanged(option, newValue));
    }

    final bool? isIndeterminate = option.isIndeterminate;
    final effectiveStyle = widget.style?.merge(option.style) ??
        option.style ??
        const CheckboxStyle();

    return InkWell(
      onTap: option.enabled && widget.enabled
          ? () => _handleOptionValueChanged(option, !isChecked)
          : null,
      borderRadius: effectiveStyle.borderRadius ?? BorderRadius.circular(4),
      hoverColor: widget.hoverColor ?? effectiveStyle.hoverColor,
      focusColor: widget.focusColor ?? effectiveStyle.focusColor,
      child: Padding(
        padding:
            effectiveStyle.padding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCheckbox(
              isChecked: isChecked,
              isIndeterminate: isIndeterminate,
              tristate: widget.tristate,
              onChanged: option.enabled && widget.enabled
                  ? (bool value) => _handleOptionValueChanged(option, value)
                  : null,
              style: effectiveStyle,
              theme: theme,
              focusNode: index < _focusNodes.length ? _focusNodes[index] : null,
              index: index,
            ),
            SizedBox(width: widget.spacing),
            Expanded(
              child: _buildCheckboxLabel(
                label: option.label,
                icon: option.icon,
                description: option.description,
                isChecked: isChecked,
                enabled: option.enabled && widget.enabled,
                style: effectiveStyle,
                theme: theme,
                leading: option.leading,
                tooltip: option.tooltip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool isChecked,
    bool? isIndeterminate,
    required bool tristate,
    required ValueChanged<bool>? onChanged,
    required CheckboxStyle style,
    required ThemeData theme,
    FocusNode? focusNode,
    required int index,
  }) {
    // Get effective values
    final effectiveActiveColor = style.activeColor ?? theme.colorScheme.primary;
    final effectiveCheckColor = style.checkColor ?? theme.colorScheme.onPrimary;
    final effectiveBorderColor = style.borderColor ?? theme.dividerColor;
    final effectiveSize = style.size ?? 20.0;
    final effectiveSplashRadius = style.splashRadius ?? 20.0;
    final effectiveShape = _getCheckboxShape(style);
    final effectiveVisualDensity = widget.visualDensity ?? theme.visualDensity;

    // Handle indeterminate state (tristate)
    bool? value = isChecked;
    if (tristate && isIndeterminate == true) {
      value = null;
    }

    // Wrap in MouseRegion to handle hover state
    return MouseRegion(
      onEnter: (_) {
        if (index >= 0 && index < _hoverStates.length) {
          setState(() {
            _hoverStates[index] = true;
          });
        }
      },
      onExit: (_) {
        if (index >= 0 && index < _hoverStates.length) {
          setState(() {
            _hoverStates[index] = false;
          });
        }
      },
      child: SizedBox(
        width: effectiveSize + 4, // Add a bit of padding
        height: effectiveSize + 4,
        child: Checkbox(
          value: value,
          tristate: tristate,
          onChanged:
              onChanged == null ? null : (bool? val) => onChanged(val ?? false),
          activeColor: effectiveActiveColor,
          checkColor: effectiveCheckColor,
          focusColor: style.focusColor,
          hoverColor: style.hoverColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: effectiveVisualDensity,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return effectiveActiveColor;
            }
            return Colors.transparent;
          }),
          side: BorderSide(
            color:
                onChanged == null ? theme.disabledColor : effectiveBorderColor,
            width: style.borderWidth ?? 1.5,
          ),
          shape: effectiveShape,
          splashRadius: effectiveSplashRadius,
          focusNode: focusNode,
          isError: widget.errorText != null && widget.errorText!.isNotEmpty,
        ),
      ),
    );
  }

  OutlinedBorder _getCheckboxShape(CheckboxStyle style) {
    // If custom shape is provided in style, use it
    if (style.shape != null) {
      return style.shape!;
    }

    // Otherwise use the specified shape type
    switch (widget.shape) {
      case CheckboxShape.square:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        );
      case CheckboxShape.rounded:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        );
      case CheckboxShape.circular:
        return const CircleBorder();
      case CheckboxShape.custom:
        // Fall back to default for custom without style.shape
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        );
    }
  }

  Widget _buildCheckboxLabel({
    String? label,
    IconData? icon,
    String? description,
    required bool isChecked,
    required bool enabled,
    required CheckboxStyle style,
    required ThemeData theme,
    Widget? leading,
    String? tooltip,
  }) {
    final TextStyle? effectiveLabelStyle = style.labelStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: enabled ? null : theme.disabledColor,
          fontWeight: isChecked ? FontWeight.w500 : null,
        );

    final TextStyle? effectiveDescStyle = style.descriptionStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: enabled
              ? theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8)
              : theme.disabledColor,
        );

    Widget labelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(width: widget.spacing),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: enabled
                    ? (isChecked
                        ? style.activeColor ?? theme.colorScheme.primary
                        : style.iconColor ?? theme.iconTheme.color)
                    : theme.disabledColor,
              ),
              SizedBox(width: widget.spacing),
            ],
            if (label != null)
              Expanded(
                child: Text(
                  label,
                  style: effectiveLabelStyle,
                ),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: effectiveDescStyle,
          ),
        ],
      ],
    );

    // Wrap with tooltip if provided
    if (tooltip != null) {
      labelContent = Tooltip(
        message: tooltip,
        child: labelContent,
      );
    }

    return labelContent;
  }

  void _handleSingleValueChanged(bool newValue) {
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
  }

  void _handleOptionValueChanged(CheckboxOption<T> option, bool isChecked) {
    if (widget.onChanged == null) return;

    final currentValues = List<T>.from(widget.value ?? []);

    if (isChecked) {
      if (!currentValues.contains(option.value)) {
        currentValues.add(option.value);
      }
    } else {
      currentValues.remove(option.value);
    }

    widget.onChanged!(currentValues);
  }

  void _handleSelectAll(List<CheckboxOption<T>> options,
      bool currentlyAllSelected, int groupIndex) {
    if (widget.onChanged == null) return;

    final currentValues = List<T>.from(widget.value ?? []);

    if (currentlyAllSelected) {
      // Deselect all options in this group
      for (final option in options) {
        currentValues.remove(option.value);
      }
    } else {
      // Select all options in this group
      for (final option in options) {
        if (!currentValues.contains(option.value)) {
          currentValues.add(option.value);
        }
      }
    }

    widget.onChanged!(currentValues);
  }

  void _toggleGroupExpansion(int groupIndex) {
    if (widget.collapsibleGroups) {
      setState(() {
        _expandedGroups[groupIndex] = !(_expandedGroups[groupIndex] ?? true);
      });
    }
  }
}

/// Form field that integrates CheckboxWidget with form validation system
class FormCheckboxField<T> extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<dynamic>> rules;

  /// Initial value - bool for single, List for multiple
  final dynamic initialValue;

  /// Field title
  final String? title;

  /// Label text beside the checkbox
  final String? label;

  /// Helper text shown below
  final String? helperText;

  /// Whether this field is required
  final bool isRequired;

  /// Whether the checkbox is enabled
  final bool enabled;

  /// Cross axis alignment for layout
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Space between checkbox and label
  final double spacing;

  /// Style for the checkbox
  final CheckboxStyle? style;

  /// Whether to use tristate checkbox (null = indeterminate)
  final bool tristate;

  /// Shape of the checkbox
  final CheckboxShape shape;

  /// List of options for checkbox group
  final List<CheckboxOption<T>>? options;

  /// List of option groups for grouped checkboxes
  final List<CheckboxGroup<T>>? groups;

  /// Layout for multiple options
  final CheckboxLayout layout;

  /// Whether groups are collapsible
  final bool collapsibleGroups;

  /// Number of columns when using grid layout
  final int gridColumns;

  /// Custom builder for option items
  final Widget Function(
      BuildContext, CheckboxOption<T>, bool, ValueChanged<bool>)? optionBuilder;

  /// Custom builder for single checkbox
  final Widget Function(BuildContext, bool, ValueChanged<bool>)?
      checkboxBuilder;

  /// Custom builder for group headers
  final Widget Function(BuildContext, CheckboxGroup<T>, bool, VoidCallback)?
      groupHeaderBuilder;

  /// Whether to display a "Select All" option for groups
  final bool showSelectAll;

  /// Optional icon to show with label
  final IconData? icon;

  /// Description text to show below label
  final String? description;

  /// Density of the layout
  final VisualDensity? visualDensity;

  /// Tooltip text for the checkbox
  final String? tooltip;

  /// Whether to show a border around the checkbox container
  final bool showBorder;

  /// Color when checkbox is hovered
  final Color? hoverColor;

  /// Color when checkbox is focused
  final Color? focusColor;

  /// Called when the field content changes
  final void Function(dynamic)? onChanged;

  /// Whether this is a single or multi select field
  final bool isMulti;

  const FormCheckboxField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.initialValue,
    this.title,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.enabled = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.verticalSpacing = 8.0,
    this.spacing = 8.0,
    this.style,
    this.tristate = false,
    this.shape = CheckboxShape.square,
    this.options,
    this.groups,
    this.layout = CheckboxLayout.vertical,
    this.collapsibleGroups = false,
    this.gridColumns = 2,
    this.optionBuilder,
    this.checkboxBuilder,
    this.groupHeaderBuilder,
    this.showSelectAll = false,
    this.icon,
    this.description,
    this.visualDensity,
    this.tooltip,
    this.showBorder = false,
    this.hoverColor,
    this.focusColor,
    this.onChanged,
    this.isMulti = false,
  }) : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        );

  @override
  FormCheckboxFieldState<T> createState() => FormCheckboxFieldState<T>();
}

class FormCheckboxFieldState<T> extends State<FormCheckboxField<T>> {
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
        defaultValue: widget.initialValue ?? (widget.isMulti ? <T>[] : false),
        rules: widget.rules,
      );

      _currentValue = _fieldController?.value ??
          (widget.initialValue ?? (widget.isMulti ? <T>[] : false));

      // Listen for field state changes
      _fieldController!.stateNotifier.addListener(_onFieldStateChanged);
    } else {
      // Standalone mode
      _currentValue = widget.initialValue ?? (widget.isMulti ? <T>[] : false);
    }
  }

  void _onFieldStateChanged() {
    if (_fieldController != null) {
      final currentFieldState = _fieldController!.state;

      setState(() {
        // Only update the value if it's different to prevent loops
        if (_currentValue != currentFieldState.value) {
          _currentValue =
              currentFieldState.value ?? (widget.isMulti ? <T>[] : false);
        }
        _errorText = currentFieldState.error;
      });
    }
  }

  @override
  void didUpdateWidget(FormCheckboxField<T> oldWidget) {
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
      _currentValue = widget.initialValue ?? (widget.isMulti ? <T>[] : false);
    }

    // Handle change between single and multi
    if (widget.isMulti != oldWidget.isMulti && _fieldController != null) {
      _fieldController!.setValue(widget.isMulti ? <T>[] : false);
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
        return CheckboxWidget<T>(
          title: widget.title,
          label: widget.label,
          helperText: widget.helperText,
          errorText: fieldState.error ?? _errorText,
          isRequired: widget.isRequired,
          value: fieldState.value ?? _currentValue,
          onChanged: widget.enabled ? _handleValueChanged : null,
          enabled: widget.enabled,
          crossAxisAlignment: widget.crossAxisAlignment,
          verticalSpacing: widget.verticalSpacing,
          spacing: widget.spacing,
          style: widget.style,
          tristate: widget.tristate,
          shape: widget.shape,
          options: widget.options,
          groups: widget.groups,
          layout: widget.layout,
          collapsibleGroups: widget.collapsibleGroups,
          gridColumns: widget.gridColumns,
          optionBuilder: widget.optionBuilder,
          checkboxBuilder: widget.checkboxBuilder,
          groupHeaderBuilder: widget.groupHeaderBuilder,
          showSelectAll: widget.showSelectAll,
          icon: widget.icon,
          description: widget.description,
          visualDensity: widget.visualDensity,
          tooltip: widget.tooltip,
          showBorder: widget.showBorder,
          hoverColor: widget.hoverColor,
          focusColor: widget.focusColor,
        );
      },
    );
  }
}
