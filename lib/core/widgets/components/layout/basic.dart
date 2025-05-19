import 'package:flutter/material.dart';

class Basic extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? content;
  final Widget? trailing;
  final AlignmentGeometry? leadingAlignment;
  final AlignmentGeometry? trailingAlignment;
  final AlignmentGeometry? titleAlignment;
  final AlignmentGeometry? subtitleAlignment;
  final AlignmentGeometry? contentAlignment;
  final double? contentSpacing;
  final double? titleSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const Basic({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.content,
    this.trailing,
    this.leadingAlignment,
    this.trailingAlignment,
    this.titleAlignment,
    this.subtitleAlignment,
    this.contentAlignment,
    this.contentSpacing, // 16
    this.titleSpacing, //4
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null)
                Align(
                  alignment: leadingAlignment ?? Alignment.topCenter,
                  child: leading!,
                ),
              if (leading != null &&
                  (title != null || content != null || subtitle != null))
                SizedBox(width: contentSpacing ?? (16)),
              if (title != null || content != null || subtitle != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: mainAxisAlignment,
                    children: [
                      if (title != null)
                        DefaultTextStyle.merge(
                          child: Align(
                            alignment: titleAlignment ?? Alignment.topLeft,
                            child: title!,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: theme.textTheme.labelMedium?.fontWeight,
                          ),
                        ),
                      if (title != null && subtitle != null)
                        SizedBox(height: 2),
                      if (subtitle != null)
                        DefaultTextStyle.merge(
                          child: Align(
                            alignment: titleAlignment ?? Alignment.topLeft,
                            child: subtitle!,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.surfaceContainer,
                          ),
                        ),
                      if ((title != null || subtitle != null) &&
                          content != null)
                        SizedBox(height: titleSpacing),
                      if (content != null)
                        DefaultTextStyle.merge(
                          child: Align(
                            alignment: titleAlignment ?? Alignment.topLeft,
                            child: subtitle!,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              if (trailing != null &&
                  (title != null ||
                      content != null ||
                      leading != null ||
                      subtitle != null))
                SizedBox(width: contentSpacing ?? (16)),
              // if (trailing != null) trailing!,
              if (trailing != null)
                Align(
                  alignment: trailingAlignment ?? Alignment.topCenter,
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same as basic, but without forcing the text style
class BasicLayout extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? content;
  final Widget? trailing;
  final AlignmentGeometry? leadingAlignment;
  final AlignmentGeometry? trailingAlignment;
  final AlignmentGeometry? titleAlignment;
  final AlignmentGeometry? subtitleAlignment;
  final AlignmentGeometry? contentAlignment;
  final double? contentSpacing;
  final double? titleSpacing;
  final BoxConstraints? constraints;

  const BasicLayout({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.content,
    this.trailing,
    this.leadingAlignment,
    this.trailingAlignment,
    this.titleAlignment,
    this.subtitleAlignment,
    this.contentAlignment,
    this.contentSpacing,
    this.titleSpacing,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null)
          Align(
            alignment: leadingAlignment ?? Alignment.topCenter,
            child: leading!,
          ),
        if (leading != null &&
            (title != null || content != null || subtitle != null))
          SizedBox(width: contentSpacing ?? (16)),
        if (title != null || content != null || subtitle != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Align(
                    alignment: titleAlignment ?? Alignment.topLeft,
                    child: title!,
                  ),
                if (title != null && subtitle != null) SizedBox(height: 2),
                if (subtitle != null)
                  Align(
                    alignment: subtitleAlignment ?? Alignment.topLeft,
                    child: subtitle!,
                  ),
                if ((title != null || subtitle != null) && content != null)
                  SizedBox(height: titleSpacing ?? (4)),
                if (content != null)
                  Align(
                    alignment: contentAlignment ?? Alignment.topLeft,
                    child: content!,
                  ),
              ],
            ),
          ),
        if (trailing != null &&
            (title != null ||
                content != null ||
                leading != null ||
                subtitle != null))
          SizedBox(width: contentSpacing ?? (16)),
        if (trailing != null)
          Align(
            alignment: trailingAlignment ?? Alignment.topCenter,
            child: trailing!,
          ),
      ],
    );
  }
}

class Label extends StatelessWidget {
  final Widget? leading;
  final Widget child;
  final Widget? trailing;

  const Label({
    super.key,
    this.leading,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) leading!,
          if (leading != null) SizedBox(width: 8),
          Expanded(child: child),
          if (trailing != null) SizedBox(width: 8),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
