import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';

class ComicSearchResultStyle {
  final Color backgroundColor;
  final Color hoverBackgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double imageWidth;
  final double imageHeight;
  final BorderRadius imageBorderRadius;
  final BoxFit imageFit;
  final TextVariant titleVariant;
  final TextStyle? titleStyle;
  final Color titleColor;
  final int titleMaxLines;
  final TextVariant subtitleVariant;
  final TextStyle? subtitleStyle;
  final Color subtitleColor;
  final int subtitleMaxLines;
  final Color highlightBackgroundColor;
  final Color highlightTextColor;
  final FontWeight highlightFontWeight;
  final double horizontalSpacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color borderColor;
  final double borderWidth;

  const ComicSearchResultStyle({
    this.backgroundColor = Colors.transparent,
    this.hoverBackgroundColor = const Color(0xFF455A64),
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.borderRadius = BorderRadius.zero,
    this.imageWidth = 60.0,
    this.imageHeight = 90.0,
    this.imageBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.imageFit = BoxFit.cover,
    this.titleVariant = TextVariant.titleMedium,
    this.titleStyle,
    this.titleColor = const Color(0xFF000000),
    this.titleMaxLines = 1,
    this.subtitleVariant = TextVariant.bodySmall,
    this.subtitleStyle,
    this.subtitleColor = const Color(0xFF757575),
    this.subtitleMaxLines = 1,
    this.highlightBackgroundColor = const Color(0xFFFFEE58),
    this.highlightTextColor = const Color(0xFF000000),
    this.highlightFontWeight = FontWeight.bold,
    this.horizontalSpacing = 16.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
  });

  ComicSearchResultStyle copyWith({
    Color? backgroundColor,
    Color? hoverBackgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double? imageWidth,
    double? imageHeight,
    BorderRadius? imageBorderRadius,
    BoxFit? imageFit,
    TextVariant? titleVariant,
    TextStyle? titleStyle,
    Color? titleColor,
    int? titleMaxLines,
    TextVariant? subtitleVariant,
    TextStyle? subtitleStyle,
    Color? subtitleColor,
    int? subtitleMaxLines,
    Color? highlightBackgroundColor,
    Color? highlightTextColor,
    FontWeight? highlightFontWeight,
    double? horizontalSpacing,
    Duration? animationDuration,
    Curve? animationCurve,
    Color? borderColor,
    double? borderWidth,
  }) {
    return ComicSearchResultStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
      imageFit: imageFit ?? this.imageFit,
      titleVariant: titleVariant ?? this.titleVariant,
      titleStyle: titleStyle ?? this.titleStyle,
      titleColor: titleColor ?? this.titleColor,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      subtitleVariant: subtitleVariant ?? this.subtitleVariant,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitleMaxLines: subtitleMaxLines ?? this.subtitleMaxLines,
      highlightBackgroundColor:
          highlightBackgroundColor ?? this.highlightBackgroundColor,
      highlightTextColor: highlightTextColor ?? this.highlightTextColor,
      highlightFontWeight: highlightFontWeight ?? this.highlightFontWeight,
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }
}

class ComicSearchResult extends StatefulWidget {
  final String title;
  final List<String>? altTitle;
  final String imageUrl;
  final String searchKeyword;

  // Gesture callbacks
  final VoidCallback? onTap;
  final VoidCallback? onThumbnailTap;
  final VoidCallback? onTitleTap;
  final VoidCallback? onAltTitleTap;

  // Style & custom builder slot
  final ComicSearchResultStyle? style;
  final Widget Function(BuildContext, ComicSearchResult)? builder;
  final Widget Function(BuildContext, String imageUrl)? thumbnailBuilder;
  final Widget Function(BuildContext, String title, String keyword)?
      titleBuilder;
  final Widget Function(BuildContext, List<String>? altTitle)? altTitleBuilder;

  const ComicSearchResult({
    super.key,
    required this.title,
    this.altTitle,
    required this.imageUrl,
    required this.searchKeyword,
    this.onTap,
    this.onThumbnailTap,
    this.onTitleTap,
    this.onAltTitleTap,
    this.style,
    this.builder,
    this.thumbnailBuilder,
    this.titleBuilder,
    this.altTitleBuilder,
  });

  @override
  State<ComicSearchResult> createState() => _ComicSearchResultState();
}

class _ComicSearchResultState extends State<ComicSearchResult> {
  bool _isHovering = false;

  ComicSearchResultStyle get _effectiveStyle =>
      widget.style ?? const ComicSearchResultStyle();

  List<TextSpan> _highlightedText(String fullText, String keyword) {
    if (keyword.isEmpty) return [TextSpan(text: fullText)];
    final matches = RegExp(RegExp.escape(keyword), caseSensitive: false)
        .allMatches(fullText);
    if (matches.isEmpty) return [TextSpan(text: fullText)];

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans
            .add(TextSpan(text: fullText.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: fullText.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: _effectiveStyle.highlightBackgroundColor,
          color: _effectiveStyle.highlightTextColor,
          fontWeight: _effectiveStyle.highlightFontWeight,
        ),
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(lastMatchEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final style = _effectiveStyle;
    // Full custom override, if builder provided
    if (widget.builder != null) return widget.builder!(context, widget);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: style.animationDuration,
          curve: style.animationCurve,
          padding: style.padding,
          decoration: BoxDecoration(
            color: _isHovering
                ? style.hoverBackgroundColor
                : style.backgroundColor,
            borderRadius: style.borderRadius,
            border: style.borderWidth > 0
                ? Border.all(color: style.borderColor, width: style.borderWidth)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // THUMBNAIL (fully customizable, fallback to default)
              GestureDetector(
                onTap: widget.onThumbnailTap ?? widget.onTap,
                child: widget.thumbnailBuilder != null
                    ? widget.thumbnailBuilder!(context, widget.imageUrl)
                    : ClipRRect(
                        borderRadius: style.imageBorderRadius,
                        child: AppImage.network(
                          widget.imageUrl,
                          width: style.imageWidth,
                          height: style.imageHeight,
                          fit: style.imageFit,
                          errorWidget: Container(
                            width: style.imageWidth,
                            height: style.imageHeight,
                            color: AppColors.neutral[300],
                            child: Icon(Icons.broken_image,
                                color: AppColors.neutral[500],
                                size: style.imageWidth * 0.5),
                          ),
                        ),
                      ),
              ),
              SizedBox(width: style.horizontalSpacing),
              // TITLE & ALT TITLE (fully customizable, fallback to default)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: widget.onTitleTap ?? widget.onTap,
                      child: widget.titleBuilder != null
                          ? widget.titleBuilder!(
                              context, widget.title, widget.searchKeyword)
                          : RichText(
                              text: TextSpan(
                                style: TextStyle(color: style.titleColor)
                                    .merge(style.titleStyle),
                                children: _highlightedText(
                                    widget.title, widget.searchKeyword),
                              ),
                              maxLines: style.titleMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: widget.onAltTitleTap ?? widget.onTap,
                      child: widget.altTitleBuilder != null
                          ? widget.altTitleBuilder!(context, widget.altTitle)
                          : AppText(
                              (widget.altTitle != null &&
                                      widget.altTitle!.isNotEmpty)
                                  ? widget.altTitle!.join(', ')
                                  : '-',
                              variant: style.subtitleVariant,
                              color: style.subtitleColor,
                              style: style.subtitleStyle,
                              maxLines: style.subtitleMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
