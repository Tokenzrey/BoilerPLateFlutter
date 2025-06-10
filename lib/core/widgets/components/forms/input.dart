library;

import 'dart:async';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template input_feature_visibility}
/// Controls when an input feature should be visible
/// {@endtemplate}
abstract class InputFeatureVisibility {
  /// Gets the dependencies needed to determine visibility
  List<ValueListenable> getDependencies();

  /// Determines if the feature can be shown based on current state
  bool canShow(TextFieldState state);

  /// Combines this visibility with another using AND logic
  InputFeatureVisibility operator &(InputFeatureVisibility other) {
    return _CompositeVisibility([this, other], _VisibilityOperator.and);
  }

  /// Combines this visibility with another using OR logic
  InputFeatureVisibility operator |(InputFeatureVisibility other) {
    return _CompositeVisibility([this, other], _VisibilityOperator.or);
  }

  /// Inverts this visibility condition
  InputFeatureVisibility operator ~() {
    return _NotVisibility(this);
  }

  /// Feature is always visible
  static final InputFeatureVisibility always = _AlwaysVisibility();

  /// Feature is never visible
  static final InputFeatureVisibility never = _NeverVisibility();

  /// Feature is visible when text is not empty
  static final InputFeatureVisibility textNotEmpty = _TextNotEmptyVisibility();

  /// Feature is visible when text is empty
  static final InputFeatureVisibility textEmpty = _TextEmptyVisibility();

  /// Feature is visible when field is focused
  static final InputFeatureVisibility focused = _FocusedVisibility();

  /// Feature is visible when field is hovered
  static final InputFeatureVisibility hovered = _HoveredVisibility();

  /// Feature is visible when text has selection
  static final InputFeatureVisibility hasSelection = _HasSelectionVisibility();
}

/// Visibility operator types
enum _VisibilityOperator { and, or }

/// Always visible feature
class _AlwaysVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) => true;
}

/// Never visible feature
class _NeverVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) => false;
}

/// Visible when text is not empty
class _TextNotEmptyVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) {
    return state.controller.text.isNotEmpty;
  }
}

/// Visible when text is empty
class _TextEmptyVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) {
    return state.controller.text.isEmpty;
  }
}

/// Visible when field is focused
class _FocusedVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) {
    return state.focusNode.hasFocus;
  }
}

/// Visible when field is hovered
class _HoveredVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) {
    return state.isHovered;
  }
}

/// Visible when text has selection
class _HasSelectionVisibility extends InputFeatureVisibility {
  @override
  List<ValueListenable> getDependencies() => [];

  @override
  bool canShow(TextFieldState state) {
    final selection = state.controller.selection;
    return selection.isValid && selection.start != selection.end;
  }
}

/// Combines multiple visibility conditions with an operator
class _CompositeVisibility extends InputFeatureVisibility {
  final List<InputFeatureVisibility> conditions;
  final _VisibilityOperator operator;

  _CompositeVisibility(this.conditions, this.operator);

  @override
  List<ValueListenable> getDependencies() {
    return conditions.expand((c) => c.getDependencies()).toList();
  }

  @override
  bool canShow(TextFieldState state) {
    if (operator == _VisibilityOperator.and) {
      return conditions.every((c) => c.canShow(state));
    } else {
      return conditions.any((c) => c.canShow(state));
    }
  }
}

/// Inverts a visibility condition
class _NotVisibility extends InputFeatureVisibility {
  final InputFeatureVisibility condition;

  _NotVisibility(this.condition);

  @override
  List<ValueListenable> getDependencies() {
    return condition.getDependencies();
  }

  @override
  bool canShow(TextFieldState state) {
    return !condition.canShow(state);
  }
}

/// {@template input_feature}
/// A feature that can be added to an input field
/// {@endtemplate}
abstract class InputFeature {
  /// Visibility condition for this feature
  final InputFeatureVisibility visibility;

  /// Creates an input feature with the given visibility
  InputFeature({required this.visibility});

  /// Creates the state for this feature
  InputFeatureState createState();

  /// Creates a clear button feature
  static InputFeature clear({
    InputFeatureVisibility? visibility,
    IconData icon = Icons.clear,
    FeaturePosition position = FeaturePosition.trailing,
  }) {
    return _ClearFeature(
      visibility: visibility ??
          (InputFeatureVisibility.textNotEmpty &
              InputFeatureVisibility.focused),
      icon: icon,
      position: position,
    );
  }

  /// Creates a password toggle feature
  static InputFeature passwordToggle({
    InputFeatureVisibility? visibility,
    PasswordToggleMode mode = PasswordToggleMode.toggle,
    IconData? iconShow,
    IconData? iconHide,
  }) {
    return _PasswordToggleFeature(
      visibility: visibility ?? InputFeatureVisibility.focused,
      mode: mode,
      iconShow: iconShow ?? Icons.visibility,
      iconHide: iconHide ?? Icons.visibility_off,
    );
  }

  /// Creates a hint/tooltip feature
  static InputFeature hint({
    required Widget Function(BuildContext) popupBuilder,
    InputFeatureVisibility? visibility,
    IconData icon = Icons.help_outline,
    FeaturePosition position = FeaturePosition.trailing,
  }) {
    return _HintFeature(
      visibility: visibility ?? InputFeatureVisibility.focused,
      popupBuilder: popupBuilder,
      icon: icon,
      position: position,
    );
  }

  /// Creates a revalidate button feature
  static InputFeature revalidate({
    InputFeatureVisibility? visibility,
    IconData icon = Icons.refresh,
    FeaturePosition position = FeaturePosition.trailing,
  }) {
    return _RevalidateFeature(
      visibility: visibility ?? InputFeatureVisibility.focused,
      icon: icon,
      position: position,
    );
  }

  /// Creates an autocomplete feature
  static InputFeature autoComplete<T>({
    required Future<List<T>> Function(String query) querySuggestions,
    required Widget Function(BuildContext, T, VoidCallback) itemBuilder,
    InputFeatureVisibility? visibility,
    BoxConstraints? popoverConstraints,
  }) {
    return _AutoCompleteFeature<T>(
      visibility: visibility ?? InputFeatureVisibility.focused,
      querySuggestions: querySuggestions,
      itemBuilder: itemBuilder,
      popoverConstraints: popoverConstraints,
    );
  }

  /// Creates a number spinner feature
  static InputFeature spinner({
    InputFeatureVisibility? visibility,
    double step = 1.0,
    bool enableGesture = true,
    String Function(String)? invalidValueFormatter,
  }) {
    return _SpinnerFeature(
      visibility: visibility ?? InputFeatureVisibility.always,
      step: step,
      enableGesture: enableGesture,
      invalidValueFormatter: invalidValueFormatter,
    );
  }

  /// Creates a copy button feature
  static InputFeature copy({
    InputFeatureVisibility? visibility,
    IconData icon = Icons.copy,
    FeaturePosition position = FeaturePosition.trailing,
  }) {
    return _CopyFeature(
      visibility: visibility ??
          (InputFeatureVisibility.textNotEmpty &
              InputFeatureVisibility.focused),
      icon: icon,
      position: position,
    );
  }

  /// Creates a paste button feature
  static InputFeature paste({
    InputFeatureVisibility? visibility,
    IconData icon = Icons.paste,
    FeaturePosition position = FeaturePosition.trailing,
  }) {
    return _PasteFeature(
      visibility: visibility ?? InputFeatureVisibility.focused,
      icon: icon,
      position: position,
    );
  }

  /// Creates a custom leading widget feature
  static InputFeature leading({
    required Widget child,
    InputFeatureVisibility? visibility,
  }) {
    return _LeadingFeature(
      visibility: visibility ?? InputFeatureVisibility.always,
      child: child,
    );
  }

  /// Creates a custom trailing widget feature
  static InputFeature trailing({
    required Widget child,
    InputFeatureVisibility? visibility,
  }) {
    return _TrailingFeature(
      visibility: visibility ?? InputFeatureVisibility.always,
      child: child,
    );
  }
}

/// Position of a feature in the input field
enum FeaturePosition {
  /// Before the input text
  leading,

  /// After the input text
  trailing,
}

/// Mode for password toggle feature
enum PasswordToggleMode {
  /// Toggle between obscured and visible text
  toggle,

  /// Show text only while pressed
  peek,
}

/// {@template input_feature_state}
/// State for an input feature
/// {@endtemplate}
abstract class InputFeatureState {
  /// The parent text field state
  TextFieldState? _fieldState;

  /// Visibility controller for animations
  late AnimationController _visibilityController;

  /// The visibility condition
  InputFeatureVisibility get visibility;

  /// Sets up the feature state
  void initState(TextFieldState fieldState) {
    _fieldState = fieldState;

    // Create animation controller for smooth visibility transitions
    _visibilityController = AnimationController(
      vsync: fieldState,
      duration: const Duration(milliseconds: 200),
      value: visibility.canShow(fieldState) ? 1.0 : 0.0,
    );

    // Listen to relevant state changes
    for (final dependency in visibility.getDependencies()) {
      dependency.addListener(_updateVisibility);
    }

    // Initial visibility check
    _updateVisibility();
  }

  /// Updates the visibility state
  void _updateVisibility() {
    if (_fieldState == null) return;

    final shouldShow = visibility.canShow(_fieldState!);
    if (shouldShow) {
      _visibilityController.forward();
    } else {
      _visibilityController.reverse();
    }
  }

  /// Called when text changes
  void onTextChanged() {
    _updateVisibility();
  }

  /// Called when selection changes
  void onSelectionChanged() {
    _updateVisibility();
  }

  /// Builds the leading widget
  Widget? buildLeading() => null;

  /// Builds the trailing widget
  Widget? buildTrailing() => null;

  /// Wraps the input field with additional functionality if needed
  Widget? wrap(Widget child) => null;

  /// Gets additional actions for keyboard shortcuts
  Map<Type, Action>? getActions() => null;

  /// Gets additional shortcuts
  Map<LogicalKeySet, Intent>? getShortcuts() => null;

  /// Cleans up resources
  void dispose() {
    for (final dependency in visibility.getDependencies()) {
      dependency.removeListener(_updateVisibility);
    }
    _visibilityController.dispose();
    _fieldState = null;
  }

  /// Creates a fade effect for the feature based on visibility
  Widget fadeVisibility(Widget child) {
    return FadeTransition(
      opacity: _visibilityController,
      child: child,
    );
  }
}

// Feature implementations (simplified for brevity)

class _ClearFeature extends InputFeature {
  final IconData icon;
  final FeaturePosition position;

  _ClearFeature({
    required super.visibility,
    required this.icon,
    required this.position,
  });

  @override
  InputFeatureState createState() => _ClearFeatureState(this);
}

class _ClearFeatureState extends InputFeatureState {
  final _ClearFeature feature;

  _ClearFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;

  @override
  Widget? buildLeading() {
    if (feature.position == FeaturePosition.leading) {
      return fadeVisibility(
        IconButton(
          icon: Icon(feature.icon, size: 16),
          onPressed: () => _fieldState?.controller.clear(),
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          padding: const EdgeInsets.all(4),
          splashRadius: 16,
        ),
      );
    }
    return null;
  }

  @override
  Widget? buildTrailing() {
    if (feature.position == FeaturePosition.trailing) {
      return fadeVisibility(
        IconButton(
          icon: Icon(feature.icon, size: 16),
          onPressed: () => _fieldState?.controller.clear(),
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          padding: const EdgeInsets.all(4),
          splashRadius: 16,
        ),
      );
    }
    return null;
  }

  @override
  Map<Type, Action> getActions() {
    return {
      TextFieldClearIntent: CallbackAction<TextFieldClearIntent>(
        onInvoke: (_) {
          _fieldState?.controller.clear();
          return null;
        },
      ),
    };
  }

  @override
  Map<LogicalKeySet, Intent> getShortcuts() {
    return {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
          TextFieldClearIntent(),
    };
  }
}

class _PasswordToggleFeature extends InputFeature {
  final PasswordToggleMode mode;
  final IconData iconShow;
  final IconData iconHide;

  _PasswordToggleFeature({
    required super.visibility,
    required this.mode,
    required this.iconShow,
    required this.iconHide,
  });

  @override
  InputFeatureState createState() => _PasswordToggleFeatureState(this);
}

class _PasswordToggleFeatureState extends InputFeatureState {
  final _PasswordToggleFeature feature;
  bool _obscureText = true;

  _PasswordToggleFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;

  @override
  Widget buildTrailing() {
    return fadeVisibility(
      IconButton(
        icon: Icon(
          _obscureText ? feature.iconShow : feature.iconHide,
          size: 16,
        ),
        onPressed: _toggleObscureText,
        constraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        padding: const EdgeInsets.all(4),
        splashRadius: 16,
      ),
    );
  }

  void _toggleObscureText() {
    if (feature.mode == PasswordToggleMode.toggle) {
      _fieldState?.setObscureText(!_obscureText);
      _obscureText = !_obscureText;
    } else {
      // Peek mode
      _fieldState?.setObscureText(false);
      Future.delayed(const Duration(seconds: 2), () {
        if (_fieldState != null) {
          _fieldState!.setObscureText(true);
        }
      });
    }
  }
}

// Other feature implementations would follow a similar pattern
// For brevity, I'm only showing two full implementations

class _HintFeature extends InputFeature {
  final Widget Function(BuildContext) popupBuilder;
  final IconData icon;
  final FeaturePosition position;

  _HintFeature({
    required super.visibility,
    required this.popupBuilder,
    required this.icon,
    required this.position,
  });

  @override
  InputFeatureState createState() => _HintFeatureState(this);
}

class _HintFeatureState extends InputFeatureState {
  final _HintFeature feature;

  _HintFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;

  @override
  Widget? buildLeading() =>
      feature.position == FeaturePosition.leading ? _buildHintIcon() : null;

  @override
  Widget? buildTrailing() =>
      feature.position == FeaturePosition.trailing ? _buildHintIcon() : null;

  Widget _buildHintIcon() {
    return fadeVisibility(
      IconButton(
        icon: Icon(feature.icon, size: 16),
        onPressed: _showHint,
        constraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        padding: const EdgeInsets.all(4),
        splashRadius: 16,
      ),
    );
  }

  void _showHint() {
    if (_fieldState == null) return;

    final overlay = Overlay.of(_fieldState!.context);
    final renderBox = _fieldState!.context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + renderBox.size.height + 4,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: feature.popupBuilder(context),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

// Placeholder implementations for other features
class _RevalidateFeature extends InputFeature {
  final IconData icon;
  final FeaturePosition position;

  _RevalidateFeature({
    required super.visibility,
    required this.icon,
    required this.position,
  });

  @override
  InputFeatureState createState() => _RevalidateFeatureState(this);
}

class _RevalidateFeatureState extends InputFeatureState {
  final _RevalidateFeature feature;

  _RevalidateFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;
}

class _AutoCompleteFeature<T> extends InputFeature {
  final Future<List<T>> Function(String query) querySuggestions;
  final Widget Function(BuildContext, T, VoidCallback) itemBuilder;
  final BoxConstraints? popoverConstraints;

  _AutoCompleteFeature({
    required super.visibility,
    required this.querySuggestions,
    required this.itemBuilder,
    this.popoverConstraints,
  });

  @override
  InputFeatureState createState() => _AutoCompleteFeatureState<T>(this);
}

class _AutoCompleteFeatureState<T> extends InputFeatureState {
  final _AutoCompleteFeature<T> feature;

  _AutoCompleteFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;
}

class _SpinnerFeature extends InputFeature {
  final double step;
  final bool enableGesture;
  final String Function(String)? invalidValueFormatter;

  _SpinnerFeature({
    required super.visibility,
    required this.step,
    required this.enableGesture,
    this.invalidValueFormatter,
  });

  @override
  InputFeatureState createState() => _SpinnerFeatureState(this);
}

class _SpinnerFeatureState extends InputFeatureState {
  final _SpinnerFeature feature;

  _SpinnerFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;
}

class _CopyFeature extends InputFeature {
  final IconData icon;
  final FeaturePosition position;

  _CopyFeature({
    required super.visibility,
    required this.icon,
    required this.position,
  });

  @override
  InputFeatureState createState() => _CopyFeatureState(this);
}

class _CopyFeatureState extends InputFeatureState {
  final _CopyFeature feature;

  _CopyFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;
}

class _PasteFeature extends InputFeature {
  final IconData icon;
  final FeaturePosition position;

  _PasteFeature({
    required super.visibility,
    required this.icon,
    required this.position,
  });

  @override
  InputFeatureState createState() => _PasteFeatureState(this);
}

class _PasteFeatureState extends InputFeatureState {
  final _PasteFeature feature;

  _PasteFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;
}

class _LeadingFeature extends InputFeature {
  final Widget child;

  _LeadingFeature({
    required super.visibility,
    required this.child,
  });

  @override
  InputFeatureState createState() => _LeadingFeatureState(this);
}

class _LeadingFeatureState extends InputFeatureState {
  final _LeadingFeature feature;

  _LeadingFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;

  @override
  Widget? buildLeading() {
    return fadeVisibility(feature.child);
  }
}

class _TrailingFeature extends InputFeature {
  final Widget child;

  _TrailingFeature({
    required super.visibility,
    required this.child,
  });

  @override
  InputFeatureState createState() => _TrailingFeatureState(this);
}

class _TrailingFeatureState extends InputFeatureState {
  final _TrailingFeature feature;

  _TrailingFeatureState(this.feature);

  @override
  InputFeatureVisibility get visibility => feature.visibility;

  @override
  Widget? buildTrailing() {
    return fadeVisibility(feature.child);
  }
}

/// Intent to clear the text field
class TextFieldClearIntent extends Intent {
  const TextFieldClearIntent();
}

/// Intent to append text to the text field
class TextFieldAppendTextIntent extends Intent {
  final String text;

  const TextFieldAppendTextIntent(this.text);
}

/// Intent to replace the current word in the text field
class TextFieldReplaceCurrentWordIntent extends Intent {
  final String replacement;

  const TextFieldReplaceCurrentWordIntent(this.replacement);
}

/// Intent to set the text in the text field
class TextFieldSetTextIntent extends Intent {
  final String text;

  const TextFieldSetTextIntent(this.text);
}

/// Intent to set the selection in the text field
class TextFieldSetSelectionIntent extends Intent {
  final TextSelection selection;

  const TextFieldSetSelectionIntent(this.selection);
}

/// Intent to select all text and copy it
class TextFieldSelectAllAndCopyIntent extends Intent {
  const TextFieldSelectAllAndCopyIntent();
}

/// {@template text_field_state}
/// State for the enhanced text field with feature management
/// {@endtemplate}
class TextFieldState extends State<InputTextField>
    with TickerProviderStateMixin {
  /// Text editing controller
  late TextEditingController controller;

  /// Focus node
  late FocusNode focusNode;

  /// Whether the field is being hovered
  bool isHovered = false;

  /// Whether the text is obscured
  bool _obscureText = false;

  /// List of active features
  final List<InputFeatureState> _features = [];

  /// Text field key for finding render object
  final GlobalKey _textFieldKey = GlobalKey();

  /// Whether text is currently obscured
  bool get obscureText => _obscureText;

  /// Set whether text is obscured
  void setObscureText(bool value) {
    setState(() {
      _obscureText = value;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize controller
    controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    controller.addListener(_onTextChanged);

    // Initialize focus node
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(_onFocusChanged);

    // Set initial obscure text
    _obscureText = widget.obscureText;

    // Initialize features
    for (final feature in widget.features) {
      final featureState = feature.createState();
      _features.add(featureState);
      featureState.initState(this);
    }

    controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(InputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if needed
    if (widget.controller != oldWidget.controller) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
      controller =
          widget.controller ?? TextEditingController(text: widget.initialValue);
      controller.addListener(_onTextChanged);
    }

    // Update focus node if needed
    if (widget.focusNode != oldWidget.focusNode) {
      focusNode.removeListener(_onFocusChanged);
      focusNode.dispose();
      focusNode = widget.focusNode ?? FocusNode();
      focusNode.addListener(_onFocusChanged);
    }

    // Update obscure text if needed
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }

    // Update features if needed
    if (widget.features != oldWidget.features) {
      // Clean up old features
      for (final feature in _features) {
        feature.dispose();
      }
      _features.clear();

      // Initialize new features
      for (final feature in widget.features) {
        final featureState = feature.createState();
        _features.add(featureState);
        featureState.initState(this);
      }
    }
  }

  @override
  void dispose() {
    // Clean up controller
    controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      controller.dispose();
    }

    // Clean up focus node
    focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      focusNode.dispose();
    }

    // Clean up features
    for (final feature in _features) {
      feature.dispose();
    }

    super.dispose();
  }

  void _onTextChanged() {
    for (final feature in _features) {
      feature.onTextChanged();
    }
    widget.onChanged?.call(controller.text);
  }

  void _onFocusChanged() {
    setState(() {});

    // If field lost focus and has formatters, apply them
    if (!focusNode.hasFocus && widget.submitFormatters.isNotEmpty) {
      String formattedText = controller.text;
      for (final formatter in widget.submitFormatters) {
        formattedText = formatter(formattedText);
      }
      if (formattedText != controller.text) {
        controller.text = formattedText;
      }
    }

    for (final feature in _features) {
      feature.onTextChanged();
    }
  }

  void _onSelectionChanged() {
    final selection = controller.selection;
    if (selection.isValid) {
      // Handle selection change
      widget.onSelectionChanged?.call(selection, null);
      for (final feature in _features) {
        feature.onSelectionChanged();
      }
    }
  }

  void _onHoverChanged(bool value) {
    if (isHovered != value) {
      setState(() {
        isHovered = value;
      });
      for (final feature in _features) {
        feature.onTextChanged();
      }
    }
  }

  // Collect all actions from features
  Map<Type, Action> _collectActions() {
    final result = <Type, Action>{};
    for (final feature in _features) {
      final actions = feature.getActions();
      if (actions != null) {
        result.addAll(actions);
      }
    }
    return result;
  }

  // Collect all shortcuts from features
  Map<LogicalKeySet, Intent> _collectShortcuts() {
    final result = <LogicalKeySet, Intent>{};
    for (final feature in _features) {
      final shortcuts = feature.getShortcuts();
      if (shortcuts != null) {
        result.addAll(shortcuts);
      }
    }
    return result;
  }

  // Build leading widgets from features
  List<Widget> _buildLeadingWidgets() {
    final widgets = <Widget>[];

    // Add prefix icon if specified
    if (widget.prefixIcon != null) {
      widgets.add(Icon(widget.prefixIcon, size: 16));
      widgets.add(const SizedBox(width: 8));
    }

    // Add leading widgets from features
    for (final feature in _features) {
      final leadingWidget = feature.buildLeading();
      if (leadingWidget != null) {
        widgets.add(leadingWidget);
        widgets.add(const SizedBox(width: 4));
      }
    }

    return widgets;
  }

  // Build trailing widgets from features
  List<Widget> _buildTrailingWidgets() {
    final widgets = <Widget>[];

    // Add trailing widgets from features
    for (final feature in _features) {
      final trailingWidget = feature.buildTrailing();
      if (trailingWidget != null) {
        widgets.add(trailingWidget);
        widgets.add(const SizedBox(width: 4));
      }
    }

    // Add suffix icon if specified
    if (widget.suffixIcon != null) {
      widgets.add(const SizedBox(width: 4));
      widgets.add(widget.suffixIcon!);
    }

    // Add error or validation indicator
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      widgets.add(const SizedBox(width: 4));
    } else if (widget.isPending) {
      widgets.add(const SizedBox(width: 4));
      widgets.add(const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap all features
    Widget result = _buildTextField(theme);

    for (final feature in _features) {
      final wrapper = feature.wrap(result);
      if (wrapper != null) {
        result = wrapper;
      }
    }

    // Add actions and shortcuts
    return Shortcuts(
      shortcuts: _collectShortcuts(),
      child: Actions(
        actions: _collectActions(),
        child: result,
      ),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    // Build base input decoration
    final InputDecoration effectiveDecoration = _buildInputDecoration(theme);

    // For testing - this is where a custom gesture detector would go
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: TextField(
        key: _textFieldKey,
        controller: controller,
        focusNode: focusNode,
        decoration: effectiveDecoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
        obscureText: _obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onSubmitted: widget.onFieldSubmitted,
        inputFormatters: widget.inputFormatters,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme) {
    final leadingWidgets = _buildLeadingWidgets();
    final trailingWidgets = _buildTrailingWidgets();

    // Basic decoration with label and placeholder
    InputDecoration decoration = widget.decoration ??
        InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8,
            ),
            borderSide: BorderSide(
              color: theme.dividerColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8,
            ),
            borderSide: BorderSide(
              color: theme.dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? 8,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          filled: widget.filled,
          fillColor: widget.filled
              ? (theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100])
              : null,
        );

    // Add hint text
    if (widget.hintText != null && widget.hintText!.isNotEmpty) {
      decoration = decoration.copyWith(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: theme.hintColor,
        ),
      );
    }

    // Add prefix/suffix widgets
    if (leadingWidgets.isNotEmpty) {
      decoration = decoration.copyWith(
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: leadingWidgets,
        ),
      );
    }

    if (trailingWidgets.isNotEmpty) {
      decoration = decoration.copyWith(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: trailingWidgets,
        ),
      );
    }

    // Hide the error text since we handle it separately
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      decoration = decoration.copyWith(
        errorText: '', // Empty error text to trigger error styling
        errorStyle:
            const TextStyle(height: 0, fontSize: 0), // Hide the error text
      );
    }

    return decoration;
  }
}

/// {@template form_text_field}
/// Enhanced text field with feature support and form integration
/// {@endtemplate}
class InputTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Initial value for the field
  final String? initialValue;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Label for the field
  final String? label;

  /// Whether the field is required
  final bool isRequired;

  /// Hint text for the field
  final String? hintText;

  /// Helper text for the field
  final String? helperText;

  /// Error text for the field
  final String? errorText;

  /// Whether async validation is in progress
  final bool isPending;

  /// Whether to obscure text
  final bool obscureText;

  /// Keyboard type for the field
  final TextInputType? keyboardType;

  /// Action to perform on submit
  final TextInputAction? textInputAction;

  /// Decoration for the text field
  final InputDecoration? decoration;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Whether to auto-focus the field
  final bool autofocus;

  /// Maximum number of lines
  final int? maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum number of characters
  final int? maxLength;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Formatters applied only on submit
  final List<String Function(String)> submitFormatters;

  /// Text style
  final TextStyle? textStyle;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final Widget? suffixIcon;

  /// Features to add to the field
  final List<InputFeature> features;

  /// Border radius
  final double? borderRadius;

  /// Whether to fill the background
  final bool filled;

  /// Whether to enable autocorrect
  final bool autocorrect;

  /// Whether to enable suggestions
  final bool enableSuggestions;

  /// Whether to enable IME personalized learning
  final bool enableIMEPersonalizedLearning;

  /// Callback for text changes
  final ValueChanged<String>? onChanged;

  /// Callback for field submission
  final ValueChanged<String>? onFieldSubmitted;

  /// Callback for selection changes
  final SelectionChangedCallback? onSelectionChanged;

  /// {@template form_text_field_constructor}
  /// Creates an enhanced text field.
  ///
  /// [controller] Text editing controller
  /// [initialValue] Initial text value
  /// [focusNode] Focus node for controlling focus
  /// [label] Text label displayed above the field
  /// [isRequired] Whether this field is required
  /// [hintText] Placeholder text
  /// [helperText] Helper text shown below the field
  /// [errorText] Error text to show when validation fails
  /// [isPending] Whether async validation is in progress
  /// [obscureText] Whether to hide the text
  /// [keyboardType] The keyboard type to use
  /// [textInputAction] Action button on the keyboard
  /// [decoration] Custom input decoration
  /// [enabled] Whether the field is editable
  /// [readOnly] Whether the field is read-only
  /// [autofocus] Whether to focus this field on load
  /// [maxLines] Maximum number of lines
  /// [minLines] Minimum number of lines
  /// [maxLength] Maximum number of characters allowed
  /// [inputFormatters] Formatters for input restriction
  /// [submitFormatters] Formatters applied only on submit
  /// [textStyle] Style for the input text
  /// [prefixIcon] Icon to show before the input
  /// [suffixIcon] Widget to show after the input
  /// [features] Features to add to the field
  /// [borderRadius] Border radius for the field
  /// [filled] Whether to fill the background
  /// [autocorrect] Whether to enable autocorrect
  /// [enableSuggestions] Whether to enable suggestions
  /// [enableIMEPersonalizedLearning] Whether to enable IME personalized learning
  /// [onChanged] Callback for when text changes
  /// [onFieldSubmitted] Callback for when field is submitted
  /// [onSelectionChanged] Callback for when selection changes
  /// {@endtemplate}
  const InputTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isPending = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.decoration,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.submitFormatters = const [],
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.features = const [],
    this.borderRadius,
    this.filled = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableIMEPersonalizedLearning = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSelectionChanged,
  }) : assert(controller == null || initialValue == null,
            'Cannot provide both a controller and an initialValue');

  @override
  TextFieldState createState() => TextFieldState();
}

/// {@template form_input_field}
/// A form input field that integrates with the enhanced form system.
///
/// This component combines InputTextField with the form validation system,
/// providing a complete solution for form fields with validation.
/// {@endtemplate}
class FormInputField extends StatefulWidget {
  /// Form controller to register this field with
  final FormController? formController;

  /// Field name for registration with FormController
  final String? name;

  /// Validation rules to apply to this field
  final List<ValidationRule<String>> rules;

  /// Initial value for the field
  final String? initialValue;

  /// Label text shown above the input field
  final String? label;

  /// Whether this field is required (affects label display)
  final bool isRequired;

  /// Whether to hide the text being edited (for passwords)
  final bool obscureText;

  /// The type of keyboard to use for editing the text
  final TextInputType? keyboardType;

  /// The decoration to show around the text field
  final InputDecoration? decoration;

  /// Whether the text field is interactive
  final bool enabled;

  /// Whether the text field is read-only
  final bool readOnly;

  /// Whether the input field should focus itself when first loaded
  final bool autofocus;

  /// Focus node for controlling the focus of this input
  final FocusNode? focusNode;

  /// The maximum number of lines for the text to span
  final int? maxLines;

  /// The minimum number of lines for the text to span
  final int? minLines;

  /// The maximum number of characters the user can enter
  final int? maxLength;

  /// The type of action button to show on the keyboard
  final TextInputAction? textInputAction;

  /// Optional input formatters to use
  final List<TextInputFormatter>? inputFormatters;

  /// Formatters applied only on submit
  final List<String Function(String)> submitFormatters;

  /// Text style for the input field
  final TextStyle? textStyle;

  /// Icon to show before the text field
  final IconData? prefixIcon;

  /// Widget to show after the text field
  final Widget? suffixIcon;

  /// Spacing between the field elements
  final double verticalSpacing;

  /// Placeholder text when the field is empty
  final String? hintText;

  /// Helper text shown below the field
  final String? helperText;

  /// Features to add to the input field
  final List<InputFeature> features;

  /// Border radius for the field
  final double? borderRadius;

  /// Whether to fill the background
  final bool filled;

  /// Called when the field focus changes
  final void Function(bool)? onFocusChange;

  /// Called when the field is submitted
  final void Function(String)? onFieldSubmitted;

  /// Called when the field content changes
  final void Function(String)? onChanged;

  /// Called when selection changes
  final SelectionChangedCallback? onSelectionChanged;

  /// {@template form_input_field_constructor}
  /// Creates a form input field.
  ///
  /// [formController] Form controller to register the field with
  /// [name] Field name for registration with FormController
  /// [rules] List of validation rules to apply
  /// [initialValue] Initial text value
  /// [label] Text label displayed above the field
  /// [isRequired] Whether this field is required (shows indicator in label)
  /// [obscureText] Whether to hide the text (for passwords)
  /// [keyboardType] The keyboard type to use
  /// [decoration] Custom input decoration
  /// [enabled] Whether the field is editable
  /// [readOnly] Whether the field is read-only
  /// [autofocus] Whether to focus this field on load
  /// [focusNode] Optional focus node for controlling focus
  /// [maxLines] Maximum number of lines
  /// [minLines] Minimum number of lines
  /// [maxLength] Maximum number of characters allowed
  /// [textInputAction] Action button on the keyboard
  /// [inputFormatters] Optional formatters for input restriction
  /// [submitFormatters] Formatters applied only on submit
  /// [textStyle] Style for the input text
  /// [prefixIcon] Icon to show before the input
  /// [suffixIcon] Widget to show after the input
  /// [verticalSpacing] Spacing between field elements
  /// [hintText] Placeholder text
  /// [helperText] Helper text shown below the field
  /// [features] Features to add to the input field
  /// [borderRadius] Border radius for the field
  /// [filled] Whether to fill the background
  /// [onFocusChange] Callback when focus changes
  /// [onFieldSubmitted] Callback when field is submitted
  /// [onChanged] Callback when content changes
  /// [onSelectionChanged] Callback when selection changes
  /// {@endtemplate}
  const FormInputField({
    super.key,
    this.formController,
    this.name,
    this.rules = const [],
    this.initialValue,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType,
    this.decoration,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.inputFormatters,
    this.submitFormatters = const [],
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.verticalSpacing = 6.0,
    this.hintText,
    this.features = const [],
    this.borderRadius,
    this.filled = false,
    this.onFocusChange,
    this.onFieldSubmitted,
    this.onChanged,
    this.onSelectionChanged,
  }) : assert(
          (formController == null) || (name != null),
          'If formController is provided, name is required',
        );

  @override
  FormInputFieldState createState() => FormInputFieldState();
}

class FormInputFieldState extends State<FormInputField> {
  late FocusNode _focusNode;
  FieldController<String>? _fieldController;
  TextEditingController? _textController;
  String? _errorText;
  bool isPending = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _initializeControllers();
  }

  void _initializeControllers() {
    // If we have a form controller and name, register the field
    if (widget.formController != null && widget.name != null) {
      _fieldController = widget.formController!.register<String>(
        widget.name!,
        defaultValue: widget.initialValue,
        rules: widget.rules,
      );

      // Create a text controller that stays in sync with field controller
      _textController = TextEditingController(
        text: _fieldController?.value ?? widget.initialValue,
      );

      // Listen for field state changes
      _fieldController!.stateNotifier.addListener(_onFieldStateChanged);
    } else {
      // Just create a standalone text controller
      _textController = TextEditingController(text: widget.initialValue);
    }
  }

  void _onFieldStateChanged() {
    if (_fieldController != null) {
      final currentFieldState = _fieldController!.state;

      // Update text if it's different (avoid loops)
      if (_textController!.text != currentFieldState.value) {
        _textController!.text = currentFieldState.value ?? '';
      }

      setState(() {
        _errorText = currentFieldState.error;
      });
    }
  }

  @override
  void didUpdateWidget(FormInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If form controller or name changed, re-register the field
    if (widget.formController != oldWidget.formController ||
        widget.name != oldWidget.name) {
      if (_fieldController != null) {
        _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      }

      _disposeControllers();
      _initializeControllers();
    }

    // Update focus node if needed
    if (widget.focusNode != oldWidget.focusNode) {
      if (widget.onFocusChange != null && oldWidget.focusNode == null) {
        _focusNode.removeListener(_onFocusChanged);
      }

      _focusNode = widget.focusNode ?? FocusNode();

      if (widget.onFocusChange != null) {
        _focusNode.addListener(_onFocusChanged);
      }
    }
  }

  void _onFocusChanged() {
    debugPrint(
        '[onFocusChanged] field: ${widget.name}, hasFocus: ${_focusNode.hasFocus}');
    widget.onFocusChange?.call(_focusNode.hasFocus);

    // If using onBlur validation mode, trigger validation when focus is lost
    if (!_focusNode.hasFocus && _fieldController != null) {
      debugPrint(
          '[FormInputFieldState._onFocusChanged] field: ${widget.name}, call markAsTouched()');
      _fieldController!.markAsTouched();
    }
  }

  void _disposeControllers() {
    if (_fieldController != null) {
      _fieldController!.stateNotifier.removeListener(_onFieldStateChanged);
      _fieldController = null;
    }

    // Only dispose if we created it
    if (_textController != null && widget.formController != null) {
      _textController!.dispose();
      _textController = null;
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _focusNode.removeListener(_onFocusChanged);
    if (widget.onFocusChange != null && widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _handleTextChanged(String value) {
    // Update the field controller if we have one
    if (_fieldController != null) {
      _fieldController!.setValue(value);
    }

    // Call the onChange callback if provided
    widget.onChanged?.call(value);
  }

  void _handleSubmitted(String value) {
    // Call the onFieldSubmitted callback if provided
    widget.onFieldSubmitted?.call(value);

    // Trigger validation if using onSubmit mode
    if (_fieldController != null) {
      _fieldController!.markAsTouched();
      _fieldController!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ValueListenableBuilder to ensure the widget rebuilds when field state changes
    return ValueListenableBuilder<FieldState<String>>(
        valueListenable: _fieldController?.stateNotifier ??
            ValueNotifier(const FieldState<String>()),
        builder: (context, fieldState, _) {
          debugPrint(
              '[FormInputField.ValueListenableBuilder] field: ${widget.name}, error: ${fieldState.error}, isTouched: ${fieldState.isTouched}');
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
              InputTextField(
                controller: _textController,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                decoration: widget.decoration,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
                submitFormatters: widget.submitFormatters,
                textStyle: widget.textStyle,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                hintText: widget.hintText,
                errorText: fieldState.error ?? _errorText,
                isPending: isPending,
                features: widget.features,
                borderRadius: widget.borderRadius,
                filled: widget.filled,
                onFieldSubmitted: _handleSubmitted,
                onChanged: _handleTextChanged,
                onSelectionChanged: widget.onSelectionChanged,
              ),
              if (widget.helperText != null &&
                  (fieldState.error == null && _errorText == null)) ...[
                SizedBox(height: widget.verticalSpacing),
                HelperText(widget.helperText!),
              ],
              if (fieldState.error != null || _errorText != null) ...[
                SizedBox(height: widget.verticalSpacing),
                ErrorMessage(errorText: fieldState.error ?? _errorText!),
              ],
            ],
          );
        });
  }
}
