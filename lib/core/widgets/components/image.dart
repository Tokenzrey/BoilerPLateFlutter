import 'dart:io';
import 'package:boilerplate/core/widgets/components/display/circular.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'display/skeleton.dart';

// Hindari tabrakan dengan dart:ui
enum ImageSource { asset, network, file, memory }

class AppImage extends StatefulWidget {
  final String src;
  final ImageSource source;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment alignment;
  final bool excludeFromSemantics;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final double scale;
  final String? semanticLabel;
  final bool gaplessPlayback;
  final bool useCache;
  final bool progressiveLoading;
  final Duration fadeInDuration;

  const AppImage({
    super.key,
    required this.src,
    required this.source,
    this.fit,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.excludeFromSemantics = false,
    this.errorWidget,
    this.loadingWidget,
    this.scale = 1.0,
    this.semanticLabel,
    this.gaplessPlayback = true,
    this.useCache = true,
    this.progressiveLoading = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  factory AppImage.network(
    String url, {
    Key? key,
    BoxFit? fit,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Alignment alignment = Alignment.center,
    Widget? errorWidget,
    Widget? loadingWidget,
    double scale = 1.0,
    String? semanticLabel,
    bool gaplessPlayback = true,
    bool useCache = true,
    bool progressiveLoading = true,
    Duration fadeInDuration = const Duration(milliseconds: 300),
  }) {
    return AppImage(
      key: key,
      src: url,
      source: ImageSource.network,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      scale: scale,
      semanticLabel: semanticLabel,
      gaplessPlayback: gaplessPlayback,
      useCache: useCache,
      progressiveLoading: progressiveLoading,
      fadeInDuration: fadeInDuration,
    );
  }

  factory AppImage.asset(
    String assetPath, {
    Key? key,
    BoxFit? fit,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Alignment alignment = Alignment.center,
    Widget? errorWidget,
    String? semanticLabel,
    double scale = 1.0,
  }) {
    return AppImage(
      key: key,
      src: assetPath,
      source: ImageSource.asset,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      errorWidget: errorWidget,
      semanticLabel: semanticLabel,
      scale: scale,
      loadingWidget: null,
      useCache: true,
    );
  }

  factory AppImage.file(
    String filePath, {
    Key? key,
    BoxFit? fit,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Alignment alignment = Alignment.center,
    Widget? errorWidget,
    Widget? loadingWidget,
    String? semanticLabel,
    double scale = 1.0,
  }) {
    return AppImage(
      key: key,
      src: filePath,
      source: ImageSource.file,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      semanticLabel: semanticLabel,
      scale: scale,
      useCache: true,
    );
  }

  factory AppImage.avatar({
    Key? key,
    required String src,
    ImageSource source = ImageSource.network,
    double size = 40,
    Color? borderColor,
    double borderWidth = 0,
    Widget? errorWidget,
    Widget? loadingWidget,
  }) {
    return AppImage(
      key: key,
      src: src,
      source: source,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      fit: BoxFit.cover,
      errorWidget: errorWidget ??
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: size / 2,
              color: Colors.grey.shade600,
            ),
          ),
      loadingWidget: loadingWidget,
    );
  }

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> with WidgetsBindingObserver {
  late ImageProvider imageProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createImageProvider();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src ||
        oldWidget.source != widget.source ||
        oldWidget.scale != widget.scale) {
      _createImageProvider();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createImageProvider();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearImageCache();
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    _clearImageCache();
  }

  void _clearImageCache() {
    if (widget.source == ImageSource.network && !widget.useCache) {
      PaintingBinding.instance.imageCache.evict(imageProvider);
    }
  }

  /// Helper to check width/height valid, finite & > 0
  int? _validSize(double? value) {
    if (value == null) return null;
    if (value.isNaN || value.isInfinite || value <= 0) return null;
    return value.toInt();
  }

  void _createImageProvider() {
    switch (widget.source) {
      case ImageSource.asset:
        imageProvider = _createOptimizedProvider(
          AssetImage(widget.src, bundle: DefaultAssetBundle.of(context)),
        );
        break;
      case ImageSource.network:
        if (widget.useCache) {
          imageProvider = CachedNetworkImageProvider(
            widget.src,
            cacheKey: widget.src,
            maxHeight: _validSize(widget.height),
            maxWidth: _validSize(widget.width),
          );
        } else {
          final Map<String, String> headers = const {
            'cache-control': 'no-cache'
          };
          imageProvider =
              NetworkImage(widget.src, scale: widget.scale, headers: headers);
        }
        break;
      case ImageSource.file:
        imageProvider = _createOptimizedProvider(FileImage(File(widget.src)));
        break;
      case ImageSource.memory:
        imageProvider = _createOptimizedProvider(AssetImage(widget.src));
        break;
    }
  }

  ImageProvider _createOptimizedProvider(ImageProvider provider) {
    final safeWidth = _validSize(widget.width);
    final safeHeight = _validSize(widget.height);
    if (safeWidth != null || safeHeight != null) {
      return ResizeImage(
        provider,
        width: safeWidth,
        height: safeHeight,
        allowUpscaling: false,
      );
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.source == ImageSource.network && widget.useCache) {
      imageWidget = CachedNetworkImage(
        imageUrl: widget.src,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        fadeInDuration: widget.fadeInDuration,
        placeholder: widget.progressiveLoading
            ? null
            : (context, url) => widget.loadingWidget ?? _buildLoadingWidget(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        progressIndicatorBuilder: widget.progressiveLoading
            ? (context, url, progress) => Stack(
                  children: [
                    _buildLoadingWidget(),
                    if (progress.totalSize != null && progress.totalSize! > 0)
                      Positioned.fill(
                        child: Center(
                          child: AppCircularProgress(
                            value: progress.downloaded / progress.totalSize!,
                            size: 30,
                            strokeWidth: 3,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                )
            : null,
        useOldImageOnUrlChange: widget.gaplessPlayback,
        memCacheWidth: _validSize(widget.width),
        memCacheHeight: _validSize(widget.height),
        cacheKey: widget.src,
      );
    } else {
      imageWidget = Image(
        image: imageProvider,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        alignment: widget.alignment,
        excludeFromSemantics: widget.excludeFromSemantics,
        gaplessPlayback: widget.gaplessPlayback,
        semanticLabel: widget.semanticLabel,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return AnimatedOpacity(
              opacity: 1.0,
              duration: widget.fadeInDuration,
              child: child,
            );
          }
          return widget.loadingWidget ?? _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
        loadingBuilder: widget.progressiveLoading
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                if (loadingProgress.expectedTotalBytes != null &&
                    loadingProgress.expectedTotalBytes! > 0) {
                  return Stack(
                    children: [
                      _buildLoadingWidget(),
                      Positioned.fill(
                        child: Center(
                          child: AppCircularProgress(
                            value: loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!,
                            size: 30,
                            strokeWidth: 3,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return _buildLoadingWidget();
              }
            : null,
      );
    }

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget() {
    final loadingWidget = Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
    );
    return loadingWidget.asSkeleton(isLoading: true);
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey.shade400,
          size: (widget.width != null && widget.height != null)
              ? (widget.width! < widget.height!
                  ? widget.width! / 2
                  : widget.height! / 2)
              : 24,
        ),
      ),
    );
  }
}
