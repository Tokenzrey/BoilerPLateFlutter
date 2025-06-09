// import 'package:boilerplate/core/widgets/components/layout/outlined_container.dart';
// import 'package:boilerplate/core/widgets/components/menu/menu.dart';
// import 'package:boilerplate/core/widgets/utils.dart';
// import 'package:data_widget/data_widget.dart';
// import 'package:flutter/material.dart';

// class Menubar extends StatefulWidget {
//   final List<MenuItem> children;
//   final Offset? popoverOffset;
//   final bool border;

//   const Menubar({
//     super.key,
//     this.popoverOffset,
//     this.border = true,
//     required this.children,
//   });

//   @override
//   State<Menubar> createState() => MenubarState();
// }

// class MenubarState extends State<Menubar> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     if (widget.border) {
//       return OutlinedContainer(
//         borderColor: theme.colorScheme.outline,
//         backgroundColor: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         child: AnimatedPadding(
//           duration: kDefaultDuration,
//           padding: const EdgeInsets.all(4),
//           child: buildContainer(context, theme),
//         ),
//       );
//     }
//     return buildContainer(context, theme);
//   }

//   Widget buildContainer(BuildContext context, ThemeData theme) {
//     return Data.inherit(
//       data: this,
//       child: MenuGroup(
//         regionGroupId: this,
//         direction: Axis.vertical,
//         itemPadding: EdgeInsets.zero,
//         subMenuOffset:
//             (widget.border ? const Offset(-4, 8) : const Offset(0, 4)),
//         builder: (context, children) {
//           return DefaultTextStyle.merge(
//             style: const TextStyle(fontSize: 12),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               child: IntrinsicHeight(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   mainAxisSize: MainAxisSize.min,
//                   children: children,
//                 ),
//               ),
//             ),
//           );
//         },
//         children: widget.children,
//       ),
//     );
//   }
// }
