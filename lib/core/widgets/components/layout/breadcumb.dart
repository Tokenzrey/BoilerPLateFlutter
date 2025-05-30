import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  /// Default separator: panah kecil “>”
  static const Widget arrowSeparator = _ArrowSeparator();

  /// Separator garis miring “/”
  static const Widget slashSeparator = _SlashSeparator();

  /// List item pada breadcrumb (biasanya Text widgets)
  final List<Widget> children;

  /// Separator yang ingin dipakai (panah atau slash)
  final Widget separator;

  const Breadcrumb({
    super.key,
    required this.children,
    this.separator = arrowSeparator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Style “muted small” untuk semua teks breadcrumb
    final TextStyle itemStyle = theme.textTheme.bodySmall!
        .copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6));

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DefaultTextStyle(
          style: itemStyle,
          child: Row(
            children: _buildItems(context, theme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context, ThemeData theme) {
    final style = DefaultTextStyle.of(context).style;
    if (children.length == 1) {
      return [
        _styledItem(children[0], style, isLast: true),
      ];
    }

    final List<Widget> row = [];
    for (var i = 0; i < children.length; i++) {
      final isLast = i == children.length - 1;
      row.add(_styledItem(children[i], style, isLast: isLast));
      if (!isLast) {
        row.add(separator);
      }
    }
    return row;
  }

  Widget _styledItem(Widget item, TextStyle style, {required bool isLast}) {
    // Jika item adalah Text, apply style & foreground
    if (item is Text) {
      return Text(
        item.data ?? '',
        style: style.copyWith(
          color: isLast
              ? style.color!
                  .withValues(alpha: 1.0) // full opacity untuk terakhir
              : style.color,
          fontWeight: isLast ? FontWeight.w600 : style.fontWeight,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    // Jika bukan Text, bungkus saja
    return item;
  }
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
