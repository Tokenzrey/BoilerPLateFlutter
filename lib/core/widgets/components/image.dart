// Gambar dari jaringan dengan loading skeleton dan circular progress
// AppImage.network(
//   'https://example.com/image.jpg',
//   width: 300,
//   height: 200,
//   fit: BoxFit.cover,
// )

// Gambar asset dengan border radius
// AppImage.asset(
//   'assets/images/logo.png',
//   width: 200,
//   height: 150,
//   borderRadius: BorderRadius.circular(12),
// )

// Avatar/profile picture
// AppImage.avatar(
//   src: 'https://example.com/profile.jpg',
//   size: 80,
// )

// Dengan custom error dan loading widgets
// AppImage.network(
//   'https://example.com/large-image.jpg',
//   progressiveLoading: true, // Menampilkan circular progress indicator
//   errorWidget: Text('Image failed to load'),
//   loadingWidget: Center(child: AppCircularProgress.small()),
// )

import 'dart:io';
import 'package:flutter/material.dart';
import 'display/skeleton.dart';
import 'progress/circular.dart';

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
  bool _hasError = false;

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

  void _createImageProvider() {
    switch (widget.source) {
      case ImageSource.asset:
        imageProvider = _createOptimizedProvider(
            AssetImage(widget.src, bundle: DefaultAssetBundle.of(context)));
        break;
      case ImageSource.network:
        final Map<String, String>? headers =
            !widget.useCache ? const {'cache-control': 'no-cache'} : null;

        imageProvider = _createOptimizedProvider(
            NetworkImage(widget.src, scale: widget.scale, headers: headers));
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
    if (widget.width != null && widget.height != null) {
      return ResizeImage(
        provider,
        width: widget.width?.toInt(),
        height: widget.height?.toInt(),
        allowUpscaling: false,
      );
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_hasError) {
      imageWidget = _buildErrorWidget();
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
          setState(() {
            _hasError = true;
          });
          return _buildErrorWidget();
        },
        loadingBuilder: widget.progressiveLoading
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Stack(
                  children: [
                    _buildLoadingWidget(),
                    if (loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.cumulativeBytesLoaded > 0)
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
