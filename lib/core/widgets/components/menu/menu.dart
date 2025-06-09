// import 'package:boilerplate/core/widgets/components/display/keyboard_shortcut.dart';
// import 'package:boilerplate/core/widgets/components/layout/basic.dart';
// import 'package:boilerplate/core/widgets/components/menu/menubar.dart';
// import 'package:boilerplate/core/widgets/components/menu/popup.dart';
// import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
// import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
// import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
// import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
// import 'package:boilerplate/core/widgets/utils.dart';
// import 'package:data_widget/data_widget.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gap/gap.dart';

// // Added RadixIcons class to fix icon references
// class RadixIcons {
//   static const IconData check = Icons.check;
//   static const IconData dotFilled = Icons.circle;
//   static const IconData chevronRight = Icons.chevron_right;
// }

// // Added extension methods for Icon formatting
// extension IconExtensions on Icon {
//   Widget iconSmall() {
//     return SizedBox(
//       width: 16,
//       height: 16,
//       child: this,
//     );
//   }
// }

// // Added extension methods for Widget styling
// extension WidgetStyleExtensions on Widget {
//   Widget iconSmall() {
//     if (this is Icon) {
//       return (this as Icon).iconSmall();
//     }
//     return SizedBox(
//       width: 16,
//       height: 16,
//       child: this,
//     );
//   }

//   Widget semiBold() {
//     return DefaultTextStyle.merge(
//       style: const TextStyle(fontWeight: FontWeight.w600),
//       child: this,
//     );
//   }

//   Widget gap(double space) {
//     return Padding(
//       padding: EdgeInsets.all(space / 2),
//       child: this,
//     );
//   }
// }

// // Added ButtonVariance enum
// enum ButtonVariance {
//   menu,
//   menubar;

//   ButtonStyle copyWith({
//     WidgetStateProperty<EdgeInsetsGeometry?>? padding,
//     WidgetStateProperty<BoxDecoration?>? decoration,
//   }) {
//     return ButtonStyle(
//       padding: padding,
//       backgroundColor: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.hovered)) {
//           return Colors.grey.withValues(alpha: 0.1);
//         }
//         return null;
//       }),
//     );
//   }
// }

// // Added Button widget
// class ButtonMenu extends StatelessWidget {
//   final Widget? child;
//   final Widget? leading;
//   final Widget? trailing;
//   final VoidCallback? onPressed;
//   final ValueChanged<bool>? onHover;
//   final ValueChanged<bool>? onFocus;
//   final bool enabled;
//   final bool disableTransition;
//   final bool disableFocusOutline;
//   final AlignmentGeometry alignment;
//   final FocusNode? focusNode;
//   final ButtonStyle? style;

//   const ButtonMenu({
//     super.key,
//     this.child,
//     this.leading,
//     this.trailing,
//     this.onPressed,
//     this.onHover,
//     this.onFocus,
//     this.enabled = true,
//     this.disableTransition = false,
//     this.disableFocusOutline = false,
//     this.alignment = Alignment.center,
//     this.focusNode,
//     this.style,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: enabled ? onPressed : null,
//       onHover: onHover,
//       onFocusChange: onFocus,
//       focusNode: focusNode,
//       style: style,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (leading != null) leading!,
//           if (child != null)
//             Expanded(
//               child: Align(
//                 alignment: alignment,
//                 child: child!,
//               ),
//             ),
//           if (trailing != null) trailing!,
//         ],
//       ),
//     );
//   }
// }

// class MenuShortcut extends StatelessWidget {
//   final ShortcutActivator activator;
//   final Widget? combiner;

//   const MenuShortcut({super.key, required this.activator, this.combiner});

//   @override
//   Widget build(BuildContext context) {
//     var activator = this.activator;
//     var combiner = this.combiner ?? const Text(' + ');
//     final displayMapper = Data.maybeOf<KeyboardShortcutDisplayHandle>(context);
//     final theme = Theme.of(context);

//     assert(displayMapper != null, 'Cannot find KeyboardShortcutDisplayMapper');
//     List<LogicalKeyboardKey> keys = shortcutActivatorToKeySet(activator);
//     List<Widget> children = [];
//     for (int i = 0; i < keys.length; i++) {
//       if (i > 0) {
//         children.add(combiner);
//       }
//       children.add(displayMapper!.buildKeyboardDisplay(context, keys[i]));
//     }
//     return DefaultTextStyle.merge(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: children,
//       ),
//       style: TextStyle(
//         fontSize: 12,
//         fontWeight: theme.textTheme.labelMedium?.fontWeight,
//         color: theme.colorScheme.surfaceContainer,
//       ),
//     );
//   }
// }

// abstract class MenuItem extends Widget {
//   const MenuItem({super.key});

//   bool get hasLeading;
//   PopoverController? get popoverController;
// }

// class MenuRadioGroup<T> extends StatelessWidget implements MenuItem {
//   final T? value;
//   final ContextedValueChanged<T>? onChanged;
//   final List<Widget> children;

//   const MenuRadioGroup({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     required this.children,
//   });

//   @override
//   bool get hasLeading => children.isNotEmpty;

//   @override
//   PopoverController? get popoverController => null;

//   @override
//   Widget build(BuildContext context) {
//     final menuGroupData = Data.maybeOf<MenuGroupData>(context);
//     assert(
//         menuGroupData != null, 'MenuRadioGroup must be a child of MenuGroup');
//     return Data<MenuRadioGroup<T>>.inherit(
//       data: this,
//       child: Flex(
//         direction: menuGroupData!.direction,
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: children,
//       ),
//     );
//   }
// }

// class MenuRadio<T> extends StatelessWidget {
//   final T value;
//   final Widget child;
//   final Widget? trailing;
//   final FocusNode? focusNode;
//   final bool enabled;
//   final bool autoClose;

//   const MenuRadio({
//     super.key,
//     required this.value,
//     required this.child,
//     this.trailing,
//     this.focusNode,
//     this.enabled = true,
//     this.autoClose = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final radioGroup = Data.maybeOf<MenuRadioGroup<T>>(context);
//     assert(radioGroup != null, 'MenuRadio must be a child of MenuRadioGroup');
//     return Data<MenuRadioGroup<T>>.boundary(
//       child: MenuButton(
//         leading: radioGroup!.value == value
//             ? SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: const Icon(
//                   RadixIcons.dotFilled,
//                 ).iconSmall(),
//               )
//             : SizedBox(width: 16),
//         onPressed: (context) {
//           radioGroup.onChanged?.call(context, value);
//         },
//         enabled: enabled,
//         focusNode: focusNode,
//         autoClose: autoClose,
//         trailing: trailing,
//         child: child,
//       ),
//     );
//   }
// }

// class MenuDivider extends StatelessWidget implements MenuItem {
//   const MenuDivider({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final menuGroupData = Data.maybeOf<MenuGroupData>(context);
//     final theme = Theme.of(context);
//     return AnimatedPadding(
//       duration: kDefaultDuration,
//       padding:
//           (menuGroupData == null || menuGroupData.direction == Axis.vertical
//               ? const EdgeInsets.symmetric(vertical: 4)
//               : const EdgeInsets.symmetric(horizontal: 4)),
//       child: menuGroupData == null || menuGroupData.direction == Axis.vertical
//           ? Divider(
//               height: 1,
//               thickness: 1,
//               indent: -4,
//               endIndent: -4,
//               color: theme.colorScheme.outline,
//             )
//           : VerticalDivider(
//               width: 1,
//               thickness: 1,
//               color: theme.colorScheme.outline,
//               indent: -4,
//               endIndent: -4,
//             ),
//     );
//   }

//   @override
//   bool get hasLeading => false;

//   @override
//   PopoverController? get popoverController => null;
// }

// class MenuGap extends StatelessWidget implements MenuItem {
//   final double size;

//   const MenuGap(this.size, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Gap(size);
//   }

//   @override
//   bool get hasLeading => false;

//   @override
//   PopoverController? get popoverController => null;
// }

// class MenuButton extends StatefulWidget implements MenuItem {
//   final Widget child;
//   final List<MenuItem>? subMenu;
//   final ContextedCallback? onPressed;
//   final Widget? trailing;
//   final Widget? leading;
//   final bool enabled;
//   final FocusNode? focusNode;
//   final bool autoClose;
//   @override
//   final PopoverController? popoverController;
//   const MenuButton({
//     super.key,
//     required this.child,
//     this.subMenu,
//     this.onPressed,
//     this.trailing,
//     this.leading,
//     this.enabled = true,
//     this.focusNode,
//     this.autoClose = true,
//     this.popoverController,
//   });

//   @override
//   State<MenuButton> createState() => _MenuButtonState();

//   @override
//   bool get hasLeading => leading != null;
// }

// class MenuLabel extends StatelessWidget implements MenuItem {
//   final Widget child;
//   final Widget? trailing;
//   final Widget? leading;

//   const MenuLabel({
//     super.key,
//     required this.child,
//     this.trailing,
//     this.leading,
//   });

//   @override
//   bool get hasLeading => leading != null;

//   @override
//   PopoverController? get popoverController => null;

//   @override
//   Widget build(BuildContext context) {
//     final menuGroupData = Data.maybeOf<MenuGroupData>(context);
//     assert(menuGroupData != null, 'MenuLabel must be a child of MenuGroup');
//     return Padding(
//       padding: const EdgeInsets.only(left: 8, top: 6, right: 6, bottom: 6) +
//           menuGroupData!.itemPadding,
//       child: Basic(
//         contentSpacing: 8,
//         leading: leading == null && menuGroupData.hasLeading
//             ? SizedBox(width: 16)
//             : leading == null
//                 ? null
//                 : SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: leading!.iconSmall(),
//                   ),
//         trailing: trailing,
//         content: child.semiBold(),
//         trailingAlignment: Alignment.center,
//         leadingAlignment: Alignment.center,
//         contentAlignment: menuGroupData.direction == Axis.vertical
//             ? AlignmentDirectional.centerStart
//             : Alignment.center,
//       ),
//     );
//   }
// }

// class MenuCheckbox extends StatelessWidget implements MenuItem {
//   final bool value;
//   final ContextedValueChanged<bool>? onChanged;
//   final Widget child;
//   final Widget? trailing;
//   final FocusNode? focusNode;
//   final bool enabled;
//   final bool autoClose;

//   const MenuCheckbox({
//     super.key,
//     this.value = false,
//     this.onChanged,
//     required this.child,
//     this.trailing,
//     this.focusNode,
//     this.enabled = true,
//     this.autoClose = true,
//   });

//   @override
//   bool get hasLeading => true;
//   @override
//   PopoverController? get popoverController => null;

//   @override
//   Widget build(BuildContext context) {
//     return MenuButton(
//       leading: value
//           ? SizedBox(
//               width: 16,
//               height: 16,
//               child: const Icon(
//                 RadixIcons.check,
//               ).iconSmall(),
//             )
//           : SizedBox(width: 16),
//       onPressed: (context) {
//         onChanged?.call(context, !value);
//       },
//       enabled: enabled,
//       focusNode: focusNode,
//       autoClose: autoClose,
//       trailing: trailing,
//       child: child,
//     );
//   }
// }

// class _MenuButtonState extends State<MenuButton> {
//   late FocusNode _focusNode;
//   final ValueNotifier<List<MenuItem>> _children = ValueNotifier([]);

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _children.value = widget.subMenu ?? [];
//   }

//   @override
//   void didUpdateWidget(covariant MenuButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.focusNode != oldWidget.focusNode) {
//       _focusNode = widget.focusNode ?? FocusNode();
//     }
//     if (!listEquals(widget.subMenu, oldWidget.subMenu)) {
//       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//         if (mounted) {
//           _children.value = widget.subMenu ?? [];
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final menuBarData = Data.maybeOf<MenubarState>(context);
//     final menuData = Data.maybeOf<MenuData>(context);
//     final menuGroupData = Data.maybeOf<MenuGroupData>(context);
//     assert(menuGroupData != null, 'MenuButton must be a child of MenuGroup');
//     // final dialogOverlayHandler = Data.maybeOf<DialogOverlayHandler>(context);
//     final isSheetOverlay = SheetOverlayHandler.isSheetOverlay(context);
//     final isDialogOverlay = DialogOverlayHandler.isDialogOverlay(context);
//     final isIndependentOverlay = isSheetOverlay || isDialogOverlay;
//     void openSubMenu(BuildContext context) {
//       menuGroupData!.closeOthers();
//       final overlayManager = OverlayManager.of(context);
//       menuData!.popoverController.show(
//         context: context,
//         regionGroupId: menuGroupData.regionGroupId,
//         consumeOutsideTaps: false,
//         dismissBackdropFocus: false,
//         modal: true,
//         handler: MenuOverlayHandler(overlayManager),
//         overlayBarrier: OverlayBarrier(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         builder: (context) {
//           var itemPadding = menuGroupData.itemPadding;
//           final isSheetOverlay = SheetOverlayHandler.isSheetOverlay(context);
//           if (isSheetOverlay) {
//             itemPadding = const EdgeInsets.symmetric(horizontal: 8);
//           }
//           return ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 192, // 12rem
//             ),
//             child: AnimatedBuilder(
//                 animation: _children,
//                 builder: (context, child) {
//                   return MenuGroup(
//                       direction: menuGroupData.direction,
//                       parent: menuGroupData,
//                       onDismissed: menuGroupData.onDismissed,
//                       regionGroupId: menuGroupData.regionGroupId,
//                       subMenuOffset: const Offset(8, -4 + -1),
//                       itemPadding: itemPadding,
//                       builder: (context, children) {
//                         return MenuPopup(
//                           children: children,
//                         );
//                       },
//                       children: _children.value);
//                 }),
//           );
//         },
//         alignment: Alignment.topLeft,
//         anchorAlignment:
//             menuBarData != null ? Alignment.bottomLeft : Alignment.topRight,
//         offset: menuGroupData.subMenuOffset,
//       );
//     }

//     return Data<MenuData>.boundary(
//       child: Data<MenubarState>.boundary(
//         child: TapRegion(
//           groupId: menuGroupData!.root,
//           child: AnimatedBuilder(
//               animation: menuData!.popoverController,
//               builder: (context, child) {
//                 return ButtonMenu(
//                   disableFocusOutline: true,
//                   alignment: menuGroupData.direction == Axis.vertical
//                       ? AlignmentDirectional.centerStart
//                       : Alignment.center,
//                   style: (menuBarData == null
//                           ? ButtonVariance.menu
//                           : ButtonVariance.menubar)
//                       .copyWith(
//                     padding: WidgetStateProperty.resolveWith((states) {
//                       // Get default padding and add itemPadding
//                       final defaultPadding = EdgeInsets.zero;
//                       return defaultPadding + menuGroupData.itemPadding;
//                     }),
//                     decoration: WidgetStateProperty.resolveWith((states) {
//                       final theme = Theme.of(context);
//                       return BoxDecoration(
//                         color: menuData.popoverController.hasOpenPopover
//                             ? theme.colorScheme.onSecondary
//                             : null,
//                         borderRadius: BorderRadius.circular(12),
//                       );
//                     }),
//                   ),
//                   trailing: menuBarData != null
//                       ? widget.trailing
//                       : widget.trailing != null ||
//                               (widget.subMenu != null && menuBarData == null)
//                           ? Row(
//                               children: [
//                                 if (widget.trailing != null) widget.trailing!,
//                                 if (widget.subMenu != null &&
//                                     menuBarData == null)
//                                   const Icon(
//                                     RadixIcons.chevronRight,
//                                   ).iconSmall(),
//                               ],
//                             ).gap(8)
//                           : null,
//                   leading: widget.leading == null &&
//                           menuGroupData.hasLeading &&
//                           menuBarData == null
//                       ? SizedBox(width: 16)
//                       : widget.leading == null
//                           ? null
//                           : SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: widget.leading!.iconSmall(),
//                             ),
//                   disableTransition: true,
//                   enabled: widget.enabled,
//                   focusNode: _focusNode,
//                   onHover: (value) {
//                     if (value) {
//                       if ((menuBarData == null ||
//                               menuGroupData.hasOpenPopovers) &&
//                           widget.subMenu != null &&
//                           widget.subMenu!.isNotEmpty) {
//                         if (!menuData.popoverController.hasOpenPopover &&
//                             !isIndependentOverlay) {
//                           openSubMenu(context);
//                         }
//                       } else {
//                         menuGroupData.closeOthers();
//                       }
//                     }
//                   },
//                   onFocus: (value) {
//                     if (value) {
//                       if (widget.subMenu != null &&
//                           widget.subMenu!.isNotEmpty) {
//                         if (!menuData.popoverController.hasOpenPopover &&
//                             !isIndependentOverlay) {
//                           openSubMenu(context);
//                         }
//                       } else {
//                         menuGroupData.closeOthers();
//                       }
//                     }
//                   },
//                   onPressed: () {
//                     widget.onPressed?.call(context);
//                     if (widget.subMenu != null && widget.subMenu!.isNotEmpty) {
//                       if (!menuData.popoverController.hasOpenPopover) {
//                         openSubMenu(context);
//                       }
//                     } else {
//                       if (widget.autoClose) {
//                         menuGroupData.closeAll();
//                       }
//                     }
//                   },
//                   child: widget.child,
//                 );
//               }),
//         ),
//       ),
//     );
//   }
// }

// class MenuGroupData {
//   final MenuGroupData? parent;
//   final List<MenuData> children;
//   final bool hasLeading;
//   final Offset? subMenuOffset;
//   final VoidCallback? onDismissed;
//   final Object? regionGroupId;
//   final Axis direction;
//   final EdgeInsets itemPadding;

//   MenuGroupData(this.parent, this.children, this.hasLeading, this.subMenuOffset,
//       this.onDismissed, this.regionGroupId, this.direction, this.itemPadding);

//   bool get hasOpenPopovers {
//     for (final child in children) {
//       if (child.popoverController.hasOpenPopover) {
//         return true;
//       }
//     }
//     return false;
//   }

//   void closeOthers() {
//     for (final child in children) {
//       child.popoverController.close();
//     }
//   }

//   void closeAll() {
//     var menuGroupData = parent;
//     if (menuGroupData == null) {
//       onDismissed?.call();
//       return;
//     }
//     menuGroupData.closeOthers();
//     menuGroupData.closeAll();
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     if (other is MenuGroupData) {
//       return listEquals(children, other.children) &&
//           parent == other.parent &&
//           hasLeading == other.hasLeading &&
//           subMenuOffset == other.subMenuOffset &&
//           onDismissed == other.onDismissed;
//     }
//     return false;
//   }

//   MenuGroupData get root {
//     var menuGroupData = parent;
//     if (menuGroupData == null) {
//       return this;
//     }
//     return menuGroupData.root;
//   }

//   @override
//   int get hashCode => Object.hash(
//         children,
//         parent,
//         hasLeading,
//         subMenuOffset,
//         onDismissed,
//       );

//   @override
//   String toString() {
//     return 'MenuGroupData{parent: $parent, children: $children, hasLeading: $hasLeading, subMenuOffset: $subMenuOffset, onDismissed: $onDismissed, regionGroupId: $regionGroupId, direction: $direction}';
//   }
// }

// class MenuData {
//   final PopoverController popoverController;

//   MenuData({PopoverController? popoverController})
//       : popoverController = popoverController ?? PopoverController();
// }

// class MenuGroup extends StatefulWidget {
//   final List<MenuItem> children;
//   final Widget Function(BuildContext context, List<Widget> children) builder;
//   final MenuGroupData? parent;
//   final Offset? subMenuOffset;
//   final VoidCallback? onDismissed;
//   final Object? regionGroupId;
//   final Axis direction;
//   final Map<Type, Action> actions;
//   final EdgeInsets itemPadding;

//   const MenuGroup({
//     super.key,
//     required this.children,
//     required this.builder,
//     this.parent,
//     this.subMenuOffset,
//     this.onDismissed,
//     this.regionGroupId,
//     this.actions = const {},
//     required this.direction,
//     required this.itemPadding,
//   });

//   @override
//   State<MenuGroup> createState() => _MenuGroupState();
// }

// class _MenuGroupState extends State<MenuGroup> {
//   final FocusScopeNode _focusScopeNode = FocusScopeNode();
//   late List<MenuData> _data;

//   @override
//   void initState() {
//     super.initState();
//     _data = List.generate(widget.children.length, (i) {
//       return MenuData();
//     });
//   }

//   @override
//   void didUpdateWidget(covariant MenuGroup oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!listEquals(oldWidget.children, widget.children)) {
//       Map<Key, MenuData> oldKeyedData = {};
//       for (int i = 0; i < oldWidget.children.length; i++) {
//         oldKeyedData[oldWidget.children[i].key ?? ValueKey(i)] = _data[i];
//       }
//       _data = List.generate(widget.children.length, (i) {
//         var child = widget.children[i];
//         var key = child.key ?? ValueKey(i);
//         var oldData = oldKeyedData[key];
//         if (oldData != null) {
//           if (child.popoverController != null &&
//               oldData.popoverController != child.popoverController) {
//             oldData.popoverController.dispose();
//             oldData = MenuData(popoverController: child.popoverController);
//           }
//         } else {
//           oldData = MenuData(popoverController: child.popoverController);
//         }
//         return oldData;
//       });
//       // dispose unused data
//       for (var data in oldKeyedData.values) {
//         if (!_data.contains(data)) {
//           data.popoverController.dispose();
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     for (var data in _data) {
//       data.popoverController.dispose();
//     }
//     super.dispose();
//   }

//   void closeAll() {
//     MenuGroupData? data = widget.parent;
//     if (data == null) {
//       widget.onDismissed?.call();
//       return;
//     }
//     data.closeOthers();
//     data.closeAll();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> children = [];
//     bool hasLeading = false;
//     for (int i = 0; i < widget.children.length; i++) {
//       final child = widget.children[i];
//       final data = _data[i];
//       if (child.hasLeading) {
//         hasLeading = true;
//       }
//       children.add(
//         Data<MenuData>.inherit(
//           data: data,
//           child: child,
//         ),
//       );
//     }
//     return Shortcuts(
//       shortcuts: {
//         if (widget.direction == Axis.vertical)
//           const SingleActivator(LogicalKeyboardKey.arrowUp):
//               const PreviousFocusIntent(),
//         if (widget.direction == Axis.vertical)
//           const SingleActivator(LogicalKeyboardKey.arrowDown):
//               const NextFocusIntent(),
//         if (widget.direction == Axis.vertical)
//           const SingleActivator(LogicalKeyboardKey.arrowLeft):
//               const PreviousSiblingFocusIntent(),
//         if (widget.direction == Axis.vertical)
//           const SingleActivator(LogicalKeyboardKey.arrowRight):
//               const NextSiblingFocusIntent(),
//         if (widget.direction == Axis.horizontal)
//           const SingleActivator(LogicalKeyboardKey.arrowLeft):
//               const PreviousFocusIntent(),
//         if (widget.direction == Axis.horizontal)
//           const SingleActivator(LogicalKeyboardKey.arrowRight):
//               const NextFocusIntent(),
//         if (widget.direction == Axis.horizontal)
//           const SingleActivator(LogicalKeyboardKey.arrowUp):
//               const PreviousSiblingFocusIntent(),
//         if (widget.direction == Axis.horizontal)
//           const SingleActivator(LogicalKeyboardKey.arrowDown):
//               const NextSiblingFocusIntent(),
//         const SingleActivator(LogicalKeyboardKey.escape):
//             const CloseMenuIntent(),
//       },
//       child: Actions(
//         actions: {
//           PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
//             onInvoke: (intent) {
//               if (widget.direction == Axis.vertical) {
//                 _focusScopeNode.focusInDirection(TraversalDirection.up);
//               } else {
//                 _focusScopeNode.focusInDirection(TraversalDirection.left);
//               }
//               return;
//             },
//           ),
//           NextFocusIntent: CallbackAction<NextFocusIntent>(
//             onInvoke: (intent) {
//               if (widget.direction == Axis.vertical) {
//                 _focusScopeNode.focusInDirection(TraversalDirection.down);
//               } else {
//                 _focusScopeNode.focusInDirection(TraversalDirection.right);
//               }
//               return;
//             },
//           ),
//           CloseMenuIntent: CallbackAction<CloseMenuIntent>(
//             onInvoke: (intent) {
//               closeAll();
//               return;
//             },
//           ),
//           ...widget.actions,
//         },
//         child: FocusScope(
//           autofocus: true,
//           node: _focusScopeNode,
//           child: Data.inherit(
//             data: MenuGroupData(
//               widget.parent,
//               _data,
//               hasLeading,
//               widget.subMenuOffset,
//               widget.onDismissed,
//               widget.regionGroupId,
//               widget.direction,
//               widget.itemPadding,
//             ),
//             child: widget.builder(context, children),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CloseMenuIntent extends Intent {
//   const CloseMenuIntent();
// }

// class PreviousSiblingFocusIntent extends Intent {
//   const PreviousSiblingFocusIntent();
// }

// class NextSiblingFocusIntent extends Intent {
//   const NextSiblingFocusIntent();
// }

// class MenuOverlayHandler extends OverlayHandler {
//   final OverlayManager manager;

//   const MenuOverlayHandler(this.manager);

//   @override
//   OverlayCompleter<T?> show<T>({
//     required BuildContext context,
//     required AlignmentGeometry alignment,
//     required WidgetBuilder builder,
//     Offset? position,
//     AlignmentGeometry? anchorAlignment,
//     PopoverConstraint widthConstraint = PopoverConstraint.flexible,
//     PopoverConstraint heightConstraint = PopoverConstraint.flexible,
//     Key? key,
//     bool rootOverlay = true,
//     bool modal = true,
//     bool barrierDismissable = true,
//     Clip clipBehavior = Clip.none,
//     Object? regionGroupId,
//     Offset? offset,
//     AlignmentGeometry? transitionAlignment,
//     EdgeInsetsGeometry? margin,
//     bool follow = true,
//     bool consumeOutsideTaps = true,
//     ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
//     bool allowInvertHorizontal = true,
//     bool allowInvertVertical = true,
//     bool dismissBackdropFocus = true,
//     Duration? showDuration,
//     Duration? dismissDuration,
//     OverlayBarrier? overlayBarrier,
//     LayerLink? layerLink,
//     Size? fixedSize,
//   }) {
//     return manager.showMenu(
//       context: context,
//       alignment: alignment,
//       builder: builder,
//       position: position,
//       anchorAlignment: anchorAlignment,
//       widthConstraint: widthConstraint,
//       heightConstraint: heightConstraint,
//       key: key,
//       rootOverlay: rootOverlay,
//       modal: modal,
//       barrierDismissable: barrierDismissable,
//       clipBehavior: clipBehavior,
//       regionGroupId: regionGroupId,
//       offset: offset,
//       transitionAlignment: transitionAlignment,
//       margin: margin,
//       follow: follow,
//       consumeOutsideTaps: consumeOutsideTaps,
//       onTickFollow: onTickFollow,
//       allowInvertHorizontal: allowInvertHorizontal,
//       allowInvertVertical: allowInvertVertical,
//       dismissBackdropFocus: dismissBackdropFocus,
//       showDuration: showDuration,
//       dismissDuration: dismissDuration,
//       overlayBarrier: overlayBarrier,
//       layerLink: layerLink,
//     );
//   }
// }

// // Define this extension method if not available elsewhere
// extension MaterialStatePropertyExtension<T> on WidgetStateProperty<T> {
//   T optionallyResolve(BuildContext context) {
//     return resolve({});
//   }
// }
