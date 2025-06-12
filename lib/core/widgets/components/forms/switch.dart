import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';

/// Styling options for switch input
class SwitchStyle {
  /// Color when switch is active
  final Color? activeColor;

  /// Color of the track when active
  final Color? activeTrackColor;

  /// Color of the track when inactive
  final Color? inactiveTrackColor;

  /// Color of the thumb when active
  final Color? activeThumbColor;

  /// Color of the thumb when inactive
  final Color? inactiveThumbColor;

  /// Focus color when switch is focused
  final Color? focusColor;

  /// Hover color when hovering over switch
  final Color? hoverColor;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Background color
  final Color? backgroundColor;

  /// Border color
  final Color? borderColor;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Padding around the switch
  final EdgeInsetsGeometry? padding;

  /// Width of the track
  final double? trackWidth;

  /// Height of the track
  final double? trackHeight;

  /// Size of the thumb
  final double? thumbSize;

  /// Scale factor for the switch
  final double? scale;

  const SwitchStyle({
    this.activeColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.focusColor,
    this.hoverColor,
    this.labelStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.trackWidth,
    this.trackHeight,
    this.thumbSize,
    this.scale,
  });

  /// Merge this style with another, with the other taking precedence
  SwitchStyle merge(SwitchStyle? other) {
    if (other == null) return this;
    return SwitchStyle(
      activeColor: other.activeColor ?? activeColor,
      activeTrackColor: other.activeTrackColor ?? activeTrackColor,
      inactiveTrackColor: other.inactiveTrackColor ?? inactiveTrackColor,
      activeThumbColor: other.activeThumbColor ?? activeThumbColor,
      inactiveThumbColor: other.inactiveThumbColor ?? inactiveThumbColor,
      focusColor: other.focusColor ?? focusColor,
      hoverColor: other.hoverColor ?? hoverColor,
      labelStyle: other.labelStyle ?? labelStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      borderRadius: other.borderRadius ?? borderRadius,
      padding: other.padding ?? padding,
      trackWidth: other.trackWidth ?? trackWidth,
      trackHeight: other.trackHeight ?? trackHeight,
      thumbSize: other.thumbSize ?? thumbSize,
      scale: other.scale ?? scale,
    );
  }
}

/// Switch input positions
enum SwitchPosition {
  /// Label on the right, switch on the left (default)
  start,

  /// Label on the left, switch on the right
  end,

  /// Switch above the label
  top,

  /// Switch below the label
  bottom,
}

/// Switch shape options
enum SwitchShape {
  /// Standard platform switch
  platform,

  /// iOS-style rounded switch
  ios,

  /// Material Design 3 switch
  material3,

  /// Custom switch (use with custom builder)
  custom,
}

/// Enhanced switch input widget
class SwitchInputWidget extends StatefulWidget {
  /// Field title (shown above)
  final String? title;

  /// Label text beside the switch
  final String? label;

  /// Helper text shown below
  final String? helperText;

  /// Error text for validation errors
  final String? errorText;

  /// Whether the field is required
  final bool isRequired;

  /// Current value
  final bool value;

  /// Callback when value changes
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is enabled
  final bool enabled;

  /// Cross axis alignment for layout
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Position of switch relative to label
  final SwitchPosition position;

  /// Switch visual style
  final SwitchShape shape;

  /// Style for the switch
  final SwitchStyle? style;

  /// Space between switch and label
  final double spacing;

  /// Optional icon to show with label
  final IconData? icon;

  /// Custom widget builder for the switch
  final Widget Function(BuildContext, bool, ValueChanged<bool>?)? switchBuilder;

  /// Custom widget builder for the label
  final Widget Function(BuildContext, String, bool)? labelBuilder;

  /// Whether to show a border around the switch container
  final bool showBorder;

  /// Description text to show below label
  final String? description;

  /// Tool tip text when hovering
  final String? tooltip;

  const SwitchInputWidget({
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
    this.position = SwitchPosition.start,
    this.shape = SwitchShape.platform,
    this.style,
    this.spacing = 8.0,
    this.icon,
    this.switchBuilder,
    this.labelBuilder,
    this.showBorder = false,
    this.description,
    this.tooltip,
  }) : assert(title != null || label != null,
            'Either title or label must be provided');

  @override
  State<SwitchInputWidget> createState() => _SwitchInputWidgetState();
}

class _SwitchInputWidgetState extends State<SwitchInputWidget> {
  // ignore: unused_field
  bool _isHovering = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final effectiveStyle = widget.style ?? const SwitchStyle();

    // Build the switch content
    Widget switchContent = _buildSwitchWithLabel(theme, effectiveStyle);

    // Add border if requested
    if (widget.showBorder) {
      switchContent = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError
                ? theme.colorScheme.error
                : effectiveStyle.borderColor ?? theme.dividerColor,
            width: 1.0,
          ),
          borderRadius: effectiveStyle.borderRadius ?? BorderRadius.circular(8),
          color: effectiveStyle.backgroundColor,
        ),
        padding: effectiveStyle.padding ?? const EdgeInsets.all(12),
        child: switchContent,
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      switchContent = Tooltip(
        message: widget.tooltip!,
        child: switchContent,
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
        switchContent,
        if (widget.description != null) ...[
          SizedBox(height: widget.verticalSpacing / 2),
          Padding(
            padding: EdgeInsets.only(
              left: widget.position == SwitchPosition.start ? 40 : 0,
              right: widget.position == SwitchPosition.end ? 40 : 0,
            ),
            child: Text(
              widget.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
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

  Widget _buildSwitchWithLabel(ThemeData theme, SwitchStyle style) {
    // Build the switch component
    Widget switchWidget = _buildSwitch(theme, style);

    // If no label, just return the switch
    if (widget.label == null) {
      return switchWidget;
    }

    // Build the label component
    Widget labelWidget = _buildLabel(theme, style);

    // Arrange switch and label according to position
    switch (widget.position) {
      case SwitchPosition.start:
        return Row(
          children: [
            switchWidget,
            SizedBox(width: widget.spacing),
            Expanded(child: labelWidget),
          ],
        );

      case SwitchPosition.end:
        return Row(
          children: [
            Expanded(child: labelWidget),
            SizedBox(width: widget.spacing),
            switchWidget,
          ],
        );

      case SwitchPosition.top:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            switchWidget,
            SizedBox(height: widget.spacing),
            labelWidget,
          ],
        );

      case SwitchPosition.bottom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget,
            SizedBox(height: widget.spacing),
            switchWidget,
          ],
        );
    }
  }

  Widget _buildSwitch(ThemeData theme, SwitchStyle style) {
    // Use custom builder if provided
    if (widget.switchBuilder != null) {
      return widget.switchBuilder!(
          context, widget.value, widget.enabled ? widget.onChanged : null);
    }

    // Build switch according to selected shape
    Widget switchWidget;

    switch (widget.shape) {
      case SwitchShape.platform:
        switchWidget = Switch.adaptive(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: style.activeColor ?? theme.colorScheme.primary,
          activeTrackColor: style.activeTrackColor,
          inactiveTrackColor: style.inactiveTrackColor,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return style.activeThumbColor ??
                  style.activeColor ??
                  theme.colorScheme.primary;
            }
            return style.inactiveThumbColor;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          focusColor: style.focusColor,
          hoverColor: style.hoverColor,
          focusNode: _focusNode,
        );
        break;

      case SwitchShape.ios:
        // iOS-style switch always has rounded track
        switchWidget = Switch.adaptive(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: style.activeColor ?? theme.colorScheme.primary,
          activeTrackColor: style.activeTrackColor ??
              theme.colorScheme.primary.withValues(alpha: 0.4),
          inactiveTrackColor: style.inactiveTrackColor ??
              theme.colorScheme.surfaceContainerHighest,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return style.activeThumbColor ?? Colors.white;
            }
            return style.inactiveThumbColor ?? Colors.white;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          focusColor: style.focusColor,
          hoverColor: style.hoverColor,
          focusNode: _focusNode,
        );
        break;

      case SwitchShape.material3:
        // Use Material 3 styles
        switchWidget = Switch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: style.activeColor ?? theme.colorScheme.primary,
          activeTrackColor:
              style.activeTrackColor ?? theme.colorScheme.primaryContainer,
          inactiveTrackColor: style.inactiveTrackColor ??
              theme.colorScheme.surfaceContainerHighest,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return style.activeThumbColor ?? theme.colorScheme.onPrimary;
            }
            return style.inactiveThumbColor ?? theme.colorScheme.outline;
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return theme.colorScheme.outline.withValues(alpha: 0.5);
          }),
          focusColor: style.focusColor,
          hoverColor: style.hoverColor,
          focusNode: _focusNode,
        );
        break;

      case SwitchShape.custom:
        // Default behavior if custom is selected but no builder is provided
        switchWidget = Switch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: style.activeColor ?? theme.colorScheme.primary,
          activeTrackColor: style.activeTrackColor,
          inactiveTrackColor: style.inactiveTrackColor,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return style.activeThumbColor ??
                  style.activeColor ??
                  theme.colorScheme.primary;
            }
            return style.inactiveThumbColor;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          focusColor: style.focusColor,
          hoverColor: style.hoverColor,
          focusNode: _focusNode,
        );
        break;
    }

    // Apply scaling if specified
    if (style.scale != null && style.scale != 1.0) {
      switchWidget = Transform.scale(
        scale: style.scale!,
        child: switchWidget,
      );
    }

    // Wrap in a MouseRegion to detect hovering
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: switchWidget,
    );
  }

  Widget _buildLabel(ThemeData theme, SwitchStyle style) {
    // Use custom label builder if provided
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(context, widget.label!, widget.value);
    }

    final effectiveLabelStyle = style.labelStyle ?? theme.textTheme.bodyMedium;

    return InkWell(
      onTap: widget.enabled && widget.onChanged != null
          ? () => widget.onChanged!(!widget.value)
          : null,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 18,
              color: widget.enabled
                  ? (widget.value
                      ? style.activeColor ?? theme.colorScheme.primary
                      : theme.iconTheme.color)
                  : theme.disabledColor,
            ),
            SizedBox(width: widget.spacing),
          ],
          Expanded(
            child: Text(
              widget.label!,
              style: effectiveLabelStyle?.copyWith(
                color: widget.enabled ? null : theme.disabledColor,
                fontWeight: widget.value ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form field that integrates SwitchInputWidget with form validation system
class FormSwitchField extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<bool>> rules;

  /// Initial value
  final bool initialValue;

  /// Field title (shown above)
  final String? title;

  /// Label text beside the switch
  final String? label;

  /// Helper text shown below
  final String? helperText;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the switch is enabled
  final bool enabled;

  /// Cross axis alignment for layout
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between elements
  final double verticalSpacing;

  /// Position of switch relative to label
  final SwitchPosition position;

  /// Switch visual style
  final SwitchShape shape;

  /// Style for the switch
  final SwitchStyle? style;

  /// Space between switch and label
  final double spacing;

  /// Optional icon to show with label
  final IconData? icon;

  /// Custom widget builder for the switch
  final Widget Function(BuildContext, bool, ValueChanged<bool>?)? switchBuilder;

  /// Custom widget builder for the label
  final Widget Function(BuildContext, String, bool)? labelBuilder;

  /// Whether to show a border around the switch container
  final bool showBorder;

  /// Description text to show below label
  final String? description;

  /// Tool tip text when hovering
  final String? tooltip;

  /// Called when the field content changes
  final ValueChanged<bool>? onChanged;

  const FormSwitchField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.initialValue = false,
    this.title,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.enabled = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.verticalSpacing = 8.0,
    this.position = SwitchPosition.start,
    this.shape = SwitchShape.platform,
    this.style,
    this.spacing = 8.0,
    this.icon,
    this.switchBuilder,
    this.labelBuilder,
    this.showBorder = false,
    this.description,
    this.tooltip,
    this.onChanged,
  }) : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        );

  @override
  FormSwitchFieldState createState() => FormSwitchFieldState();
}

class FormSwitchFieldState extends State<FormSwitchField> {
  FieldController<bool>? _fieldController;
  bool _currentValue = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // If we have a form controller and name, register the field
    if (widget.formController != null && widget.name != null) {
      _fieldController = widget.formController!.register<bool>(
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
          _currentValue = currentFieldState.value ?? false;
        }
        _errorText = currentFieldState.error;
      });
    }
  }

  @override
  void didUpdateWidget(FormSwitchField oldWidget) {
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

  void _handleValueChanged(bool value) {
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
    return ValueListenableBuilder<FieldState<bool>>(
      valueListenable: _fieldController?.stateNotifier ??
          ValueNotifier(const FieldState<bool>()),
      builder: (context, fieldState, _) {
        return SwitchInputWidget(
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
          position: widget.position,
          shape: widget.shape,
          style: widget.style,
          spacing: widget.spacing,
          icon: widget.icon,
          switchBuilder: widget.switchBuilder,
          labelBuilder: widget.labelBuilder,
          showBorder: widget.showBorder,
          description: widget.description,
          tooltip: widget.tooltip,
        );
      },
    );
  }
}
