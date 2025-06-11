import 'dart:ui';

import 'package:boilerplate/core/widgets/animation.dart';
import 'package:boilerplate/core/widgets/utils.dart';
import 'package:flutter/material.dart';

class SurfaceBlur extends StatefulWidget {
  final Widget child;
  final double? surfaceBlur;
  final BorderRadiusGeometry? borderRadius;

  const SurfaceBlur({
    super.key,
    required this.child,
    this.surfaceBlur,
    this.borderRadius,
  });

  @override
  State<SurfaceBlur> createState() => _SurfaceBlurState();
}

class _SurfaceBlurState extends State<SurfaceBlur> {
  final GlobalKey _mainContainerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    if (widget.surfaceBlur == null || widget.surfaceBlur! <= 0) {
      return KeyedSubtree(
        key: _mainContainerKey,
        child: widget.child,
      );
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.surfaceBlur!,
                sigmaY: widget.surfaceBlur!,
              ),
              // had to add SizedBox, otherwise it won't blur
              child: const SizedBox(),
            ),
          ),
        ),
        KeyedSubtree(
          key: _mainContainerKey,
          child: widget.child,
        ),
      ],
    );
  }
}

class OutlinedContainer extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Clip clipBehavior;
  final BorderRadiusGeometry? borderRadius;
  final BorderStyle? borderStyle;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final double? width;
  final double? height;
  final Duration? duration;
  const OutlinedContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.clipBehavior = Clip.antiAlias,
    this.borderRadius,
    this.borderStyle,
    this.borderWidth,
    this.boxShadow,
    this.padding,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.width,
    this.height,
    this.duration,
  });

  @override
  State<OutlinedContainer> createState() => _OutlinedContainerState();
}

class _OutlinedContainerState extends State<OutlinedContainer> {
  final GlobalKey _mainContainerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    var borderRadius =
        widget.borderRadius?.resolve(Directionality.of(context)) ??
            BorderRadius.circular(20);
    var backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;
    if (widget.surfaceOpacity != null) {
      backgroundColor = backgroundColor.scaleAlpha(widget.surfaceOpacity!);
    }
    Widget childWidget = AnimatedContainer(
      duration: widget.duration ?? Duration.zero,
      key: _mainContainerKey,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: widget.borderColor ?? theme.colorScheme.outline,
          width: widget.borderWidth ?? (1),
          style: widget.borderStyle ?? BorderStyle.solid,
        ),
        borderRadius: borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: AnimatedContainer(
        duration: widget.duration ?? Duration.zero,
        padding: widget.padding,
        clipBehavior: widget.clipBehavior,
        decoration: BoxDecoration(
          borderRadius: subtractByBorder(
            borderRadius,
            widget.borderWidth ?? (1),
          ),
        ),
        child: widget.child,
      ),
    );
    if (widget.surfaceBlur != null && widget.surfaceBlur! > 0) {
      childWidget = SurfaceBlur(
        surfaceBlur: widget.surfaceBlur!,
        borderRadius: subtractByBorder(
          borderRadius,
          widget.borderWidth ?? (1),
        ),
        child: childWidget,
      );
    }
    return childWidget;
  }
}

class DashedLineProperties {
  final double width;
  final double gap;
  final double thickness;
  final Color color;

  const DashedLineProperties({
    required this.width,
    required this.gap,
    required this.thickness,
    required this.color,
  });

  static DashedLineProperties lerp(
    DashedLineProperties a,
    DashedLineProperties b,
    double t,
  ) {
    return DashedLineProperties(
      width: lerpDouble(a.width, b.width, t)!,
      gap: lerpDouble(a.gap, b.gap, t)!,
      thickness: lerpDouble(a.thickness, b.thickness, t)!,
      color: Color.lerp(a.color, b.color, t)!,
    );
  }
}

class DashedLine extends StatelessWidget {
  final double? width;
  final double? gap;
  final double? thickness;
  final Color? color;

  const DashedLine({
    super.key,
    this.width,
    this.gap,
    this.thickness,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedValueBuilder(
        value: DashedLineProperties(
          width: width ?? (8),
          gap: gap ?? (5),
          thickness: thickness ?? (1),
          color: color ?? theme.colorScheme.outline,
        ),
        duration: kDefaultDuration,
        lerp: (a, b, t) => DashedLineProperties.lerp(a!, b!, t),
        builder: (context, value, child) {
          return CustomPaint(
            painter: DashedLinePainter(
              width: value.width,
              gap: value.gap,
              thickness: value.thickness,
              color: value.color,
            ),
          );
        });
  }
}

class DashedContainerProperties {
  final double width;
  final double gap;
  final double thickness;
  final Color color;
  final BorderRadiusGeometry borderRadius;

  const DashedContainerProperties({
    required this.width,
    required this.gap,
    required this.thickness,
    required this.color,
    required this.borderRadius,
  });

  static DashedContainerProperties lerp(
    BuildContext context,
    DashedContainerProperties a,
    DashedContainerProperties b,
    double t,
  ) {
    return DashedContainerProperties(
      width: lerpDouble(a.width, b.width, t)!,
      gap: lerpDouble(a.gap, b.gap, t)!,
      thickness: lerpDouble(a.thickness, b.thickness, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      borderRadius: BorderRadius.lerp(a.borderRadius.optionallyResolve(context),
          b.borderRadius.optionallyResolve(context), t)!,
    );
  }
}

class DashedContainer extends StatelessWidget {
  final double? strokeWidth;
  final double? gap;
  final double? thickness;
  final Color? color;
  final Widget child;
  final BorderRadiusGeometry? borderRadius;

  const DashedContainer({
    super.key,
    this.strokeWidth,
    this.gap,
    this.thickness,
    this.color,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedValueBuilder(
      value: DashedContainerProperties(
        width: strokeWidth ?? (8),
        gap: gap ?? (5),
        thickness: thickness ?? (1),
        color: color ?? theme.colorScheme.outline,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      duration: kDefaultDuration,
      lerp: (a, b, t) {
        return DashedContainerProperties.lerp(context, a!, b!, t);
      },
      builder: (context, value, child) {
        return CustomPaint(
          painter: DashedPainter(
            width: value.width,
            gap: value.gap,
            thickness: value.thickness,
            color: value.color,
            borderRadius: value.borderRadius.optionallyResolve(context),
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double width;
  final double gap;
  final double thickness;
  final Color color;

  DashedLinePainter({
    required this.width,
    required this.gap,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    PathMetrics pathMetrics = path.computeMetrics();
    Path draw = Path();
    for (PathMetric pathMetric in pathMetrics) {
      for (double i = 0; i < pathMetric.length; i += gap + width) {
        double start = i;
        double end = i + width;
        if (end > pathMetric.length) {
          end = pathMetric.length;
        }
        draw.addPath(
          pathMetric.extractPath(start, end),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(
      draw,
      Paint()
        ..color = color
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.gap != gap ||
        oldDelegate.thickness != thickness ||
        oldDelegate.color != color;
  }
}

class DashedPainter extends CustomPainter {
  final double width;
  final double gap;
  final double thickness;
  final Color color;
  final BorderRadius? borderRadius;

  DashedPainter({
    required this.width,
    required this.gap,
    required this.thickness,
    required this.color,
    this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    if (borderRadius != null && borderRadius != BorderRadius.zero) {
      path.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        topLeft: borderRadius!.topLeft,
        topRight: borderRadius!.topRight,
        bottomLeft: borderRadius!.bottomLeft,
        bottomRight: borderRadius!.bottomRight,
      ));
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    PathMetrics pathMetrics = path.computeMetrics();
    Path draw = Path();
    for (PathMetric pathMetric in pathMetrics) {
      for (double i = 0; i < pathMetric.length; i += gap + width) {
        double start = i;
        double end = i + width;
        if (end > pathMetric.length) {
          end = pathMetric.length;
        }
        draw.addPath(
          pathMetric.extractPath(start, end),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(
      draw,
      Paint()
        ..color = color
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant DashedPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.gap != gap ||
        oldDelegate.thickness != thickness ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
