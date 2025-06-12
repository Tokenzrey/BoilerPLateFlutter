import 'package:flutter/material.dart';
import 'dart:math';

/// A customizable pagination widget with extensive styling and builder options.
class Pagination extends StatelessWidget {
  /// The current page number (1-based index).
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Callback function when page is changed.
  final Function(int) onPageChanged;

  /// Maximum number of page buttons to display (excluding first/last/navigation).
  final int maxPages;

  /// Whether to show text labels for next/previous buttons.
  final bool showLabels;

  /// Hide the next button when on the last page.
  final bool hideNextOnLastPage;

  /// Hide the previous button when on the first page.
  final bool hidePrevOnFirstPage;

  /// Show a button to navigate to the first page.
  final bool showSkipToFirstPage;

  /// Show a button to navigate to the last page.
  final bool showSkipToLastPage;

  /// Show total pages indicator.
  final bool showTotalPages;

  /// Size preset for pagination buttons.
  final PaginationSize size;

  /// Custom text for the next button.
  final String? nextLabel;

  /// Custom text for the previous button.
  final String? previousLabel;

  /// Theme configuration for the pagination.
  final PaginationTheme? theme;

  /// Direction of pagination layout (horizontal or vertical).
  final Axis direction;

  /// Custom builder for page number buttons.
  final Widget Function(BuildContext, int, bool, VoidCallback?)?
      pageButtonBuilder;

  /// Custom builder for the previous button.
  final Widget Function(BuildContext, bool, VoidCallback?)?
      previousButtonBuilder;

  /// Custom builder for the next button.
  final Widget Function(BuildContext, bool, VoidCallback?)? nextButtonBuilder;

  /// Custom builder for first page button.
  final Widget Function(BuildContext, bool, VoidCallback?)?
      firstPageButtonBuilder;

  /// Custom builder for last page button.
  final Widget Function(BuildContext, bool, VoidCallback?)?
      lastPageButtonBuilder;

  /// Custom builder for ellipsis/more dots indicator.
  final Widget Function(BuildContext)? ellipsisBuilder;

  /// Custom builder for total pages indicator.
  final Widget Function(BuildContext, int, int)? totalPagesBuilder;

  /// Additional styling for the pagination container.
  final BoxDecoration? containerDecoration;

  /// Padding around the entire pagination widget.
  final EdgeInsetsGeometry? padding;

  /// Space between pagination items.
  final double? itemSpacing;

  /// Space between icons and labels in button items.
  final double? iconLabelSpacing;

  /// Animation configuration for hover/press states.
  final Duration animationDuration;

  /// Whether to use compact layout that shows fewer items on small screens.
  final bool responsive;

  /// Widget to display when there's only one page (null hides pagination).
  final Widget? singlePageWidget;

  /// Default constructor for the Pagination widget.
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
    this.pageButtonBuilder,
    this.previousButtonBuilder,
    this.nextButtonBuilder,
    this.firstPageButtonBuilder,
    this.lastPageButtonBuilder,
    this.ellipsisBuilder,
    this.totalPagesBuilder,
    this.containerDecoration,
    this.padding,
    this.itemSpacing,
    this.iconLabelSpacing,
    this.animationDuration = const Duration(milliseconds: 150),
    this.responsive = true,
    this.singlePageWidget,
  }) : assert(totalPages > 0, 'Total pages must be greater than 0');

  /// Creates a simple numeric pagination with minimal controls.
  factory Pagination.simple({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
    int maxPages = 5,
    PaginationSize size = PaginationSize.medium,
    PaginationTheme? theme,
  }) {
    return Pagination(
      currentPage: currentPage > totalPages
          ? totalPages
          : currentPage.clamp(1, totalPages),
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      maxPages: maxPages,
      showLabels: false,
      showSkipToFirstPage: false,
      showSkipToLastPage: false,
      showTotalPages: false,
      size: size,
      theme: theme,
    );
  }

  /// Creates a compact pagination suitable for mobile.
  factory Pagination.compact({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
    PaginationTheme? theme,
  }) {
    return Pagination(
      currentPage: currentPage > totalPages
          ? totalPages
          : currentPage.clamp(1, totalPages),
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      maxPages: 3,
      showLabels: false,
      size: PaginationSize.small,
      theme: theme,
    );
  }

  /// Creates an informative pagination with page count.
  factory Pagination.withInfo({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
    PaginationTheme? theme,
  }) {
    return Pagination(
      currentPage: currentPage > totalPages
          ? totalPages
          : currentPage.clamp(1, totalPages),
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      showTotalPages: true,
      theme: theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return early if only one page and no widget provided
    if (totalPages <= 1 && singlePageWidget == null) {
      return const SizedBox.shrink();
    }

    // Show custom widget if there's only one page
    if (totalPages <= 1 && singlePageWidget != null) {
      return singlePageWidget!;
    }

    // Ensure currentPage is valid and within range
    final effectiveCurrentPage = min(max(1, currentPage), totalPages);

    final effectiveTheme = theme ?? PaginationTheme.fromContext(context);
    final effectiveItemSpacing =
        itemSpacing ?? (direction == Axis.horizontal ? 8.0 : 4.0);
    final effectiveIconLabelSpacing = iconLabelSpacing ?? 4.0;

    final visiblePageButtons = _calculateVisiblePages(effectiveCurrentPage);

    final isFirstPage = effectiveCurrentPage == 1;
    final isLastPage = effectiveCurrentPage == totalPages;

    final needStartDots = visiblePageButtons.isNotEmpty &&
        visiblePageButtons.first > 1 &&
        totalPages > maxPages;

    final needEndDots = visiblePageButtons.isNotEmpty &&
        visiblePageButtons.last < totalPages &&
        totalPages > maxPages;

    final items = <Widget>[];

    // First page button
    if (showSkipToFirstPage && !isFirstPage && totalPages > 2) {
      items.add(
        Semantics(
          button: true,
          label: 'Go to first page',
          child: _buildFirstPageButton(context, effectiveTheme, isFirstPage),
        ),
      );
      items.add(_buildSpacer(effectiveItemSpacing));
    }

    // Previous button
    if (!(isFirstPage && hidePrevOnFirstPage)) {
      items.add(
        Semantics(
          button: true,
          enabled: !isFirstPage,
          label: 'Previous page',
          child: _buildPreviousButton(
              context, effectiveTheme, isFirstPage, effectiveIconLabelSpacing),
        ),
      );
      items.add(_buildSpacer(effectiveItemSpacing));
    }

    // First page with dots if needed
    if (needStartDots) {
      items.add(
        Semantics(
          button: true,
          label: 'Page 1',
          child: _buildPageButton(context, effectiveTheme, 1, isFirstPage),
        ),
      );
      items.add(_buildSpacer(effectiveItemSpacing, small: true));
      items.add(
        Semantics(
          label: 'More pages',
          child: _buildEllipsis(context, effectiveTheme),
        ),
      );
      items.add(_buildSpacer(effectiveItemSpacing, small: true));
    }

    // Page number buttons
    for (int i = 0; i < visiblePageButtons.length; i++) {
      final pageNum = visiblePageButtons[i];
      final isActive = pageNum == effectiveCurrentPage;

      items.add(
        Semantics(
          button: true,
          selected: isActive,
          label: 'Page $pageNum${isActive ? ', current page' : ''}',
          child: _buildPageButton(context, effectiveTheme, pageNum, isActive),
        ),
      );

      if (i < visiblePageButtons.length - 1) {
        items.add(_buildSpacer(effectiveItemSpacing, small: true));
      }
    }

    // Last page with dots if needed
    if (needEndDots) {
      items.add(_buildSpacer(effectiveItemSpacing, small: true));
      items.add(
        Semantics(
          label: 'More pages',
          child: _buildEllipsis(context, effectiveTheme),
        ),
      );
      items.add(_buildSpacer(effectiveItemSpacing, small: true));
      items.add(
        Semantics(
          button: true,
          label: 'Page $totalPages',
          child:
              _buildPageButton(context, effectiveTheme, totalPages, isLastPage),
        ),
      );
    }

    items.add(_buildSpacer(effectiveItemSpacing));

    // Next button
    if (!(isLastPage && hideNextOnLastPage)) {
      items.add(
        Semantics(
          button: true,
          enabled: !isLastPage,
          label: 'Next page',
          child: _buildNextButton(
              context, effectiveTheme, isLastPage, effectiveIconLabelSpacing),
        ),
      );
    }

    // Last page button
    if (showSkipToLastPage && !isLastPage && totalPages > 2) {
      items.add(_buildSpacer(effectiveItemSpacing));
      items.add(
        Semantics(
          button: true,
          label: 'Go to last page',
          child: _buildLastPageButton(context, effectiveTheme, isLastPage),
        ),
      );
    }

    // Total pages indicator
    if (showTotalPages && totalPages > 1) {
      items.add(_buildSpacer(effectiveItemSpacing));
      items.add(
        Semantics(
          label: 'Page $effectiveCurrentPage of $totalPages',
          child:
              _buildTotalPages(context, effectiveTheme, effectiveCurrentPage),
        ),
      );
    }

    // Build the final container
    final container = direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          );

    // Apply container decoration if provided
    if (containerDecoration != null || padding != null) {
      return Container(
        decoration: containerDecoration,
        padding: padding,
        child: container,
      );
    }

    return container;
  }

  Widget _buildSpacer(double spacing, {bool small = false}) {
    final effectiveSpacing = small ? spacing / 2 : spacing;

    return direction == Axis.horizontal
        ? SizedBox(width: effectiveSpacing)
        : SizedBox(height: effectiveSpacing);
  }

  Widget _buildFirstPageButton(
      BuildContext context, PaginationTheme theme, bool isFirstPage) {
    if (firstPageButtonBuilder != null) {
      return firstPageButtonBuilder!(
        context,
        isFirstPage,
        isFirstPage ? null : () => onPageChanged(1),
      );
    }

    return PaginationButton(
      onPressed: isFirstPage ? null : () => onPageChanged(1),
      type: PaginationButtonType.ghost,
      size: size,
      theme: theme,
      animationDuration: animationDuration,
      tooltip: 'Go to first page',
      child: const Icon(Icons.first_page, size: 16),
    );
  }

  Widget _buildLastPageButton(
      BuildContext context, PaginationTheme theme, bool isLastPage) {
    if (lastPageButtonBuilder != null) {
      return lastPageButtonBuilder!(
        context,
        isLastPage,
        isLastPage ? null : () => onPageChanged(totalPages),
      );
    }

    return PaginationButton(
      onPressed: isLastPage ? null : () => onPageChanged(totalPages),
      type: PaginationButtonType.ghost,
      size: size,
      theme: theme,
      animationDuration: animationDuration,
      tooltip: 'Go to last page',
      child: const Icon(Icons.last_page, size: 16),
    );
  }

  Widget _buildPreviousButton(BuildContext context, PaginationTheme theme,
      bool isFirstPage, double iconSpacing) {
    if (previousButtonBuilder != null) {
      return previousButtonBuilder!(
        context,
        isFirstPage,
        isFirstPage ? null : () => onPageChanged(currentPage - 1),
      );
    }

    final label = previousLabel ?? "Previous";

    return PaginationButton(
      onPressed: isFirstPage ? null : () => onPageChanged(currentPage - 1),
      type: PaginationButtonType.ghost,
      size: size,
      theme: theme,
      animationDuration: animationDuration,
      tooltip: 'Previous page',
      child: showLabels
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 16, color: theme.iconColor),
                SizedBox(width: iconSpacing),
                Text(label),
              ],
            )
          : Icon(Icons.chevron_left, color: theme.iconColor),
    );
  }

  Widget _buildNextButton(BuildContext context, PaginationTheme theme,
      bool isLastPage, double iconSpacing) {
    if (nextButtonBuilder != null) {
      return nextButtonBuilder!(
        context,
        isLastPage,
        isLastPage ? null : () => onPageChanged(currentPage + 1),
      );
    }

    final label = nextLabel ?? "Next";

    return PaginationButton(
      onPressed: isLastPage ? null : () => onPageChanged(currentPage + 1),
      type: PaginationButtonType.ghost,
      size: size,
      theme: theme,
      animationDuration: animationDuration,
      tooltip: 'Next page',
      child: showLabels
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                SizedBox(width: iconSpacing),
                Icon(Icons.chevron_right, size: 16, color: theme.iconColor),
              ],
            )
          : Icon(Icons.chevron_right, color: theme.iconColor),
    );
  }

  Widget _buildPageButton(BuildContext context, PaginationTheme theme,
      int pageNumber, bool isActive) {
    if (pageButtonBuilder != null) {
      return pageButtonBuilder!(
        context,
        pageNumber,
        isActive,
        isActive ? null : () => onPageChanged(pageNumber),
      );
    }

    return PaginationButton(
      onPressed: isActive ? null : () => onPageChanged(pageNumber),
      type:
          isActive ? PaginationButtonType.outline : PaginationButtonType.ghost,
      size: size,
      theme: theme,
      active: isActive,
      animationDuration: animationDuration,
      tooltip: 'Page $pageNumber',
      child: Text(pageNumber.toString()),
    );
  }

  Widget _buildEllipsis(BuildContext context, PaginationTheme theme) {
    if (ellipsisBuilder != null) {
      return ellipsisBuilder!(context);
    }

    return MoreDots(
      direction: direction,
      theme: theme,
    );
  }

  Widget _buildTotalPages(
      BuildContext context, PaginationTheme theme, int effectiveCurrentPage) {
    if (totalPagesBuilder != null) {
      return totalPagesBuilder!(context, effectiveCurrentPage, totalPages);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "of $totalPages",
        style: theme.textStyle,
      ),
    );
  }

  List<int> _calculateVisiblePages(int effectiveCurrentPage) {
    if (totalPages <= maxPages) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final halfMax = maxPages ~/ 2;

    // Adjust start page based on current page position
    int startPage = max(1, effectiveCurrentPage - halfMax);
    int endPage = min(totalPages, startPage + maxPages - 1);

    // Adjust start page if we're near the end to ensure we show maxPages buttons
    if (endPage - startPage < maxPages - 1) {
      startPage = max(1, endPage - maxPages + 1);
    }

    return List.generate(
      min(maxPages, endPage - startPage + 1),
      (index) => startPage + index,
    );
  }
}

/// Size presets for pagination buttons
enum PaginationSize { small, medium, large }

/// Button style types for pagination
enum PaginationButtonType { filled, ghost, outline }

/// Theme configuration for pagination styling
class PaginationTheme {
  /// Color for active page button text or border
  final Color activeColor;

  /// Background color for active page buttons
  final Color activeBackgroundColor;

  /// Text color for regular page buttons
  final Color textColor;

  /// Color for disabled buttons
  final Color disabledColor;

  /// Border color for buttons with borders
  final Color borderColor;

  /// Color for icons in buttons
  final Color iconColor;

  /// Background color for ghost buttons
  final Color ghostBackgroundColor;

  /// Hover color for ghost buttons
  final Color ghostHoverColor;

  /// Background color for hover state of filled buttons
  final Color? filledHoverColor;

  /// Active text color for filled buttons
  final Color? filledActiveTextColor;

  /// Base text style for buttons
  final TextStyle textStyle;

  /// Border radius for pagination buttons
  final BorderRadius? buttonBorderRadius;

  /// Border width for buttons with borders
  final double? buttonBorderWidth;

  /// Active border width for active buttons
  final double? activeBorderWidth;

  /// Shadow for pagination buttons
  final List<BoxShadow>? buttonShadow;

  /// Vertical padding for buttons
  final double? buttonVerticalPadding;

  /// Horizontal padding for buttons
  final double? buttonHorizontalPadding;

  /// Creates a pagination theme with custom styling.
  const PaginationTheme({
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.textColor,
    required this.disabledColor,
    required this.borderColor,
    required this.iconColor,
    required this.ghostBackgroundColor,
    required this.ghostHoverColor,
    this.filledHoverColor,
    this.filledActiveTextColor,
    required this.textStyle,
    this.buttonBorderRadius,
    this.buttonBorderWidth,
    this.activeBorderWidth,
    this.buttonShadow,
    this.buttonVerticalPadding,
    this.buttonHorizontalPadding,
  });

  /// Creates a pagination theme from the current app theme.
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
      filledHoverColor: primaryColor.withValues(alpha: 0.8),
      filledActiveTextColor: theme.colorScheme.onPrimary,
      textStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      buttonBorderRadius: BorderRadius.circular(4),
      buttonBorderWidth: 1.0,
      activeBorderWidth: 1.5,
      buttonShadow: null,
    );
  }

  /// Create a copy of this theme with some properties replaced.
  PaginationTheme copyWith({
    Color? activeColor,
    Color? activeBackgroundColor,
    Color? textColor,
    Color? disabledColor,
    Color? borderColor,
    Color? iconColor,
    Color? ghostBackgroundColor,
    Color? ghostHoverColor,
    Color? filledHoverColor,
    Color? filledActiveTextColor,
    TextStyle? textStyle,
    BorderRadius? buttonBorderRadius,
    double? buttonBorderWidth,
    double? activeBorderWidth,
    List<BoxShadow>? buttonShadow,
    double? buttonVerticalPadding,
    double? buttonHorizontalPadding,
  }) {
    return PaginationTheme(
      activeColor: activeColor ?? this.activeColor,
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      textColor: textColor ?? this.textColor,
      disabledColor: disabledColor ?? this.disabledColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      ghostBackgroundColor: ghostBackgroundColor ?? this.ghostBackgroundColor,
      ghostHoverColor: ghostHoverColor ?? this.ghostHoverColor,
      filledHoverColor: filledHoverColor ?? this.filledHoverColor,
      filledActiveTextColor:
          filledActiveTextColor ?? this.filledActiveTextColor,
      textStyle: textStyle ?? this.textStyle,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonBorderWidth: buttonBorderWidth ?? this.buttonBorderWidth,
      activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      buttonVerticalPadding:
          buttonVerticalPadding ?? this.buttonVerticalPadding,
      buttonHorizontalPadding:
          buttonHorizontalPadding ?? this.buttonHorizontalPadding,
    );
  }

  /// Create a theme with dark mode colors.
  factory PaginationTheme.dark(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return PaginationTheme(
      activeColor: primaryColor,
      activeBackgroundColor: primaryColor.withValues(alpha: 0.2),
      textColor: Colors.white70,
      disabledColor: Colors.white30,
      borderColor: Colors.white24,
      iconColor: Colors.white70,
      ghostBackgroundColor: Colors.transparent,
      ghostHoverColor: Colors.white10,
      textStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70) ??
          const TextStyle(color: Colors.white70),
      buttonBorderRadius: BorderRadius.circular(4),
    );
  }

  /// Create a theme with custom brand colors.
  factory PaginationTheme.custom({
    required Color primaryColor,
    required Color textColor,
    required Color backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return PaginationTheme(
      activeColor: primaryColor,
      activeBackgroundColor: primaryColor.withValues(alpha: 0.1),
      textColor: textColor,
      disabledColor: textColor.withValues(alpha: 0.4),
      borderColor: textColor.withValues(alpha: 0.2),
      iconColor: textColor,
      ghostBackgroundColor: Colors.transparent,
      ghostHoverColor: textColor.withValues(alpha: 0.05),
      textStyle: TextStyle(color: textColor),
      buttonBorderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }
}

/// Button widget for pagination items
class PaginationButton extends StatefulWidget {
  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Widget to display inside the button
  final Widget child;

  /// Type of button to display
  final PaginationButtonType type;

  /// Size preset for the button
  final PaginationSize size;

  /// Whether this button represents the active page
  final bool active;

  /// Theme configuration
  final PaginationTheme theme;

  /// Duration for hover/press animations
  final Duration animationDuration;

  /// Optional tooltip text
  final String? tooltip;

  /// Optional padding override
  final EdgeInsetsGeometry? padding;

  /// Creates a pagination button.
  const PaginationButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.type,
    required this.size,
    required this.theme,
    this.active = false,
    this.animationDuration = const Duration(milliseconds: 150),
    this.tooltip,
    this.padding,
  });

  @override
  State<PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<PaginationButton> {
  bool _isHovered = false;
  bool _isPressed = false;

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

  EdgeInsetsGeometry get _buttonPadding {
    if (widget.padding != null) {
      return widget.padding!;
    }

    // Use theme's padding if specified
    if (widget.theme.buttonHorizontalPadding != null &&
        widget.theme.buttonVerticalPadding != null) {
      return EdgeInsets.symmetric(
        horizontal: widget.theme.buttonHorizontalPadding!,
        vertical: widget.theme.buttonVerticalPadding!,
      );
    }

    // Default padding based on size
    switch (widget.size) {
      case PaginationSize.small:
        return const EdgeInsets.symmetric(horizontal: 6.0);
      case PaginationSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case PaginationSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  BorderRadius get _borderRadius {
    return widget.theme.buttonBorderRadius ?? BorderRadius.circular(4);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    Widget buttonContent = AnimatedContainer(
      duration: widget.animationDuration,
      height: _buttonSize,
      padding: _buttonPadding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDisabled),
        border: _getBorder(isDisabled),
        borderRadius: _borderRadius,
        boxShadow:
            (_isPressed && !isDisabled) ? null : widget.theme.buttonShadow,
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
    );

    // Add press & hover effects
    buttonContent = GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        cursor:
            isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: buttonContent,
      ),
    );

    // Add tooltip if provided
    if (widget.tooltip != null) {
      buttonContent = Tooltip(
        message: widget.tooltip!,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled && widget.active) {
      return widget.theme.activeBackgroundColor;
    }

    switch (widget.type) {
      case PaginationButtonType.filled:
        if (isDisabled) {
          return widget.theme.activeBackgroundColor.withValues(alpha: 0.5);
        } else if (_isPressed) {
          return widget.theme.activeColor;
        } else if (_isHovered) {
          return widget.theme.filledHoverColor ??
              widget.theme.activeBackgroundColor.withValues(alpha: 0.8);
        } else {
          return widget.theme.activeBackgroundColor;
        }

      case PaginationButtonType.outline:
        if (_isHovered) {
          return widget.theme.activeBackgroundColor.withValues(alpha: 0.2);
        } else {
          return widget.theme.activeBackgroundColor.withValues(alpha: 0.1);
        }

      case PaginationButtonType.ghost:
        if (_isPressed) {
          return widget.theme.ghostHoverColor.withValues(alpha: 0.8);
        } else if (_isHovered) {
          return widget.theme.ghostHoverColor;
        } else {
          return widget.theme.ghostBackgroundColor;
        }
    }
  }

  Border? _getBorder(bool isDisabled) {
    final borderWidth = widget.active
        ? widget.theme.activeBorderWidth ?? 1.5
        : widget.theme.buttonBorderWidth ?? 1.0;

    switch (widget.type) {
      case PaginationButtonType.outline:
        return Border.all(
          color: isDisabled
              ? widget.theme.disabledColor
              : widget.active
                  ? widget.theme.activeColor
                  : widget.theme.borderColor,
          width: borderWidth,
        );
      case PaginationButtonType.filled:
        return Border.all(
          color: isDisabled
              ? widget.theme.disabledColor
              : widget.theme.activeColor,
          width: borderWidth,
        );
      case PaginationButtonType.ghost:
        return _isHovered || _isPressed
            ? Border.all(
                color: widget.theme.borderColor.withValues(alpha: 0.3),
                width: borderWidth,
              )
            : null;
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
        return widget.theme.filledActiveTextColor ?? widget.theme.activeColor;
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

/// Ellipsis indicator for pagination
class MoreDots extends StatelessWidget {
  /// Direction of layout
  final Axis direction;

  /// Theme configuration
  final PaginationTheme theme;

  /// Custom dot character or text
  final String dotCharacter;

  /// Creates an ellipsis indicator.
  const MoreDots({
    super.key,
    required this.direction,
    required this.theme,
    this.dotCharacter = "...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        dotCharacter,
        style: theme.textStyle.copyWith(
          color: theme.disabledColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
