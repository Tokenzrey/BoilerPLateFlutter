import 'package:flutter/material.dart';

class CollapsibleTheme {
  final EdgeInsets? triggerPadding;
  final IconData expandedIcon;
  final IconData collapsedIcon;
  final double iconGap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final TextStyle? textButtonStyle;
  final Duration animationDuration;

  const CollapsibleTheme({
    this.triggerPadding,
    this.expandedIcon = Icons.keyboard_arrow_up,
    this.collapsedIcon = Icons.keyboard_arrow_down,
    this.iconGap = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textButtonStyle,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  CollapsibleTheme copyWith({
    EdgeInsets? triggerPadding,
    IconData? expandedIcon,
    IconData? collapsedIcon,
    double? iconGap,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    TextStyle? textButtonStyle,
    Duration? animationDuration,
  }) {
    return CollapsibleTheme(
      triggerPadding: triggerPadding ?? this.triggerPadding,
      expandedIcon: expandedIcon ?? this.expandedIcon,
      collapsedIcon: collapsedIcon ?? this.collapsedIcon,
      iconGap: iconGap ?? this.iconGap,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      textButtonStyle: textButtonStyle ?? this.textButtonStyle,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

class AppCollapsible extends StatefulWidget {
  final List<Widget> children;
  final bool initialExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final CollapsibleTheme? theme;
  const AppCollapsible({
    super.key,
    required this.children,
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.theme,
  });

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible> {
  late bool _isExpanded;
  late final CollapsibleTheme _effectiveTheme;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _effectiveTheme = widget.theme ?? const CollapsibleTheme();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CollapsibleScope(
      isExpanded: _isExpanded,
      toggleExpanded: _toggleExpanded,
      theme: _effectiveTheme,
      child: Column(
        crossAxisAlignment: _effectiveTheme.crossAxisAlignment,
        mainAxisAlignment: _effectiveTheme.mainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: widget.children,
      ),
    );
  }
}

class AppCollapsibleTrigger extends StatelessWidget {
  final Widget child;
  final bool showIcon;
  final EdgeInsets? padding;
  final String? tooltip;

  const AppCollapsibleTrigger({
    super.key,
    required this.child,
    this.showIcon = true,
    this.padding,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final scope = _CollapsibleScope.of(context);
    final theme = scope.theme;
    final effectivePadding = padding ?? theme.triggerPadding ?? EdgeInsets.zero;

    return InkWell(
      onTap: scope.toggleExpanded,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: effectivePadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: child),
            if (showIcon) ...[
              SizedBox(width: theme.iconGap),
              Tooltip(
                message: tooltip ?? (scope.isExpanded ? 'Collapse' : 'Expand'),
                child: Icon(
                  scope.isExpanded ? theme.expandedIcon : theme.collapsedIcon,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppCollapsibleContent extends StatelessWidget {
  final Widget child;
  final bool collapsible;
  final bool animate;

  const AppCollapsibleContent({
    super.key,
    required this.child,
    this.collapsible = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final scope = _CollapsibleScope.of(context);

    if (!collapsible) {
      return child;
    }

    if (!scope.isExpanded && !animate) {
      return const SizedBox.shrink();
    }

    return AnimatedSizeAndFade(
      vsync: Scaffold.of(context),
      duration: scope.theme.animationDuration,
      child: scope.isExpanded ? child : const SizedBox.shrink(),
    );
  }
}

class AppExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String expandText;
  final String collapseText;
  final bool initialExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final CollapsibleTheme? theme;

  const AppExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    this.expandText = 'Read more',
    this.collapseText = 'Read less',
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.theme,
  });

  @override
  State<AppExpandableText> createState() => _AppExpandableTextState();
}

class _AppExpandableTextState extends State<AppExpandableText> {
  bool _isExpanded = false;
  late final TextSpan _textSpan;
  bool _hasOverflow = false;
  late final CollapsibleTheme _effectiveTheme;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _effectiveTheme = widget.theme ?? const CollapsibleTheme();
    _textSpan = TextSpan(text: widget.text, style: widget.style);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textStyle = widget.style ?? defaultTextStyle.style;
    final buttonStyle = _effectiveTheme.textButtonStyle ??
        textStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: _textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        _hasOverflow = textPainter.didExceedMaxLines;

        if (!_hasOverflow) {
          return Text(
            widget.text,
            style: textStyle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                widget.text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
              secondChild: Text(
                widget.text,
                style: textStyle,
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: _effectiveTheme.animationDuration,
            ),
            GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _isExpanded ? widget.collapseText : widget.expandText,
                  style: buttonStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AppCollapsibleSection extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool initialExpanded;
  final IconData? collapsedIcon;
  final IconData? expandedIcon;
  final ValueChanged<bool>? onExpansionChanged;

  const AppCollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.initialExpanded = false,
    this.collapsedIcon,
    this.expandedIcon,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCollapsible(
      initialExpanded: initialExpanded,
      onExpansionChanged: onExpansionChanged,
      theme: collapsedIcon != null || expandedIcon != null
          ? CollapsibleTheme(
              collapsedIcon: collapsedIcon ?? Icons.keyboard_arrow_down,
              expandedIcon: expandedIcon ?? Icons.keyboard_arrow_up,
            )
          : null,
      children: [
        AppCollapsibleTrigger(child: title),
        AppCollapsibleContent(
          animate: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: content,
          ),
        ),
      ],
    );
  }
}

class _CollapsibleScope extends InheritedWidget {
  final bool isExpanded;
  final VoidCallback toggleExpanded;
  final CollapsibleTheme theme;

  const _CollapsibleScope({
    required this.isExpanded,
    required this.toggleExpanded,
    required this.theme,
    required super.child,
  });

  static _CollapsibleScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_CollapsibleScope>();
    assert(scope != null, 'No _CollapsibleScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(_CollapsibleScope oldWidget) {
    return isExpanded != oldWidget.isExpanded || theme != oldWidget.theme;
  }
}

class AnimatedSizeAndFade extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final TickerProvider vsync;

  const AnimatedSizeAndFade({
    super.key,
    required this.child,
    required this.duration,
    this.curve = Curves.easeInOut,
    required this.vsync,
  });

  @override
  State<AnimatedSizeAndFade> createState() => _AnimatedSizeAndFadeState();
}

class _AnimatedSizeAndFadeState extends State<AnimatedSizeAndFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: widget.vsync,
      duration: widget.duration,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0),
    );

    if (widget.child is! SizedBox || (widget.child as SizedBox).width != 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedSizeAndFade oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child is SizedBox && (widget.child as SizedBox).width == 0) {
      _controller.reverse();
    } else if (oldWidget.child is SizedBox &&
        (oldWidget.child as SizedBox).width == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
