// class PaginationShowcasePage extends StatefulWidget {
//   const PaginationShowcasePage({super.key});

//   @override
//   State<PaginationShowcasePage> createState() => _PaginationShowcasePageState();
// }

// class _PaginationShowcasePageState extends State<PaginationShowcasePage> {
//   final Map<String, int> currentPages = {
//     'basic': 1,
//     'compact': 1,
//     'large': 1,
//     'vertical': 1,
//     'iconOnly': 1,
//     'custom': 1,
//     'configured': 1,
//   };

//   void _setPage(String key, int page) {
//     setState(() => currentPages[key] = page);
//   }

//   Widget _buildSection(String title, Widget child) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         child,
//       ]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pagination Examples')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildSection(
//               "Basic Pagination",
//               Pagination(
//                 currentPage: currentPages['basic']!,
//                 totalPages: 5,
//                 onPageChanged: (p) => _setPage('basic', p),
//               ),
//             ),
//             _buildSection(
//               "Compact Pagination for Mobile",
//               Pagination(
//                 currentPage: currentPages['compact']!,
//                 totalPages: 3,
//                 size: PaginationSize.small,
//                 showLabels: false,
//                 onPageChanged: (p) => _setPage('compact', p),
//               ),
//             ),
//             _buildSection(
//               "Large Pagination with Many Pages",
//               Pagination(
//                 currentPage: currentPages['large']!,
//                 totalPages: 25,
//                 size: PaginationSize.large,
//                 maxPages: 7,
//                 onPageChanged: (p) => _setPage('large', p),
//               ),
//             ),
//             _buildSection(
//               "Vertical Pagination",
//               Pagination(
//                 currentPage: currentPages['vertical']!,
//                 totalPages: 8,
//                 direction: Axis.vertical,
//                 onPageChanged: (p) => _setPage('vertical', p),
//               ),
//             ),
//             _buildSection(
//               "Icon-Only Pagination",
//               Pagination(
//                 currentPage: currentPages['iconOnly']!,
//                 totalPages: 10,
//                 showLabels: false,
//                 onPageChanged: (p) => _setPage('iconOnly', p),
//               ),
//             ),
//             _buildSection(
//               "Custom Themed Pagination",
//               Pagination(
//                 currentPage: currentPages['custom']!,
//                 totalPages: 12,
//                 onPageChanged: (p) => _setPage('custom', p),
//                 theme: PaginationTheme(
//                   activeColor: Colors.purple,
//                   activeBackgroundColor: Colors.purple.withOpacity(0.1),
//                   textColor: Colors.black,
//                   disabledColor: Colors.grey,
//                   borderColor: Colors.purpleAccent,
//                   iconColor: Colors.purple,
//                   ghostBackgroundColor: Colors.transparent,
//                   ghostHoverColor: Colors.purple.withOpacity(0.05),
//                   textStyle: const TextStyle(fontSize: 14),
//                 ),
//               ),
//             ),
//             _buildSection(
//               "Pagination with Custom Configuration",
//               Pagination(
//                 currentPage: currentPages['configured']!,
//                 totalPages: 9,
//                 maxPages: 3,
//                 showSkipToFirstPage: false,
//                 showSkipToLastPage: false,
//                 showLabels: true,
//                 showTotalPages: true,
//                 onPageChanged: (p) => _setPage('configured', p),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:math';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int maxPages;
  final bool showLabels;
  final bool hideNextOnLastPage;
  final bool hidePrevOnFirstPage;
  final bool showSkipToFirstPage;
  final bool showSkipToLastPage;
  final bool showTotalPages;
  final PaginationSize size;
  final String? nextLabel;
  final String? previousLabel;
  final PaginationTheme? theme;
  final Axis direction;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxPages = 5,
    this.showLabels = true,
    this.hideNextOnLastPage = false,
    this.hidePrevOnFirstPage = false,
    this.showSkipToFirstPage = true,
    this.showSkipToLastPage = true,
    this.showTotalPages = false,
    this.size = PaginationSize.medium,
    this.nextLabel,
    this.previousLabel,
    this.theme,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? PaginationTheme.fromContext(context);

    final visiblePageButtons = _calculateVisiblePages();

    final isFirstPage = currentPage == 1;
    final isLastPage = currentPage == totalPages;

    final needStartDots = visiblePageButtons.isNotEmpty &&
        visiblePageButtons.first > 1 &&
        totalPages > maxPages;

    final needEndDots = visiblePageButtons.isNotEmpty &&
        visiblePageButtons.last < totalPages &&
        totalPages > maxPages;

    final items = <Widget>[];

    if (showSkipToFirstPage && !isFirstPage && totalPages > 2) {
      items.add(
        PaginationButton(
          onPressed: () => onPageChanged(1),
          type: PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: const Icon(Icons.first_page, size: 16),
        ),
      );

      items.add(_buildSpacer());
    }

    if (!(isFirstPage && hidePrevOnFirstPage)) {
      items.add(
        PaginationButton(
          onPressed: isFirstPage ? null : () => onPageChanged(currentPage - 1),
          type: PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: _buildPrevLabel(context, effectiveTheme),
        ),
      );

      items.add(_buildSpacer());
    }

    if (needStartDots) {
      items.add(
        PaginationButton(
          onPressed: () => onPageChanged(1),
          type: 1 == currentPage
              ? PaginationButtonType.outline
              : PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: Text("1"),
        ),
      );

      items.add(
        MoreDots(direction: direction, theme: effectiveTheme),
      );
    }

    for (final pageNum in visiblePageButtons) {
      items.add(
        PaginationButton(
          onPressed:
              pageNum == currentPage ? null : () => onPageChanged(pageNum),
          type: pageNum == currentPage
              ? PaginationButtonType.outline
              : PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          active: pageNum == currentPage,
          child: Text(pageNum.toString()),
        ),
      );

      if (pageNum != visiblePageButtons.last) {
        items.add(_buildSpacer(small: true));
      }
    }

    if (needEndDots) {
      items.add(
        MoreDots(direction: direction, theme: effectiveTheme),
      );

      items.add(
        PaginationButton(
          onPressed: () => onPageChanged(totalPages),
          type: totalPages == currentPage
              ? PaginationButtonType.outline
              : PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: Text(totalPages.toString()),
        ),
      );
    }

    items.add(_buildSpacer());

    if (!(isLastPage && hideNextOnLastPage)) {
      items.add(
        PaginationButton(
          onPressed: isLastPage ? null : () => onPageChanged(currentPage + 1),
          type: PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: _buildNextLabel(context, effectiveTheme),
        ),
      );
    }

    if (showSkipToLastPage && !isLastPage && totalPages > 2) {
      items.add(_buildSpacer());

      items.add(
        PaginationButton(
          onPressed: () => onPageChanged(totalPages),
          type: PaginationButtonType.ghost,
          size: size,
          theme: effectiveTheme,
          child: const Icon(Icons.last_page, size: 16),
        ),
      );
    }
    if (showTotalPages && totalPages > 1) {
      items.add(_buildSpacer());

      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "of $totalPages",
            style: effectiveTheme.textStyle,
          ),
        ),
      );
    }

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }
  }

  Widget _buildSpacer({bool small = false}) {
    return SizedBox(
      width: direction == Axis.horizontal ? (small ? 4.0 : 8.0) : 0,
      height: direction == Axis.vertical ? (small ? 4.0 : 8.0) : 0,
    );
  }

  Widget _buildPrevLabel(BuildContext context, PaginationTheme theme) {
    final label = previousLabel ?? "Previous";

    return showLabels
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, size: 16, color: theme.iconColor),
              const SizedBox(width: 4),
              Text(label),
            ],
          )
        : Icon(Icons.chevron_left, color: theme.iconColor);
  }

  Widget _buildNextLabel(BuildContext context, PaginationTheme theme) {
    final label = nextLabel ?? "Next";

    return showLabels
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: theme.iconColor),
            ],
          )
        : Icon(Icons.chevron_right, color: theme.iconColor);
  }

  List<int> _calculateVisiblePages() {
    if (totalPages <= maxPages) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final halfMax = maxPages ~/ 2;

    int startPage = max(1, currentPage - halfMax);
    int endPage = min(totalPages, startPage + maxPages - 1);

    if (endPage - startPage < maxPages - 1) {
      startPage = max(1, endPage - maxPages + 1);
    }

    return List.generate(
      min(maxPages, endPage - startPage + 1),
      (index) => startPage + index,
    );
  }
}

enum PaginationSize { small, medium, large }

enum PaginationButtonType { filled, ghost, outline }

class PaginationTheme {
  final Color activeColor;
  final Color activeBackgroundColor;
  final Color textColor;
  final Color disabledColor;
  final Color borderColor;
  final Color iconColor;
  final Color ghostBackgroundColor;
  final Color ghostHoverColor;
  final TextStyle textStyle;

  const PaginationTheme({
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.textColor,
    required this.disabledColor,
    required this.borderColor,
    required this.iconColor,
    required this.ghostBackgroundColor,
    required this.ghostHoverColor,
    required this.textStyle,
  });

  factory PaginationTheme.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return PaginationTheme(
      activeColor: primaryColor,
      activeBackgroundColor: primaryColor.withValues(alpha: 0.1),
      textColor: theme.colorScheme.onSurface,
      disabledColor: theme.disabledColor,
      borderColor: theme.dividerColor,
      iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ghostBackgroundColor: Colors.transparent,
      ghostHoverColor: theme.hoverColor,
      textStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
    );
  }
}

class PaginationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final PaginationButtonType type;
  final PaginationSize size;
  final bool active;
  final PaginationTheme theme;

  const PaginationButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.type,
    required this.size,
    required this.theme,
    this.active = false,
  });

  @override
  State<PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<PaginationButton> {
  bool _isHovered = false;

  double get _buttonSize {
    switch (widget.size) {
      case PaginationSize.small:
        return 28.0;
      case PaginationSize.medium:
        return 36.0;
      case PaginationSize.large:
        return 44.0;
    }
  }

  EdgeInsets get _buttonPadding {
    switch (widget.size) {
      case PaginationSize.small:
        return const EdgeInsets.symmetric(horizontal: 6.0);
      case PaginationSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case PaginationSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _buttonSize,
          padding: _buttonPadding,
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDisabled),
            border: _getBorder(isDisabled),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: widget.theme.textStyle.copyWith(
                color: _getTextColor(isDisabled),
                fontWeight: widget.active ? FontWeight.bold : FontWeight.normal,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled && widget.active) {
      return widget.theme.activeBackgroundColor;
    }

    switch (widget.type) {
      case PaginationButtonType.filled:
        return isDisabled
            ? widget.theme.activeBackgroundColor.withValues(alpha: 0.5)
            : _isHovered
                ? widget.theme.activeBackgroundColor.withValues(alpha: 0.8)
                : widget.theme.activeBackgroundColor;

      case PaginationButtonType.outline:
        return _isHovered
            ? widget.theme.activeBackgroundColor.withValues(alpha: 0.2)
            : widget.theme.activeBackgroundColor.withValues(alpha: 0.1);

      case PaginationButtonType.ghost:
        return _isHovered
            ? widget.theme.ghostHoverColor
            : widget.theme.ghostBackgroundColor;
    }
  }

  Border? _getBorder(bool isDisabled) {
    switch (widget.type) {
      case PaginationButtonType.outline:
        return Border.all(
          color: isDisabled
              ? widget.theme.disabledColor
              : widget.active
                  ? widget.theme.activeColor
                  : widget.theme.borderColor,
          width: widget.active ? 1.5 : 1.0,
        );
      case PaginationButtonType.filled:
      case PaginationButtonType.ghost:
        return null;
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return widget.active
          ? widget.theme.activeColor
          : widget.theme.disabledColor;
    }

    switch (widget.type) {
      case PaginationButtonType.filled:
        return widget.theme.activeColor;
      case PaginationButtonType.outline:
        return widget.active
            ? widget.theme.activeColor
            : widget.theme.textColor;
      case PaginationButtonType.ghost:
        return widget.active
            ? widget.theme.activeColor
            : widget.theme.textColor;
    }
  }
}

class MoreDots extends StatelessWidget {
  final Axis direction;
  final PaginationTheme theme;

  const MoreDots({
    super.key,
    required this.direction,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "...",
        style: theme.textStyle.copyWith(
          color: theme.disabledColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
