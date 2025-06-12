import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A breadcrumb item with customization options
class BreadcrumbItem {
  /// The label text to display
  final String? text;

  /// Custom widget to display instead of text
  final Widget? child;

  /// Icon to display before the text
  final IconData? icon;

  /// Whether this item is active (usually the last one)
  final bool isActive;

  /// Custom style for this specific item
  final TextStyle? style;

  /// Color for the icon
  final Color? iconColor;

  /// Size for the icon
  final double? iconSize;

  /// Spacing between icon and text
  final double iconSpacing;

  /// Called when this item is tapped
  final VoidCallback? onTap;

  /// Tooltip to show on hover
  final String? tooltip;

  /// Creates a breadcrumb item with text
  BreadcrumbItem.text(
    String this.text, {
    this.icon,
    this.isActive = false,
    this.style,
    this.iconColor,
    this.iconSize,
    this.iconSpacing = 4,
    this.onTap,
    this.tooltip,
  }) : child = null;

  /// Creates a breadcrumb item with a custom widget
  BreadcrumbItem.widget({
    required Widget this.child,
    this.icon,
    this.isActive = false,
    this.iconColor,
    this.iconSize,
    this.iconSpacing = 4,
    this.onTap,
    this.tooltip,
  })  : text = null,
        style = null;

  /// Creates a breadcrumb item from a string
  factory BreadcrumbItem(String text) => BreadcrumbItem.text(text);
}

/// Configuration options for the Breadcrumb widget
class BreadcrumbStyle {
  /// Text style for regular breadcrumb items
  final TextStyle? itemStyle;

  /// Text style for the active (last) breadcrumb item
  final TextStyle? activeItemStyle;

  /// Background color for regular items
  final Color? itemBackgroundColor;

  /// Background color for active items
  final Color? activeItemBackgroundColor;

  /// Padding around each item
  final EdgeInsetsGeometry? itemPadding;

  /// Border radius for items
  final BorderRadius? itemBorderRadius;

  /// Color for item borders
  final Color? itemBorderColor;

  /// Width for item borders
  final double? itemBorderWidth;

  /// Spacing between items (excluding separator)
  final double? itemSpacing;

  /// Color for the separator
  final Color? separatorColor;

  /// Size for the separator
  final double? separatorSize;

  /// Padding around separators
  final EdgeInsetsGeometry? separatorPadding;

  const BreadcrumbStyle({
    this.itemStyle,
    this.activeItemStyle,
    this.itemBackgroundColor,
    this.activeItemBackgroundColor,
    this.itemPadding,
    this.itemBorderRadius,
    this.itemBorderColor,
    this.itemBorderWidth,
    this.itemSpacing,
    this.separatorColor,
    this.separatorSize,
    this.separatorPadding,
  });
}

/// A breadcrumb navigation widget with customizable items and separators
class Breadcrumb extends StatelessWidget {
  // Default separator: >"
  static const Widget arrowSeparator = _ArrowSeparator();
  static const Widget slashSeparator = _SlashSeparator();

  /// A list of breadcrumb items to display
  final List<BreadcrumbItem>? items;

  /// A list of widgets to display (legacy API)
  final List<Widget>? children;

  /// The separator widget between items
  final Widget separator;

  /// Custom styling for the breadcrumb
  final BreadcrumbStyle? style;

  /// Maximum items to show before collapsing
  final int? maxVisibleItems;

  /// How to handle overflowing items
  final OverflowBehavior overflowBehavior;

  /// Function to build custom item widgets
  final Widget Function(BuildContext, BreadcrumbItem, bool)? itemBuilder;

  /// Function to build custom separator widgets
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Whether to enable horizontal scrolling
  final bool enableScrolling;

  /// How to align the breadcrumb within its container
  final MainAxisAlignment alignment;

  /// Creates a breadcrumb navigation widget
  const Breadcrumb({
    super.key,
    this.items,
    this.children,
    this.separator = arrowSeparator,
    this.style,
    this.maxVisibleItems,
    this.overflowBehavior = OverflowBehavior.scroll,
    this.itemBuilder,
    this.separatorBuilder,
    this.enableScrolling = true,
    this.alignment = MainAxisAlignment.start,
  }) : assert(items != null || children != null,
            'Either items or children must be provided');

  /// Creates a breadcrumb with string items
  Breadcrumb.fromStrings({
    super.key,
    required List<String> labels,
    this.separator = arrowSeparator,
    this.style,
    this.maxVisibleItems,
    this.overflowBehavior = OverflowBehavior.scroll,
    this.itemBuilder,
    this.separatorBuilder,
    this.enableScrolling = true,
    this.alignment = MainAxisAlignment.start,
    List<VoidCallback?>? onTapActions,
  })  : items = List.generate(
          labels.length,
          (index) => BreadcrumbItem.text(
            labels[index],
            isActive: index == labels.length - 1,
            onTap: onTapActions != null && index < onTapActions.length
                ? onTapActions[index]
                : null,
          ),
        ),
        children = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle defaultItemStyle = style?.itemStyle ??
        theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6));

    final TextStyle defaultActiveStyle = style?.activeItemStyle ??
        defaultItemStyle.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 1.0),
          fontWeight: FontWeight.w600,
        );

    Widget content = DefaultTextStyle(
      style: defaultItemStyle,
      child: Row(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: _buildItems(context, defaultItemStyle, defaultActiveStyle),
      ),
    );

    if (enableScrolling) {
      content = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: content,
        ),
      );
    }

    return content;
  }

  List<Widget> _buildItems(
    BuildContext context,
    TextStyle defaultStyle,
    TextStyle activeStyle,
  ) {
    // Handle legacy children API
    if (items == null && children != null) {
      if (children!.length == 1) {
        return [
          _styledLegacyItem(children![0], defaultStyle,
              isLast: true, activeStyle: activeStyle),
        ];
      }

      final List<Widget> row = [];
      for (var i = 0; i < children!.length; i++) {
        final isLast = i == children!.length - 1;
        row.add(_styledLegacyItem(
          children![i],
          defaultStyle,
          isLast: isLast,
          activeStyle: activeStyle,
        ));
        if (!isLast) {
          row.add(separatorBuilder != null
              ? separatorBuilder!(context, i)
              : separator);
        }
      }
      return row;
    }

    // Handle new BreadcrumbItem API
    if (items == null || items!.isEmpty) return [];

    if (items!.length == 1) {
      return [_buildItemWidget(context, items![0], true)];
    }

    List<BreadcrumbItem> visibleItems = items!;

    // Handle overflow behavior if maxVisibleItems is specified
    if (maxVisibleItems != null &&
        items!.length > maxVisibleItems! &&
        overflowBehavior == OverflowBehavior.ellipsis) {
      // Keep first item, add ellipsis, then show the last (maxVisibleItems-2) items
      visibleItems = [
        items!.first,
        BreadcrumbItem.widget(
          child: const Text('...'),
          onTap: () {
            // Could show a dropdown with all items here
          },
        ),
        ...items!.skip(items!.length - (maxVisibleItems! - 1)),
      ];
    }

    final List<Widget> row = [];
    for (var i = 0; i < visibleItems.length; i++) {
      final isLast = i == visibleItems.length - 1;
      final item = visibleItems[i];

      row.add(_buildItemWidget(context, item, isLast));

      if (!isLast) {
        // Add separator between items
        row.add(separatorBuilder != null
            ? separatorBuilder!(context, i)
            : _buildSeparator(context, i));
      }
    }

    return row;
  }

  Widget _buildItemWidget(
      BuildContext context, BreadcrumbItem item, bool isLast) {
    // Use custom item builder if provided
    if (itemBuilder != null) {
      return itemBuilder!(context, item, isLast);
    }

    // Default style from theme
    final defaultStyle = DefaultTextStyle.of(context).style;

    // Item-specific style overrides
    final TextStyle itemStyle = item.style ??
        (item.isActive || isLast
            ? (style?.activeItemStyle ??
                defaultStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: defaultStyle.color?.withValues(alpha: 1.0),
                ))
            : (style?.itemStyle ?? defaultStyle));

    // Background color
    final Color? backgroundColor = item.isActive || isLast
        ? style?.activeItemBackgroundColor
        : style?.itemBackgroundColor;

    // Border
    BoxBorder? border;
    if (style?.itemBorderColor != null) {
      border = Border.all(
        color: style!.itemBorderColor!,
        width: style?.itemBorderWidth ?? 1.0,
      );
    }

    // Content widget (text or custom child)
    Widget content;
    if (item.child != null) {
      content = item.child!;
    } else {
      // Build content with optional icon
      List<Widget> contentParts = [];

      if (item.icon != null) {
        contentParts.add(
          Icon(
            item.icon,
            size: item.iconSize ?? 14,
            color: item.iconColor ?? itemStyle.color,
          ),
        );
        contentParts.add(SizedBox(width: item.iconSpacing));
      }

      contentParts.add(
        Flexible(
          child: Text(
            item.text ?? '',
            style: itemStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: contentParts,
      );
    }

    // Add padding if specified
    if (style?.itemPadding != null) {
      content = Padding(
        padding: style!.itemPadding!,
        child: content,
      );
    }

    // Add background/border if needed
    if (backgroundColor != null || border != null) {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: style?.itemBorderRadius,
        ),
        child: content,
      );
    }

    // Add tap handler if specified
    if (item.onTap != null) {
      content = InkWell(
        onTap: item.onTap,
        borderRadius: style?.itemBorderRadius,
        child: content,
      );
    }

    // Add tooltip if specified
    if (item.tooltip != null) {
      content = Tooltip(
        message: item.tooltip!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildSeparator(BuildContext context, int index) {
    // Use the provided separator
    if (style?.separatorPadding != null) {
      return Padding(
        padding: style!.separatorPadding!,
        child: separator,
      );
    }
    return separator;
  }

  Widget _styledLegacyItem(
    Widget item,
    TextStyle style, {
    required bool isLast,
    required TextStyle activeStyle,
  }) {
    if (item is Text) {
      return Text(
        item.data ?? '',
        style: isLast ? activeStyle : style,
        overflow: TextOverflow.ellipsis,
      );
    }
    return item;
  }
}

/// Defines how to handle breadcrumb items that overflow available space
enum OverflowBehavior {
  /// Allow horizontal scrolling (default)
  scroll,

  /// Show ellipsis to indicate hidden items
  ellipsis,

  /// Wrap to a new line (requires a Column parent)
  wrap,
}

class _ArrowSeparator extends StatelessWidget {
  const _ArrowSeparator();

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: muted,
      ),
    );
  }
}

class _SlashSeparator extends StatelessWidget {
  const _SlashSeparator();

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '/',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: muted),
      ),
    );
  }
}

/// Extra separator options for convenience
class BreadcrumbSeparators {
  /// A forward slash separator (/)
  static const Widget slash = _SlashSeparator();

  /// A right arrow separator (>)
  static const Widget arrow = _ArrowSeparator();

  /// A dot separator (•)
  static Widget dot(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(color: muted),
      ),
    );
  }

  /// A custom text separator with default styling
  static Widget text(BuildContext context, String separator) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        separator,
        style: TextStyle(color: muted),
      ),
    );
  }

  /// A custom icon separator with default styling
  static Widget icon(BuildContext context, IconData icon, {double size = 16}) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        icon,
        size: size,
        color: muted,
      ),
    );
  }
}
