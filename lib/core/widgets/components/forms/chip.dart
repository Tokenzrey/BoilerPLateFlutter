import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';

/// Data class for individual chips
class ChipData {
  final String label;
  final dynamic value;
  final IconData? icon;
  final Widget? avatar;
  final bool deletable;
  final bool disabled;
  final ChipStyle? style;

  const ChipData({
    required this.label,
    required this.value,
    this.icon,
    this.avatar,
    this.deletable = false,
    this.disabled = false,
    this.style,
  });

  ChipData copyWith({
    String? label,
    dynamic value,
    IconData? icon,
    Widget? avatar,
    bool? deletable,
    bool? disabled,
    ChipStyle? style,
  }) {
    return ChipData(
      label: label ?? this.label,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      avatar: avatar ?? this.avatar,
      deletable: deletable ?? this.deletable,
      disabled: disabled ?? this.disabled,
      style: style ?? this.style,
    );
  }
}

/// Data class for chip groups
class ChipGroupData {
  final String title;
  final List<ChipData> chips;
  final bool expanded;

  const ChipGroupData({
    required this.title,
    required this.chips,
    this.expanded = true,
  });

  ChipGroupData copyWith({
    String? title,
    List<ChipData>? chips,
    bool? expanded,
  }) {
    return ChipGroupData(
      title: title ?? this.title,
      chips: chips ?? this.chips,
      expanded: expanded ?? this.expanded,
    );
  }
}

/// Styling class for chips with comprehensive customization options
class ChipStyle {
  /// Background color for the chip
  final Color? backgroundColor;

  /// Border color for the chip
  final Color? borderColor;

  /// Text color for the chip label
  final Color? textColor;

  /// Internal padding within the chip
  final EdgeInsets? padding;

  /// Shape of the chip (can be RoundedRectangleBorder, StadiumBorder, etc.)
  final ShapeBorder? shape;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Color for the icon
  final Color? iconColor;

  /// Border radius for the avatar
  final BorderRadius? avatarBorderRadius;

  /// Delete icon color
  final Color? deleteIconColor;

  /// Delete icon size
  final double? deleteIconSize;

  /// Border width
  final double? borderWidth;

  /// Elevation of chip
  final double? elevation;

  /// Shadow color
  final Color? shadowColor;

  /// Height constraint for the chip
  final double? height;

  /// Text scale factor for labels
  final double? textScaleFactor;

  const ChipStyle({
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.padding,
    this.shape,
    this.labelStyle,
    this.iconColor,
    this.avatarBorderRadius,
    this.deleteIconColor,
    this.deleteIconSize,
    this.borderWidth,
    this.elevation,
    this.shadowColor,
    this.height,
    this.textScaleFactor,
  });

  ChipStyle merge(ChipStyle? other) {
    if (other == null) return this;
    return ChipStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      textColor: other.textColor ?? textColor,
      padding: other.padding ?? padding,
      shape: other.shape ?? shape,
      labelStyle: other.labelStyle ?? labelStyle,
      iconColor: other.iconColor ?? iconColor,
      avatarBorderRadius: other.avatarBorderRadius ?? avatarBorderRadius,
      deleteIconColor: other.deleteIconColor ?? deleteIconColor,
      deleteIconSize: other.deleteIconSize ?? deleteIconSize,
      borderWidth: other.borderWidth ?? borderWidth,
      elevation: other.elevation ?? elevation,
      shadowColor: other.shadowColor ?? shadowColor,
      height: other.height ?? height,
      textScaleFactor: other.textScaleFactor ?? textScaleFactor,
    );
  }
}

/// A modular Flutter chip field component with support for single/multi select,
/// deletable, input (tag), grouping, and custom builder/style.
class ChipField extends StatefulWidget {
  /// List of chips to display
  final List<ChipData>? chips;

  /// Currently selected values
  final List<dynamic>? selectedValues;

  /// Callback when selection changes
  final Function(List<dynamic>)? onChanged;

  /// Whether to allow multiple selections
  final bool isMulti;

  /// Whether the input field is enabled for adding new chips
  final bool inputEnabled;

  /// Callback to get suggestions when typing in input field
  final Future<List<String>> Function(String)? suggestionCallback;

  /// Called when a suggestion is selected
  final Function(String)? onSuggestionSelected;

  /// Validator for input field
  final String? Function(String)? validator;

  /// Maximum number of chips allowed
  final int? maxChips;

  /// Custom builder for chip items
  final Widget Function(BuildContext, ChipData, bool selected,
      VoidCallback onTap, VoidCallback? onDelete)? chipBuilder;

  /// Style for normal chips
  final ChipStyle? chipStyle;

  /// Style for selected chips
  final ChipStyle? chipSelectedStyle;

  /// Style for added chips (from input field)
  final ChipStyle? addedChipStyle;

  /// Grouped chips data
  final List<ChipGroupData>? groupData;

  /// Custom builder for group headers
  final Widget Function(
          BuildContext, ChipGroupData, bool expanded, VoidCallback onToggle)?
      groupBuilder;

  /// Whether groups are collapsible
  final bool collapsibleGroup;

  /// Custom builder for input field
  final Widget Function(
          BuildContext, TextEditingController, Function(String) onSubmitted)?
      inputBuilder;

  /// Error text to display
  final String? errorText;

  /// Helper text to display
  final String? helperText;

  /// Spacing between chips and input field
  final double inputFieldSpacing;

  /// Spacing between chips in the wrap
  final double chipSpacing;

  /// Spacing between rows of chips
  final double chipRunSpacing;

  const ChipField({
    super.key,
    this.chips,
    this.selectedValues,
    this.onChanged,
    this.isMulti = false,
    this.inputEnabled = false,
    this.suggestionCallback,
    this.onSuggestionSelected,
    this.validator,
    this.maxChips,
    this.chipBuilder,
    this.chipStyle,
    this.chipSelectedStyle,
    this.addedChipStyle,
    this.groupData,
    this.groupBuilder,
    this.collapsibleGroup = false,
    this.inputBuilder,
    this.errorText,
    this.helperText,
    this.inputFieldSpacing = 12.0,
    this.chipSpacing = 8.0,
    this.chipRunSpacing = 8.0,
  }) : assert(
          onChanged != null || selectedValues == null,
          'If selectedValues is provided, onChanged must also be provided (controlled mode)',
        );

  @override
  State<ChipField> createState() => _ChipFieldState();
}

class _ChipFieldState extends State<ChipField> {
  // Internal state for selected values (used in uncontrolled mode)
  late List<dynamic> _selectedValues;

  // Controller for the input field
  late TextEditingController _inputController;

  // Track group expansion states
  final Map<String, bool> _groupExpansionState = {};

  // Suggestions for the input field
  List<String> _suggestions = [];

  // Loading state for suggestions
  bool _isLoading = false;

  // Error from input validation
  String? _inputError;

  // Debounce timer for input changes
  Timer? _debounceTimer;

  // Focus node for the input field
  final FocusNode _inputFocusNode = FocusNode();

  // Index of the currently focused suggestion
  int _focusedSuggestionIndex = -1;

  @override
  void initState() {
    super.initState();
    // Initialize with provided values or empty list
    _selectedValues = widget.selectedValues ?? [];
    _inputController = TextEditingController();
    _initGroupExpansionState();

    // Set up focus for suggestion navigation
    _inputFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_inputFocusNode.hasFocus) {
      _focusedSuggestionIndex = -1;
    }
  }

  @override
  void didUpdateWidget(ChipField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update internal state if external values changed
    if (widget.selectedValues != oldWidget.selectedValues &&
        widget.selectedValues != null) {
      _selectedValues = widget.selectedValues!;
    }

    // Update group expansion state if groups changed, preserving existing state where possible
    if (widget.groupData != oldWidget.groupData) {
      _updateGroupExpansionState();
    }
  }

  void _initGroupExpansionState() {
    if (widget.groupData != null) {
      for (final group in widget.groupData!) {
        _groupExpansionState[group.title] = group.expanded;
      }
    }
  }

  void _updateGroupExpansionState() {
    if (widget.groupData != null) {
      for (final group in widget.groupData!) {
        // Only set default if state doesn't already exist
        if (!_groupExpansionState.containsKey(group.title)) {
          _groupExpansionState[group.title] = group.expanded;
        }
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _debounceTimer?.cancel();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // Check if a value is already in the selected values
  bool _isValueSelected(dynamic value) {
    final effectiveSelectedValues = widget.selectedValues ?? _selectedValues;
    return effectiveSelectedValues.contains(value);
  }

  // Get effective selected values (controlled or uncontrolled)
  List<dynamic> get _effectiveSelectedValues {
    return widget.selectedValues ?? _selectedValues;
  }

  void _toggleSelection(ChipData chip) {
    if (chip.disabled) return;

    // Get current values
    final currentValues =
        List<dynamic>.from(widget.selectedValues ?? _selectedValues);

    // Toggle selection
    if (currentValues.contains(chip.value)) {
      currentValues.remove(chip.value);
    } else {
      if (widget.isMulti) {
        currentValues.add(chip.value);
      } else {
        currentValues.clear();
        currentValues.add(chip.value);
      }
    }

    // Update internal state in uncontrolled mode
    if (widget.selectedValues == null) {
      setState(() {
        _selectedValues = currentValues;
      });
    }

    // Notify parent in controlled mode
    if (widget.onChanged != null) {
      widget.onChanged!(currentValues);
    }
  }

  void _deleteChip(ChipData chip) {
    // Get current values
    final currentValues =
        List<dynamic>.from(widget.selectedValues ?? _selectedValues);

    // Remove the chip value
    if (currentValues.contains(chip.value)) {
      currentValues.remove(chip.value);

      // Update internal state in uncontrolled mode
      if (widget.selectedValues == null) {
        setState(() {
          _selectedValues = currentValues;
        });
      }

      // Notify parent in controlled mode
      if (widget.onChanged != null) {
        widget.onChanged!(currentValues);
      }
    }
  }

  void _toggleGroup(String groupTitle) {
    if (!widget.collapsibleGroup) return;

    setState(() {
      _groupExpansionState[groupTitle] =
          !(_groupExpansionState[groupTitle] ?? true);
    });
  }

  void _addChip(String value) {
    if (value.trim().isEmpty) return;

    // Clear any previous input error
    setState(() {
      _inputError = null;
    });

    // Get current values
    final currentValues =
        List<dynamic>.from(widget.selectedValues ?? _selectedValues);

    // Check if we've hit the max chips limit
    if (widget.maxChips != null && currentValues.length >= widget.maxChips!) {
      setState(() {
        _inputError = "Maximum ${widget.maxChips} chips allowed";
        // Clear input field for better UX
        _inputController.clear();
      });
      return;
    }

    // Check for duplicates
    final trimmedValue = value.trim();
    if (currentValues.contains(trimmedValue)) {
      setState(() {
        _inputError = "This value is already selected";
        // Clear input field for better UX
        _inputController.clear();
      });
      return;
    }

    // Validate input if validator provided
    if (widget.validator != null) {
      final error = widget.validator!(trimmedValue);
      if (error != null) {
        setState(() {
          _inputError = error;
          // Clear input field for better UX
          _inputController.clear();
        });
        return;
      }
    }

    // Create new chip data
    // Try to find matching existing chip to inherit properties
    ChipData? existingChip;
    if (widget.chips != null) {
      existingChip = widget.chips!.firstWhere(
        (chip) => chip.value == trimmedValue,
        orElse: () => ChipData(
          label: trimmedValue,
          value: trimmedValue,
          deletable: true,
          // Use the addedChipStyle if provided
          style: widget.addedChipStyle,
        ),
      );
    }

    final newChip = existingChip ??
        ChipData(
          label: trimmedValue,
          value: trimmedValue,
          deletable: true,
          // Use the addedChipStyle if provided
          style: widget.addedChipStyle,
        );

    // Add to selected values
    currentValues.add(newChip.value);

    // Update internal state in uncontrolled mode
    if (widget.selectedValues == null) {
      setState(() {
        _selectedValues = currentValues;
      });
    }

    // Notify parent in controlled mode
    if (widget.onChanged != null) {
      widget.onChanged!(currentValues);
    }

    // Clear input and suggestions
    _inputController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  void _onInputChanged(String value) async {
    // Clear any previous input error
    if (_inputError != null) {
      setState(() {
        _inputError = null;
      });
    }

    // Reset focused suggestion
    _focusedSuggestionIndex = -1;

    // If no suggestion callback, do nothing
    if (widget.suggestionCallback == null) return;

    // Debounce input changes
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (value.isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final results = await widget.suggestionCallback!(value);
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _inputController.clear();
    setState(() {
      _suggestions = [];
      _focusedSuggestionIndex = -1;
    });

    if (widget.onSuggestionSelected != null) {
      widget.onSuggestionSelected!(suggestion);
    } else {
      _addChip(suggestion);
    }
  }

  void _clearAll() {
    // Clear selection
    if (widget.selectedValues == null) {
      setState(() {
        _selectedValues = [];
      });
    }

    // Notify parent in controlled mode
    if (widget.onChanged != null) {
      widget.onChanged!([]);
    }
  }

  // Handle keyboard events for navigating suggestions
  void _handleKeyEvent(KeyEvent event) {
    if (_suggestions.isEmpty) return;

    // Only handle key down events
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _focusedSuggestionIndex =
            (_focusedSuggestionIndex + 1) % _suggestions.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _focusedSuggestionIndex = _focusedSuggestionIndex <= 0
            ? _suggestions.length - 1
            : _focusedSuggestionIndex - 1;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        _focusedSuggestionIndex >= 0 &&
        _focusedSuggestionIndex < _suggestions.length) {
      _onSuggestionSelected(_suggestions[_focusedSuggestionIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasInputError = _inputError != null && _inputError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.groupData != null) _buildGroupedChips() else _buildChips(),
        // Add spacing between chips and input field if both are present
        if (widget.inputEnabled &&
            (widget.chips != null ||
                (_effectiveSelectedValues.isNotEmpty && widget.inputEnabled)))
          SizedBox(height: widget.inputFieldSpacing),
        if (widget.inputEnabled) _buildInputField(),
        if (widget.helperText != null && !hasError && !hasInputError) ...[
          const SizedBox(height: 6),
          HelperText(widget.helperText!),
        ],
        // Show only one error at a time, prioritizing input error
        if (hasInputError) ...[
          const SizedBox(height: 6),
          ErrorMessage(errorText: _inputError!),
        ] else if (hasError) ...[
          const SizedBox(height: 6),
          ErrorMessage(errorText: widget.errorText!),
        ],
      ],
    );
  }

  Widget _buildChips() {
    // For inputEnabled mode, display chips based on selected values
    final effectiveChips =
        widget.inputEnabled ? _buildChipsFromValues() : widget.chips;

    if (effectiveChips == null || effectiveChips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: widget.chipSpacing,
      runSpacing: widget.chipRunSpacing,
      children: effectiveChips.map((chip) {
        final selected = _isValueSelected(chip.value);
        return _buildChip(chip, selected);
      }).toList(),
    );
  }

  // Build chips from selected values (for inputEnabled mode)
  List<ChipData> _buildChipsFromValues() {
    final effectiveSelectedValues = widget.selectedValues ?? _selectedValues;

    return effectiveSelectedValues.map((value) {
      // Try to find matching chip from props to inherit properties
      if (widget.chips != null) {
        final existingChip = widget.chips!.firstWhere(
          (chip) => chip.value == value,
          orElse: () => ChipData(
            label: value.toString(),
            value: value,
            deletable: true,
            style: widget.addedChipStyle,
          ),
        );

        // If found, make it deletable (user can remove selected chips)
        return existingChip.copyWith(
          deletable: true,
          // Apply addedChipStyle for user-generated chips
          style: widget.addedChipStyle ?? existingChip.style,
        );
      }

      // Default chip if no match found
      return ChipData(
        label: value.toString(),
        value: value,
        deletable: true,
        style: widget.addedChipStyle,
      );
    }).toList();
  }

  Widget _buildChip(ChipData chip, bool selected) {
    if (widget.chipBuilder != null) {
      return widget.chipBuilder!(
          context,
          chip,
          selected,
          () => _toggleSelection(chip),
          chip.deletable ? () => _deleteChip(chip) : null);
    }

    // Determine if this is an added chip (for inputEnabled mode)
    final bool isAddedChip = widget.inputEnabled &&
        _effectiveSelectedValues.contains(chip.value) &&
        (widget.chips == null ||
            !widget.chips!.any((c) => c.value == chip.value));

    // Style priority:
    // 1. Chip's own style
    // 2. Added chip style (if applicable)
    // 3. Selected/default style
    ChipStyle? chipSpecificStyle;
    if (isAddedChip) {
      chipSpecificStyle = widget.addedChipStyle;
    }

    // Merge styles in correct order
    final baseStyle = widget.chipStyle ?? const ChipStyle();
    final selectedStyle = widget.chipSelectedStyle ?? const ChipStyle();
    final chipStyle = chip.style ??
        chipSpecificStyle ??
        (selected ? selectedStyle : baseStyle);

    final resolvedStyle =
        baseStyle.merge(selected ? selectedStyle.merge(chipStyle) : chipStyle);

    return ChipWidget(
      label: chip.label,
      selected: selected,
      disabled: chip.disabled,
      deletable: chip.deletable,
      icon: chip.icon,
      avatar: chip.avatar,
      onTap: () => _toggleSelection(chip),
      onDelete: chip.deletable ? () => _deleteChip(chip) : null,
      style: resolvedStyle,
    );
  }

  Widget _buildGroupedChips() {
    if (widget.groupData == null || widget.groupData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.groupData!.length,
      itemBuilder: (context, index) {
        return _buildChipGroup(widget.groupData![index]);
      },
    );
  }

  Widget _buildChipGroup(ChipGroupData group) {
    if (widget.groupBuilder != null) {
      final isExpanded = _groupExpansionState[group.title] ?? group.expanded;
      return widget.groupBuilder!(
          context, group, isExpanded, () => _toggleGroup(group.title));
    }

    return _ChipGroup(
      title: group.title,
      expanded: _groupExpansionState[group.title] ?? group.expanded,
      collapsible: widget.collapsibleGroup,
      onToggle: () => _toggleGroup(group.title),
      chipBuilder: (chip) {
        final selected = _isValueSelected(chip.value);
        return _buildChip(chip, selected);
      },
      chips: group.chips,
      chipSpacing: widget.chipSpacing,
      chipRunSpacing: widget.chipRunSpacing,
    );
  }

  Widget _buildInputField() {
    if (widget.inputBuilder != null) {
      return widget.inputBuilder!(context, _inputController, _addChip);
    }

    return _ChipInputField(
      controller: _inputController,
      inputFocusNode: _inputFocusNode,
      onSubmitted: _addChip,
      onChanged: _onInputChanged,
      suggestions: _suggestions,
      isLoading: _isLoading,
      onSuggestionSelected: _onSuggestionSelected,
      focusedSuggestionIndex: _focusedSuggestionIndex,
      showClear: _effectiveSelectedValues.isNotEmpty,
      onClearAll: _clearAll,
      onKeyEvent: _handleKeyEvent,
    );
  }
}

/// Form-integrated Chip Field for use with FormController
class FormChipField extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<List<dynamic>>> rules;

  /// Initial selected values
  final List<dynamic>? initialSelectedValues;

  /// List of options to display as chips
  final List<ChipData>? chips;

  /// Whether to allow multiple selections
  final bool isMulti;

  /// Label text shown above the input field
  final String? label;

  /// Whether this field is required (affects label display)
  final bool isRequired;

  /// Whether the chip input field is enabled
  final bool inputEnabled;

  /// Spacing between the field elements
  final double verticalSpacing;

  /// Helper text shown below the field
  final String? helperText;

  /// Callback for suggestions when typing in input field
  final Future<List<String>> Function(String)? suggestionCallback;

  /// Called when a suggestion is selected
  final Function(String)? onSuggestionSelected;

  /// Validator for chip input
  final String? Function(String)? inputValidator;

  /// Maximum number of chips
  final int? maxChips;

  /// Custom chip builder
  final Widget Function(BuildContext, ChipData, bool selected,
      VoidCallback onTap, VoidCallback? onDelete)? chipBuilder;

  /// Style for unselected chips
  final ChipStyle? chipStyle;

  /// Style for selected chips
  final ChipStyle? chipSelectedStyle;

  /// Style for added chips (from input)
  final ChipStyle? addedChipStyle;

  /// Groups for chips
  final List<ChipGroupData>? groupData;

  /// Custom group builder
  final Widget Function(
          BuildContext, ChipGroupData, bool expanded, VoidCallback onToggle)?
      groupBuilder;

  /// Whether groups can be collapsed
  final bool collapsibleGroup;

  /// Custom input field builder
  final Widget Function(
          BuildContext, TextEditingController, Function(String) onSubmitted)?
      inputBuilder;

  /// Called when the field content changes
  final void Function(List<dynamic>)? onChanged;

  /// Spacing between chips and input field
  final double inputFieldSpacing;

  /// Spacing between chips in the wrap
  final double chipSpacing;

  /// Spacing between rows of chips
  final double chipRunSpacing;

  const FormChipField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.initialSelectedValues,
    this.chips,
    this.isMulti = false,
    this.label,
    this.isRequired = false,
    this.inputEnabled = false,
    this.verticalSpacing = 6.0,
    this.helperText,
    this.suggestionCallback,
    this.onSuggestionSelected,
    this.inputValidator,
    this.maxChips,
    this.chipBuilder,
    this.chipStyle,
    this.chipSelectedStyle,
    this.addedChipStyle,
    this.groupData,
    this.groupBuilder,
    this.collapsibleGroup = false,
    this.inputBuilder,
    this.onChanged,
    this.inputFieldSpacing = 12.0,
    this.chipSpacing = 6.0,
    this.chipRunSpacing = 6.0,
  }) : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        );

  @override
  FormChipFieldState createState() => FormChipFieldState();
}

class FormChipFieldState extends State<FormChipField> {
  FieldController<List<dynamic>>? _fieldController;
  List<dynamic>? _currentValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    debugPrint('FormChipField - initState: ${widget.name}');
    _initializeController();
  }

  void _initializeController() {
    debugPrint('FormChipField - _initializeController: ${widget.name}');
    // If we have a form controller and name, register the field
    if (widget.formController != null && widget.name != null) {
      debugPrint(
          'FormChipField - Registering with FormController: ${widget.name}');
      _fieldController = widget.formController!.register<List<dynamic>>(
        widget.name!,
        defaultValue: widget.initialSelectedValues ?? [],
        rules: widget.rules,
      );

      _currentValue = _fieldController?.value ?? [];
      debugPrint(
          'FormChipField - Initial value: ${_currentValue?.length} items');

      // Listen for field state changes
      _fieldController!.stateNotifier.addListener(_onFieldStateChanged);
      debugPrint('FormChipField - Added listener to field controller');
    } else {
      // Standalone mode
      _currentValue = widget.initialSelectedValues ?? [];
      debugPrint(
          'FormChipField - Standalone mode, initial value: ${_currentValue?.length} items');
    }
  }

  void _onFieldStateChanged() {
    debugPrint(
        'FormChipField - _onFieldStateChanged triggered: ${widget.name}');
    if (_fieldController != null) {
      final currentFieldState = _fieldController!.state;
      debugPrint(
          'FormChipField - Field state changed: ${currentFieldState.value?.length} items, error: ${currentFieldState.error}');

      setState(() {
        // Only update the value if it's different to prevent loops
        if (!_areListsEqual(
            _currentValue ?? [], currentFieldState.value ?? [])) {
          debugPrint(
              'FormChipField - Updating value from ${_currentValue?.length} to ${currentFieldState.value?.length} items');
          _currentValue = currentFieldState.value ?? [];
        } else {
          debugPrint('FormChipField - Values are equal, no update needed');
        }
        _errorText = currentFieldState.error;
      });
    }
  }

  // Helper to compare two lists
  bool _areListsEqual(List<dynamic> list1, List<dynamic> list2) {
    debugPrint(
        'FormChipField - Comparing lists: ${list1.length} vs ${list2.length}');
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(FormChipField oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('FormChipField - didUpdateWidget: ${widget.name}');

    // If form controller or name changed, re-register the field
    if (widget.formController != oldWidget.formController ||
        widget.name != oldWidget.name) {
      debugPrint('FormChipField - Controller or name changed, re-registering');
      if (_fieldController != null) {
        _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
        debugPrint('FormChipField - Removed listener from old controller');
      }

      _disposeController();
      _initializeController();
    }

    // Update value if initialSelectedValues changed and we're not in form controller mode
    if (widget.initialSelectedValues != oldWidget.initialSelectedValues &&
        widget.formController == null) {
      debugPrint(
          'FormChipField - Updating initialSelectedValues in standalone mode');
      _currentValue = widget.initialSelectedValues ?? [];
    }
  }

  void _disposeController() {
    debugPrint('FormChipField - _disposeController called: ${widget.name}');
    if (_fieldController != null) {
      _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      _fieldController = null;
      debugPrint('FormChipField - Field controller disposed');
    }
  }

  void _handleValueChanged(List<dynamic> value) {
    debugPrint(
        'FormChipField - _handleValueChanged: ${value.length} items - ${widget.name}');
    // Only update if the value actually changed
    if (!_areListsEqual(value, _currentValue ?? [])) {
      setState(() {
        _currentValue = value;
        debugPrint(
            'FormChipField - State updated with new value: ${value.length} items');
      });

      // If we have a field controller, update it
      if (_fieldController != null) {
        debugPrint('FormChipField - Updating field controller with new value');
        _fieldController!.setValue(value);
        _fieldController!.markAsTouched();
        debugPrint('FormChipField - Field marked as touched');
      }

      // Call the onChange callback if provided
      if (widget.onChanged != null) {
        debugPrint('FormChipField - Calling parent onChanged callback');
        widget.onChanged?.call(value);
      }
    } else {
      debugPrint('FormChipField - Value unchanged, skipping update');
    }
  }

  @override
  void dispose() {
    debugPrint('FormChipField - dispose: ${widget.name}');
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('FormChipField - build: ${widget.name}');
    return ValueListenableBuilder<FieldState<List<dynamic>>>(
      valueListenable: _fieldController?.stateNotifier ??
          ValueNotifier(const FieldState<List<dynamic>>()),
      builder: (context, fieldState, _) {
        debugPrint(
            'FormChipField - ValueListenableBuilder triggered: ${widget.name}');
        debugPrint(
            'FormChipField - fieldState value: ${fieldState.value?.length} items, error: ${fieldState.error}');

        // Use field controller value or current value as fallback
        final currentValues = fieldState.value ?? _currentValue ?? [];
        debugPrint(
            'FormChipField - currentValues: ${currentValues.length} items');

        // For inputEnabled mode, we create virtual chips based on selected values
        final currentChips = widget.inputEnabled
            ? _buildChipsFromValues(currentValues)
            : widget.chips;

        debugPrint(
            'FormChipField - Building ChipField with ${currentValues.length} selected values');
        debugPrint(
            'FormChipField - Number of chips: ${currentChips?.length ?? 0}');

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
            ChipField(
              chips: currentChips,
              selectedValues: currentValues,
              onChanged: _handleValueChanged,
              isMulti: widget.isMulti,
              inputEnabled: widget.inputEnabled,
              suggestionCallback: widget.suggestionCallback,
              onSuggestionSelected: widget.onSuggestionSelected,
              validator: widget.inputValidator,
              maxChips: widget.maxChips,
              chipBuilder: widget.chipBuilder,
              chipStyle: widget.chipStyle,
              chipSelectedStyle: widget.chipSelectedStyle,
              addedChipStyle: widget.addedChipStyle,
              groupData: widget.groupData,
              groupBuilder: widget.groupBuilder,
              collapsibleGroup: widget.collapsibleGroup,
              inputBuilder: widget.inputBuilder,
              errorText: fieldState.error ?? _errorText,
              helperText: widget.helperText,
              inputFieldSpacing: widget.inputFieldSpacing,
              chipSpacing: widget.chipSpacing,
              chipRunSpacing: widget.chipRunSpacing,
            ),
          ],
        );
      },
    );
  }

  // Build virtual chips from selected values (for inputEnabled mode)
  List<ChipData> _buildChipsFromValues(List<dynamic> values) {
    debugPrint(
        'FormChipField - _buildChipsFromValues: ${values.length} values');
    final result = values.map((value) {
      // Try to find matching chip from props to inherit properties
      if (widget.chips != null) {
        final existingChip = widget.chips!.firstWhere(
          (chip) => chip.value == value,
          orElse: () => ChipData(
            label: value.toString(),
            value: value,
            deletable: true,
            style: widget.addedChipStyle,
          ),
        );

        // Make sure it's deletable
        return existingChip.copyWith(
            deletable: true,
            style: widget.addedChipStyle ?? existingChip.style);
      }

      // Default chip if no match found
      return ChipData(
        label: value.toString(),
        value: value,
        deletable: true,
        style: widget.addedChipStyle,
      );
    }).toList();

    debugPrint('FormChipField - Created ${result.length} virtual chips');
    return result;
  }
}

/// Individual Chip Widget implementation
class ChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final bool deletable;
  final IconData? icon;
  final Widget? avatar;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final ChipStyle? style;

  const ChipWidget({
    super.key,
    required this.label,
    this.selected = false,
    this.disabled = false,
    this.deletable = false,
    this.icon,
    this.avatar,
    required this.onTap,
    this.onDelete,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Apply improved default styles with smaller size
    final backgroundColor = style?.backgroundColor ??
        (selected
            ? theme.colorScheme.primary.withValues(alpha: 38)
            : theme.colorScheme.surface);

    final borderColor = style?.borderColor ??
        (selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 128));

    final textColor = style?.textColor ??
        (selected ? theme.colorScheme.primary : theme.colorScheme.onSurface);

    final borderWidth = style?.borderWidth ?? 1.0;

    final height = style?.height;

    final elevation = style?.elevation ?? 0.0;

    final shadowColor = style?.shadowColor ?? Colors.black12;

    final deleteIconSize = style?.deleteIconSize ?? 16.0;

    final deleteIconColor = style?.deleteIconColor ?? textColor;

    final labelStyle = style?.labelStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontSize: 13.0, // Smaller default text size
        );

    final iconColor = style?.iconColor ?? textColor;

    // More compact default padding for smaller chips
    final padding = style?.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final shape = style?.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        );

    final opacity = disabled ? 0.5 : 1.0;

    // Apply optional text scale factor
    final textWidget = style?.textScaleFactor != null
        ? Transform(
            transform: Matrix4.identity()
              ..scale(style!.textScaleFactor!, 1.0, 1.0),
            alignment: Alignment.center,
            child: Text(
              label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : Text(
            label,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          );

    return Semantics(
      button: true,
      selected: selected,
      enabled: !disabled,
      label: "Chip: $label${selected ? ', selected' : ''}",
      onTap: disabled ? null : onTap,
      onDismiss: deletable && !disabled ? onDelete : null,
      child: Opacity(
        opacity: opacity,
        child: Material(
          elevation: elevation,
          shadowColor: shadowColor,
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: shape is RoundedRectangleBorder
                ? (shape.borderRadius as BorderRadius?)
                : null,
            child: Container(
              height: height,
              constraints:
                  height != null ? BoxConstraints(minHeight: height) : null,
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: shape,
              ),
              child: Padding(
                padding: padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (avatar != null) ...[
                      ClipRRect(
                        borderRadius: style?.avatarBorderRadius ??
                            BorderRadius.circular(12),
                        child: SizedBox(
                          width: 20, // Slightly smaller avatar
                          height: 20,
                          child: avatar!,
                        ),
                      ),
                      const SizedBox(width: 6), // Tighter spacing
                    ] else if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16, // Smaller icon
                        color: iconColor,
                      ),
                      const SizedBox(width: 4), // Tighter spacing
                    ],
                    Flexible(child: textWidget),
                    if (deletable && onDelete != null) ...[
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: disabled ? null : onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2, right: 2),
                          child: Icon(
                            Icons.close,
                            size: deleteIconSize,
                            color: deleteIconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip Group implementation
class _ChipGroup extends StatelessWidget {
  final String title;
  final bool expanded;
  final bool collapsible;
  final VoidCallback onToggle;
  final List<ChipData> chips;
  final Widget Function(ChipData chip) chipBuilder;
  final double chipSpacing;
  final double chipRunSpacing;

  const _ChipGroup({
    required this.title,
    required this.expanded,
    required this.collapsible,
    required this.onToggle,
    required this.chips,
    required this.chipBuilder,
    this.chipSpacing = 8.0,
    this.chipRunSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: collapsible,
          label:
              "$title group${collapsible ? ', tap to ${expanded ? 'collapse' : 'expand'}' : ''}",
          child: InkWell(
            onTap: collapsible ? onToggle : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (collapsible)
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurface,
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !expanded
              ? const SizedBox(height: 0)
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Wrap(
                    spacing: chipSpacing,
                    runSpacing: chipRunSpacing,
                    children: chips.map(chipBuilder).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Chip Input Field implementation with keyboard navigation
/// Fixed to avoid focus hierarchy issues
class _ChipInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode inputFocusNode;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final List<String> suggestions;
  final bool isLoading;
  final Function(String) onSuggestionSelected;
  final int focusedSuggestionIndex;
  final bool showClear;
  final VoidCallback onClearAll;
  final Function(KeyEvent)? onKeyEvent;

  const _ChipInputField({
    required this.controller,
    required this.inputFocusNode,
    required this.onSubmitted,
    required this.onChanged,
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionSelected,
    required this.focusedSuggestionIndex,
    required this.showClear,
    required this.onClearAll,
    this.onKeyEvent,
  });

  @override
  State<_ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<_ChipInputField> {
  // Create a separate focus node for keyboard listener to fix the error
  final _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set up keyboard event listener
    widget.inputFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // When input gets focus, focus the keyboard listener too
    if (widget.inputFocusNode.hasFocus && !_keyboardFocusNode.hasFocus) {
      _keyboardFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Focus(
                focusNode: _keyboardFocusNode,
                onKeyEvent: (_, event) {
                  widget.onKeyEvent?.call(event);
                  // Don't consume the event, pass it to the child TextField
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.inputFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a chip...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    suffixIcon: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: widget.onChanged,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onSubmitted(value);
                    }
                  },
                ),
              ),
            ),
            if (widget.showClear) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Clear all',
                child: IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: widget.onClearAll,
                ),
              ),
            ],
          ],
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.suggestions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: theme.dividerColor),
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                final bool isHighlighted =
                    index == widget.focusedSuggestionIndex;

                return Material(
                  color: isHighlighted
                      ? theme.colorScheme.primary.withValues(alpha: 10)
                      : null,
                  child: ListTile(
                    title: Text(suggestion),
                    dense: true,
                    onTap: () => widget.onSuggestionSelected(suggestion),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// Custom validation rules remain unchanged
/// Validates that a multi-select field has at least one value selected
class RequiredChipsRule extends ValidationRule<List<dynamic>> {
  final String message;

  RequiredChipsRule({this.message = 'Please select at least one option'});

  @override
  String? validate(List<dynamic>? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }
}

/// Validates that a multi-select field has a minimum number of selections
class MinChipsRule extends ValidationRule<List<dynamic>> {
  final int minCount;
  final String message;

  MinChipsRule(this.minCount, {String? message})
      : message = message ?? 'Please select at least $minCount options';

  @override
  String? validate(List<dynamic>? value, String fieldName) {
    if (value == null || value.length < minCount) {
      return message;
    }
    return null;
  }
}

/// Validates that a multi-select field has at most a maximum number of selections
class MaxChipsRule extends ValidationRule<List<dynamic>> {
  final int maxCount;
  final String message;

  MaxChipsRule(this.maxCount, {String? message})
      : message = message ?? 'Please select no more than $maxCount options';

  @override
  String? validate(List<dynamic>? value, String fieldName) {
    if (value != null && value.length > maxCount) {
      return message;
    }
    return null;
  }
}
