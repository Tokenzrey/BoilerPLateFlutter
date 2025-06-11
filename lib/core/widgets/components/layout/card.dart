// import 'package:boilerplate/core/widgets/components/layout/outlined_container.dart';
// import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
// import 'package:flutter/material.dart';

// class Card extends StatelessWidget {
//   final Widget child;
//   final EdgeInsetsGeometry? padding;
//   final bool filled;
//   final Color? fillColor;
//   final BorderRadiusGeometry? borderRadius;
//   final Color? borderColor;
//   final double? borderWidth;
//   final Clip clipBehavior;
//   final List<BoxShadow>? boxShadow;
//   final double? surfaceOpacity;
//   final double? surfaceBlur;
//   final Duration? duration;

//   const Card({
//     super.key,
//     required this.child,
//     this.padding,
//     this.filled = false,
//     this.fillColor,
//     this.borderRadius,
//     this.clipBehavior = Clip.none,
//     this.borderColor,
//     this.borderWidth,
//     this.boxShadow,
//     this.surfaceOpacity,
//     this.surfaceBlur,
//     this.duration,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return OutlinedContainer(
//       clipBehavior: clipBehavior,
//       borderRadius: borderRadius,
//       borderWidth: borderWidth,
//       borderColor: borderColor,
//       backgroundColor: filled
//           ? fillColor ?? theme.colorScheme.outline
//           : theme.colorScheme.surfaceContainer,
//       boxShadow: boxShadow,
//       padding: padding ?? (EdgeInsets.all(16)),
//       surfaceOpacity: surfaceOpacity,
//       surfaceBlur: surfaceBlur,
//       duration: duration,
//       child: DefaultTextStyle.merge(
//         child: child,
//         style: TextStyle(
//           color: theme.colorScheme.surfaceContainer,
//         ),
//       ),
//     );
//   }
// }

// class SurfaceCard extends StatelessWidget {
//   final Widget child;
//   final EdgeInsetsGeometry? padding;
//   final bool filled;
//   final Color? fillColor;
//   final BorderRadiusGeometry? borderRadius;
//   final Color? borderColor;
//   final double? borderWidth;
//   final Clip clipBehavior;
//   final List<BoxShadow>? boxShadow;
//   final double? surfaceOpacity;
//   final double? surfaceBlur;
//   final Duration? duration;

//   const SurfaceCard({
//     super.key,
//     required this.child,
//     this.padding,
//     this.filled = false,
//     this.fillColor,
//     this.borderRadius,
//     this.clipBehavior = Clip.none,
//     this.borderColor,
//     this.borderWidth,
//     this.boxShadow,
//     this.surfaceOpacity,
//     this.surfaceBlur,
//     this.duration,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var isSheetOverlay = SheetOverlayHandler.isSheetOverlay(context);
//     var padding = this.padding;
//     if (isSheetOverlay) {
//       return Padding(
//         padding: padding ?? (EdgeInsets.all(16)),
//         child: child,
//       );
//     }
//     return Card(
//       clipBehavior: clipBehavior,
//       borderRadius: borderRadius,
//       borderWidth: borderWidth,
//       borderColor: borderColor,
//       filled: filled,
//       fillColor: fillColor,
//       boxShadow: boxShadow,
//       padding: padding,
//       surfaceOpacity: surfaceOpacity ?? 0.14,
//       surfaceBlur: surfaceBlur ?? 0.5,
//       duration: duration,
//       child: child,
//     );
//   }
// }
