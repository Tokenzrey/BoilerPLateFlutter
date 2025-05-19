import 'package:boilerplate/core/widgets/components/display/chip.dart';
import 'package:boilerplate/core/widgets/components/forms/error_text.dart';
import 'package:boilerplate/core/widgets/components/forms/helper_text.dart';
import 'package:boilerplate/core/widgets/components/forms/label_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'form.dart';
import 'input.dart';

typedef ChipWidgetBuilder<T> = Widget Function(BuildContext context, T chip);

/// Controller for ChipInput that manages state
class ChipInputController<T> extends ValueNotifier<List<T>> {
  ChipInputController([super.initialValue = const []]);

  void add(T value) {
    this.value = [...this.value, value];
  }

  void remove(T value) {
    this.value = this.value.where((item) => item != value).toList();
  }

  void removeAt(int index) {
    if (index >= 0 && index < value.length) {
      final newList = List<T>.from(value);
      newList.removeAt(index);
      value = newList;
    }
  }

  void clear() {
    value = [];
  }
}

/// A form field that allows selecting multiple items as chips
class FormChipField<T> extends StatefulWidget {
  /// Unique form key for this field
  final FormKey<List<T>> formKey;

  /// Initial value for the field
  final List<T> initialValue;

  /// Validators for this field
  final List<Validator<List<T>>> validators;

  /// Label text shown above the input field
  final String? label;

  /// Whether this field is required
  final bool isRequired;

  /// Controller for the chip input
  final ChipInputController<T>? controller;

  /// Controller for the text input
  final TextEditingController? textController;

  /// Focus node for the text input
  final FocusNode? focusNode;

  /// Constraints for the suggestion popover
  final BoxConstraints popoverConstraints;

  /// Controller for undo history
  final UndoHistoryController? undoHistoryController;

  /// Called when text is submitted
  final ValueChanged<String>? onSubmitted;

  /// Initial text for the input field
  final String? initialText;

  /// Available suggestions to show
  final List<T> suggestions;

  /// Input formatters for text input
  final List<TextInputFormatter>? inputFormatters;

  /// Called when a suggestion is chosen
  final void Function(int index)? onSuggestionChosen;

  /// Called when value changes
  final ValueChanged<List<T>>? onChanged;

  /// Builder for chip widgets
  final ChipWidgetBuilder<T> chipBuilder;

  /// Builder for suggestion widgets
  final ChipWidgetBuilder<T>? suggestionBuilder;

  /// Whether to use chip widgets or custom widgets
  final bool useChips;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Placeholder widget when empty
  final Widget? placeholder;

  /// Builder for suggestion leading widgets
  final Widget Function(BuildContext, T)? suggestionLeadingBuilder;

  /// Builder for suggestion trailing widgets
  final Widget Function(BuildContext, T)? suggestionTrailingBuilder;

  /// Widget to show at the trailing end of the input
  final Widget? inputTrailingWidget;

  /// Helper text to display below the field
  final String? helperText;

  /// Whether the field is enabled
  final bool enabled;

  const FormChipField({
    super.key,
    required this.formKey,
    this.initialValue = const [],
    this.validators = const [],
    this.label,
    this.isRequired = false,
    this.controller,
    this.textController,
    this.focusNode,
    this.popoverConstraints = const BoxConstraints(maxHeight: 300),
    this.undoHistoryController,
    this.onSubmitted,
    this.initialText,
    this.suggestions = const [],
    this.inputFormatters,
    this.onSuggestionChosen,
    this.onChanged,
    required this.chipBuilder,
    this.suggestionBuilder,
    this.useChips = true,
    this.textInputAction,
    this.placeholder,
    this.suggestionLeadingBuilder,
    this.suggestionTrailingBuilder,
    this.inputTrailingWidget,
    this.helperText,
    this.enabled = true,
  });

  @override
  State<FormChipField<T>> createState() => _FormChipFieldState<T>();
}

class _FormChipFieldState<T> extends State<FormChipField<T>> {
  late ChipInputController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? ChipInputController<T>(widget.initialValue);
  }

  @override
  void didUpdateWidget(FormChipField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if needed
    if (widget.controller != oldWidget.controller) {
      if (widget.controller == null) {
        _controller = ChipInputController<T>(widget.initialValue);
      } else {
        _controller = widget.controller!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormEntry<List<T>>(
      formKey: widget.formKey,
      initialValue: _controller.value,
      validators: widget.validators,
      builder: (context, field) {
        // Synchronize form value with controller
        _controller.addListener(() {
          field.setValue(_controller.value);
          widget.onChanged?.call(_controller.value);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              LabelText(
                widget.label!,
                isRequired: widget.isRequired,
              ),
              const SizedBox(height: 6),
            ],
            ChipInput<T>(
              controller: widget.textController,
              popoverConstraints: widget.popoverConstraints,
              undoHistoryController: widget.undoHistoryController,
              onSubmitted: widget.onSubmitted,
              initialText: widget.initialText,
              focusNode: widget.focusNode,
              suggestions: widget.suggestions,
              chips: _controller.value,
              inputFormatters: widget.inputFormatters,
              onSuggestionChoosen: widget.onSuggestionChosen,
              onChanged: (chips) {
                _controller.value = chips;
                field.setValue(chips);
              },
              useChips: widget.useChips,
              chipBuilder: widget.chipBuilder,
              suggestionBuilder: widget.suggestionBuilder,
              textInputAction: widget.textInputAction,
              placeholder: widget.placeholder,
              suggestionLeadingBuilder: widget.suggestionLeadingBuilder,
              suggestionTrailingBuilder: widget.suggestionTrailingBuilder,
              inputTrailingWidget: widget.inputTrailingWidget,
              enabled: widget.enabled && field.error == null,
            ),
            if (widget.helperText != null && field.error == null) ...[
              const SizedBox(height: 6),
              HelperText(widget.helperText!),
            ],
            if (field.error != null) ...[
              const SizedBox(height: 6),
              ErrorMessage(errorText: field.error!),
            ],
          ],
        );
      },
    );
  }
}

class ChipInput<T> extends StatefulWidget {
  final TextEditingController? controller;
  final BoxConstraints popoverConstraints;
  final UndoHistoryController? undoHistoryController;
  final ValueChanged<String>? onSubmitted;
  final String? initialText;
  final FocusNode? focusNode;
  final List<T> suggestions;
  final List<T> chips;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(int index)? onSuggestionChoosen;
  final ValueChanged<List<T>>? onChanged;
  final ChipWidgetBuilder<T> chipBuilder;
  final ChipWidgetBuilder<T>? suggestionBuilder;
  final bool useChips;
  final TextInputAction? textInputAction;
  final Widget? placeholder;
  final Widget Function(BuildContext, T)? suggestionLeadingBuilder;
  final Widget Function(BuildContext, T)? suggestionTrailingBuilder;
  final Widget? inputTrailingWidget;
  final bool enabled;

  const ChipInput({
    super.key,
    this.controller,
    this.popoverConstraints = const BoxConstraints(maxHeight: 300),
    this.undoHistoryController,
    this.initialText,
    this.onSubmitted,
    this.focusNode,
    this.suggestions = const [],
    this.chips = const [],
    this.inputFormatters,
    this.onSuggestionChoosen,
    this.onChanged,
    this.useChips = true,
    this.suggestionBuilder,
    this.textInputAction,
    this.placeholder,
    this.suggestionLeadingBuilder,
    this.suggestionTrailingBuilder,
    this.inputTrailingWidget,
    required this.chipBuilder,
    this.enabled = true,
  });

  @override
  State<ChipInput<T>> createState() => ChipInputState<T>();
}

class ChipInputState<T> extends State<ChipInput<T>>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late ValueNotifier<List<T>> _suggestions;
  final ValueNotifier<int> _selectedSuggestions = ValueNotifier(-1);
  OverlayEntry? _overlayEntry;
  // Removed unused fields:
  // final GlobalKey _popoverKey = GlobalKey();
  // List<T> _currentValue = [];

  @override
  void initState() {
    super.initState();
    _suggestions = ValueNotifier([]);
    _focusNode = widget.focusNode ?? FocusNode();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialText);
    // Removed initialization of unused field:
    // _currentValue = List.from(widget.chips);

    _suggestions.addListener(_onSuggestionsChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.suggestions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        _suggestions.value = widget.suggestions;
      });
    }
  }

  void _onFocusChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onSuggestionsChanged();
    });
  }

  void _onSuggestionsChanged() {
    if (_suggestions.value.isEmpty || !_focusNode.hasFocus) {
      _hideOverlay();
    } else if (_overlayEntry == null && _suggestions.value.isNotEmpty) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: _buildPopover(context),
        ),
      );
    });

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _chipBuilder(int index) {
    if (!widget.useChips) {
      return widget.chipBuilder(context, widget.chips[index]);
    }

    return Chip(
      trailing: ChipButton(
        onPressed: () {
          List<T> chips = List.of(widget.chips);
          chips.removeAt(index);
          widget.onChanged?.call(chips);
        },
        child: const Icon(Icons.close, size: 16),
      ),
      child: widget.chipBuilder(context, widget.chips[index]),
    );
  }

  @override
  void didUpdateWidget(ChipInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      _controller = widget.controller!;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }

    if (!listEquals(widget.suggestions, _suggestions.value)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _suggestions.value = widget.suggestions;
      });
    }

    // Removed update of unused field:
    // if (!listEquals(widget.chips, oldWidget.chips)) {
    //   _currentValue = List.from(widget.chips);
    // }
  }

  Widget _buildPopover(BuildContext context) {
    return ConstrainedBox(
      constraints: widget.popoverConstraints,
      child: AnimatedBuilder(
        animation: Listenable.merge([_suggestions, _selectedSuggestions]),
        builder: (context, child) {
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(4),
            children: [
              for (int i = 0; i < _suggestions.value.length; i++)
                _buildSuggestionItem(i),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionItem(int index) {
    final theme = Theme.of(context);
    final isSelected = index == _selectedSuggestions.value;

    return InkWell(
      onTap: () {
        widget.onSuggestionChoosen?.call(index);
        _controller.clear();
        _selectedSuggestions.value = -1;
        _hideOverlay();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (widget.suggestionLeadingBuilder != null) ...[
              widget.suggestionLeadingBuilder!(
                  context, _suggestions.value[index]),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: widget.suggestionBuilder
                      ?.call(context, _suggestions.value[index]) ??
                  Text(_suggestions.value[index].toString()),
            ),
            if (widget.suggestionTrailingBuilder != null) ...[
              const SizedBox(width: 10),
              widget.suggestionTrailingBuilder!(
                  context, _suggestions.value[index]),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _suggestions.dispose();
    _selectedSuggestions.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (_selectedSuggestions.value >= 0 &&
        _selectedSuggestions.value < _suggestions.value.length) {
      // A suggestion is selected, use it
      widget.onSuggestionChoosen?.call(_selectedSuggestions.value);
    } else if (text.isNotEmpty) {
      // No suggestion selected, use the entered text
      widget.onSubmitted?.call(text);
    }
    _focusNode.requestFocus();
    _controller.clear();
    _selectedSuggestions.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.text,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.tab): const SelectSuggestionIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            const NextSuggestionIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            const PreviousSuggestionIntent(),
      },
      actions: {
        SelectSuggestionIntent: CallbackAction(
          onInvoke: (intent) {
            var index = _selectedSuggestions.value;
            if (index >= 0 && index < _suggestions.value.length) {
              widget.onSuggestionChoosen?.call(index);
              _controller.clear();
              _selectedSuggestions.value = -1;
            } else if (_suggestions.value.isNotEmpty) {
              _selectedSuggestions.value = 0;
            }
            return null;
          },
        ),
        NextSuggestionIntent: CallbackAction(
          onInvoke: (intent) {
            var index = _selectedSuggestions.value;
            if (index < _suggestions.value.length - 1) {
              _selectedSuggestions.value = index + 1;
            } else if (_suggestions.value.isNotEmpty) {
              _selectedSuggestions.value = 0;
            }
            return null;
          },
        ),
        PreviousSuggestionIntent: CallbackAction(
          onInvoke: (intent) {
            var index = _selectedSuggestions.value;
            if (index > 0) {
              _selectedSuggestions.value = index - 1;
            } else if (_suggestions.value.isNotEmpty) {
              _selectedSuggestions.value = _suggestions.value.length - 1;
            }
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        child: AnimatedBuilder(
          animation: _focusNode,
          builder: (context, child) {
            Widget inputField = _buildInputField();

            if (widget.chips.isNotEmpty) {
              if (_focusNode.hasFocus) {
                inputField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    inputField,
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                        right: 6,
                        bottom: 4,
                      ),
                      child: Wrap(
                        runSpacing: 4,
                        spacing: 4,
                        children: [
                          for (int i = 0; i < widget.chips.length; i++)
                            _chipBuilder(i),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                inputField = Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    Visibility(
                      visible: false,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainInteractivity: true,
                      maintainSize: true,
                      maintainSemantics: true,
                      child: inputField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Wrap(
                        runSpacing: 4,
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (int i = 0; i < widget.chips.length; i++)
                            _chipBuilder(i),
                          if (_controller.text.isNotEmpty) const Gap(4),
                          if (_controller.text.isNotEmpty)
                            Text(_controller.text),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: _focusNode.hasFocus ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: inputField),
                  if (widget.inputTrailingWidget != null) ...[
                    const VerticalDivider(
                      indent: 10,
                      endIndent: 10,
                    ),
                    widget.inputTrailingWidget!,
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return InputTextField(
      controller: _controller,
      focusNode: _focusNode,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      enabled: widget.enabled,
      maxLines: 1,
      hintText: widget.placeholder != null ? '' : null,
      onFieldSubmitted: _handleSubmitted,
    );
  }
}

class SelectSuggestionIntent extends Intent {
  const SelectSuggestionIntent();
}

class NextSuggestionIntent extends Intent {
  const NextSuggestionIntent();
}

class PreviousSuggestionIntent extends Intent {
  const PreviousSuggestionIntent();
}
