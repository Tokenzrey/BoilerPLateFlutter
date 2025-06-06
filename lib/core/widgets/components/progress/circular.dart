import 'package:flutter/material.dart';

class AppCircularProgress extends StatelessWidget {
  final double? value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;
  final Widget? center;
  final Duration animationDuration;
  final String? semanticLabel;

  const AppCircularProgress({
    super.key,
    this.value,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.percentageTextStyle,
    this.center,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.semanticLabel,
  });

  factory AppCircularProgress.small({
    Key? key,
    double? value,
    Color? color,
    Color? backgroundColor,
    bool showPercentage = false,
    TextStyle? percentageTextStyle,
    Widget? center,
    String? semanticLabel,
  }) {
    return AppCircularProgress(
      key: key,
      value: value,
      size: 24.0,
      strokeWidth: 2.5,
      color: color,
      backgroundColor: backgroundColor,
      showPercentage: showPercentage,
      percentageTextStyle: percentageTextStyle,
      center: center,
      semanticLabel: semanticLabel,
    );
  }

  factory AppCircularProgress.medium({
    Key? key,
    double? value,
    Color? color,
    Color? backgroundColor,
    bool showPercentage = false,
    TextStyle? percentageTextStyle,
    Widget? center,
    String? semanticLabel,
  }) {
    return AppCircularProgress(
      key: key,
      value: value,
      size: 40.0,
      strokeWidth: 4.0,
      color: color,
      backgroundColor: backgroundColor,
      showPercentage: showPercentage,
      percentageTextStyle: percentageTextStyle,
      center: center,
      semanticLabel: semanticLabel,
    );
  }

  factory AppCircularProgress.large({
    Key? key,
    double? value,
    Color? color,
    Color? backgroundColor,
    bool showPercentage = false,
    TextStyle? percentageTextStyle,
    Widget? center,
    String? semanticLabel,
  }) {
    return AppCircularProgress(
      key: key,
      value: value,
      size: 60.0,
      strokeWidth: 5.0,
      color: color,
      backgroundColor: backgroundColor,
      showPercentage: showPercentage,
      percentageTextStyle: percentageTextStyle,
      center: center,
      semanticLabel: semanticLabel,
    );
  }

  factory AppCircularProgress.overlay({
    Key? key,
    double? value,
    Color? color,
    Color? backgroundColor,
    Color overlayColor = Colors.black26,
    double size = 50.0,
    double strokeWidth = 4.0,
    bool showPercentage = false,
    TextStyle? percentageTextStyle,
    Widget? center,
    String? semanticLabel,
  }) {
    return AppCircularProgress._overlay(
      key: key,
      value: value,
      size: size,
      strokeWidth: strokeWidth,
      color: color,
      backgroundColor: backgroundColor,
      overlayColor: overlayColor,
      showPercentage: showPercentage,
      percentageTextStyle: percentageTextStyle,
      center: center,
      semanticLabel: semanticLabel,
    );
  }

  const AppCircularProgress._overlay({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    required Color overlayColor,
    required this.showPercentage,
    required this.percentageTextStyle,
    required this.center,
    required this.semanticLabel,
  }) : animationDuration = const Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color progressColor = color ?? theme.colorScheme.primary;
    final Color trackColor = backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25);

    Widget progressIndicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        color: progressColor,
        backgroundColor: trackColor,
        semanticsLabel: semanticLabel,
      ),
    );

    if (center != null || (showPercentage && value != null)) {
      Widget centerWidget;

      if (center != null) {
        centerWidget = center!;
      } else if (showPercentage && value != null) {
        final int percentage = (value! * 100).round();
        centerWidget = Text(
          '$percentage%',
          style: percentageTextStyle ??
              TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
        );
      } else {
        centerWidget = const SizedBox.shrink();
      }

      progressIndicator = Stack(
        alignment: Alignment.center,
        children: [
          progressIndicator,
          centerWidget,
        ],
      );
    }

    return progressIndicator;
  }

  static Widget withLoadingOverlay({
    required Widget child,
    required bool isLoading,
    Color? overlayColor,
    AppCircularProgress? progressIndicator,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: overlayColor ?? Colors.black26,
            child: Center(
              child: progressIndicator ?? AppCircularProgress.medium(),
            ),
          ),
        ),
      ],
    );
  }
}
