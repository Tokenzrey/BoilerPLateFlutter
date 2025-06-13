import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';

class ComicCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String chapter;
  final String updated;
  final String scanlator;
  final String likes;
  final String countryCodeUrl;
  final bool isBookmarked;
  final bool showCountryFlag;
  final bool showBookmark;
  final bool onlyTitle;
  final bool showTitle;
  final bool showUpdated;
  final bool showLike;
  final bool showScanlator;
  final VoidCallback? onTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onTitleTap;
  final VoidCallback? onChapterTap;
  final VoidCallback? onDetailTap;
  final Function(bool)? onBookmarkChanged;
  final ComicCardStyle? style;

  const ComicCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.chapter,
    required this.updated,
    required this.scanlator,
    required this.likes,
    required this.countryCodeUrl,
    this.isBookmarked = false,
    this.showCountryFlag = true,
    this.showBookmark = true,
    this.onlyTitle = false,
    this.showTitle = true,
    this.showUpdated = true,
    this.showLike = true,
    this.showScanlator = true,
    this.onTap,
    this.onImageTap,
    this.onTitleTap,
    this.onChapterTap,
    this.onDetailTap,
    this.onBookmarkChanged,
    this.style,
  });

  @override
  State<ComicCard> createState() => _ComicCardState();
}

class _ComicCardState extends State<ComicCard> {
  bool _isHoveringCard = false;
  bool _isHoveringBookmark = false;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  @override
  void didUpdateWidget(covariant ComicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _isBookmarked = widget.isBookmarked;
    }
  }

  ComicCardStyle get _effectiveStyle => widget.style ?? ComicCardStyle.light();

  @override
  Widget build(BuildContext context) {
    final style = _effectiveStyle;
    final double cardWidth = style.width ?? 240;
    final double cardHeight = style.height ?? 400;
    final double imageHeight = style.imageHeight ?? cardHeight * 0.75;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringCard = true),
      onExit: (_) => setState(() => _isHoveringCard = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: style.animationDuration,
          curve: style.animationCurve,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: style.borderRadius ?? BorderRadius.circular(8),
            boxShadow: _isHoveringCard
                ? style.hoverBoxShadow ?? style.boxShadow
                : style.boxShadow,
            border: style.border,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- IMAGE COVER ---
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onImageTap ?? widget.onTap,
                child: Stack(
                  children: [
                    // Cover image - NOT STRETCHED
                    ClipRRect(
                      borderRadius: style.imageBorderRadius ??
                          const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                      child: AspectRatio(
                        aspectRatio: cardWidth / imageHeight,
                        child: AppImage.network(
                          widget.imageUrl,
                          fit: style.imageFit ?? BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget:
                              _customImageError(imageHeight, cardWidth),
                        ),
                      ),
                    ),
                    if (widget.showCountryFlag)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: AppImage.network(
                          widget.countryCodeUrl,
                          width: style.flagWidth ?? 28,
                          height: style.flagHeight ?? 18,
                          fit: BoxFit.cover,
                          errorWidget: _flagErrorWidget(style),
                        ),
                      ),
                    if (widget.showBookmark)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isBookmarked = !_isBookmarked);
                            widget.onBookmarkChanged?.call(_isBookmarked);
                          },
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => _isHoveringBookmark = true),
                            onExit: (_) =>
                                setState(() => _isHoveringBookmark = false),
                            child: Icon(
                              Icons.bookmark,
                              size: (_isBookmarked || _isHoveringBookmark)
                                  ? style.bookmarkActiveSize ?? 28
                                  : style.bookmarkSize ?? 22,
                              color: _isBookmarked
                                  ? style.bookmarkActiveColor ??
                                      AppColors.green[400]
                                  : AppColors.neutral[400],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // --- CONTENT SECTION ---
              Expanded(
                child: Padding(
                  padding: style.contentPadding ?? const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.onlyTitle)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: widget.onChapterTap,
                                child: AppText(
                                  widget.chapter,
                                  variant: TextVariant.bodySmall,
                                  style: style.chapterStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (widget.showLike)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: style.likeIconSize ?? 14,
                                    color: style.likeIconColor ??
                                        AppColors.neutral[600],
                                  ),
                                  const SizedBox(width: 3),
                                  AppText(
                                    widget.likes,
                                    variant: TextVariant.bodySmall,
                                    style: style.likesStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      if (!widget.onlyTitle &&
                          (widget.showUpdated || widget.showScanlator))
                        const SizedBox(height: 4),
                      if (!widget.onlyTitle &&
                          (widget.showUpdated || widget.showScanlator))
                        GestureDetector(
                          onTap: widget.onDetailTap ?? widget.onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.showUpdated)
                                AppText(
                                  widget.updated,
                                  variant: TextVariant.bodySmall,
                                  style: style.updatedStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (widget.showScanlator)
                                AppText(
                                  widget.scanlator,
                                  variant: TextVariant.bodySmall,
                                  style: style.scanlatorStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      if (widget.showTitle)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: GestureDetector(
                            onTap: widget.onTitleTap ?? widget.onTap,
                            child: AppText(
                              widget.title,
                              variant: TextVariant.titleMedium,
                              style: style.titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customImageError(double height, double width) {
    final style = _effectiveStyle;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: style.imageErrorColor ?? AppColors.neutral[300],
        borderRadius: style.imageBorderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: AppColors.neutral[500], size: 38),
            const SizedBox(height: 10),
            AppText(
              'Failed to load image',
              style: TextStyle(
                color: AppColors.neutral[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _flagErrorWidget(ComicCardStyle style) {
    return Container(
      width: style.flagWidth ?? 24,
      height: style.flagHeight ?? 16,
      decoration: BoxDecoration(
        color: AppColors.neutral[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.flag, color: Colors.grey, size: 14),
    );
  }
}

class ComicCardStyle {
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final List<BoxShadow>? boxShadow;
  final List<BoxShadow>? hoverBoxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final BorderRadius? imageBorderRadius;
  final double? imageHeight;
  final BoxFit? imageFit;
  final Color? imageErrorColor;
  final TextStyle? titleStyle;
  final TextStyle? chapterStyle;
  final TextStyle? updatedStyle;
  final TextStyle? scanlatorStyle;
  final TextStyle? likesStyle;
  final Color? bookmarkColor;
  final Color? bookmarkActiveColor;
  final Color? likeIconColor;
  final double? bookmarkSize;
  final double? bookmarkActiveSize;
  final double? likeIconSize;
  final double? flagWidth;
  final double? flagHeight;
  final double? spaceBetweenElements;
  final Duration animationDuration;
  final Curve animationCurve;

  const ComicCardStyle({
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.contentPadding,
    this.boxShadow,
    this.hoverBoxShadow,
    this.border,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.imageBorderRadius,
    this.imageHeight,
    this.imageFit,
    this.imageErrorColor,
    this.titleStyle,
    this.chapterStyle,
    this.updatedStyle,
    this.scanlatorStyle,
    this.likesStyle,
    this.bookmarkColor,
    this.bookmarkActiveColor,
    this.likeIconColor,
    this.bookmarkSize,
    this.bookmarkActiveSize,
    this.likeIconSize,
    this.flagWidth,
    this.flagHeight,
    this.spaceBetweenElements,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  factory ComicCardStyle.light() {
    return ComicCardStyle(
      backgroundColor: AppColors.neutral,
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.neutral[950]!.withValues(alpha: 0.07),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      hoverBoxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      imageBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      imageFit: BoxFit.cover,
      imageErrorColor: AppColors.neutral[200],
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.neutral[900],
      ),
      chapterStyle: TextStyle(
        fontSize: 12,
        color: AppColors.neutral[700],
      ),
      updatedStyle: TextStyle(
        fontSize: 12,
        color: AppColors.neutral[500],
      ),
      scanlatorStyle: TextStyle(
        fontSize: 12,
        color: AppColors.neutral[400],
      ),
      likesStyle: TextStyle(
        fontSize: 12,
        color: AppColors.neutral[600],
      ),
      bookmarkColor: AppColors.neutral[400],
      bookmarkActiveColor: AppColors.green[400],
      likeIconColor: AppColors.neutral[600],
      bookmarkSize: 22,
      bookmarkActiveSize: 28,
      likeIconSize: 14,
      flagWidth: 24,
      flagHeight: 16,
      spaceBetweenElements: 4,
    );
  }
}
