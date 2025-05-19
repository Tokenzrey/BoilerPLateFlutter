import 'package:boilerplate/core/widgets/components/menu/menu.dart';
import 'package:boilerplate/core/widgets/components/menu/popup.dart';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:data_widget/data_widget.dart';
import 'package:flutter/material.dart';

OverlayCompleter<T?> showDropdown<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Offset? position,
  AlignmentGeometry? anchorAlignment,
  PopoverConstraint widthConstraint = PopoverConstraint.flexible,
  PopoverConstraint heightConstraint = PopoverConstraint.flexible,
  Key? key,
  bool rootOverlay = true,
  bool modal = true,
  Clip clipBehavior = Clip.none,
  Object? regionGroupId,
  Offset? offset,
  AlignmentGeometry? transitionAlignment,
  EdgeInsetsGeometry? margin,
  bool follow = true,
  bool consumeOutsideTaps = false,
  ValueChanged<PopoverOverlayWidgetState>? onTickFollow,
  bool allowInvertHorizontal = true,
  bool allowInvertVertical = true,
  bool dismissBackdropFocus = true,
  Duration? showDuration,
  Duration? dismissDuration,
}) {
  final GlobalKey key = GlobalKey();
  final overlayManager = OverlayManager.of(context);
  return overlayManager.showMenu<T>(
    context: context,
    alignment: Alignment.topCenter,
    offset: offset ?? (const Offset(0, 4)),
    follow: follow,
    clipBehavior: clipBehavior,
    margin: margin,
    transitionAlignment: transitionAlignment,
    onTickFollow: onTickFollow,
    allowInvertHorizontal: allowInvertHorizontal,
    allowInvertVertical: allowInvertVertical,
    showDuration: showDuration,
    dismissDuration: dismissDuration,
    widthConstraint: widthConstraint,
    heightConstraint: heightConstraint,
    position: position,
    anchorAlignment: anchorAlignment,
    consumeOutsideTaps: consumeOutsideTaps,
    regionGroupId: key,
    modal: modal,
    dismissBackdropFocus: dismissBackdropFocus,
    overlayBarrier: OverlayBarrier(
      borderRadius: BorderRadius.circular(12),
    ),
    builder: (context) {
      return Data.inherit(
        data: DropdownMenuData(key),
        child: builder(context),
      );
    },
  );
}

class DropdownMenuData {
  final GlobalKey key;

  DropdownMenuData(this.key);
}

class DropdownMenu extends StatefulWidget {
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final List<MenuItem> children;

  const DropdownMenu({
    super.key,
    this.surfaceOpacity,
    this.surfaceBlur,
    required this.children,
  });

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  @override
  Widget build(BuildContext context) {
    final isSheetOverlay = SheetOverlayHandler.isSheetOverlay(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 192,
      ),
      child: MenuGroup(
        regionGroupId: Data.maybeOf<DropdownMenuData>(context)?.key,
        subMenuOffset: const Offset(8, -4),
        itemPadding: isSheetOverlay
            ? const EdgeInsets.symmetric(horizontal: 8)
            : EdgeInsets.zero,
        onDismissed: () {
          closeOverlay(context);
        },
        direction: Axis.vertical,
        builder: (context, children) {
          return MenuPopup(
            // does not need to check for theme.surfaceOpacity and theme.surfaceBlur
            // MenuPopup already has default values for these properties
            surfaceOpacity: widget.surfaceOpacity,
            surfaceBlur: widget.surfaceBlur,
            children: children,
          );
        },
        children: widget.children,
      ),
    );
  }
}
