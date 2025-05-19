import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Defines the type of animation effect for the skeleton
enum SkeletonEffectType {
  shimmer,
  pulse,
  none,
}

/// Configuration for skeleton appearance and behavior
class SkeletonConfig {
  final Color baseColor;
  final Color highlightColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final bool enableTransitionAnimation;
  final SkeletonEffectType effectType;
  final Duration fadeDuration;
  final Curve fadeCurve;
  final List<Type> ignoreTypes;
  final List<Key> ignoreKeys;
  final double textLastLineWidthFactor;
  final double textLineSpacing;

  const SkeletonConfig({
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.easeInOut,
    this.borderRadius = 8.0,
    this.enableTransitionAnimation = true,
    this.effectType = SkeletonEffectType.shimmer,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.fadeCurve = Curves.easeInOut,
    this.ignoreTypes = const [],
    this.ignoreKeys = const [],
    this.textLastLineWidthFactor = 0.7,
    this.textLineSpacing = 6.0,
  });

  factory SkeletonConfig.light(BuildContext context) {
    final theme = Theme.of(context);
    return SkeletonConfig(
      baseColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
      highlightColor: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
    );
  }

  factory SkeletonConfig.dark(BuildContext context) {
    final theme = Theme.of(context);
    return SkeletonConfig(
      baseColor: theme.colorScheme.surfaceContainerHighest.withAlpha(25),
      highlightColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
    );
  }

  SkeletonConfig copyWith({
    Color? baseColor,
    Color? highlightColor,
    Duration? animationDuration,
    Curve? animationCurve,
    double? borderRadius,
    bool? enableTransitionAnimation,
    SkeletonEffectType? effectType,
    Duration? fadeDuration,
    Curve? fadeCurve,
    List<Type>? ignoreTypes,
    List<Key>? ignoreKeys,
    double? textLastLineWidthFactor,
    double? textLineSpacing,
  }) {
    return SkeletonConfig(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      borderRadius: borderRadius ?? this.borderRadius,
      enableTransitionAnimation:
          enableTransitionAnimation ?? this.enableTransitionAnimation,
      effectType: effectType ?? this.effectType,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      fadeCurve: fadeCurve ?? this.fadeCurve,
      ignoreTypes: ignoreTypes ?? this.ignoreTypes,
      ignoreKeys: ignoreKeys ?? this.ignoreKeys,
      textLastLineWidthFactor:
          textLastLineWidthFactor ?? this.textLastLineWidthFactor,
      textLineSpacing: textLineSpacing ?? this.textLineSpacing,
    );
  }
}

/// Main skeleton widget that wraps content with loading effects
class AppSkeleton extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final SkeletonConfig? config;
  final bool isUnified;
  final bool ignoreContainers;
  final Widget? replacement;
  final bool isLeaf;
  final Widget Function(BuildContext, Widget)? placeholderBuilder;

  const AppSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
    this.config,
    this.isUnified = false,
    this.ignoreContainers = false,
    this.replacement,
    this.isLeaf = false,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? SkeletonConfig.light(context);

    // Handle custom placeholder if provided
    if (placeholderBuilder != null && isLoading) {
      return placeholderBuilder!(context, child);
    }

    // Handle replacement widget if provided
    if (replacement != null && isLoading) {
      return replacement!;
    }

    // Special case for leaf nodes
    if (isLeaf) {
      return Skeleton.leaf(
        enabled: isLoading,
        child: child,
      );
    }

    // Special case for unified skeletons
    if (isUnified) {
      return Skeleton.unite(
        unite: isLoading,
        child: child,
      );
    }

    // Create the skeletonizer config based on effect type
    var skeletonConfig = SkeletonizerConfigData();

    switch (effectiveConfig.effectType) {
      case SkeletonEffectType.shimmer:
        skeletonConfig = SkeletonizerConfigData(
          effect: ShimmerEffect(
            baseColor: effectiveConfig.baseColor,
            highlightColor: effectiveConfig.highlightColor,
            duration: effectiveConfig.animationDuration,
          ),
        );
        break;
      case SkeletonEffectType.pulse:
        skeletonConfig = SkeletonizerConfigData(
          effect: PulseEffect(
            from: effectiveConfig.baseColor,
            to: effectiveConfig.highlightColor,
            duration: effectiveConfig.animationDuration,
          ),
        );
        break;
      case SkeletonEffectType.none:
        skeletonConfig = SkeletonizerConfigData();
        break;
    }

    // Create the final widget with transition animation
    Widget skeletonWidget = SkeletonizerConfig(
      data: skeletonConfig,
      child: Skeletonizer(
        enabled: isLoading,
        ignoreContainers: ignoreContainers,
        child: child,
      ),
    );

    // Add fade transition when switching between skeleton and actual content
    if (effectiveConfig.enableTransitionAnimation) {
      return AnimatedSwitcher(
        duration: effectiveConfig.fadeDuration,
        switchInCurve: effectiveConfig.fadeCurve,
        switchOutCurve: effectiveConfig.fadeCurve,
        child: isLoading
            ? skeletonWidget
            : KeyedSubtree(key: ValueKey('loaded_content'), child: child),
      );
    }

    return skeletonWidget;
  }

  /// Unified builder for lists and grids
  static Widget builder({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    bool isLoading = true,
    int? loadingItemCount,
    SkeletonConfig? config,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical,
    SliverGridDelegate? gridDelegate,
    ScrollController? controller,
  }) {
    final effectiveItemCount = isLoading ? (loadingItemCount ?? 5) : itemCount;

    // Use GridView if gridDelegate is provided, otherwise ListView
    final Widget listWidget = gridDelegate != null
        ? GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            scrollDirection: scrollDirection,
            controller: controller,
            gridDelegate: gridDelegate,
            itemCount: effectiveItemCount,
            itemBuilder: itemBuilder,
          )
        : ListView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            scrollDirection: scrollDirection,
            controller: controller,
            itemCount: effectiveItemCount,
            itemBuilder: itemBuilder,
          );

    return AppSkeleton(
      isLoading: isLoading,
      config: config,
      child: listWidget,
    );
  }

  /// Sliver list with skeleton
  static Widget sliverList({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    bool isLoading = true,
    int? loadingItemCount,
    SkeletonConfig? config,
    SliverChildBuilderDelegate? childrenDelegate,
  }) {
    final effectiveItemCount = isLoading ? (loadingItemCount ?? 5) : itemCount;

    return SliverSkeletonBuilder(
      isLoading: isLoading,
      config: config,
      builder: (context, skeletonLoading) => SliverList(
        delegate: childrenDelegate ??
            SliverChildBuilderDelegate(
              (context, index) => itemBuilder(context, index),
              childCount: effectiveItemCount,
            ),
      ),
    );
  }

  /// Sliver grid with skeleton
  static Widget sliverGrid({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    required SliverGridDelegate gridDelegate,
    bool isLoading = true,
    int? loadingItemCount,
    SkeletonConfig? config,
  }) {
    final effectiveItemCount = isLoading ? (loadingItemCount ?? 6) : itemCount;

    return SliverSkeletonBuilder(
      isLoading: isLoading,
      config: config,
      builder: (context, skeletonLoading) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, index),
          childCount: effectiveItemCount,
        ),
        gridDelegate: gridDelegate,
      ),
    );
  }
}

/// Helper for sliver skeleton widgets
class SliverSkeletonBuilder extends StatelessWidget {
  final bool isLoading;
  final SkeletonConfig? config;
  final Widget Function(BuildContext, bool) builder;

  const SliverSkeletonBuilder({
    super.key,
    required this.isLoading,
    this.config,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? SkeletonConfig.light(context);

    // Create skeletonizer config based on effect type
    var skeletonConfig = SkeletonizerConfigData();

    switch (effectiveConfig.effectType) {
      case SkeletonEffectType.shimmer:
        skeletonConfig = SkeletonizerConfigData(
          effect: ShimmerEffect(
            baseColor: effectiveConfig.baseColor,
            highlightColor: effectiveConfig.highlightColor,
            duration: effectiveConfig.animationDuration,
          ),
        );
        break;
      case SkeletonEffectType.pulse:
        skeletonConfig = SkeletonizerConfigData(
          effect: PulseEffect(
            from: effectiveConfig.baseColor,
            to: effectiveConfig.highlightColor,
            duration: effectiveConfig.animationDuration,
          ),
        );
        break;
      case SkeletonEffectType.none:
        skeletonConfig = SkeletonizerConfigData();
        break;
    }

    return SkeletonizerConfig(
      data: skeletonConfig,
      child: builder(context, isLoading),
    );
  }
}

/// Widget extension methods for skeleton loading
extension SkeletonExtension on Widget {
  Widget asSkeleton({
    bool isLoading = true,
    SkeletonConfig? config,
    bool isUnified = false,
    bool ignoreContainers = false,
    Widget? replacement,
    bool isLeaf = false,
    AsyncSnapshot? snapshot,
    Widget Function(BuildContext, Widget)? placeholderBuilder,
  }) {
    // Handle AsyncSnapshot automatically if provided
    if (snapshot != null) {
      isLoading = snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData;
    }

    // Auto-detect images and avatars
    if (this is Image ||
        runtimeType.toString().contains('Avatar') ||
        runtimeType.toString().contains('CircleAvatar')) {
      return Skeleton.leaf(
        enabled: isLoading,
        child: this,
      );
    }

    // Auto-detect Text widgets with multiple lines
    if (this is Text) {
      final textWidget = this as Text;
      final maxLines = textWidget.maxLines;

      // If it's a multi-line text, use appropriate skeleton
      if (maxLines != null && maxLines > 1) {
        return SkeletonText(
          text: textWidget.data ?? '',
          lines: maxLines,
          isLoading: isLoading,
          style: textWidget.style,
          config: config,
        );
      }
    }

    return AppSkeleton(
      isLoading: isLoading,
      config: config,
      isUnified: isUnified,
      ignoreContainers: ignoreContainers,
      replacement: replacement,
      isLeaf: isLeaf,
      placeholderBuilder: placeholderBuilder,
      child: this,
    );
  }

  Widget ignoreSkeleton() {
    return Skeleton.ignore(child: this);
  }

  Widget keepOriginal({bool keep = true}) {
    return Skeleton.keep(
      keep: keep,
      child: this,
    );
  }

  Widget asUnifiedSkeleton({bool isLoading = true, SkeletonConfig? config}) {
    return asSkeleton(isLoading: isLoading, config: config, isUnified: true);
  }

  Widget asLeafSkeleton({bool isLoading = true, SkeletonConfig? config}) {
    return asSkeleton(isLoading: isLoading, config: config, isLeaf: true);
  }
}

/// Auto-transforms text into a skeleton with multiple lines
class SkeletonText extends StatelessWidget {
  final int lines;
  final bool isLoading;
  final String text;
  final TextStyle? style;
  final double? lastLineWidthFactor;
  final double? lineSpacing;
  final SkeletonConfig? config;

  const SkeletonText({
    super.key,
    required this.text,
    this.lines = 1,
    this.isLoading = true,
    this.style,
    this.lastLineWidthFactor,
    this.lineSpacing,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        style ?? Theme.of(context).textTheme.bodyMedium!;
    final effectiveConfig = config ?? SkeletonConfig.light(context);
    final effectiveLastLineWidthFactor =
        lastLineWidthFactor ?? effectiveConfig.textLastLineWidthFactor;
    final effectiveLineSpacing = lineSpacing ?? effectiveConfig.textLineSpacing;

    if (!isLoading) {
      return Text(text, style: effectiveStyle);
    }

    final lineWidgets = <Widget>[];

    for (int i = 0; i < lines; i++) {
      final isLastLine = i == lines - 1;
      final widthFactor = isLastLine ? effectiveLastLineWidthFactor : 1.0;

      lineWidgets.add(
        FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: effectiveStyle.fontSize! * (effectiveStyle.height ?? 1.2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: effectiveConfig.baseColor,
            ),
          ),
        ),
      );

      if (!isLastLine) {
        lineWidgets.add(SizedBox(height: effectiveLineSpacing));
      }
    }

    return AppSkeleton(
      isLoading: true,
      config: config,
      isLeaf: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lineWidgets,
      ),
    );
  }
}

/// Creates a shaped skeleton placeholder
class SkeletonShape extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final bool isLoading;
  final Widget? child;
  final SkeletonConfig? config;

  const SkeletonShape({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.isLoading = true,
    this.child,
    this.config,
  });

  factory SkeletonShape.circle({
    Key? key,
    required double size,
    bool isLoading = true,
    Widget? child,
    SkeletonConfig? config,
  }) {
    return SkeletonShape(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      isLoading: isLoading,
      config: config,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? SkeletonConfig.light(context);

    if (!isLoading && child != null) {
      return child!;
    }

    return AppSkeleton(
      isLoading: isLoading,
      config: config,
      isLeaf: true,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: effectiveConfig.baseColor,
        ),
      ),
    );
  }
}

/// Automatically binds async operations to skeleton loading states
class AsyncSkeleton<T> extends StatelessWidget {
  final Future<T>? future;
  final Stream<T>? stream;
  final Widget Function(BuildContext, T) builder;
  final SkeletonConfig? config;
  final Widget? loadingFallback;
  final Widget Function(BuildContext, Object?)? errorBuilder;

  const AsyncSkeleton({
    super.key,
    this.future,
    this.stream,
    required this.builder,
    this.config,
    this.loadingFallback,
    this.errorBuilder,
  }) : assert(future != null || stream != null,
            'Either future or stream must be provided');

  @override
  Widget build(BuildContext context) {
    if (future != null) {
      return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError && errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }

          if (snapshot.hasData) {
            return builder(context, snapshot.data as T);
          }

          return loadingFallback ??
              AppSkeleton(
                isLoading: true,
                config: config,
                child: Builder(
                  builder: (context) {
                    try {
                      // Try to create a skeleton version of the widget
                      return builder(context, null as T);
                    } catch (_) {
                      // Fallback to an empty container if builder requires non-null data
                      return Container();
                    }
                  },
                ),
              );
        },
      );
    } else {
      return StreamBuilder<T>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError && errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }

          if (snapshot.hasData) {
            return builder(context, snapshot.data as T);
          }

          return loadingFallback ??
              AppSkeleton(
                isLoading: true,
                config: config,
                child: Builder(
                  builder: (context) {
                    try {
                      // Try to create a skeleton version of the widget
                      return builder(context, null as T);
                    } catch (_) {
                      // Fallback to an empty container if builder requires non-null data
                      return Container();
                    }
                  },
                ),
              );
        },
      );
    }
  }
}
